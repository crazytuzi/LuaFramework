--[[
    文件名：main.lua
    描述：游戏进入首文件
    创建人：廖元刚
    创建时间：2016.3.29
-- ]]

cc.FileUtils:getInstance():setPopupNotify(true)

require "config"
require "cocos.init"

-- 是否需要弹窗显示调用栈错误信息
ShowTracebackMsg = false
-- 是否需要启动网络请求
NeedLanchRequest = true

local requireList = {"main" }

if oneTime == nil then
    orgRequire = require
end
oneTime = oneTime or 0

function newRequire(str)
    if not package.loaded[str] then
        table.insert(requireList, str)
    end
    return orgRequire(str)
end
require = newRequire

CCLog = function(...)
    IPlatform:getInstance():dump(string.format(...))
end

local function main()
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    require("game").new():run()
end

getRequireList = function()
    return  requireList
end

clearRequireList = function()
    for i ,v in ipairs(getRequireList()) do
        if package.loaded[v] then
            package.loaded[v] = nil
        end
    end

    requireList = {"main"}
end

-- lua 异常信息回调函数
function __G__TRACKBACK__(msg)
    local tracebackStr = debug.traceback(msg, 3)
    CCLog("MQE:\n----------------------------------------\n" .. 
        tracebackStr .. "\n" .. 
        "----------------------------------------\n")
    
    if device.platform == "ios" then
        buglyReportLuaException(msg, debug.traceback())
    end

    if ShowTracebackMsg then
        require("commonLayer.MsgBoxLayer")
        MsgBoxLayer.addLongTextLayer(tracebackStr)
    end
    
    return msg
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
