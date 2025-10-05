#!/usr/bin/env python3
"""
Diagram Generator for Secured and Monitored Web Infrastructure (Task 2)
Generates visual diagrams for infrastructure with firewalls, SSL, and monitoring
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, Circle
import numpy as np

# Set up the plotting style
plt.style.use('default')
plt.rcParams['figure.facecolor'] = 'white'
plt.rcParams['axes.facecolor'] = 'white'

def create_secured_infrastructure_diagram():
    """Create the main secured infrastructure diagram"""
    fig, ax = plt.subplots(1, 1, figsize=(16, 12))
    
    # Colors
    colors = {
        'user': '#4CAF50',
        'internet': '#2196F3', 
        'firewall': '#F44336',
        'load_balancer': '#FF9800',
        'web_server': '#9C27B0',
        'database': '#795548',
        'ssl': '#FFD700',
        'monitoring': '#00BCD4'
    }
    
    # Draw User
    user_box = FancyBboxPatch((1, 10), 2, 1, boxstyle="round,pad=0.1", 
                              facecolor=colors['user'], edgecolor='black', linewidth=2)
    ax.add_patch(user_box)
    ax.text(2, 10.5, '👤 User\n(HTTPS Client)', ha='center', va='center', fontsize=10, fontweight='bold')
    
    # Draw Internet/DNS
    internet_box = FancyBboxPatch((1, 8), 2, 1, boxstyle="round,pad=0.1",
                                  facecolor=colors['internet'], edgecolor='black', linewidth=2)
    ax.add_patch(internet_box)
    ax.text(2, 8.5, '🌐 Internet/DNS\nwww.foobar.com', ha='center', va='center', fontsize=10, fontweight='bold')
    
    # Draw Public Firewall (Firewall 1)
    firewall1_box = FancyBboxPatch((5, 8), 3, 1, boxstyle="round,pad=0.1",
                                   facecolor=colors['firewall'], edgecolor='black', linewidth=2)
    ax.add_patch(firewall1_box)
    ax.text(6.5, 8.5, '🔒 Firewall 1 (Public)\nDMZ Protection\nPorts: 80, 443, 8404', ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Draw Load Balancer with SSL
    lb_box = FancyBboxPatch((5, 6), 3, 1.5, boxstyle="round,pad=0.1",
                            facecolor=colors['load_balancer'], edgecolor='black', linewidth=2)
    ax.add_patch(lb_box)
    ax.text(6.5, 6.75, '⚖️ Load Balancer\nHAproxy + SSL\n🔐 SSL Certificate\n📊 Monitoring Agent', 
            ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Draw SSL Certificate symbol
    ssl_circle = Circle((7.5, 7.2), 0.2, facecolor=colors['ssl'], edgecolor='black', linewidth=2)
    ax.add_patch(ssl_circle)
    ax.text(7.5, 7.2, '🔐', ha='center', va='center', fontsize=12)
    
    # Draw Private Firewalls (Firewall 2 & 3)
    firewall2_box = FancyBboxPatch((1, 4), 2.5, 1, boxstyle="round,pad=0.1",
                                   facecolor=colors['firewall'], edgecolor='black', linewidth=2)
    ax.add_patch(firewall2_box)
    ax.text(2.25, 4.5, '🔒 Firewall 2\nPrivate Network\nWeb Server 1', ha='center', va='center', fontsize=8, fontweight='bold')
    
    firewall3_box = FancyBboxPatch((9.5, 4), 2.5, 1, boxstyle="round,pad=0.1",
                                   facecolor=colors['firewall'], edgecolor='black', linewidth=2)
    ax.add_patch(firewall3_box)
    ax.text(10.75, 4.5, '🔒 Firewall 3\nPrivate Network\nWeb Server 2', ha='center', va='center', fontsize=8, fontweight='bold')
    
    # Draw Web Servers
    web1_box = FancyBboxPatch((1, 2), 2.5, 1.5, boxstyle="round,pad=0.1",
                              facecolor=colors['web_server'], edgecolor='black', linewidth=2)
    ax.add_patch(web1_box)
    ax.text(2.25, 2.75, '🌐 Web Server 1\n10.0.0.2\nNginx + PHP-FPM\n📊 Monitoring Agent', 
            ha='center', va='center', fontsize=8, fontweight='bold')
    
    web2_box = FancyBboxPatch((9.5, 2), 2.5, 1.5, boxstyle="round,pad=0.1",
                              facecolor=colors['web_server'], edgecolor='black', linewidth=2)
    ax.add_patch(web2_box)
    ax.text(10.75, 2.75, '🌐 Web Server 2\n10.0.0.3\nNginx + PHP-FPM\n📊 Monitoring Agent', 
            ha='center', va='center', fontsize=8, fontweight='bold')
    
    # Draw Database Server
    db_box = FancyBboxPatch((5, 0.5), 3, 1.5, boxstyle="round,pad=0.1",
                            facecolor=colors['database'], edgecolor='black', linewidth=2)
    ax.add_patch(db_box)
    ax.text(6.5, 1.25, '🗄️ Database Server\n10.0.0.4\nMySQL Primary + Replica\n📊 Monitoring Agent', 
            ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Draw Monitoring symbols
    monitoring_positions = [(6, 6.3), (1.8, 2.3), (10.2, 2.3), (6.8, 0.8)]
    for pos in monitoring_positions:
        mon_circle = Circle(pos, 0.15, facecolor=colors['monitoring'], edgecolor='black', linewidth=1)
        ax.add_patch(mon_circle)
        ax.text(pos[0], pos[1], '📊', ha='center', va='center', fontsize=8)
    
    # Draw connections with arrows
    # User to Internet
    ax.annotate('', xy=(2, 8.8), xytext=(2, 9.7), 
                arrowprops=dict(arrowstyle='->', lw=2, color='green'))
    ax.text(2.5, 9.2, 'HTTPS Request', fontsize=8, rotation=90, va='center')
    
    # Internet to Public Firewall
    ax.annotate('', xy=(5, 8.5), xytext=(3, 8.5), 
                arrowprops=dict(arrowstyle='->', lw=2, color='blue'))
    ax.text(4, 8.8, 'Filtered Traffic', fontsize=8, ha='center')
    
    # Public Firewall to Load Balancer
    ax.annotate('', xy=(6.5, 7.3), xytext=(6.5, 7.8), 
                arrowprops=dict(arrowstyle='->', lw=2, color='orange'))
    
    # Load Balancer to Private Firewalls
    ax.annotate('', xy=(2.25, 4.8), xytext=(5.5, 6.2), 
                arrowprops=dict(arrowstyle='->', lw=2, color='purple'))
    ax.annotate('', xy=(10.75, 4.8), xytext=(7.5, 6.2), 
                arrowprops=dict(arrowstyle='->', lw=2, color='purple'))
    
    # Private Firewalls to Web Servers
    ax.annotate('', xy=(2.25, 3.3), xytext=(2.25, 4.2), 
                arrowprops=dict(arrowstyle='->', lw=2, color='purple'))
    ax.annotate('', xy=(10.75, 3.3), xytext=(10.75, 4.2), 
                arrowprops=dict(arrowstyle='->', lw=2, color='purple'))
    
    # Web Servers to Database
    ax.annotate('', xy=(5.2, 1.8), xytext=(3.5, 2.2), 
                arrowprops=dict(arrowstyle='->', lw=2, color='brown'))
    ax.annotate('', xy=(7.8, 1.8), xytext=(9.5, 2.2), 
                arrowprops=dict(arrowstyle='->', lw=2, color='brown'))
    
    # Add title and labels
    ax.set_title('Task 2: Secured and Monitored Web Infrastructure\nThree-Server Architecture with Firewalls, SSL, and Monitoring', 
                 fontsize=16, fontweight='bold', pad=20)
    
    # Add legend
    legend_elements = [
        patches.Rectangle((0, 0), 1, 1, facecolor=colors['firewall'], label='🔒 Firewalls (3)'),
        patches.Rectangle((0, 0), 1, 1, facecolor=colors['ssl'], label='🔐 SSL Certificate'),
        patches.Rectangle((0, 0), 1, 1, facecolor=colors['monitoring'], label='📊 Monitoring Agents (3)'),
        patches.Rectangle((0, 0), 1, 1, facecolor=colors['load_balancer'], label='⚖️ Load Balancer'),
        patches.Rectangle((0, 0), 1, 1, facecolor=colors['web_server'], label='🌐 Web Servers'),
        patches.Rectangle((0, 0), 1, 1, facecolor=colors['database'], label='🗄️ Database Server')
    ]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=9)
    
    # Set axis properties
    ax.set_xlim(0, 13)
    ax.set_ylim(0, 12)
    ax.set_aspect('equal')
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('secured_infrastructure_diagram.png', dpi=300, bbox_inches='tight')
    plt.show()

def create_security_features_diagram():
    """Create diagram showing security features in detail"""
    fig, ax = plt.subplots(1, 1, figsize=(14, 10))
    
    # Security layers diagram
    colors = {
        'public': '#F44336',
        'dmz': '#FF9800', 
        'private': '#4CAF50',
        'database': '#2196F3',
        'ssl': '#FFD700'
    }
    
    # Draw security zones
    public_zone = FancyBboxPatch((1, 7), 11, 2, boxstyle="round,pad=0.2",
                                 facecolor=colors['public'], alpha=0.3, edgecolor='red', linewidth=2)
    ax.add_patch(public_zone)
    ax.text(6.5, 8.5, '🌍 PUBLIC ZONE - Internet Facing', ha='center', va='center', fontsize=14, fontweight='bold')
    
    dmz_zone = FancyBboxPatch((1, 5), 11, 1.5, boxstyle="round,pad=0.2",
                              facecolor=colors['dmz'], alpha=0.3, edgecolor='orange', linewidth=2)
    ax.add_patch(dmz_zone)
    ax.text(6.5, 6.2, '🛡️ DMZ ZONE - Load Balancer + SSL Termination', ha='center', va='center', fontsize=12, fontweight='bold')
    
    private_zone = FancyBboxPatch((1, 2.5), 11, 2, boxstyle="round,pad=0.2",
                                  facecolor=colors['private'], alpha=0.3, edgecolor='green', linewidth=2)
    ax.add_patch(private_zone)
    ax.text(6.5, 4, '🔒 PRIVATE ZONE - Web Servers', ha='center', va='center', fontsize=12, fontweight='bold')
    
    database_zone = FancyBboxPatch((1, 0.5), 11, 1.5, boxstyle="round,pad=0.2",
                                   facecolor=colors['database'], alpha=0.3, edgecolor='blue', linewidth=2)
    ax.add_patch(database_zone)
    ax.text(6.5, 1.5, '🗄️ DATABASE ZONE - MySQL Servers', ha='center', va='center', fontsize=12, fontweight='bold')
    
    # Add security controls
    security_controls = [
        (3, 8, '🔒 Firewall 1\nPublic Access Control'),
        (10, 8, '🔐 SSL/TLS\nEncryption'),
        (3, 6, '⚖️ Load Balancer\nTraffic Distribution'),
        (10, 6, '📊 Monitoring\nSumo Logic'),
        (3, 3.5, '🔒 Firewall 2\nWeb Server 1'),
        (10, 3.5, '🔒 Firewall 3\nWeb Server 2'),
        (6.5, 1, '🛡️ Database Firewall\nMySQL Access Control')
    ]
    
    for x, y, text in security_controls:
        control_box = FancyBboxPatch((x-0.8, y-0.3), 1.6, 0.6, boxstyle="round,pad=0.1",
                                     facecolor='white', edgecolor='black', linewidth=1)
        ax.add_patch(control_box)
        ax.text(x, y, text, ha='center', va='center', fontsize=8, fontweight='bold')
    
    ax.set_title('Security Layers and Controls\nDefense in Depth Architecture', 
                 fontsize=16, fontweight='bold', pad=20)
    
    ax.set_xlim(0, 13)
    ax.set_ylim(0, 10)
    ax.set_aspect('equal')
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('security_layers_diagram.png', dpi=300, bbox_inches='tight')
    plt.show()

def create_monitoring_flow_diagram():
    """Create diagram showing monitoring data flow"""
    fig, ax = plt.subplots(1, 1, figsize=(14, 10))
    
    colors = {
        'server': '#4CAF50',
        'agent': '#00BCD4',
        'cloud': '#2196F3',
        'dashboard': '#FF9800'
    }
    
    # Draw servers with monitoring agents
    servers = [
        (2, 7, 'Load Balancer\n📊 Sumo Agent\nHAproxy Logs'),
        (2, 5, 'Web Server 1\n📊 Sumo Agent\nNginx Logs'),
        (2, 3, 'Web Server 2\n📊 Sumo Agent\nNginx + PHP Logs'),
        (2, 1, 'Database Server\n📊 Sumo Agent\nMySQL Logs')
    ]
    
    for x, y, text in servers:
        server_box = FancyBboxPatch((x-1, y-0.5), 2, 1, boxstyle="round,pad=0.1",
                                    facecolor=colors['server'], edgecolor='black', linewidth=2)
        ax.add_patch(server_box)
        ax.text(x, y, text, ha='center', va='center', fontsize=9, fontweight='bold')
        
        # Add monitoring agent symbol
        agent_circle = Circle((x+0.7, y+0.3), 0.15, facecolor=colors['agent'], edgecolor='black')
        ax.add_patch(agent_circle)
        ax.text(x+0.7, y+0.3, '📊', ha='center', va='center', fontsize=8)
    
    # Draw data collection flow
    collection_box = FancyBboxPatch((5, 3.5), 3, 2, boxstyle="round,pad=0.2",
                                    facecolor=colors['agent'], edgecolor='black', linewidth=2)
    ax.add_patch(collection_box)
    ax.text(6.5, 4.5, '📡 Data Collection\n\n• Log Files Parsing\n• System Metrics\n• Performance Data\n• Security Events', 
            ha='center', va='center', fontsize=10, fontweight='bold')
    
    # Draw Sumo Logic Cloud
    cloud_box = FancyBboxPatch((10, 3.5), 3, 2, boxstyle="round,pad=0.2",
                               facecolor=colors['cloud'], edgecolor='black', linewidth=2)
    ax.add_patch(cloud_box)
    ax.text(11.5, 4.5, '☁️ Sumo Logic Cloud\n\n• Data Processing\n• Real-time Analysis\n• Alert Generation\n• Data Storage', 
            ha='center', va='center', fontsize=10, fontweight='bold')
    
    # Draw dashboards and alerts
    dashboard_positions = [
        (10, 7, '📊 Performance\nDashboard'),
        (12, 7, '🚨 Security\nAlerts'),
        (10, 1, '📈 QPS\nMonitoring'),
        (12, 1, '🔍 Log\nAnalysis')
    ]
    
    for x, y, text in dashboard_positions:
        dash_box = FancyBboxPatch((x-0.7, y-0.4), 1.4, 0.8, boxstyle="round,pad=0.1",
                                  facecolor=colors['dashboard'], edgecolor='black', linewidth=1)
        ax.add_patch(dash_box)
        ax.text(x, y, text, ha='center', va='center', fontsize=8, fontweight='bold')
    
    # Draw arrows for data flow
    # Servers to Collection
    for y in [7, 5, 3, 1]:
        ax.annotate('', xy=(5, 4.5), xytext=(3, y), 
                    arrowprops=dict(arrowstyle='->', lw=2, color='darkgreen'))
    
    # Collection to Cloud
    ax.annotate('', xy=(10, 4.5), xytext=(8, 4.5), 
                arrowprops=dict(arrowstyle='->', lw=3, color='blue'))
    ax.text(9, 5, 'HTTPS\nSecure Transfer', ha='center', va='center', fontsize=8)
    
    # Cloud to Dashboards
    for x, y, _ in dashboard_positions:
        ax.annotate('', xy=(x, y), xytext=(11.5, 4.5), 
                    arrowprops=dict(arrowstyle='->', lw=1, color='orange'))
    
    ax.set_title('Monitoring and Data Flow Architecture\nSumo Logic Integration', 
                 fontsize=16, fontweight='bold', pad=20)
    
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 9)
    ax.set_aspect('equal')
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('monitoring_flow_diagram.png', dpi=300, bbox_inches='tight')
    plt.show()

def create_ssl_encryption_diagram():
    """Create diagram showing SSL encryption flow"""
    fig, ax = plt.subplots(1, 1, figsize=(14, 8))
    
    colors = {
        'client': '#4CAF50',
        'encrypted': '#FFD700',
        'decrypted': '#FF9800',
        'server': '#2196F3'
    }
    
    # Draw SSL encryption flow
    client_box = FancyBboxPatch((1, 5), 2, 1.5, boxstyle="round,pad=0.1",
                                facecolor=colors['client'], edgecolor='black', linewidth=2)
    ax.add_patch(client_box)
    ax.text(2, 5.75, '👤 Client\nWeb Browser', ha='center', va='center', fontsize=10, fontweight='bold')
    
    # Encrypted path
    encrypted_path = FancyBboxPatch((5, 6), 4, 1, boxstyle="round,pad=0.1",
                                    facecolor=colors['encrypted'], edgecolor='black', linewidth=2)
    ax.add_patch(encrypted_path)
    ax.text(7, 6.5, '🔐 ENCRYPTED CHANNEL (HTTPS)\nTLS 1.3 Encryption', ha='center', va='center', fontsize=10, fontweight='bold')
    
    # Load balancer SSL termination
    lb_box = FancyBboxPatch((11, 5), 2.5, 1.5, boxstyle="round,pad=0.1",
                            facecolor=colors['decrypted'], edgecolor='black', linewidth=2)
    ax.add_patch(lb_box)
    ax.text(12.25, 5.75, '⚖️ Load Balancer\nSSL Termination\n🔓 Decryption', ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Internal path
    internal_path = FancyBboxPatch((5, 3), 4, 1, boxstyle="round,pad=0.1",
                                   facecolor=colors['decrypted'], edgecolor='black', linewidth=2)
    ax.add_patch(internal_path)
    ax.text(7, 3.5, '⚠️ INTERNAL CHANNEL (HTTP)\nUnencrypted - Security Risk', ha='center', va='center', fontsize=10, fontweight='bold')
    
    # Web servers
    web1_box = FancyBboxPatch((1, 1), 2, 1, boxstyle="round,pad=0.1",
                              facecolor=colors['server'], edgecolor='black', linewidth=2)
    ax.add_patch(web1_box)
    ax.text(2, 1.5, '🌐 Web Server 1\n10.0.0.2', ha='center', va='center', fontsize=9, fontweight='bold')
    
    web2_box = FancyBboxPatch((11, 1), 2, 1, boxstyle="round,pad=0.1",
                              facecolor=colors['server'], edgecolor='black', linewidth=2)
    ax.add_patch(web2_box)
    ax.text(12, 1.5, '🌐 Web Server 2\n10.0.0.3', ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Draw arrows
    # Client to encrypted channel
    ax.annotate('', xy=(5, 6.5), xytext=(3, 5.75), 
                arrowprops=dict(arrowstyle='->', lw=3, color='green'))
    ax.text(4, 6.3, 'HTTPS\nRequest', ha='center', va='center', fontsize=8, rotation=15)
    
    # Encrypted channel to load balancer
    ax.annotate('', xy=(11, 6), xytext=(9, 6.5), 
                arrowprops=dict(arrowstyle='->', lw=3, color='gold'))
    
    # Load balancer to internal channel
    ax.annotate('', xy=(9, 3.5), xytext=(11.5, 5.2), 
                arrowprops=dict(arrowstyle='->', lw=2, color='orange'))
    
    # Internal channel to web servers
    ax.annotate('', xy=(3, 1.8), xytext=(5.5, 3.2), 
                arrowprops=dict(arrowstyle='->', lw=2, color='orange'))
    ax.annotate('', xy=(11, 1.8), xytext=(8.5, 3.2), 
                arrowprops=dict(arrowstyle='->', lw=2, color='orange'))
    
    # Add security issue callout
    issue_box = FancyBboxPatch((6, 0.2), 2, 0.6, boxstyle="round,pad=0.1",
                               facecolor='red', alpha=0.3, edgecolor='red', linewidth=2)
    ax.add_patch(issue_box)
    ax.text(7, 0.5, '⚠️ SECURITY ISSUE:\nSSL Termination Risk', ha='center', va='center', fontsize=8, fontweight='bold')
    
    ax.set_title('SSL/TLS Encryption Flow and Security Considerations\nTask 2: HTTPS Implementation', 
                 fontsize=16, fontweight='bold', pad=20)
    
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 8)
    ax.set_aspect('equal')
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('ssl_encryption_diagram.png', dpi=300, bbox_inches='tight')
    plt.show()

def main():
    """Generate all Task 2 diagrams"""
    print("🎨 Generating Task 2: Secured and Monitored Infrastructure Diagrams...")
    
    try:
        print("📊 Creating main secured infrastructure diagram...")
        create_secured_infrastructure_diagram()
        
        print("🔒 Creating security layers diagram...")
        create_security_features_diagram()
        
        print("📡 Creating monitoring flow diagram...")
        create_monitoring_flow_diagram()
        
        print("🔐 Creating SSL encryption diagram...")
        create_ssl_encryption_diagram()
        
        print("✅ All Task 2 diagrams generated successfully!")
        print("\nGenerated files:")
        print("- secured_infrastructure_diagram.png")
        print("- security_layers_diagram.png") 
        print("- monitoring_flow_diagram.png")
        print("- ssl_encryption_diagram.png")
        
    except Exception as e:
        print(f"❌ Error generating diagrams: {e}")
        return False
    
    return True

if __name__ == "__main__":
    main()
