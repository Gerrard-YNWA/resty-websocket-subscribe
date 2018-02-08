if 0 == ngx.worker.id() then
	sub = require('src.subscribe')
	ngx.timer.at(0, sub)
end

_g_push_semaphore_set = {}
