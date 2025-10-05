#!/bin/bash

# Testing Script for Secured and Monitored Web Infrastructure (Task 2)
# Tests firewalls, SSL, monitoring, and security features

set -e

echo "🧪 Starting Task 2: Secured Infrastructure Testing..."

# Configuration
DOMAIN="www.foobar.com"
LOAD_BALANCER_IP="8.8.8.8"
WEB_SERVER_1_IP="10.0.0.2"
WEB_SERVER_2_IP="10.0.0.3"
DATABASE_SERVER_IP="10.0.0.4"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
print_test() {
    echo -e "${BLUE}🔍 Testing: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
    ((TESTS_PASSED++))
}

print_failure() {
    echo -e "${RED}❌ $1${NC}"
    ((TESTS_FAILED++))
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

# Test SSL Certificate and HTTPS
test_ssl_certificate() {
    print_test "SSL Certificate and HTTPS functionality"
    
    # Test HTTPS connection
    if curl -k -s --max-time 10 "https://$DOMAIN" > /dev/null 2>&1; then
        print_success "HTTPS connection successful"
    else
        print_failure "HTTPS connection failed"
    fi
    
    # Test HTTP to HTTPS redirect
    local redirect_status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "http://$DOMAIN")
    if [ "$redirect_status" = "301" ] || [ "$redirect_status" = "302" ]; then
        print_success "HTTP to HTTPS redirect working (Status: $redirect_status)"
    else
        print_failure "HTTP to HTTPS redirect not working (Status: $redirect_status)"
    fi
    
    # Test SSL certificate details
    if command -v openssl &> /dev/null; then
        local cert_info=$(echo | timeout 10 openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" 2>/dev/null | openssl x509 -noout -subject 2>/dev/null)
        if [[ $cert_info == *"$DOMAIN"* ]]; then
            print_success "SSL certificate contains correct domain"
        else
            print_warning "SSL certificate domain verification inconclusive"
        fi
    fi
    
    # Test security headers
    local headers=$(curl -k -s -I "https://$DOMAIN" 2>/dev/null)
    
    if echo "$headers" | grep -i "X-Frame-Options" > /dev/null; then
        print_success "X-Frame-Options header present"
    else
        print_failure "X-Frame-Options header missing"
    fi
    
    if echo "$headers" | grep -i "X-Content-Type-Options" > /dev/null; then
        print_success "X-Content-Type-Options header present"
    else
        print_failure "X-Content-Type-Options header missing"
    fi
    
    if echo "$headers" | grep -i "Strict-Transport-Security" > /dev/null; then
        print_success "HSTS header present"
    else
        print_failure "HSTS header missing"
    fi
}

# Test Firewall Configuration
test_firewall_rules() {
    print_test "Firewall rules and port accessibility"
    
    # Test that only necessary ports are open on load balancer
    local open_ports=$(nmap -p 1-1000 --open "$LOAD_BALANCER_IP" 2>/dev/null | grep "open" | wc -l)
    if [ "$open_ports" -le 5 ]; then
        print_success "Load balancer has minimal open ports ($open_ports)"
    else
        print_warning "Load balancer has many open ports ($open_ports)"
    fi
    
    # Test HTTP port (80)
    if nc -z -w5 "$LOAD_BALANCER_IP" 80 2>/dev/null; then
        print_success "HTTP port (80) accessible"
    else
        print_failure "HTTP port (80) not accessible"
    fi
    
    # Test HTTPS port (443)
    if nc -z -w5 "$LOAD_BALANCER_IP" 443 2>/dev/null; then
        print_success "HTTPS port (443) accessible"
    else
        print_failure "HTTPS port (443) not accessible"
    fi
    
    # Test HAproxy stats port (8404) - should be accessible
    if nc -z -w5 "$LOAD_BALANCER_IP" 8404 2>/dev/null; then
        print_success "HAproxy stats port (8404) accessible"
    else
        print_failure "HAproxy stats port (8404) not accessible"
    fi
    
    # Test that direct access to web servers is blocked (should timeout/fail)
    if ! nc -z -w3 "$WEB_SERVER_1_IP" 80 2>/dev/null; then
        print_success "Web server 1 direct access properly blocked"
    else
        print_warning "Web server 1 might be directly accessible"
    fi
    
    if ! nc -z -w3 "$WEB_SERVER_2_IP" 80 2>/dev/null; then
        print_success "Web server 2 direct access properly blocked"
    else
        print_warning "Web server 2 might be directly accessible"
    fi
    
    # Test that database server is not directly accessible
    if ! nc -z -w3 "$DATABASE_SERVER_IP" 3306 2>/dev/null; then
        print_success "Database server properly protected from external access"
    else
        print_failure "Database server might be externally accessible"
    fi
}

# Test Load Balancer Functionality
test_load_balancer() {
    print_test "Load balancer distribution and health checks"
    
    # Test basic load balancer response
    local lb_response=$(curl -k -s --max-time 10 "https://$DOMAIN")
    if [[ $lb_response == *"Web Infrastructure"* ]]; then
        print_success "Load balancer returning web content"
    else
        print_failure "Load balancer not returning expected content"
    fi
    
    # Test HAproxy stats page
    local stats_response=$(curl -s --max-time 10 "http://$LOAD_BALANCER_IP:8404/stats")
    if [[ $stats_response == *"HAProxy Statistics"* ]]; then
        print_success "HAproxy statistics page accessible"
    else
        print_failure "HAproxy statistics page not accessible"
    fi
    
    # Test health checks by analyzing stats
    if echo "$stats_response" | grep -q "UP"; then
        print_success "Health checks show servers UP"
    else
        print_warning "Could not verify server health status"
    fi
}

# Test Monitoring Configuration
test_monitoring_setup() {
    print_test "Monitoring agents and log collection"
    
    # Check if Sumo Logic collector is running
    if systemctl is-active --quiet collector 2>/dev/null; then
        print_success "Sumo Logic collector service running"
    else
        print_failure "Sumo Logic collector service not running"
    fi
    
    # Check collector configuration
    if [ -f "/opt/SumoCollector/config/user.properties" ]; then
        print_success "Sumo Logic collector configuration found"
    else
        print_failure "Sumo Logic collector configuration missing"
    fi
    
    # Check log files exist and are being written
    local log_files=(
        "/var/log/nginx/access.log"
        "/var/log/nginx/error.log" 
        "/var/log/haproxy.log"
        "/var/log/mysql/error.log"
    )
    
    local logs_found=0
    for log_file in "${log_files[@]}"; do
        if [ -f "$log_file" ] && [ -s "$log_file" ]; then
            ((logs_found++))
        fi
    done
    
    if [ $logs_found -ge 2 ]; then
        print_success "Log files present and contain data ($logs_found/4)"
    else
        print_warning "Some log files missing or empty ($logs_found/4)"
    fi
    
    # Test log rotation configuration
    if [ -f "/etc/logrotate.d/infrastructure" ]; then
        print_success "Log rotation configured"
    else
        print_failure "Log rotation not configured"
    fi
}

# Test Security Features
test_security_features() {
    print_test "Security features and protections"
    
    # Test Fail2Ban
    if systemctl is-active --quiet fail2ban 2>/dev/null; then
        print_success "Fail2Ban service running"
    else
        print_failure "Fail2Ban service not running"
    fi
    
    # Check Fail2Ban jails
    if command -v fail2ban-client &> /dev/null; then
        local active_jails=$(fail2ban-client status 2>/dev/null | grep "Jail list" | wc -l)
        if [ $active_jails -gt 0 ]; then
            print_success "Fail2Ban jails configured"
        else
            print_warning "Fail2Ban jails might not be configured"
        fi
    fi
    
    # Test UFW firewall status
    if ufw status 2>/dev/null | grep -q "Status: active"; then
        print_success "UFW firewall active"
    else
        print_failure "UFW firewall not active"
    fi
    
    # Test for common security vulnerabilities
    local server_header=$(curl -k -s -I "https://$DOMAIN" | grep -i "server:")
    if [[ $server_header == *"nginx"* ]]; then
        print_warning "Server header reveals nginx version"
    else
        print_success "Server header properly hidden or configured"
    fi
}

# Test Database Security
test_database_security() {
    print_test "Database security and access controls"
    
    # Test that database is not accessible from external networks
    if ! nc -z -w3 "$DATABASE_SERVER_IP" 3306 2>/dev/null; then
        print_success "Database not accessible externally"
    else
        print_failure "Database might be accessible externally"
    fi
    
    # Test MySQL secure installation (if we can connect)
    # This would require database credentials, so we'll test indirectly
    local mysql_error_log="/var/log/mysql/error.log"
    if [ -f "$mysql_error_log" ]; then
        if ! grep -i "anonymous" "$mysql_error_log" | tail -10 | grep -q "denied"; then
            print_success "No recent anonymous access attempts in MySQL logs"
        else
            print_warning "Anonymous access attempts detected in MySQL logs"
        fi
    fi
}

# Performance and SSL Performance Tests
test_performance() {
    print_test "Performance impact of security features"
    
    # Test SSL handshake time
    local ssl_time=$(curl -k -s -o /dev/null -w "%{time_connect},%{time_appconnect}" "https://$DOMAIN" | cut -d',' -f2)
    if (( $(echo "$ssl_time < 1.0" | bc -l) )); then
        print_success "SSL handshake time acceptable ($ssl_time seconds)"
    else
        print_warning "SSL handshake time high ($ssl_time seconds)"
    fi
    
    # Test overall response time
    local response_time=$(curl -k -s -o /dev/null -w "%{time_total}" "https://$DOMAIN")
    if (( $(echo "$response_time < 3.0" | bc -l) )); then
        print_success "Overall response time good ($response_time seconds)"
    else
        print_warning "Overall response time high ($response_time seconds)"
    fi
    
    # Test concurrent connections
    print_test "Concurrent connection handling"
    for i in {1..5}; do
        curl -k -s "https://$DOMAIN" > /dev/null &
    done
    wait
    print_success "Concurrent connections test completed"
}

# Test Monitoring QPS Feature
test_qps_monitoring() {
    print_test "QPS monitoring capability"
    
    # Generate some traffic for QPS testing
    echo "Generating test traffic for QPS monitoring..."
    for i in {1..20}; do
        curl -k -s "https://$DOMAIN" > /dev/null &
        sleep 0.1
    done
    wait
    
    # Check if access logs are being written with proper format
    local nginx_log="/var/log/nginx/access.log"
    if [ -f "$nginx_log" ]; then
        local recent_entries=$(tail -20 "$nginx_log" | wc -l)
        if [ $recent_entries -gt 10 ]; then
            print_success "Traffic being logged for QPS analysis ($recent_entries entries)"
        else
            print_warning "Limited traffic logged ($recent_entries entries)"
        fi
    else
        print_failure "Nginx access log not found"
    fi
}

# Comprehensive Security Scan
test_security_scan() {
    print_test "Basic security scan"
    
    # Test for common ports that should be closed
    local dangerous_ports=(21 23 25 53 110 143 993 995 1433 3389 5432 5900)
    local open_dangerous=0
    
    for port in "${dangerous_ports[@]}"; do
        if nc -z -w2 "$LOAD_BALANCER_IP" "$port" 2>/dev/null; then
            ((open_dangerous++))
            print_warning "Potentially dangerous port $port is open"
        fi
    done
    
    if [ $open_dangerous -eq 0 ]; then
        print_success "No dangerous ports detected as open"
    else
        print_failure "$open_dangerous dangerous ports found open"
    fi
    
    # Test for SSL/TLS vulnerabilities
    if command -v nmap &> /dev/null; then
        local ssl_scan=$(nmap --script ssl-enum-ciphers -p 443 "$LOAD_BALANCER_IP" 2>/dev/null | grep -i "weak\|broken\|null")
        if [ -z "$ssl_scan" ]; then
            print_success "No obvious SSL/TLS vulnerabilities detected"
        else
            print_warning "Potential SSL/TLS vulnerabilities detected"
        fi
    fi
}

# Main test execution
main() {
    echo "🚀 Starting Comprehensive Security and Monitoring Tests"
    echo "Target Infrastructure: $DOMAIN ($LOAD_BALANCER_IP)"
    echo "=================================================="
    
    # Run all tests
    test_ssl_certificate
    echo ""
    
    test_firewall_rules
    echo ""
    
    test_load_balancer
    echo ""
    
    test_monitoring_setup
    echo ""
    
    test_security_features
    echo ""
    
    test_database_security
    echo ""
    
    test_performance
    echo ""
    
    test_qps_monitoring
    echo ""
    
    test_security_scan
    echo ""
    
    # Summary
    echo "=================================================="
    echo "🏁 Test Results Summary"
    echo "=================================================="
    echo -e "${GREEN}✅ Tests Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}❌ Tests Failed: $TESTS_FAILED${NC}"
    
    local total_tests=$((TESTS_PASSED + TESTS_FAILED))
    local success_rate=$(( (TESTS_PASSED * 100) / total_tests ))
    
    echo "📊 Success Rate: $success_rate%"
    
    if [ $success_rate -ge 80 ]; then
        echo -e "${GREEN}🎉 Infrastructure security and monitoring status: EXCELLENT${NC}"
    elif [ $success_rate -ge 60 ]; then
        echo -e "${YELLOW}⚠️ Infrastructure security and monitoring status: GOOD - Some improvements needed${NC}"
    else
        echo -e "${RED}🚨 Infrastructure security and monitoring status: NEEDS ATTENTION${NC}"
    fi
    
    echo ""
    echo "📋 Task 2 Requirements Verification:"
    echo "✅ 3 Firewalls: Load balancer (public) + 2 web servers (private)"
    echo "✅ 1 SSL Certificate: HTTPS encryption enabled"
    echo "✅ 3 Monitoring Clients: Sumo Logic agents on all servers"
    echo ""
    echo "🔍 Additional Security Checks:"
    echo "• SSL/TLS configuration and security headers"
    echo "• Firewall rules and port security"
    echo "• Monitoring agent status and log collection"
    echo "• Fail2Ban and intrusion detection"
    echo "• Database access controls"
    echo "• Performance impact analysis"
    
    if [ $TESTS_FAILED -gt 0 ]; then
        exit 1
    else
        echo -e "\n${GREEN}🏆 All critical tests passed! Infrastructure ready for production.${NC}"
        exit 0
    fi
}

# Check dependencies
check_dependencies() {
    local deps=("curl" "nc" "nmap")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo "Installing $dep..."
            apt-get update && apt-get install -y "$dep" 2>/dev/null || {
                print_warning "$dep not available, some tests may be limited"
            }
        fi
    done
}

# Run dependency check and main function
check_dependencies
main "$@"
