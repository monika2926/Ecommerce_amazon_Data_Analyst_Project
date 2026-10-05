# ============================================================
# PROJECT: E-commerce Data Analyst Project
# FILE: 02_Python_Analysis_Questions.py
# PURPOSE: Solve all 10 business analysis questions
# ============================================================

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns


import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    classification_report,
    confusion_matrix,
    ConfusionMatrixDisplay
)

# ------------------------------------------------------------
# Load Cleaned Dataset
# ------------------------------------------------------------

file_path = "01_Dataset/amazon_ecommerce_1M_cleaned.csv"
df = pd.read_csv(file_path)

df["purchase_date"] = pd.to_datetime(
    df["purchase_date"],
    errors="coerce"
)

print("Cleaned Dataset Loaded Successfully!")
print("Shape:")
print(df.shape)


# ============================================================
# QUESTION 1
# TOP 10 BRANDS BY REVENUE
# ============================================================

brand_revenue = (
    df.groupby("brand")["final_price"]
    .sum()
    .sort_values(ascending=False)
    .head(10)
)

print("\nTop 10 Brands by Revenue:")
print(brand_revenue)


# Chart

plt.figure(figsize=(10, 6))

brand_revenue.sort_values().plot(
    kind="barh"
)

plt.title("Top 10 Brands by Revenue")
plt.xlabel("Revenue")
plt.ylabel("Brand")

plt.tight_layout()
plt.show()


# ============================================================
# QUESTION 2
# RETURN PERCENTAGE BY CATEGORY
# ============================================================

return_percentage = (
    df.groupby("category")["is_returned"]
    .mean()
    .mul(100)
    .sort_values(ascending=False)
)

print("\nReturn Percentage by Category:")
print(return_percentage)


# Chart

plt.figure(figsize=(8, 5))

return_percentage.sort_values().plot(
    kind="barh"
)

plt.title("Return Percentage by Category")
plt.xlabel("Return Percentage")
plt.ylabel("Category")

plt.tight_layout()
plt.show()


# ============================================================
# QUESTION 3
# MONTHLY SALES TREND
# ============================================================

monthly_sales = (
    df.groupby(
        df["purchase_date"].dt.to_period("M")
    )["final_price"]
    .sum()
)

print("\nMonthly Sales Trend:")
print(monthly_sales)


# Chart

plt.figure(figsize=(12, 6))

monthly_sales.index = (
    monthly_sales.index.astype(str)
)

monthly_sales.plot(
    kind="line"
)

plt.title("Monthly Sales Trend")
plt.xlabel("Month")
plt.ylabel("Sales Revenue")

plt.xticks(rotation=45)

plt.tight_layout()
plt.show()


# ============================================================
# QUESTION 4
# CORRELATION ANALYSIS
# ============================================================

correlation_columns = [
    "price",
    "discount",
    "rating",
    "review_count",
    "seller_rating",
    "shipping_time_days"
]

correlation = (
    df[correlation_columns].corr()
)

print("\nCorrelation Matrix:")
print(correlation)


# Heatmap

plt.figure(figsize=(10, 7))

sns.heatmap(
    correlation,
    annot=True,
    cmap="coolwarm",
    fmt=".2f"
)

plt.title("Correlation Heatmap")

plt.tight_layout()
plt.show()


# ============================================================
# QUESTION 5
# HIGH-RATED AND HIGH-DISCOUNT PRODUCTS
# ============================================================

filtered_products = df[
    (df["rating"] > 4.5)
    &
    (df["discount"] > 30)
    &
    (df["review_count"] > 100)
]

print(
    "\nNumber of High-Rated and High-Discount Products:"
)

print(len(filtered_products))


# Category-wise analysis

category_count = (
    filtered_products["category"]
    .value_counts()
)

print("\nFiltered Products by Category:")
print(category_count)


# Chart

plt.figure(figsize=(8, 5))

category_count.sort_values().plot(
    kind="barh"
)

plt.title(
    "High-Rated and High-Discount Products by Category"
)

plt.xlabel("Number of Products")
plt.ylabel("Category")

plt.tight_layout()
plt.show()


# ============================================================
# QUESTION 6
# SELLER PERFORMANCE ANALYSIS
# ============================================================

seller_performance = (
    df.groupby("seller_id")
    .agg(
        seller_rating=(
            "seller_rating",
            "mean"
        ),

        return_rate=(
            "is_returned",
            "mean"
        ),

        avg_shipping_time=(
            "shipping_time_days",
            "mean"
        ),

        avg_product_rating=(
            "rating",
            "mean"
        )
    )
)


# Convert return rate into percentage

seller_performance["return_rate"] *= 100


print("\nSeller Performance:")
print(
    seller_performance.head(10)
)


# ------------------------------------------------------------
# Seller Performance Score
# ------------------------------------------------------------

seller_performance[
    "performance_score"
] = (

    seller_performance["seller_rating"]

    +

    seller_performance[
        "avg_product_rating"
    ]

    -

    (
        seller_performance[
            "return_rate"
        ] / 100
    )

    -

    (
        seller_performance[
            "avg_shipping_time"
        ] / 10
    )
)


print("\nSeller Performance Score:")

print(
    seller_performance[
        [
            "seller_rating",
            "return_rate",
            "avg_shipping_time",
            "avg_product_rating",
            "performance_score"
        ]
    ].head(10)
)


# ------------------------------------------------------------
# Top 10 Sellers
# ------------------------------------------------------------

top_sellers = (
    seller_performance[
        "performance_score"
    ]
    .sort_values(
        ascending=False
    )
    .head(10)
)

print(
    "\nTop 10 Sellers by Performance Score:"
)

print(top_sellers)


# Chart

plt.figure(figsize=(10, 6))

top_sellers.sort_values().plot(
    kind="barh"
)

plt.title(
    "Top 10 Sellers by Performance Score"
)

plt.xlabel("Performance Score")
plt.ylabel("Seller ID")

plt.tight_layout()
plt.show()


# ============================================================
# QUESTION 7
# PRICING OUTLIERS USING IQR
# ============================================================

Q1 = df["price"].quantile(0.25)

Q3 = df["price"].quantile(0.75)

IQR = Q3 - Q1

lower_bound = (
    Q1 - 1.5 * IQR
)

upper_bound = (
    Q3 + 1.5 * IQR
)


iqr_outliers = df[
    (df["price"] < lower_bound)
    |
    (df["price"] > upper_bound)
]


print("\nPricing Outliers using IQR:")

print("Q1:", Q1)

print("Q3:", Q3)

print("IQR:", IQR)

print(
    "Lower Bound:",
    lower_bound
)

print(
    "Upper Bound:",
    upper_bound
)

print(
    "Number of Price Outliers:",
    len(iqr_outliers)
)


# ------------------------------------------------------------
# Pricing Outliers using Z-Score
# ------------------------------------------------------------

price_mean = df["price"].mean()

price_std = df["price"].std()


z_score = (
    (df["price"] - price_mean)
    / price_std
)


z_score_outliers = df[
    z_score.abs() > 3
]


print(
    "\nPricing Outliers using Z-Score:"
)

print(
    "Number of Z-Score Outliers:",
    len(z_score_outliers)
)


# ============================================================
# QUESTION 8
# SHIPPING TIME VS CUSTOMER RATING
# ============================================================

rating_by_shipping = (
    df.groupby(
        "shipping_time_days"
    )["rating"]
    .mean()
)


print(
    "\nAverage Rating by Shipping Time:"
)

print(rating_by_shipping)


# ============================================================
# QUESTION 9
# DELIVERY STATUS ANALYSIS
# ============================================================

delivery_analysis = (
    df.groupby("delivery_status")
    .agg(
        avg_shipping_time=(
            "shipping_time_days",
            "mean"
        ),

        avg_rating=(
            "rating",
            "mean"
        ),

        total_orders=(
            "user_id",
            "count"
        )
    )
)


print(
    "\nDelivery Status Analysis:"
)

print(delivery_analysis)


# ============================================================
# QUESTION 10
# CUSTOMER BEHAVIOR ANALYSIS
# ============================================================


# ------------------------------------------------------------
# 10A. Customer Behavior by Device
# ------------------------------------------------------------

device_analysis = (
    df.groupby("device")
    .agg(
        total_orders=(
            "user_id",
            "count"
        ),

        total_revenue=(
            "final_price",
            "sum"
        ),

        avg_rating=(
            "rating",
            "mean"
        )
    )
)


print(
    "\nCustomer Behavior by Device:"
)

print(device_analysis)


# ------------------------------------------------------------
# 10B. Customer Behavior by Payment Method
# ------------------------------------------------------------

payment_analysis = (
    df.groupby("payment_method")
    .agg(
        total_orders=(
            "user_id",
            "count"
        ),

        total_revenue=(
            "final_price",
            "sum"
        ),

        avg_rating=(
            "rating",
            "mean"
        )
    )
)


print(
    "\nCustomer Behavior by Payment Method:"
)

print(payment_analysis)


# ------------------------------------------------------------
# 10C. Customer Behavior by Location
# ------------------------------------------------------------

location_analysis = (
    df.groupby("location")
    .agg(
        total_orders=(
            "user_id",
            "count"
        ),

        total_revenue=(
            "final_price",
            "sum"
        ),

        avg_rating=(
            "rating",
            "mean"
        )
    )
)


print(
    "\nCustomer Behavior by Location:"
)

print(location_analysis)


# ------------------------------------------------------------
# 10D. Customer Behavior by Category
# ------------------------------------------------------------

category_analysis = (
    df.groupby("category")
    .agg(
        total_orders=(
            "user_id",
            "count"
        ),

        total_revenue=(
            "final_price",
            "sum"
        ),

        avg_rating=(
            "rating",
            "mean"
        )
    )
)


print(
    "\nCustomer Behavior by Category:"
)

print(category_analysis)


# ============================================================
# END
# ============================================================

print(
    "\n============================================================"
)

print(
    "PYTHON ANALYSIS QUESTIONS COMPLETED"
)

print(
    "============================================================"
)