dim(hosp_clus)
head(hosp_clus)
summary(hosp_clus)

hosp_new <- hosp_clus %>%
  mutate(smr_inv = 1-smr,
         infect_inv = 1-infect_rate)

par(mfrow=c(2,2))
fviz_nbclust(hosp_new, kmeans, method = "wss")
fviz_nbclust(hosp_new, kmeans, method = "silhouette")
set.seed(240)
fviz_nbclust(hosp_new, kmeans, method = "gap_stat", nboot = 50)+
  labs(subtitle = "Gap statistic method")
par(mfrow=c(1,1))

km_out <- kmeans(hosp_new, 2)
km_out$cluster

hosp_data$clust_new <- km_out$cluster

par(mfrow=c(2,3))
boxplot(smr~clust_new, data=hosp_data)
boxplot(infect_rate~clust_new, data=hosp_data)
boxplot(patient_quality~clust_new, data=hosp_data)
boxplot(cont_transition~clust_new, data=hosp_data)
boxplot(informed_care~clust_new, data=hosp_data)
par(mfrow=c(1,1))


hc.complete <- hclust(dist(hosp_new), method="complete")
hc.average <- hclust(dist(hosp_new), method="average")
hc.single <- hclust(dist(hosp_new), method="single")
hc.centroid <- hclust(dist(hosp_new), method="centroid")
hc.ward <- hclust(dist(hosp_new), method=)

par(mfrow=c(3,2))
plot(hc.complete, main="Complete Linkage")
plot(hc.average, main="Average Linkage")
plot(hc.single, main="Single Linkage")
plot(hc.centroid, main="Centroid Linkage")
plot(hc.ward, main="Ward Linkage")
par(mfrow=c(1,1))

hc.ward$labels
label1 <- cutree(hc.ward, 4)

par(mfrow=c(2,3))
boxplot(hosp_data$smr~label1)
boxplot(hosp_data$infect_rate~label1)
boxplot(hosp_data$patient_quality~label1)
boxplot(hosp_data$cont_transition~label1)
boxplot(hosp_data$informed_care~label1)
par(mfrow=c(1,1))