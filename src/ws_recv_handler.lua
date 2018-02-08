local function handle_client_binary(data, queue)
	queue:offer({opcode = 'binary', data = data})
end

local function handle_client_text(data, queue)
	queue:offer({opcode = 'text', data = data})
end

local function handle_client_ping(data, queue)
	queue:offer({opcode = 'pong'})
end

local function handle_client_pong(data, queue)
	--do logic here
end

local function handle_client_close(data, queue)
	queue:offer({opcode = 'close'})
end


--register
return {
	['binary'] = handle_client_binary,
	['text'] = handle_client_text,
	['ping'] = handle_client_ping,
	['pong'] = handle_client_pong,
	['close'] = handle_client_close,
}
