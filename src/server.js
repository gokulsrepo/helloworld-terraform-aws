const express = require('express');
const app = express();

app.use(function(req, res, next) {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
    next();
});

app.get('/', (req, res) => {
    res.send("Hello World!, from Gokul! for Pearlthoughts Task");
});

app.listen(3000, () =>{
   console.log('Server running on port 3000.'); 
});
