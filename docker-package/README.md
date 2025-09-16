# Portfolio Docker Package

This directory contains all the necessary files to containerize and deploy the Sourav Patel DevOps Portfolio using Docker with a multistage build process.

## 🐳 Docker Architecture

### Multi-Stage Build Process

1. **Builder Stage**: Prepares and optimizes static assets
2. **Production Stage**: Serves the application using Nginx

### Key Features

- **Lightweight**: Uses Alpine Linux for minimal image size
- **Secure**: Runs as non-root user with proper permissions
- **Optimized**: Includes gzip compression and caching headers
- **Health Checks**: Built-in health monitoring
- **Production Ready**: Includes security headers and SSL support

## 📁 File Structure

```
docker-package/
├── Dockerfile              # Multi-stage Docker build configuration
├── nginx.conf              # Nginx configuration for static site serving
├── nginx-proxy.conf        # Reverse proxy configuration for production
├── docker-compose.yml      # Docker Compose orchestration
├── package.json            # Node.js package configuration
├── build.sh                # Linux/macOS build script
├── build.ps1               # Windows PowerShell build script
├── .dockerignore           # Docker build context exclusions
└── README.md               # This documentation
```

## 🚀 Quick Start

### Prerequisites

- Docker Desktop (Windows/macOS) or Docker Engine (Linux)
- Docker Compose (included with Docker Desktop)
- Docker Hub account (for pushing images) - [Sign up here](https://hub.docker.com)

### 🎯 Interactive Features

The build scripts include several interactive features to make Docker operations easier:

- **Interactive Tag Input**: When pushing to Docker Hub, the script will prompt for a tag if none is specified
- **Menu-Driven Interface**: Run scripts without parameters to access an interactive menu
- **Smart Defaults**: All operations use sensible defaults (latest tag, port 8080, etc.)
- **Cross-Platform Support**: Identical functionality on Windows (PowerShell) and Linux/macOS (Bash)

#### **Interactive Menu Options:**
When you run `.\build.ps1` or `./build.sh` without parameters, you'll see:

```
Portfolio Docker Management
==========================
1. Build and run (single container)
2. Build and run (Docker Compose)
3. Stop container
4. Show logs
5. Health check
6. Test portfolio URL
7. Push to Docker Hub
8. Build and push to Docker Hub
9. Cleanup
10. Exit

Current tag: latest
Docker Hub: aroundarmor/portfolio:latest
```

### Option 1: Using Build Scripts

#### Windows (PowerShell)
```powershell
# Navigate to docker-package directory
cd docker-package

# Run interactive menu
.\build.ps1

# Or run specific commands
.\build.ps1 build      # Build and run single container
.\build.ps1 compose    # Build and run with Docker Compose
.\build.ps1 stop       # Stop containers
.\build.ps1 logs       # View logs
.\build.ps1 health     # Health check
.\build.ps1 test       # Test portfolio URL accessibility
.\build.ps1 push       # Push to Docker Hub (interactive tag input)
.\build.ps1 build-and-push  # Build and push to Docker Hub
.\build.ps1 cleanup    # Clean up Docker resources
```

#### Linux/macOS (Bash)
```bash
# Navigate to docker-package directory
cd docker-package

# Make script executable
chmod +x build.sh

# Run interactive menu
./build.sh

# Or run specific commands
./build.sh build       # Build and run single container
./build.sh compose     # Build and run with Docker Compose
./build.sh stop        # Stop containers
./build.sh logs        # View logs
./build.sh health      # Health check
./build.sh test        # Test portfolio URL accessibility
./build.sh push        # Push to Docker Hub (interactive tag input)
./build.sh build-and-push  # Build and push to Docker Hub
./build.sh cleanup     # Clean up Docker resources
```

### Option 2: Manual Docker Commands

#### Single Container
```bash
# Build the image
docker build -f docker-package/Dockerfile -t sourav-portfolio .

# Run the container
docker run -d \
  --name portfolio-container \
  -p 8080:8080 \
  --restart unless-stopped \
  sourav-portfolio

# Check if running
docker ps

# View logs
docker logs portfolio-container

# Health check
curl http://localhost:8080/health
```

#### Docker Compose
```bash
# Navigate to docker-package directory
cd docker-package

# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## 🌐 Accessing the Portfolio

Once the container is running, the portfolio will be available at:

- **Local Development**: http://localhost:8080
- **Health Check**: http://localhost:8080/health

## 🐳 Docker Hub Integration

### **Publishing to Docker Hub**

Your portfolio can be easily published to Docker Hub for public access:

#### **Login to Docker Hub:**
```bash
docker login -u aroundarmor
```

#### **Push to Docker Hub:**

**Interactive Tag Input:**
The build scripts now support interactive tag input. When you run push commands without specifying a tag, the script will prompt you to enter one:

```bash
# Windows PowerShell - Interactive mode
.\build.ps1 push
# Will prompt: "Enter tag for Docker Hub (press Enter for 'latest'): "

# Linux/macOS - Interactive mode  
./build.sh push
# Will prompt: "Enter tag for Docker Hub (press Enter for 'latest'): "
```

**Direct Tag Specification:**
You can also specify tags directly via command line:

```bash
# Windows PowerShell
.\build.ps1 push v1.0.0
.\build.ps1 push dev
.\build.ps1 push latest

# Linux/macOS
./build.sh push v1.0.0
./build.sh push dev
./build.sh push latest

# Or use NPM scripts
npm run docker:build:push
```

**Build and Push in One Command:**
```bash
# Windows PowerShell
.\build.ps1 build-and-push v1.0.0

# Linux/macOS
./build.sh build-and-push v1.0.0
```

#### **Pull and Run from Docker Hub:**
```bash
# Pull the image
docker pull aroundarmor/portfolio:latest

# Run the container
docker run -d --name portfolio-container -p 8080:8080 aroundarmor/portfolio:latest
```

#### **Available Tags:**
- `aroundarmor/portfolio:latest` - Latest version
- `aroundarmor/portfolio:v1.0.0` - Version 1.0.0
- `aroundarmor/portfolio:dev` - Development version

#### **Docker Hub Repository:**
Your images will be available at: https://hub.docker.com/r/aroundarmor/portfolio

## 🔧 Configuration

### Environment Variables

The container can be configured using environment variables:

```bash
# Custom port (default: 8080)
docker run -p 3000:8080 sourav-portfolio

# Custom nginx configuration
docker run -v /path/to/nginx.conf:/etc/nginx/nginx.conf:ro sourav-portfolio
```

### Nginx Configuration

The `nginx.conf` file includes:

- **Gzip Compression**: Reduces bandwidth usage
- **Security Headers**: XSS protection, content type options, etc.
- **Caching**: Optimized cache headers for static assets
- **Health Endpoint**: `/health` for monitoring
- **Error Pages**: Custom error handling

### Production Deployment

For production deployment, use the included reverse proxy configuration:

```bash
# Start with production profile
docker-compose --profile production up -d
```

This will start:
- Portfolio container (port 8080)
- Nginx reverse proxy (ports 80/443)

## 📊 Monitoring and Health Checks

### Built-in Health Checks

The container includes automatic health monitoring:

```bash
# Check container health
docker inspect --format='{{.State.Health.Status}}' portfolio-container

# View health check logs
docker inspect --format='{{range .State.Health.Log}}{{.Output}}{{end}}' portfolio-container
```

### Health Endpoint

The application exposes a health endpoint:

```bash
# HTTP health check
curl http://localhost:8080/health

# Expected response
healthy
```

## 🛠️ Development

### Building from Source

```bash
# Clone the repository
git clone https://github.com/aroundarmor/portfolio-1.git
cd portfolio-1

# Build Docker image
docker build -f docker-package/Dockerfile -t sourav-portfolio .

# Run container
docker run -p 8080:8080 sourav-portfolio
```

### Customizing the Build

1. **Modify Dockerfile**: Edit build stages or add dependencies
2. **Update nginx.conf**: Change server configuration
3. **Adjust docker-compose.yml**: Modify service definitions

## 🔒 Security Features

### Container Security

- **Non-root User**: Runs as nginx user (UID 1001)
- **Read-only Filesystem**: Immutable application files
- **Minimal Base Image**: Alpine Linux for reduced attack surface
- **Security Headers**: Comprehensive HTTP security headers

### Network Security

- **Internal Communication**: Services communicate via Docker network
- **Port Exposure**: Only necessary ports are exposed
- **SSL/TLS Support**: Ready for HTTPS deployment

## 📈 Performance Optimizations

### Image Optimization

- **Multi-stage Build**: Reduces final image size
- **Alpine Linux**: Minimal base image (~5MB)
- **Layer Caching**: Optimized layer structure
- **Asset Optimization**: Minified and compressed assets

### Runtime Performance

- **Nginx**: High-performance web server
- **Gzip Compression**: Reduces bandwidth usage
- **Static File Caching**: Optimized cache headers
- **Connection Pooling**: Efficient connection handling

## 🐛 Troubleshooting

### Common Issues

#### Container Won't Start
```bash
# Check Docker logs
docker logs portfolio-container

# Verify image exists
docker images | grep sourav-portfolio

# Check port availability
netstat -tulpn | grep 8080
```

#### Health Check Fails
```bash
# Check container status
docker ps -a

# View detailed logs
docker logs portfolio-container

# Test health endpoint manually
curl -v http://localhost:8080/health
```

#### Permission Issues
```bash
# Check file permissions
ls -la docs/

# Rebuild with proper permissions
docker build --no-cache -f docker-package/Dockerfile -t sourav-portfolio .
```

### Debug Mode

Run container in debug mode:

```bash
# Run with shell access
docker run -it --rm sourav-portfolio sh

# Run with custom nginx config
docker run -v $(pwd)/nginx-debug.conf:/etc/nginx/nginx.conf sourav-portfolio
```

## 📝 Logs and Monitoring

### Viewing Logs

```bash
# Container logs
docker logs portfolio-container

# Follow logs in real-time
docker logs -f portfolio-container

# Docker Compose logs
docker-compose logs -f
```

### Log Locations

- **Nginx Access Logs**: `/var/log/nginx/access.log`
- **Nginx Error Logs**: `/var/log/nginx/error.log`
- **Container Logs**: `docker logs <container-name>`

## 🔄 Updates and Maintenance

### Updating the Application

```bash
# Pull latest changes
git pull origin main

# Rebuild image
docker build -f docker-package/Dockerfile -t sourav-portfolio .

# Restart container
docker-compose down && docker-compose up -d
```

### Cleaning Up

```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Full cleanup
docker system prune -a
```

## 📞 Support

For issues or questions:

- **Email**: work.1sourav@gmail.com
- **LinkedIn**: [linkedin.com/in/aroundarmor](https://www.linkedin.com/in/aroundarmor)
- **GitHub**: [github.com/aroundarmor](https://github.com/aroundarmor)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

---

**Built with ❤️ by Sourav Patel**

*Transforming Infrastructure Challenges into Scalable Solutions*
