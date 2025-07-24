# Global News Hub

Your daily source for worldwide headlines.  
A web application that fetches and displays news articles using the [NewsAPI.org](https://newsapi.org/) external API, with features for searching and filtering by category.

---

## Features

- **Live news headlines** from the United States
- **Search** by keyword
- **Filter** by news category
- Responsive, user-friendly interface
- Robust error handling for API/network issues

---

## Screenshot

![Screenshot](./screenshot.png)

---

## Getting Started (Local Development)

1. **Clone the repository:**
    ```bash
    git clone https://github.com/Reginah24/global-news-hub.git
    cd global-news-hub
    ```

2. **Install dependencies:**
    ```bash
    npm install
    ```

3. **Set up your API key:**
    - Create a `.env` file in the root directory:
        ```
        NEWS_API_KEY=your_newsapi_key_here
        ```
    - (Or, you can edit `server.js` directly, but `.env` is recommended.)

4. **Start the backend proxy server:**
    ```bash
    node server.js
    ```

5. **Open `index.html` in your browser** to use the app locally.

---

## Deployment

### Vercel

Due to technical issues with the provided webservers, this project is deployed on [Vercel](https://vercel.com/):

- **Live Demo:** [https://your-vercel-app-url.vercel.app](https://your-vercel-app-url.vercel.app)

#### Steps to Deploy on Vercel

1. Push your code to GitHub.
2. Go to [Vercel](https://vercel.com/) and import your GitHub repository.
3. In Vercel dashboard, add your NewsAPI key as an environment variable (`NEWS_API_KEY`).
4. Deploy! Vercel will handle both the backend and frontend.

---

## API Attribution

- Powered by [NewsAPI.org](https://newsapi.org/)
- Please review their [terms of use](https://newsapi.org/terms).

---

## Security

- **API keys** are never exposed in the frontend. All requests go through a secure backend proxy.
- `.env` and sensitive files are excluded from version control via `.gitignore`.

---

## Challenges & Notes

- The original assignment required deployment on university webservers, but due to access issues, Vercel was used as a reliable alternative.
- NewsAPI free tier only allows requests from localhost or via a backend proxy.
- [Add any other challenges you faced and how you solved them.]

---

## Credits

- [NewsAPI.org](https://newsapi.org/)
- [Express](https://expressjs.com/)
- [Node.js](https://nodejs.org/)
- [Tailwind CSS](https://tailwindcss.com/) <!-- Remove if not used -->

---

## Author

- GitHub: [Reginah24](https://github.com/Reginah24)

---

## License

This project is for educational purposes.