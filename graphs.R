library(tidyverse)

# Initialization
purchases <- read.csv("purchases.csv")   # Remember to change working dir! Use original purchases.csv!
purchases$Source <- sub("^$", "Misc", purchases$Source)
purchases$Date.Purchased <- do.call(c, lapply(purchases$Date.Purchased, function(x) parse_date(x, "%m/%d/%Y")))   # Untested directly

teaminfo <- read.csv("teaminfo.csv")
g <- !(teaminfo$Gender %in% c("Male", "Female", "Nonbinary"))
teaminfo$Gender[g] <- "Other"

## Data for Event DC306 (3/6/2022): https://docs.google.com/spreadsheets/d/1gGekBB92K-NU-nrTIQ2Gt3FhzLvs0LguhGsg8bORkI4/edit#gid=956466144
dc306 <- read_tsv("DC306.tsv") %>% mutate(`Calculated Cargo` = `Avg Match` - `Avg Hangar` - `Avg Taxi + Auto Cargo`)

## Data for events with data on 3/22
all <- read_tsv("all.tsv")

# Dollar Comparison
amt <- purchases %>% group_by(Source) %>% summarize(price = sum(parse_number(Total)))  # Exact Values
amt %>% ggplot() + geom_col(aes(x = reorder(Source, price), y = price)) + theme(axis.text.x = element_text(angle = 90)) + xlab("Source") + ggtitle("Amount (in dollars) bought from multiple sellers during the 2019-2020 year")

# Date Comparison
purchases %>% ggplot(aes(Date.Purchased)) + geom_density(fill="blue", alpha=0.25)

# Shipping Costs
purchasesN <- read.csv("purchasesN.csv")   # Remember to copy all shipping values to Shipping column and delete all taxes!
purchasesN %>% filter(Shipping != "") %>% group_by(Source) %>% summarize(Shipping = sum(parse_number(Shipping))) %>% ggplot(aes(reorder(Source, Shipping), Shipping)) + geom_col() + theme(axis.text.x = element_text(angle = 90)) + xlab("Source") + ylab("Shipping Cost") + ggtitle("A Comparison of Shipping Costs by Seller")

# No. of Orders
as.data.frame(table(purchasesN$Source)) %>% ggplot(aes(reorder(Var1, Freq), Freq)) + geom_col() + theme(axis.text.x = element_text(angle = 90)) + xlab("Source") + ylab("Frequency") + ggtitle("The Frequency of Order from Various Sellers")

# No. of Orders by Seller
purchasesN %>% filter(Source %in% c("ANDYMARK", "McMaster", "VEX ROBOTICS")) %>% ggplot(aes(Date.Purchased, fill=Source)) + geom_density(alpha=0.25) + facet_grid(. ~ Source) + ggtitle("When We Bought Items, By Seller")

# Money vs. Date
purchasesN %>% ggplot(aes(Date.Purchased, weight = parse_number(Total))) + geom_histogram(binwidth=10) + xlab("Purchase Date") + ylab("Amount spent") + ggtitle("How Much We Spent and When")

# Median Price vs. Seller
purchasesN %>% group_by(Source) %>% summarize(median_price = median(parse_number(Unit.Price))) %>% ggplot(aes(reorder(Source, median_price), median_price)) + geom_col() + theme(axis.text.x = element_text(angle = 90)) + xlab("Source") + ylab("Median Unit Price") + ggtitle("Median Price by Seller")

# Date vs. Quantity
purchasesN %>% ggplot(aes(Date.Purchased, weight = Quantity.Purchased)) + geom_histogram(binwidth=10) + xlab("Date Purchased") + ylab("Quantity Purchased") + ggtitle("When we Buy a High Number of Items")

# Gender disparity
teaminfo %>% group_by(Gender) %>% summarize(ct = length(Gender)) %>% ggplot(aes(reorder(Gender, ct), ct)) + geom_col() + xlab("Gender") + ylab("Count") + ggtitle("Gender Disparities in Gryphon Robotics")

# Age disparity
d <- teaminfo %>% group_by(Grade) %>% summarize(ct = length(Grade))
d$Grade <- factor(d$Grade, levels = c("Freshman", "Sophomore", "Junior", "Senior"))
d %>% ggplot(aes(Grade, ct)) + geom_col() + ylab("Count") + ggtitle("Grade Disparities")

# People per sub team
data.frame(subteams = c("Awards", "Outreach", "Media/Public Relations", "Imagery", "Safety", "Programming", "Electrical", "Mechanical", "Finance", "CAD", "Strat/Scouting") , count = c(2,11,9,13,5,23,22,33,14,10,5)) %>% ggplot(aes(reorder(subteams, count), count)) + geom_col() + theme(axis.text.x = element_text(angle = 90)) + xlab("Subteam") + ggtitle("The Number of People in each Subteam")

# Point Breakdown by Team during Teleop (DC306)
ggplot(dc306, aes(`Calculated Cargo`, `Avg Hangar`, label = Team)) + geom_point(aes(color = Rank <= 5)) + geom_text(hjust = -0.25, vjust = 1) + theme_bw() + xlab("Average Cargo Points") + ylab("Average Hangar Points") + ggtitle("Comparison of Point Breakdown during Teleop by Team")

# Match Points vs Ranking Point for all teams (2022)
all %>% ggplot() + geom_point(aes(`Avg Match`, `Total Ranking Points*`, color = `Team` != 5549)) + ggtitle("The Correlation between Match Points Scored and Ranking Points Recieved") + xlab("Average Match Points Scored") + ylab("Total Ranking Points Recieved")

# Box plot for teams' average match score
matchscore5549 <- ((all %>% filter(`Team` == 5549))$`Avg Match`)[1]
all %>% ggplot() + geom_boxplot(aes(0, `Avg Match`), width=0.4) + xlim(-1, 1) + geom_hline(aes(yintercept = matchscore5549, color = "red")) + ggtitle("Boxplot of Match Scores for Virginia") + xlab("") + ylab("Average Match Score")
