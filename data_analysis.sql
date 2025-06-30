SELECT *
FROM fintech_user_data;

SELECT *
FROM fintech_behavioural_analysis;

SELECT *
FROM fintech_risks_and_defaults;

SELECT *
FROM fintech_geo_demographics;

SELECT `location`, COUNT(*) AS `Number of Users`
FROM fintech_geo_demographics
GROUP BY location;

SELECT gender, COUNT(*) AS `Number of Users`
FROM fintech_geo_demographics
GROUP BY gender;

SELECT 
    CASE 
        WHEN age BETWEEN 0 AND 12 THEN 'Child (0-12)'
        WHEN age BETWEEN 13 AND 19 THEN 'Teenager (13-19)'
        WHEN age BETWEEN 20 AND 35 THEN 'Young Adult (20-35)'
        WHEN age BETWEEN 36 AND 55 THEN 'Adult (36-55)'
        WHEN age >= 56 THEN 'Senior (56+)'
        ELSE 'Unknown'
    END AS age_group, 
    COUNT(*)
FROM fintech_geo_demographics
GROUP BY age_group;


SELECT smartphone_owner, COUNT(*) AS `Number of Users`
FROM fintech_geo_demographics
GROUP BY smartphone_owner;

SELECT literacy_level, COUNT(*) AS `Number of Users`
FROM fintech_geo_demographics
GROUP BY literacy_level;



CREATE TABLE combined_data
SELECT user_risk_reg_demo.*, behav.onboarding_completed, behav.kyc_dropoff_stage, behav.avg_session_time_min, behav.daily_app_opens, behav.language_selected, behav.support_requests
FROM 
(SELECT user_risk_reg.*, demo.location, demo.age, demo.gender, demo.preferred_language, demo.literacy_level, demo.smartphone_owner
FROM
(SELECT user_risk.*, reg.has_jan_dhan_account, reg.aadhaar_linked, reg.kyc_status, reg.govt_subsidy_received
FROM 
(
SELECT ud.*, risk.loan_requested, risk.loan_approved, risk.repayment_behavior, risk.credit_utilization_pct, risk.previous_loans_count
FROM fintech_user_data AS ud
JOIN fintech_risks_and_defaults AS risk
ON ud.user_id=risk.user_id) AS user_risk
JOIN fintech_regulatory_data AS reg
ON user_risk.user_id=reg.user_id) AS user_risk_reg
JOIN fintech_geo_demographics AS demo
ON user_risk_reg.user_id=demo.user_id) AS user_risk_reg_demo
JOIN fintech_behavioural_analysis AS behav
ON user_risk_reg_demo.user_id=behav.user_id;


SELECT *
FROM combined_data;


ALTER TABLE combined_data
DROP COLUMN preferred_language;

SELECT *
FROM combined_data;

SELECT wallet_balance_avg, upi_txn_count
FROM combined_data
ORDER BY upi_txn_count DESC;


SELECT mobile_recharge_amt_avg + monthly_utility_bill AS `Monthly Expenditure`, gig_platform_income, loan_requested
FROM combined_data
ORDER BY mobile_recharge_amt_avg DESC;


 


SELECT MAX(wallet_balance_avg)
FROM combined_data;

SELECT gig_platform_income, loan_requested
FROM combined_data
ORDER BY loan_requested DESC;


SELECT 
    CASE 
        WHEN upi_txn_count BETWEEN 40 AND 50 THEN 'Very High'
        WHEN upi_txn_count BETWEEN 30 AND 40 THEN 'High'
        WHEN upi_txn_count BETWEEN 20 AND 30 THEN 'Medium'
        WHEN upi_txn_count BETWEEN 0 AND 20 THEN 'Low'
        ELSE 'Unknown'
    END AS `UPI Frequency`, 
    COUNT(*) AS `Number of Users`,
    AVG(wallet_balance_avg) AS `Average Wallet`
FROM combined_data
GROUP BY `UPI Frequency`;


SELECT 
    CASE 
        WHEN ecommerce_txn_count BETWEEN 12 AND 14 THEN ' Very High'
        WHEN ecommerce_txn_count BETWEEN 9 AND 11 THEN ' High'
        WHEN ecommerce_txn_count BETWEEN 6 AND 8 THEN 'Medium'
        WHEN ecommerce_txn_count BETWEEN 3 AND 5 THEN 'Low'
        WHEN ecommerce_txn_count BETWEEN 0 AND 2 THEN ' Very Low'
        ELSE 'Unknown'
    END AS `E-Commerce Frequency`, 
    COUNT(*) AS `Number of Customers`,
    AVG(cash_on_delivery_pct) AS `Average COD %`
FROM combined_data
GROUP BY `E-Commerce Frequency`;



SELECT 
	CASE 
		WHEN t1.`Monthly Expenditure` BETWEEN 399 AND 500 THEN 'Very Low'
        WHEN t1.`Monthly Expenditure` BETWEEN 501 AND 900 THEN 'Low'
        WHEN t1.`Monthly Expenditure` BETWEEN 901 AND 1400 THEN 'Medium'
        WHEN t1.`Monthly Expenditure` BETWEEN 1401 AND 1900 THEN 'High'
        WHEN t1.`Monthly Expenditure` BETWEEN 1901 AND 2466 THEN 'Very High'
	END AS `Expenditure Brackets`,
    COUNT(*) AS `Number of Customers`,
    AVG(t1.gig_platform_income) AS `Average Gig Platform Income`,
    AVG(t1.loan_requested) AS `Average Loan Requested`
FROM(
SELECT mobile_recharge_amt_avg + monthly_utility_bill AS `Monthly Expenditure`, gig_platform_income, loan_requested
FROM combined_data
ORDER BY mobile_recharge_amt_avg DESC) AS t1
GROUP BY `Expenditure Brackets`
ORDER BY `Average Gig Platform Income` DESC;



SELECT kyc_dropoff_stage, onboarding_completed, COUNT(*)
FROM combined_data
GROUP BY kyc_dropoff_stage, onboarding_completed;


SELECT kyc_dropoff_stage, COUNT(*)
FROM combined_data
GROUP BY kyc_dropoff_stage;


SELECT 
    CASE 
        WHEN loan_requested BETWEEN 7501 AND 10000 THEN ' Very High'
        WHEN loan_requested BETWEEN 5001 AND 7500 THEN ' High'
        WHEN loan_requested BETWEEN 3001 AND 5000 THEN 'Medium'
        WHEN loan_requested BETWEEN 2001 AND 3000 THEN 'Low'
        WHEN loan_requested BETWEEN 0 AND 2000 THEN ' Very Low'
        ELSE 'Unknown'
    END AS `Loan Brackets`, 
    COUNT(*) AS `Number of Customers`,
    AVG(credit_utilization_pct) AS `Average Credit Util. %`
FROM combined_data
GROUP BY `Loan Brackets`;


SELECT 
    CASE 
        WHEN avg_session_time_min BETWEEN 13 AND 15 THEN ' Very High'
        WHEN avg_session_time_min BETWEEN 10 AND 13 THEN ' High'
        WHEN avg_session_time_min BETWEEN 8 AND 10 THEN 'Medium'
        WHEN avg_session_time_min BETWEEN 4 AND 8 THEN 'Low'
        WHEN avg_session_time_min BETWEEN 2 AND 4 THEN ' Very Low'
        ELSE 'Unknown'
    END AS `App Usage Brackets`, 
    loan_approved AS `Loan Approval`,
	COUNT(*) AS `Number of Customers`
FROM combined_data
GROUP BY `App Usage Brackets`, `Loan Approval`
ORDER BY `App Usage Brackets` ASC;



SELECT repayment_behavior, loan_approved, previous_loans_count, COUNT(*)
FROM combined_data
GROUP BY repayment_behavior, loan_approved, previous_loans_count
ORDER BY repayment_behavior ASC;


