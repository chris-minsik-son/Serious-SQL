# SQL Case Study 3 - Foodie-Fi
[🍦 View My Profile](https://github.com/chris-minsik-son)
[🍰 View Repositories](https://github.com/chris-minsik-son?tab=repositories)
[🍨 View Main Folder](https://github.com/chris-minsik-son/SQL-Code)

## Table of Contents
  - [Introduction](#introduction)
  - [Problem Statement](#problem-statement)
  - [Available Data](#available-data)
  - [Case Study Questions](#case-study-questions)
  - [Solutions](#solutions)

<p align="center">
<img src="/Images/case-study-3.png" width=40% height=40%>

## Introduction
Subscription based businesses are super popular and Danny realised that there was a large gap in the market - he wanted to create a new streaming service that only had food related content - something like Netflix but with only cooking shows! <br>

Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world! <br>

Danny created Foodie-Fi with a data driven mindset and wanted to ensure all future investment decisions and new features were decided using data. This case study focuses on using subscription style digital data to answer important business questions. <br>

## Available Data
Danny has shared the data design for Foodie-Fi and also short descriptions on each of the database tables - our case study focuses on only 2 tables but there will be a challenge to create a new table for the Foodie-Fi team. <br>

All datasets exist within the foodie_fi database schema - be sure to include this reference within your SQL scripts as you start exploring the data and answering the case study questions.


### Table 1: plans
Customers can choose which plans to join Foodie-Fi when they first sign up. <br>

Basic plan customers have limited access and can only stream their videos and is only available monthly at $9.90 <br>

Pro plan customers have no watch time limits and are able to download videos for offline viewing. Pro plans start at $19.90 a month or $199 for an annual subscription. <br>

Customers can sign up to an initial 7 day free trial will automatically continue with the pro monthly subscription plan unless they cancel, downgrade to basic or upgrade to an annual pro plan at any point during the trial. <br>

When customers cancel their Foodie-Fi service - they will have a churn plan record with a null price but their plan will continue until the end of the billing period.

| plan_id |   plan_name   | price  |
|---------|---------------|--------|
|       0 | trial         |   0.00 |
|       1 | basic monthly |   9.90 |
|       2 | pro monthly   |  19.90 |
|       3 | pro annual    | 199.00 |
|       4 | churn         |        |


### Table 2: subscriptions
Customer subscriptions show the exact date where their specific ```plan_id``` starts. <br>

If customers downgrade from a pro plan or cancel their subscription - the higher plan will remain in place until the period is over - the ```start_date``` in the ```subscriptions``` table will reflect the date that the actual plan changes. <br>

When customers upgrade their account from a basic plan to a pro or annual pro plan - the higher plan will take effect straightaway. <br>

When customers churn - they will keep their access until the end of their current billing period but the ```start_date``` will be technically the day they decided to cancel their service.

| customer_id | plan_id | start_date|
|-------------|---------|-----------|
|           1 |       0 | 2020-08-01|
|           1 |       1 | 2020-08-08|
|           2 |       0 | 2020-09-20|
|           2 |       3 | 2020-09-27|
|           3 |       0 | 2020-01-13|
|           3 |       1 | 2020-01-20|
|           4 |       0 | 2020-01-17|
|           4 |       1 | 2020-01-24|
|           4 |       4 | 2020-04-21|
|           5 |       0 | 2020-08-03|
|           5 |       1 | 2020-08-10|

## Case Study Questions

### A. Customer Journey
Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey. <br>

Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

### B. Data Analysis Questions
1. How many customers has Foodie-Fi ever had?
2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
6. What is the number and percentage of customer plans after their initial free trial?
7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
8. How many customers have upgraded to an annual plan in 2020?
9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

### C. Challenge Payment Question
The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:
- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
- once a customer churns they will no longer make payments
Example outputs for this table might look like the following:

<details>
<summary>
View table
</summary>

|customer_id |	plan_id |	plan_name |	payment_date |	amount |	payment_order |
|------------|----------|-------------|--------------|---------|------------------|
|1 |	1 |	basic monthly |	2020-08-08 |	9.90 |	1|
|1 |	1 |	basic monthly |	2020-09-08 |	9.90 |	2|
|1 |	1 |	basic monthly |	2020-10-08 |	9.90 |	3|
|1 |	1 |	basic monthly |	2020-11-08 |	9.90 |	4|
|1 |	1 |	basic monthly |	2020-12-08 |	9.90 |	5|
|2 |	3 |	pro annual |	2020-09-27 |	199.00 |	1|
|7 |	1 |	basic monthly |	2020-02-12 |	9.90 |	1|
|7 |	1 |	basic monthly |	2020-03-12 |	9.90 |	2|
|7 |	1 |	basic monthly |	2020-04-12 |	9.90 |	3|
|7 |	1 |	basic monthly |	2020-05-12 |	9.90 |	4|
|7 |	2 |	pro monthly |	2020-05-22 |	10.00 |	5|
|7 |	2 |	pro monthly |	2020-06-22 |	19.90 |	6|
|7 |	2 |	pro monthly |	2020-07-22 |	19.90 |	7|
|7 |	2 |	pro monthly |	2020-08-22 |	19.90 |	8|
|7 |	2 |	pro monthly |	2020-09-22 |	19.90 |	9|
|7 |	2 |	pro monthly |	2020-10-22 |	19.90 |	10|
|7 |	2 |	pro monthly |	2020-11-22 |	19.90 |	11|
|7 |	2 |	pro monthly |	2020-12-22 |	19.90 |	12|
|13 |	1 |	basic monthly |	2020-12-22 |	9.90 |	1|
|15 |	2 |	pro monthly |	2020-03-24 |	19.90 |	1|
|15 |	2 |	pro monthly |	2020-04-24 |	19.90 |	2|
|16 |	1 |	basic monthly |	2020-06-07 |	9.90 |	1|
|16 |	1 |	basic monthly |	2020-07-07 |	9.90 |	2|
|16 |	1 |	basic monthly |	2020-08-07 |	9.90 |	3|
|16 |	1 |	basic monthly |	2020-09-07 |	9.90 |	4|
|16 |	1 |	basic monthly |	2020-10-07 |	9.90 |	5|
|16 |	3 |	pro annual |	2020-10-21 |	189.10 |	6|
|18 |	2 |	pro monthly |	2020-07-13 |	19.90 |	1|
|18 |	2 |	pro monthly |	2020-08-13 |	19.90 |	2|
|18 |	2 |	pro monthly |	2020-09-13 |	19.90 |	3|
|18 |	2 |	pro monthly |	2020-10-13 |	19.90 |	4|
|18 |	2 |	pro monthly |	2020-11-13 |	19.90 |	5|
|18 |	2 |	pro monthly |	2020-12-13 |	19.90 |	6|
|19 |	2 |	pro monthly |	2020-06-29 |	19.90 |	1|
|19 |	2 |	pro monthly |	2020-07-29 |	19.90 |	2|
|19 |	3 |	pro annual |	2020-08-29 |	199.00 |	3|
|25 |	1 |	basic monthly |	2020-05-17 |	9.90 |	1|
|25 |	2 |	pro monthly |	2020-06-16 |	10.00 |	2|
|25 |	2 |	pro monthly |	2020-07-16 |	19.90 |	3|
|25 |	2 |	pro monthly |	2020-08-16 |	19.90 |	4|
|25 |	2 |	pro monthly |	2020-09-16 |	19.90 |	5|
|25 |	2 |	pro monthly |	2020-10-16 |	19.90 |	6|
|25 |	2 |	pro monthly |	2020-11-16 |	19.90 |	7|
|25 |	2 |	pro monthly |	2020-12-16 |	19.90 |	8|
|39 |	1 |	basic monthly |	2020-06-04 |	9.90 |	1|
|39 |	1 |	basic monthly |	2020-07-04 |	9.90 |	2|
|39 |	1 |	basic monthly |	2020-08-04 |	9.90 |	3|
|39 |	2 |	pro monthly  |	2020-08-25 |	10.00 |	4|

</details>

### D. Outside The Box Questions
The following are open ended questions which might be asked during a technical interview for this case study - there are no right or wrong answers, but answers that make sense from both a technical and a business perspective make an amazing impression!
1. How would you calculate the rate of growth for Foodie-Fi?
2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?
3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?
4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?
5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?

## Solutions

### A. Customer Journey
Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey. <br>

Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

### B. Data Analysis Questions
1. How many customers has Foodie-Fi ever had?
2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
6. What is the number and percentage of customer plans after their initial free trial?
7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
8. How many customers have upgraded to an annual plan in 2020?
9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

### C. Challenge Payment Question
The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:
- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
- once a customer churns they will no longer make payments
Example outputs for this table might look like the following:

<details>
<summary>
View table
</summary>

|customer_id |	plan_id |	plan_name |	payment_date |	amount |	payment_order |
|------------|----------|-------------|--------------|---------|------------------|
|1 |	1 |	basic monthly |	2020-08-08 |	9.90 |	1|
|1 |	1 |	basic monthly |	2020-09-08 |	9.90 |	2|
|1 |	1 |	basic monthly |	2020-10-08 |	9.90 |	3|
|1 |	1 |	basic monthly |	2020-11-08 |	9.90 |	4|
|1 |	1 |	basic monthly |	2020-12-08 |	9.90 |	5|
|2 |	3 |	pro annual |	2020-09-27 |	199.00 |	1|
|7 |	1 |	basic monthly |	2020-02-12 |	9.90 |	1|
|7 |	1 |	basic monthly |	2020-03-12 |	9.90 |	2|
|7 |	1 |	basic monthly |	2020-04-12 |	9.90 |	3|
|7 |	1 |	basic monthly |	2020-05-12 |	9.90 |	4|
|7 |	2 |	pro monthly |	2020-05-22 |	10.00 |	5|
|7 |	2 |	pro monthly |	2020-06-22 |	19.90 |	6|
|7 |	2 |	pro monthly |	2020-07-22 |	19.90 |	7|
|7 |	2 |	pro monthly |	2020-08-22 |	19.90 |	8|
|7 |	2 |	pro monthly |	2020-09-22 |	19.90 |	9|
|7 |	2 |	pro monthly |	2020-10-22 |	19.90 |	10|
|7 |	2 |	pro monthly |	2020-11-22 |	19.90 |	11|
|7 |	2 |	pro monthly |	2020-12-22 |	19.90 |	12|
|13 |	1 |	basic monthly |	2020-12-22 |	9.90 |	1|
|15 |	2 |	pro monthly |	2020-03-24 |	19.90 |	1|
|15 |	2 |	pro monthly |	2020-04-24 |	19.90 |	2|
|16 |	1 |	basic monthly |	2020-06-07 |	9.90 |	1|
|16 |	1 |	basic monthly |	2020-07-07 |	9.90 |	2|
|16 |	1 |	basic monthly |	2020-08-07 |	9.90 |	3|
|16 |	1 |	basic monthly |	2020-09-07 |	9.90 |	4|
|16 |	1 |	basic monthly |	2020-10-07 |	9.90 |	5|
|16 |	3 |	pro annual |	2020-10-21 |	189.10 |	6|
|18 |	2 |	pro monthly |	2020-07-13 |	19.90 |	1|
|18 |	2 |	pro monthly |	2020-08-13 |	19.90 |	2|
|18 |	2 |	pro monthly |	2020-09-13 |	19.90 |	3|
|18 |	2 |	pro monthly |	2020-10-13 |	19.90 |	4|
|18 |	2 |	pro monthly |	2020-11-13 |	19.90 |	5|
|18 |	2 |	pro monthly |	2020-12-13 |	19.90 |	6|
|19 |	2 |	pro monthly |	2020-06-29 |	19.90 |	1|
|19 |	2 |	pro monthly |	2020-07-29 |	19.90 |	2|
|19 |	3 |	pro annual |	2020-08-29 |	199.00 |	3|
|25 |	1 |	basic monthly |	2020-05-17 |	9.90 |	1|
|25 |	2 |	pro monthly |	2020-06-16 |	10.00 |	2|
|25 |	2 |	pro monthly |	2020-07-16 |	19.90 |	3|
|25 |	2 |	pro monthly |	2020-08-16 |	19.90 |	4|
|25 |	2 |	pro monthly |	2020-09-16 |	19.90 |	5|
|25 |	2 |	pro monthly |	2020-10-16 |	19.90 |	6|
|25 |	2 |	pro monthly |	2020-11-16 |	19.90 |	7|
|25 |	2 |	pro monthly |	2020-12-16 |	19.90 |	8|
|39 |	1 |	basic monthly |	2020-06-04 |	9.90 |	1|
|39 |	1 |	basic monthly |	2020-07-04 |	9.90 |	2|
|39 |	1 |	basic monthly |	2020-08-04 |	9.90 |	3|
|39 |	2 |	pro monthly  |	2020-08-25 |	10.00 |	4|

</details>

### D. Outside The Box Questions
The following are open ended questions which might be asked during a technical interview for this case study - there are no right or wrong answers, but answers that make sense from both a technical and a business perspective make an amazing impression!
1. How would you calculate the rate of growth for Foodie-Fi?
2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?
3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?
4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?
5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?