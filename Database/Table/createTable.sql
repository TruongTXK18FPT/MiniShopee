-- Database
CREATE DATABASE MiniShopee;
-- 1.Bảng Người dùng và Bảo mật
CREATE TABLE Users (
	id Binary(16) PRIMARY KEY,
    email varchar(255) UNIQUE NOT NULL,
    bio varchar(255),
    password_hash varchar(255) NOT NULL,
    full_name varchar(100),
    phone_number varchar(20),
    avatar_url text,
    role enum('admin','seller','kol','shop_manager','customer','service','sale_manager','video_corrector','supervisor') default 'customer',
    is_email_verified boolean default FALSE,
    birth_day date,
    gender varchar(10),
    created_at timestamp default current_timestamp,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
CREATE TABLE Addresses (
	address_id binary(16) PRIMARY KEY,
    user_id binary(16),
    street text,
    city varchar(100),
    state varchar(100),
    postal_code varchar(20),
    country varchar(100),
    is_default boolean default false,
    foreign key(user_id) references Users(id)
);
-- 2. Bảng sản phẩm và danh mục
CREATE TABLE Products(
	product_id binary(16) primary key,
    name varchar(255) not null,
    description text,
    price decimal(10,2),
    discount_percent float,
    discount_price decimal(10,2) generated always as(price * discount_percent * 100) STORED,
    seller_id binary(16),
    category_id binary(16),
    created_at timestamp default current_timestamp,
    updated_at timestamp default current_timestamp on update current_timestamp,
    foreign key (seller_id) references Users(id),
    foreign key (category_id) references Categories(category_id)
);
CREATE TABLE Categories(
	category_id binary(16) primary key,
    name varchar(100) unique not null,
    parent_category_id binary(16),
    foreign key (parent_category_id) references Categories(category_id)
);
CREATE TABLE Product_Image(
	product_img_id binary(16) primary key,
    product_id binary(16),
    product_img text,
    order_number int,
    foreign key (product_id) references Products(product_id) 
);
CREATE TABLE Product_Details(
	id binary(16) primary key,
    product_id binary(16),
    specifications json,
    warrantly varchar(100),
    origin varchar(100),
    material varchar(100),
    foreign key (product_id) references Products(product_id)
);
CREATE TABLE Inventory(
	inventory_id binary(16) primary key,
    product_id binary(16),
    sku varchar(50) unique,
    quantiy int,
    variant json,
    foreign key (product_id) references Products(product_id) 
);
-- 3. Bảng đơn hàng và thanh toán
CREATE TABLE Orders(
	id binary(16) primary key,
    user_id binary(16),
    total_amount decimal(10,2),
    status enum ('pending','processing','shipped','deliveried', 'cancelled') default 'pending', -- Trạng thái đơn hàng
    payment_method enum ('Cash On Delivery', 'Credit Card','Momo','Wallet Coin') default 'Cash On Delivery', -- Phương thức thanh toán
    coupon_id binary(16),
    shipping_address_id binary(16),
    created_at timestamp default current_timestamp,
    foreign key (user_id) references Users(id),
    foreign key (shipping_address_id) references Addresses(address_id),
    foreign key (coupon_id) references Coupons(id)
);
CREATE TABLE Order_Items(
	id binary(16) primary key,
    order_id binary(16),
    product_id binary(16),
    quantity int,
    price_at_purchase decimal(10,2),
    foreign key (order_id) references Orders(id),
    foreign key (product_id) references Products(product_id) 
);
CREATE TABLE Payments(
	payment_id binary(16) primary key,
    order_id binary(16),
    amount decimal(10,2),
    transaction_id varchar(255),
    status enum('success','failed','pending') default 'pending',
    created_at timestamp default current_timestamp,
    foreign key (order_id) references Orders(id)
);
-- 4. Bảng giỏ hàng và yêu thích
CREATE TABLE Carts(
	id binary(16) primary key,
    user_id binary(16),
    created_at timestamp default current_timestamp,
    foreign key(user_id) references Users(id)
);
CREATE TABLE Cart_Items(
	id binary(16) primary key,
    cart_id binary(16),
    product_id binary(16),
    quantity int,
    foreign key (cart_id) references Carts(id),
    foreign key (product_id) references Products(product_id) 
);
-- 5. Bảng đánh giá và tương tác
CREATE TABLE Reviews(
	id binary(16) primary key,
    product_id binary(16),
    user_id binary(16),
    rating tinyint NOT NULL CHECK(rating Between 1 and 5),
    comment text,
    created_at timestamp default current_timestamp,
    foreign key (product_id) references Products(product_id),
    foreign key (user_id) references Users(id)
);
-- 6. Nhóm khuyến mãi
CREATE TABLE Coupons(
	id binary(16) primary key,
    code varchar(50) UNIQUE,
    discount_type enum('percentage','fixed') default 'percentage',
    discount_value decimal(10,2),
    expire_at timestamp,
    max_usage int
);
-- 7. Nhóm ví ảo và Coin
CREATE TABLE User_Wallets(
	id binary(16) primary key,
    user_id binary(16),
    balance decimal(12,2),
    currency VARCHAR(10) default 'MSOSS Coin',
    created_at timestamp default current_timestamp,
    updated_at timestamp default current_timestamp on update current_timestamp,
    foreign key (user_id) references Users(id)
);
CREATE TABLE Transactions(
	id binary(16) primary key,
	wallet_id binary(16),
    amount decimal(12,2),
    type enum('deposit','withdraw','purchase','reward','transfer') default 'deposit',
    status enum('pending','success','failed') default 'pending',
    description varchar(255),
    reference_id binary(16),
    created_at timestamp default current_timestamp,
    foreign key (wallet_id) references User_Wallets(id)
);
-- 8. Bảng Livestream KOL
CREATE TABLE LiveStreams(
	id binary(16) primary key,
    kol_id binary(16),
    title varchar(255),
    start_time timestamp,
    end_time timestamp,
    status enum('scheduled','live','ended') default 'scheduled',
    thumbnail_url text,
    foreign key (kol_id) references Kol_Profiles(id)
);
CREATE TABLE Kol_Profiles(
	id binary(16) primary key,
    bio text,
    social_links json,
    total_followers int
);
-- 9. Bảng Mini Game
CREATE TABLE Games(
	id binary(16) primary key,
    name varchar(100),
    type enum('spin_wheel','quiz','puzzle'),
    max_attempts int
);
CREATE TABLE User_game_attempts(
	user_id binary(16),
    game_id binary(16),
    attempt_date date,
    score int,
    foreign key (user_id) references Users(id),
    foreign key(game_id) references Games(id)
);
-- 10. Bảng Blog
CREATE TABLE Blog_posts(
	id binary(16),
    author_id binary(16),
    title varchar(255),
    content text,
    status enum('draft','published', 'archived') default 'draft',
    published_at timestamp
);
-- 11. Bảng Xếp hạng thành viên
CREATE TABLE Membership_tiers(
	id binary(16),
    name varchar(50),
    min_points int,
    discount_rate decimal(5,2),
    badge_icon varchar(255)
);
CREATE TABLE User_memberships(
	user_id binary(16),
    tier_id binary(16),
    current_points int,
    expires_at timestamp
);
-- 12. Bảng thông báo
CREATE TABLE notifications (
    id BINARY(16) PRIMARY KEY,
    user_id BINARY(16) NOT NULL,
    type ENUM('order', 'promotion', 'system', 'livestream') NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    status ENUM('unread', 'read') DEFAULT 'unread',
    link VARCHAR(255),
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
-- Index cho truy vấn thông báo theo user và trạng thái
CREATE INDEX idx_notifications_user_status ON notifications(user_id, status);
-- 13. Bảng nhật ký kiểm tra hệ thống
CREATE TABLE audit_logs (
    id BINARY(16) PRIMARY KEY,
    user_id BINARY(16),
    action_type ENUM('create', 'update', 'delete') NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id BINARY(16) NOT NULL,
    old_value JSON,
    new_value JSON,
    metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Index cho truy vấn nhanh theo entity
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
-- Users table indexes
CREATE INDEX idx_users_email ON Users(email);
CREATE INDEX idx_users_role ON Users(role);

-- Addresses table indexes
CREATE INDEX idx_addresses_user_id ON Addresses(user_id);

-- Products table indexes
CREATE INDEX idx_products_seller_id ON Products(seller_id);
CREATE INDEX idx_products_category_id ON Products(category_id);
CREATE INDEX idx_products_price ON Products(price);

-- Categories table indexes
CREATE INDEX idx_categories_parent_category_id ON Categories(parent_category_id);

-- Product_Image table indexes
CREATE INDEX idx_product_image_product_id ON Product_Image(product_id);

-- Inventory table indexes
CREATE INDEX idx_inventory_product_id ON Inventory(product_id);
CREATE INDEX idx_inventory_sku ON Inventory(sku);

-- Orders table indexes
CREATE INDEX idx_orders_user_id ON Orders(user_id);
CREATE INDEX idx_orders_status ON Orders(status);
CREATE INDEX idx_orders_payment_method ON Orders(payment_method);
CREATE INDEX idx_orders_shipping_address_id ON Orders(shipping_address_id);
CREATE INDEX idx_orders_coupon_id ON Orders(coupon_id);

-- Order_Items table indexes
CREATE INDEX idx_order_items_order_id ON Order_Items(order_id);
CREATE INDEX idx_order_items_product_id ON Order_Items(product_id);

-- Payments table indexes
CREATE INDEX idx_payments_order_id ON Payments(order_id);
CREATE INDEX idx_payments_status ON Payments(status);

-- Carts table indexes
CREATE INDEX idx_carts_user_id ON Carts(user_id);

-- Cart_Items table indexes
CREATE INDEX idx_cart_items_cart_id ON Cart_Items(cart_id);
CREATE INDEX idx_cart_items_product_id ON Cart_Items(product_id);

-- Reviews table indexes
CREATE INDEX idx_reviews_product_id ON Reviews(product_id);
CREATE INDEX idx_reviews_user_id ON Reviews(user_id);

-- Coupons table indexes
CREATE INDEX idx_coupons_code ON Coupons(code);
CREATE INDEX idx_coupons_expire_at ON Coupons(expire_at);

-- User_Wallets table indexes
CREATE INDEX idx_user_wallets_user_id ON User_Wallets(user_id);

-- Transactions table indexes
CREATE INDEX idx_transactions_wallet_id ON Transactions(wallet_id);
CREATE INDEX idx_transactions_status ON Transactions(status);
CREATE INDEX idx_transactions_reference_id ON Transactions(reference_id);

-- LiveStreams table indexes
CREATE INDEX idx_livestreams_kol_id ON LiveStreams(kol_id);
CREATE INDEX idx_livestreams_status ON LiveStreams(status);

-- Kol_Profiles table indexes
CREATE INDEX idx_kol_profiles_total_followers ON Kol_Profiles(total_followers);

-- Games table indexes
CREATE INDEX idx_games_type ON Games(type);

-- User_game_attempts table indexes
CREATE INDEX idx_user_game_attempts_user_id ON User_game_attempts(user_id);
CREATE INDEX idx_user_game_attempts_game_id ON User_game_attempts(game_id);

-- Blog_posts table indexes
CREATE INDEX idx_blog_posts_author_id ON Blog_posts(author_id);
CREATE INDEX idx_blog_posts_status ON Blog_posts(status);

-- Membership_tiers table indexes
CREATE INDEX idx_membership_tiers_min_points ON Membership_tiers(min_points);

-- User_memberships table indexes
CREATE INDEX idx_user_memberships_user_id ON User_memberships(user_id);
CREATE INDEX idx_user_memberships_tier_id ON User_memberships(tier_id);

-- Audit_logs table indexes
CREATE INDEX idx_audit_logs_user_id ON Audit_logs(user_id);
