f = open("datafinalproject.dat", "r")

# creates a list with all the lines and information I am interested in

n = 1
found = 0
important = []
for line in f:
    if len(line.strip()) == 0:
        found = 0
    if "Query_" in line:  # lines that have the query
        found = 1
        line = line.strip()
        line = line.split()
        important.append("patient_{:02d}".format(n))
        important.append(line[1])
        if "aaaa" in line[2]:  # last line of a patient, being line now a list
            n += 1
    elif found == 1:  # lines that have the hit
        line = line.strip()
        line = line.split()
        important.append(line[2])
# print(important)  # if you put *important it prints nicer

# it creates list with the patient just once and the sequences.

patient_numbers = []
A = []
B = []
counter = 0
counter_number = 0
patient_name = "patient_00"
for line in important:
    if "patient" in line:
        if line != patient_name:
            patient_name = line
            patient_numbers.append(patient_name)
            A.append(patient_name)
            B.append(patient_name)
            counter_number += 1
        counter += 1
    elif counter == 1:
        if counter_number == 1:
            A.append(line)
            B.append(line)
            counter_number = 0
        counter += 1
    elif counter == 2:
        A.append(line)
        counter += 1
    elif counter == 3:
        B.append(line)
        counter = 0
# print(patient_numbers)
# print(A)
# print(B)


# to put all the sequences together

seqA = []
counter = 0
sequence_sum = ""
patient_name = "patient_00"
length_counter = 0
for line in A:
    length_counter += 1
    if "patient" in line:
        if line != patient_name:
            seqA.append(sequence_sum)
            seqA.append(line)
            sequence_sum = ""
            counter = 1
    elif counter == 1:
        if line != "1":
            sequence_sum = "." * (int(line) - 1)
            counter = 2
        counter = 2
    elif counter == 2:
        one_line = line
        sequence_sum += one_line
    if length_counter == len(A):
        seqA.append(sequence_sum)
        sequence_sum = ""
# print(seqA)

seqB = []
counter = 0
sequence_sum = ""
patient_name = "patient_00"
length_counter = 0
for line in B:
    length_counter += 1
    if "patient" in line:
        if line != patient_name:
            seqB.append(sequence_sum)
            seqB.append(line)
            sequence_sum = ""
            counter = 1
    elif counter == 1:
        if line != "1":
            sequence_sum = "." * (int(line) - 1)
            counter = 2
        counter = 2
    elif counter == 2:
        one_line = line
        sequence_sum += one_line
    if length_counter == len(B):
        seqB.append(sequence_sum)
        sequence_sum = ""
# print(seqB)

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
# print(dic_A)

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

# to check the length of the sequences
# for key, value in dic_A.items() :
#     print (key, len(value))

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
# print(result)

# to print the table!

print("{:<15} {:<10} {:<10} {:<10} {:<10} {:<10} {:<10} {:<10} {:<10} {:<10} {:<10} {:<10}".format("Name", "T134A",
                                                                                                   "A443G", "G769C",
                                                                                                   "G955C", "A990C",
                                                                                                   "G1051A", "G1078T",
                                                                                                   "T1941A", "T2138C",
                                                                                                   "G2638T", "A3003T"))
for patient, mut in result.items():
    print("{:<15}".format(patient), end=" ")
    for value in mut.values():
        print("{:<10}".format(value), end=" ")
    print("")
