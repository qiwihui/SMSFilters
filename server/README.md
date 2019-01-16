短信提交服务端
===

目前直接使用文件保存，运行方法：

```bash
docker run --name flaskapp --restart=always -p 80:80 -v $(PWD):/app -d jazzdd/alpine-flask
```
