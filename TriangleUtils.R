MakeLong <- function(df){
  df <- df %>% 
    group_by(AY, Lag, EvalDate) %>% 
    summarise(IncrPayment = sum(Payment)) %>% 
    arrange(AY, Lag) %>% 
    group_by(AY) %>% 
    mutate(CumulPayment = cumsum(IncrPayment)) %>% 
    ungroup()
  
  df  
}

MakeTri <- function(df, asOf){
  df <- df %>% 
    filter(EvalDate <= asOf) %>% 
    select(-EvalDate, -CumulPayment) %>% 
    tidyr::spread(Lag, IncrPayment)
  
  df
}
