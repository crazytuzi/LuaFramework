--[[
    @Author nan.zhang
    @Brief  create validation tree and compare later, quit app if any failure.
]]



local QLogFile = import(".QLogFile")

local function mixValue(value)
    return QUtility:float_to_uint32(value)
end
local function validateValue(value, mixedValue)
    if mixedValue ~= mixValue(value)then
        if device.platform == "mac" or device.platform == "pc" then
            scheduler.performWithDelayGlobal(function()
                os.exit()
            end, 3)
            CCMessageBox("检查到数值校验错误，可能存在未被验证的数据修改！游戏即将退出！", "")
            assert(false, "检查到数值校验错误，可能存在未被验证的数据修改！游戏即将退出！")
        else
            while true do
                QLogFile:error("QValidation: validation failure, game will be terminated!")
                QLogFile:error(debug.traceback())
                os.exit() 
            end
        end
    end
end
-- create number validation object
function q.createValidation(value)
    local v = nil
    if value ~= nil then
        v = mixValue(value)
    end
    local obj = {}
    function obj:set(new_value)
        v = mixValue(new_value)
    end
    function obj:validate(old_value)
        if v ~= nil and old_value ~= nil then
            validateValue(old_value, v) 
        end
    end
    return obj
end
local function _createValidationForTable(t)
    local obj = {}
    for k, v in pairs(t) do
        if type(v) == "number" then
            obj[k] = mixValue(v)
        elseif type(v) == "table" then
            obj[k] = _createValidationForTable(v)
        end
    end
    return obj
end
local function _validateForTable(t, tv)
    if type(tv) ~= "table" then
        return
    end
    for k, v in pairs(t) do
        if type(v) == "number" then
            validateValue(v, tv[k])
        elseif type(v) == "table" then
            _validateForTable(v, tv[k])
        end
    end
end
function q.createValidationForTable(t)
    return _createValidationForTable(t)
end
function q.validateForTable(t, tv)
    return _validateForTable(t, tv)
end

-- create QRenderTexture, redraw only 1 frame
function q.createQRenderTexture(width, height)
    local rt = CCRenderTexture:create(width, height)
    rt:setClearFlags(4 * 16 * 16 * 16) -- Warning: GL_COLOR_BUFFER_BIT is platform dependent!
    rt:setAutoDraw(true)
    rt:retain()
    scheduler.performWithDelayGlobal(function()
        rt:setAutoDraw(false)
        rt:release()
    end, 0)
    return rt
end

function  q.safeSetValue(t, ...)
    if t == nil then
        return
    end
    local args = {...}
    local t = t
    local k = args[1]
    local subt = nil
    for i = 1, (#args - 2) do
        subt = t[k]
        if subt == nil then
            subt = {}
            t[k] = subt
        end
        t = subt
        k = args[i + 2]
    end
    if t and k and args[#args] then
        t[k] = args[#args]
    end
end

function q.safeGetValue(t, ...)
    if t == nil then
        return
    end
    local args = {...}
    local t = t
    local k = args[1]
    local subt = nil
    for i = 1, (#args - 1) do 
        subt = t[k]
        if subt == nil then
            return nil
        end
        t = subt
        k = args[i + 1]
    end
    if t and k then
        return t[k]
    end
end

function  q.safeAddValue(t, ...)
    if t == nil or type(t) ~= "table" then
        return
    end
    local args = {...}
    local t = t
    local k = args[1]
    local subt = nil
    for i = 1, (#args - 2) do
        subt = t[k]
        if subt == nil then
            subt = {}
            t[k] = subt
        end
        t = subt
        k = args[i + 1]
    end
    if t and k and args[#args] then
        local old_value = t[k] or 0
        t[k] = old_value + args[#args]
    end
end