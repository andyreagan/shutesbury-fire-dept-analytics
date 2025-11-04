# Shutesbury Fire Department Analytics

Analytics dashboard for Shutesbury Fire Department call data, built with [Observable Framework](https://observablehq.com/framework).

## 🚀 Deployment

This project automatically builds and deploys to GitHub Pages when changes are pushed to the `main` branch.

**Live Site:** `https://[your-username].github.io/shutesbury-fire-dept-analytics/`

## 📦 Local Development

To work on this project locally:

```bash
cd framework
npm install
npm run dev
```

Then visit http://localhost:3000 to preview the site.

## 🏗️ Building Locally

To build the static site locally:

```bash
cd framework
npm run build
```

This generates the static HTML site in the `framework/dist/` directory.

## 🔧 Technical Details

The project uses Observable Framework with local npm dependencies for d3 and Observable Plot, ensuring builds work in restricted network environments.
