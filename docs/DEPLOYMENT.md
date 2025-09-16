# GitHub Pages Deployment Guide

This guide will help you deploy your Netflix-inspired DevOps portfolio to GitHub Pages.

## Prerequisites

- A GitHub account
- Git installed on your local machine
- Basic knowledge of Git commands

## Step-by-Step Deployment

### 1. Prepare Your Repository

1. **Fork or clone this repository** to your GitHub account
2. **Rename the repository** to match your username (e.g., `yourusername.github.io` for a user site, or keep the current name for a project site)

### 2. Customize Your Portfolio

Before deploying, update the following in `docs/index.html`:

#### Personal Information
- Replace "Your Name" with your actual name
- Update email addresses and contact information
- Replace social media links with your profiles
- Update the hero section with your title and description

#### Content Updates
- Modify the About section with your personal story
- Update skills to match your expertise
- Replace project descriptions with your actual projects
- Update the experience timeline with your work history
- Add your own statistics and achievements

#### Contact Information
```html
<!-- Update these sections in the contact area -->
<div class="contact-method">
    <i class="fas fa-envelope"></i>
    <span>your.actual.email@example.com</span>
</div>
<div class="contact-method">
    <i class="fab fa-linkedin"></i>
    <span>linkedin.com/in/your-actual-profile</span>
</div>
<div class="contact-method">
    <i class="fab fa-github"></i>
    <span>github.com/your-actual-username</span>
</div>
```

### 3. Enable GitHub Pages

1. **Go to your repository** on GitHub
2. **Click on "Settings"** tab
3. **Scroll down to "Pages"** section in the left sidebar
4. **Under "Source"**, select "Deploy from a branch"
5. **Choose "main" branch** and **"/docs" folder**
6. **Click "Save"**

### 4. Configure Custom Domain (Optional)

If you have a custom domain:

1. **Add a CNAME file** in the `docs/` folder:
   ```
   yourdomain.com
   ```

2. **Update DNS settings** with your domain provider:
   - Add a CNAME record pointing to `yourusername.github.io`

3. **Enable "Enforce HTTPS"** in GitHub Pages settings

### 5. Verify Deployment

1. **Wait 2-5 minutes** for GitHub Pages to deploy your static files
2. **Visit your site** at:
   - `https://yourusername.github.io/portfolio-1` (project site)
   - `https://yourusername.github.io` (user site)

### 6. Verify Your Portfolio

Your portfolio is now ready! Since this is a pure static site, there's no configuration file needed. All your information is already in the HTML file.

## Troubleshooting

### Common Issues

1. **Site not loading**: Check if GitHub Pages is enabled and the correct branch/folder is selected
2. **Styling issues**: Ensure all CSS files are in the `docs/` folder
3. **Images not loading**: Use relative paths for images and ensure they're in the `docs/` folder
4. **Custom domain not working**: Check DNS settings and CNAME file

### Deployment Issues

If you encounter deployment issues:

1. **Check the Pages tab** in your repository settings
2. **Ensure all files are properly formatted**
3. **Verify file paths are correct** (all files should be in the `docs/` folder)

### Performance Optimization

1. **Optimize images** before uploading
2. **Minify CSS and JavaScript** for production
3. **Enable GitHub Pages caching** in settings

## Local Development

To test changes locally before deploying:

```bash
# Navigate to the docs folder
cd docs

# Start a local server (Python 3)
python -m http.server 8000

# Or using Node.js (if you have http-server installed)
npx http-server -p 8000

# Open http://localhost:8000 in your browser
```

## Continuous Deployment

Your site will automatically update when you push changes to the main branch. The typical workflow is:

1. **Make changes** to your portfolio files
2. **Commit and push** to the main branch
3. **GitHub Pages automatically deploys** your static files
4. **Changes are live** within 2-5 minutes

## Security Considerations

- **Never commit sensitive information** like API keys or passwords
- **Use environment variables** for any configuration that needs to be secret
- **Enable branch protection** rules for the main branch
- **Regularly update dependencies** to maintain security

## Analytics and SEO

Consider adding:

1. **Google Analytics** for visitor tracking
2. **Google Search Console** for SEO monitoring
3. **Meta tags** for better social media sharing
4. **Sitemap** for search engine indexing

## Support

If you encounter issues:

1. **Check GitHub Pages documentation**
2. **Review the repository's Issues section**
3. **Contact GitHub Support** for platform-specific issues

---

**Your portfolio should now be live and accessible to the world! 🚀**
