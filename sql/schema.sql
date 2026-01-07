-- TP3 OLAP Star Schema
-- Database: olap
-- Fact: 9,800 rows | Dimensions: normalized

-- 1. DIMENSION TABLES
DROP TABLE IF EXISTS dim_time CASCADE;
DROP TABLE IF EXISTS dim_customer CASCADE;
DROP TABLE IF EXISTS dim_geography CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;
DROP TABLE IF EXISTS fact_sales CASCADE;

-- TIME DIMENSION
CREATE TABLE dim_time (
    time_key SERIAL PRIMARY KEY,
    date_full DATE NOT NULL,
    year SMALLINT NOT NULL,
    quarter TINYINT NOT NULL,
    month TINYINT NOT NULL,
    week SMALLINT NOT NULL,
    day TINYINT NOT NULL,
    day_name VARCHAR(10),
    quarter_name VARCHAR(20),
    month_name VARCHAR(20)
);

-- CUSTOMER DIMENSION
CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id VARCHAR(20) UNIQUE NOT NULL,
    customer_name VARCHAR(100),
    segment VARCHAR(50)
);

-- GEOGRAPHY DIMENSION
CREATE TABLE dim_geography (
    geo_key SERIAL PRIMARY KEY,
    region VARCHAR(50),
    state VARCHAR(100),
    city VARCHAR(100),
    country VARCHAR(100) DEFAULT 'United States',
    postal_code INTEGER
);

-- PRODUCT DIMENSION
CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,
    product_id VARCHAR(20) UNIQUE,
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(255)
);

-- 2. FACT TABLE (9,800 rows)
CREATE TABLE fact_sales (
    fact_key SERIAL PRIMARY KEY,
    
    -- Foreign Keys
    time_key INTEGER REFERENCES dim_time(time_key),
    customer_key INTEGER REFERENCES dim_customer(customer_key),
    geo_key INTEGER REFERENCES dim_geography(geo_key),
    product_key INTEGER REFERENCES dim_product(product_key),
    
    -- Measures
    order_id VARCHAR(20),
    ship_mode VARCHAR(50),
    sales DECIMAL(10,2) NOT NULL,
    quantity INTEGER DEFAULT 1,
    
    -- Audit
    load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. PERFORMANCE INDEXES
CREATE INDEX idx_fact_time ON fact_sales(time_key);
CREATE INDEX idx_fact_geo ON fact_sales(geo_key);
CREATE INDEX idx_fact_customer ON fact_sales(customer_key);
CREATE INDEX idx_fact_product ON fact_sales(product_key);
