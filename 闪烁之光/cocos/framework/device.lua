--[[

Copyright (c) 2011-2014 chukong-inc.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

local device = {}

device.platform    = "unknown"
device.model       = "unknown"

local app = cc.Application:getInstance()
local target = app:getTargetPlatform()
if target == cc.PLATFORM_OS_WINDOWS then
    device.platform = "windows"
elseif target == cc.PLATFORM_OS_MAC then
    device.platform = "mac"
elseif target == cc.PLATFORM_OS_ANDROID then
    device.platform = "android"
elseif target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then
    device.platform = "ios"
    local director = cc.Director:getInstance()
    local view = director:getOpenGLView()
    local framesize = view:getFrameSize()
    local w, h = framesize.width, framesize.height
    if w == 640 and h == 960 then
        device.model = "iphone 4"
    elseif w == 640 and h == 1136 then
        device.model = "iphone 5"
    elseif w == 750 and h == 1334 then
        device.model = "iphone 6"
    elseif w == 1242 and h == 2208 then
        device.model = "iphone 6 plus"
    elseif w == 768 and h == 1024 then
        device.model = "ipad"
    elseif w == 1536 and h == 2048 then
        device.model = "ipad retina"
    end
elseif target == cc.PLATFORM_OS_WINRT then
    device.platform = "winrt"
elseif target == cc.PLATFORM_OS_WP8 then
    device.platform = "wp8"
end

device.platform_os = target

local language_ = app:getCurrentLanguage()
if language_ == cc.LANGUAGE_CHINESE then
    language_ = "cn"
elseif language_ == cc.LANGUAGE_FRENCH then
    language_ = "fr"
elseif language_ == cc.LANGUAGE_ITALIAN then
    language_ = "it"
elseif language_ == cc.LANGUAGE_GERMAN then
    language_ = "gr"
elseif language_ == cc.LANGUAGE_SPANISH then
    language_ = "sp"
elseif language_ == cc.LANGUAGE_RUSSIAN then
    language_ = "ru"
elseif language_ == cc.LANGUAGE_KOREAN then
    language_ = "kr"
elseif language_ == cc.LANGUAGE_JAPANESE then
    language_ = "jp"
elseif language_ == cc.LANGUAGE_HUNGARIAN then
    language_ = "hu"
elseif language_ == cc.LANGUAGE_PORTUGUESE then
    language_ = "pt"
elseif language_ == cc.LANGUAGE_ARABIC then
    language_ = "ar"
else
    language_ = "en"
end

device.language = language_
device.writablePath = cc.FileUtils:getInstance():getWritablePath()
device.directorySeparator = "/"
device.pathSeparator = ":"
if device.platform == "windows" then
    device.directorySeparator = "\\"
    device.pathSeparator = ";"
end

--[[
    获取设备名称
]]
function device.getDeviceName()
    return device.callFunc("getDeviceName")
end

--==============================--
--desc:刘海屏
--time:2018-07-21 12:25:55
--@return 
--==============================--
function device.hasNotchInScreen()
    return device.callFunc("hasNotchInScreen")
end

--==============================--
--desc:内存大小   / 1024 + 0.5  对比 1 为低内存  2 为中内存 3 为高内存
--time:2019-01-08 04:31:15
--@return 
--==============================--
function device.sysTotalSize()
    return device.callFunc("sysTotalSize")
end

--[[
    获得设备号
]]
function device.getIdFa()
    return device.callFunc("idfa")
end

--[[
    个推账号id
]]
function device.getuiId()
    return device.callFunc("getuiId")
end

--[[
    是否是wifi环境
]]
function device.isWifiState()
    return device.sdkCallFunc("wifiState") == 3
end

-- [[
-- 渠道ID
-- ]]
function device.getChannel()
    local channel = device.callFunc("channel")
    local sub_channel = device.callFunc("sub_channel")
    if channel ~= "" and sub_channel ~= "" and CHANNEL_MERGE == true then
        channel = channel .. "_" .. sub_channel
    end
    return channel
end

--[[
    当前电量剩余
]]
function device.getBatteryLevel()
    return device.sdkCallFunc("batteryLevel")
end

--[[
    回调C++方法,该接口返回字符串数值
    @param:arg1 为字符串
    @param:arg2 为整型
    @param:arg3 为浮点
    @param:arg4 为字符串
]]
function device.callFunc(funcname, arg1, arg2, arg3, arg4)
    if not cc.GameDevice.callFunc or funcname == nil or funcname == "" then 
        return ""
    end
    arg1 = arg1 or ""
    arg2 = arg2 or 0
    arg3 = arg3 or 0
    arg4 = arg4 or ""
    return cc.GameDevice:callFunc(funcname, arg1, arg2, arg3, arg4)
end

--[[
    回调C++方法,该方法返回整型值
    @param:arg1 为字符串
    @param:arg2 为整型
    @param:arg3 为浮点
    @param:arg4 为字符串
]]
function device.sdkCallFunc(funcname, arg1, arg2, arg3, arg4)
    if funcname == "sdkExit" then
        return cc.Director:getInstance():endToLua()
    end
    if not cc.GameDevice.sdkCallFunc or funcname == nil or funcname == "" then 
        return -1
    end
    arg1 = arg1 or ""
    arg2 = arg2 or 0
    arg3 = arg3 or 0
    arg4 = arg4 or ""
    return cc.GameDevice:sdkCallFunc(funcname, arg1, arg2, arg3, arg4)
end

-- printInfo("# device.platform              = " .. device.platform)
-- printInfo("# device.model                 = " .. device.model)
-- printInfo("# device.language              = " .. device.language)
-- printInfo("# device.writablePath          = " .. device.writablePath)
-- printInfo("# device.directorySeparator    = " .. device.directorySeparator)
-- printInfo("# device.pathSeparator         = " .. device.pathSeparator)
-- printInfo("#")

return device
