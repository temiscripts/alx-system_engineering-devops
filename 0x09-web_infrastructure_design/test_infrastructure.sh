#!/bin/bash

# Simple Web Stack Testing Script
# This script validates the infrastructure setup and functionality
# Author: Infrastructure Design Team

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results counters
TESTS_PASSED=0
TESTS_FAILED=0
TOTAL_TESTS=0

# Logging functions
log() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
    ((TOTAL_TESTS++))
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
    ((TOTAL_TESTS++))
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Test function wrapper
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    info "Testing: $test_name"
    
    if eval "$test_command" >/dev/null 2>&1; then
        log "$test_name"
    else
        fail "$test_name"
    fi
}

# System information
show_system_info() {
    echo "=========================================="
    echo "SYSTEM INFORMATION"
    echo "=========================================="
    echo "OS: $(lsb_release -d | cut -f2)"
    echo "Kernel: $(uname -r)"
    echo "Hostname: $(hostname)"
    echo "IP Address: $(hostname -I | awk '{print $1}')"
    echo "Date: $(date)"
    echo
}

# Test 1: Check if server is running
test_server_running() {
    info "Testing server availability..."
    
    # Test if system is responsive
    run_test "System uptime check" "uptime"
    run_test "Network connectivity" "ping -c 1 8.8.8.8"
    run_test "DNS resolution" "nslookup google.com"
}

# Test 2: Check web server (Nginx)
test_web_server() {
    info "Testing web server (Nginx)..."
    
    run_test "Nginx service status" "systemctl is-active nginx"
    run_test "Nginx configuration syntax" "nginx -t"
    run_test "Nginx listening on port 80" "netstat -tlnp | grep ':80'"
    run_test "Nginx process running" "pgrep nginx"
    
    # Test HTTP response
    if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200"; then
        log "HTTP response on port 80"
    else
        fail "HTTP response on port 80"
    fi
}

# Test 3: Check application server (PHP)
test_application_server() {
    info "Testing application server (PHP)..."
    
    run_test "PHP-FPM service status" "systemctl is-active php7.4-fpm"
    run_test "PHP-FPM socket exists" "test -S /var/run/php/php7.4-fpm.sock"
    run_test "PHP-FPM process running" "pgrep php-fpm"
    
    # Test PHP version
    if php -v >/dev/null 2>&1; then
        log "PHP executable available"
        info "PHP Version: $(php -v | head -n1)"
    else
        fail "PHP executable available"
    fi
    
    # Test PHP modules
    local required_modules=("mysqli" "pdo" "curl" "gd" "mbstring")
    for module in "${required_modules[@]}"; do
        if php -m | grep -q "$module"; then
            log "PHP module: $module"
        else
            fail "PHP module: $module"
        fi
    done
}

# Test 4: Check database (MySQL)
test_database() {
    info "Testing database (MySQL)..."
    
    run_test "MySQL service status" "systemctl is-active mysql"
    run_test "MySQL listening on port 3306" "netstat -tlnp | grep ':3306'"
    run_test "MySQL process running" "pgrep mysql"
    
    # Test MySQL connection (if credentials are available)
    if mysql -u root -psecure_password_123 -e "SELECT 1;" >/dev/null 2>&1; then
        log "MySQL root connection"
        
        # Test application database
        if mysql -u webuser -pwebpass123 -e "USE foobar_db; SELECT 1;" >/dev/null 2>&1; then
            log "Application database connection"
        else
            fail "Application database connection"
        fi
    else
        warn "MySQL root connection (credentials may differ)"
    fi
}

# Test 5: Check application files
test_application_files() {
    info "Testing application files..."
    
    run_test "Web directory exists" "test -d /var/www/foobar.com"
    run_test "Index.php exists" "test -f /var/www/foobar.com/index.php"
    run_test "Web directory permissions" "test -r /var/www/foobar.com/index.php"
    run_test "Web directory ownership" "stat -c %U /var/www/foobar.com | grep -q www-data"
    
    # Test PHP syntax
    if php -l /var/www/foobar.com/index.php >/dev/null 2>&1; then
        log "PHP syntax check for index.php"
    else
        fail "PHP syntax check for index.php"
    fi
}

# Test 6: Check domain name configuration
test_domain_configuration() {
    info "Testing domain name configuration..."
    
    # Check Nginx site configuration
    run_test "Nginx site config exists" "test -f /etc/nginx/sites-available/foobar.com"
    run_test "Nginx site enabled" "test -L /etc/nginx/sites-enabled/foobar.com"
    
    # Test local resolution (if hosts file is configured)
    if grep -q "foobar.com" /etc/hosts 2>/dev/null; then
        log "Local hosts file configured"
    else
        warn "Local hosts file not configured (DNS should point to this server)"
    fi
}

# Test 7: Check communication protocols
test_communication_protocols() {
    info "Testing communication protocols..."
    
    # Test HTTP
    if curl -s -I http://localhost | grep -q "HTTP/"; then
        log "HTTP protocol working"
    else
        fail "HTTP protocol working"
    fi
    
    # Test if HTTPS is configured (optional)
    if netstat -tlnp | grep -q ':443'; then
        log "HTTPS port listening (SSL configured)"
    else
        warn "HTTPS not configured (optional for basic setup)"
    fi
    
    # Test TCP connections
    run_test "TCP/IP stack functional" "netstat -i | grep -q lo"
}

# Test 8: Security checks
test_security() {
    info "Testing security configuration..."
    
    # Check firewall
    if command -v ufw >/dev/null 2>&1; then
        if ufw status | grep -q "Status: active"; then
            log "UFW firewall active"
        else
            warn "UFW firewall not active"
        fi
    else
        warn "UFW firewall not installed"
    fi
    
    # Check for security headers (if site is accessible)
    if curl -s -I http://localhost | grep -q "X-Frame-Options"; then
        log "Security headers configured"
    else
        warn "Security headers not found"
    fi
}

# Test 9: Performance and resource checks
test_performance() {
    info "Testing performance and resources..."
    
    # Check disk space
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$disk_usage" -lt 80 ]; then
        log "Disk space sufficient (${disk_usage}% used)"
    else
        warn "Disk space usage high (${disk_usage}% used)"
    fi
    
    # Check memory
    local mem_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
    if [ "$mem_usage" -lt 80 ]; then
        log "Memory usage acceptable (${mem_usage}% used)"
    else
        warn "Memory usage high (${mem_usage}% used)"
    fi
    
    # Check load average
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    if (( $(echo "$load_avg < 2.0" | bc -l) )); then
        log "System load acceptable ($load_avg)"
    else
        warn "System load high ($load_avg)"
    fi
}

# Test 10: Full stack integration test
test_full_stack_integration() {
    info "Testing full stack integration..."
    
    # Create a temporary PHP test file
    local test_file="/tmp/stack_test.php"
    cat > "$test_file" << 'EOF'
<?php
// Full stack test
$db_connected = false;
$web_server = isset($_SERVER['SERVER_SOFTWARE']);
$php_working = true;

// Test database connection
try {
    $pdo = new PDO("mysql:host=localhost", "webuser", "webpass123");
    $db_connected = true;
} catch(PDOException $e) {
    $db_connected = false;
}

// Return JSON result
header('Content-Type: application/json');
echo json_encode([
    'web_server' => $web_server,
    'php_working' => $php_working,
    'database_connected' => $db_connected,
    'timestamp' => date('Y-m-d H:i:s')
]);
?>
EOF

    # Copy test file to web directory
    cp "$test_file" "/var/www/foobar.com/test.php"
    chown www-data:www-data "/var/www/foobar.com/test.php"
    
    # Test the stack
    local response=$(curl -s http://localhost/test.php)
    
    if echo "$response" | grep -q '"web_server":true'; then
        log "Web server integration"
    else
        fail "Web server integration"
    fi
    
    if echo "$response" | grep -q '"php_working":true'; then
        log "PHP integration"
    else
        fail "PHP integration"
    fi
    
    if echo "$response" | grep -q '"database_connected":true'; then
        log "Database integration"
    else
        fail "Database integration"
    fi
    
    # Clean up
    rm -f "/var/www/foobar.com/test.php" "$test_file"
}

# Identify infrastructure issues
identify_issues() {
    echo
    echo "=========================================="
    echo "INFRASTRUCTURE ISSUES ANALYSIS"
    echo "=========================================="
    
    echo "🚨 Single Point of Failure (SPOF):"
    echo "   ✗ All components on single server"
    echo "   ✗ Server failure = complete outage"
    echo "   ✗ No redundancy or failover"
    echo
    
    echo "⏰ Downtime During Maintenance:"
    echo "   ✗ Code deployments require restarts"
    echo "   ✗ System updates need reboots"
    echo "   ✗ No rolling update capability"
    echo
    
    echo "📈 Scalability Limitations:"
    echo "   ✗ Cannot handle high traffic"
    echo "   ✗ Limited by single server resources"
    echo "   ✗ No horizontal scaling"
    echo "   ✗ Database becomes bottleneck"
    echo
}

# Generate test report
generate_report() {
    echo
    echo "=========================================="
    echo "TEST SUMMARY REPORT"
    echo "=========================================="
    echo "Total Tests: $TOTAL_TESTS"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"
    echo "Success Rate: $(( TESTS_PASSED * 100 / TOTAL_TESTS ))%"
    echo
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}🎉 ALL TESTS PASSED! Infrastructure is working correctly.${NC}"
    else
        echo -e "${RED}⚠️  Some tests failed. Please review the issues above.${NC}"
    fi
    
    echo
    echo "Recommendations:"
    echo "1. Monitor system resources regularly"
    echo "2. Set up automated backups"
    echo "3. Plan for infrastructure scaling"
    echo "4. Implement monitoring and alerting"
    echo "5. Consider redundancy for production use"
}

# Main test execution
main() {
    echo "=========================================="
    echo "SIMPLE WEB STACK VALIDATION TESTS"
    echo "=========================================="
    echo
    
    show_system_info
    test_server_running
    test_web_server
    test_application_server
    test_database
    test_application_files
    test_domain_configuration
    test_communication_protocols
    test_security
    test_performance
    test_full_stack_integration
    identify_issues
    generate_report
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    main "$@"
else
    echo "Note: Some tests require root privileges for full validation."
    echo "Run with sudo for complete testing."
    echo
    main "$@"
fi
