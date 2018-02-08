local function handle_server_binary(ws, data)
	ws:send_binary(data)
end

local function handle_server_text(ws, data)
	ws:send_text(data)
end

local function handle_server_ping(ws)
	ws:send_pong()
end

local function handle_server_pong(ws)
	ws:send_ping()
end

local function handle_server_close(ws)
	ws:send_close()
end


--register
return {
	['binary'] = handle_server_binary,
	['text'] = handle_server_text,
	['ping'] = handle_server_ping,
	['pong'] = handle_server_pong,
	['close'] = handle_server_close,
}
