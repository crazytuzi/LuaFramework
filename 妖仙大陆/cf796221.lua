local sRootPath = 'design/' 





local Sandbox = require 'Zeus.Logic.Sandbox'
local getSandbox = Sandbox.getSandbox

local loadfile = loadfile
local setfenv = setfenv
local pcall = pcall
local assert = assert

local tCache = {}
local tCacheEnv = {}

local _M = {
    _VERSION = '1.0',
    RootPath = sRootPath,
}

local function safeLoad(filename)
    local f, r = _M.load(filename)
    
    assert(f, r)
    return r
end

function _M.load(sFileName, bNotUseCache)
    if not bNotUseCache then
        local cached = tCache[sFileName]
        if cached then return true, cached end
    end

    local fUntrusted, sMessage = loadfile(sRootPath..sFileName)
    if not fUntrusted then return nil, sMessage end
    local tSandbox = getSandbox()
    tSandbox.load = safeLoad
    function process()
        local _ENV = tSandbox
        if setfenv then
            setfenv(fUntrusted, tSandbox)
        end
        
        return pcall(fUntrusted)
    end
    local ok, res = process()

    if not bNotUseCache and ok then
        tCache[sFileName] = res
    end
    print('_M.load(sFileName, bNotUseCache)')
    return ok, res
end

function _M.loadAndGetEnv(sFileName, bNotUseCache, tFuns)
    if not bNotUseCache then
        local cached = tCacheEnv[sFileName]
        if cached then return true, cached end
    end

    local fUntrusted, sMessage = loadfile(sRootPath..sFileName)
    if not fUntrusted then return nil, sMessage end
    local tSandbox = getSandbox()
    tSandbox.load = safeLoad
    if tFuns then
        for k,v in pairs(tFuns) do
            tSandbox[k] = v
        end
    end
    local function process()
        if type(fUntrusted) ~= 'function' then
            return false,fUntrusted
        end
        local _ENV = tSandbox
        if setfenv then
            setfenv(fUntrusted, tSandbox)
        end
        
        return pcall(fUntrusted)
    end
    local ok, res = process()

    if not ok then return nil, res end       
    

    if not bNotUseCache and ok then
        tCacheEnv[sFileName] = tSandbox
    end
    return ok, tSandbox
end

function _M.get_class_data_func(sClass, is_not_use_cache)
  return function(file_name, is_has_ext)
    local ext = '.lua'
    if is_has_ext then
       ext = '' 
    end
    local ok, data = _M.load(sClass..file_name..ext, is_not_use_cache)
    assert(ok, data)
    return data
  end
end

return _M
