local setmetatable = setmetatable
local pairs = pairs

local _M = {}

function _M.new(self)
    local o = { first = 0, last = -1}
    setmetatable(o, self)
    self.__index = self
    return o
end

function _M.push_front (self, value)
    local first = self.first - 1
    self.first  = first
    self[first] = value
    return first
end

function _M.push_back (self, value)
    local last = self.last + 1
    self.last = last
    self[last] = value
    return last
end

function _M.pop_front (self)
    local first = self.first
    if first > self.last then
        return nil
    end
    local value = self[first]
    self[first] = nil
    self.first = first + 1
    return value
end

function _M.pop_back (self)
    local last = self.last
    if self.first > last then
        return nil
    end
    local value = self[last]
    self[last] = nil
    self.last = last - 1
    return value
end

function _M.front(self)
    local first = self.first
    if first > self.last then
        return nil
    end
    local value = self[first]
    return value
end

function _M.back(self)
    local last = self.last
    if self.first > last then
        return nil
    end
    local value = self[last]
    return value
end

function _M.clear (self)
    for i,v in pairs(self) do
        self[i] = nil
    end
    self.first = 0
    self.last = -1
end

function _M.size (self)
    local size = self.last - self.first + 1
    return size, self.first, self.last
end

return _M
