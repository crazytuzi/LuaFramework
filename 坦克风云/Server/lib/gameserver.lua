local socket = require "socket"
local struct = require("struct")

local default_cfg = {
    header_length = 5,
    get_length = 1024,
    timeout=3,
}

local set_timeout = function(timeout)
    default_cfg.timeout = timeout
end

local mkcmd = function(data)
    return "1 " .. data .. "\r\n"
end

local expect_table = function(s)
    if s then
        return json.decode(s)
    end

    return nil
end

--- methods

-- connection

local connect = function(self, server, port)
    self.cnx = socket.tcp()
    self.cnx:settimeout(default_cfg.timeout)
    return self.cnx:connect(server, port)
end

-- consumer

local reserve_data_length = function(self)
    local len = 0

    local chunk, status, partial = self.cnx:receive(default_cfg.header_length)
    if chunk then
        local header = chunk:sub(2,4)
        len = struct.unpack("H",header)
    end

    return len
end

local reserve = function(self)
    local reserve_data = ''
    local get_length = default_cfg.get_length
    local result_length = reserve_data_length(self)

    if result_length > 0 then
        local nextLen = result_length - default_cfg.header_length
        if get_length > nextLen then get_length = nextLen end

        while nextLen > 0 do
            local chunk, status, partial = self.cnx:receive(get_length)

            if chunk then
                reserve_data = reserve_data .. chunk
                nextLen = nextLen - get_length
            else
                break
            end

            if get_length > nextLen then get_length = nextLen end
        end
    end

    return reserve_data
end

local reserve_with_timeout = function(self, timeout)
    self.cnx:settimeout(timeout)
end

-- producer

local put = function(self, data)
    local cmd = mkcmd(data)
    self.cnx:send(cmd)
    local res = reserve(self)
    return expect_table(res)
end

local close = function(self)
    if self.cnx then
        self.cnx:close()
    end
end

--- class

local methods = {
    -- connection
    connect = connect, -- (server,port) -> ok
    -- producer
    put = put, -- (pri,delay,ttr,data) -> ok,[id|err]
    -- consumer
    reserve = reserve, -- () -> ok,[job|err]
    reserve_with_timeout = reserve_with_timeout, -- () -> ok,[job|nil|err]
    close = close,
}

local new = function(server, port)
    local r = {}
    if connect(r, server, port) == 1 then
        return setmetatable(r, {__index = methods})
    end

    return nil
end

return {
    new = new,
    set_timeout=set_timeout,
}
