# Docker Hub Push Examples

## 🐳 Docker Hub Integration

Your build scripts now support pushing to Docker Hub with the username `aroundarmor` and repository `portfolio`.

### **Quick Commands**

#### **Windows PowerShell:**
```powershell
# Login to Docker Hub first
docker login -u aroundarmor

# Push with default tag (latest)
.\build.ps1 push

# Push with custom tag
.\build.ps1 push v1.0.0

# Build and push in one command
.\build.ps1 build
.\build.ps1 push v1.0.0

# Or use the interactive menu
.\build.ps1
# Then select option 7 (Push to Docker Hub) or 8 (Build and push)
```

#### **Linux/macOS Bash:**
```bash
# Login to Docker Hub first
docker login -u aroundarmor

# Push with default tag (latest)
./build.sh push

# Push with custom tag
./build.sh push v1.0.0

# Build and push in one command
./build.sh build
./build.sh push v1.0.0

# Or use the interactive menu
./build.sh
# Then select option 7 (Push to Docker Hub) or 8 (Build and push)
```

### **NPM Scripts:**
```bash
# From project root
npm run docker:tag        # Tag image for Docker Hub
npm run docker:push       # Push to Docker Hub
npm run docker:build:push # Build, tag, and push
```

### **Manual Docker Commands:**
```bash
# Build the image
docker build -f docker-package/Dockerfile -t sourav-portfolio .

# Tag for Docker Hub
docker tag sourav-portfolio aroundarmor/portfolio:latest
docker tag sourav-portfolio aroundarmor/portfolio:v1.0.0

# Push to Docker Hub
docker push aroundarmor/portfolio:latest
docker push aroundarmor/portfolio:v1.0.0
```

### **Pull and Run from Docker Hub:**
```bash
# Pull the image
docker pull aroundarmor/portfolio:latest

# Run the container
docker run -d --name portfolio-container -p 8080:8080 aroundarmor/portfolio:latest

# Access at http://localhost:8080
```

### **Available Tags:**
- `aroundarmor/portfolio:latest` - Latest version
- `aroundarmor/portfolio:v1.0.0` - Version 1.0.0
- `aroundarmor/portfolio:dev` - Development version
- `aroundarmor/portfolio:stable` - Stable release

### **Docker Hub Repository:**
Your images will be available at: https://hub.docker.com/r/aroundarmor/portfolio

### **Features:**
- ✅ Automatic tagging with your Docker Hub username
- ✅ Support for custom tags
- ✅ Login verification
- ✅ Error handling and user feedback
- ✅ Cross-platform support (Windows/Linux/macOS)
- ✅ Integration with build scripts
- ✅ NPM script support


