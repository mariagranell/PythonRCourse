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
        important.append(line[2])
        # important.append(line[1:3])
        # print("first1 ", line)
    elif found == 1:  # lines that have the hit
        line = line.strip()
        line = line.split()
        important.append(line[2])
        # print("secondif ", line)

# print(important)  # if you put *impotant it prints nicer

# it creates list with just the sequences and patient once.

query = []
A = []
B = []
counter = 0
patient_name = "patient_00"
for line in important:
    if "patient" in line:
        if line != patient_name:
            patient_name = line
            query.append(patient_name)
            A.append(patient_name)
            B.append(patient_name)
        counter += 1
    elif counter == 1:
        query.append(line)
        counter += 1
    elif counter == 2:
        A.append(line)
        counter += 1
    elif counter == 3:
        B.append(line)
        counter = 0

# print(query)
# print(A)
# print(B)

# this puts all the sequences together

seqA = []
counter2 = 1
sequence_sum = ""
patient_name = "patient_00"
for line in A:
    if "patient" in line:
        if line != patient_name:
            seqA.append(sequence_sum)
            seqA.append(line)
            sequence_sum = ""
    elif counter2 == 1:
        one_line = line
        sequence_sum += one_line

# print(seqA)

seqB = []
counter3 = 1
sequence_sum = ""
patient_name = "patient_00"
for line in B:
    if "patient" in line:
        if line != patient_name:
            seqB.append(sequence_sum)
            seqB.append(line)
            sequence_sum = ""
    elif counter3 == 1:
        one_line = line
        sequence_sum += one_line

# print(seqB)

# now i have "patientA" "seqA" "patientB" "seqB"
seq_AB = seqA + seqB
# print(len(seq_AB[2]))
# print(seq_AB)


# in this way you can check in which positions there is an A
s = seqB[1:3] + seqA[1:3]
# print(s[1])
mut134 = 0
counter4 = 0
n = [133]
for line in s:
    if "patient" in line:
        counter4 += 1
    elif counter4 == 1:
        for position in n:
            if line[position] != '.':
                mut134 += 1
        counter4 = 0

# print(mut134)


# to make a dictionary with seqA

counter5 = 0
dic_A = {}
for line in seqA:
    if "patient" in line:
        pat_name = line
        counter5 += 1
    elif counter5 == 1:
        dic_A[pat_name] = line
        counter5 = 0
#print(dic_A)

# to make a dictionary with seqB
counter6 = 0
dic_B = {}
for line in seqB:
    if "patient" in line:
        pat_name = line
        counter6 += 1
    elif counter6 == 1:
        dic_B[pat_name] = line
        counter6 = 0
#print(dic_B)

# sum up the mutations of given indexes

mut_index_list = [133, 442, 768, 954, 989, 1050, 1077, 1940, 2137, 2637, 3002]
patient_index_list = list(range(1, 18))
result = {}
for patient_index in patient_index_list:
    patient_name = "patient_{:02d}".format(patient_index)
    result[patient_name] = {}
    for mut_index in mut_index_list:
        counter = 0
        potential_mutation_A = dic_A.get(patient_name)[mut_index]
        if potential_mutation_A != ".":
            counter += 1
        potential_mutation_B = dic_B.get(patient_name)[mut_index]
        if potential_mutation_B != ".":
            counter += 1
        result[patient_name][mut_index] = counter

#print(result)

print("{:<10} {:<10} {:<10} {:<10} {:<10} {:<10} {:<10} {:<10} {:<10} {:<10} {:<10} {:<10}".format( "Name", "T134A", "A443G", "G769C", "G955C", "A990C", "G1051A", "G1078T", "T1941A", "T2138C", "G2638T", "A3003T"))
for patient, mut in result.items():
    print("{:<10} {:<10}".format())