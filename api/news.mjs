import fetch from 'node-fetch';

export default async function handler(req, res) {
    const NEWS_API_KEY = process.env.NEWS_API_KEY;
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
        res.status(200).json(data);
    } catch (err) {
        res.status(500).json({ message: 'Server error', error: err.toString() });
    }
}