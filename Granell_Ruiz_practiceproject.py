import re

f = open('practiceproject1.fq', 'r')
data = f.readlines()

# to put the data in a list
dat = []
counter = 0
for line in data:
    line = line.strip()
    dat.append(line)
    counter += 1
    if counter > len(data):
        break

# to get the NAME of the sequences
number_names = list(range(0, len(dat), 4))
atnames = list(dat[i] for i in number_names)
names = []
for line in atnames:
    names.append(line.replace('@', ''))

# to get the %GC content of the sequences
number_sequences = list(range(1, len(dat), 4))
sequences = list(dat[i] for i in number_sequences)


def perGC(s):
    g = s.count("G")
    c = s.count("C")
    n = g + c
    return "{:.2f}".format((n / len(s)) * 100)

perGCsequences = []
for i in sequences:
    perGCsequences.append(perGC(i))
    # print(perGCsequences)

# to get the AVERAGE QUALITY SCORE of the sequences
number_quality = list(range(3, len(dat), 4))
quality = list(dat[i] for i in number_quality)


def qaver(quality_sequence):
    quality_values = []
    for i in quality_sequence:
        quality_values.append(ord(i))
    quality_average = sum(quality_values) / len(quality_values)
    return "{:.2f}".format(quality_average)


qaversequences = []
for i in quality:
    qaversequences.append(qaver(i))
    # print(qaversequences)

# Bonus
gencode = {
    'ATA': 'I', 'ATC': 'I', 'ATT': 'I', 'ATG': 'M',
    'ACA': 'T', 'ACC': 'T', 'ACG': 'T', 'ACT': 'T',
    'AAC': 'N', 'AAT': 'N', 'AAA': 'K', 'AAG': 'K',
    'AGC': 'S', 'AGT': 'S', 'AGA': 'R', 'AGG': 'R',
    'CTA': 'L', 'CTC': 'L', 'CTG': 'L', 'CTT': 'L',
    'CCA': 'P', 'CCC': 'P', 'CCG': 'P', 'CCT': 'P',
    'CAC': 'H', 'CAT': 'H', 'CAA': 'Q', 'CAG': 'Q',
    'CGA': 'R', 'CGC': 'R', 'CGG': 'R', 'CGT': 'R',
    'GTA': 'V', 'GTC': 'V', 'GTG': 'V', 'GTT': 'V',
    'GCA': 'A', 'GCC': 'A', 'GCG': 'A', 'GCT': 'A',
    'GAC': 'D', 'GAT': 'D', 'GAA': 'E', 'GAG': 'E',
    'GGA': 'G', 'GGC': 'G', 'GGG': 'G', 'GGT': 'G',
    'TCA': 'S', 'TCC': 'S', 'TCG': 'S', 'TCT': 'S',
    'TTC': 'F', 'TTT': 'F', 'TTA': 'L', 'TTG': 'L',
    'TAC': 'Y', 'TAT': 'Y', 'TAA': '_', 'TAG': '_',
    'TGC': 'C', 'TGT': 'C', 'TGA': '_', 'TGG': 'W'}  # https://pythonforbiologists.com/dictionaries

peptides = []
for seq in sequences:
    codons = []
    for tri in re.findall('...', seq):
        for codon in gencode.keys():
            tri = tri.replace(codon, gencode[codon])
        codons.append(tri)

    amino = "".join(codons)
    pep = amino.split('_')
    pep = list(filter(None, pep))
    peptides.append(pep)

# to create the table I checked:
# https://stackoverflow.com/questions/39032720/formatting-lists-into-columns-of-a-table-output-python-3
# I would like to know how to remove the brackets for the sequences. I could not find it, if you could let me know
# or direct me in the right direction

headers = ['Name', '%GC', 'Average quality score', 'Peptides']
table = [headers] + list(zip(names, perGCsequences, qaversequences, peptides))

for i, d in enumerate(table):
    line = ''.join(str(x).ljust(23) for x in d)
    print(line)
    if i == 0:
        print('-' * len(line))

# EXPORT FROM FASTQ TO FASTA

fastq = open('practiceproject1.fq', 'r')
# print(fastq)

outfile = open('convertedfile.fasta', 'w')

line_id = 1

for line in fastq:

    if line_id == 4:
        line_id = 1
    elif line_id == 3:
        line_id += 1
    elif line_id == 2:
        fastq_seq = line
        outfile.write(fastq_seq)
        outfile.write("\n")
        line_id += 1
    else:
        if '@' in line:
            fastq_header = line.replace('@', '>')
            outfile.write(fastq_header)
            line_id += 1

outfile.close()
