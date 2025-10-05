#!/usr/bin/env python3
"""
Simple Web Stack Infrastructure Diagram Generator
This script generates a visual representation of the simple web stack infrastructure.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch
import numpy as np

def create_infrastructure_diagram():
    """Create a visual diagram of the simple web stack infrastructure."""
    
    # Create figure and axis
    fig, ax = plt.subplots(1, 1, figsize=(12, 10))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 12)
    ax.axis('off')
    
    # Title
    ax.text(5, 11.5, 'Simple Web Stack Infrastructure', 
            fontsize=16, fontweight='bold', ha='center')
    ax.text(5, 11, 'www.foobar.com (8.8.8.8)', 
            fontsize=12, ha='center', style='italic')
    
    # User's Computer
    user_box = FancyBboxPatch((0.5, 9), 2, 1, 
                              boxstyle="round,pad=0.1", 
                              facecolor='lightblue', 
                              edgecolor='blue', linewidth=2)
    ax.add_patch(user_box)
    ax.text(1.5, 9.5, "User's Computer", fontsize=10, ha='center', fontweight='bold')
    
    # Internet/DNS Cloud
    dns_box = FancyBboxPatch((4, 9), 2, 1, 
                             boxstyle="round,pad=0.1", 
                             facecolor='lightgray', 
                             edgecolor='gray', linewidth=2)
    ax.add_patch(dns_box)
    ax.text(5, 9.5, 'DNS/Internet', fontsize=10, ha='center', fontweight='bold')
    ax.text(5, 9.2, 'www.foobar.com', fontsize=8, ha='center')
    ax.text(5, 9, '→ 8.8.8.8', fontsize=8, ha='center')
    
    # Main Server Box
    server_box = FancyBboxPatch((3, 2), 4, 6, 
                                boxstyle="round,pad=0.1", 
                                facecolor='lightyellow', 
                                edgecolor='orange', linewidth=3)
    ax.add_patch(server_box)
    ax.text(5, 7.5, 'Server (8.8.8.8)', fontsize=12, ha='center', fontweight='bold')
    
    # Nginx Web Server
    nginx_box = FancyBboxPatch((3.2, 6.5), 3.6, 0.8, 
                               boxstyle="round,pad=0.05", 
                               facecolor='lightgreen', 
                               edgecolor='green', linewidth=2)
    ax.add_patch(nginx_box)
    ax.text(5, 6.9, 'Nginx Web Server', fontsize=10, ha='center', fontweight='bold')
    ax.text(5, 6.6, '(Port 80/443)', fontsize=8, ha='center')
    
    # Application Server
    app_box = FancyBboxPatch((3.2, 5.5), 3.6, 0.8, 
                             boxstyle="round,pad=0.05", 
                             facecolor='lightcoral', 
                             edgecolor='red', linewidth=2)
    ax.add_patch(app_box)
    ax.text(5, 5.9, 'Application Server', fontsize=10, ha='center', fontweight='bold')
    ax.text(5, 5.6, '(PHP/Python/Node.js)', fontsize=8, ha='center')
    
    # Application Files
    files_box = FancyBboxPatch((3.2, 4.5), 3.6, 0.8, 
                               boxstyle="round,pad=0.05", 
                               facecolor='lightsalmon', 
                               edgecolor='darkorange', linewidth=2)
    ax.add_patch(files_box)
    ax.text(5, 4.9, 'Application Files', fontsize=10, ha='center', fontweight='bold')
    ax.text(5, 4.6, '(Code Base)', fontsize=8, ha='center')
    
    # MySQL Database
    db_box = FancyBboxPatch((3.2, 3.5), 3.6, 0.8, 
                            boxstyle="round,pad=0.05", 
                            facecolor='lightsteelblue', 
                            edgecolor='steelblue', linewidth=2)
    ax.add_patch(db_box)
    ax.text(5, 3.9, 'MySQL Database', fontsize=10, ha='center', fontweight='bold')
    ax.text(5, 3.6, '(Port 3306)', fontsize=8, ha='center')
    
    # Arrows for request flow
    # User to DNS
    arrow1 = ConnectionPatch((2.5, 9.5), (4, 9.5), "data", "data",
                            arrowstyle="-|>", shrinkA=5, shrinkB=5, 
                            mutation_scale=20, fc="blue", alpha=0.6)
    ax.add_artist(arrow1)
    ax.text(3.25, 9.7, 'DNS Query', fontsize=8, ha='center', color='blue')
    
    # DNS to Server
    arrow2 = ConnectionPatch((5, 9), (5, 8), "data", "data",
                            arrowstyle="-|>", shrinkA=5, shrinkB=5, 
                            mutation_scale=20, fc="green", alpha=0.6)
    ax.add_artist(arrow2)
    ax.text(5.8, 8.5, 'HTTP Request', fontsize=8, ha='center', color='green')
    
    # Internal server arrows
    # Nginx to App Server
    arrow3 = ConnectionPatch((5, 6.5), (5, 6.3), "data", "data",
                            arrowstyle="-|>", shrinkA=2, shrinkB=2, 
                            mutation_scale=15, fc="red", alpha=0.8)
    ax.add_artist(arrow3)
    
    # App Server to Files
    arrow4 = ConnectionPatch((5, 5.5), (5, 5.3), "data", "data",
                            arrowstyle="-|>", shrinkA=2, shrinkB=2, 
                            mutation_scale=15, fc="red", alpha=0.8)
    ax.add_artist(arrow4)
    
    # App Server to Database
    arrow5 = ConnectionPatch((5, 4.5), (5, 4.3), "data", "data",
                            arrowstyle="-|>", shrinkA=2, shrinkB=2, 
                            mutation_scale=15, fc="red", alpha=0.8)
    ax.add_artist(arrow5)
    
    # Add protocol labels
    ax.text(8, 9, 'Protocols:', fontsize=10, fontweight='bold')
    ax.text(8, 8.7, '• HTTP/HTTPS', fontsize=9)
    ax.text(8, 8.5, '• TCP/IP', fontsize=9)
    ax.text(8, 8.3, '• DNS', fontsize=9)
    
    # Add issues box
    issues_box = FancyBboxPatch((0.5, 0.5), 9, 1.5, 
                                boxstyle="round,pad=0.1", 
                                facecolor='mistyrose', 
                                edgecolor='red', linewidth=2)
    ax.add_patch(issues_box)
    ax.text(5, 1.7, 'Infrastructure Issues', fontsize=12, ha='center', fontweight='bold', color='red')
    ax.text(1, 1.4, '• SPOF: Single server failure brings down entire system', fontsize=9)
    ax.text(1, 1.2, '• Downtime: Maintenance requires service interruption', fontsize=9)
    ax.text(1, 1.0, '• Scalability: Cannot handle high traffic loads', fontsize=9)
    ax.text(1, 0.8, '• No redundancy or failover capabilities', fontsize=9)
    
    plt.tight_layout()
    return fig

def create_request_flow_diagram():
    """Create a detailed request flow diagram."""
    
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 8)
    ax.axis('off')
    
    # Title
    ax.text(5, 7.5, 'Request Flow Process', 
            fontsize=16, fontweight='bold', ha='center')
    
    # Steps
    steps = [
        "1. User enters www.foobar.com",
        "2. DNS resolves to 8.8.8.8",
        "3. HTTP request sent to server",
        "4. Nginx receives request",
        "5. Nginx forwards to app server",
        "6. App server queries database",
        "7. Response generated",
        "8. Response sent to user"
    ]
    
    colors = ['lightblue', 'lightgreen', 'lightyellow', 'lightcoral', 
              'lightpink', 'lightgray', 'lightsalmon', 'lightsteelblue']
    
    y_positions = np.linspace(6.5, 1, len(steps))
    
    for i, (step, color, y_pos) in enumerate(zip(steps, colors, y_positions)):
        # Step box
        step_box = FancyBboxPatch((0.5, y_pos-0.2), 9, 0.4, 
                                  boxstyle="round,pad=0.05", 
                                  facecolor=color, 
                                  edgecolor='gray', linewidth=1)
        ax.add_patch(step_box)
        ax.text(5, y_pos, step, fontsize=11, ha='center', fontweight='bold')
        
        # Arrow to next step
        if i < len(steps) - 1:
            arrow = ConnectionPatch((5, y_pos-0.2), (5, y_positions[i+1]+0.2), 
                                   "data", "data",
                                   arrowstyle="-|>", shrinkA=2, shrinkB=2, 
                                   mutation_scale=15, fc="black", alpha=0.7)
            ax.add_artist(arrow)
    
    plt.tight_layout()
    return fig

if __name__ == "__main__":
    # Create and save the infrastructure diagram
    fig1 = create_infrastructure_diagram()
    plt.figure(fig1.number)
    plt.savefig('simple_web_stack_diagram.png', dpi=300, bbox_inches='tight')
    print("Infrastructure diagram saved as 'simple_web_stack_diagram.png'")
    
    # Create and save the request flow diagram
    fig2 = create_request_flow_diagram()
    plt.figure(fig2.number)
    plt.savefig('request_flow_diagram.png', dpi=300, bbox_inches='tight')
    print("Request flow diagram saved as 'request_flow_diagram.png'")
    
    plt.show()
