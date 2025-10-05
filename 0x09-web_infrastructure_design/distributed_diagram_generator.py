#!/usr/bin/env python3
"""
Distributed Web Infrastructure Diagram Generator
This script generates visual representations of the distributed web infrastructure.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch, Circle
import numpy as np

def create_distributed_infrastructure_diagram():
    """Create a visual diagram of the distributed web infrastructure."""
    
    # Create figure and axis
    fig, ax = plt.subplots(1, 1, figsize=(16, 12))
    ax.set_xlim(0, 16)
    ax.set_ylim(0, 14)
    ax.axis('off')
    
    # Title
    ax.text(8, 13.5, 'Distributed Web Infrastructure', 
            fontsize=18, fontweight='bold', ha='center')
    ax.text(8, 13, 'Three-Server Architecture with Load Balancing', 
            fontsize=14, ha='center', style='italic')
    
    # User's Computer
    user_box = FancyBboxPatch((1, 11), 2.5, 1, 
                              boxstyle="round,pad=0.1", 
                              facecolor='lightblue', 
                              edgecolor='blue', linewidth=2)
    ax.add_patch(user_box)
    ax.text(2.25, 11.5, "User's Computer", fontsize=11, ha='center', fontweight='bold')
    
    # Internet/DNS Cloud
    dns_box = FancyBboxPatch((6.5, 11), 3, 1, 
                             boxstyle="round,pad=0.1", 
                             facecolor='lightgray', 
                             edgecolor='gray', linewidth=2)
    ax.add_patch(dns_box)
    ax.text(8, 11.7, 'Internet/DNS', fontsize=11, ha='center', fontweight='bold')
    ax.text(8, 11.4, 'www.foobar.com', fontsize=9, ha='center')
    ax.text(8, 11.1, '→ 8.8.8.8', fontsize=9, ha='center')
    
    # Load Balancer Server
    lb_box = FancyBboxPatch((6, 8.5), 4, 2, 
                            boxstyle="round,pad=0.1", 
                            facecolor='orange', 
                            edgecolor='darkorange', linewidth=3)
    ax.add_patch(lb_box)
    ax.text(8, 9.8, 'Load Balancer Server', fontsize=13, ha='center', fontweight='bold')
    ax.text(8, 9.5, 'HAproxy', fontsize=11, ha='center', fontweight='bold')
    ax.text(8, 9.2, 'Public IP: 8.8.8.8', fontsize=10, ha='center')
    ax.text(8, 8.9, 'Round Robin Distribution', fontsize=9, ha='center', style='italic')
    
    # Web Server 1
    web1_box = FancyBboxPatch((1, 5), 3.5, 3, 
                              boxstyle="round,pad=0.1", 
                              facecolor='lightgreen', 
                              edgecolor='green', linewidth=3)
    ax.add_patch(web1_box)
    ax.text(2.75, 7.5, 'Web Server 1', fontsize=12, ha='center', fontweight='bold')
    ax.text(2.75, 7.2, '(10.0.0.2)', fontsize=10, ha='center')
    
    # Nginx on Web Server 1
    nginx1_box = FancyBboxPatch((1.2, 6.5), 3.1, 0.4, 
                                boxstyle="round,pad=0.02", 
                                facecolor='darkgreen', 
                                edgecolor='darkgreen', linewidth=1)
    ax.add_patch(nginx1_box)
    ax.text(2.75, 6.7, 'Nginx (80/443)', fontsize=9, ha='center', color='white', fontweight='bold')
    
    # PHP-FPM on Web Server 1
    php1_box = FancyBboxPatch((1.2, 6), 3.1, 0.4, 
                              boxstyle="round,pad=0.02", 
                              facecolor='darkblue', 
                              edgecolor='darkblue', linewidth=1)
    ax.add_patch(php1_box)
    ax.text(2.75, 6.2, 'PHP-FPM', fontsize=9, ha='center', color='white', fontweight='bold')
    
    # App Files on Web Server 1
    app1_box = FancyBboxPatch((1.2, 5.5), 3.1, 0.4, 
                              boxstyle="round,pad=0.02", 
                              facecolor='darkred', 
                              edgecolor='darkred', linewidth=1)
    ax.add_patch(app1_box)
    ax.text(2.75, 5.7, 'Application Files', fontsize=9, ha='center', color='white', fontweight='bold')
    
    # Web Server 2
    web2_box = FancyBboxPatch((11.5, 5), 3.5, 3, 
                              boxstyle="round,pad=0.1", 
                              facecolor='lightgreen', 
                              edgecolor='green', linewidth=3)
    ax.add_patch(web2_box)
    ax.text(13.25, 7.5, 'Web Server 2', fontsize=12, ha='center', fontweight='bold')
    ax.text(13.25, 7.2, '(10.0.0.3)', fontsize=10, ha='center')
    
    # Nginx on Web Server 2
    nginx2_box = FancyBboxPatch((11.7, 6.5), 3.1, 0.4, 
                                boxstyle="round,pad=0.02", 
                                facecolor='darkgreen', 
                                edgecolor='darkgreen', linewidth=1)
    ax.add_patch(nginx2_box)
    ax.text(13.25, 6.7, 'Nginx (80/443)', fontsize=9, ha='center', color='white', fontweight='bold')
    
    # PHP-FPM on Web Server 2
    php2_box = FancyBboxPatch((11.7, 6), 3.1, 0.4, 
                              boxstyle="round,pad=0.02", 
                              facecolor='darkblue', 
                              edgecolor='darkblue', linewidth=1)
    ax.add_patch(php2_box)
    ax.text(13.25, 6.2, 'PHP-FPM', fontsize=9, ha='center', color='white', fontweight='bold')
    
    # App Files on Web Server 2
    app2_box = FancyBboxPatch((11.7, 5.5), 3.1, 0.4, 
                              boxstyle="round,pad=0.02", 
                              facecolor='darkred', 
                              edgecolor='darkred', linewidth=1)
    ax.add_patch(app2_box)
    ax.text(13.25, 5.7, 'Application Files', fontsize=9, ha='center', color='white', fontweight='bold')
    
    # Database Server
    db_box = FancyBboxPatch((5.5, 1.5), 5, 2.5, 
                            boxstyle="round,pad=0.1", 
                            facecolor='lightsteelblue', 
                            edgecolor='steelblue', linewidth=3)
    ax.add_patch(db_box)
    ax.text(8, 3.5, 'Database Server', fontsize=12, ha='center', fontweight='bold')
    ax.text(8, 3.2, '(10.0.0.4)', fontsize=10, ha='center')
    
    # Primary MySQL
    primary_db_box = FancyBboxPatch((5.7, 2.5), 2.1, 0.6, 
                                    boxstyle="round,pad=0.02", 
                                    facecolor='darkblue', 
                                    edgecolor='darkblue', linewidth=1)
    ax.add_patch(primary_db_box)
    ax.text(6.75, 2.8, 'MySQL Primary', fontsize=9, ha='center', color='white', fontweight='bold')
    ax.text(6.75, 2.6, '(Master)', fontsize=8, ha='center', color='white')
    
    # Replica MySQL
    replica_db_box = FancyBboxPatch((8.2, 2.5), 2.1, 0.6, 
                                    boxstyle="round,pad=0.02", 
                                    facecolor='purple', 
                                    edgecolor='purple', linewidth=1)
    ax.add_patch(replica_db_box)
    ax.text(9.25, 2.8, 'MySQL Replica', fontsize=9, ha='center', color='white', fontweight='bold')
    ax.text(9.25, 2.6, '(Slave)', fontsize=8, ha='center', color='white')
    
    # Replication arrow
    repl_arrow = ConnectionPatch((7.8, 2.8), (8.2, 2.8), "data", "data",
                                arrowstyle="-|>", shrinkA=2, shrinkB=2, 
                                mutation_scale=15, fc="red", ec="red", alpha=0.8)
    ax.add_artist(repl_arrow)
    ax.text(8, 3.05, 'Replication', fontsize=8, ha='center', color='red', fontweight='bold')
    
    # Connection arrows
    # User to DNS
    arrow1 = ConnectionPatch((3.5, 11.5), (6.5, 11.5), "data", "data",
                            arrowstyle="-|>", shrinkA=5, shrinkB=5, 
                            mutation_scale=20, fc="blue", alpha=0.7)
    ax.add_artist(arrow1)
    ax.text(5, 11.8, 'DNS Query', fontsize=9, ha='center', color='blue')
    
    # DNS to Load Balancer
    arrow2 = ConnectionPatch((8, 11), (8, 10.5), "data", "data",
                            arrowstyle="-|>", shrinkA=5, shrinkB=5, 
                            mutation_scale=20, fc="green", alpha=0.7)
    ax.add_artist(arrow2)
    ax.text(8.8, 10.7, 'HTTP Request', fontsize=9, ha='center', color='green')
    
    # Load Balancer to Web Servers
    arrow3 = ConnectionPatch((7, 8.5), (3.5, 8), "data", "data",
                            arrowstyle="-|>", shrinkA=5, shrinkB=5, 
                            mutation_scale=20, fc="orange", alpha=0.8)
    ax.add_artist(arrow3)
    
    arrow4 = ConnectionPatch((9, 8.5), (12.5, 8), "data", "data",
                            arrowstyle="-|>", shrinkA=5, shrinkB=5, 
                            mutation_scale=20, fc="orange", alpha=0.8)
    ax.add_artist(arrow4)
    
    # Web Servers to Database
    arrow5 = ConnectionPatch((4, 5), (6.5, 4), "data", "data",
                            arrowstyle="-|>", shrinkA=5, shrinkB=5, 
                            mutation_scale=20, fc="purple", alpha=0.8)
    ax.add_artist(arrow5)
    
    arrow6 = ConnectionPatch((12, 5), (9.5, 4), "data", "data",
                            arrowstyle="-|>", shrinkA=5, shrinkB=5, 
                            mutation_scale=20, fc="purple", alpha=0.8)
    ax.add_artist(arrow6)
    
    # Add legend
    legend_box = FancyBboxPatch((0.5, 0.2), 4, 1.2, 
                                boxstyle="round,pad=0.1", 
                                facecolor='white', 
                                edgecolor='black', linewidth=1)
    ax.add_patch(legend_box)
    ax.text(2.5, 1.1, 'Infrastructure Legend', fontsize=11, ha='center', fontweight='bold')
    ax.text(0.7, 0.9, '🔵 User Request Flow', fontsize=9)
    ax.text(0.7, 0.7, '🟠 Load Distribution', fontsize=9)
    ax.text(0.7, 0.5, '🟣 Database Operations', fontsize=9)
    ax.text(0.7, 0.3, '🔴 Database Replication', fontsize=9)
    
    # Add issues box
    issues_box = FancyBboxPatch((11.5, 0.2), 4, 1.2, 
                                boxstyle="round,pad=0.1", 
                                facecolor='mistyrose', 
                                edgecolor='red', linewidth=2)
    ax.add_patch(issues_box)
    ax.text(13.5, 1.1, 'Infrastructure Issues', fontsize=11, ha='center', fontweight='bold', color='red')
    ax.text(11.7, 0.9, '• SPOF: Load Balancer & DB Primary', fontsize=8)
    ax.text(11.7, 0.7, '• Security: No HTTPS, No Firewall', fontsize=8)
    ax.text(11.7, 0.5, '• Monitoring: No monitoring system', fontsize=8)
    ax.text(11.7, 0.3, '• Network: No segmentation', fontsize=8)
    
    plt.tight_layout()
    return fig

def create_load_balancing_diagram():
    """Create a detailed load balancing flow diagram."""
    
    fig, ax = plt.subplots(1, 1, figsize=(14, 10))
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Title
    ax.text(7, 9.5, 'Load Balancing Flow - Round Robin Algorithm', 
            fontsize=16, fontweight='bold', ha='center')
    
    # Load Balancer
    lb_circle = Circle((7, 7), 1, facecolor='orange', edgecolor='darkorange', linewidth=3)
    ax.add_patch(lb_circle)
    ax.text(7, 7, 'HAproxy\nLoad\nBalancer', fontsize=10, ha='center', fontweight='bold')
    
    # Web Server 1
    ws1_circle = Circle((3, 4), 0.8, facecolor='lightgreen', edgecolor='green', linewidth=2)
    ax.add_patch(ws1_circle)
    ax.text(3, 4, 'Web\nServer 1\n10.0.0.2', fontsize=9, ha='center', fontweight='bold')
    
    # Web Server 2
    ws2_circle = Circle((11, 4), 0.8, facecolor='lightgreen', edgecolor='green', linewidth=2)
    ax.add_patch(ws2_circle)
    ax.text(11, 4, 'Web\nServer 2\n10.0.0.3', fontsize=9, ha='center', fontweight='bold')
    
    # Request sequence
    requests = [
        (1, 8.5, "Request 1", 3),
        (1, 8, "Request 2", 11),
        (1, 7.5, "Request 3", 3),
        (1, 7, "Request 4", 11),
    ]
    
    colors = ['red', 'blue', 'green', 'purple']
    
    for i, (x, y, label, target_x) in enumerate(requests):
        # Request label
        ax.text(x, y, label, fontsize=10, fontweight='bold', color=colors[i])
        
        # Arrow to load balancer
        arrow1 = ConnectionPatch((x + 0.8, y), (6, y), "data", "data",
                                arrowstyle="-|>", shrinkA=2, shrinkB=2, 
                                mutation_scale=15, fc=colors[i], ec=colors[i], alpha=0.7)
        ax.add_artist(arrow1)
        
        # Arrow from load balancer to target server
        if target_x == 3:
            arrow2 = ConnectionPatch((6.2, 6.5), (3.6, 4.6), "data", "data",
                                    arrowstyle="-|>", shrinkA=2, shrinkB=2, 
                                    mutation_scale=15, fc=colors[i], ec=colors[i], alpha=0.7)
        else:
            arrow2 = ConnectionPatch((7.8, 6.5), (10.4, 4.6), "data", "data",
                                    arrowstyle="-|>", shrinkA=2, shrinkB=2, 
                                    mutation_scale=15, fc=colors[i], ec=colors[i], alpha=0.7)
        ax.add_artist(arrow2)
    
    # Algorithm explanation
    algo_box = FancyBboxPatch((0.5, 1), 6, 2, 
                              boxstyle="round,pad=0.1", 
                              facecolor='lightyellow', 
                              edgecolor='orange', linewidth=2)
    ax.add_patch(algo_box)
    ax.text(3.5, 2.5, 'Round Robin Algorithm', fontsize=12, ha='center', fontweight='bold')
    ax.text(0.7, 2.2, '1. Requests distributed sequentially', fontsize=10)
    ax.text(0.7, 1.9, '2. Cycles through all healthy servers', fontsize=10)
    ax.text(0.7, 1.6, '3. Equal distribution over time', fontsize=10)
    ax.text(0.7, 1.3, '4. Simple and effective for similar servers', fontsize=10)
    
    # Active-Active explanation
    active_box = FancyBboxPatch((7.5, 1), 6, 2, 
                                boxstyle="round,pad=0.1", 
                                facecolor='lightcyan', 
                                edgecolor='blue', linewidth=2)
    ax.add_patch(active_box)
    ax.text(10.5, 2.5, 'Active-Active Setup', fontsize=12, ha='center', fontweight='bold')
    ax.text(7.7, 2.2, '• Both servers handle requests simultaneously', fontsize=10)
    ax.text(7.7, 1.9, '• Maximum resource utilization', fontsize=10)
    ax.text(7.7, 1.6, '• Better performance than Active-Passive', fontsize=10)
    ax.text(7.7, 1.3, '• Automatic failover if one server fails', fontsize=10)
    
    plt.tight_layout()
    return fig

def create_database_replication_diagram():
    """Create a database replication diagram."""
    
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 8)
    ax.axis('off')
    
    # Title
    ax.text(6, 7.5, 'Database Primary-Replica (Master-Slave) Architecture', 
            fontsize=16, fontweight='bold', ha='center')
    
    # Application Servers
    app1_box = FancyBboxPatch((0.5, 5), 2, 1.5, 
                              boxstyle="round,pad=0.1", 
                              facecolor='lightgreen', 
                              edgecolor='green', linewidth=2)
    ax.add_patch(app1_box)
    ax.text(1.5, 5.75, 'Web Server 1\nApplication', fontsize=10, ha='center', fontweight='bold')
    
    app2_box = FancyBboxPatch((9.5, 5), 2, 1.5, 
                              boxstyle="round,pad=0.1", 
                              facecolor='lightgreen', 
                              edgecolor='green', linewidth=2)
    ax.add_patch(app2_box)
    ax.text(10.5, 5.75, 'Web Server 2\nApplication', fontsize=10, ha='center', fontweight='bold')
    
    # Primary Database
    primary_box = FancyBboxPatch((2, 2), 3, 2, 
                                 boxstyle="round,pad=0.1", 
                                 facecolor='lightblue', 
                                 edgecolor='blue', linewidth=3)
    ax.add_patch(primary_box)
    ax.text(3.5, 3.5, 'MySQL Primary', fontsize=12, ha='center', fontweight='bold')
    ax.text(3.5, 3.2, '(Master)', fontsize=11, ha='center')
    ax.text(3.5, 2.9, 'Port 3306', fontsize=10, ha='center')
    ax.text(3.5, 2.6, 'Writes & Reads', fontsize=10, ha='center', style='italic')
    ax.text(3.5, 2.3, 'Binary Logging', fontsize=9, ha='center', color='blue')
    
    # Replica Database
    replica_box = FancyBboxPatch((7, 2), 3, 2, 
                                 boxstyle="round,pad=0.1", 
                                 facecolor='lavender', 
                                 edgecolor='purple', linewidth=3)
    ax.add_patch(replica_box)
    ax.text(8.5, 3.5, 'MySQL Replica', fontsize=12, ha='center', fontweight='bold')
    ax.text(8.5, 3.2, '(Slave)', fontsize=11, ha='center')
    ax.text(8.5, 2.9, 'Port 3307', fontsize=10, ha='center')
    ax.text(8.5, 2.6, 'Reads Only', fontsize=10, ha='center', style='italic')
    ax.text(8.5, 2.3, 'Relay Logging', fontsize=9, ha='center', color='purple')
    
    # Write operations (to primary)
    write_arrow1 = ConnectionPatch((1.5, 5), (3, 4), "data", "data",
                                  arrowstyle="-|>", shrinkA=5, shrinkB=5, 
                                  mutation_scale=20, fc="red", ec="red", alpha=0.8)
    ax.add_artist(write_arrow1)
    ax.text(1.8, 4.3, 'WRITE\nOperations', fontsize=9, ha='center', color='red', fontweight='bold')
    
    write_arrow2 = ConnectionPatch((10.5, 5), (4, 4), "data", "data",
                                  arrowstyle="-|>", shrinkA=5, shrinkB=5, 
                                  mutation_scale=20, fc="red", ec="red", alpha=0.8)
    ax.add_artist(write_arrow2)
    ax.text(9.2, 4.3, 'WRITE\nOperations', fontsize=9, ha='center', color='red', fontweight='bold')
    
    # Read operations (from replica)
    read_arrow1 = ConnectionPatch((1.5, 5), (8, 4), "data", "data",
                                 arrowstyle="-|>", shrinkA=5, shrinkB=5, 
                                 mutation_scale=20, fc="green", ec="green", alpha=0.8)
    ax.add_artist(read_arrow1)
    ax.text(3.5, 4.7, 'READ Operations', fontsize=9, ha='center', color='green', fontweight='bold')
    
    read_arrow2 = ConnectionPatch((10.5, 5), (9, 4), "data", "data",
                                 arrowstyle="-|>", shrinkA=5, shrinkB=5, 
                                 mutation_scale=20, fc="green", ec="green", alpha=0.8)
    ax.add_artist(read_arrow2)
    ax.text(10, 4.7, 'READ\nOperations', fontsize=9, ha='center', color='green', fontweight='bold')
    
    # Replication flow
    repl_arrow = ConnectionPatch((5, 3), (7, 3), "data", "data",
                                arrowstyle="-|>", shrinkA=5, shrinkB=5, 
                                mutation_scale=25, fc="orange", ec="orange", linewidth=3)
    ax.add_artist(repl_arrow)
    ax.text(6, 3.3, 'Binary Log\nReplication', fontsize=10, ha='center', color='orange', fontweight='bold')
    
    # Explanation box
    explain_box = FancyBboxPatch((1, 0.2), 10, 1.2, 
                                 boxstyle="round,pad=0.1", 
                                 facecolor='lightyellow', 
                                 edgecolor='black', linewidth=1)
    ax.add_patch(explain_box)
    ax.text(6, 1.1, 'Replication Process', fontsize=12, ha='center', fontweight='bold')
    ax.text(1.2, 0.8, '1. Primary logs all changes in binary log', fontsize=10)
    ax.text(1.2, 0.6, '2. Replica requests and receives binary log entries', fontsize=10)
    ax.text(1.2, 0.4, '3. Replica applies changes to maintain synchronized copy', fontsize=10)
    
    plt.tight_layout()
    return fig

def create_infrastructure_issues_diagram():
    """Create a diagram showing infrastructure issues."""
    
    fig, ax = plt.subplots(1, 1, figsize=(14, 10))
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Title
    ax.text(7, 9.5, 'Infrastructure Issues Analysis', 
            fontsize=18, fontweight='bold', ha='center', color='red')
    
    # SPOF Section
    spof_box = FancyBboxPatch((0.5, 6.5), 6, 2.5, 
                              boxstyle="round,pad=0.1", 
                              facecolor='mistyrose', 
                              edgecolor='red', linewidth=3)
    ax.add_patch(spof_box)
    ax.text(3.5, 8.5, 'Single Points of Failure (SPOF)', fontsize=14, ha='center', fontweight='bold', color='red')
    
    # SPOF items
    spof_items = [
        "🔴 Load Balancer: If HAproxy fails, entire site down",
        "🔴 Database Primary: Write operations impossible if fails",
        "🔴 Network Connection: Single connection to internet",
        "🔴 Data Center: Single location dependency"
    ]
    
    for i, item in enumerate(spof_items):
        ax.text(0.7, 8.2 - i*0.3, item, fontsize=10, va='center')
    
    # Security Issues Section
    security_box = FancyBboxPatch((7.5, 6.5), 6, 2.5, 
                                  boxstyle="round,pad=0.1", 
                                  facecolor='lightcoral', 
                                  edgecolor='darkred', linewidth=3)
    ax.add_patch(security_box)
    ax.text(10.5, 8.5, 'Security Issues', fontsize=14, ha='center', fontweight='bold', color='darkred')
    
    # Security items
    security_items = [
        "🛡️ No HTTPS: Data transmitted in plain text",
        "🛡️ No Firewall: Servers exposed to attacks",
        "🛡️ No Authentication: Services not authenticated",
        "🛡️ No Network Segmentation: Flat network topology"
    ]
    
    for i, item in enumerate(security_items):
        ax.text(7.7, 8.2 - i*0.3, item, fontsize=10, va='center')
    
    # Monitoring Issues Section
    monitoring_box = FancyBboxPatch((0.5, 3.5), 6, 2.5, 
                                    boxstyle="round,pad=0.1", 
                                    facecolor='lightyellow', 
                                    edgecolor='orange', linewidth=3)
    ax.add_patch(monitoring_box)
    ax.text(3.5, 5.5, 'Monitoring Issues', fontsize=14, ha='center', fontweight='bold', color='orange')
    
    # Monitoring items
    monitoring_items = [
        "📊 No System Monitoring: No visibility into performance",
        "📊 No Alerting: Issues discovered only when users complain",
        "📊 No Log Aggregation: Difficult troubleshooting",
        "📊 No Health Checks: Manual detection of failures"
    ]
    
    for i, item in enumerate(monitoring_items):
        ax.text(0.7, 5.2 - i*0.3, item, fontsize=10, va='center')
    
    # Solutions Section
    solutions_box = FancyBboxPatch((7.5, 3.5), 6, 2.5, 
                                   boxstyle="round,pad=0.1", 
                                   facecolor='lightgreen', 
                                   edgecolor='green', linewidth=3)
    ax.add_patch(solutions_box)
    ax.text(10.5, 5.5, 'Recommended Solutions', fontsize=14, ha='center', fontweight='bold', color='green')
    
    # Solution items
    solution_items = [
        "✅ Load Balancer Clustering (HAproxy + Keepalived)",
        "✅ SSL/TLS Certificates for HTTPS encryption",
        "✅ Comprehensive Monitoring (Prometheus/Grafana)",
        "✅ Database Failover and Network Segmentation"
    ]
    
    for i, item in enumerate(solution_items):
        ax.text(7.7, 5.2 - i*0.3, item, fontsize=10, va='center')
    
    # Impact Assessment
    impact_box = FancyBboxPatch((2, 0.5), 10, 2.5, 
                                boxstyle="round,pad=0.1", 
                                facecolor='lavender', 
                                edgecolor='purple', linewidth=3)
    ax.add_patch(impact_box)
    ax.text(7, 2.7, 'Impact Assessment & Risk Levels', fontsize=14, ha='center', fontweight='bold', color='purple')
    
    impact_items = [
        "🔥 HIGH RISK: SPOF components can cause complete outage",
        "🔥 HIGH RISK: Security vulnerabilities expose sensitive data",
        "⚠️ MEDIUM RISK: No monitoring delays issue detection",
        "⚠️ MEDIUM RISK: Manual processes increase recovery time",
        "📈 BUSINESS IMPACT: Revenue loss, customer dissatisfaction, compliance issues"
    ]
    
    for i, item in enumerate(impact_items):
        ax.text(2.2, 2.4 - i*0.3, item, fontsize=10, va='center')
    
    plt.tight_layout()
    return fig

if __name__ == "__main__":
    # Create and save all diagrams
    
    # Main infrastructure diagram
    fig1 = create_distributed_infrastructure_diagram()
    plt.figure(fig1.number)
    plt.savefig('distributed_infrastructure_diagram.png', dpi=300, bbox_inches='tight')
    print("Distributed infrastructure diagram saved as 'distributed_infrastructure_diagram.png'")
    
    # Load balancing diagram
    fig2 = create_load_balancing_diagram()
    plt.figure(fig2.number)
    plt.savefig('load_balancing_diagram.png', dpi=300, bbox_inches='tight')
    print("Load balancing diagram saved as 'load_balancing_diagram.png'")
    
    # Database replication diagram
    fig3 = create_database_replication_diagram()
    plt.figure(fig3.number)
    plt.savefig('database_replication_diagram.png', dpi=300, bbox_inches='tight')
    print("Database replication diagram saved as 'database_replication_diagram.png'")
    
    # Infrastructure issues diagram
    fig4 = create_infrastructure_issues_diagram()
    plt.figure(fig4.number)
    plt.savefig('infrastructure_issues_diagram.png', dpi=300, bbox_inches='tight')
    print("Infrastructure issues diagram saved as 'infrastructure_issues_diagram.png'")
    
    plt.show()
