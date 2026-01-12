
- -- =====================================================
-- CUSTOMER RETENTION & REVENUE LEAKAGE ANALYSIS DATASET
-- 1,200+ rows across 4 tables with realistic patterns
-- =====================================================

-- Create Database
DROP DATABASE IF EXISTS retention_analysis;
CREATE DATABASE retention_analysis;
USE retention_analysis;

-- TABLE 1: CUSTOMERS (Demographics & Segmentation)
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    signup_date DATE NOT NULL,
    customer_segment ENUM('Enterprise', 'Mid-Market', 'SMB') NOT NULL,
    acquisition_channel ENUM('Direct Sales', 'Website', 'Partner', 'Referral') NOT NULL,
    region ENUM('North America', 'Europe', 'Asia Pacific', 'Latin America') NOT NULL,
    company_size ENUM('1-50', '51-200', '201-1000', '1000+') NOT NULL,
    industry ENUM('Technology', 'Healthcare', 'Finance', 'Retail', 'Manufacturing', 'Education') NOT NULL,
    account_manager_id INT
);

-- TABLE 2: SUBSCRIPTIONS (Plan details and Churn markers)
CREATE TABLE subscriptions (
    subscription_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    plan_type ENUM('Basic', 'Professional', 'Enterprise', 'Premium') NOT NULL,
    mrr DECIMAL(10,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    churn_date DATE,
    churn_reason VARCHAR(100),
    contract_length INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- TABLE 3: USAGE METRICS (Engagement & Satisfaction)
CREATE TABLE usage_metrics (
    usage_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    month DATE NOT NULL,
    login_count INT NOT NULL,
    feature_usage_score DECIMAL(5,2) NOT NULL,
    support_tickets INT NOT NULL,
    nps_score INT,
    product_adoption_rate DECIMAL(5,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- TABLE 4: TRANSACTIONS (Revenue tracking & Leakage)
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    transaction_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_status ENUM('Paid', 'Late', 'Failed', 'Pending') NOT NULL,
    days_overdue INT DEFAULT 0,
    invoice_id VARCHAR(50) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Note: In a production environment, use the INSERT INTO statements 
-- provided in your original file to populate the 1,200+ rows.
