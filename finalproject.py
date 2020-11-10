import re

f = open("datafinalproject.dat", "r")

# creates a list with all the lines and information i am
# interested in

n = 1
found = 0
important = []
for line in f:
    if "aaaa" in line:  # last line of a patient
        n += 1
    if len(line.strip()) == 0:
        found = 0
        # print("stop")
    if "Query_" in line:  # lines that have the query
        found = 1
        line = line.strip()
        line = line.split()
        important.append("patient_{:02d}".format(n))
        important.append(line[1])
        important.append(line[2])
        # important.append(line[1:3])
        # print("first1 ", line)
    elif found == 1:  # lines that have the hit
        line = line.strip()
        line = line.split()
        important.append(line[2])
        # print("secondif ", line)

print(important) #if you put *impotant it prints nicer

# this is the failing option of the previous one

# mut_count = 0
# checking = 0
# positions_mutations = ("121", "421")
# pat = 0
# matrix = []
# for line in important:
#     if any(s in line for s in positions_mutations):
#         checking = 1
#     elif "patient" in line:
#         checking = 0
#     elif checking == 1:
#         if line[13] == 'A':
#             mut_count += 1
#         elif line[21] == 'G':
#             mut_count += 1
#     if "aaaa" in line:
#         pat += 1
#         matrix.append("patient_{:02d}".format(pat))
#         matrix.append(mut_count)
#         mut_count = 0
#
# print(matrix)

# this option checks for each mutation but not for all in one.

mutT134A = 0
checking = 0
pat = 0
matrix = []
for line in important:
     if line == "121":
         checking = 1
     elif "patient" in line:
         checking = 0
     elif checking == 1:
         if line[13] == 'A':
             mutT134A += 1
     if "aaaa" in line:
         pat += 1
         matrix.append("patient_{:02d}".format(pat))
         matrix.append(mutT134A)
         mutT134A = 0

print(matrix)


mutT134A = 0
checkingmutT134A = 0
mutA443G = 0
checkingmutA433G = 0
pat = 0
matrix = []
for line in important:
     if line == "121":
         checkingmutT134A = 1
     if line == "421":
         checkingmutA433G = 1
     elif "patient" in line:
         checkingmutT134A = 0
         checkingmutA433G = 0
     elif checkingmutT134A == 1:
         if line[13] == 'A':
             mutT134A += 1
     elif checkingmutA433G == 1:
         if line[21] == 'G':
             mutA443G += 1
     if "aaaa" in line:
         pat += 1
         matrix.append("patient_{:02d}".format(pat))
         matrix.append(mutT134A)
         matrix.append(mutA443G)
         mutT134A = 0
         mutA443G = 0

#print(matrix)