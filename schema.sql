-- V Corner | MySQL 8.0+ | العملة: IQD
CREATE DATABASE IF NOT EXISTS perfume_store CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE perfume_store;

CREATE TABLE IF NOT EXISTS brands (
  brand_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  brand_name VARCHAR(150) NOT NULL,
  brand_name_ar VARCHAR(150) NULL,
  brand_type ENUM('designer','luxury','arabian','mass_market','pharmacy','other') NOT NULL DEFAULT 'other',
  country_of_origin VARCHAR(100) NULL,
  PRIMARY KEY (brand_id), UNIQUE KEY uq_brands_name (brand_name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS categories (
  category_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  category_name VARCHAR(120) NOT NULL,
  category_name_ar VARCHAR(120) NOT NULL,
  PRIMARY KEY (category_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS products (
  product_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sku VARCHAR(64) NULL,
  brand_id BIGINT UNSIGNED NOT NULL,
  category_id BIGINT UNSIGNED NOT NULL,
  product_name VARCHAR(200) NOT NULL,
  product_name_ar VARCHAR(200) NULL,
  product_type ENUM('perfume','deodorant','antiperspirant','body_spray','other') NOT NULL DEFAULT 'perfume',
  target_gender ENUM('men','women','unisex','kids','all') NOT NULL DEFAULT 'unisex',
  authenticity ENUM('original','independent_alternative','inspired_by','unknown') NOT NULL DEFAULT 'unknown',
  concentration VARCHAR(80) NULL,
  volume_ml DECIMAL(8,2) NULL,
  price_iqd DECIMAL(14,2) NOT NULL DEFAULT 0,   -- سعر البيع
  cost_iqd DECIMAL(14,2) NOT NULL DEFAULT 0,    -- سعر الشراء (سري: لا يُعرض للزبائن)
  stock_quantity INT NOT NULL DEFAULT 0,
  image_url VARCHAR(1000) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (product_id),
  UNIQUE KEY uq_products_sku (sku),
  KEY ix_products_active (is_active, product_type),
  CONSTRAINT fk_products_brand FOREIGN KEY (brand_id) REFERENCES brands(brand_id),
  CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories(category_id),
  CONSTRAINT ck_price CHECK (price_iqd >= 0 AND cost_iqd >= 0 AND stock_quantity >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS orders (
  order_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_number VARCHAR(40) NOT NULL,
  customer_name VARCHAR(200) NOT NULL,
  customer_phone VARCHAR(50) NOT NULL,
  city VARCHAR(100) NOT NULL,
  delivery_address TEXT NULL,
  total_iqd DECIMAL(14,2) NOT NULL,
  order_status ENUM('pending','confirmed','shipped','delivered','cancelled') NOT NULL DEFAULT 'pending',
  ordered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (order_id), UNIQUE KEY uq_orders_number (order_number),
  KEY ix_orders_status (order_status, ordered_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS order_items (
  order_item_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  quantity INT NOT NULL,
  unit_price_iqd DECIMAL(14,2) NOT NULL,
  unit_cost_iqd DECIMAL(14,2) NOT NULL DEFAULT 0, -- لقطة من التكلفة وقت البيع لحساب الربح بدقة
  PRIMARY KEY (order_item_id),
  CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
  CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS users (
  user_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(60) NOT NULL,
  password_hash VARCHAR(100) NOT NULL,
  role ENUM('admin','staff') NOT NULL DEFAULT 'staff',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (user_id), UNIQUE KEY uq_users_name (username)
) ENGINE=InnoDB;

-- تحليل المنافسين: تُدخل الأسعار يدوياً من مراقبتك للسوق
CREATE TABLE IF NOT EXISTS competitor_prices (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  competitor_name VARCHAR(150) NOT NULL,
  product_label VARCHAR(200) NOT NULL,
  competitor_price_iqd DECIMAL(14,2) NOT NULL,
  our_product_id BIGINT UNSIGNED NULL,
  notes VARCHAR(500) NULL,
  observed_at DATE NOT NULL DEFAULT (CURRENT_DATE),
  PRIMARY KEY (id),
  CONSTRAINT fk_cp_product FOREIGN KEY (our_product_id) REFERENCES products(product_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- فجوات السوق: ما لا يقدمه المنافسون
CREATE TABLE IF NOT EXISTS market_gaps (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  gap_title VARCHAR(200) NOT NULL,
  details VARCHAR(1000) NULL,
  status ENUM('idea','planned','done') NOT NULL DEFAULT 'idea',
  PRIMARY KEY (id)
) ENGINE=InnoDB;

INSERT IGNORE INTO categories (category_id, category_name, category_name_ar) VALUES
 (1,'Perfumes','عطور'),(2,'Deodorants','مزيلات عرق'),(3,'Body sprays','بخاخات جسم');
INSERT IGNORE INTO market_gaps (id, gap_title, details) VALUES
 (1,'فصل الأصلي عن البديل بوضوح','كثير من المتاجر تخلط الوصف؛ نعرض شارة "أصلي" أو "بديل مستقل" على كل منتج'),
 (2,'توصيل وتأكيد عبر الواتساب خلال دقائق','طلب يصل مباشرة لشاشة الإدارة ويُؤكَّد برسالة جاهزة');
