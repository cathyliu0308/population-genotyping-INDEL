file=open("111.txt","r")
res=list()
for line in file:
    if not len(line):
        continue
    else:
        res.append(line)
print (res)
file.close()
