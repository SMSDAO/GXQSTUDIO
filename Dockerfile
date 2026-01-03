FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy project files
COPY . .

# Compile smart contracts
RUN npx hardhat compile

# Build dashboard
WORKDIR /app/dashboard
COPY dashboard/package.json dashboard/package-lock.json ./
RUN npm install
RUN npm install --save-dev browserify-zlib crypto-browserify https-browserify os-browserify path-browserify stream-browserify stream-http
RUN npm run electron:build

# Second stage for Electron build
FROM electronuserland/builder:wine

WORKDIR /app

# Copy from builder stage
COPY --from=builder /app /app

# Build Windows executable
WORKDIR /app/dashboard
RUN npm run package-win

# Final stage for serving the application
FROM nginx:alpine

# Copy built files
COPY --from=1 /app/dashboard/dist /usr/share/nginx/html

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]