const http = require('http');
const port = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  // Thay đổi: Thêm endpoint /status khác hoàn toàn bài cũ
  if (req.url === '/status') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ status: 'UP', environment: process.env.NODE_ENV || 'development' }));
  }

  // Endpoint gốc
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    msg: 'hello from ' + (process.env.NAME || 'docker'),
    ts: Date.now()
  }));
});

if (require.main === module) {
  server.listen(port, () => console.log(`listening on ${port}`));
}

module.exports = server;