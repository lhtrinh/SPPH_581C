###########K-means clustering example
# iris data
library(tidyverse)
data(iris)
head(iris)
summary(iris)

# standardize numeric vars in iris
iris_std <- iris %>%
  mutate_if(is.numeric, scale)
head(iris_std)

####################
# K-Means clustering
####################
#run 1 clustering
iris_clus <- iris_std[,names(iris_std)!="Species"]
head(iris_clus)
km.out <- kmeans(iris_clus, 3)
km.out$tot.withinss

# function to loop through different k
km_df <- data.frame(k_val = 0, total_ss = 0)
k_clus_fn <- function(df, n){
  for (k in 1:n){
    km.out <- kmeans(iris_clus, k)
    
    km_df[k,1] <- k
    km_df[k,2] <- km.out$tot.withinss
  }
  return(km_df)
}

kmeans_df <- k_clus_fn(iris_clus, 10)
head(kmeans_df)
plot(total_ss~k_val, data=kmeans_df, type=c("b"))


###############################
# Now on to the Toronto hospital data
###############################
# setwd(choose.dir("C:/Users/lyhtr/OneDrive - UBC/CLASSES/SPPH_581C/"))
hosp_data <- read.csv("C:/Users/lyhtr/OneDrive - UBC/CLASSES/SPPH_581C/Ontario_hospital_data.csv")
str(hosp_data)
summary(hosp_data)
# standardized: 
#smr, infect_rate, 
#patient_quality, cont_transition, informed_care


#data plots
library(GGally)
hosp_clus <- hosp_data%>%
  select(smr, infect_rate,patient_quality, cont_transition, informed_care)
ggpairs(hosp_clus)

#k means clustering using fviz_nbclust:
fviz_nbclust(hosp_clus, kmeans, method = "wss")
fviz_nbclust(hosp_clus, kmeans, method = "silhouette")
set.seed(1234)
fviz_nbclust(hosp_clus, kmeans, method = "gap_stat", 
             nstart = 25,  nboot = 100)+
  labs(subtitle = "Gap statistic method")

#elbow and silhouette methods show k=3 optimal clusters
#gap statistic method shows 1 optimal cluster but 3 is good too
final_clus <- kmeans(hosp_clus, 3, nstart=25)
fviz_cluster(final_clus, data=hosp_clus)
final_clus$cluster

#explore high-performing hospitals
#add cluster labels back to original data
hosp_data$cluster <- final_clus$cluster
head(hosp_data)

#smr
boxplot(smr~cluster, data=hosp_data) 
#cluster 3 has sig lower smr

#infect_rate
boxplot(infect_rate~cluster, data=hosp_data) 
#clus3 has lower infect rate

#patient_quality
boxplot(patient_quality~cluster, data=hosp_data)
#1 highest patient quality, clus3 is second

#continuity & transition
boxplot(cont_transition~cluster, data=hosp_data)
#same pattern as patient_quality

#informed care
boxplot(informed_care~cluster, data=hosp_data)
#same pattern as 2 above

#can we cluster 3 into 2 groups?
clus3_data <- hosp_data[hosp_data$cluster==3,]
clus3_clus_vars <- clus3_data%>%
  select(smr, infect_rate, patient_quality, cont_transition, informed_care)
fviz_nbclust(clus3_clus_vars, kmeans, method = "wss")
fviz_nbclust(clus3_clus_vars, kmeans, method = "silhouette")
set.seed(235)
fviz_nbclust(clus3_clus_vars, kmeans, method = "gap_stat", nboot = 50)+
  labs(subtitle = "Gap statistic method")

#k-means clustering not quite successful


##########################################
# hierarchical clustering
########################################
hc.complete <- hclust(dist(hosp_clus), method="complete")
hc.average <- hclust(dist(hosp_clus), method="average")
hc.single <- hclust(dist(hosp_clus), method="single")

#plots
par(mfrow=c(2,2))
plot(hc.complete, main="Complete Linkage")
plot(hc.average, main="Average Linkage")
plot(hc.single, main="Single Linkage")
par(mfrow=c(1,1))

#use average linkage
# cutree(hc.average, k=3)

#explore the 3 clusters
hosp_data$avg_clust <- cutree(hc.average, k=3)

par(mfrow=c(2,3))
boxplot(smr~avg_clust, data=hosp_data)
#cluster 2 has lower smr
boxplot(infect_rate~avg_clust, data=hosp_data)
#same with infection rate
boxplot(patient_quality~avg_clust, data=hosp_data)
#3 is the highest, 2 in the middle
boxplot(cont_transition~avg_clust, data=hosp_data)
boxplot(informed_care~avg_clust,data=hosp_data)
#same with cont & informed care
par(mfrow=c(1,1))




#cut by complete linkage?
hosp_data$comp_hclust <- cutree(hc.complete, k=4)
table(hosp_data$comp_hclust)

par(mfrow=c(2,3))
boxplot(smr~comp_hclust, data=hosp_data)
#cluster 2 has lower smr
boxplot(infect_rate~comp_hclust, data=hosp_data)
# #same with infection rate
boxplot(patient_quality~comp_hclust, data=hosp_data)
#3 is the highest, 2 in the middle
boxplot(cont_transition~comp_hclust, data=hosp_data)
boxplot(informed_care~comp_hclust,data=hosp_data)
par(mfrow=c(1,1))
#looks like cluster 4 performed the best

high_perf <- hosp_data[hosp_data$comp_hclust==4,]
dim(high_perf)
summary(high_perf)



id1 <- sort(hosp_data$id[hosp_data$cluster==3])
id2 <- sort(hosp_data$id[hosp_data$hcluster==2])
id3 <- sort(hosp_data$id[hosp_data$comp_hclust==4])
setdiff(id1, id2)
setdiff(id2, id3)
setdiff(id3, id1)
#very similar clusters



########################################
#### What if you just cluster 2 vars?
test_dat <- hosp_data %>% select(infect_rate, informed_care)
test_clus <- kmeans(test_dat, 3)
test_clus$cluster

boxplot(hosp_data$smr~test_clus$cluster)
boxplot(hosp_data$patient_quality~test_clus$cluster)
test_clus$tot.withinss
final_clus$tot.withinss

setdiff(hosp_data$id[test_clus$cluster==1],id1)


########################################
#try mahalanobis distance
#data=hosp_clus
x <- hosp_clus
x_mean <- apply(x, 2, mean)
x_cov <- var(x)
x_mah <- mahalanobis(x, x_mean, x_cov)
x_mah

