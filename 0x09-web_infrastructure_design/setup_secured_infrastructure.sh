#!/bin/bash

# Setup Script for Secured and Monitored Web Infrastructure (Task 2)
# This script sets up a three-server infrastructure with firewalls, SSL, and monitoring

set -e

echo "🔧 Starting Secured and Monitored Web Infrastructure Setup..."

# Configuration
DOMAIN="www.foobar.com"
LOAD_BALANCER_IP="8.8.8.8"
WEB_SERVER_1_IP="10.0.0.2"
WEB_SERVER_2_IP="10.0.0.3"
DATABASE_SERVER_IP="10.0.0.4"
SUMO_ACCESS_ID="${SUMO_ACCESS_ID:-your_sumo_access_id}"
SUMO_ACCESS_KEY="${SUMO_ACCESS_KEY:-your_sumo_access_key}"

# Function to detect server role
detect_server_role() {
    local current_ip=$(hostname -I | awk '{print $1}')
    
    case $current_ip in
        $LOAD_BALANCER_IP)
            echo "load_balancer"
            ;;
        $WEB_SERVER_1_IP)
            echo "web_server_1"
            ;;
        $WEB_SERVER_2_IP)
            echo "web_server_2"
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
    apt-get install -y curl wget software-properties-common ufw fail2ban
}

# Configure UFW Firewall
setup_firewall() {
    local role=$1
    echo "🔒 Setting up firewall for $role..."
    
    # Reset UFW
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
    
    case $role in
        "load_balancer")
            # Public firewall - DMZ protection
            ufw allow 22/tcp comment "SSH"
            ufw allow 80/tcp comment "HTTP"
            ufw allow 443/tcp comment "HTTPS"
            ufw allow 8404/tcp comment "HAproxy Stats"
            ;;
        "web_server_1"|"web_server_2")
            # Private network firewall
            ufw allow 22/tcp comment "SSH"
            ufw allow from $LOAD_BALANCER_IP to any port 80 comment "HTTP from LB"
            ufw allow from $LOAD_BALANCER_IP to any port 443 comment "HTTPS from LB"
            ufw allow from $DATABASE_SERVER_IP to any port 3306 comment "MySQL"
            ;;
        "database_server")
            # Database server firewall
            ufw allow 22/tcp comment "SSH"
            ufw allow from $WEB_SERVER_1_IP to any port 3306 comment "MySQL from Web1"
            ufw allow from $WEB_SERVER_2_IP to any port 3306 comment "MySQL from Web2"
            ufw allow from $WEB_SERVER_1_IP to any port 3307 comment "MySQL Replica from Web1"
            ufw allow from $WEB_SERVER_2_IP to any port 3307 comment "MySQL Replica from Web2"
            ;;
    esac
    
    ufw --force enable
    echo "✅ Firewall configured for $role"
}

# Setup SSL Certificate
setup_ssl_certificate() {
    echo "📜 Setting up SSL certificate..."
    
    # Install Certbot
    apt-get install -y certbot
    
    # Create self-signed certificate for testing
    mkdir -p /etc/haproxy/certs
    
    if [ ! -f "/etc/haproxy/certs/${DOMAIN}.pem" ]; then
        echo "🔐 Creating self-signed SSL certificate..."
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout /tmp/${DOMAIN}.key \
            -out /tmp/${DOMAIN}.crt \
            -subj "/C=US/ST=CA/L=San Francisco/O=Example Corp/CN=${DOMAIN}"
        
        # Combine cert and key for HAproxy
        cat /tmp/${DOMAIN}.crt /tmp/${DOMAIN}.key > /etc/haproxy/certs/${DOMAIN}.pem
        chmod 600 /etc/haproxy/certs/${DOMAIN}.pem
        
        echo "✅ SSL certificate created"
    fi
}

# Setup HAproxy with SSL
setup_haproxy_ssl() {
    echo "⚖️ Setting up HAproxy with SSL..."
    
    apt-get install -y haproxy
    
    # Backup original config
    cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.backup
    
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
    ssl-default-server-ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384
    ssl-default-server-options no-sslv3 no-tlsv10 no-tlsv11

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
    http-response set-header Strict-Transport-Security "max-age=31536000; includeSubDomains"
    
    # Redirect HTTP to HTTPS
    redirect scheme https if !{ ssl_fc }
    
    default_backend web_servers

backend web_servers
    balance roundrobin
    option httpchk GET /health
    http-check expect status 200
    
    server web1 10.0.0.2:80 check inter 2000 rise 2 fall 3
    server web2 10.0.0.3:80 check inter 2000 rise 2 fall 3

# Statistics interface
listen stats
    bind *:8404
    stats enable
    stats uri /stats
    stats refresh 30s
    stats admin if TRUE
EOF

    systemctl enable haproxy
    systemctl restart haproxy
    echo "✅ HAproxy with SSL configured"
}

# Install Sumo Logic Collector
install_sumo_collector() {
    echo "📊 Installing Sumo Logic monitoring agent..."
    
    # Download and install Sumo Logic collector
    wget -O /tmp/SumoCollector_19.361-15_amd64.deb \
        "https://collectors.sumologic.com/rest/download/deb/64"
    
    dpkg -i /tmp/SumoCollector_19.361-15_amd64.deb || true
    apt-get install -f -y
    
    # Configure collector
    mkdir -p /opt/SumoCollector/config
    
    cat > /opt/SumoCollector/config/user.properties << EOF
name=infrastructure-collector-$(hostname)
accessid=${SUMO_ACCESS_ID}
accesskey=${SUMO_ACCESS_KEY}
category=production/web-infrastructure
hostName=$(hostname)
timeZone=UTC
EOF

    systemctl enable collector
    systemctl start collector
    echo "✅ Sumo Logic collector installed"
}

# Configure monitoring sources
setup_monitoring_sources() {
    local role=$1
    echo "📈 Setting up monitoring sources for $role..."
    
    mkdir -p /opt/SumoCollector/config/sources
    
    case $role in
        "load_balancer")
            cat > /opt/SumoCollector/config/sources/haproxy.json << 'EOF'
{
  "api.version":"v1",
  "sources": [
    {
      "name":"HAproxy Access Logs",
      "category":"haproxy/access",
      "pathExpression":"/var/log/haproxy.log",
      "sourceType":"LocalFile"
    },
    {
      "name":"System Metrics",
      "category":"system/metrics",
      "interval":60000,
      "sourceType":"SystemStats"
    }
  ]
}
EOF
            ;;
        "web_server_1"|"web_server_2")
            cat > /opt/SumoCollector/config/sources/nginx.json << 'EOF'
{
  "api.version":"v1",
  "sources": [
    {
      "name":"Nginx Access Logs",
      "category":"nginx/access",
      "pathExpression":"/var/log/nginx/access.log",
      "sourceType":"LocalFile"
    },
    {
      "name":"Nginx Error Logs",
      "category":"nginx/error",
      "pathExpression":"/var/log/nginx/error.log",
      "sourceType":"LocalFile"
    },
    {
      "name":"PHP-FPM Logs",
      "category":"php/fpm",
      "pathExpression":"/var/log/php*.log",
      "sourceType":"LocalFile"
    }
  ]
}
EOF
            ;;
        "database_server")
            cat > /opt/SumoCollector/config/sources/mysql.json << 'EOF'
{
  "api.version":"v1",
  "sources": [
    {
      "name":"MySQL Error Logs",
      "category":"mysql/error",
      "pathExpression":"/var/log/mysql/error.log",
      "sourceType":"LocalFile"
    },
    {
      "name":"MySQL Slow Query Logs",
      "category":"mysql/slow",
      "pathExpression":"/var/log/mysql/slow.log",
      "sourceType":"LocalFile"
    }
  ]
}
EOF
            ;;
    esac
    
    systemctl restart collector
    echo "✅ Monitoring sources configured"
}

# Setup Fail2Ban for additional security
setup_fail2ban() {
    echo "🛡️ Setting up Fail2Ban..."
    
    cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5
backend = systemd

[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log

[nginx-http-auth]
enabled = true
filter = nginx-http-auth
logpath = /var/log/nginx/error.log

[nginx-req-limit]
enabled = true
filter = nginx-req-limit
logpath = /var/log/nginx/error.log
EOF

    systemctl enable fail2ban
    systemctl restart fail2ban
    echo "✅ Fail2Ban configured"
}

# Configure log rotation
setup_log_rotation() {
    echo "🔄 Setting up log rotation..."
    
    cat > /etc/logrotate.d/infrastructure << 'EOF'
/var/log/nginx/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 www-data www-data
    postrotate
        systemctl reload nginx
    endscript
}

/var/log/haproxy.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    postrotate
        systemctl reload rsyslog
    endscript
}
EOF

    echo "✅ Log rotation configured"
}

# Main execution
main() {
    echo "🚀 Starting Task 2: Secured and Monitored Web Infrastructure Setup"
    
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
    setup_firewall $SERVER_ROLE
    install_sumo_collector
    setup_monitoring_sources $SERVER_ROLE
    setup_fail2ban
    setup_log_rotation
    
    # Role-specific setup
    case $SERVER_ROLE in
        "load_balancer")
            setup_ssl_certificate
            setup_haproxy_ssl
            ;;
        "web_server_1"|"web_server_2")
            # Web server specific setup (reuse from previous tasks)
            source ./setup_distributed_infrastructure.sh
            setup_web_server
            ;;
        "database_server")
            # Database server specific setup (reuse from previous tasks)
            source ./setup_distributed_infrastructure.sh
            setup_database_server
            ;;
    esac
    
    echo "🎉 Task 2 setup completed successfully!"
    echo "🔗 HAproxy stats: https://${DOMAIN}:8404/stats"
    echo "🔒 SSL certificate: /etc/haproxy/certs/${DOMAIN}.pem"
    echo "📊 Monitoring: Check Sumo Logic dashboard"
    echo ""
    echo "🚨 Next steps:"
    echo "1. Replace self-signed certificate with production SSL certificate"
    echo "2. Configure Sumo Logic access credentials"
    echo "3. Set up monitoring dashboards and alerts"
    echo "4. Test SSL certificate and firewall rules"
}

# Run main function
main "$@"
