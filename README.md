# resty-websocket-subscribe
ngx_lua websocket subscribe based on redis

```
mkdir -p logs
nginx -p . -c conf/nginx-dev.conf
cd test

publish topic on redis

127.0.0.1:6379> PUBLISH channel1 "hello openresty!"
(integer) 1

client output
[test]$ python t.py (websocket-client required)
start thread-0
start thread-1
start thread-2
start thread-3
start thread-4
start thread-5
start thread-6
start thread-7
start thread-8
start thread-9
thread-0:hello openresty!
thread-1:hello openresty!
thread-2:hello openresty!
thread-3:hello openresty!
thread-4:hello openresty!
thread-5:hello openresty!
thread-6:hello openresty!
thread-7:hello openresty!
thread-8:hello openresty!
thread-9:hello openresty!
```
