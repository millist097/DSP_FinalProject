import csv 
import matplotlib.pyplot as plt
import plotly.plotly as py
import plotly.graph_objs as go


with open( 'DataSets/459Hz_60d_70cm.csv', 'r') as csvfile:
	spamreader = csv.reader(csvfile,delimiter=',')
	for row in spamreader:
		channelA = row[1]
		channelB = row[1]
		channelC = row[2]
		channelD = row[3]

	for element in spamreader:
		print(element)

#plt.plot(list(range(2047)), channelA)

#plt.show()
