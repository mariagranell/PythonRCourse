# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Practice project in R
# Author: Maria Granell Ruiz
# Email: mgranellruiz@gmail.com
# Submission date: 23/11/2020 by 23:59
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

## Import the datasets
data_pd <- read.csv("original_data/BPI889_PD_run-in.csv", header = T, as.is = T)
data_cov <- read.table("original_data/BPI889_demographics.tab", header = T, sep = "", as.is = T)

## Visually inspect imported data.frames
head(data_pd)
str(data_pd)
head(data_cov, n = 10L)
str(data_cov)

# Data Management -------------------------------------------------------------------------------
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

## Change variables
### Set variables names
names(data_pd)[1] <- "ID"
head(data_pd) # to check the names

### Transform dataset from wide to long format
tidy_pd <- gather(data_pd, key= TIME, value = CD4, -ID)
head(tidy_pd, n = 5L) # to understand the new format
nrow(tidy_pd)
ncol(tidy_pd)

### Format Numeric variables
summary(tidy_pd)

tidy_pd[,3] <- as.numeric(tidy_pd$CD4)
tidy_pd[,1] <- gsub("^.*?_","",tidy_pd$ID)
tidy_pd[,2] <- gsub("\\D*","",tidy_pd$TIME)

unique(tidy_pd$TIME)
tidy_pd[,2] <- as.numeric(tidy_pd$TIME)

### Formate categorical variables
head(data_cov)
data_cov$SEX <- factor(data_cov$SEX, levels = c('M','F'), labels = c('Male', 'Female'))
data_cov$TB <- factor(data_cov$TB, levels = 0:1, labels = c('HIV','HIV+TB'))

### Create new variables

# change height to meters
data_cov$HT <- data_cov$HT/100

# new variable BMI
data_cov$BMI <- round(data_cov$WT/(data_cov$HT)^2, digits = 1)

# new variable CBMI taking into consideration males and females differences in classification of BMI
data_cov$CBMI <- ifelse(data_cov$SEX == "Female", 1,
                        ifelse(data_cov$BMI < 20, "underweight",
                               ifelse(data_cov$BMI <= 25, "lean",
                                      ifelse( data_cov$BMI <= 30, "overweight", "obese"))))

paste(data_cov$CBMI, data_cov$BMI)
data_cov$CBMI <- ifelse(data_cov$SEX == "Male", data_cov$CBMI,
                        ifelse(data_cov$BMI < 18, "underweight",
                               ifelse(data_cov$BMI <= 25, "lean",
                                      ifelse( data_cov$BMI <= 30, "overweight", "obese"))))

# to check that the changes made are correct
data_cov %>%
  group_by(CBMI, SEX) %>%
  summarize( max(BMI), min(BMI))

## Merge datasets
data_cov[,1] <- gsub("^.*?_","",data_cov$ID)
data_cbind <- cbind(tidy_pd, data_cov)
data_merge <- merge(tidy_pd, data_cov)
data_all <- merge(tidy_pd, data_cov, by = "ID")
str(data_cbind)
str(data_merge)
str(data_all)

## Re-arrange the data
### Reorder variables
col_order <- c("ID", "TIME", "CD4", "BCD4", "BVL", "WT", "HT", "BMI", "CBMI", "SEX", "TB")
data_all <- data_all[, col_order]

### Reorder rows
# order() to reorganise the rows of data_all by first increasing ID and then increasing TIME.
data_all <- data_all[order(data_all$ID, data_all$TIME),]
head(data_all)

# Numerical and graphical data summary ----------------------------------------------------------
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

## Numerical summary of time-invariant variables
head(data_all)
data_first <- data_all[!duplicated(data_all$ID),]
head(data_first) # to check the previous command
summary(data_all[, 4:8])
summary(data_all[, 9:11])

## Graphical summary of time-invariant variables
### Histograms

# with hist()
par(mfrow = c(3, 2))
for (i in 4:8){
  print(hist(data_first[,i], main= paste("Histogram of" , names(data_all)[i]),
             ylab = "count", xlab = paste(names(data_all)[i])))
}
dev.off()

hist(data_first[,4])

# with ggplot()

# Inside of loops just ggplot + hist works
plist = list()
for (j in 4:8){
  x <- data_first[, j]
  plist[[j-3]] <- ggplot(data.frame(x), aes(x = x)) +
    geom_histogram(bins = 30) +
    labs(title = paste("Histogram of" ,
                       names(data_all)[j]),
         x = names(data_all)[j],
         y = "Count")
}
ggarrange(plotlist = plist, nrow = 3, ncol = 2, labels = 4:8)

# plist[1:5]


### Correlation matrix
# A matrix of scatterplots is produced.
pairs(data_first[,4:8],
      upper.panel = NULL,
      lower.panel = panel.smooth,
      pch = 3
)

ggpairs(data_first[,4:8])

### Box plots
new_order <- with(data_first, reorder(CBMI , WT, mean)) #to order the CMBI categories increasing in weight
boxplot(data_first$WT ~ new_order , ylab="Weight" , xlab = "CMBI", col="red", boxwex=0.5 , main="why")

ggplot(data_first, aes(x=reorder(CBMI,WT), y=WT)) +
  geom_boxplot( fill= "gold1")+
  scale_x_discrete(name="CMBI") +
  scale_y_continuous(name="Weight") +
  theme_gray()

ggplot(data_first, aes(x=TB, y=BCD4, fill=TB, color=TB)) +
  geom_boxplot(         # custom boxes
    color=c("#69b3a2", "orange"),
    fill=c("#69b3a2","orange"),
    alpha=0.2,

    # Notch
    notch=TRUE,
    notchwidth = 0.8,

    # custom outliers
    outlier.colour="blue",
    outlier.fill="blue",
    outlier.size=3
  )+
  scale_x_discrete(name="TB") +
  scale_y_continuous(name="BCD4") +
  theme_pubclean()
## Numerical summary of time-variant variables
data_all %>%
  filter(!is.na(CD4)) %>%
  group_by(TIME) %>%
  summarize( mean=mean(CD4 ), median=median(CD4 ), sd=sd(CD4 ), min=min(CD4 ) , max=max(CD4 ) )

## Graphical summary of time-variant variables
### Scatterplots
data_all %>%
  filter(!is.na(CD4)) %>%
  group_by(ID) %>%
  ggplot( aes(TIME, CD4, color=TB)) +
  geom_jitter(width = 0.95, size=5) +
  theme_bw()


#### Spaghetti plots
data_all %>%
  filter(!is.na(CD4)) %>%
  ggplot(aes(x=TIME, y=CD4)) +
  geom_line(alpha=.3,aes(group=ID)) +
  geom_point(alpha=.3) +
  geom_hline(yintercept=500, linetype="dashed", color = "red")+
  geom_hline(yintercept=200, linetype="dashed", color = "red")

#### Panel plots
data_all %>%
  filter(!is.na(CD4)) %>%
  group_by(ID) %>%
  ggplot( aes(TIME, CD4, color=TB)) +
  geom_jitter(width = 0.95, size=5) + #to make the dots disperse vertically
  facet_wrap(~ SEX)+
  theme_linedraw()

# Statistical testing ---------------------------------------------------------------------------
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
anov <- aov(data_all$CD4 ~ data_all$TIME) # as continuous
summary(anov)

anov2 <- aov(data_all$CD4 ~ factor(data_all$TIME)) # as categorical
summary(anov2)

timeto0 <- subset(data_all, data_all$TIME==0)
tail(timeto0) # to check that the time is set to 0
t.test(timeto0$CD4 ~timeto0$TB) # as categorical
t.test(timeto0$CD4 ~ as.integer(timeto0$TB)) # as continuous




