#!/bin/bash

# Portfolio Docker Build Script
# Author: Sourav Patel
# Description: Build and deploy portfolio using Docker

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="sourav-portfolio"
DOCKERHUB_USER="aroundarmor"
DOCKERHUB_REPO="portfolio"
CONTAINER_NAME="portfolio-container"
PORT="8080"
COMPOSE_FILE="docker-compose.yml"
TAG="${1:-latest}"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    log_success "Docker is running"
}

# Check if curl is available
check_curl() {
    if ! command -v curl > /dev/null 2>&1; then
        log_warning "curl not found. Health checks will be skipped."
        return 1
    fi
    return 0
}

# Build Docker image
build_image() {
    log_info "Building Docker image: $IMAGE_NAME"
    
    # Check if we're in the right directory
    if [ ! -f "Dockerfile" ]; then
        log_error "Dockerfile not found. Please run this script from docker-package directory."
        exit 1
    fi
    
    # Check if docs directory exists in parent directory
    if [ ! -d "../docs" ]; then
        log_error "docs directory not found in parent directory."
        exit 1
    fi
    
    # Build the image from parent directory
    log_info "Building from parent directory with correct context..."
    docker build -f docker-package/Dockerfile -t $IMAGE_NAME ..
    
    if [ $? -eq 0 ]; then
        log_success "Docker image built successfully"
    else
        log_error "Failed to build Docker image"
        exit 1
    fi
}

# Run container
run_container() {
    log_info "Starting container: $CONTAINER_NAME"
    
    # Stop and remove existing container if it exists
    if docker ps -a --format 'table {{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        log_warning "Stopping existing container"
        docker stop $CONTAINER_NAME > /dev/null 2>&1 || true
        docker rm $CONTAINER_NAME > /dev/null 2>&1 || true
    fi
    
    # Run new container
    docker run -d \
        --name $CONTAINER_NAME \
        -p $PORT:8080 \
        --restart unless-stopped \
        $IMAGE_NAME
    
    if [ $? -eq 0 ]; then
        log_success "Container started successfully"
        log_info "Portfolio is available at: http://localhost:$PORT"
    else
        log_error "Failed to start container"
        exit 1
    fi
}

# Health check
health_check() {
    log_info "Performing health check..."
    
    # Wait for container to start
    sleep 5
    
    # Check if container is running
    if ! docker ps --format 'table {{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        log_error "Container is not running"
        docker logs $CONTAINER_NAME
        exit 1
    fi
    
    # Check if curl is available for health check
    if ! check_curl; then
        log_warning "Skipping HTTP health check (curl not available)"
        log_info "Container is running. You can manually test at http://localhost:$PORT"
        return 0
    fi
    
    # Check if application is responding
    for i in {1..10}; do
        if curl -f http://localhost:$PORT/health > /dev/null 2>&1; then
            log_success "Health check passed"
            return 0
        fi
        log_info "Waiting for application to start... ($i/10)"
        sleep 2
    done
    
    log_error "Health check failed"
    docker logs $CONTAINER_NAME
    exit 1
}

# Show logs
show_logs() {
    log_info "Showing container logs..."
    docker logs -f $CONTAINER_NAME
}

# Stop container
stop_container() {
    log_info "Stopping container: $CONTAINER_NAME"
    docker stop $CONTAINER_NAME > /dev/null 2>&1 || true
    docker rm $CONTAINER_NAME > /dev/null 2>&1 || true
    log_success "Container stopped and removed"
}

# Clean up
cleanup() {
    log_info "Cleaning up Docker resources..."
    docker system prune -f
    docker volume prune -f
    log_success "Cleanup completed"
}

# Test portfolio URL
test_portfolio() {
    log_info "Testing portfolio URL..."
    
    if ! check_curl; then
        log_warning "Cannot test URL (curl not available)"
        log_info "Portfolio should be available at: http://localhost:$PORT"
        return 0
    fi
    
    if curl -f http://localhost:$PORT/ > /dev/null 2>&1; then
        log_success "Portfolio is accessible at http://localhost:$PORT"
    else
        log_warning "Portfolio might not be accessible yet"
        log_info "Try accessing http://localhost:$PORT manually"
    fi
}

# Get tag from user input
get_tag_input() {
    local default_tag="${1:-latest}"
    
    echo ""
    echo -e "${YELLOW}Enter tag for Docker Hub (press Enter for '$default_tag'): ${NC}\c"
    read user_input
    
    if [ -z "$user_input" ]; then
        echo "$default_tag"
    else
        echo "$user_input"
    fi
}

# Push to Docker Hub
push_to_dockerhub() {
    local tag_name="${1:-$TAG}"
    
    # If no tag provided, ask user for input
    if [ "$tag_name" = "latest" ]; then
        tag_name=$(get_tag_input "latest")
    fi
    
    log_info "Pushing image to Docker Hub with tag: $tag_name"
    
    # Check if user is logged in to Docker Hub
    if ! docker info | grep -q "Username"; then
        log_warning "Not logged in to Docker Hub. Please run: docker login"
        log_info "You can login with: docker login -u $DOCKERHUB_USER"
        return 1
    fi
    
    # Create Docker Hub image name
    local dockerhub_image="${DOCKERHUB_USER}/${DOCKERHUB_REPO}:${tag_name}"
    
    # Tag the local image for Docker Hub
    log_info "Tagging image as: $dockerhub_image"
    docker tag $IMAGE_NAME $dockerhub_image
    
    if [ $? -eq 0 ]; then
        # Push to Docker Hub
        log_info "Pushing to Docker Hub..."
        docker push $dockerhub_image
        
        if [ $? -eq 0 ]; then
            log_success "Successfully pushed to Docker Hub: $dockerhub_image"
            log_info "You can now pull this image with: docker pull $dockerhub_image"
        else
            log_error "Failed to push to Docker Hub"
            return 1
        fi
    else
        log_error "Failed to tag image"
        return 1
    fi
}

# Build and push to Docker Hub
build_and_push() {
    local tag_name="${1:-$TAG}"
    
    # If no tag provided, ask user for input
    if [ "$tag_name" = "latest" ]; then
        tag_name=$(get_tag_input "latest")
    fi
    
    log_info "Building and pushing to Docker Hub with tag: $tag_name"
    
    # Build the image
    build_image
    
    if [ $? -eq 0 ]; then
        # Push to Docker Hub
        push_to_dockerhub $tag_name
    else
        log_error "Build failed, skipping push"
        return 1
    fi
}

# Docker Compose functions
compose_up() {
    log_info "Starting services with Docker Compose..."
    
    # Check if docker-compose.yml exists
    if [ ! -f "docker-compose.yml" ]; then
        log_error "docker-compose.yml not found in current directory"
        exit 1
    fi
    
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
        log_success "Services started successfully"
        log_info "Portfolio is available at: http://localhost:$PORT"
        test_portfolio
    else
        log_error "Failed to start services"
        exit 1
    fi
}

compose_down() {
    log_info "Stopping services with Docker Compose..."
    docker-compose down
    log_success "Services stopped"
}

compose_logs() {
    log_info "Showing Docker Compose logs..."
    docker-compose logs -f
}

# Main menu
show_menu() {
    echo -e "${BLUE}Portfolio Docker Management${NC}"
    echo "=========================="
    echo "1. Build and run (single container)"
    echo "2. Build and run (Docker Compose)"
    echo "3. Stop container"
    echo "4. Show logs"
    echo "5. Health check"
    echo "6. Test portfolio URL"
    echo "7. Push to Docker Hub"
    echo "8. Build and push to Docker Hub"
    echo "9. Cleanup"
    echo "10. Exit"
    echo ""
    echo -e "${YELLOW}Current tag: $TAG${NC}"
    echo -e "${YELLOW}Docker Hub: ${DOCKERHUB_USER}/${DOCKERHUB_REPO}:${TAG}${NC}"
    echo ""
}

# Main execution
main() {
    case "${1:-menu}" in
        "build")
            check_docker
            build_image
            run_container
            health_check
            test_portfolio
            ;;
        "compose")
            check_docker
            compose_up
            ;;
        "stop")
            stop_container
            ;;
        "logs")
            show_logs
            ;;
        "health")
            health_check
            ;;
        "cleanup")
            cleanup
            ;;
        "test")
            test_portfolio
            ;;
        "push")
            if [ "$TAG" = "latest" ]; then
                TAG=$(get_tag_input "latest")
            fi
            push_to_dockerhub
            ;;
        "menu"|*)
            while true; do
                show_menu
                read -p "Select an option (1-10): " choice
                case $choice in
                    1)
                        check_docker
                        build_image
                        run_container
                        health_check
                        test_portfolio
                        ;;
                    2)
                        check_docker
                        compose_up
                        ;;
                    3)
                        stop_container
                        ;;
                    4)
                        show_logs
                        ;;
                    5)
                        health_check
                        ;;
                    6)
                        test_portfolio
                        ;;
                    7)
                        push_to_dockerhub
                        ;;
                    8)
                        check_docker
                        build_and_push
                        ;;
                    9)
                        cleanup
                        ;;
                    10)
                        log_info "Goodbye!"
                        exit 0
                        ;;
                    *)
                        log_error "Invalid option. Please try again."
                        ;;
                esac
                echo ""
                read -p "Press Enter to continue..."
                clear
            done
            ;;
    esac
}

# Run main function
main "$@"
