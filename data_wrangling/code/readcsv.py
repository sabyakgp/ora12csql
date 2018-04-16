import csv
with open('data/data-text.csv', 'r') as csvfile:
#	reader = csv.reader(csvfile)
	reader = csv.DictReader(csvfile)
	for row in reader:
	   print (row)
