#!/bin/bash

# Configuration
EMAIL="nalawaderushi@gmail.com"  # Replace with your email address
LOG_FILE="/var/log/sys_health.log"

# Log Function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | sudo tee -a "$LOG_FILE" > /dev/null
}

check_disk() {
    echo "============================="
    echo "   Disk Usage"
    echo "============================="
    df -h
    log_message "Disk usage checked"
}

check_services() {
    echo "============================="
    echo "   Running Services"
    echo "============================="
    systemctl list-units --type=service --state=running | head -n 20
    log_message "Running services checked"
}

check_memory() {
    echo "============================="
    echo "   Memory Usage"
    echo "============================="
    free -h
    log_message "Memory usage checked"
}

check_cpu() {
    echo "============================="
    echo "   CPU Usage"
    echo "============================="
    top -bn1 | head -n 15
    echo ""
    echo "CPU Load Average:"
    uptime
    log_message "CPU usage checked"
}

send_report() {
    echo "Generating report..."
    REPORT=$(mktemp)
    {
        echo "System Health Report - $(date)"
        echo "Hostname: $(hostname)"
        echo "-----------------------------------"
        echo "DISK USAGE:"
        df -h
        echo ""
        echo "MEMORY USAGE:"
        free -h
        echo ""
        echo "CPU INFO:"
        uptime
        echo ""
        echo "RUNNING SERVICES (Top 20):"
        systemctl list-units --type=service --state=running | head -n 20
    } > "$REPORT"

    cat "$REPORT"
    mail -s "System Health Report - $(hostname) - $(date)" "$EMAIL" < "$REPORT"
    echo "Report sent to $EMAIL!"
    log_message "Email report sent"
    rm "$REPORT"
}

# For cron job --email option
if [ "$1" == "--email" ]; then
    send_report
    exit 0
fi

# Main Menu
while true; do
    clear
    echo "============================="
    echo " System Health Check Menu"
    echo "============================="
    echo "1. Check Disk Usage"
    echo "2. Monitor Running Services"
    echo "3. Assess Memory Usage"
    echo "4. Evaluate CPU Usage"
    echo "5. Send Comprehensive Report"
    echo "6. Exit"
    echo "============================="
    read -p "Enter your choice [1-6]: " choice

    case $choice in
        1) check_disk ;;
        2) check_services ;;
        3) check_memory ;;
        4) check_cpu ;;
        5) send_report ;;
        6) echo "Exiting... Thank you!"; exit 0 ;;
        *) echo "Invalid option! Please try again." ;;
    esac
    echo ""
    read -p "Press Enter to continue..."
done

