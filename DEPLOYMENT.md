# GitHub Pages Deployment Setup

This repository is configured to automatically build and deploy to GitHub Pages using GitHub Actions.

## One-Time Setup

You need to enable GitHub Pages in your repository settings:

### Steps:

1. Go to your repository on GitHub
2. Click on **Settings** (top right)
3. In the left sidebar, click on **Pages** (under "Code and automation")
4. Under "Build and deployment":
   - **Source**: Select "GitHub Actions"
   - (This replaces the old method of deploying from a branch)
5. Click **Save**

That's it! GitHub will automatically detect the workflow file (`.github/workflows/deploy.yml`) and start using it.

## How It Works

1. **Trigger**: The workflow runs automatically when you push to the `main` branch
2. **Build**:
   - Checks out the repository
   - Installs Node.js 18
   - Installs npm dependencies from `framework/package.json`
   - Runs `npm run build` in the `framework` directory
3. **Deploy**: Uploads the built site from `framework/dist/` to GitHub Pages

## Manual Trigger

You can also manually trigger a deployment:

1. Go to the **Actions** tab in your repository
2. Click on "Build and Deploy Observable Framework" workflow
3. Click "Run workflow" button
4. Select the branch and click "Run workflow"

## Viewing Your Site

After the first successful deployment, your site will be available at:

```
https://[your-username].github.io/shutesbury-fire-dept-analytics/
```

## Troubleshooting

If the deployment fails:

1. Check the **Actions** tab for error logs
2. Common issues:
   - Missing data files in the `framework/docs/data/` directory
   - npm package installation failures
   - Build errors in the Observable Framework code

## Local Testing

Before pushing, you can test the build locally:

```bash
cd framework
npm install
npm run build
```

If this succeeds locally, it should work in GitHub Actions too.
