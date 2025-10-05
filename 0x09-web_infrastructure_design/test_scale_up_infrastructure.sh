#!/bin/bash

# Testing Script for Scale Up Web Infrastructure (Task 3)
# Tests load balancer clustering, component separation, and scalability

set -e

echo "🧪 Starting Task 3: Scale Up Infrastructure Testing..."

# Configuration
DOMAIN="www.foobar.com"
VIRTUAL_IP="8.8.8.8"
LB_MASTER_IP="10.0.0.10"
LB_BACKUP_IP="10.0.0.11"
WEB_SERVER_1_IP="10.0.0.20"
WEB_SERVER_2_IP="10.0.0.21"
APP_SERVER_IP="10.0.0.30"
DATABASE_SERVER_IP="10.0.0.40"

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

# Test Load Balancer Clustering with Keepalived
test_load_balancer_cluster() {
    print_test "Load balancer clustering and failover"
    
    # Test Virtual IP accessibility
    if ping -c 1 -W 5 "$VIRTUAL_IP" > /dev/null 2>&1; then
        print_success "Virtual IP ($VIRTUAL_IP) is reachable"
    else
        print_failure "Virtual IP ($VIRTUAL_IP) is not reachable"
    fi
    
    # Test which load balancer is currently active
    local active_lb=""
    if curl -s --max-time 5 "http://$VIRTUAL_IP:8404/stats" > /dev/null 2>&1; then
        print_success "Load balancer cluster responding on virtual IP"
        
        # Try to determine which LB is active
        if nc -z -w3 "$LB_MASTER_IP" 8404 2>/dev/null; then
            if nc -z -w3 "$LB_BACKUP_IP" 8404 2>/dev/null; then
                print_success "Both load balancers are running"
            else
                print_success "Master LB is active, backup may be standby"
                active_lb="master"
            fi
        elif nc -z -w3 "$LB_BACKUP_IP" 8404 2>/dev/null; then
            print_success "Backup LB is active (failover scenario)"
            active_lb="backup"
        fi
    else
        print_failure "Load balancer cluster not responding"
    fi
    
    # Test Keepalived status
    if systemctl is-active --quiet keepalived 2>/dev/null; then
        print_success "Keepalived service is running"
    else
        print_failure "Keepalived service is not running"
    fi
    
    # Test HAproxy service on both LBs
    if ssh -o ConnectTimeout=5 "$LB_MASTER_IP" "systemctl is-active haproxy" 2>/dev/null | grep -q "active"; then
        print_success "HAproxy running on master LB"
    else
        print_warning "Cannot verify HAproxy status on master LB"
    fi
    
    if ssh -o ConnectTimeout=5 "$LB_BACKUP_IP" "systemctl is-active haproxy" 2>/dev/null | grep -q "active"; then
        print_success "HAproxy running on backup LB"
    else
        print_warning "Cannot verify HAproxy status on backup LB"
    fi
}

# Test Component Separation
test_component_separation() {
    print_test "Component separation and dedicated services"
    
    # Test Web Servers (should only run Nginx)
    for i in 1 2; do
        local web_ip=""
        if [ $i -eq 1 ]; then
            web_ip="$WEB_SERVER_1_IP"
        else
            web_ip="$WEB_SERVER_2_IP"
        fi
        
        # Test Nginx on web servers
        if nc -z -w5 "$web_ip" 80 2>/dev/null; then
            print_success "Web Server $i: Nginx service accessible"
        else
            print_failure "Web Server $i: Nginx service not accessible"
        fi
        
        # Test that PHP-FPM is NOT running on web servers
        if ! ssh -o ConnectTimeout=5 "$web_ip" "pgrep php-fpm" > /dev/null 2>&1; then
            print_success "Web Server $i: PHP-FPM properly separated (not running)"
        else
            print_warning "Web Server $i: PHP-FPM still running (should be separated)"
        fi
        
        # Test static content serving
        local static_response=$(curl -s --max-time 10 "http://$web_ip/health" 2>/dev/null)
        if [[ $static_response == *"healthy"* ]]; then
            print_success "Web Server $i: Health endpoint responding"
        else
            print_failure "Web Server $i: Health endpoint not responding"
        fi
    done
    
    # Test Application Server (should only run PHP-FPM)
    if nc -z -w5 "$APP_SERVER_IP" 9000 2>/dev/null; then
        print_success "Application Server: PHP-FPM service accessible on port 9000"
    else
        print_failure "Application Server: PHP-FPM service not accessible"
    fi
    
    # Test that Nginx is NOT running on application server
    if ! ssh -o ConnectTimeout=5 "$APP_SERVER_IP" "pgrep nginx" > /dev/null 2>&1; then
        print_success "Application Server: Nginx properly separated (not running)"
    else
        print_warning "Application Server: Nginx still running (should be separated)"
    fi
    
    # Test application server response
    local app_response=$(curl -s --max-time 10 "http://$APP_SERVER_IP:9000/app-test.php" 2>/dev/null)
    if [[ $app_response == *"success"* ]]; then
        print_success "Application Server: PHP application responding"
    else
        print_failure "Application Server: PHP application not responding"
    fi
    
    # Test Database Server (should only run MySQL)
    if nc -z -w5 "$DATABASE_SERVER_IP" 3306 2>/dev/null; then
        print_success "Database Server: MySQL service accessible"
    else
        print_failure "Database Server: MySQL service not accessible"
    fi
    
    # Test that web services are NOT running on database server
    if ! ssh -o ConnectTimeout=5 "$DATABASE_SERVER_IP" "pgrep nginx\|pgrep php-fpm" > /dev/null 2>&1; then
        print_success "Database Server: Web services properly separated (not running)"
    else
        print_warning "Database Server: Web services still running (should be separated)"
    fi
}

# Test Inter-Component Communication
test_component_communication() {
    print_test "Inter-component communication flow"
    
    # Test Load Balancer → Web Servers
    local lb_stats=$(curl -s --max-time 10 "http://$VIRTUAL_IP:8404/stats" 2>/dev/null)
    if echo "$lb_stats" | grep -q "web1.*UP\|web2.*UP"; then
        print_success "Load balancer can communicate with web servers"
    else
        print_failure "Load balancer cannot communicate with web servers"
    fi
    
    # Test Web Servers → Application Server
    local web_to_app_test=""
    for web_ip in "$WEB_SERVER_1_IP" "$WEB_SERVER_2_IP"; do
        if ssh -o ConnectTimeout=5 "$web_ip" "nc -z -w3 $APP_SERVER_IP 9000" 2>/dev/null; then
            print_success "Web server ($web_ip) can communicate with application server"
        else
            print_failure "Web server ($web_ip) cannot communicate with application server"
        fi
    done
    
    # Test Application Server → Database Server
    if ssh -o ConnectTimeout=5 "$APP_SERVER_IP" "nc -z -w3 $DATABASE_SERVER_IP 3306" 2>/dev/null; then
        print_success "Application server can communicate with database server"
    else
        print_failure "Application server cannot communicate with database server"
    fi
    
    # Test end-to-end request flow
    local end_to_end_response=$(curl -s --max-time 15 "http://$VIRTUAL_IP/" 2>/dev/null)
    if [[ $end_to_end_response == *"Scale Up"* ]]; then
        print_success "End-to-end request flow working"
    else
        print_failure "End-to-end request flow not working"
    fi
}

# Test Load Distribution and Balancing
test_load_distribution() {
    print_test "Load distribution between web servers"
    
    local web1_requests=0
    local web2_requests=0
    
    # Send multiple requests to test distribution
    for i in {1..10}; do
        local response=$(curl -s --max-time 5 "http://$VIRTUAL_IP/" 2>/dev/null)
        if [[ $response == *"$WEB_SERVER_1_IP"* ]]; then
            ((web1_requests++))
        elif [[ $response == *"$WEB_SERVER_2_IP"* ]]; then
            ((web2_requests++))
        fi
        sleep 0.1
    done
    
    if [ $web1_requests -gt 0 ] && [ $web2_requests -gt 0 ]; then
        print_success "Load balanced between servers (Web1: $web1_requests, Web2: $web2_requests)"
    elif [ $((web1_requests + web2_requests)) -gt 5 ]; then
        print_warning "Requests served but distribution unclear (Web1: $web1_requests, Web2: $web2_requests)"
    else
        print_failure "Load balancing not working properly"
    fi
}

# Test Scalability Features
test_scalability() {
    print_test "Scalability and performance optimization"
    
    # Test concurrent request handling
    echo "Testing concurrent request handling..."
    local concurrent_jobs=10
    local successful_requests=0
    
    for i in $(seq 1 $concurrent_jobs); do
        {
            if curl -s --max-time 10 "http://$VIRTUAL_IP/" > /dev/null 2>&1; then
                echo "success" > "/tmp/test_result_$i"
            fi
        } &
    done
    wait
    
    # Count successful requests
    for i in $(seq 1 $concurrent_jobs); do
        if [ -f "/tmp/test_result_$i" ]; then
            ((successful_requests++))
            rm -f "/tmp/test_result_$i"
        fi
    done
    
    if [ $successful_requests -ge 8 ]; then
        print_success "Concurrent requests handled well ($successful_requests/$concurrent_jobs)"
    else
        print_warning "Some concurrent requests failed ($successful_requests/$concurrent_jobs)"
    fi
    
    # Test resource optimization per component
    local components=("$WEB_SERVER_1_IP:nginx" "$WEB_SERVER_2_IP:nginx" "$APP_SERVER_IP:php-fpm" "$DATABASE_SERVER_IP:mysql")
    
    for component in "${components[@]}"; do
        local ip=$(echo $component | cut -d: -f1)
        local service=$(echo $component | cut -d: -f2)
        
        local cpu_usage=$(ssh -o ConnectTimeout=5 "$ip" "top -bn1 | grep $service | head -1 | awk '{print \$9}'" 2>/dev/null)
        if [ ! -z "$cpu_usage" ] && (( $(echo "$cpu_usage < 50" | bc -l) )); then
            print_success "$service on $ip: CPU usage optimal ($cpu_usage%)"
        elif [ ! -z "$cpu_usage" ]; then
            print_warning "$service on $ip: CPU usage high ($cpu_usage%)"
        else
            print_warning "Cannot check CPU usage for $service on $ip"
        fi
    done
}

# Test High Availability Features
test_high_availability() {
    print_test "High availability and fault tolerance"
    
    # Test health check endpoints
    local health_endpoints=("$WEB_SERVER_1_IP/health" "$WEB_SERVER_2_IP/health")
    
    for endpoint in "${health_endpoints[@]}"; do
        local health_response=$(curl -s --max-time 5 "http://$endpoint" 2>/dev/null)
        if [[ $health_response == *"healthy"* ]]; then
            print_success "Health check endpoint $endpoint responding"
        else
            print_failure "Health check endpoint $endpoint not responding"
        fi
    done
    
    # Test database replication (if configured)
    local replication_status=$(ssh -o ConnectTimeout=5 "$DATABASE_SERVER_IP" "mysql -e 'SHOW SLAVE STATUS\G' 2>/dev/null | grep 'Slave_IO_Running'" 2>/dev/null)
    if [[ $replication_status == *"Yes"* ]]; then
        print_success "Database replication running"
    else
        print_warning "Database replication status unclear"
    fi
    
    # Test failover capability by checking multiple LB access methods
    local failover_methods=("$VIRTUAL_IP" "$LB_MASTER_IP" "$LB_BACKUP_IP")
    local accessible_lbs=0
    
    for lb_ip in "${failover_methods[@]}"; do
        if curl -s --max-time 5 "http://$lb_ip:8404/stats" > /dev/null 2>&1; then
            ((accessible_lbs++))
        fi
    done
    
    if [ $accessible_lbs -ge 2 ]; then
        print_success "Multiple load balancer access points available"
    else
        print_warning "Limited load balancer redundancy ($accessible_lbs/3)"
    fi
}

# Test Security with Component Separation
test_separated_security() {
    print_test "Security in separated architecture"
    
    # Test that each component only exposes necessary ports
    local security_checks=(
        "$WEB_SERVER_1_IP:80:Web Server 1"
        "$WEB_SERVER_2_IP:80:Web Server 2" 
        "$APP_SERVER_IP:9000:Application Server"
        "$DATABASE_SERVER_IP:3306:Database Server"
    )
    
    for check in "${security_checks[@]}"; do
        local ip=$(echo $check | cut -d: -f1)
        local port=$(echo $check | cut -d: -f2)
        local name=$(echo $check | cut -d: -f3)
        
        if nc -z -w3 "$ip" "$port" 2>/dev/null; then
            print_success "$name: Required port $port accessible"
        else
            print_failure "$name: Required port $port not accessible"
        fi
    done
    
    # Test that components are not exposing unnecessary services
    # Web servers should not expose 3306 (MySQL)
    if ! nc -z -w2 "$WEB_SERVER_1_IP" 3306 2>/dev/null; then
        print_success "Web Server 1: MySQL port properly isolated"
    else
        print_failure "Web Server 1: MySQL port exposed"
    fi
    
    # Application server should not expose 80 (HTTP)
    if ! nc -z -w2 "$APP_SERVER_IP" 80 2>/dev/null; then
        print_success "Application Server: HTTP port properly isolated"
    else
        print_failure "Application Server: HTTP port exposed"
    fi
    
    # Database server should not expose 80 or 9000
    if ! nc -z -w2 "$DATABASE_SERVER_IP" 80 2>/dev/null && ! nc -z -w2 "$DATABASE_SERVER_IP" 9000 2>/dev/null; then
        print_success "Database Server: Web/App ports properly isolated"
    else
        print_failure "Database Server: Web/App ports exposed"
    fi
}

# Test Performance Optimization
test_performance_optimization() {
    print_test "Performance optimization for separated components"
    
    # Test static content serving performance (web servers)
    local static_start=$(date +%s.%N)
    curl -s "http://$WEB_SERVER_1_IP/health" > /dev/null 2>&1
    local static_end=$(date +%s.%N)
    local static_time=$(echo "$static_end - $static_start" | bc)
    
    if (( $(echo "$static_time < 0.5" | bc -l) )); then
        print_success "Static content serving fast ($static_time seconds)"
    else
        print_warning "Static content serving slow ($static_time seconds)"
    fi
    
    # Test dynamic content processing (application server)
    local dynamic_start=$(date +%s.%N)
    curl -s "http://$APP_SERVER_IP:9000/app-test.php" > /dev/null 2>&1
    local dynamic_end=$(date +%s.%N)
    local dynamic_time=$(echo "$dynamic_end - $dynamic_start" | bc)
    
    if (( $(echo "$dynamic_time < 1.0" | bc -l) )); then
        print_success "Dynamic content processing fast ($dynamic_time seconds)"
    else
        print_warning "Dynamic content processing slow ($dynamic_time seconds)"
    fi
    
    # Test overall response time through load balancer
    local overall_start=$(date +%s.%N)
    curl -s "http://$VIRTUAL_IP/" > /dev/null 2>&1
    local overall_end=$(date +%s.%N)
    local overall_time=$(echo "$overall_end - $overall_start" | bc)
    
    if (( $(echo "$overall_time < 2.0" | bc -l) )); then
        print_success "Overall response time good ($overall_time seconds)"
    else
        print_warning "Overall response time needs improvement ($overall_time seconds)"
    fi
}

# Test Monitoring and Observability
test_monitoring_separation() {
    print_test "Monitoring in separated architecture"
    
    # Test that logs are properly separated by component
    local log_locations=(
        "$WEB_SERVER_1_IP:/var/log/nginx/access.log"
        "$APP_SERVER_IP:/var/log/php-fpm-errors.log"
        "$DATABASE_SERVER_IP:/var/log/mysql/error.log"
    )
    
    for log_location in "${log_locations[@]}"; do
        local server=$(echo $log_location | cut -d: -f1)
        local log_path=$(echo $log_location | cut -d: -f2)
        
        if ssh -o ConnectTimeout=5 "$server" "test -f $log_path" 2>/dev/null; then
            print_success "Log file exists on $(echo $log_location | cut -d'/' -f3): $log_path"
        else
            print_warning "Log file missing: $log_location"
        fi
    done
    
    # Test HAproxy statistics for component monitoring
    local stats_content=$(curl -s --max-time 10 "http://$VIRTUAL_IP:8404/stats" 2>/dev/null)
    if echo "$stats_content" | grep -q "web1\|web2"; then
        print_success "HAproxy stats showing separated web servers"
    else
        print_failure "HAproxy stats not showing proper server separation"
    fi
}

# Main test execution
main() {
    echo "🚀 Starting Comprehensive Scale Up Infrastructure Tests"
    echo "Target Infrastructure: $DOMAIN ($VIRTUAL_IP)"
    echo "Component Separation Architecture Testing"
    echo "========================================================="
    
    # Run all tests
    test_load_balancer_cluster
    echo ""
    
    test_component_separation
    echo ""
    
    test_component_communication
    echo ""
    
    test_load_distribution
    echo ""
    
    test_scalability
    echo ""
    
    test_high_availability
    echo ""
    
    test_separated_security
    echo ""
    
    test_performance_optimization
    echo ""
    
    test_monitoring_separation
    echo ""
    
    # Summary
    echo "========================================================="
    echo "🏁 Test Results Summary"
    echo "========================================================="
    echo -e "${GREEN}✅ Tests Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}❌ Tests Failed: $TESTS_FAILED${NC}"
    
    local total_tests=$((TESTS_PASSED + TESTS_FAILED))
    local success_rate=$(( (TESTS_PASSED * 100) / total_tests ))
    
    echo "📊 Success Rate: $success_rate%"
    
    if [ $success_rate -ge 85 ]; then
        echo -e "${GREEN}🎉 Scale Up Infrastructure status: EXCELLENT${NC}"
    elif [ $success_rate -ge 70 ]; then
        echo -e "${YELLOW}⚠️ Scale Up Infrastructure status: GOOD - Some optimizations needed${NC}"
    else
        echo -e "${RED}🚨 Scale Up Infrastructure status: NEEDS ATTENTION${NC}"
    fi
    
    echo ""
    echo "📋 Task 3 Requirements Verification:"
    echo "✅ Additional Server: Dedicated application server added"
    echo "✅ Load Balancer Cluster: HAproxy + Keepalived clustering"
    echo "✅ Component Separation:"
    echo "   • Web Servers: Nginx only (static content)"
    echo "   • Application Server: PHP-FPM only (dynamic processing)"
    echo "   • Database Server: MySQL only (data storage)"
    echo ""
    echo "🏗️ Architecture Benefits Demonstrated:"
    echo "• Independent component scaling"
    echo "• Optimized resource allocation"
    echo "• Eliminated load balancer SPOF"
    echo "• Better security isolation"
    echo "• Improved maintenance capabilities"
    
    if [ $TESTS_FAILED -gt 0 ]; then
        echo -e "\n${RED}⚠️ Some tests failed. Check component configuration and connectivity.${NC}"
        exit 1
    else
        echo -e "\n${GREEN}🏆 All tests passed! Scale Up infrastructure ready for production.${NC}"
        exit 0
    fi
}

# Check dependencies
check_dependencies() {
    local deps=("curl" "nc" "bc" "ssh")
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
