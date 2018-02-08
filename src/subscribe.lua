local redis = require('resty.redis')
local cjson = require('cjson.safe')
local semaphore = require('ngx.semaphore')

local function getRedis()
	local red = redis:new()
	local ok, err = red:connect("127.0.0.1", 6379)
	if ok then
		return red
	else
		ngx.log(ngx.ERR, 'connect to redis failed, err: ', err)
		return nil
	end
end

local function releaseRedis(red)
	red:close()
end

return function(premature, timeout)
	if premature then
		return
	end
	red = getRedis()
	if not red then
		ngx.log(ngx.ERR, "new redis failed")
		return
	end
	red:set_timeout(timeout or 5000)
        local pattern = "channel*"
	local ok, err = red:psubscribe(pattern)
	if err then
		ngx.log(ngx.ERR, "psubscribe err: ", err)
	else
		ngx.log(ngx.INFO, "start to subscribe on ", pattern) 
		while true and not ngx.worker.exiting() do
			ok, err = red:read_reply()--waitfor subscribe reply
			if ok then
				ngx.log(ngx.INFO, 'read', cjson.encode(ok))
				local key = ok[3]
				local value = ok[4]
				local res = ngx.shared.res
				res:set(key, value)
				if _g_push_semaphore_set[key] then
					local sema = _g_push_semaphore_set[key]
					if sema then
						local count = sema:count()
						if count < 0 then
							sema:post(math.abs(count))
						end
					end
				end
			elseif err == "timeout" then
				--continue
			else
				ngx.log(ngx.ERR, "read err: ", err)
				break
			end
		end
	end
	releaseRedis(red)
end

