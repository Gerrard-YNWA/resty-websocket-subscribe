local queue = {}

function queue.new()
    return setmetatable({first = 1, last = 0}, {__index = queue})
end

function queue.offer(self, v)
    self.last = self.last + 1
    self[self.last] = v
end

function queue.poll(self)
    if self.first > self.last then
        return nil
    end

    local v = self[self.first]
    self[self.first] = nil
    self.first = self.first + 1
    return v
end

function queue.size(self)
    return self.last - self.first + 1
end

function queue.clear(self)
    while self:poll() do end 
end

return queue
