const { test, describe, before, after } = require('node:test');
const assert = require('node:assert');
const server = require('../app/server.js');

describe('Kiểm tra API Endpoints', () => {
  const PORT = 3005;
  const BASE_URL = `http://localhost:${PORT}`;

  before(() => {
    return new Promise((resolve) => server.listen(PORT, resolve));
  });

  after(() => {
    return new Promise((resolve) => server.close(resolve));
  });

  // TEST 1: Kiểm tra status code của endpoint mới /status
  test('Endpoint /status trả về status 200', async () => {
    const res = await fetch(`${BASE_URL}/status`);
    assert.strictEqual(res.status, 200);
  });

  // TEST 2: Kiểm tra nội dung JSON (Dùng để tạo test ĐỎ / XANH)
  test('Endpoint /status trả về đúng thông tin hệ thống', async () => {
    const res = await fetch(`${BASE_URL}/status`);
    const data = await res.json();

    assert.ok(data.environment);

    // BƯỚC 1 (ĐỂ PIPELINE ĐỎ): Hãy comment dòng 'UP' bên dưới và mở comment dòng 'DOWN' ra để cố tình làm lỗi
    assert.strictEqual(data.status, 'DOWN');

    // BƯỚC 2 (ĐỂ PIPELINE XANH): Giữ nguyên dòng dưới để pass bài
    // assert.strictEqual(data.status, 'UP');
  });
});