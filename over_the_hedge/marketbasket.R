if(!require(pacman)) install.packages("pacman");
pacman::p_load(
  'kableExtra',
  'ggplot2',
  'adobeanalyticsr',  ## Adobe Analytics API
  'dplyr', ## Wrangler
  'tidyr', ## wrangler
  'tidyverse',
  'arules', ## MBA functions
  'arulesViz' ## MBA viz
)

aw_token()
companies <- get_me()  
companies <- companies %>% filter(companyName == 'Search Discovery')
report_suites <- aw_get_reportsuites(companies$globalCompanyId, limit = 100)
report_suites <- report_suites %>% filter(name == 'Orbital Provisions Prod')
start_date <- '2019-03-01' #Sys.Date() - 30
end_date <- '2021-09-22' #Sys.Date() - 1


aw_get_dimensions(rsid = report_suites$rsid, 
                  company_id = companies$globalCompanyId) %>% 
  filter(grepl('oberon', support) ) %>% 
  select(title, name, description) %>% 
  View('dimensions')

aw_get_metrics(rsid = report_suites$rsid, 
               company_id = companies$globalCompanyId) %>% 
  filter(grepl('oberon', support) ) %>% 
  select(title, name, description) %>%
  View('Metrics')

df <- aw_freeform_table(
  company_id = companies$globalCompanyId,
  rsid = report_suites$rsid,
  date_range = c(start_date, end_date),
  dimensions = c('evar19', 'evar6'),
  metrics = c("orders", "revenue"),
  top = 200
)
top_purch <- df %>% 
  group_by(evar6) %>%
  summarise(purchases = sum(orders)) %>% 
  ggplot(aes(evar6, purchases)) +
  geom_bar(stat = 'identity') +
  xlab('Item') +
  ylab('# of Purchases') +
  coord_flip() +
  theme_minimal()

max_n <- df$orders %>% max()
prods <- df$evar6 %>% unique()
colnames(df) <- c('TransactionId', 'ProductName', 'qty', 'revenue')
df %>% 
  head() 


df <- df %>%
  mutate(
    itemCost = revenue / qty
  ) %>% 
  uncount(weights = qty) 

df %>% 
  head()


df <- plyr::ddply(df,c('TransactionId'),
                  function(tf1)paste(tf1$ProductName,
                                     collapse = ','))
df %>% 
  head(100) 


df <- tidyr::separate(df,'V1',
                      into = paste('item',1:max_n,sep = "_"),
                      sep = ',')
df %>% 
  tail() 

write.csv(df, 'AA_basket.csv')

items <- read.transactions('AA_basket.csv', format = 'basket', sep = ",")

rules <- apriori(items, parameter = list(supp=0.01, conf=0.05))

df_rules <- data.frame(
  lhs = labels(lhs(rules)),
  rhs = labels(rhs(rules)),
  rules@quality) %>% 
  select(-coverage) %>% 
  filter(lhs != '{}')

df_rules %>% 
  head() 

df_rules$support <- rescale(df_rules$support, c(0,100))

#### Recommender System ####
## Remove the brackets from the rule sets
df_rules$lhs <- gsub('\\{|}', '', df_rules$lhs)
df_rules$rhs <- gsub('\\{|}', '', df_rules$rhs)

## Function to return the top itmes
reccomender <-  function(ruleset, focus){
  ruleset %>% 
    filter(lhs == focus) %>% 
    arrange(-confidence, lift) %>% 
    top_n(10, lift)
  
}

reccomender(df_rules, 'The Partnership: A NASA History of the Apollo-Soyuz Test Project') %>% 
  View()
