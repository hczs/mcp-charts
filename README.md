# mcp-charts

使用 `@antv/mcp-server-chart` + `gpt-vis-ssr` 的一套私有化制图服务。提供 MCP Server（SSE 传输）和图表渲染服务，便于在本地或内网部署。

## 功能概览
- `mcp-server-chart`：对外提供 MCP Server（SSE），端口 `1123`
- `gpt-vis-ssr`：图表渲染服务，端口 `3000`，提供 `POST /render`
- 两个服务通过 `VIS_REQUEST_SERVER` 连接

## 快速开始
前置要求：已安装 Docker 和 Docker Compose。

```bash
docker-compose up -d --build
```

服务启动后：
- MCP Server：`http://localhost:1123`
- 渲染服务：`http://localhost:3000`

## 仅使用已构建镜像启动
无需拉取项目源码，直接使用已构建镜像启动即可：

```yaml
version: "3.8"

services:
  gpt-vis-ssr:
    image: hsunnyc/gpt-vis-ssr:latest
    ports:
      - "3000:3000"
    volumes:
      - ./images:/app/public/images
    environment:
      - NODE_ENV=production
      - TZ=Asia/Shanghai
      - PUBLIC_BASE_URL=http://localhost:3000
    restart: unless-stopped

  mcp-server-chart:
    image: hsunnyc/mcp-server-chart:latest
    ports:
      - "1123:1123"
    environment:
      - VIS_REQUEST_SERVER=http://gpt-vis-ssr:3000/render
    depends_on:
      - gpt-vis-ssr
```

保存为 `docker-compose.yml` 后运行：
```bash
docker-compose up -d
```

## 多架构镜像发布（M 系列可用）
M 系列本地构建默认是 `linux/arm64`，为兼容 x86 机器，需发布多架构镜像。下面示例同时构建并推送 `linux/amd64` + `linux/arm64`：

```bash
# 仅需一次：创建并启用 buildx builder
docker buildx create --use --name multiarch-builder

# 构建并推送 mcp-server-chart
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t hsunnyc/mcp-server-chart:latest \
  --push \
  .

# 构建并推送 gpt-vis-ssr
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t hsunnyc/gpt-vis-ssr:latest \
  --push \
  ./gpt_vis_ssr
```

## 配置说明
`docker-compose.yml` 中关键环境变量：
- `VIS_REQUEST_SERVER`：`mcp-server-chart` 调用渲染服务的地址，默认 `http://gpt-vis-ssr:3000/render`
- `PUBLIC_BASE_URL`：渲染服务返回图片 URL 的公网前缀，默认 `http://localhost:3000`
- `TZ`：时区设置，默认 `Asia/Shanghai`

## 渲染服务使用示例
请求：
```bash
curl -X POST http://localhost:3000/render \
  -H "Content-Type: application/json" \
  -d '{
    "type": "column",
    "data": [
      { "category": "交通", "value": 2000 },
      { "category": "住宿", "value": 1200 },
      { "category": "吃喝", "value": 1000 },
      { "category": "门票", "value": 800 },
      { "category": "其他", "value": 300 }
    ],
    "title": "旅行计划费用统计",
    "axisXTitle": "费用类别",
    "axisYTitle": "金额 (元)"
  }'
```

响应：
```json
{
  "success": true,
  "resultObj": "http://localhost:3000/images/<uuid>.png"
}
```

## 目录结构
- `Dockerfile`：`mcp-server-chart` 服务镜像构建
- `docker-compose.yml`：本项目一键启动
- `gpt_vis_ssr/`：渲染服务实现与独立说明

## 相关资料
- https://github.com/antvis/GPT-Vis/tree/main/bindings/gpt-vis-ssr
- https://github.com/antvis/mcp-server-chart
