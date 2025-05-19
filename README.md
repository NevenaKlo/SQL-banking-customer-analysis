# Banking Customer Behavior Analysis

## 📌 Project Overview

**Banking Intelligence** aims to develop a supervised machine learning model to predict customer behaviors using transactional data and product ownership information. This project focuses on constructing a **denormalized feature table** that aggregates financial and behavioral indicators derived from the available database tables.

## 🎯 Objective

The objective is to create a customer-centric feature table for machine learning training. The table will include both quantitative and qualitative indicators based on transactions, accounts, and demographic information, uniquely keyed by `id_cliente`.

---

## 🚀 Added Value

The feature engineering process and resulting dataset will bring several advantages:

- **Customer Behavior Prediction**  
  Identify patterns that indicate future actions, such as opening or closing accounts.

- **Churn Reduction**  
  Spot at-risk customers early using behavioral indicators and enable proactive marketing strategies.

- **Risk Management Optimization**  
  Segment customers by financial behavior to better assess credit risk.

- **Product Personalization**  
  Tailor financial offers to individual customer preferences and habits.

- **Fraud Detection**  
  Detect transaction anomalies and unusual account activities as potential fraud indicators.

---

## 🗄️ Database Structure

The database includes the following tables:

- `cliente`: personal details about customers (e.g., birth date).
- `conto`: accounts held by customers.
- `tipo_conto`: definitions of account types.
- `tipo_transazione`: categories of transaction types.
- `transazioni`: transaction-level details for each account.

---

## 🧮 Calculated Behavioral Indicators

The final dataset is grouped by `id_cliente` and includes:

### ➤ Basic Indicators
- Customer age (calculated from `data_nascita`)

### ➤ Transaction Indicators (across all accounts)
- Number of incoming and outgoing transactions
- Total incoming and outgoing transaction amounts

### ➤ Account Indicators
- Total number of accounts
- Count of each account type (`Conto Base`, `Conto Business`, `Conto Privati`, `Conto Famiglie`)

### ➤ Transaction Indicators by Account Type
- Incoming/outgoing transaction count per account type
- Incoming/outgoing amount per account type

---

## 🛠️ How the SQL Script Works

The SQL file provided performs the following steps:

1. Calculates customer age using the `cliente` table.
2. Aggregates transaction counts and amounts by transaction type (`+` for incoming, `-` for outgoing).
3. Summarizes account counts by type for each customer.
4. Combines account type and transaction data.
5. Produces a final denormalized table `banca_mml`, joining all relevant indicators per customer.




