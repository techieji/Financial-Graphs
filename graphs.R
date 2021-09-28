library(tidyverse)

# Initialization
purchases <- read.csv("purchases.csv")   # Remember to change the working dir! Use original purchases.csv!
purchases$Source <- sub("^$", "Misc", purchases$Source)
purchases$Date.Purchased <- do.call(c, lapply(purchases$Date.Purchased, function(x) parse_date(x, "%m/%d/%Y")))   # Untested directly

# Dollar Comparison
amt <- purchases %>% group_by(Source) %>% summarize(price = sum(parse_number(Total)))  # Exact Values
amt %>% ggplot() + geom_col(aes(x = reorder(Source, price), y = price)) + theme(axis.text.x = element_text(angle = 90)) + xlab("Source") + ggtitle("Amount (in dollars) bought from multiple sellers during the 2019-2020 year")

# Date Comparison
purchases %>% ggplot(aes(Date.Purchased)) + geom_density(fill="blue", alpha=0.25)

# Shipping Costs
purchasesN <- read.csv("purchasesN.csv")   # Remember to copy all shipping values to the Shipping column and delete all taxes!
purchasesN %>% filter(Shipping != "") %>% group_by(Source) %>% summarize(Shipping = sum(parse_number(Shipping))) %>% ggplot(aes(reorder(Source, Shipping), Shipping)) + geom_col() + theme(axis.text.x = element_text(angle = 90)) + xlab("Source") + ylab("Shipping Cost") + ggtitle("A Comparison of Shipping Costs by Seller")

# No. of Orders
as.data.frame(table(purchasesN$Source)) %>% ggplot(aes(reorder(Var1, Freq), Freq)) + geom_col() + theme(axis.text.x = element_text(angle = 90)) + xlab("Source") + ylab("Frequency") + ggtitle("The Frequency of Order from Various Sellers")
