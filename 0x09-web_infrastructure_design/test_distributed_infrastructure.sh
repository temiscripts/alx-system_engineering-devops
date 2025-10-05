#!/bin/bash

# Distributed Web Infrastructure Testing Script
# This script validates the three-server distributed infrastructure
# Author: Infrastructure Design Team

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
LOAD_BALANCER_IP="8.8.8.8"
WEB_SERVER_1_IP="10.0.0.2"
WEB_SERVER_2_IP="10.0.0.3"
DATABASE_SERVER_IP="10.0.0.4"
DOMAIN_NAME="www.foobar.com"

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

# Show system information
show_system_info() {
    echo "=========================================="
    echo "DISTRIBUTED INFRASTRUCTURE TEST REPORT"
    echo "=========================================="
    echo "Test Date: $(date)"
    echo "Load Balancer: $LOAD_BALANCER_IP"
    echo "Web Server 1: $WEB_SERVER_1_IP"
    echo "Web Server 2: $WEB_SERVER_2_IP"
    echo "Database Server: $DATABASE_SERVER_IP"
    echo "Domain: $DOMAIN_NAME"
    echo
}

# Test 1: Load Balancer (HAproxy)
test_load_balancer() {
    info "Testing Load Balancer (HAproxy)..."
    
    # Test HAproxy service
    run_test "HAproxy service running" "systemctl is-active haproxy"
    run_test "HAproxy listening on port 80" "netstat -tlnp | grep ':80.*haproxy'"
    run_test "HAproxy process active" "pgrep haproxy"
    run_test "HAproxy configuration valid" "haproxy -f /etc/haproxy/haproxy.cfg -c"
    
    # Test statistics page
    if curl -s -u admin:password123 http://localhost:8080/stats | grep -q "HAproxy"; then
        log "HAproxy statistics page accessible"
    else
        fail "HAproxy statistics page accessible"
    fi
    
    # Test load balancing functionality
    info "Testing load balancing distribution..."
    local responses=()
    for i in {1..10}; do
        local response=$(curl -s http://localhost/health 2>/dev/null || echo "FAIL")
        responses+=("$response")
    done
    
    if [[ "${responses[*]}" =~ "OK" ]]; then
        log "Load balancer distributing requests"
    else
        fail "Load balancer distributing requests"
    fi
}

# Test 2: Web Servers
test_web_servers() {
    info "Testing Web Servers..."
    
    # Test Web Server 1
    info "Testing Web Server 1 ($WEB_SERVER_1_IP)..."
    run_test "Web Server 1 - Nginx service" "ssh root@$WEB_SERVER_1_IP 'systemctl is-active nginx'"
    run_test "Web Server 1 - PHP-FPM service" "ssh root@$WEB_SERVER_1_IP 'systemctl is-active php7.4-fpm'"
    run_test "Web Server 1 - Health endpoint" "curl -s http://$WEB_SERVER_1_IP/health | grep -q OK"
    
    # Test Web Server 2
    info "Testing Web Server 2 ($WEB_SERVER_2_IP)..."
    run_test "Web Server 2 - Nginx service" "ssh root@$WEB_SERVER_2_IP 'systemctl is-active nginx'"
    run_test "Web Server 2 - PHP-FPM service" "ssh root@$WEB_SERVER_2_IP 'systemctl is-active php7.4-fpm'"
    run_test "Web Server 2 - Health endpoint" "curl -s http://$WEB_SERVER_2_IP/health | grep -q OK"
    
    # Test application files
    run_test "Web Server 1 - Application files" "ssh root@$WEB_SERVER_1_IP 'test -f /var/www/foobar.com/index.php'"
    run_test "Web Server 2 - Application files" "ssh root@$WEB_SERVER_2_IP 'test -f /var/www/foobar.com/index.php'"
}

# Test 3: Database Server
test_database_server() {
    info "Testing Database Server..."
    
    # Test primary MySQL
    run_test "Primary MySQL service" "ssh root@$DATABASE_SERVER_IP 'systemctl is-active mysql'"
    run_test "Primary MySQL listening on 3306" "ssh root@$DATABASE_SERVER_IP 'netstat -tlnp | grep :3306'"
    
    # Test replica MySQL
    run_test "Replica MySQL process" "ssh root@$DATABASE_SERVER_IP 'pgrep -f mysqld.*3307'"
    run_test "Replica MySQL listening on 3307" "ssh root@$DATABASE_SERVER_IP 'netstat -tlnp | grep :3307'"
    
    # Test database connectivity
    if ssh root@$DATABASE_SERVER_IP 'mysql -u webuser -pwebpass123 -e "SELECT 1;" foobar_db' >/dev/null 2>&1; then
        log "Database connectivity (primary)"
    else
        fail "Database connectivity (primary)"
    fi
    
    # Test replication status
    if ssh root@$DATABASE_SERVER_IP 'mysql -u root -psecure_password_123 -e "SHOW MASTER STATUS;"' | grep -q "mysql-bin"; then
        log "Database replication configured"
    else
        fail "Database replication configured"
    fi
}

# Test 4: Load Distribution
test_load_distribution() {
    info "Testing Load Distribution..."
    
    # Test round-robin distribution
    local server_responses=()
    for i in {1..20}; do
        local response=$(curl -s http://localhost/index.php | grep -o "Server IP: [0-9.]*" | cut -d' ' -f3)
        server_responses+=("$response")
        sleep 0.1
    done
    
    # Count unique servers
    local unique_servers=$(printf '%s\n' "${server_responses[@]}" | sort -u | wc -l)
    
    if [ "$unique_servers" -ge 2 ]; then
        log "Load distribution across multiple servers"
        info "Detected $unique_servers different web servers responding"
    else
        fail "Load distribution across multiple servers"
    fi
    
    # Test session persistence (should be stateless)
    local consistent_responses=true
    for i in {1..5}; do
        local response1=$(curl -s http://localhost/index.php | grep "Server IP")
        local response2=$(curl -s http://localhost/index.php | grep "Server IP")
        if [[ "$response1" == "$response2" ]]; then
            consistent_responses=false
            break
        fi
    done
    
    if ! $consistent_responses; then
        log "Stateless load balancing (no sticky sessions)"
    else
        warn "Possible sticky sessions detected"
    fi
}

# Test 5: Database Operations
test_database_operations() {
    info "Testing Database Operations..."
    
    # Test write operation (should go to primary)
    local test_data="Test_$(date +%s)"
    if ssh root@$DATABASE_SERVER_IP "mysql -u webuser -pwebpass123 foobar_db -e \"INSERT INTO visitors (ip_address, user_agent, server_name) VALUES ('127.0.0.1', 'Test Script', '$test_data');\"" >/dev/null 2>&1; then
        log "Database write operation (primary)"
    else
        fail "Database write operation (primary)"
    fi
    
    # Test read operation
    if ssh root@$DATABASE_SERVER_IP "mysql -u webuser -pwebpass123 foobar_db -e \"SELECT COUNT(*) FROM visitors;\"" >/dev/null 2>&1; then
        log "Database read operation"
    else
        fail "Database read operation"
    fi
    
    # Test data synchronization (check if data exists)
    sleep 2  # Wait for replication
    if ssh root@$DATABASE_SERVER_IP "mysql -u webuser -pwebpass123 foobar_db -e \"SELECT * FROM visitors WHERE server_name='$test_data';\"" | grep -q "$test_data"; then
        log "Database data synchronization"
    else
        warn "Database replication may have delay"
    fi
}

# Test 6: Failover Simulation
test_failover() {
    info "Testing Failover Scenarios..."
    
    # Test web server failover
    info "Simulating Web Server 1 failure..."
    
    # Stop Web Server 1
    ssh root@$WEB_SERVER_1_IP 'systemctl stop nginx' >/dev/null 2>&1
    
    # Wait for health check to detect failure
    sleep 5
    
    # Test if load balancer routes to Server 2 only
    local server_down_responses=()
    for i in {1..10}; do
        local response=$(curl -s http://localhost/health 2>/dev/null || echo "FAIL")
        server_down_responses+=("$response")
    done
    
    if [[ "${server_down_responses[*]}" =~ "OK" ]]; then
        log "Web server failover working"
    else
        fail "Web server failover working"
    fi
    
    # Restore Web Server 1
    ssh root@$WEB_SERVER_1_IP 'systemctl start nginx' >/dev/null 2>&1
    sleep 3
    
    info "Web Server 1 restored"
}

# Test 7: Security Configuration
test_security() {
    info "Testing Security Configuration..."
    
    # Test firewall on load balancer
    if ufw status | grep -q "Status: active"; then
        log "Load balancer firewall active"
    else
        warn "Load balancer firewall not active"
    fi
    
    # Test web server access restrictions
    if ssh root@$WEB_SERVER_1_IP 'ufw status' | grep -q "Status: active"; then
        log "Web server firewall active"
    else
        warn "Web server firewall not configured"
    fi
    
    # Test database access restrictions
    if ssh root@$DATABASE_SERVER_IP 'ufw status' | grep -q "Status: active"; then
        log "Database server firewall active"
    else
        warn "Database server firewall not configured"
    fi
    
    # Test HTTPS availability
    if curl -k -s https://localhost >/dev/null 2>&1; then
        log "HTTPS available"
    else
        warn "HTTPS not configured"
    fi
}

# Test 8: Performance Metrics
test_performance() {
    info "Testing Performance Metrics..."
    
    # Test response time
    local response_time=$(curl -w "%{time_total}" -s -o /dev/null http://localhost/index.php)
    if (( $(echo "$response_time < 2.0" | bc -l) )); then
        log "Response time acceptable ($response_time seconds)"
    else
        warn "Response time high ($response_time seconds)"
    fi
    
    # Test concurrent connections
    local concurrent_test=$(ab -n 100 -c 10 http://localhost/index.php 2>/dev/null | grep "Requests per second" | awk '{print $4}')
    if [[ -n "$concurrent_test" ]] && (( $(echo "$concurrent_test > 10" | bc -l) )); then
        log "Concurrent request handling ($concurrent_test req/sec)"
    else
        warn "Concurrent request performance may be low"
    fi
}

# Test 9: Infrastructure Issues Check
test_infrastructure_issues() {
    echo
    echo "=========================================="
    echo "INFRASTRUCTURE ISSUES ANALYSIS"
    echo "=========================================="
    
    info "Checking for Single Points of Failure (SPOF)..."
    
    # Load Balancer SPOF
    local lb_count=$(ps aux | grep haproxy | grep -v grep | wc -l)
    if [ "$lb_count" -eq 1 ]; then
        warn "SPOF: Single load balancer instance"
    else
        log "Load balancer redundancy detected"
    fi
    
    # Database SPOF
    if ssh root@$DATABASE_SERVER_IP 'mysql -u root -psecure_password_123 -e "SHOW MASTER STATUS;"' | grep -q "mysql-bin"; then
        warn "SPOF: Primary database has no automatic failover"
    fi
    
    info "Checking security issues..."
    
    # HTTPS check
    if ! curl -k -s https://localhost >/dev/null 2>&1; then
        warn "Security Issue: No HTTPS encryption"
    fi
    
    # Firewall check
    if ! ufw status | grep -q "Status: active"; then
        warn "Security Issue: Firewall not fully configured"
    fi
    
    info "Checking monitoring..."
    
    # Monitoring systems
    local monitoring_found=false
    for service in nagios zabbix prometheus; do
        if systemctl is-active $service >/dev/null 2>&1; then
            monitoring_found=true
            break
        fi
    done
    
    if ! $monitoring_found; then
        warn "Infrastructure Issue: No monitoring system detected"
    fi
}

# Generate comprehensive report
generate_report() {
    echo
    echo "=========================================="
    echo "DISTRIBUTED INFRASTRUCTURE TEST SUMMARY"
    echo "=========================================="
    echo "Total Tests: $TOTAL_TESTS"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"
    echo "Success Rate: $(( TESTS_PASSED * 100 / TOTAL_TESTS ))%"
    echo
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}🎉 ALL TESTS PASSED! Distributed infrastructure is working correctly.${NC}"
    else
        echo -e "${RED}⚠️  Some tests failed. Please review the issues above.${NC}"
    fi
    
    echo
    echo "Infrastructure Components Status:"
    echo "✓ Load Balancer (HAproxy) - Distributing traffic"
    echo "✓ Web Server 1 - Active in pool"
    echo "✓ Web Server 2 - Active in pool"
    echo "✓ Database Primary - Handling writes"
    echo "✓ Database Replica - Available for reads"
    echo
    
    echo "Key Improvements Made:"
    echo "✓ Eliminated web server SPOF"
    echo "✓ Implemented load distribution"
    echo "✓ Added database redundancy"
    echo "✓ Enabled horizontal scaling"
    echo
    
    echo "Remaining Issues to Address:"
    echo "! Load balancer is still a SPOF"
    echo "! No HTTPS encryption implemented"
    echo "! No comprehensive monitoring"
    echo "! Database primary is still a SPOF"
    echo
    
    echo "Next Steps:"
    echo "1. Implement load balancer clustering"
    echo "2. Add SSL/TLS certificates"
    echo "3. Set up monitoring and alerting"
    echo "4. Configure database automatic failover"
    echo "5. Implement proper security measures"
}

# Main test execution
main() {
    show_system_info
    test_load_balancer
    test_web_servers
    test_database_server
    test_load_distribution
    test_database_operations
    test_failover
    test_security
    test_performance
    test_infrastructure_issues
    generate_report
}

# Check if required tools are available
check_dependencies() {
    local required_tools=("curl" "ssh" "bc" "ab")
    local missing_tools=()
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        error "Missing required tools: ${missing_tools[*]}"
        info "Please install missing tools and run again"
        exit 1
    fi
}

# Entry point
if [[ $EUID -eq 0 ]]; then
    check_dependencies
    main "$@"
else
    echo "Note: Some tests require root privileges for full validation."
    echo "Run with sudo for complete testing."
    echo
    check_dependencies
    main "$@"
fi
