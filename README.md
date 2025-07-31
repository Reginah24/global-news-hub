# Global News Hub

A responsive news application that displays trending news from around the world using the News API. I built this using HTML, CSS, and JavaScript to practice API integration and web development skills.

![Global News Hub Screenshot](screenshot.png)

## Features

- Real-time news from multiple sources
- Search functionality for specific topics
- Category filtering (Business, Technology, Sports, etc.)
- Responsive design that works on mobile and desktop
- Error handling for network issues
- Clean, user-friendly interface

## Technologies Used

- HTML5, CSS3, JavaScript
- Tailwind CSS for styling
- News API for data
- Docker for deployment
- HAProxy for load balancing

## Getting Started

### Requirements

- News API key (free from newsapi.org)
- Docker (optional, for containerized deployment)
- Modern web browser

### Setup Instructions

1. Clone this repository:
```bash
git clone https://github.com/Reginah24/global-news-hub.git
cd global-news-hub
```

2. Get a News API key:
   - Go to newsapi.org and create a free account
   - Copy your API key

3. Set up environment variables:
```bash
cp .env.example .env
# Edit .env and add your API key
```

4. Run the application:

**Option 1: Local server**
```bash
python -m http.server 8000
# Open http://localhost:8000
```

**Option 2: Docker**
```bash
docker build -t global-news-hub .
docker run -p 8080:8080 --env-file .env global-news-hub
# Open http://localhost:8080
```

**Option 3: Full stack with load balancer**
```bash
docker-compose up -d
# Open http://localhost
```

## Project Structure

```
global-news-hub/
├── index.html              # Main application
├── Dockerfile              # Docker configuration
├── docker-compose.yml      # Multi-container setup
├── haproxy.cfg             # Load balancer config
├── deploy.ps1/.sh          # Deployment scripts
├── test-loadbalancer.*     # Load balancer tests
├── .env.example            # Environment template
└── README.md               # This file
```

## How It Works

The application fetches news data from the News API and displays it in a clean, responsive interface. Users can search for specific topics or filter by categories. I implemented error handling to deal with API rate limits and network issues.

For deployment, I used Vercel for the live production environment, which provides excellent performance and global CDN distribution. I also prepared Docker configurations and HAProxy setup for containerized deployment scenarios.

## Live Demo

🌐 **Live Application**: [https://your-app-name.vercel.app](https://your-vercel-url.vercel.app)

## Deployment Options

### Option 1: Vercel (Production)
```bash
# Connect GitHub repo to Vercel
# Add NEWS_API_KEY environment variable in Vercel dashboard
# Automatic deployment on git push
```

### Option 2: Docker (Local/Server)
```bash
docker build -t global-news-hub .
docker run -p 8080:8080 --env-file .env global-news-hub
```

### Option 3: Multi-container with Load Balancer
```bash
docker-compose up -d
```

## Testing

I tested the application with various search terms and categories:
- Technology news
- Sports updates  
- Business headlines
- Health information

The responsive design was tested on different screen sizes to ensure it works well on mobile devices.

## Deployment

The app can be deployed in several ways:
1. Simple static hosting
2. Docker container
3. Multi-container setup with load balancing

I included deployment scripts for both Windows and Linux environments.

## Issues and Solutions

During development, I encountered a few challenges:
- CORS issues with the News API (solved using a proxy)
- API rate limiting (handled with proper error messages)
- Responsive design on small screens (fixed with better CSS)

## Assignment Requirements

This project meets the course requirements:
- External API integration ✓
- Professional UI/UX ✓  
- Docker deployment ✓
- Load balancer configuration ✓
- Complete documentation ✓
