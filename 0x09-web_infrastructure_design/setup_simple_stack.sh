#!/bin/bash

# Simple Web Stack Setup Script
# This script sets up a complete LAMP stack on a single server
# Author: Infrastructure Design Team
# Date: $(date)

set -e  # Exit on any error

echo "=========================================="
echo "Simple Web Stack Installation Script"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
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

# Install Nginx web server
install_nginx() {
    log "Installing Nginx web server..."
    apt-get install nginx -y
    
    # Enable and start nginx
    systemctl enable nginx
    systemctl start nginx
    
    # Check if nginx is running
    if systemctl is-active --quiet nginx; then
        log "Nginx installed and started successfully"
    else
        error "Failed to start Nginx"
        exit 1
    fi
}

# Install MySQL database
install_mysql() {
    log "Installing MySQL database..."
    
    # Set MySQL root password (change this in production!)
    MYSQL_ROOT_PASSWORD="secure_password_123"
    
    # Pre-configure MySQL installation
    echo "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD" | debconf-set-selections
    echo "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD" | debconf-set-selections
    
    apt-get install mysql-server -y
    
    # Secure MySQL installation
    mysql -u root -p$MYSQL_ROOT_PASSWORD -e "DELETE FROM mysql.user WHERE User='';"
    mysql -u root -p$MYSQL_ROOT_PASSWORD -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
    mysql -u root -p$MYSQL_ROOT_PASSWORD -e "DROP DATABASE IF EXISTS test;"
    mysql -u root -p$MYSQL_ROOT_PASSWORD -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
    mysql -u root -p$MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"
    
    # Enable and start MySQL
    systemctl enable mysql
    systemctl start mysql
    
    log "MySQL installed and configured successfully"
    log "MySQL root password: $MYSQL_ROOT_PASSWORD"
}

# Install PHP and required modules
install_php() {
    log "Installing PHP and required modules..."
    
    apt-get install php-fpm php-mysql php-curl php-gd php-mbstring php-xml php-zip -y
    
    # Enable and start PHP-FPM
    systemctl enable php7.4-fpm  # Adjust version as needed
    systemctl start php7.4-fpm
    
    log "PHP installed successfully"
}

# Configure Nginx for PHP
configure_nginx() {
    log "Configuring Nginx for www.foobar.com..."
    
    # Create site configuration
    cat > /etc/nginx/sites-available/foobar.com << 'EOF'
server {
    listen 80;
    server_name www.foobar.com foobar.com;
    root /var/www/foobar.com;
    index index.php index.html index.htm;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;

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
    }

    # Deny access to .htaccess files
    location ~ /\.ht {
        deny all;
    }

    # Static files caching
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
}
EOF

    # Enable the site
    ln -sf /etc/nginx/sites-available/foobar.com /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    
    # Test nginx configuration
    nginx -t
    
    if [ $? -eq 0 ]; then
        systemctl reload nginx
        log "Nginx configured successfully"
    else
        error "Nginx configuration test failed"
        exit 1
    fi
}

# Create application directory and files
setup_application() {
    log "Setting up application files..."
    
    # Create web directory
    mkdir -p /var/www/foobar.com
    
    # Create sample index.php
    cat > /var/www/foobar.com/index.php << 'EOF'
<?php
/**
 * Simple Web Application
 * Demonstrates LAMP stack functionality
 */

// Database configuration
$host = 'localhost';
$username = 'webuser';
$password = 'webpass123';
$database = 'foobar_db';

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to Foobar.com</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f4f4f4;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        .header {
            background: #333;
            color: white;
            padding: 20px;
            text-align: center;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .info-box {
            background: #e8f4f8;
            padding: 15px;
            border-left: 4px solid #007cba;
            margin: 10px 0;
        }
        .status {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 3px;
            color: white;
            font-weight: bold;
        }
        .success { background: #28a745; }
        .error { background: #dc3545; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Welcome to www.foobar.com</h1>
            <p>Simple Web Stack Infrastructure</p>
        </div>
        
        <div class="info-box">
            <h3>Infrastructure Components Status</h3>
            
            <p><strong>Web Server (Nginx):</strong> 
                <span class="status success">Running</span>
            </p>
            
            <p><strong>Application Server (PHP):</strong> 
                <span class="status success">PHP <?php echo phpversion(); ?></span>
            </p>
            
            <p><strong>Database (MySQL):</strong>
                <?php
                try {
                    $pdo = new PDO("mysql:host=$host", $username, $password);
                    echo '<span class="status success">Connected</span>';
                } catch(PDOException $e) {
                    echo '<span class="status error">Connection Failed</span>';
                }
                ?>
            </p>
            
            <p><strong>Server IP:</strong> <?php echo $_SERVER['SERVER_ADDR'] ?? 'N/A'; ?></p>
            <p><strong>Server Time:</strong> <?php echo date('Y-m-d H:i:s'); ?></p>
        </div>
        
        <div class="info-box">
            <h3>Request Information</h3>
            <p><strong>Client IP:</strong> <?php echo $_SERVER['REMOTE_ADDR'] ?? 'N/A'; ?></p>
            <p><strong>User Agent:</strong> <?php echo $_SERVER['HTTP_USER_AGENT'] ?? 'N/A'; ?></p>
            <p><strong>Request Method:</strong> <?php echo $_SERVER['REQUEST_METHOD'] ?? 'N/A'; ?></p>
            <p><strong>Request URI:</strong> <?php echo $_SERVER['REQUEST_URI'] ?? 'N/A'; ?></p>
        </div>
        
        <div class="info-box">
            <h3>Infrastructure Design</h3>
            <p>This website is hosted on a simple web stack consisting of:</p>
            <ul>
                <li><strong>Single Server:</strong> All components on one machine</li>
                <li><strong>Nginx:</strong> Web server handling HTTP requests</li>
                <li><strong>PHP-FPM:</strong> Application server processing dynamic content</li>
                <li><strong>MySQL:</strong> Database storing application data</li>
                <li><strong>Linux:</strong> Operating system (Ubuntu/CentOS)</li>
            </ul>
        </div>
        
        <div class="info-box">
            <h3>Known Limitations</h3>
            <ul>
                <li><strong>SPOF:</strong> Single point of failure - server failure affects entire site</li>
                <li><strong>Downtime:</strong> Maintenance requires service interruption</li>
                <li><strong>Scalability:</strong> Limited ability to handle high traffic</li>
                <li><strong>No Redundancy:</strong> No backup systems in place</li>
            </ul>
        </div>
    </div>
</body>
</html>
EOF

    # Set proper permissions
    chown -R www-data:www-data /var/www/foobar.com
    chmod -R 755 /var/www/foobar.com
    
    log "Application files created successfully"
}

# Setup database and user
setup_database() {
    log "Setting up application database..."
    
    MYSQL_ROOT_PASSWORD="secure_password_123"
    DB_NAME="foobar_db"
    DB_USER="webuser"
    DB_PASS="webpass123"
    
    # Create database and user
    mysql -u root -p$MYSQL_ROOT_PASSWORD << EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;

USE $DB_NAME;

-- Create sample table
CREATE TABLE IF NOT EXISTS visitors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ip_address VARCHAR(45),
    user_agent TEXT,
    visit_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO visitors (ip_address, user_agent) 
VALUES ('127.0.0.1', 'Sample User Agent');

EOF

    log "Database setup completed"
    log "Database: $DB_NAME"
    log "Username: $DB_USER"
    log "Password: $DB_PASS"
}

# Configure firewall
setup_firewall() {
    log "Configuring firewall..."
    
    # Install UFW if not present
    apt-get install ufw -y
    
    # Reset firewall rules
    ufw --force reset
    
    # Set default policies
    ufw default deny incoming
    ufw default allow outgoing
    
    # Allow SSH (important!)
    ufw allow ssh
    
    # Allow HTTP and HTTPS
    ufw allow 80/tcp
    ufw allow 443/tcp
    
    # Enable firewall
    ufw --force enable
    
    log "Firewall configured successfully"
}

# Create monitoring script
create_monitoring() {
    log "Creating monitoring script..."
    
    cat > /usr/local/bin/stack_monitor.sh << 'EOF'
#!/bin/bash
# Simple stack monitoring script

echo "=== Simple Web Stack Status ==="
echo "Date: $(date)"
echo

# Check Nginx
if systemctl is-active --quiet nginx; then
    echo "✓ Nginx: Running"
else
    echo "✗ Nginx: Not running"
fi

# Check PHP-FPM
if systemctl is-active --quiet php7.4-fpm; then
    echo "✓ PHP-FPM: Running"
else
    echo "✗ PHP-FPM: Not running"
fi

# Check MySQL
if systemctl is-active --quiet mysql; then
    echo "✓ MySQL: Running"
else
    echo "✗ MySQL: Not running"
fi

# Check disk space
echo
echo "=== Disk Usage ==="
df -h / | tail -1

# Check memory usage
echo
echo "=== Memory Usage ==="
free -h

# Check load average
echo
echo "=== Load Average ==="
uptime

# Check active connections
echo
echo "=== Active HTTP Connections ==="
netstat -an | grep :80 | wc -l
EOF

    chmod +x /usr/local/bin/stack_monitor.sh
    log "Monitoring script created at /usr/local/bin/stack_monitor.sh"
}

# Main installation function
main() {
    log "Starting Simple Web Stack installation..."
    
    check_root
    update_system
    install_nginx
    install_mysql
    install_php
    configure_nginx
    setup_application
    setup_database
    setup_firewall
    create_monitoring
    
    echo
    echo "=========================================="
    log "Installation completed successfully!"
    echo "=========================================="
    echo
    echo "Your simple web stack is now ready!"
    echo "- Website: http://www.foobar.com (make sure DNS points to this server)"
    echo "- Server IP: $(curl -s ifconfig.me || echo 'Check manually')"
    echo "- MySQL root password: secure_password_123"
    echo "- Database user: webuser / webpass123"
    echo
    echo "Important Notes:"
    echo "1. Configure your DNS to point www.foobar.com to this server's IP"
    echo "2. Consider setting up SSL certificates for HTTPS"
    echo "3. Change default passwords in production"
    echo "4. Regular backups are recommended"
    echo "5. Monitor your server with: /usr/local/bin/stack_monitor.sh"
    echo
    warn "Remember: This is a single server setup with inherent limitations (SPOF, scalability)"
}

# Run main function
main "$@"
