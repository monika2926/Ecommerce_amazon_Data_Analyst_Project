# ============================================================
# PROJECT: E-commerce Data Analyst Project
# FILE: 01_Python_Data_Cleaning.py
# PURPOSE: Load, clean and validate the raw e-commerce dataset
# ============================================================

import pandas as pd
import numpy as np


# ------------------------------------------------------------
# 1. Load Dataset
# ------------------------------------------------------------

file_path = "01_Dataset/amazon_ecommerce_1M.csv"

df = pd.read_csv(file_path)

print("Dataset loaded successfully!")

print("\nDataset Shape:")
print(df.shape)

print("\nColumn Names:")
print(df.columns.tolist())

print("\nData Types:")
print(df.dtypes)

# ============================================================
# 2. BASIC DATA CHECK
# ============================================================

print("\nCategories:")
print(df["category"].unique())

print("\nDelivery Status:")
print(df["delivery_status"].unique())

print("\nReturn Values:")
print(df["is_returned"].unique())


# ------------------------------------------------------------
# 3. Convert purchase_date to datetime
# ------------------------------------------------------------

df["purchase_date"] = pd.to_datetime(
    df["purchase_date"],
    errors="coerce"
)

print("\nPurchase Date Data Type:")
print(df["purchase_date"].dtype)

print("Invalid purchase dates:", df["purchase_date"].isna().sum())


# ------------------------------------------------------------
# 4. Check Missing Values
# ------------------------------------------------------------

print("\nMissing Values:")
print(df.isnull().sum())


# ------------------------------------------------------------
# 5. Check Duplicate Rows
# ------------------------------------------------------------

print("\nDuplicate Rows:")
print(df.duplicated().sum())

# Remove exact duplicate rows if any
duplicate_count = df.duplicated().sum()
if duplicate_count > 0:
    df = df.drop_duplicates().copy()

print("Shape after duplicate removal:", df.shape)


# ------------------------------------------------------------
# 6. Validate final_price
# ------------------------------------------------------------

calculated_price = (
    df["price"] * (1 - df["discount"] / 100)
)

price_difference = (
    df["final_price"] - calculated_price
).abs()

print("\nFinal Price Validation:")
print("Maximum Difference:", price_difference.max())
print(
    "Rows with Difference:",
    (price_difference > 0).sum()
)

# Original final_price is retained because
# calculated price does not exactly match it.


# ------------------------------------------------------------
# 7. Check Invalid Numerical Values
# ------------------------------------------------------------

print("\nInvalid Numerical Values:")

print(
    "Negative Price:",
    (df["price"] < 0).sum()
)

print(
    "Invalid Discount:",
    ((df["discount"] < 0) |
     (df["discount"] > 100)).sum()
)

print(
    "Invalid Rating:",
    ((df["rating"] < 0) |
     (df["rating"] > 5)).sum()
)

print(
    "Invalid Review Count:",
    (df["review_count"] < 0).sum()
)

print(
    "Invalid Stock:",
    (df["stock"] < 0).sum()
)

print(
    "Invalid Shipping Time:",
    (df["shipping_time_days"] < 0).sum()
)


# ------------------------------------------------------------
# 8. Check Categorical Values
# ------------------------------------------------------------

print("\nCategories:")
print(df["category"].unique())

print("\nBrands:")
print(df["brand"].unique())

print("\nLocations:")
print(df["location"].unique())

print("\nDevices:")
print(df["device"].unique())

print("\nPayment Methods:")
print(df["payment_method"].unique())

print("\nDelivery Status:")
print(df["delivery_status"].unique())


# ------------------------------------------------------------
# 9. Check Return / Delivery Consistency
# ------------------------------------------------------------

print("\nReturn and Delivery Consistency:")

return_delivery_table = pd.crosstab(
    df["is_returned"],
    df["delivery_status"]
)

print(return_delivery_table)


# ------------------------------------------------------------
# 10. Save Cleaned Dataset
# ------------------------------------------------------------

cleaned_file_path = (
    "01_Dataset/amazon_ecommerce_1M_cleaned.csv"
)

df.to_csv(
    cleaned_file_path,
    index=False
)

print("\nCleaned dataset saved successfully!")

print(cleaned_file_path)


# ------------------------------------------------------------
# END
# ------------------------------------------------------------

print(
    "\n============================================================"
)

print("PYTHON DATA CLEANING COMPLETED")

print(
    "============================================================"
)