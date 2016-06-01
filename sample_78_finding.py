file1=open('78sample.txt','r')
#file1=open('0.txt','r')
file2=open('sample_whole_2535.txt','r')
##dict={}
####for line2 in file2:
####    #print (line2)
####    for line1 in file1:
####        print (line1)
####        #print (line2[:7],line1[:7])
####        if line2[:7]==line1[:7]:
####            print (line2)
####        #dict[line2[:7]] = line2
####        #print (line2[:7])
####        #print (dict[line2[:7]])
##for line1 in file1:
##    for line2 in file2:
##        if line1[:7]== line2[:7]:
##            print (line2)
##            break

nameDict={}    
for line in file1:
    nameDict[line[:7]]=1
#print(nameDict)
count=0
for line in file2:
    if(line[:7] in nameDict):
        #print (line[:7])
        print(line)
        count+=1
print(count)
