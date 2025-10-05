#!/bin/bash

# Setup Script for Scale Up Web Infrastructure (Task 3)
# This script sets up a scaled infrastructure with component separation and load balancer clustering

set -e

echo "🔧 Starting Scale Up Web Infrastructure Setup..."

# Configuration
DOMAIN="www.foobar.com"
VIRTUAL_IP="8.8.8.8"
LB_MASTER_IP="10.0.0.10"
LB_BACKUP_IP="10.0.0.11"
WEB_SERVER_1_IP="10.0.0.20"
WEB_SERVER_2_IP="10.0.0.21"
APP_SERVER_IP="10.0.0.30"
DATABASE_SERVER_IP="10.0.0.40"

# Function to detect server role
detect_server_role() {
    local current_ip=$(hostname -I | awk '{print $1}')
    
    case $current_ip in
        $LB_MASTER_IP)
            echo "lb_master"
            ;;
        $LB_BACKUP_IP)
            echo "lb_backup"
            ;;
        $WEB_SERVER_1_IP)
            echo "web_server_1"
            ;;
        $WEB_SERVER_2_IP)
            echo "web_server_2"
            ;;
        $APP_SERVER_IP)
            echo "app_server"
            ;;
        $DATABASE_SERVER_IP)
            echo "database_server"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Update system packages
update_system() {
    echo "📦 Updating system packages..."
    apt-get update
    apt-get upgrade -y
    apt-get install -y curl wget software-properties-common ufw
}

# Setup Load Balancer Cluster with Keepalived
setup_load_balancer_cluster() {
    local role=$1
    echo "⚖️ Setting up load balancer cluster ($role)..."
    
    # Install HAproxy and Keepalived
    apt-get install -y haproxy keepalived
    
    # HAproxy configuration
    cat > /etc/haproxy/haproxy.cfg << 'EOF'
global
    daemon
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    
    # SSL Configuration
    ssl-default-bind-ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384
    ssl-default-bind-options no-sslv3 no-tlsv10 no-tlsv11

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms
    option httplog
    option dontlognull
    option http-server-close
    option forwardfor
    option redispatch
    retries 3

frontend web_frontend
    bind *:80
    bind *:443 ssl crt /etc/haproxy/certs/
    
    # Security headers
    http-response set-header X-Frame-Options DENY
    http-response set-header X-Content-Type-Options nosniff
    http-response set-header X-XSS-Protection "1; mode=block"
    
    # Redirect HTTP to HTTPS
    redirect scheme https if !{ ssl_fc }
    
    default_backend web_servers

backend web_servers
    balance roundrobin
    option httpchk GET /health
    http-check expect status 200
    
    server web1 10.0.0.20:80 check inter 2000 rise 2 fall 3
    server web2 10.0.0.21:80 check inter 2000 rise 2 fall 3

# Statistics interface
listen stats
    bind *:8404
    stats enable
    stats uri /stats
    stats refresh 30s
    stats admin if TRUE
EOF

    # Keepalived configuration
    if [ "$role" = "lb_master" ]; then
        PRIORITY=100
        STATE="MASTER"
    else
        PRIORITY=90
        STATE="BACKUP"
    fi
    
    cat > /etc/keepalived/keepalived.conf << EOF
vrrp_script chk_haproxy {
    script "/bin/kill -0 \`cat /var/run/haproxy.pid\`"
    interval 2
    weight 2
    fall 3
    rise 2
}

vrrp_instance VI_1 {
    state $STATE
    interface eth0
    virtual_router_id 51
    priority $PRIORITY
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass mypassword123
    }
    virtual_ipaddress {
        $VIRTUAL_IP
    }
    track_script {
        chk_haproxy
    }
}
EOF

    # Enable and start services
    systemctl enable haproxy keepalived
    systemctl restart haproxy keepalived
    
    echo "✅ Load balancer cluster configured ($role)"
}

# Setup dedicated web server (Nginx only)
setup_dedicated_web_server() {
    local server_num=$1
    echo "🌐 Setting up dedicated web server $server_num..."
    
    # Install Nginx
    apt-get install -y nginx
    
    # Nginx configuration optimized for static content
    cat > /etc/nginx/sites-available/default << 'EOF'
upstream app_server {
    server 10.0.0.30:9000 max_fails=3 fail_timeout=30s;
    keepalive 32;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    server_name www.foobar.com;
    root /var/www/html;
    index index.php index.html index.htm;
    
    # Optimize for static content
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|pdf|txt|tar|woff|svg|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header X-Served-By "Web-Server-$server_num";
        access_log off;
    }
    
    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
    
    # PHP processing - forward to application server
    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass app_server;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        fastcgi_param HTTP_X_FORWARDED_FOR $remote_addr;
        fastcgi_param HTTP_X_FORWARDED_PROTO $scheme;
    }
    
    # Default location for other requests
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
}
EOF

    # Optimize Nginx configuration
    cat > /etc/nginx/nginx.conf << 'EOF'
user www-data;
worker_processes auto;
pid /run/nginx.pid;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    # Basic Settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # Logging Settings
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                   '$status $body_bytes_sent "$http_referer" '
                   '"$http_user_agent" "$http_x_forwarded_for" '
                   '$request_time';
    
    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log;
    
    # Gzip Settings
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;
    
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF

    # Create sample content
    mkdir -p /var/www/html
    cat > /var/www/html/index.php << 'EOF'
<?php
echo "<h1>Web Infrastructure - Task 3: Scale Up</h1>";
echo "<p>Server: " . gethostname() . "</p>";
echo "<p>Server IP: " . $_SERVER['SERVER_ADDR'] . "</p>";
echo "<p>Client IP: " . $_SERVER['REMOTE_ADDR'] . "</p>";
echo "<p>Timestamp: " . date('Y-m-d H:i:s') . "</p>";

// Test application server connection
echo "<h2>Application Server Test</h2>";
$app_response = file_get_contents('http://10.0.0.30:9000/app-test.php');
echo "<p>App Server Response: " . ($app_response ? 'Connected' : 'Failed') . "</p>";
?>
EOF

    # Set permissions
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html
    
    # Enable and start Nginx
    systemctl enable nginx
    systemctl restart nginx
    
    echo "✅ Dedicated web server $server_num configured"
}

# Setup dedicated application server (PHP-FPM only)
setup_dedicated_app_server() {
    echo "🚀 Setting up dedicated application server..."
    
    # Install PHP-FPM
    apt-get install -y php7.4-fpm php7.4-mysql php7.4-curl php7.4-json php7.4-mbstring
    
    # PHP-FPM configuration optimized for application processing
    cat > /etc/php/7.4/fpm/pool.d/www.conf << 'EOF'
[www]
user = www-data
group = www-data

; Listen on network interface for requests from web servers
listen = 9000
listen.owner = www-data
listen.group = www-data
listen.mode = 0660

; Process management
pm = dynamic
pm.max_children = 50
pm.start_servers = 10
pm.min_spare_servers = 5
pm.max_spare_servers = 20
pm.max_requests = 1000

; Performance tuning
pm.process_idle_timeout = 30s
request_terminate_timeout = 120s

; Security
security.limit_extensions = .php

; Logging
php_admin_value[error_log] = /var/log/php-fpm-errors.log
php_admin_flag[log_errors] = on
catch_workers_output = yes

; Session handling
php_value[session.save_handler] = files
php_value[session.save_path] = /var/lib/php/sessions

; Memory and execution limits
php_admin_value[memory_limit] = 256M
php_admin_value[max_execution_time] = 60
php_admin_value[upload_max_filesize] = 32M
php_admin_value[post_max_size] = 32M
EOF

    # Create application directory
    mkdir -p /var/www/application
    
    # Create test application
    cat > /var/www/application/app-test.php << 'EOF'
<?php
// Application server test endpoint
header('Content-Type: application/json');

$response = [
    'status' => 'success',
    'server' => gethostname(),
    'timestamp' => date('Y-m-d H:i:s'),
    'php_version' => phpversion(),
    'memory_usage' => memory_get_usage(true),
    'load_average' => sys_getloadavg()
];

echo json_encode($response);
?>
EOF

    cat > /var/www/application/index.php << 'EOF'
<?php
// Main application entry point
echo "<h1>Dedicated Application Server</h1>";
echo "<p>Server: " . gethostname() . "</p>";
echo "<p>PHP Version: " . phpversion() . "</p>";
echo "<p>Memory Usage: " . number_format(memory_get_usage(true) / 1024 / 1024, 2) . " MB</p>";

// Database connection test
try {
    $pdo = new PDO('mysql:host=10.0.0.40:3306;dbname=test', 'webapp', 'webapp_password');
    echo "<p>Database Connection: ✅ Connected</p>";
} catch (PDOException $e) {
    echo "<p>Database Connection: ❌ Failed - " . $e->getMessage() . "</p>";
}

// Load balancer info
if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
    echo "<p>Load Balancer IP: " . $_SERVER['HTTP_X_FORWARDED_FOR'] . "</p>";
}
?>
EOF

    # Set permissions
    chown -R www-data:www-data /var/www/application
    chmod -R 755 /var/www/application
    
    # Enable and start PHP-FPM
    systemctl enable php7.4-fpm
    systemctl restart php7.4-fpm
    
    echo "✅ Dedicated application server configured"
}

# Setup dedicated database server (MySQL only)
setup_dedicated_database_server() {
    echo "🗄️ Setting up dedicated database server..."
    
    # Install MySQL
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y mysql-server
    
    # MySQL configuration optimized for database operations
    cat > /etc/mysql/mysql.conf.d/99-custom.cnf << 'EOF'
[mysqld]
# Performance tuning
innodb_buffer_pool_size = 2G
innodb_log_file_size = 256M
innodb_log_buffer_size = 64M
innodb_flush_log_at_trx_commit = 2
innodb_file_per_table = 1

# Query cache
query_cache_type = 1
query_cache_size = 128M
query_cache_limit = 2M

# Connection settings
max_connections = 200
max_user_connections = 180
thread_cache_size = 16

# Buffer settings
key_buffer_size = 256M
sort_buffer_size = 2M
read_buffer_size = 1M
read_rnd_buffer_size = 4M
myisam_sort_buffer_size = 64M

# Logging
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 2
log_queries_not_using_indexes = 1

# Replication settings
server-id = 1
log-bin = mysql-bin
binlog_format = ROW
sync_binlog = 1
expire_logs_days = 7

# Network settings
bind-address = 0.0.0.0
EOF

    # Restart MySQL to apply configuration
    systemctl restart mysql
    
    # Secure MySQL installation
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'secure_root_password';"
    mysql -e "DELETE FROM mysql.user WHERE User='';"
    mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
    mysql -e "DROP DATABASE IF EXISTS test;"
    mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
    mysql -e "FLUSH PRIVILEGES;"
    
    # Create application database and user
    mysql -u root -psecure_root_password << 'EOF'
CREATE DATABASE IF NOT EXISTS webapp;
CREATE USER 'webapp'@'%' IDENTIFIED BY 'webapp_password';
GRANT ALL PRIVILEGES ON webapp.* TO 'webapp'@'%';

CREATE USER 'replica'@'%' IDENTIFIED BY 'replica_password';
GRANT REPLICATION SLAVE ON *.* TO 'replica'@'%';

FLUSH PRIVILEGES;
EOF

    # Create sample table
    mysql -u root -psecure_root_password webapp << 'EOF'
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (username, email) VALUES 
('john_doe', 'john@example.com'),
('jane_smith', 'jane@example.com'),
('admin', 'admin@foobar.com');
EOF

    echo "✅ Dedicated database server configured"
}

# Configure firewall for each component
setup_component_firewall() {
    local role=$1
    echo "🔒 Setting up firewall for $role..."
    
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
    
    case $role in
        "lb_master"|"lb_backup")
            ufw allow 22/tcp comment "SSH"
            ufw allow 80/tcp comment "HTTP"
            ufw allow 443/tcp comment "HTTPS"
            ufw allow 8404/tcp comment "HAproxy Stats"
            ufw allow from $LB_MASTER_IP comment "Keepalived Master"
            ufw allow from $LB_BACKUP_IP comment "Keepalived Backup"
            ;;
        "web_server_1"|"web_server_2")
            ufw allow 22/tcp comment "SSH"
            ufw allow from $LB_MASTER_IP to any port 80 comment "HTTP from LB Master"
            ufw allow from $LB_BACKUP_IP to any port 80 comment "HTTP from LB Backup"
            ;;
        "app_server")
            ufw allow 22/tcp comment "SSH"
            ufw allow from $WEB_SERVER_1_IP to any port 9000 comment "PHP-FPM from Web1"
            ufw allow from $WEB_SERVER_2_IP to any port 9000 comment "PHP-FPM from Web2"
            ;;
        "database_server")
            ufw allow 22/tcp comment "SSH"
            ufw allow from $APP_SERVER_IP to any port 3306 comment "MySQL from App Server"
            ;;
    esac
    
    ufw --force enable
    echo "✅ Firewall configured for $role"
}

# Main execution
main() {
    echo "🚀 Starting Task 3: Scale Up Web Infrastructure Setup"
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        echo "❌ This script must be run as root"
        exit 1
    fi
    
    # Detect server role
    SERVER_ROLE=$(detect_server_role)
    echo "🔍 Detected server role: $SERVER_ROLE"
    
    if [ "$SERVER_ROLE" = "unknown" ]; then
        echo "❌ Unable to detect server role. Please check IP configuration."
        exit 1
    fi
    
    # Common setup for all servers
    update_system
    setup_component_firewall $SERVER_ROLE
    
    # Role-specific setup
    case $SERVER_ROLE in
        "lb_master")
            setup_load_balancer_cluster "lb_master"
            ;;
        "lb_backup")
            setup_load_balancer_cluster "lb_backup"
            ;;
        "web_server_1")
            setup_dedicated_web_server "1"
            ;;
        "web_server_2")
            setup_dedicated_web_server "2"
            ;;
        "app_server")
            setup_dedicated_app_server
            ;;
        "database_server")
            setup_dedicated_database_server
            ;;
    esac
    
    echo "🎉 Task 3 setup completed successfully!"
    echo ""
    echo "🔗 Access points:"
    echo "   Website: https://www.foobar.com"
    echo "   HAproxy stats: http://${VIRTUAL_IP}:8404/stats"
    echo ""
    echo "📊 Server roles:"
    echo "   Load Balancer Master: ${LB_MASTER_IP}"
    echo "   Load Balancer Backup: ${LB_BACKUP_IP}"
    echo "   Web Server 1: ${WEB_SERVER_1_IP}"
    echo "   Web Server 2: ${WEB_SERVER_2_IP}"
    echo "   Application Server: ${APP_SERVER_IP}"
    echo "   Database Server: ${DATABASE_SERVER_IP}"
    echo ""
    echo "🚨 Next steps:"
    echo "1. Test load balancer failover"
    echo "2. Verify component separation"
    echo "3. Monitor performance metrics"
    echo "4. Set up SSL certificates"
}

# Run main function
main "$@"
