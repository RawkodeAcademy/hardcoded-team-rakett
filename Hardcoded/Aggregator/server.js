const express = require('express');
const app = express();

const PORT = process.env.PORT ? parseInt(process.env.PORT, 10) : 8080;

const NORMALIZER_URL = process.env.NORMALIZER_URL || 'http://localhost:8080';
const TOKENIZER_URL = process.env.TOKENIZER_URL || 'http://localhost:8080';

app.use(express.json());

async function callService(url, body) {
    const resp = await fetch(url, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify(body)
    });
    if (!resp.ok) throw new Error('bad status ' + resp.status);
    const json = await resp.json().catch(() => null);
    return { json };
}

async function analyze(text) {
    const result = {
        normalized: null,
        tokens: null,
        degraded: false
    };

    // Call normalizer first
    let normalized = null;
    try {
        const n = await callService(NORMALIZER_URL + '/op', { text });
        if (n?.json?.degraded) {
            result.degraded = true;
            result.normalized = n.json.value ?? null;
        } else {
            normalized = n?.json?.value ?? null;
            result.normalized = normalized;
        }
    } catch {
        result.degraded = true;
        return result;
    }

    // Call tokenizer
    try {
        const t = await callService(TOKENIZER_URL + '/op', { text });
        if (t?.json?.degraded) {
            result.degraded = true;
        }
        result.tokens = t?.json?.value ?? null;
    } catch {
        result.degraded = true;
    }

    // Set degraded if any required field is null
    if (result.normalized === null || result.tokens === null) {
        result.degraded = true;
    }

    return result;
}

app.post('/analyze', async (req, res) => {
    const { text } = req.body;

    // Validate input
    if (typeof text !== 'string') {
        return res.status(200).json({
            degraded: true,
            error: 'Text field must be a string'
        });
    }

    try {
        const result = await analyze(text);
        res.status(200).json(result);
    } catch (error) {
        // Graceful fallback on unexpected error
        res.status(200).json({
            degraded: true,
            error: `Unexpected error: ${error.message}`
        });
    }
});

app.get('/healthz', (req, res) => {
    res.json({ ok: true });
});

app.listen(PORT, () => {
    console.log(`Aggregator API listening on port ${PORT}`);
});
