const express = require('express');
const fetch = require('node-fetch');
const cors = require('cors');

const app = express();
const PORT = 5000;
const NEWS_API_KEY = '40fca6d18ddd460ab49eb8f2e9c408e2'; 

app.use(cors());

app.get('/news', async (req, res) => {
    const { q, category, country } = req.query;
    let url;
    if (q) {
        url = `https://newsapi.org/v2/everything?q=${encodeURIComponent(q)}&apiKey=${NEWS_API_KEY}&language=en`;
    } else {
        url = `https://newsapi.org/v2/top-headlines?apiKey=${NEWS_API_KEY}&language=en`;
        if (category && category !== 'general') url += `&category=${category}`;
        if (country) url += `&country=${country}`;
    }
    try {
        const response = await fetch(url);
        const data = await response.json();
        res.json(data);
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.toString() });
    }
});

app.listen(PORT, () => console.log(`Proxy server running on http://localhost:${PORT}`));