// Fuzz testing for the tokenizer parser
// This tests the critical text parsing logic with various edge cases and random inputs

function tokenize(text) {
    if (!text) {
        return [];
    }
    return text.trim().split(/\s+/).filter(word => word.length > 0);
}

function generateRandomString(length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 \t\n\r!@#$%^&*()[]{}|\\/<>?;:\'"~`';
    let result = '';
    for (let i = 0; i < length; i++) {
        result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
}

function runFuzzTests() {
    console.log('Starting fuzz tests for tokenizer parser...\n');

    let passed = 0;
    let failed = 0;

    // Test cases
    const testCases = [
        // Edge cases
        { input: '', expected: 0, description: 'Empty string' },
        { input: '   ', expected: 0, description: 'Only whitespace' },
        { input: '\t\n\r', expected: 0, description: 'Only tabs and newlines' },
        { input: 'single', expected: 1, description: 'Single word' },
        { input: '  leading', expected: 1, description: 'Leading whitespace' },
        { input: 'trailing  ', expected: 1, description: 'Trailing whitespace' },
        { input: 'multiple   spaces   between', expected: 3, description: 'Multiple spaces' },
        { input: 'a\tb\nc\rd', expected: 4, description: 'Mixed whitespace characters' },

        // Special characters
        { input: '!@#$%', expected: 1, description: 'Special characters' },
        { input: 'hello@world.com test', expected: 2, description: 'Email-like string' },
        { input: '  \t  word  \n  ', expected: 1, description: 'Word surrounded by mixed whitespace' },

        // Unicode and international characters
        { input: 'café résumé', expected: 2, description: 'Accented characters' },
        { input: '日本語 テスト', expected: 2, description: 'Japanese characters' },
        { input: '🚀 emoji test 🎉', expected: 4, description: 'Emoji characters' },

        // Very long strings
        { input: 'word '.repeat(1000), expected: 1000, description: '1000 words' },
        { input: 'a'.repeat(10000), expected: 1, description: 'Very long single word' },
    ];

    // Run predefined test cases
    console.log('Running predefined test cases:');
    for (const test of testCases) {
        try {
            const tokens = tokenize(test.input);
            const count = tokens.length;

            if (count === test.expected) {
                console.log(`✓ PASS: ${test.description} (${count} tokens)`);
                passed++;
            } else {
                console.log(`✗ FAIL: ${test.description} - Expected ${test.expected}, got ${count}`);
                failed++;
            }
        } catch (error) {
            console.log(`✗ FAIL: ${test.description} - Error: ${error.message}`);
            failed++;
        }
    }

    // Run random fuzz tests
    console.log('\nRunning random fuzz tests:');
    const fuzzIterations = 100;

    for (let i = 0; i < fuzzIterations; i++) {
        try {
            const length = Math.floor(Math.random() * 1000);
            const randomInput = generateRandomString(length);
            const tokens = tokenize(randomInput);

            // Basic sanity checks
            if (!Array.isArray(tokens)) {
                throw new Error('Result is not an array');
            }

            if (tokens.some(token => token.length === 0)) {
                throw new Error('Empty tokens found in result');
            }

            if (tokens.some(token => /\s/.test(token))) {
                throw new Error('Whitespace found in tokens');
            }

            passed++;
        } catch (error) {
            console.log(`✗ FAIL: Random test ${i + 1} - ${error.message}`);
            failed++;
        }
    }

    console.log(`\n${fuzzIterations} random fuzz tests completed`);

    // Summary
    console.log('\n' + '='.repeat(50));
    console.log(`Total tests: ${passed + failed}`);
    console.log(`Passed: ${passed}`);
    console.log(`Failed: ${failed}`);
    console.log(`Success rate: ${((passed / (passed + failed)) * 100).toFixed(2)}%`);
    console.log('='.repeat(50));

    return failed === 0;
}

// Run tests
const success = runFuzzTests();
process.exit(success ? 0 : 1);
