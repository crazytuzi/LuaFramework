








local socket = require("socket")
local url = require("socket.url")
local ltn12 = require("ltn12")
local mime = require("mime")
local string = require("string")
local headers = require("socket.headers")
local base = _G
local table = require("table")
socket.http = {}
local _M = socket.http





_M.TIMEOUT = 60

_M.USERAGENT = socket._VERSION


local SCHEMES = { ["http"] = true }

local PORT = 80




local function receiveheaders(sock, headers)
    local line, name, value, err
    headers = headers or {}
    
    line, err = sock:receive()
    if err then return nil, err end
    
    while line ~= "" do
        
        name, value = socket.skip(2, string.find(line, "^(.-):%s*(.*)"))
        if not (name and value) then return nil, "malformed reponse headers" end
        name = string.lower(name)
        
        line, err  = sock:receive()
        if err then return nil, err end
        
        while string.find(line, "^%s") do
            value = value .. line
            line = sock:receive()
            if err then return nil, err end
        end
        
        if headers[name] then headers[name] = headers[name] .. ", " .. value
        else headers[name] = value end
    end
    return headers
end




socket.sourcet["http-chunked"] = function(sock, headers)
    return base.setmetatable({
        getfd = function() return sock:getfd() end,
        dirty = function() return sock:dirty() end
    }, {
        __call = function()
            
            local line, err = sock:receive()
            if err then return nil, err end
            local size = base.tonumber(string.gsub(line, ";.*", ""), 16)
            if not size then return nil, "invalid chunk size" end
            
            if size > 0 then
                
                local chunk, err, part = sock:receive(size)
                if chunk then sock:receive() end
                return chunk, err
            else
                
                headers, err = receiveheaders(sock, headers)
                if not headers then return nil, err end
            end
        end
    })
end

socket.sinkt["http-chunked"] = function(sock)
    return base.setmetatable({
        getfd = function() return sock:getfd() end,
        dirty = function() return sock:dirty() end
    }, {
        __call = function(self, chunk, err)
            if not chunk then return sock:send("0\r\n\r\n") end
            local size = string.format("%X\r\n", string.len(chunk))
            return sock:send(size ..  chunk .. "\r\n")
        end
    })
end




local metat = { __index = {} }

function _M.open(host, port, create)
    
    local c = socket.try((create or socket.tcp)())
    local h = base.setmetatable({ c = c }, metat)
    
    h.try = socket.newtry(function() h:close() end)
    
    h.try(c:settimeout(_M.TIMEOUT))
    h.try(c:connect(host, port or PORT))
    
    return h
end

function metat.__index:sendrequestline(method, uri)
    local reqline = string.format("%s %s HTTP/1.1\r\n", method or "GET", uri)
    return self.try(self.c:send(reqline))
end

function metat.__index:sendheaders(tosend)
    local canonic = headers.canonic
    local h = "\r\n"
    for f, v in base.pairs(tosend) do
        h = (canonic[f] or f) .. ": " .. v .. "\r\n" .. h
    end
    self.try(self.c:send(h))
    return 1
end

function metat.__index:sendbody(headers, source, step)
    source = source or ltn12.source.empty()
    step = step or ltn12.pump.step
    
    local mode = "http-chunked"
    if headers["content-length"] then mode = "keep-open" end
    return self.try(ltn12.pump.all(source, socket.sink(mode, self.c), step))
end

function metat.__index:receivestatusline()
    local status = self.try(self.c:receive(5))
    
    
    if status ~= "HTTP/" then return nil, status end
    
    status = self.try(self.c:receive("*l", status))
    local code = socket.skip(2, string.find(status, "HTTP/%d*%.%d* (%d%d%d)"))
    return self.try(base.tonumber(code), status)
end

function metat.__index:receiveheaders()
    return self.try(receiveheaders(self.c))
end

function metat.__index:receivebody(headers, sink, step)
    sink = sink or ltn12.sink.null()
    step = step or ltn12.pump.step
    local length = base.tonumber(headers["content-length"])
    local t = headers["transfer-encoding"] 
    local mode = "default" 
    if t and t ~= "identity" then mode = "http-chunked"
    elseif base.tonumber(headers["content-length"]) then mode = "by-length" end
    return self.try(ltn12.pump.all(socket.source(mode, self.c, length),
        sink, step))
end

function metat.__index:receive09body(status, sink, step)
    local source = ltn12.source.rewind(socket.source("until-closed", self.c))
    source(status)
    return self.try(ltn12.pump.all(source, sink, step))
end

function metat.__index:close()
    return self.c:close()
end




local function adjusturi(reqt)
    local u = reqt
    
    if not reqt.proxy and not _M.PROXY then
        u = {
           path = socket.try(reqt.path, "invalid path 'nil'"),
           params = reqt.params,
           query = reqt.query,
           fragment = reqt.fragment
        }
    end
    return url.build(u)
end

local function adjustproxy(reqt)
    local proxy = reqt.proxy or _M.PROXY
    if proxy then
        proxy = url.parse(proxy)
        return proxy.host, proxy.port or 3128
    else
        return reqt.host, reqt.port
    end
end

local function adjustheaders(reqt)
    
    local host = string.gsub(reqt.authority, "^.-@", "")
    local lower = {
        ["user-agent"] = _M.USERAGENT,
        ["host"] = host,
        ["connection"] = "close, TE",
        ["te"] = "trailers"
    }
    
    if reqt.user and reqt.password then
        lower["authorization"] =
            "Basic " ..  (mime.b64(reqt.user .. ":" .. reqt.password))
    end
    
    local proxy = reqt.proxy or _M.PROXY
    if proxy then
        proxy = url.parse(proxy)
        if proxy.user and proxy.password then
            lower["proxy-authorization"] =
                "Basic " ..  (mime.b64(proxy.user .. ":" .. proxy.password))
        end
    end
    
    for i,v in base.pairs(reqt.headers or lower) do
        lower[string.lower(i)] = v
    end
    return lower
end


local default = {
    host = "",
    port = PORT,
    path ="/",
    scheme = "http"
}

local function adjustrequest(reqt)
    
    local nreqt = reqt.url and url.parse(reqt.url, default) or {}
    
    for i,v in base.pairs(reqt) do nreqt[i] = v end
    if nreqt.port == "" then nreqt.port = PORT end
    if not (nreqt.host and nreqt.host ~= "") then
        socket.try(nil, "invalid host '" .. base.tostring(nreqt.host) .. "'")
    end
    
    nreqt.uri = reqt.uri or adjusturi(nreqt)
    
    nreqt.headers = adjustheaders(nreqt)
    
    nreqt.host, nreqt.port = adjustproxy(nreqt)
    return nreqt
end

local function shouldredirect(reqt, code, headers)
    local location = headers.location
    if not location then return false end
    location = string.gsub(location, "%s", "")
    if location == "" then return false end
    local scheme = string.match(location, "^([%w][%w%+%-%.]*)%:")
    if scheme and not SCHEMES[scheme] then return false end
    return (reqt.redirect ~= false) and
           (code == 301 or code == 302 or code == 303 or code == 307) and
           (not reqt.method or reqt.method == "GET" or reqt.method == "HEAD")
           and (not reqt.nredirects or reqt.nredirects < 5)
end

local function shouldreceivebody(reqt, code)
    if reqt.method == "HEAD" then return nil end
    if code == 204 or code == 304 then return nil end
    if code >= 100 and code < 200 then return nil end
    return 1
end


local trequest, tredirect

 function tredirect(reqt, location)
    local result, code, headers, status = trequest {
        
        
        url = url.absolute(reqt.url, location),
        source = reqt.source,
        sink = reqt.sink,
        headers = reqt.headers,
        proxy = reqt.proxy,
        nredirects = (reqt.nredirects or 0) + 1,
        create = reqt.create
    }
    
    headers = headers or {}
    headers.location = headers.location or location
    return result, code, headers, status
end

 function trequest(reqt)
    
    
    local nreqt = adjustrequest(reqt)
    local h = _M.open(nreqt.host, nreqt.port, nreqt.create)
    
    h:sendrequestline(nreqt.method, nreqt.uri)
    h:sendheaders(nreqt.headers)
    
    if nreqt.source then
        h:sendbody(nreqt.headers, nreqt.source, nreqt.step)
    end
    local code, status = h:receivestatusline()
    
    if not code then
        h:receive09body(status, nreqt.sink, nreqt.step)
        return 1, 200
    end
    local headers
    
    while code == 100 do
        headers = h:receiveheaders()
        code, status = h:receivestatusline()
    end
    headers = h:receiveheaders()
    
    
    if shouldredirect(nreqt, code, headers) and not nreqt.source then
        h:close()
        return tredirect(reqt, headers.location)
    end
    
    if shouldreceivebody(nreqt, code) then
        h:receivebody(headers, nreqt.sink, nreqt.step)
    end
    h:close()
    return 1, code, headers, status
end


local function genericform(u, b)
    local t = {}
    local reqt = {
        url = u,
        sink = ltn12.sink.table(t),
        target = t
    }
    if b then
        reqt.source = ltn12.source.string(b)
        reqt.headers = {
            ["content-length"] = string.len(b),
            ["content-type"] = "application/x-www-form-urlencoded"
        }
        reqt.method = "POST"
    end
    return reqt
end

_M.genericform = genericform

local function srequest(u, b)
    local reqt = genericform(u, b)
    local _, code, headers, status = trequest(reqt)
    return table.concat(reqt.target), code, headers, status
end

_M.request = socket.protect(function(reqt, body)
    if base.type(reqt) == "string" then return srequest(reqt, body)
    else return trequest(reqt) end
end)

return _M
