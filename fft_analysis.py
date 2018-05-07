from numpy import genfromtxt

my_data = genfromtxt('dataTest.csv',delimiter=',')

for thing in my_data:
	print(thing)