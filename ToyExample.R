#' Simulate three (two?) years
#' Each year has one (more?) claims
#' For at least one of the years, one of the claims is reported between 12 and 18 months
#' Compose aggregate triangle
#' Decompose into separate triangles
#' 
#' A claim will be reported within 12 months x% of the time. A claim will be reported
#' within 24 months 1-x% of the time.
#' 
#' Each claim will generate 2 payments.
#' The second payment is always 50% more than the first
#' A claim reported within 12 months will have its first payment equal to $1000
library(dplyr)

source("TriangleUtils.R")

SimClaim <- function(claimNum, ay, fast = TRUE){
  evalYears <- seq(from = ay, to = ay + 2)
  if (fast){
    payments <- c(1000, 0, 0)
    evals <- as.Date(paste0(evalYears, "-12-31"))
  } else {
    payments <- c(1500, 0, 500)
    evals <- as.Date(paste0(evalYears + 1, "-12-31"))
  }
  payments[2] <- payments[1] * 1.5
  df <- data.frame(AY = rep(ay, 3)
                   , ClaimNumber = rep(claimNum, 3)
                   , EvalDate = evals
                   , Payment = payments
                   , stringsAsFactors = FALSE)
  df
}

SimClaims <- function(ay){
  claimNums <- paste0(ay, "_", 1:3)
  dfFast <- lapply(claimNums[1:2], SimClaim, fast = TRUE, ay)
  dfFast <- do.call(rbind, dfFast)
  dfSlow <- SimClaim(claimNums[3], ay, fast = FALSE)
  df <- rbind(dfFast, dfSlow)
  df
}

AY <- 2011:2015
dfDetail <- lapply(AY, SimClaims)
dfDetail <-  do.call(rbind, dfDetail) %>% 
  mutate(Lag = 12 * (lubridate::year(EvalDate) - AY + 1))

dfDetailIBNYR <- dfDetail %>% 
  group_by(ClaimNumber) %>% 
  summarise(EvalDate = min(EvalDate)) %>% 
  inner_join(dfDetail)

dfDetailIBNER <- dfDetail %>% 
  anti_join(dfDetailIBNYR, by = c("AY", "ClaimNumber", "EvalDate", "Lag"))
  
dfIBNYR <- dfDetailIBNYR %>% 
  MakeLong()

dfIBNER <- dfDetailIBNER %>% 
  MakeLong()

dfIBNR <- dfDetail %>% 
  MakeLong()

dfTri <- dfIBNR %>%
  MakeTri(asOf = as.Date("2015-12-31"))  

dfTriIBNYR <- dfIBNYR %>% 
  MakeTri(asOf = as.Date("2015-12-31"))

dfTriIBNER <- dfIBNER %>% 
  MakeTri(asOf = as.Date("2015-12-31"))
  
save(file = "ToyExample.rda"
     , list = ls())