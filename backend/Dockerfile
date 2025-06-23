# Use Node.js 20 alpine image
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./
COPY pnpm-lock.yaml ./

# Install pnpm
RUN npm install -g pnpm@9.6.0

# Copy workspace and backend files
COPY backend/package*.json ./backend/
COPY packages/ ./packages/

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy backend source code
COPY backend/ ./backend/

# Build the application
RUN cd backend && npm run build

# Expose port
EXPOSE 10000

# Set environment
ENV NODE_ENV=production
ENV PORT=10000

# Start the application
CMD ["node", "backend/dist/server.js"] 