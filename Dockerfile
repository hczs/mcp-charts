# Use Node.js 16 as the base image
FROM node:18-alpine

# Set workdir
WORKDIR /app

# Global install of @antv/mcp-server-chart
RUN npm install -g @antv/mcp-server-chart

# Start the server (using streamable for transmission)
CMD ["mcp-server-chart", "--transport", "sse", "--port", "1123", "--host", "0.0.0.0"]