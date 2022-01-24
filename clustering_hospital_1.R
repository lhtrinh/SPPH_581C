summary(hosp_data)
nrow(hosp_data)


#principle component analysis for data reduction
pca_out <- prcomp(hosp_clus)
pca_out
x<-scale(pca_out$x)
apply(hosp_clus,2,mean)
apply(hosp_clus,2,sd)
k_df <- data.frame(kval=0, fstat=0)
for (k in 1:10){
  km.out <- kmeans(x, k)
  k_df[k,1] <- k
  k_df[k,2] <- km.out$tot.withinss
}
plot(fstat~kval, data=k_df, type="b") #optimal k=3


km.final <- kmeans(hosp_clus, 3)
hosp_new$kcluster <- km.final$cluster
km.final$tot.withinss
km.final$cluster
km.final$size

hosp_data$pca_clust <- km.final$cluster

par(mfrow=c(2,3))
boxplot(smr~pca_clust, data=hosp_data)
boxplot(infect_rate~pca_clust, data=hosp_data)
boxplot(patient_quality~pca_clust, data=hosp_data)
boxplot(cont_transition~pca_clust, data=hosp_data)
boxplot(informed_care~pca_clust, data=hosp_data)
par(mfrow=c(1,1))

#############################################
#hierarchical clustering with pca outputs
hc.complete2 <- hclust(dist(x), method="complete")
hc.average2 <- hclust(dist(x), method="average")
hc.single2 <- hclust(dist(x), method="single")

par(mfrow=c(2,2))
plot(hc.complete2, main="Complete Linkage")
plot(hc.average2, main="Average Linkage")
plot(hc.single2, main="Single Linkage")
par(mfrow=c(1,1))


hosp_data$pca_hclust_comp <- cutree(hc.complete2, k=4)
par(mfrow=c(2,3))
boxplot(smr~pca_hclust_comp, data=hosp_data)
#cluster 2 has lower smr
boxplot(infect_rate~pca_hclust_comp, data=hosp_data)
#same with infection rate
boxplot(patient_quality~pca_hclust_comp, data=hosp_data)
#3 is the highest, 2 in the middle
boxplot(cont_transition~pca_hclust_comp, data=hosp_data)
boxplot(informed_care~pca_hclust_comp,data=hosp_data)
#same with cont & informed care
par(mfrow=c(1,1))