# TP N° 3 : Analyse OLAP sur Bases de Données Publiques

**Auteurs:** Ouled Meriem Farouk; Mezouari Abdel El Kader  
**Institution:** University Sid M2  
**Date:** 2026-01-07

---

## 📋 Table des Matières

- [Abstract](#abstract)
- [1. Introduction](#1-introduction)
- [2. Dataset](#2-dataset)
- [3. Tools and Environment](#3-tools-and-environment)
- [4. Star Schema Design](#4-star-schema-design)
- [5. ETL Process](#5-etl-process)
- [6. Database Exploration](#6-database-exploration)
- [7. OLAP Queries](#7-olap-queries)
  - [Task 5 — Basic Aggregations](#task-5--basic-aggregations)
  - [Task 6 — GROUP BY ROLLUP](#task-6--group-by-rollup)
  - [Task 7 — GROUP BY CUBE](#task-7--group-by-cube)
  - [Task 8 — GROUPING SETS](#task-8--grouping-sets)
  - [Task 9 — Ranking Functions](#task-9--ranking-functions)
  - [Task 10 — Pivoting](#task-10--pivoting)
  - [Task 11 — Window Functions](#task-11--window-functions)
- [8. Visualizations](#8-visualizations)
  - [Task 12 — Category and Year Dashboard](#task-12--category-and-year-dashboard)
  - [Task 13 — RANK vs DENSE_RANK](#task-13--rank-vs-dense_rank)
  - [Task 14 — Region × Quarter Heatmap](#task-14--region--quarter-heatmap)
- [9. Key Findings](#9-key-findings)
- [10. Reproducibility](#10-reproducibility)
- [11. Limitations and Future Work](#11-limitations-and-future-work)
- [12. Appendix](#12-appendix)
- [References](#references)

---

## Abstract

This report documents the end‑to‑end design and implementation of a small analytical data warehouse and OLAP workload. We build a star schema around retail sales, load data through a concise ETL, explore database metadata, implement a representative set of OLAP queries (aggregations, ROLLUP, CUBE, GROUPING SETS, ranking, pivoting, and window functions), and visualize insights via dashboards and heatmaps. The solution is implemented in PostgreSQL and Python (pandas, SQLAlchemy, matplotlib/seaborn) with fully reproducible notebooks.

## 1. Introduction

Online Analytical Processing (OLAP) enables fast multidimensional analysis of large datasets. A star schema organizes facts and descriptive dimensions to support performant aggregations and slice‑and‑dice analysis. This work applies OLAP techniques to a retail sales dataset: we model, load, query, and visualize the data to illustrate common analytical patterns.

## 2. Dataset

- Source: Kaggle — Sales Forecastinghttps://www.kaggle.com/datasets/rohitsahoo/sales-forecasting
- Local file: `data/row_data.csv`
- Analytical grain: one row per order line (transactional detail)
- Key fields: order/date, product (category, sub‑category, name), customer (segment), geography (region/state/city), measures (sales, quantity)

## 3. Tools and Environment

- Database: PostgreSQL (local) — database `olap`
- Python: pandas, SQLAlchemy, matplotlib, seaborn (see `requirements.txt`)
- Notebooks: VS Code Jupyter notebooks under `notebooks/`
- SQL assets: `sql/schema.sql`, `sql/queries.sql`

## 4. Star Schema Design

Star schema with one fact and four dimensions:

```
				 dim_time
						 |
						 |
dim_customer----fact_sales----dim_product
						 |
						 |
			 dim_geography
```

Fact table `fact_sales` (granularity: order line):

- Surrogate key: `fact_key`
- Foreign keys: `time_key` → `dim_time`, `customer_key` → `dim_customer`, `geo_key` → `dim_geography`, `product_key` → `dim_product`
- Measures: `sales` (DECIMAL), `quantity` (INTEGER)
- Additional: `order_id`, `ship_mode`, `load_date`

Dimension highlights:

- `dim_time`: date, year, quarter, month, week, day (+ names); supports time hierarchies
- `dim_customer`: customer_id, customer_name, segment
- `dim_geography`: region, state, city, country (default US), postal_code
- `dim_product`: product_id, category, sub_category, product_name

Design principles observed:

- Surrogate integer keys on all dimensions
- Clear granularity in fact table
- Denormalized descriptive attributes for slicing and dicing
- Indexes on fact foreign keys for join performance

## 5. ETL Process

Implemented with notebooks:

- `01_convert_csv_into_sql_database.ipynb`: ingest CSV, connect to PostgreSQL
- `02_etl_postgres_star_schema.ipynb`: create schema and load dimensions/fact

Key steps:

1. Create tables from `sql/schema.sql`
2. Prepare dimension datasets from CSV; deduplicate on business keys
3. Load dimensions to generate surrogate keys
4. Map fact rows to dimension keys; load `fact_sales`

Notable fix: During product dimension loading, deduplication is performed specifically on `product_id` (not all columns) to prevent duplicate key violations when re‑running the ETL.

## 6. Database Exploration

Notebook: `03_database_info.ipynb` compiles metadata:

- PostgreSQL version, schemas, tables
- Table sizes and row counts
- Primary/foreign keys, indexes
- Data previews for each table
- Star schema summary view

These checks validate structural integrity and confirm star schema conformance.

## 7. OLAP Queries

Notebook: `04_olap_queries.ipynb` implements Tasks 5–11.

### Task 5 — Basic Aggregations

- SUM, AVG, COUNT, MIN, MAX across dimensions: product category, geography region, customer segment, time hierarchies.

### Task 6 — GROUP BY ROLLUP

- Hierarchical totals e.g., `category → sub_category`, `year → quarter → month`.
- Produces subtotals and grand totals in a single pass.

### Task 7 — GROUP BY CUBE

- All combinations across dimensions e.g., `region × segment`, `category × year`.
- Useful for flexible slice‑and‑dice with totals across all axes.

### Task 8 — GROUPING SETS

- Custom subtotal sets in one query, labelled for readability.

### Task 9 — Ranking Functions

- `RANK()` and `DENSE_RANK()` to identify top products overall and within partitions (e.g., per region).

### Task 10 — Pivoting

- CASE‑based pivot queries converting rows to columns (e.g., sales by year, by segment, by quarter).

### Task 11 — Window Functions

- Running totals, moving averages, and period‑over‑period comparisons (e.g., `LAG/LEAD`).

## 8. Visualizations

Notebook: `04_visualizations.ipynb` (visualization tasks).
Libraries: matplotlib, seaborn; data fetched via SQLAlchemy.

### Task 12 — Category and Year Dashboard

- 4‑panel figure: total sales by category (bar), trends by category over years (line), YoY grouped bars, and category distribution (pie).
- Query note: transaction counts computed with `COUNT(*)` to avoid non‑existent `sale_id`.

### Task 13 — RANK vs DENSE_RANK

- Side‑by‑side barh plots showing assigned ranks for top products using `RANK()` vs `DENSE_RANK()`.
- Interpretation: `RANK()` skips numbers after ties; `DENSE_RANK()` does not.

### Task 14 — Region × Quarter Heatmap

- Heatmap of total sales by `region` and `quarter` using a pivot table.
- Query note: join uses `f.geo_key = g.geo_key` per schema.

## 9. Key Findings

- The dashboard reveals category‑level differences and temporal patterns that can guide assortment and promotion decisions.
- CUBE and GROUPING SETS enable rapid comparison across multiple dimension combinations without multiple queries.
- Ranking analyses highlight best‑selling products; differences between `RANK` and `DENSE_RANK` become visible when ties occur.
- Heatmaps make seasonal and regional performance variations immediately apparent.

## 10. Reproducibility

Prerequisites:

- Local PostgreSQL running and accessible on `localhost:5432`
- A database named `olap` (create if missing)
- Python 3 with virtual environment

Setup commands (Linux, bash):

```bash
cd /home/nbx/Desktop/files/tp_olap
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Ensure database exists
createdb olap || true

# (Optional) Recreate schema
psql -U postgres -d olap -f sql/schema.sql

# Run notebooks in order:
# 1) 01_convert_csv_into_sql_database.ipynb
# 2) 02_etl_postgres_star_schema.ipynb
# 3) 03_database_info.ipynb
# 4) 04_olap_queries.ipynb
# 5) 04_visualizations.ipynb
```

Notes:

- Connection URI used in notebooks: `postgresql://postgres:aa@localhost:5432/olap`
- Update credentials as needed for your environment.

## 11. Limitations and Future Work

- Dataset scope is limited; consider additional dimensions (e.g., promotions, channels) and measures (discount, profit if available).
- Slowly Changing Dimensions (SCD) not implemented; future work can add SCD Type 2 for historical attribute tracking.
- Automate ETL with orchestration (e.g., Airflow) and add tests/quality checks.
- Materialize common aggregates as summary tables for faster dashboards.

## 12. Appendix

- Schema DDL: `sql/schema.sql`
- Example queries: `notebooks/04_olap_queries.ipynb` (optionally mirror into `sql/queries.sql`)
- Visualizations: `notebooks/04_visualizations.ipynb`
- Raw data: `data/row_data.csv`

## References

- Kaggle: Sales Forecasting — https://www.kaggle.com/datasets/rohitsahoo/sales-forecasting
