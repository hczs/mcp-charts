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
