#!/bin/bash

LOG_FILE="/var/log/devopsfetch.log"

if [ ! -f "$LOG_FILE" ]; then
    sudo touch "$LOG_FILE"
    sudo chmod 644 "$LOG_FILE"
fi

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG_FILE"
}

display_active_ports() {
    sudo netstat -tulpn | grep LISTEN
}

get_port_info() {
    ss -tuln sport = ":$1"
}

list_docker_images() {
    docker images
}

list_docker_containers() {
    docker ps
}

get_container_info() {
    docker inspect "$1"
}

display_nginx_domains() {
   sudo nginx -T | grep "server_name"
}

display_nginx_domain_inf0() {
    grep -A 10 -B 10 "server_name $1" /etc/nginx/sites-available/*
}

list_user() {
    awk -F':' '{ print $1}' /etc/passwd
}

display_user_last_log_in_time() {
   lastlog
}


fetch_user_info() {
    grep "^$1:" /etc/passwd
}

display_time_range_info() {
    echo "Activities within $1:"
    journalctl --since "$1"
}


display_help_options() {
    echo "Usage: $0 [options]
Options:
    -p, --port [PORT]       Display active ports and services or specific port info
    -d, --docker [NAME]     Display Docker images and containers or specific container info
    -n, --nginx [DOMAIN]    Display Nginx domains and ports or specific domain info
    -u, --users [USERNAME]  List users and their last login times or specific user info
    -t, --time              Specify a time range (Not Implemented)
    -m, --monitor           Enable continuous monitoring mode
    -h, --help              Show this help message"
}

monitor() {
    while true; do
        log "Monitoring system activities..."
        log "Active Ports:"
        get_active_ports >> "$LOG_FILE"
        log "Docker Containers:"
        list_docker_containers >> "$LOG_FILE"
        log "Users and Last Logins:"
        list_users >> "$LOG_FILE"
        sleep 60
    done
}

main() {
    if [[ $# -eq 0 ]]; then
      display_help_options
      exit 1
    fi

    while [[ $# -gt 0 ]]; do
        case "$1" in 
            -p|--port)
                if [[ -z "$2" || "$2" == -* ]]; then
                 display_active_ports
                else
                    get_port_info "$2"
                    shift
                fi 
                ;;
            -d|--docker)
                if [[ -z "$2" || "$2" == -* ]]; then
                    list_docker_images
                    list_docker_containers
                else
                    get_container_info "$2"
                    shift
                fi
                ;;  

            -n|--nginx)
                if [[ -z "$2" || "$2" == -* ]]; then
                    display_nginx_domains
                else
                    display_nginx_domain_inf0 "$2"
                    shift
                fi
                ;;  
            -u|--users)
                if [[ -z "$2" || "$2" == -* ]]; then
                    list_users
                    display_user_last_log_in_time
                else
                    get_user_info "$2"
                    get_user_login_times "$2"
                    shift
                fi
                ;;
            -t|--time)
                display_time_range_info
                ;;
            -m|--monitor)
                monitor
                ;;
            -h|--help)
                show_help
                ;;
            *)
                echo "Invalid option: $1"
                show_help
                exit 1
                ;;                      
        esac 
        shift    
    done                    
}

main "$@"