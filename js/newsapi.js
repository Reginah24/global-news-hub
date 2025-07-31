// Configuration and API handling
class NewsAPI {
    constructor() {
        // Try to get API key from environment or use a placeholder
        this.apiKey = this.getApiKey();
        this.baseUrl = 'https://newsapi.org/v2';
        this.proxyUrl = 'https://api.allorigins.win/get?url=';
    }

    getApiKey() {
        // In production, this would come from environment variables
        // For now, we'll use a method that can be easily replaced
        const apiKey = window.NEWS_API_KEY || process?.env?.NEWS_API_KEY || '6e7e3e191a044942bdfe97a0b382cf4d';
        return apiKey;
    }

    async fetchNews(query = '', category = '', country = 'us') {
        try {
            let newsApiUrl;
            
            if (query.trim()) {
                newsApiUrl = `${this.baseUrl}/everything?q=${encodeURIComponent(query)}&apiKey=${this.apiKey}&language=en&sortBy=publishedAt&pageSize=20`;
            } else {
                newsApiUrl = `${this.baseUrl}/top-headlines?apiKey=${this.apiKey}&language=en&country=${country}&pageSize=20`;
                if (category && category !== 'general') {
                    newsApiUrl += `&category=${category}`;
                }
            }

            const proxyUrl = this.proxyUrl + encodeURIComponent(newsApiUrl);
            
            const response = await fetch(proxyUrl);
            
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            
            const data = await response.json();
            const newsData = JSON.parse(data.contents);
            
            if (newsData.status !== 'ok') {
                throw new Error(newsData.message || 'Failed to fetch news');
            }
            
            return newsData.articles || [];
        } catch (error) {
            console.error("Failed to fetch news:", error);
            throw error;
        }
    }
}

// Export for use in main application
window.NewsAPI = NewsAPI;
