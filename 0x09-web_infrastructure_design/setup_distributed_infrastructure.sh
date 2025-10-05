#!/bin/bash

# Distributed Web Infrastructure Setup Script
# This script sets up a three-server distributed web infrastructure
# Author: Infrastructure Design Team
# Date: $(date)

set -e  # Exit on any error

echo "=========================================="
echo "Distributed Web Infrastructure Setup"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration variables
LOAD_BALANCER_IP="8.8.8.8"
WEB_SERVER_1_IP="10.0.0.2"
WEB_SERVER_2_IP="10.0.0.3"
DATABASE_SERVER_IP="10.0.0.4"
DOMAIN_NAME="www.foobar.com"

# Logging functions
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Detect server role based on IP address
detect_server_role() {
    local current_ip=$(hostname -I | awk '{print $1}')
    
    case $current_ip in
        $LOAD_BALANCER_IP)
            echo "load_balancer"
            ;;
        $WEB_SERVER_1_IP|$WEB_SERVER_2_IP)
            echo "web_server"
            ;;
        $DATABASE_SERVER_IP)
            echo "database_server"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
        exit 1
    fi
}

# Update system packages
update_system() {
    log "Updating system packages..."
    apt-get update -y
    apt-get upgrade -y
    log "System updated successfully"
}

# Setup Load Balancer (HAproxy)
setup_load_balancer() {
    log "Setting up Load Balancer (HAproxy)..."
    
    # Install HAproxy
    apt-get install haproxy -y
    
    # Backup original configuration
    cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.backup
    
    # Create HAproxy configuration
    cat > /etc/haproxy/haproxy.cfg << EOF
global
    daemon
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy

    # Default SSL material locations
    ca-base /etc/ssl/certs
    crt-base /etc/ssl/private

    # Default ciphers to use on SSL-enabled listening sockets
    ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS
    ssl-default-bind-options no-sslv3

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http

frontend web_frontend
    bind *:80
    # bind *:443 ssl crt /etc/ssl/certs/foobar.com.pem  # For future HTTPS
    default_backend web_servers

backend web_servers
    balance roundrobin
    option httpchk GET /health
    http-check expect status 200
    
    server web1 $WEB_SERVER_1_IP:80 check
    server web2 $WEB_SERVER_2_IP:80 check

# Statistics page
listen stats
    bind *:8080
    stats enable
    stats uri /stats
    stats realm HAproxy\ Statistics
    stats auth admin:password123
EOF

    # Enable and start HAproxy
    systemctl enable haproxy
    systemctl start haproxy
    
    # Test configuration
    haproxy -f /etc/haproxy/haproxy.cfg -c
    
    if [ $? -eq 0 ]; then
        log "HAproxy configured and started successfully"
        log "Statistics available at http://$LOAD_BALANCER_IP:8080/stats"
    else
        error "HAproxy configuration failed"
        exit 1
    fi
}

# Setup Web Server
setup_web_server() {
    log "Setting up Web Server (Nginx + PHP)..."
    
    # Install Nginx and PHP
    apt-get install nginx php-fpm php-mysql php-curl php-gd php-mbstring php-xml php-zip -y
    
    # Create health check endpoint
    mkdir -p /var/www/html
    echo "OK" > /var/www/html/health
    
    # Configure Nginx for load balancer
    cat > /etc/nginx/sites-available/foobar.com << 'EOF'
server {
    listen 80;
    server_name _;
    root /var/www/foobar.com;
    index index.php index.html index.htm;

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "OK\n";
        add_header Content-Type text/plain;
    }

    # Main location block
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # PHP processing
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
        
        # Add server identification header
        add_header X-Served-By $hostname;
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
    }

    # Static files caching
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

    # Enable the site
    ln -sf /etc/nginx/sites-available/foobar.com /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    
    # Create application directory
    mkdir -p /var/www/foobar.com
    
    # Create sample application
    cat > /var/www/foobar.com/index.php << 'EOF'
<?php
/**
 * Distributed Web Application
 * Demonstrates load-balanced LAMP stack
 */

// Database configuration
$primary_host = '10.0.0.4';
$replica_host = '10.0.0.4';
$username = 'webuser';
$password = 'webpass123';
$database = 'foobar_db';
$primary_port = 3306;
$replica_port = 3307;

// Get server information
$server_name = gethostname();
$server_ip = $_SERVER['SERVER_ADDR'] ?? 'N/A';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Distributed Infrastructure - Foobar.com</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: rgba(255,255,255,0.1);
            padding: 20px;
            border-radius: 15px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        .server-info {
            background: rgba(255,255,255,0.2);
            padding: 20px;
            border-radius: 10px;
            margin: 20px 0;
        }
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }
        .card {
            background: rgba(255,255,255,0.15);
            padding: 20px;
            border-radius: 10px;
            border: 1px solid rgba(255,255,255,0.2);
        }
        .status {
            display: inline-block;
            padding: 5px 15px;
            border-radius: 20px;
            font-weight: bold;
            margin: 5px 0;
        }
        .success { background: #28a745; }
        .error { background: #dc3545; }
        .warning { background: #ffc107; color: #000; }
        .info { background: #17a2b8; }
        h1, h2, h3 { margin-top: 0; }
        ul { margin: 10px 0; padding-left: 20px; }
        .highlight { background: rgba(255,255,0,0.3); padding: 2px 5px; border-radius: 3px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🌐 Distributed Web Infrastructure</h1>
            <h2>www.foobar.com</h2>
            <p>Three-Server Load Balanced Architecture</p>
        </div>
        
        <div class="server-info">
            <h3>🖥️ Current Server Information</h3>
            <p><strong>Server Name:</strong> <span class="highlight"><?php echo $server_name; ?></span></p>
            <p><strong>Server IP:</strong> <span class="highlight"><?php echo $server_ip; ?></span></p>
            <p><strong>Request Time:</strong> <?php echo date('Y-m-d H:i:s'); ?></p>
            <p><strong>PHP Version:</strong> <?php echo phpversion(); ?></p>
        </div>
        
        <div class="grid">
            <div class="card">
                <h3>⚖️ Load Balancer Status</h3>
                <p><strong>HAproxy:</strong> <span class="status success">Active</span></p>
                <p><strong>Algorithm:</strong> Round Robin</p>
                <p><strong>Setup:</strong> Active-Active</p>
                <p><strong>Servers:</strong> 2 Web Servers</p>
                <ul>
                    <li>Web Server 1: 10.0.0.2</li>
                    <li>Web Server 2: 10.0.0.3</li>
                </ul>
            </div>
            
            <div class="card">
                <h3>🌐 Web Server Status</h3>
                <p><strong>Nginx:</strong> <span class="status success">Running</span></p>
                <p><strong>PHP-FPM:</strong> <span class="status success">Running</span></p>
                <p><strong>Current Server:</strong> <?php echo ($server_ip == '10.0.0.2') ? 'Web Server 1' : 'Web Server 2'; ?></p>
                <p><strong>Load Distribution:</strong> Automatic</p>
            </div>
            
            <div class="card">
                <h3>🗄️ Database Status</h3>
                <?php
                // Test primary database connection
                try {
                    $primary_pdo = new PDO("mysql:host=$primary_host:$primary_port", $username, $password);
                    echo '<p><strong>Primary (Master):</strong> <span class="status success">Connected</span></p>';
                    $primary_connected = true;
                } catch(PDOException $e) {
                    echo '<p><strong>Primary (Master):</strong> <span class="status error">Failed</span></p>';
                    $primary_connected = false;
                }
                
                // Test replica database connection
                try {
                    $replica_pdo = new PDO("mysql:host=$replica_host:$replica_port", $username, $password);
                    echo '<p><strong>Replica (Slave):</strong> <span class="status success">Connected</span></p>';
                    $replica_connected = true;
                } catch(PDOException $e) {
                    echo '<p><strong>Replica (Slave):</strong> <span class="status warning">Not Available</span></p>';
                    $replica_connected = false;
                }
                ?>
                <p><strong>Setup:</strong> Primary-Replica</p>
                <p><strong>Replication:</strong> Asynchronous</p>
            </div>
            
            <div class="card">
                <h3>📊 Request Information</h3>
                <p><strong>Client IP:</strong> <?php echo $_SERVER['REMOTE_ADDR'] ?? 'N/A'; ?></p>
                <p><strong>User Agent:</strong> <?php echo substr($_SERVER['HTTP_USER_AGENT'] ?? 'N/A', 0, 50) . '...'; ?></p>
                <p><strong>Request Method:</strong> <?php echo $_SERVER['REQUEST_METHOD'] ?? 'N/A'; ?></p>
                <p><strong>Load Balancer:</strong> <?php echo $_SERVER['HTTP_X_FORWARDED_FOR'] ?? 'Direct'; ?></p>
            </div>
        </div>
        
        <div class="card">
            <h3>🏗️ Infrastructure Architecture</h3>
            <ul>
                <li><strong>Load Balancer:</strong> HAproxy with Round Robin distribution</li>
                <li><strong>Web Servers:</strong> 2x Nginx + PHP-FPM (Active-Active setup)</li>
                <li><strong>Database:</strong> MySQL Primary-Replica cluster</li>
                <li><strong>Application:</strong> Distributed PHP application with shared codebase</li>
                <li><strong>Network:</strong> Private network with public load balancer</li>
            </ul>
        </div>
        
        <div class="card">
            <h3>⚠️ Known Infrastructure Issues</h3>
            <ul>
                <li><strong>SPOF:</strong> Load balancer and primary database are single points of failure</li>
                <li><strong>Security:</strong> No firewall protection or HTTPS encryption</li>
                <li><strong>Monitoring:</strong> No comprehensive monitoring system in place</li>
                <li><strong>Network:</strong> No network segmentation or intrusion detection</li>
            </ul>
        </div>
        
        <div class="card">
            <h3>🔄 Load Balancing Demonstration</h3>
            <p>Refresh this page multiple times to see requests distributed between servers.</p>
            <p>Current request served by: <strong class="highlight"><?php echo $server_name; ?></strong></p>
            <button onclick="location.reload()">Refresh Page</button>
        </div>
    </div>
</body>
</html>
EOF

    # Set proper permissions
    chown -R www-data:www-data /var/www/foobar.com
    chmod -R 755 /var/www/foobar.com
    
    # Test Nginx configuration and restart
    nginx -t
    systemctl enable nginx php7.4-fpm
    systemctl restart nginx php7.4-fpm
    
    log "Web server configured successfully"
}

# Setup Database Server
setup_database_server() {
    log "Setting up Database Server (MySQL Primary-Replica)..."
    
    # Install MySQL
    MYSQL_ROOT_PASSWORD="secure_password_123"
    echo "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD" | debconf-set-selections
    echo "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD" | debconf-set-selections
    
    apt-get install mysql-server -y
    
    # Configure Primary MySQL instance
    cat > /etc/mysql/mysql.conf.d/primary.cnf << EOF
[mysqld]
bind-address = 0.0.0.0
server-id = 1
log-bin = mysql-bin
binlog-format = ROW
port = 3306

# Primary-specific settings
auto_increment_increment = 2
auto_increment_offset = 1
EOF

    # Configure Replica MySQL instance (on same server for demo)
    cat > /etc/mysql/mysql.conf.d/replica.cnf << EOF
[mysqld]
bind-address = 0.0.0.0
server-id = 2
log-bin = mysql-bin-replica
binlog-format = ROW
port = 3307
datadir = /var/lib/mysql-replica
socket = /var/run/mysqld/mysqld-replica.sock
pid-file = /var/run/mysqld/mysqld-replica.pid

# Replica-specific settings
read_only = 1
relay-log = relay-bin
relay-log-index = relay-bin.index
EOF

    # Create replica data directory
    mkdir -p /var/lib/mysql-replica
    chown mysql:mysql /var/lib/mysql-replica
    
    # Initialize replica database
    mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql-replica
    
    # Start primary MySQL
    systemctl restart mysql
    
    # Start replica MySQL
    mysqld_safe --defaults-file=/etc/mysql/mysql.conf.d/replica.cnf --user=mysql &
    
    # Create database and users
    mysql -u root -p$MYSQL_ROOT_PASSWORD << EOF
-- Create application database
CREATE DATABASE IF NOT EXISTS foobar_db;

-- Create application user
CREATE USER IF NOT EXISTS 'webuser'@'%' IDENTIFIED BY 'webpass123';
GRANT ALL PRIVILEGES ON foobar_db.* TO 'webuser'@'%';

-- Create replication user
CREATE USER IF NOT EXISTS 'replica_user'@'%' IDENTIFIED BY 'replica_password';
GRANT REPLICATION SLAVE ON *.* TO 'replica_user'@'%';

-- Create sample table and data
USE foobar_db;
CREATE TABLE IF NOT EXISTS visitors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ip_address VARCHAR(45),
    user_agent TEXT,
    server_name VARCHAR(100),
    visit_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO visitors (ip_address, user_agent, server_name) 
VALUES ('127.0.0.1', 'Setup Script', 'Database Server');

FLUSH PRIVILEGES;

-- Show master status for replication setup
SHOW MASTER STATUS;
EOF

    log "Database server configured successfully"
    log "Primary MySQL running on port 3306"
    log "Replica MySQL running on port 3307"
}

# Configure firewall
setup_firewall() {
    log "Configuring firewall..."
    
    apt-get install ufw -y
    ufw --force reset
    
    local server_role=$(detect_server_role)
    
    case $server_role in
        "load_balancer")
            ufw default deny incoming
            ufw default allow outgoing
            ufw allow ssh
            ufw allow 80/tcp
            ufw allow 443/tcp
            ufw allow 8080/tcp  # HAproxy stats
            ;;
        "web_server")
            ufw default deny incoming
            ufw default allow outgoing
            ufw allow ssh
            ufw allow from $LOAD_BALANCER_IP to any port 80
            ;;
        "database_server")
            ufw default deny incoming
            ufw default allow outgoing
            ufw allow ssh
            ufw allow from $WEB_SERVER_1_IP to any port 3306
            ufw allow from $WEB_SERVER_2_IP to any port 3306
            ufw allow from $WEB_SERVER_1_IP to any port 3307
            ufw allow from $WEB_SERVER_2_IP to any port 3307
            ;;
    esac
    
    ufw --force enable
    log "Firewall configured for $server_role"
}

# Main setup function
main() {
    local server_role=$(detect_server_role)
    
    log "Starting setup for server role: $server_role"
    
    check_root
    update_system
    
    case $server_role in
        "load_balancer")
            setup_load_balancer
            ;;
        "web_server")
            setup_web_server
            ;;
        "database_server")
            setup_database_server
            ;;
        "unknown")
            warn "Server role could not be determined. Please run setup manually."
            info "Expected IPs:"
            info "Load Balancer: $LOAD_BALANCER_IP"
            info "Web Server 1: $WEB_SERVER_1_IP"
            info "Web Server 2: $WEB_SERVER_2_IP"
            info "Database Server: $DATABASE_SERVER_IP"
            exit 1
            ;;
    esac
    
    setup_firewall
    
    echo
    echo "=========================================="
    log "Setup completed for $server_role!"
    echo "=========================================="
    
    case $server_role in
        "load_balancer")
            echo "Load Balancer configured:"
            echo "- Website: http://$DOMAIN_NAME"
            echo "- Statistics: http://$LOAD_BALANCER_IP:8080/stats"
            echo "- Backend servers: $WEB_SERVER_1_IP, $WEB_SERVER_2_IP"
            ;;
        "web_server")
            echo "Web Server configured:"
            echo "- Nginx and PHP-FPM running"
            echo "- Health check: http://$(hostname -I | awk '{print $1}')/health"
            echo "- Application files in /var/www/foobar.com"
            ;;
        "database_server")
            echo "Database Server configured:"
            echo "- Primary MySQL: port 3306"
            echo "- Replica MySQL: port 3307"
            echo "- Database: foobar_db"
            echo "- User: webuser / webpass123"
            ;;
    esac
    
    echo
    warn "Remember to:"
    echo "1. Configure DNS to point $DOMAIN_NAME to $LOAD_BALANCER_IP"
    echo "2. Set up proper SSL certificates for HTTPS"
    echo "3. Implement monitoring and alerting"
    echo "4. Regular backups and security updates"
}

# Run main function
main "$@"
