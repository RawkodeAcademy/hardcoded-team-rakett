const express = require('express');
const app = express();
const port = 3000;

app.use(express.json());

// Request counter for metrics
let requestCounter = 0;

app.post('/', (req, res) => {
    requestCounter++;
    const { text } = req.body;

    if (!text) {
        return res.status(400).json({ error: 'Text is required' });
    }

    // Split by whitespace and filter out empty strings
    const tokens = text.trim().split(/\s+/).filter(word => word.length > 0);
    const tokenCount = tokens.length;

    res.json({
        key: 'tokens',
        value: tokenCount,
        cache_hit: false
    });
});

app.get('/metrics', (req, res) => {
    res.json({
        requests: requestCounter
    });
});

app.listen(port, () => {
    console.log(`Tokenizer API listening on port ${port}`);
});
