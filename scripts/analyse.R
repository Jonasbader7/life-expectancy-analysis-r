# Run from the repository root: Rscript scripts/analyse.R
# Portfolio edition; original submission is preserved in original/.
options(stringsAsFactors=FALSE)
dir.create('results', showWarnings=FALSE)
a <- read.csv('data/rankings.csv', check.names=FALSE)
b <- read.csv('data/covariates.csv', check.names=FALSE)
stopifnot(!anyDuplicated(a[['Commuting Zone ID']]), !anyDuplicated(b[['Commuting Zone ID']]))
d <- merge(a,b,by='Commuting Zone ID')
names(d)[match(c('Q1 Life Expectancy at Age 40 (Race-Adjusted) Women','Current Smokers in Q1','30-day Mortality Rate Index','Mean Household Income'),names(d))] <- c('LE40W','SmokersQ1','MortRate30','HHIncome')
stopifnot(all(complete.cases(d[c('LE40W','SmokersQ1','MortRate30','HHIncome')])))
stopifnot(all(d$SmokersQ1 >= 0 & d$SmokersQ1 <= 1))
d$unter_durchschnitt <- as.integer(d$HHIncome < mean(d$HHIncome))
models <- list(M1=lm(LE40W~SmokersQ1+MortRate30,d),M2=lm(LE40W~SmokersQ1+MortRate30+unter_durchschnitt,d),M3=lm(LE40W~SmokersQ1*unter_durchschnitt+MortRate30,d))
sink('results/model-summary.txt')
cat('Regions:',nrow(d),'\nIncome threshold:',mean(d$HHIncome),'\n')
for(n in names(models)){cat('\n',n,'\n');print(summary(models[[n]]));print(confint(models[[n]]))}
cat('\nSession\n');print(sessionInfo());sink()
write.csv(do.call(rbind,lapply(names(models),function(n){s<-summary(models[[n]]);data.frame(model=n,n=nobs(models[[n]]),r_squared=s$r.squared,adjusted_r_squared=s$adj.r.squared)})),'results/model-fit.csv',row.names=FALSE)
png('results/interaction.png',width=1400,height=900,res=140)
plot(d$SmokersQ1*100,d$LE40W,col=ifelse(d$unter_durchschnitt==1,'#c45a27','#196b8c'),pch=16,xlab='Raucheranteil im untersten Einkommensquartil (%)',ylab='Lebenserwartung Frauen, bedingt auf Alter 40 (Jahre)',main='Regionaler Zusammenhang: Raucheranteil und Lebenserwartung')
for(g in 0:1){sub<-d[d$unter_durchschnitt==g,];nd<-data.frame(SmokersQ1=seq(min(sub$SmokersQ1),max(sub$SmokersQ1),length.out=100),unter_durchschnitt=g,MortRate30=mean(d$MortRate30));lines(nd$SmokersQ1*100,predict(models$M3,nd),col=if(g==1)'#c45a27' else '#196b8c',lwd=2)}
legend('topright',c('Einkommen ab Mittelwert','Einkommen unter Mittelwert'),col=c('#196b8c','#c45a27'),pch=16,bty='n')
mtext('Modell M3; Mortalitaetsindex am Mittelwert. Assoziation, kein Kausalnachweis.',side=1,line=4,cex=.75)
dev.off()
pdf('results/diagnostics.pdf',width=9,height=9)
for(m in models){par(mfrow=c(2,2));plot(m)}
dev.off()
