# SPOS (Smart Point of Sale) ☕ 🍔

A modern, mobile-friendly, multi-tenant SaaS Point of Sale (POS) system optimized for coffee shops, cafes, and restaurants. Built with **Ruby on Rails 8**, **Tailwind CSS**, and powered by **Midtrans Payment Gateway** for subscriptions.

**[ Link Live Demo ](https://kasirku.fly.dev/)**

 **Demo Account**
  * Owner: owner@kedaikopi.com / password
  * Admin: admin@kedaikopi.com / password
---

## 📖 About the Project

**SPOS** is a multi-tenant Software-as-a-Service (SaaS) application designed to allow food and beverage business owners to set up their own POS terminals. Business owners can register their establishment (tenant), select a subscription plan, and immediately access a dedicated, dark-themed POS dashboard. 

The application is structured to offer secure data separation for each business, support staff roles (Owner and Admin/Cashier), manage real-time inventory levels, and handle payment processing.

---

## ✨ Key Features

### 🛒 1. Point of Sale Terminal (POS)
* **Mobile-First & Fully Responsive:** Clean, premium dark-mode user interface designed for tablets, mobile devices, and desktops.
* **Instant Product Filtering:** Fast text-based search and quick category toggle filters (`All`, `Food`, `Beverages`).
* **Floating Interactive Cart:** Adds products in real-time, displays item counts, updates total pricing, and manages item additions/removals.
* **Easy Checkout:** Instant popup screens upon successful checkout, allowing cashiers to save transactions or print invoices.

### 📊 2. Owner Dashboard & Management
* **Real-time Analytics:** Visual representation of business metrics using line charts (powered by `Chartkick` and `Groupdate`).
* **Transaction Reports:** Detailed tables of successful and canceled transactions with options to filter data by custom date ranges.
* **User Management:** Owners can register and manage store Admins/Staff (capped at a maximum of 2 admins per tenant to enforce subscription plans).

### 📦 3. Inventory & Product Administration
* **Product Catalog (CRUD):** Admins can manage products with names, description details, category tags, pricing, and stock amounts.
* **Dynamic Stock Level Badges:** Real-time visibility into inventory statuses (e.g., `Out of Stock` blocks purchase, `Low Stock` labels count limits).
* **Inventory Quick Controls:** Simple dashboard views for staff to adjust and manage stock levels quickly.

### 💳 4. Multi-Tenant SaaS & Subscription System
* **Tenant Isolation:** Automatic scoping of database queries using the `acts_as_tenant` gem to prevent data leakage between different restaurants.
* **Subscription Management:** Subscription signup flow with options for Monthly or Annual payment plans.
* **Midtrans Payment Integration:** Real-time generation of Midtrans Snap redirect URLs and tokens, coupled with secure webhook notification processing.
* **Subscription Grace Period & Expiry Alerts:** Alerts users on login if their subscription is about to expire (within 7 days) or has expired.

### 🚀 5. Production & DevOps Ready
* **Kamal Deployment:** Complete config for dockerized single-command deployments using Kamal.
* **Fly.io Configurations:** Preconfigured `fly.toml` for simple cloud hosting.
* **Litestream Integration:** Seamless replication of SQLite databases to S3-compatible object storage for lightweight, zero-maintenance disaster recovery.

---

## 🛠️ Tech Stack

* **Language & Framework:** [Ruby 3.3.11](https://www.ruby-lang.org/) / [Ruby on Rails 8.1.x](https://rubyonrails.org/)
* **Database:** SQLite 3 (configured with Solid Cache, Solid Queue, and Solid Cable)
* **CSS & Frontend Styling:** Tailwind CSS
* **JavaScript & SPA Engine:** Hotwire (Turbo & Stimulus)
* **Authentication:** Devise
* **Authorization:** Pundit
* **Search Engine:** Ransack
* **Replication & Backup:** Litestream
* **Payment Gateway Integration:** Veritrans (Midtrans API client)
* **Visualizations:** Chartkick & Groupdate

---

## 🚀 Getting Started

### 📋 Prerequisites
Make sure you have the following installed on your local machine:
* Ruby 3.3.11
* SQLite 3
* Bundler

### 🔧 Installation & Database Setup
1. Clone this repository and navigate to the project directory:
   ```bash
   cd spos
   ```

2. Run the automated setup script. This will install gem dependencies, prepare/seed the SQLite database, and clean logs:
   ```bash
   bin/setup
   ```

### 💻 Running Locally
To launch the application server and compile assets (Tailwind compilation watch task) concurrently:
```bash
bin/dev
```
Open your browser and navigate to `http://localhost:3000`.

---

## 🔑 Seeded Accounts (Development)

To test the application locally without creating a new subscription, use the credentials preloaded during database seeding:

### 🏝️ Tenant 1: Warung Bahari (Indonesian Food)
* **Owner account:** `owner@warungbahari.com` / `password`
* **Admin/Staff account:** `admin@warungbahari.com` / `password`
* **Cashier account:** `kasir@warungbahari.com` / `password`

### ☕ Tenant 2: Kedai Kopi Senja (Coffee Shop)
* **Owner account:** `owner@kedaikopi.com` / `password`
* **Admin/Staff account:** `admin@kedaikopi.com` / `password`

### 🌶️ Tenant 3: RM Padang Sederhana (Minang Cuisine)
* **Owner account:** `owner@padangsederhana.com` / `password`
* **Admin/Staff account:** `admin@padangsederhana.com` / `password`

---

## ⚙️ Configuration & Environment Variables

If you are setting up your own registration and subscription system, you need to configure your **Midtrans** keys. You can add them as environment variables or save them in Rails encrypted credentials:

```bash
MIDTRANS_SERVER_KEY="your-midtrans-server-key"
MIDTRANS_CLIENT_KEY="your-midtrans-client-key"
```

For **Litestream** backups, configure the following credentials to link your SQLite database replication to your S3 bucket:
```bash
LITESTREAM_REPLICA_BUCKET="your-s3-bucket-name"
LITESTREAM_ACCESS_KEY_ID="your-s3-access-key-id"
LITESTREAM_SECRET_ACCESS_KEY="your-s3-secret-access-key"
```
