#include <stdio.h>
#include <math.h>

void setup()
{
  Serial.begin (115200) ; // was for debugging
  adc_setup () ;         // setup ADC
  volatile bool flag = false;  // flag for serial
  
  pmc_enable_periph_clk (TC_INTERFACE_ID + 0*3+0) ;  // clock the TC0 channel 0

  TcChannel * t = &(TC0->TC_CHANNEL)[0] ;    // pointer to TC0 registers for its channel 0
  t->TC_CCR = TC_CCR_CLKDIS ;  // disable internal clocking while setup regs
  t->TC_IDR = 0xFFFFFFFF ;     // disable interrupts
  t->TC_SR ;                   // read int status reg to clear pending
  t->TC_CMR = TC_CMR_TCCLKS_TIMER_CLOCK1 |   // use TCLK1 (prescale by 2, = 42MHz)
              TC_CMR_WAVE |                  // waveform mode
              TC_CMR_WAVSEL_UP_RC |          // count-up PWM using RC as threshold
              TC_CMR_EEVT_XC0 |     // Set external events from XC0 (this setup TIOB as output)
              TC_CMR_ACPA_CLEAR | TC_CMR_ACPC_CLEAR |
              TC_CMR_BCPB_CLEAR | TC_CMR_BCPC_CLEAR ;
  
  t->TC_RC =  2625;     // counter resets on RC, so sets period in terms of 42MHz clock
  t->TC_RA =  440 ;     // roughly square wave
  t->TC_CMR = (t->TC_CMR & 0xFFF0FFFF) | TC_CMR_ACPA_CLEAR | TC_CMR_ACPC_SET ;  // set clear and set from RA and RC compares
  
  t->TC_CCR = TC_CCR_CLKEN | TC_CCR_SWTRG ;  // re-enable local clocking and switch to hardware trigger source.

  setup_pio_TIOA0 () ;  // drive Arduino pin 2 at 48kHz to bring clock out
  //dac_setup () ;        // setup up DAC auto-triggered at 48kHz
}

void setup_pio_TIOA0 ()  // Configure Ard pin 2 as output from TC0 channel A (copy of trigger event)
{
  PIOB->PIO_PDR = PIO_PB25B_TIOA0 ;  // disable PIO control
  PIOB->PIO_IDR = PIO_PB25B_TIOA0 ;   // disable PIO interrupts
  PIOB->PIO_ABSR |= PIO_PB25B_TIOA0 ;  // switch to B peripheral
}


void dac_setup (){
  pmc_enable_periph_clk (DACC_INTERFACE_ID) ; // start clocking DAC
  DACC->DACC_CR = DACC_CR_SWRST ;  // reset DAC

  DACC->DACC_MR = 
    DACC_MR_TRGEN_EN | DACC_MR_TRGSEL (1) |  // trigger 1 = TIO output of TC0
    (0 << DACC_MR_USER_SEL_Pos) |  // select channel 0
    DACC_MR_REFRESH (0x0F) |       // bit of a guess... I'm assuming refresh not needed at 48kHz
    (24 << DACC_MR_STARTUP_Pos) ;  // 24 = 1536 cycles which I think is in range 23..45us since DAC clock = 42MHz

  DACC->DACC_IDR = 0xFFFFFFFF ; // no interrupts
  DACC->DACC_CHER = DACC_CHER_CH0 << 0 ; // enable chan0
}

void dac_write (int val){
  DACC->DACC_CDR = val & 0xFFF ;
}



void adc_setup (){
  NVIC_EnableIRQ (ADC_IRQn) ;   // enable ADC interrupt vector
  ADC->ADC_MR = (ADC->ADC_MR) | 0X00800000; // enable different settings for each channel
  ADC->ADC_IDR = 0xFFFFFFFF ;   // disable interrupts
  ADC->ADC_IER = 0x55 ;         // enable End-Of-Conv interrupt 
  ADC->ADC_CHDR = 0xFFFF ;      // disable all channels
  
  ADC->ADC_CGR = 0x15555555 ;   // All gains set to x1
  ADC->ADC_COR = 0xFFFF0000 ;   // set all channels to differential mode
  ADC->ADC_CHER = 0xFF;         // enable just A0
Serial.println("ADC Setup complete.");  
  //delay(10);
  ADC->ADC_MR = (ADC->ADC_MR & 0xFFFFFFF0) | (1 << 1) | ADC_MR_TRGEN ;  // 1 = trig source TIO from TC0

}

// Circular buffer, power of two.
#define BUFSIZE 0x300
#define BUFMASK 0X3ff
volatile float samplesA [BUFSIZE] ;
volatile float pastSamplesA[2] = {0,0};
volatile float samplesB [BUFSIZE] ;
volatile float samplesC [BUFSIZE] ;
volatile float samplesD [BUFSIZE] ;
volatile int sptrA = 0 ;
volatile int sptrB = 0 ;
volatile int sptrC = 0 ;
volatile int sptrD = 0 ;
volatile float OFFSET_CHANNEL_A = 0;
volatile float OFFSET_CHANNEL_B = 0;
volatile float OFFSET_CHANNEL_C= 0;
volatile float OFFSET_CHANNEL_D = 0;
volatile int sptrALast = 0x3FF;
volatile bool flag = false;   
static float FC[5] = {.2647, .5294, .2647, .1151, -.1739}; // filter coeficcents
volatile float gain =1;

#ifdef __cplusplus
extern "C" 
{
#endif

void ADC_Handler (void){
  
  if (ADC->ADC_ISR & ADC_ISR_EOC0){   // ensure there was an End-of-Conversion and we read the ISR reg
    int val = *(ADC->ADC_CDR + 0) ;    // get conversion result
    float temp = gain*((3.3*(float)(val-2048)/4096.0) -OFFSET_CHANNEL_A);           // stick in circular buffer
    samplesA [sptrA] = temp;//1*FC[0]*temp + gain*FC[1]*pastSamplesA[0] + gain*FC[2]*pastSamplesA[1]
                        //+ FC[3]*samplesA[sptrA-1] + FC[4]*samplesA[sptrA-2];
    sptrA = (sptrA+1) & BUFMASK ;      // move pointer
  }


  if (ADC->ADC_ISR & ADC_ISR_EOC2){   // ensure there was an End-of-Conversion and we read the ISR reg
    int val = *(ADC->ADC_CDR + 2) ;    // get conversion result
    samplesB [sptrB] = gain*((3.3*(float)(val-2048)/4096.0)-OFFSET_CHANNEL_B) ;           // stick in circular buffer
    sptrB = (sptrB+1) & BUFMASK ;      // move pointer 
  }


  if (ADC->ADC_ISR & ADC_ISR_EOC4) {  // ensure there was an End-of-Conversion and we read the ISR reg
    int val = *(ADC->ADC_CDR+4) ;    // get conversion result
    samplesC [sptrC] = gain*((3.3*(float)(val-2048)/4096.0)-OFFSET_CHANNEL_C) ;           // stick in circular buffer
    sptrC = (sptrC+1) & BUFMASK ;      // move pointer
  }


  if (ADC->ADC_ISR & ADC_ISR_EOC6){   // ensure there was an End-of-Conversion and we read the ISR reg
    int val = *(ADC->ADC_CDR+6) ;    // get conversion result
    samplesD [sptrD] = gain*((3.3*(float)(val-2048)/4096.0)-OFFSET_CHANNEL_D) ;           // stick in circular buffer
    sptrD = (sptrD+1) & BUFMASK ;      // move pointer
   // flag = true;
    if( sptrC == 255){
      flag = true;
      ADC->ADC_IDR = 0xFFFFFFFF ;   // disable interrupts
    }
  }


  }// end of ADC_Handler - adc inturupt 


#ifdef __cplusplus 
}
#endif

void cal(){
  float sumA = 0;
  float sumB = 0;
  float sumC = 0;
  float sumD = 0;
  for(int i = 0; i < 255; i = i+1){
    sumA += samplesA[i];
    sumB += samplesB[i];
    sumC += samplesC[i];
    sumD += samplesD[i];
  }
  OFFSET_CHANNEL_A = sumA/255.0;
  OFFSET_CHANNEL_B = sumB/255.0;
  OFFSET_CHANNEL_C = sumC/255.0;
  OFFSET_CHANNEL_D = sumD/255.0;
  gain = 500; // CHANGE THE GAIN HERE
}// end funcion cal

const int windowSize = 0x1F40;
uint16_t temp[4][windowSize];
int currentIndex = 0;
int printingFlag = false;
char output[64];
bool calabrate = true;

void loop(){

//when flag window treue
//   calc crosscorr
//   calc angle
//   calc distance
//   display
// 
  
  if( flag == true ){
    if(calabrate == true){
      cal();
      calabrate = false;
      Serial.println("test1");
    }
    else{
      flag = false;
      Serial.println("test");
      for(int i = 0; i < 255; i = i+1){
        sprintf(output,"%d,%.4f,%.4f,%.4f,%.4f\n",i,samplesA[i],samplesB[i],samplesC[i],samplesD[i]);
        Serial.print(output);
        //Serial.print(i);Serial.print(',');
       // Serial.print(samplesA[i]);//Serial.print(',');
       // Serial.print(',');Serial.print(samplesB[i]);
       // Serial.print(',');Serial.print(samplesC[i]);
       // Serial.print(',');Serial.println(samplesD[i]);
      }
    }
    sptrA = sptrB = sptrC = sptrD =0;
    ADC->ADC_IER = 0x55 ;         // enable End-Of-Conv interrupt 
  }

}
