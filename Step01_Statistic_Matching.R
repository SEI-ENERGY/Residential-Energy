library(StatMatch)
library(reshape)
library(ade4)
library(Hmisc)

# Read in data
setwd("/Users/zoe/Documents/PROJECTS/SEI/Residential Energy Consumption Estimation/")

recs = read.csv("data/recs2009_south_atlantic_census_division(5).csv")
pums<- read.csv("data/ss09hga.csv")

# reformating common variables in recs
recs$BTUOTHER <- recs$TOTALBTU - recs$BTUEL - recs$BTUNG

recs$x_hhtype <- factor(recs$TYPEHUQ, labels = c(" mobile home", " single family detached", " single family attached", " apartment in building with 2-4 units", " apartment in building with 5+ units"))
recs$x_tenure <- factor(recs$KOWNRENT, labels = c(" owned by someone in the household", " rented", " occupied without payment of rent"))
recs$x_yearbuilt <- cut(recs$YEARMADE, breaks = c(-Inf, 1939, 1949, 1959, 1969, 1979, 1989,1999,2004,2005,2006,2007, 2008, Inf), labels = c(" 1939 or earlier", " 1940-1949", " 1950-1959", " 1960-1969"," 1970-1979"," 1980-1989", " 1990-1999", " 2000-2004", "2005","2006","2007","2008", "2009"), order = TRUE)
recs$x_mvin <- cut(recs$OCCUPYYRANGE, breaks = c(-Inf, 4, 5, 6,7,Inf), labels = c(" 30 years or more", " 20-29 years", " 10-19 years", " 5-9 years", " 4 or less years"), ordered = TRUE)

recs$BEDROOMS[recs$BEDROOMS<0] <- NA
recs$x_bedrooms <- recs$BEDROOMS

recs$x_totrooms <- recs$TOTROOMS

recs$x_heatfuel <- cut(recs$FUELHEAT, breaks = c(-Inf, 0, 1, 2, 4,5,7, Inf), labels = c(" No fuel used", " natural gas", " propange/LPG", " fuel oil or Kerosene", " electricity", " wood", " other fuel"))
recs$x_heatfuel <- recs$FUELHEAT
recs$x_heatfuel[recs$x_heatfuel == 2] <- 8
recs$x_heatfuel[recs$x_heatfuel == 4] <- 8
recs$x_heatfuel[recs$x_heatfuel == 7] <- 8
recs$x_heatfuel[recs$x_heatfuel == 0] <- 8
recs$x_heatfuel <- cut(recs$x_heatfuel, breaks = c(-Inf, 1, 5,Inf), labels = c( " natural gas",  " electricity", " other fuel"))

recs$x_hhsize <- recs$NHSLDMEM
recs$x_hhincome <- factor(recs$MONEYPY, labels = c("less than $2,500", " $2,500 to $4,999", " $5,000 to $7,499", " $7,500 to $9,999", " $10,000, to $14,999", " $15,000 to $19,999", " $20,000 to $24,999", " $25,000 to $29,999", " $30,000 to $34,999", " $35,000 to $39,999", " $40,000 to $44,999", " $45,000 to $49,999", " $50,000 to $54,999", " $55,000 to $59,999", " $60,000 to $64,999", " $65,000 to $69,999", " $70,000 to $74,999", " $75,000 to 79,999", " $80,000 to $84,999", " $85,000 to $89,999", " $90,000 to $94,999", " $95,000 to $99,999", " $100,000 to $119,999", " 120,000 or More"),ordered = TRUE)
recs$x_yearel <- recs$DOLLAREL
recs$x_yearng <- recs$DOLLARNG/recs$HDD65*374 #https://www.eia.gov/totalenergy/data/annual/showtext.php?t=ptb0107
recs$x_yearother <- recs$TOTALDOL - recs$DOLLAREL - recs$DOLLARNG

# reformating common variables in pums
pums<- pums[,1:82] #get rid of the weights
pums$x_hhtype <- cut(pums$BLD, breaks= c(-Inf, 1,2,3,5,Inf), labels = c(" mobile home", " single family detached", " single family attached", " apartment in building with 2-4 units", " apartment in building with 5+ units"))
pums$x_tenure <- cut(pums$TEN, breaks = c(-Inf, 2, 3, Inf), labels = c(" owned by someone in the household", " rented", " occupied without payment of rent"))
pums$x_yearbuilt <- cut(pums$YBL, breaks = c(-Inf, 1939, 1949, 1959, 1969, 1979, 1989,1999,2004,2005,2006,2007, 2008, Inf), labels = c(" 1939 or earlier", " 1940-1949", " 1950-1959", " 1960-1969"," 1970-1979"," 1980-1989", " 1990-1999", " 2000-2004", "2005","2006","2007","2008", "2009"), ordered = TRUE)
pums$x_mvin <- cut(pums$MV, breaks = c(-Inf, 3, 4, 5, 6,Inf), labels = c(" 4 or less years"," 5-9 years" , " 10-19 years",  " 20-29 years"," 30 years or more" ), ordered = TRUE)
pums$x_bedrooms <- pums$BDSP
pums$x_totrooms <- pums$RMSP
pums$x_heatfuel <- pums$HFL
pums$x_heatfuel[pums$x_heatfuel==5] <- 8
pums$x_heatfuel[pums$x_heatfuel==2] <- 8
pums$x_heatfuel[pums$x_heatfuel==4] <- 8
pums$x_heatfuel[pums$x_heatfuel==6] <- 8
pums$x_heatfuel[pums$x_heatfuel==9] <- 8
pums$x_heatfuel <- cut(pums$x_heatfuel, breaks = c(-Inf, 1,3, Inf), labels = c( " natural gas", " electricity",  " other fuel"))
pums$x_hhsize <- pums$NP
pums$x_hhincome <- cut(pums$HINCP, breaks = c(-Inf, 2500, 4900, 7499, 9999, 14999, 19999, 24999, 29999, 34999, 39999, 44999, 49999, 54999, 59999, 64999, 69999, 74999, 79999, 84999, 89999, 94999, 99999, 119999, Inf), labels = c("less than $2,500", " $2,500 to $4,999", " $5,000 to $7,499", " $7,500 to $9,999", " $10,000, to $14,999", " $15,000 to $19,999", " $20,000 to $24,999", " $25,000 to $29,999", " $30,000 to $34,999", " $35,000 to $39,999", " $40,000 to $44,999", " $45,000 to $49,999", " $50,000 to $54,999", " $55,000 to $59,999", " $60,000 to $64,999", " $65,000 to $69,999", " $70,000 to $74,999", " $75,000 to 79,999", " $80,000 to $84,999", " $85,000 to $89,999", " $90,000 to $94,999", " $95,000 to $99,999", " $100,000 to $119,999", " 120,000 or More"),ordered = TRUE)
pums$x_yearel <- pums$ELEP*12
pums$x_yearel[pums$x_yearel==24] <- 0
pums$x_yearel[pums$x_yearel==12] <- 0


pums$x_yearng <- pums$GASP
pums$x_yearng[pums$x_yearng==1] <- 0
pums$x_yearng[pums$x_yearng==2] <- 0
pums$x_yearng[pums$x_yearng==3] <- 0

pums$x_yearother <- pums$FULP
pums$x_yearother[pums$x_yearother==1] <- 0
pums$x_yearother[pums$x_yearother==2] <- 0

spearman2(TOTALBTU~x_hhtype+x_tenure+x_yearbuilt+x_mvin+x_bedrooms+x_totrooms+x_heatfuel+x_hhsize+ x_hhincome+ x_yearel+ x_yearng+ x_yearother, p =2, data = recs)
spearman2(BTUEL~x_hhtype+x_tenure+x_yearbuilt+x_mvin+x_bedrooms+x_totrooms+x_heatfuel+x_hhsize+ x_hhincome+ x_yearel+ x_yearng+ x_yearother, p =2, data = recs)
spearman2(BTUNG~x_hhtype+x_tenure+x_yearbuilt+x_mvin+x_bedrooms+x_totrooms+x_heatfuel+x_hhsize+ x_hhincome+ x_yearel+ x_yearng+ x_yearother, p =2, data = recs)
spearman2(BTUOTHER~x_hhtype+x_tenure+x_yearbuilt+x_mvin+x_bedrooms+x_totrooms+x_heatfuel+x_hhsize+ x_hhincome+ x_yearel+ x_yearng+ x_yearother, p =2, data = recs)

# drop NA values and standardize common variables
pums <- pums[complete.cases(pums[,c("x_hhtype", "x_heatfuel", "x_totrooms", "x_yearel", "x_yearng", "x_yearother")]),]

merge_totrooms <- c(pums$x_totrooms, recs$x_totrooms)
sd <- sd(merge_totrooms)
mean <- mean(merge_totrooms)
pums$x_totrooms_std <- (pums$x_totrooms - mean)/sd
recs$x_totrooms_std <- (recs$x_totrooms - mean)/sd

merge_yearel <- c(pums$x_yearel, recs$x_yearel)
sd <- sd(merge_yearel)
mean <- mean(merge_yearel)
pums$x_yearel_std <- (pums$x_yearel - mean)/sd
recs$x_yearel_std <- (recs$x_yearel - mean)/sd

merge_yearng <- c(pums$x_yearng, recs$x_yearng)
sd <- sd(merge_yearng)
mean <- mean(merge_yearng)
pums$x_yearng_std <- (pums$x_yearng - mean)/sd
recs$x_yearng_std <- (recs$x_yearng - mean)/sd

merge_yearother <- c(pums$x_yearother, recs$x_yearother)
sd <- sd(merge_yearother)
mean <- mean(merge_yearother)
pums$x_yearother_std <- (pums$x_yearother - mean)/sd
recs$x_yearother_std <- (recs$x_yearother - mean)/sd

merge_hhsize <- c(pums$x_hhsize, recs$x_hhsize)
sd <- sd(merge_hhsize)
mean <- mean(merge_hhsize)
pums$x_hhsize_std <- (pums$x_hhsize - mean)/sd
recs$x_hhsize_std <- (recs$x_hhsize - mean)/sd

# statmatch electricity BTU
group.v <- c("x_hhtype")
X.mtc <- c("x_totrooms_std", "x_yearel_std")
X.join <- c("SERIALNO","x_totrooms","x_yearel","x_yearng", "x_hhtype", "x_heatfuel")

out.el <- NND.hotdeck(data.rec = recs, data.don = pums, match.vars = X.mtc, don.class = group.v, constrained = TRUE )
elbtu <- create.fused(data.rec = recs, data.don = pums, mtc.ids = out.el$mtc.ids, z.vars=X.join)
elbtu$dist <- out.el$dist.rd
summary(elbtu$dist)
elbtu<- elbtu[elbtu$dist<1,] #cut off distance above 1

elbtu <- elbtu[,c("SERIALNO","BTUEL")]
pums_el_final <- merge(pums, elbtu, by="SERIALNO", all.x = TRUE)
el_training <- pums_el_final[complete.cases(pums_el_final[,"BTUEL"]),]
el_imputing <- pums_el_final[is.na(pums_el_final$"BTUEL"),]

# prepare electric outputs for machine learning
el_training <- el_training[,-83:-99]
el_imputing <- el_imputing[,-83:-100]
el_training[is.na(el_training)] <- 0
el_imputing[is.na(el_imputing)] <- 0

write.csv(el_training, "output/el_training.csv", row.names =FALSE)
write.csv(el_imputing, "output/el_imputing.csv", row.names =FALSE)

# statmatch natural gas BTU
group.v <- c("x_heatfuel")
X.mtc <- c("x_yearng_std")
X.join <- c("SERIALNO","x_yearng", "x_heatfuel")

out.ng <- NND.hotdeck(data.rec = recs, data.don = pums, match.vars = X.mtc, don.class = group.v, constrained = TRUE )
ngbtu <- create.fused(data.rec = recs, data.don = pums, mtc.ids = out.ng$mtc.ids, z.vars=X.join)
ngbtu$dist <- out.ng$dist.rd
ngbtu<- ngbtu[ngbtu$dist<1,]

ngbtu <- ngbtu[,c("SERIALNO","BTUNG")]
pums_ng_final <- merge(pums, ngbtu, by="SERIALNO", all.x = TRUE)
ng_training <- pums_ng_final[complete.cases(pums_ng_final[,"BTUNG"]),]
ng_imputing <- pums_ng_final[is.na(pums_ng_final$"BTUNG"),]

ng_training <- ng_training[,-83:-99]
ng_imputing <- ng_imputing[,-83:-100]
ng_training[is.na(ng_training)] <- 0
ng_imputing[is.na(ng_imputing)] <- 0

write.csv(ng_training, "output/ng_training.csv", row.names =FALSE)
write.csv(ng_imputing, "output/ng_imputing.csv", row.names =FALSE)


# statmatch other BTU
group.v <- c("x_heatfuel")
X.mtc <- c("x_yearother_std")
X.join <- c("SERIALNO","x_yearother", "x_heatfuel")

out.other<- NND.hotdeck(data.rec = recs, data.don = pums, match.vars = X.mtc, don.class = group.v, constrained = TRUE )
obtu <- create.fused(data.rec = recs, data.don = pums, mtc.ids = out.other$mtc.ids, z.vars=X.join)
obtu$dist <- out.other$dist.rd
obtu <- obtu[obtu$dist<1, ]
obtu <- obtu[,c("SERIALNO","BTUOTHER")]
pums_other_final <- merge(pums, obtu, by="SERIALNO", all.x = TRUE)

other_training <- pums_other_final[complete.cases(pums_other_final[,"BTUOTHER"]),]
other_imputing <- pums_other_final[is.na(pums_other_final$"BTUOTHER"),]
other_training <- other_training[,-83:-99]
other_imputing <- other_imputing[,-83:-100]
other_training[is.na(other_training)] <- 0
other_imputing[is.na(other_imputing)] <- 0

write.csv(other_training, "output/other_training.csv", row.names =FALSE)
write.csv(other_imputing, "output/other_imputing.csv", row.names =FALSE)









