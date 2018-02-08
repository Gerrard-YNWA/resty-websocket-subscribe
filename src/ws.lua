local server = require("resty.websocket.server")
local semaphore = require('ngx.semaphore')
local queue = require('src.queue')
local ws_recv_handler = require('src.ws_recv_handler')
local ws_send_handler = require('src.ws_send_handler')
local cjson = require('cjson.safe')


local function get_sema(key)
	if _g_push_semaphore_set[key] then
		return _g_push_semaphore_set[key]
	else
		local sema, err = semaphore:new()
		if not sema then
			ngx.log(ngx.ERR, 'new semaphore failed', err)
			return nil, err
		end
		_g_push_semaphore_set[key] = sema
		return sema
	end
end

local function do_ws_send(ws, opQueue)
	local sema, key, operation, ok, err, res
	local key = "channel1"
	sema = get_sema(key)
	if not sema then
		ws:send_close()
		return
	end
	while true and not ngx.worker.exiting() do
		operation = opQueue:poll()
		if not operation then
			ok, err = sema:wait(5)
			if ok then
				res = ngx.shared.res
				local value = res:get(key)
				if value  then
					opQueue:offer({opcode = 'text', data = value})
				end
			elseif err ~= 'timeout' then
				ws:send_close()
				break
			end
		else
			local opcode = operation.opcode 
			pcall(ws_send_handler[opcode], ws, operation.data)
			if opcode == 'close' then
				ws:send_close()
				break
			end
		end
	end
end

local function do_ws_recv(ws, opQueue)
	local data, typ, err
	while true and not ngx.worker.exiting() do
		data, typ, err = ws:recv_frame()
		if err and not string.find(err, "timeout", 1, true) then
			ngx.log(ngx.ERR, "failed to receive a frame:", err)
			opQueue:offer({opcode = 'close'})
			break
		end
		pcall(ws_recv_handler[typ], data, opQueue)
		if typ == 'close' then
			break
		end
	end
end


local ws, err = server:new{
	timeout = 5000,
	max_payload_len = math.pow(2, 31)
}
if not ws then
	ngx.log(ngx.ERR, "failed to new websocket:", err)
	return ngx.exit(444)
end

local opQueue = queue.new()
local send_co = ngx.thread.spawn(do_ws_send, ws, opQueue)
do_ws_recv(ws, opQueue)
ngx.thread.wait(send_co)
