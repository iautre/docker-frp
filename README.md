## frp服务端

基于[frp](https://github.com/fatedier/frp)官方源码打包，最小镜像，不到10m大小

## 使用方法
准备frps.ini文件放到服务器目录下，比如：/app/conf/frps.ini, 指定配置映射端口

```
docker run -d --name frps -v /app/conf:/conf -p 7000:7000 iautre/frps
```