#!/usr/bin/env python3
"""
Diagram Generator for Scale Up Web Infrastructure (Task 3)
Generates visual diagrams for separated components and load balancer clustering
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, Circle, ConnectionPatch
import numpy as np

# Set up the plotting style
plt.style.use('default')
plt.rcParams['figure.facecolor'] = 'white'
plt.rcParams['axes.facecolor'] = 'white'

def create_scale_up_infrastructure_diagram():
    """Create the main scale up infrastructure diagram"""
    fig, ax = plt.subplots(1, 1, figsize=(16, 14))
    
    # Colors for different components
    colors = {
        'user': '#4CAF50',
        'internet': '#2196F3',
        'lb_cluster': '#FF9800',
        'web_server': '#9C27B0',
        'app_server': '#E91E63',
        'database': '#795548',
        'connection': '#607D8B'
    }
    
    # Draw User
    user_box = FancyBboxPatch((7, 12), 2, 1, boxstyle="round,pad=0.1", 
                              facecolor=colors['user'], edgecolor='black', linewidth=2)
    ax.add_patch(user_box)
    ax.text(8, 12.5, '👤 User\n(HTTPS Client)', ha='center', va='center', fontsize=10, fontweight='bold')
    
    # Draw Internet/DNS
    internet_box = FancyBboxPatch((7, 10), 2, 1, boxstyle="round,pad=0.1",
                                  facecolor=colors['internet'], edgecolor='black', linewidth=2)
    ax.add_patch(internet_box)
    ax.text(8, 10.5, '🌐 Internet/DNS\nwww.foobar.com\nVIP: 8.8.8.8', ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Draw Load Balancer Cluster
    lb_cluster_box = FancyBboxPatch((5, 7.5), 6, 2, boxstyle="round,pad=0.2",
                                    facecolor=colors['lb_cluster'], alpha=0.3, edgecolor='orange', linewidth=3)
    ax.add_patch(lb_cluster_box)
    ax.text(8, 9, '⚖️ LOAD BALANCER CLUSTER', ha='center', va='center', fontsize=12, fontweight='bold')
    
    # Master LB
    lb_master_box = FancyBboxPatch((5.5, 8), 2, 0.8, boxstyle="round,pad=0.1",
                                   facecolor=colors['lb_cluster'], edgecolor='black', linewidth=2)
    ax.add_patch(lb_master_box)
    ax.text(6.5, 8.4, '🔧 LB Master\n10.0.0.10\n(Active)', ha='center', va='center', fontsize=8, fontweight='bold')
    
    # Backup LB
    lb_backup_box = FancyBboxPatch((8.5, 8), 2, 0.8, boxstyle="round,pad=0.1",
                                   facecolor=colors['lb_cluster'], edgecolor='black', linewidth=2)
    ax.add_patch(lb_backup_box)
    ax.text(9.5, 8.4, '🔧 LB Backup\n10.0.0.11\n(Standby)', ha='center', va='center', fontsize=8, fontweight='bold')
    
    # Virtual IP indicator
    vip_circle = Circle((8, 7.8), 0.2, facecolor='gold', edgecolor='black', linewidth=2)
    ax.add_patch(vip_circle)
    ax.text(8, 7.8, 'VIP', ha='center', va='center', fontsize=6, fontweight='bold')
    
    # Draw Web Server Tier
    web_tier_box = FancyBboxPatch((1, 5), 14, 1.5, boxstyle="round,pad=0.2",
                                  facecolor=colors['web_server'], alpha=0.2, edgecolor='purple', linewidth=2)
    ax.add_patch(web_tier_box)
    ax.text(8, 6.2, '🌐 WEB SERVER TIER (Nginx Only - Static Content)', ha='center', va='center', fontsize=12, fontweight='bold')
    
    # Web Server 1
    web1_box = FancyBboxPatch((2, 5.2), 3, 1, boxstyle="round,pad=0.1",
                              facecolor=colors['web_server'], edgecolor='black', linewidth=2)
    ax.add_patch(web1_box)
    ax.text(3.5, 5.7, '🌐 Web Server 1\n10.0.0.20\nNginx Only', ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Web Server 2
    web2_box = FancyBboxPatch((11, 5.2), 3, 1, boxstyle="round,pad=0.1",
                              facecolor=colors['web_server'], edgecolor='black', linewidth=2)
    ax.add_patch(web2_box)
    ax.text(12.5, 5.7, '🌐 Web Server 2\n10.0.0.21\nNginx Only', ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Draw Application Server Tier
    app_tier_box = FancyBboxPatch((5, 2.5), 6, 1.5, boxstyle="round,pad=0.2",
                                  facecolor=colors['app_server'], alpha=0.2, edgecolor='red', linewidth=2)
    ax.add_patch(app_tier_box)
    ax.text(8, 3.7, '🚀 APPLICATION SERVER TIER', ha='center', va='center', fontsize=12, fontweight='bold')
    
    # Application Server
    app_box = FancyBboxPatch((6, 2.7), 4, 1, boxstyle="round,pad=0.1",
                             facecolor=colors['app_server'], edgecolor='black', linewidth=2)
    ax.add_patch(app_box)
    ax.text(8, 3.2, '🚀 Application Server\n10.0.0.30\nPHP-FPM Only\nBusiness Logic', ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Draw Database Server Tier
    db_tier_box = FancyBboxPatch((5, 0), 6, 1.5, boxstyle="round,pad=0.2",
                                 facecolor=colors['database'], alpha=0.2, edgecolor='brown', linewidth=2)
    ax.add_patch(db_tier_box)
    ax.text(8, 1.2, '🗄️ DATABASE SERVER TIER', ha='center', va='center', fontsize=12, fontweight='bold')
    
    # Database Server
    db_box = FancyBboxPatch((6, 0.2), 4, 1, boxstyle="round,pad=0.1",
                            facecolor=colors['database'], edgecolor='black', linewidth=2)
    ax.add_patch(db_box)
    ax.text(8, 0.7, '🗄️ Database Server\n10.0.0.40\nMySQL Only\nPrimary + Replica', ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Draw connections with different styles
    # User to Internet
    ax.annotate('', xy=(8, 10.8), xytext=(8, 11.8), 
                arrowprops=dict(arrowstyle='->', lw=3, color='green'))
    ax.text(8.5, 11.3, 'HTTPS', fontsize=8, rotation=90, va='center')
    
    # Internet to LB Cluster (VIP)
    ax.annotate('', xy=(8, 9.3), xytext=(8, 9.8), 
                arrowprops=dict(arrowstyle='->', lw=3, color='blue'))
    ax.text(8.5, 9.5, 'VIP', fontsize=8, rotation=90, va='center')
    
    # LB Cluster to Web Servers
    ax.annotate('', xy=(3.5, 6), xytext=(6.5, 7.8), 
                arrowprops=dict(arrowstyle='->', lw=2, color='orange'))
    ax.annotate('', xy=(12.5, 6), xytext=(9.5, 7.8), 
                arrowprops=dict(arrowstyle='->', lw=2, color='orange'))
    ax.text(5, 6.8, 'Load\nBalanced', fontsize=7, ha='center')
    ax.text(11, 6.8, 'Load\nBalanced', fontsize=7, ha='center')
    
    # Web Servers to Application Server
    ax.annotate('', xy=(7, 3.5), xytext=(3.5, 5.4), 
                arrowprops=dict(arrowstyle='->', lw=2, color='purple'))
    ax.annotate('', xy=(9, 3.5), xytext=(12.5, 5.4), 
                arrowprops=dict(arrowstyle='->', lw=2, color='purple'))
    ax.text(5, 4.5, 'PHP\nRequests', fontsize=7, ha='center', rotation=45)
    ax.text(11, 4.5, 'PHP\nRequests', fontsize=7, ha='center', rotation=-45)
    
    # Application Server to Database
    ax.annotate('', xy=(8, 1.3), xytext=(8, 2.8), 
                arrowprops=dict(arrowstyle='->', lw=2, color='brown'))
    ax.text(8.5, 2, 'SQL\nQueries', fontsize=8, rotation=90, va='center')
    
    # Add HA indicator between LBs
    ha_line = ConnectionPatch((6.5, 7.9), (9.5, 7.9), "data", "data",
                              arrowstyle="<->", shrinkA=5, shrinkB=5, 
                              mutation_scale=20, fc="red", lw=2)
    ax.add_artist(ha_line)
    ax.text(8, 7.6, 'Keepalived\nHA Cluster', ha='center', va='center', fontsize=7, fontweight='bold')
    
    # Add title
    ax.set_title('Task 3: Scale Up Web Infrastructure\nComponent Separation + Load Balancer Clustering', 
                 fontsize=16, fontweight='bold', pad=20)
    
    # Add legend
    legend_elements = [
        patches.Rectangle((0, 0), 1, 1, facecolor=colors['lb_cluster'], label='⚖️ Load Balancer Cluster'),
        patches.Rectangle((0, 0), 1, 1, facecolor=colors['web_server'], label='🌐 Web Servers (Nginx)'),
        patches.Rectangle((0, 0), 1, 1, facecolor=colors['app_server'], label='🚀 Application Server (PHP-FPM)'),
        patches.Rectangle((0, 0), 1, 1, facecolor=colors['database'], label='🗄️ Database Server (MySQL)'),
        patches.Rectangle((0, 0), 1, 1, facecolor='gold', label='🔗 Virtual IP (VIP)')
    ]
    ax.legend(handles=legend_elements, loc='upper right', bbox_to_anchor=(1, 1), fontsize=9)
    
    # Set axis properties
    ax.set_xlim(0, 16)
    ax.set_ylim(0, 14)
    ax.set_aspect('equal')
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('scale_up_infrastructure_diagram.png', dpi=300, bbox_inches='tight')
    plt.show()

def create_component_separation_diagram():
    """Create diagram showing component separation benefits"""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 8))
    
    colors = {
        'monolithic': '#FF5722',
        'separated': '#4CAF50',
        'web': '#9C27B0',
        'app': '#E91E63',
        'db': '#795548'
    }
    
    # Before: Monolithic servers
    ax1.set_title('BEFORE: Monolithic Servers\n(Task 1 Architecture)', fontsize=14, fontweight='bold')
    
    monolithic_servers = [
        (2, 6, 'Web Server 1\n• Nginx\n• PHP-FPM\n• App Files\n• Resource Competition'),
        (2, 3, 'Web Server 2\n• Nginx\n• PHP-FPM\n• App Files\n• Resource Competition')
    ]
    
    for x, y, text in monolithic_servers:
        mono_box = FancyBboxPatch((x-1.5, y-1), 3, 2, boxstyle="round,pad=0.1",
                                  facecolor=colors['monolithic'], edgecolor='black', linewidth=2)
        ax1.add_patch(mono_box)
        ax1.text(x, y, text, ha='center', va='center', fontsize=9, fontweight='bold')
        
        # Add warning symbols
        ax1.text(x+1.2, y+0.7, '⚠️', ha='center', va='center', fontsize=12)
    
    # Database server
    db_box1 = FancyBboxPatch((0.5, 0.5), 3, 1, boxstyle="round,pad=0.1",
                             facecolor=colors['db'], edgecolor='black', linewidth=2)
    ax1.add_patch(db_box1)
    ax1.text(2, 1, '🗄️ Database Server\nMySQL Only', ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Load balancer SPOF
    lb_box1 = FancyBboxPatch((0.5, 8), 3, 1, boxstyle="round,pad=0.1",
                             facecolor='red', alpha=0.7, edgecolor='black', linewidth=2)
    ax1.add_patch(lb_box1)
    ax1.text(2, 8.5, '⚖️ Single Load Balancer\n❌ SPOF Risk', ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Issues list
    issues_text = "Issues:\n• Resource competition\n• Difficult to scale\n• Complex troubleshooting\n• SPOF at load balancer\n• Inflexible scaling"
    ax1.text(5, 5, issues_text, ha='left', va='center', fontsize=10, 
             bbox=dict(boxstyle="round,pad=0.5", facecolor='red', alpha=0.3))
    
    ax1.set_xlim(0, 8)
    ax1.set_ylim(0, 10)
    ax1.set_aspect('equal')
    ax1.axis('off')
    
    # After: Separated components
    ax2.set_title('AFTER: Separated Components\n(Task 3 Architecture)', fontsize=14, fontweight='bold')
    
    # Load balancer cluster
    lb_cluster = FancyBboxPatch((1, 8), 4, 1, boxstyle="round,pad=0.1",
                                facecolor=colors['separated'], edgecolor='black', linewidth=2)
    ax2.add_patch(lb_cluster)
    ax2.text(3, 8.5, '⚖️ LB Cluster\n✅ HA with Keepalived', ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Web servers
    web_servers = [
        (1, 6, '🌐 Web Server 1\nNginx Only\nStatic Content'),
        (5, 6, '🌐 Web Server 2\nNginx Only\nStatic Content')
    ]
    
    for x, y, text in web_servers:
        web_box = FancyBboxPatch((x-0.8, y-0.5), 1.6, 1, boxstyle="round,pad=0.1",
                                 facecolor=colors['web'], edgecolor='black', linewidth=2)
        ax2.add_patch(web_box)
        ax2.text(x, y, text, ha='center', va='center', fontsize=8, fontweight='bold')
    
    # Application server
    app_box = FancyBboxPatch((2, 3.5), 2, 1, boxstyle="round,pad=0.1",
                             facecolor=colors['app'], edgecolor='black', linewidth=2)
    ax2.add_patch(app_box)
    ax2.text(3, 4, '🚀 App Server\nPHP-FPM Only\nBusiness Logic', ha='center', va='center', fontsize=8, fontweight='bold')
    
    # Database server
    db_box2 = FancyBboxPatch((2, 1), 2, 1, boxstyle="round,pad=0.1",
                             facecolor=colors['db'], edgecolor='black', linewidth=2)
    ax2.add_patch(db_box2)
    ax2.text(3, 1.5, '🗄️ Database Server\nMySQL Only\nData Storage', ha='center', va='center', fontsize=8, fontweight='bold')
    
    # Benefits list
    benefits_text = "Benefits:\n• Independent scaling\n• Optimized resources\n• Easy troubleshooting\n• No SPOF\n• Better security isolation\n• Flexible architecture"
    ax2.text(6.5, 4, benefits_text, ha='left', va='center', fontsize=10,
             bbox=dict(boxstyle="round,pad=0.5", facecolor='green', alpha=0.3))
    
    # Draw arrows showing separation
    ax2.annotate('', xy=(1, 5.5), xytext=(2.5, 7.8), 
                 arrowprops=dict(arrowstyle='->', lw=2, color='green'))
    ax2.annotate('', xy=(5, 5.5), xytext=(3.5, 7.8), 
                 arrowprops=dict(arrowstyle='->', lw=2, color='green'))
    ax2.annotate('', xy=(3, 4.8), xytext=(3, 5.5), 
                 arrowprops=dict(arrowstyle='->', lw=2, color='purple'))
    ax2.annotate('', xy=(3, 2.8), xytext=(3, 3.5), 
                 arrowprops=dict(arrowstyle='->', lw=2, color='brown'))
    
    ax2.set_xlim(0, 10)
    ax2.set_ylim(0, 10)
    ax2.set_aspect('equal')
    ax2.axis('off')
    
    plt.tight_layout()
    plt.savefig('component_separation_comparison.png', dpi=300, bbox_inches='tight')
    plt.show()

def create_load_balancer_clustering_diagram():
    """Create detailed load balancer clustering diagram"""
    fig, ax = plt.subplots(1, 1, figsize=(14, 10))
    
    colors = {
        'master': '#4CAF50',
        'backup': '#FF9800',
        'vip': '#FFD700',
        'keepalived': '#F44336',
        'web': '#9C27B0'
    }
    
    # Draw network diagram
    ax.text(7, 9.5, 'Load Balancer Clustering with Keepalived', ha='center', va='center', 
            fontsize=16, fontweight='bold')
    
    # Virtual IP cloud
    vip_circle = Circle((7, 8), 0.8, facecolor=colors['vip'], edgecolor='black', linewidth=3)
    ax.add_patch(vip_circle)
    ax.text(7, 8, 'Virtual IP\n8.8.8.8\n(Floating)', ha='center', va='center', fontsize=10, fontweight='bold')
    
    # Master Load Balancer
    master_box = FancyBboxPatch((2, 5.5), 3, 2, boxstyle="round,pad=0.2",
                                facecolor=colors['master'], edgecolor='black', linewidth=2)
    ax.add_patch(master_box)
    ax.text(3.5, 6.5, '🔧 Master LB\n10.0.0.10\n\n• HAproxy Active\n• Keepalived Master\n• Priority: 100\n• State: MASTER', 
            ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Backup Load Balancer
    backup_box = FancyBboxPatch((9, 5.5), 3, 2, boxstyle="round,pad=0.2",
                                facecolor=colors['backup'], edgecolor='black', linewidth=2)
    ax.add_patch(backup_box)
    ax.text(10.5, 6.5, '🔧 Backup LB\n10.0.0.11\n\n• HAproxy Standby\n• Keepalived Backup\n• Priority: 90\n• State: BACKUP', 
            ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Keepalived communication
    keepalived_line = ConnectionPatch((5, 6.5), (9, 6.5), "data", "data",
                                      arrowstyle="<->", shrinkA=5, shrinkB=5, 
                                      mutation_scale=20, fc=colors['keepalived'], lw=3)
    ax.add_artist(keepalived_line)
    ax.text(7, 7, 'Keepalived\nVRRP Protocol\nHealth Checks', ha='center', va='center', 
            fontsize=8, fontweight='bold', bbox=dict(boxstyle="round,pad=0.3", facecolor='white'))
    
    # VIP assignment arrows
    ax.annotate('', xy=(5.5, 7.5), xytext=(6.5, 8), 
                arrowprops=dict(arrowstyle='->', lw=3, color='green'))
    ax.text(5.8, 7.8, 'VIP\nOwnership', ha='center', va='center', fontsize=7, rotation=30)
    
    # Dotted line to backup (inactive)
    ax.plot([8.5, 10.5], [7.5, 6.8], ':', linewidth=3, color='gray')
    ax.text(9.5, 7.2, 'Standby\n(Inactive)', ha='center', va='center', fontsize=7, style='italic')
    
    # Web servers
    web_servers = [
        (2, 2, '🌐 Web Server 1\n10.0.0.20'),
        (6, 2, '🌐 Web Server 2\n10.0.0.21'),
        (10, 2, '🌐 Additional\nWeb Servers...')
    ]
    
    for x, y, text in web_servers:
        web_box = FancyBboxPatch((x-1, y-0.5), 2, 1, boxstyle="round,pad=0.1",
                                 facecolor=colors['web'], edgecolor='black', linewidth=1)
        ax.add_patch(web_box)
        ax.text(x, y, text, ha='center', va='center', fontsize=8, fontweight='bold')
        
        # Arrows from both LBs to web servers
        ax.annotate('', xy=(x, y+0.4), xytext=(3.5, 5.5), 
                    arrowprops=dict(arrowstyle='->', lw=1, color='green', alpha=0.7))
        ax.annotate('', xy=(x, y+0.4), xytext=(10.5, 5.5), 
                    arrowprops=dict(arrowstyle='->', lw=1, color='orange', alpha=0.5, linestyle='dashed'))
    
    # Failover scenario box
    failover_box = FancyBboxPatch((0.5, 0.2), 6, 1, boxstyle="round,pad=0.1",
                                  facecolor='yellow', alpha=0.3, edgecolor='red', linewidth=2)
    ax.add_patch(failover_box)
    ax.text(3.5, 0.7, '🚨 FAILOVER SCENARIO:\nMaster fails → Backup takes VIP → Traffic continues\nFailover time: < 3 seconds', 
            ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Configuration details box
    config_box = FancyBboxPatch((7.5, 0.2), 6, 1, boxstyle="round,pad=0.1",
                                facecolor='lightblue', alpha=0.3, edgecolor='blue', linewidth=2)
    ax.add_patch(config_box)
    ax.text(10.5, 0.7, '⚙️ CONFIGURATION:\n• Virtual Router ID: 51\n• Advertisement Interval: 1s\n• Authentication: Password', 
            ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Traffic flow indicators
    ax.text(1, 8.5, '📈 Normal Traffic Flow:\nUser → VIP (8.8.8.8) → Master LB → Web Servers', 
            ha='left', va='center', fontsize=9, 
            bbox=dict(boxstyle="round,pad=0.3", facecolor='lightgreen', alpha=0.7))
    
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 10)
    ax.set_aspect('equal')
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('load_balancer_clustering_diagram.png', dpi=300, bbox_inches='tight')
    plt.show()

def create_resource_optimization_diagram():
    """Create diagram showing resource optimization per component"""
    fig, ax = plt.subplots(1, 1, figsize=(14, 10))
    
    # Create resource allocation charts
    components = ['Load Balancer', 'Web Servers', 'App Server', 'Database']
    cpu_cores = [2, 4, 8, 8]
    ram_gb = [2, 4, 8, 16]
    storage_type = ['Standard', 'SSD', 'Standard', 'High-Perf SSD']
    
    # Color coding for components
    colors = ['#FF9800', '#9C27B0', '#E91E63', '#795548']
    
    # Create subplot layout
    x_positions = [2, 5, 8, 11]
    
    for i, (component, cpu, ram, storage, color) in enumerate(zip(components, cpu_cores, ram_gb, storage_type, colors)):
        x = x_positions[i]
        
        # Component box
        comp_box = FancyBboxPatch((x-1, 7), 2, 1.5, boxstyle="round,pad=0.1",
                                  facecolor=color, edgecolor='black', linewidth=2)
        ax.add_patch(comp_box)
        ax.text(x, 7.75, component, ha='center', va='center', fontsize=10, fontweight='bold')
        
        # CPU allocation bar
        cpu_bar = FancyBboxPatch((x-0.8, 5.5), 1.6 * (cpu/8), 0.4, boxstyle="round,pad=0.02",
                                 facecolor='red', alpha=0.7, edgecolor='black')
        ax.add_patch(cpu_bar)
        ax.text(x, 6, f'{cpu} Cores', ha='center', va='center', fontsize=8, fontweight='bold')
        
        # RAM allocation bar
        ram_bar = FancyBboxPatch((x-0.8, 4.5), 1.6 * (ram/16), 0.4, boxstyle="round,pad=0.02",
                                 facecolor='blue', alpha=0.7, edgecolor='black')
        ax.add_patch(ram_bar)
        ax.text(x, 5, f'{ram}GB RAM', ha='center', va='center', fontsize=8, fontweight='bold')
        
        # Storage type
        storage_box = FancyBboxPatch((x-0.8, 3.5), 1.6, 0.4, boxstyle="round,pad=0.02",
                                     facecolor='green', alpha=0.7, edgecolor='black')
        ax.add_patch(storage_box)
        ax.text(x, 3.7, storage, ha='center', va='center', fontsize=7, fontweight='bold')
        
        # Optimization focus
        focus_areas = [
            'Connection\nHandling',
            'Static File\nServing',
            'CPU Intensive\nProcessing', 
            'I/O & Memory\nOperations'
        ]
        
        focus_box = FancyBboxPatch((x-0.8, 2), 1.6, 1, boxstyle="round,pad=0.1",
                                   facecolor='yellow', alpha=0.5, edgecolor='black')
        ax.add_patch(focus_box)
        ax.text(x, 2.5, focus_areas[i], ha='center', va='center', fontsize=8, fontweight='bold')
    
    # Add titles and labels
    ax.text(6.5, 9.5, 'Resource Optimization per Component', ha='center', va='center', 
            fontsize=16, fontweight='bold')
    
    ax.text(1, 6, 'CPU:', ha='right', va='center', fontsize=10, fontweight='bold')
    ax.text(1, 5, 'RAM:', ha='right', va='center', fontsize=10, fontweight='bold')
    ax.text(1, 3.7, 'Storage:', ha='right', va='center', fontsize=10, fontweight='bold')
    ax.text(1, 2.5, 'Focus:', ha='right', va='center', fontsize=10, fontweight='bold')
    
    # Add scaling benefits
    benefits_text = """
    Scaling Benefits:
    
    🔧 Load Balancers: Scale for connection handling
    🌐 Web Servers: Scale for traffic volume  
    🚀 App Server: Scale for processing load
    🗄️ Database: Scale for data growth
    
    ✅ Independent scaling reduces costs
    ✅ Optimized resource allocation  
    ✅ Better performance per dollar
    """
    
    ax.text(13.5, 5, benefits_text, ha='left', va='center', fontsize=9,
            bbox=dict(boxstyle="round,pad=0.5", facecolor='lightgreen', alpha=0.7))
    
    # Add cost comparison
    cost_text = """
    Cost Comparison:
    
    Task 1 (Monolithic): $400/month
    • Over-provisioned servers
    • Resource waste
    
    Task 3 (Separated): $450/month  
    • Optimized allocation
    • Better performance
    • Higher availability
    
    ✅ Better ROI despite higher cost
    """
    
    ax.text(13.5, 1.5, cost_text, ha='left', va='center', fontsize=9,
            bbox=dict(boxstyle="round,pad=0.5", facecolor='lightblue', alpha=0.7))
    
    ax.set_xlim(0, 18)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('resource_optimization_diagram.png', dpi=300, bbox_inches='tight')
    plt.show()

def main():
    """Generate all Task 3 diagrams"""
    print("🎨 Generating Task 3: Scale Up Infrastructure Diagrams...")
    
    try:
        print("📊 Creating main scale up infrastructure diagram...")
        create_scale_up_infrastructure_diagram()
        
        print("🏗️ Creating component separation comparison...")
        create_component_separation_diagram()
        
        print("⚖️ Creating load balancer clustering diagram...")
        create_load_balancer_clustering_diagram()
        
        print("📈 Creating resource optimization diagram...")
        create_resource_optimization_diagram()
        
        print("✅ All Task 3 diagrams generated successfully!")
        print("\nGenerated files:")
        print("- scale_up_infrastructure_diagram.png")
        print("- component_separation_comparison.png")
        print("- load_balancer_clustering_diagram.png")
        print("- resource_optimization_diagram.png")
        
    except Exception as e:
        print(f"❌ Error generating diagrams: {e}")
        return False
    
    return True

if __name__ == "__main__":
    main()
