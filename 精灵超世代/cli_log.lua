-- --------------------------------------------------+
-- 日志上报
-- @author whjing2011@gmail.com
-- --------------------------------------------------*/

LOG_TYPE = {
    device = "device"
    ,flash = "flash"
    ,advice = "advice"
    ,load_start = "load_start"
    ,load_end = "load_end"
    ,reg_acc = "reg_acc"
    ,select_srv = "select_srv"
    ,create_role = "create_role"
    ,get_def_srv = "get_def_srv"
    ,enter_city = "enter_city"
}

-- 是否记录日志
local __is_log = true 
__is_log = __is_log and LOG_URL ~= nil and cc.CCGameLib.logsign and (PLATFORM ~= cc.PLATFORM_OS_WINDOWS and PLATFORM ~= cc.PLATFORM_OS_MAC)

-- 日志上报
function log_to_web(url_type, log_args) 
    if not __is_log then return end
    local url = LOG_URL..url_type
    local date_time = os.date("%Y-%m-%d %H:%M:%S")
    local body = "?date_time=" .. log_url_encode(date_time)
    body = body .. "&sign=" .. cc.CCGameLib:getInstance():logsign(date_time)
    for k, v in pairs(log_args) do 
        body = body .. "&" .. k .. "=" .. log_url_encode(v)
    end
    url = url .. body
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("POST", url)
    xhr:registerScriptHandler(function()
        log_to_idfa_web(body)
    end)
    xhr:send()
end

-- 上报信息到注册服
function log_to_idfa_web(body) 
    if not CONF_IDFA_WEB then return end
    local url = CONF_IDFA_WEB
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("POST", url)
    xhr:registerScriptHandler(function()
    end)
    xhr:send(body)
end

-- url编码
function log_url_encode(str)  
    str = string.gsub (str, "\n", "\r\n")  
    str = string.gsub (str, "([^%w ])",  
    function (c) return string.format ("%%%02X", string.byte(c)) end)  
    str = string.gsub (str, " ", "+")  
    return str      
end 

-- 获取设备类型
function log_get_device_type()
    if PLATFORM == cc.PLATFORM_OS_WINDOWS then
        return "win"
    elseif PLATFORM == cc.PLATFORM_OS_MAC then
        return "mac"
    elseif PLATFORM == cc.PLATFORM_OS_IPHONE then
        return "iphone"
    elseif PLATFORM == cc.PLATFORM_OS_IPAD then
        return "ipad"
    elseif PLATFORM == cc.PLATFORM_OS_ANDROID then
        return "android"
    elseif PLATFORM == cc.PLATFORM_OS_LINUX then
        return "linux"
    else
        return "other"
    end
end

-- 获取设备基本信息
function log_get_device_info0000()
    local channel = get_channel()
    return {
        device_id = getIdFa()
        -- ,device_type = log_get_device_type()
        ,device_type = cc.GameDevice:callFunc("getDeviceName", '', 0, 0, '')
        ,os = cc.GameDevice:callFunc("system_version", '', 0, 0, '')
        ,carrier = cc.GameDevice:callFunc("carrier_name", '', 0, 0, '')
        ,network_type = device.isWifiState() and "wifi" or "数据"
        ,resolution = ''
        ,product_name = GAME_CODE
        ,platform_name = PLATFORM_NAME
        ,channel_name = channel
    }
end

function log_get_device_info()
    local channel = "111"
    return {
        device_id = "111"
        -- ,device_type = log_get_device_type()
        ,device_type = "111"
        ,os = "111"
        ,carrier = "111"
        ,network_type = "111"
        ,resolution = ''
        ,product_name = GAME_CODE
        ,platform_name = PLATFORM_NAME
        ,channel_name = channel
    }
end

-- 获取日志当前标识
function log_flag(key, val)
    if not __is_log then return false end
    val = val or 1
    local file = string.format("%slog_flag.lua", cc.FileUtils:getInstance():getWritablePath())
    if __log_flag == nil then -- 取值
        __log_flag = {}
        if cc.FileUtils:getInstance():isFileExist(file) then
            local ok, ret = pcall(function() return dofile(file) end)
            if ok and type(ret) == "table" then 
                __log_flag = ret
            end
        end
    end
    local old_val = __log_flag[key]
    if old_val ~= val then  -- 更新值
        __log_flag[key] = val
        local str = "return {"
        for k, v in pairs(__log_flag) do
            if type(v) == "string" then
                str = str .. "\n  " .. k .. " = [[" .. v .. "]],"
            else
                str = str .. "\n  " .. k .. " = " .. v .. ","
            end
        end
        str = str .. "\n}"
        local f = assert(io.open(file, 'wb'))
        f:write(str)
        f:close()
    end
    return old_val ~= val
end

-- 设备激活
function log_activate_device()
    if log_flag(LOG_TYPE.device) then -- 未上报过 上报一次
        local log = log_get_device_info()
        log_to_web("/device/activation", log)
    end
end

-- 闪屏 step.1
function log_flash()
    if log_flag(LOG_TYPE.flash) then -- 未上报过 上报一次
        local log = log_get_device_info()
        log.step = 1
        log_to_web("/entry/step", log)
    end
end

-- 忠告 step.2
function log_advice()
    if log_flag(LOG_TYPE.advice) then -- 未上报过 上报一次
        local log = log_get_device_info()
        log.step = 2
        log_to_web("/entry/step", log)
    end
end

-- 加载游戏开始 step.3
function log_loading_start()
    if log_flag(LOG_TYPE.load_start) then -- 未上报过 上报一次
        local log = log_get_device_info()
        log.step = 3
        log_to_web("/entry/step", log)
    end
end

-- 加载游戏结束 step.4
function log_loading_end()
    if log_flag(LOG_TYPE.load_end) then -- 未上报过 上报一次
        local log = log_get_device_info()
        log.step = 4
        log_to_web("/entry/step", log)
    end
end

-- 注册账号 step.5
function log_reg_account(account)
    if log_flag(LOG_TYPE.reg_acc) then -- 未上报过 上报一次
        local log = log_get_device_info()
        log.step = 5
        log.account_id = account
        log.account_name = account
        log_to_web("/entry/step", log)
    end
end

-- 选服 step.6
function log_select_server(account)
    if log_flag(LOG_TYPE.select_srv) then -- 未上报过 上报一次
        local log = log_get_device_info()
        log.step = 6
        log.account_id = account
        log.account_name = account
        log_to_web("/entry/step", log)
    end
end

-- 创建角色 step.7
function log_create_role(account)
    if log_flag(LOG_TYPE.create_role) then -- 未上报过 上报一次
        local log = log_get_device_info()
        log.step = 7
        log.account_id = account
        log.account_name = account
        log_to_web("/entry/step", log)
    end
end

-- 起名 step.8
function log_enter_city(account)
    if log_flag(LOG_TYPE.enter_city) then -- 未上报过 上报一次
        local log = log_get_device_info()
        log.step = 8
        log.account_id = account
        log.account_name = account
        log_to_web("/entry/step", log)
    end
end

-- 获取到默认服 step.9
function log_get_def_srv(account)
    -- if log_flag(LOG_TYPE.get_def_srv) then -- 未上报过 上报一次
    --     local log = log_get_device_info()
    --     log.step = 9
    --     log.account_id = account
    --     log.account_name = account
    --     log_to_web("/entry/step", log)
    -- end
end

log_activate_device() -- 加载文件开始上报激活设备
log_flash()
