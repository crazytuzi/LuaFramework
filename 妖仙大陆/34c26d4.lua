








local string = require("string")
local table = require("table")
local unpack = unpack or table.unpack
local base = _G
local _M = {}
if module then 
    ltn12 = _M
end
local filter,source,sink,pump = {},{},{},{}

_M.filter = filter
_M.source = source
_M.sink = sink
_M.pump = pump

local unpack = unpack or table.unpack
local select = base.select


_M.BLOCKSIZE = 2048
_M._VERSION = "LTN12 1.0.3"





function filter.cycle(low, ctx, extra)
    base.assert(low)
    return function(chunk)
        local ret
        ret, ctx = low(ctx, chunk, extra)
        return ret
    end
end



function filter.chain(...)
    local arg = {...}
    local n = base.select('#',...)
    local top, index = 1, 1
    local retry = ""
    return function(chunk)
        retry = chunk and retry
        while true do
            if index == top then
                chunk = arg[index](chunk)
                if chunk == "" or top == n then return chunk
                elseif chunk then index = index + 1
                else
                    top = top+1
                    index = top
                end
            else
                chunk = arg[index](chunk or "")
                if chunk == "" then
                    index = index - 1
                    chunk = retry
                elseif chunk then
                    if index == n then return chunk
                    else index = index + 1 end
                else base.error("filter returned inappropriate nil") end
            end
        end
    end
end





local function empty()
    return nil
end

function source.empty()
    return empty
end


function source.error(err)
    return function()
        return nil, err
    end
end


function source.file(handle, io_err)
    if handle then
        return function()
            local chunk = handle:read(_M.BLOCKSIZE)
            if not chunk then handle:close() end
            return chunk
        end
    else return source.error(io_err or "unable to open file") end
end


function source.simplify(src)
    base.assert(src)
    return function()
        local chunk, err_or_new = src()
        src = err_or_new or src
        if not chunk then return nil, err_or_new
        else return chunk end
    end
end


function source.string(s)
    if s then
        local i = 1
        return function()
            local chunk = string.sub(s, i, i+_M.BLOCKSIZE-1)
            i = i + _M.BLOCKSIZE
            if chunk ~= "" then return chunk
            else return nil end
        end
    else return source.empty() end
end


function source.rewind(src)
    base.assert(src)
    local t = {}
    return function(chunk)
        if not chunk then
            chunk = table.remove(t)
            if not chunk then return src()
            else return chunk end
        else
            table.insert(t, chunk)
        end
    end
end


function source.chain(src, f, ...)
    if ... then f=filter.chain(f, ...) end
    base.assert(src and f)
    local last_in, last_out = "", ""
    local state = "feeding"
    local err
    return function()
        if not last_out then
            base.error('source is empty!', 2)
        end
        while true do
            if state == "feeding" then
                last_in, err = src()
                if err then return nil, err end
                last_out = f(last_in)
                if not last_out then
                    if last_in then
                        base.error('filter returned inappropriate nil')
                    else
                        return nil
                    end
                elseif last_out ~= "" then
                    state = "eating"
                    if last_in then last_in = "" end
                    return last_out
                end
            else
                last_out = f(last_in)
                if last_out == "" then
                    if last_in == "" then
                        state = "feeding"
                    else
                        base.error('filter returned ""')
                    end
                elseif not last_out then
                    if last_in then
                        base.error('filter returned inappropriate nil')
                    else
                        return nil
                    end
                else
                    return last_out
                end
            end
        end
    end
end




function source.cat(...)
    local arg = {...}
    local src = table.remove(arg, 1)
    return function()
        while src do
            local chunk, err = src()
            if chunk then return chunk end
            if err then return nil, err end
            src = table.remove(arg, 1)
        end
    end
end





function sink.table(t)
    t = t or {}
    local f = function(chunk, err)
        if chunk then table.insert(t, chunk) end
        return 1
    end
    return f, t
end


function sink.simplify(snk)
    base.assert(snk)
    return function(chunk, err)
        local ret, err_or_new = snk(chunk, err)
        if not ret then return nil, err_or_new end
        snk = err_or_new or snk
        return 1
    end
end


function sink.file(handle, io_err)
    if handle then
        return function(chunk, err)
            if not chunk then
                handle:close()
                return 1
            else return handle:write(chunk) end
        end
    else return sink.error(io_err or "unable to open file") end
end


local function null()
    return 1
end

function sink.null()
    return null
end


function sink.error(err)
    return function()
        return nil, err
    end
end


function sink.chain(f, snk, ...)
    if ... then
        local args = { f, snk, ... }
        snk = table.remove(args, #args)
        f = filter.chain(unpack(args))
    end
    base.assert(f and snk)
    return function(chunk, err)
        if chunk ~= "" then
            local filtered = f(chunk)
            local done = chunk and ""
            while true do
                local ret, snkerr = snk(filtered, err)
                if not ret then return nil, snkerr end
                if filtered == done then return 1 end
                filtered = f(done)
            end
        else return 1 end
    end
end





function pump.step(src, snk)
    local chunk, src_err = src()
    local ret, snk_err = snk(chunk, src_err)
    if chunk and ret then return 1
    else return nil, src_err or snk_err end
end


function pump.all(src, snk, step)
    base.assert(src and snk)
    step = step or pump.step
    while true do
        local ret, err = step(src, snk)
        if not ret then
            if err then return nil, err
            else return 1 end
        end
    end
end

return _M
