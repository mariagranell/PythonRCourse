# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---  
# Examination project in R 
# Author: Maria Granell Ruiz
# Email: mgranellruiz@gmail.com
# Submission date:
# Version: 1
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---  
# Setup environment and data import -------------------------------------------------------------
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

## Load libraries
library("tidyr")
library("dplyr")
library("ggplot2")
library("ggpubr")
library("GGally")

## Set working directory
setwd("/Users/mariagranell/Desktop/Rcourses/PythonR/labs")

# Data Management ---------------------------------------------------------
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---  
# Must include: data import, variable assignment, dataset reorganisation (merge + long format),
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---  

## Import the datasets
data_pk <- read.csv("original_data/BPI889_PK_17.csv", # since is a "," separated file I used csv to read it
                    header = T,                           # to include headers in the object
                    na.strings = "."                      # to change the missing values from . to NA
)
data_snp <- read.table("original_data/BPI889_SNP_17.txt",
                       header = T,                        # to include headers in the object
                       row.names = NULL,                  # frist collum as a variable and not aa a vector of row names
                       sep = ""                           # the separator is ‘white space’
)

## Visually inspect imported data.frames
head(data_pk, n = 5L)
str(data_pk)
# Blood samples were collected at 10, 20, 30, 45, 60, 90, 120, 150, 180, 240, 300, 360, 480, 720 and 1440
# min post-dose for BPI889 concentration determination. The concentrations of BPI889 are found in the PK data file.
# Units of concentrations are mg/L. Note NA are indicated with .
head(data_snp, n = 5L)
str(data_snp)

### modifications to data_pk
# rename the variables
names(data_pk) <- c("id", "0.15", "0.3", "0.5","0.75","1","1.5","2","2.5","3","4","5","6","8","12","24","sex","weight","height","age")
data_pk$sex <- as.factor(data_pk$sex) # is a factor because is category of two levels

# remove the pat form patients
#data_pk[,1] <- gsub("\\D*","",data_pk$id)
#data_pk$id <- as.integer(data_pk$id) # I changed t an integer to be able to oder the data set by increasing ID
#data_pk <- data_pk[order(data_pk$id),] # Reorder rows

### modifications to data_snp
names(data_snp) <- c("id", "T134A", "A443G", "G769C", "G955C", "A990C")

### Combine dataframs into one object with long format

# to merge the data frams by id
data_all <- merge(data_pk, data_snp, by = "id")
head(data_all, n= 5L)

# first I gathered the time and then the snp.
tidy_all <- gather(data_all, key= time, value = concentration, -sex, -age, -height, -weight, -T134A, -A443G, -G769C, -G955C, -A990C, -id)
tidy_all <- gather(tidy_all, key= snp, value = genotype, -sex, -age, -time, -height, -weight, -concentration, -id)

tidy_all$time <- as.numeric(tidy_all$time) # so later in the grpahs we can plot against time, a number
tidy_all$snp <- as.factor(tidy_all$snp)    # snp to fators because they are categories of values

# Variable calculations ---------------------------------------------------
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---  
# Must include: calculation of body size measurement, categorization of body size measurement, 
# PK variable calculation
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---  
## to make some of the calculations I used a combination of long a short format

# Calculation of body composition measurement: TBW
data_all$tbw <- ifelse(data_all$sex == "M",
                       2.447-0.09156*data_all$age + 0.1074*data_all$height + 0.3362*data_all$weight,
                       -2.097 + 0.1067*data_all$height + 0.2466*data_all$weight)

# Categorization of TBW into two groups: TBW above and below 40 L
data_all$fortytbw <- ifelse(data_all$tbw > 40,
                       "above",
                       "below")

### Calculate PK variables Cmax, t1/2 and AUC

## cmax
data_all[, "cmax"] <- apply(data_all[, 2:16], 1, max, na.rm = T)
head(data_all)

## half_life

# change data_all to long format
head(data_all)
tidy_all2 <- gather(data_all, key= time, value = concentration,  -T134A, -A443G, -G769C, -G955C, -A990C,
                    -id, -sex, -age, -height, -weight, -cmax, -tbw, -fortytbw)
tidy_all2 <- gather(tidy_all2, key= snp, value = genotype, -id, -sex, -age, -height, -weight, -cmax, -tbw, -fortytbw,
                    -concentration, -time)
tidy_all2$time <- as.numeric(tidy_all2$time)                          # to oder the data by time during the loop
head(tidy_all2, n= 5L)
str(tidy_all)

# calculate k

n_pat <- nrow(tidy_all2[!duplicated(tidy_all2$id),])                  # to extract the number of patients
n_row <- 0                                                            # to determine when a patient was selected
k_list <- matrix(ncol=2,nrow = n_pat)                                   # to acummulate the value of k
colnames(k_list) <- c("id", "k")                                      # to name variables
max_c_row <- 0
c_max_value <- 0
for (i in 1:n_pat){
  dat_each_pat <-subset(tidy_all2, id == paste("pat", i,sep=""))
  n_row <- nrow(dat_each_pat)
  if (n_row == 75){
    # to recollect wich patient is
    k_list[i,1] <- paste("pat", i,sep="")

    # organize data frame to do the lm
    dat_each_pat <- dat_each_pat[order(dat_each_pat$time),]           # to order by time
    dat_each_pat <- dat_each_pat[!duplicated(dat_each_pat$time),]     # to remove duplicates

    # to subset the curve
    c_max_value <- dat_each_pat$cmax[1]                               # to get the cmax value
    max_c_row <- which(dat_each_pat$concentration == c_max_value)     # to get the row when the graph peaks
    dat_each_pat <- dat_each_pat[max_c_row:nrow(dat_each_pat),]       # to get the data from the peak to the
    dat_each_pat <- subset(dat_each_pat, concentration > 0)           # to remove the 0 for the log

    # calculate k
    model <- lm(log(concentration)~time, na.action=na.omit, dat_each_pat)
    model
    k <- abs(summary(model)$coefficients[2,1])                        # to extract the absolute value of the slope

    # collect k
    k_list[i,2] <- round(k, digits = 4)                               # store k with 4 digits


  }
}

k_list

# calculate half_life
half_life <- as.data.frame(k_list)
half_life[,2] <- log(2)/as.numeric(half_life[,2])
colnames(half_life) <- c("id", "half_life")

# to include half_life in the data frame
tidy_all2 <- merge(tidy_all2, half_life, by = "id")
tail(tidy_all2)
str(tidy_all2)

# auc

n_pat <- nrow(tidy_all2[!duplicated(tidy_all2$id),])                  # to extract the number of patients
n_row <- 0                                                            # to determine when a patient was selected
n_time <- 15                                                          # the numer of times the blood sales were collected
t_list <- matrix(0,ncol=3,nrow = (n_time + 1))                   # to acummulate the calculations of t, for t and control for pat0
auc_list <- matrix(ncol=3,nrow = n_time)                              # to acummulate the calculations of auc for each patient
auc_list_all <- matrix(0,ncol=3)                                 # the calculations of auc for all patients
colnames(t_list) <- c("t", "concentration","time")                    # to name variables
colnames(auc_list) <- c("id", "auc","time")
colnames(auc_list_all) <- c("id", "auc","time")

for (i in 1:n_pat){
  dat_each_pat <-subset(tidy_all2, id == paste("pat", i,sep=""))      # to select the data of each patient
  n_row <- nrow(dat_each_pat)                                         # when the data of a new patient start
  if (n_row == 75){

    # organize data frame
    dat_each_pat <- dat_each_pat[order(dat_each_pat$time),]           # to order by time
    dat_each_pat <- dat_each_pat[!duplicated(dat_each_pat$time),]     # to remove duplicates
    n_time <- nrow(dat_each_pat)

    # calculate t and auc
    k <- dat_each_pat[1,8]                                                     # to collect k
    for (j in 1:n_time){
      # to recollect wich patient is
      auc_list[j,1] <- paste("pat", i,sep="")

      # calculate t
      t_list[j+1,2] <- dat_each_pat[j,10]                                      # to store concentration
      t_list[j+1,3] <- dat_each_pat[j,9]                                       # to store time
      t_list[j+1,1] <- (t_list[j+1,2]+t_list[j,2])/2*(t_list[j+1,3]-t_list[j,3])

      # calculate acu
      auc <- sum(t_list[,1]) + (t_list[j+1,2]/k)
      auc_list[j,2] <- round(auc, digits = 4)                          # to store auc calculations with 4 digits
      auc_list[j,3] <- dat_each_pat[j,9]                                        # to store the tme of the auc
    }

    #to store the list of auc
    auc_list_all <- rbind(auc_list_all, auc_list)

  }
}

auc_list_all <- auc_list_all[2:nrow(auc_list_all),] # to remove the first observation

# to include auc in the data frame
tidy_all2 <- merge(tidy_all2, auc_list_all, by = c("id","time"))
tail(tidy_all2)
str(tidy_all2)

n_pat <- nrow(tidy_all2[!duplicated(tidy_all2$id),])                  # to extract the number of patients
n_row <- 0                                                            # to determine when a patient was selected
n_time <- 15                                                          # the numer of times the blood sales were collected
t_list <- matrix(0,ncol=3,nrow = (n_time + 1))                   # to acummulate the calculations of t, for t and control for pat0
auc_list <- matrix(ncol=2,nrow = n_pat)                               # to acummulate the calculations of auc for each patient
colnames(t_list) <- c("t", "concentration","time")                    # to name variables
colnames(auc_list) <- c("id", "auc")

head(tidy_all2)

for (i in 1:n_pat){
  dat_each_pat <-subset(tidy_all2, id == paste("pat", i,sep=""))      # to select the data of each patient
  n_row <- nrow(dat_each_pat)                                         # when the data of a new patient start
  if (n_row == 75){
    # to recollect wich patient is
    auc_list[i,1] <- paste("pat", i,sep="")

    # organize data frame
    dat_each_pat <- dat_each_pat[order(dat_each_pat$time),]           # to order by time
    dat_each_pat <- dat_each_pat[!duplicated(dat_each_pat$time),]     # to remove duplicates
    n_time <- nrow(dat_each_pat)

    # calculate t and auc
    k <- dat_each_pat[1,8]                                                     # to collect k
    for (j in 1:n_time){

      # calculate t
      t_list[j+1,2] <- dat_each_pat[j,10]                                      # to store concentration
      t_list[j+1,3] <- dat_each_pat[j,9]                                       # to store time
      t_list[j+1,1] <- (t_list[j+1,2]+t_list[j,2])/2*(t_list[j+1,3]-t_list[j,3])
    }

    # calculate auc
    auc <- sum(t_list[,1]) + (t_list[n_time,2]/k)

    # to store the calculated auc in the list
    auc_list[i,2] <- round(auc, digits = 4)
  }
}

# to include auc in the data frame
tidy_all2 <- merge(tidy_all2, auc_list, by = "id")
tail(tidy_all2)
str(tidy_all2)


# Data Exploration --------------------------------------------------------
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Must include: numerical summary of PK variables, graphical assessment of 1) PK profiles,
# 2) PK variable correlations, 3)PK variable-SNP correlations,
# 4) PK variable-body size measurement correlation with linear regression
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

# summary of Cmax
tidy_all2%>%
  summarize(mean =mean(cmax), median= median(cmax), sd = sd(cmax),  min_range=min(cmax), max_range=max(cmax))

# summary of half_life
tidy_all2$half_life <- as.numeric(tidy_all2$half_life)
tidy_all2%>%
  summarize(mean =mean(half_life), median= median(half_life), sd = sd(half_life),  min_range=min(half_life), max_range=max(half_life))

# summary of auc
tidy_all2$auc <- as.numeric(tidy_all2$auc)
tidy_all2%>%
  summarize(mean =mean(auc), median= median(auc), sd = sd(auc), min_range=min(auc), max_range=max(auc))

# Graphical analysis -----------------------------------------------------
df <- tidy_all2 # I renamed my main dataframe (tidy_all2) as df

# Graphically display individual concentrations of BPI889 versus time (spaghetti plot)
df %>%
  filter(!is.na(concentration)) %>%
  ggplot(aes(x=time, y=concentration)) +
  geom_line(alpha=.3,aes(group=id)) +
  geom_point(alpha=.3) +
  scale_x_continuous(breaks=c(0.15, 0.3, 0.5,0.75,1,1.5,2,2.5,3,4,5,6,8,12,24))+
  theme_gray()

# Graphically display correlations between Cmax, t1/2 and AUC (scatter plot)
df%>%
  group_by(id)%>%
  ggplot( aes(x = half_life, y = auc)) +
    geom_point(aes(color = sex), alpha = 0.5)

geom_point(aes(color = sex, size = cmax), alpha = 0.5) +
  scale_color_manual(values = c("#00AFBB", "#FC4E07")) +
  scale_size(range = c(0.5, 12))  # Adjust the range of points size

# Graphically display t1/2 and AUC versus SNPs (box-whiskers plots)
a<-ggplot(df, aes(x=snp, y=half_life)) +
  geom_boxplot(fill="slateblue", alpha=0.2) +
  xlab("SNP")
b<-ggplot(df, aes(x=snp, y=auc)) +
  geom_boxplot(fill="orange", alpha=0.2) +
  xlab("SNP")
ggarrange(a, b, nrow = 1, ncol = 2, labels = 1:2)

# Graphically display correlations between t1/2 and TBW to assess a
# relationship and add a linear regression (scatter with linear regression)

ggplot(df, aes(x=half_life, y=tbw)) +
  geom_point()+
  geom_smooth(method=lm)


# Statistical testing -----------------------------------------------------
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---  
# Must include: ANOVA of PK variables for SNPs, t-test of PK variable for body size measurement groups 
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---  

# Perform an ANOVA of AUC and Cmax for the five SNPs
anov_auc <- aov(auc ~ snp, data = df)
summary(anov_auc)

anov_cmax <- aov(cmax ~ snp, data = tidy_all2)
summary(anov_cmax)
ggboxplot(tidy_all2, x = "snp", y = "cmax")

# Perform a t-test of t1/2 for the two categorical groups of TBW
t.test(half_life ~ fortytbw, data = df)
ggboxplot(df, x = "fortytbw", y = "half_life")

