// Libs
const express = require("express");

// Data
const app = express();
const PORT = 3000;

// Code
app.get('/', (req, res) => res.status(200).send("Nice"));

app.listen(PORT, () => {
    console.log(`The server is open on port: ${PORT}`);
});
