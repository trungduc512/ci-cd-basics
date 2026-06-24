# Stage 1: Builder
FROM node:24 AS builder

WORKDIR /usr/src/app

# Sao chép package.json và package-lock.json để cài đặt dependencies
COPY package*.json ./

# Cài đặt chỉ các production dependencies để tối ưu kích thước image
RUN npm install --omit=dev

# Thay đổi: Sao chép toàn bộ thư mục app chứa server.js vào stage builder
COPY app/ ./app/

# Stage 2: Runtime
FROM node:24-alpine AS runtime

# Dọn dẹp npm và yarn toàn cục để loại bỏ hoàn toàn các lỗ hổng bảo mật (CVEs) khi Trivy quét
RUN rm -rf /usr/local/lib/node_modules/npm \
           /usr/local/bin/npm \
           /usr/local/bin/npx \
           /opt/yarn-v* \
           /usr/local/bin/yarn \
           /usr/local/bin/yarnpkg

# Thiết lập các nhãn OCI (Open Container Initiative) mẫu
LABEL org.opencontainers.image.title="Simple Node.js Server" \
      org.opencontainers.image.description="A simple lightweight HTTP server running on Node.js alpine" \
      org.opencontainers.image.source="https://github.com/trungduc512/ci-cd-basics" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.licenses="MIT"

# Thiết lập biến môi trường mặc định
ENV NODE_ENV=production \
    PORT=3000

# Tạo thư mục làm việc chính thức
WORKDIR /usr/src/app

# Thay đổi: Sao chép toàn bộ ứng dụng (bao gồm thư mục app/ và node_modules) từ stage builder và gán quyền sở hữu cho user node
COPY --from=builder --chown=node:node /usr/src/app .

# Sử dụng non-root user mặc định của Alpine Node để đảm bảo an toàn hệ thống
USER node

# Khai báo port ứng dụng lắng nghe
EXPOSE 3000

# Thay đổi: Cập nhật Healthcheck sử dụng wget gọi tới endpoint /status mới tinh chỉnh ở bài trước
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT}/status || exit 1

# Thay đổi: Lệnh khởi chạy ứng dụng trỏ chính xác vào file app/server.js
CMD ["node", "app/server.js"]