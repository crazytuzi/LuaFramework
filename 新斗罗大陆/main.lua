-- collectgarbage("setpause", 100) 
-- collectgarbage("setstepmul", 5000) 

COMMANDS = {}

function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("NEW LUA ERROR: " .. tostring(errorMessage) .. "\n")
    local debugTraceBack = debug.traceback("", 2)
    print(debugTraceBack)
    local errorLog = errorMessage .. "\n" .. debugTraceBack .. "\n"
    if DEBUG_PRINT_LUA_ERROR then
    	CCMessageBox(errorLog, "LUA ERROR")
    end
    QUtility:addLuaError(errorLog)

    -- 添加Bugly的Lua异常上报
    if buglyReportLuaException then
        buglyReportLuaException(errorMessage, debugTraceBack)
    end

    print("----------------------------------------")
end

function Q_AddThirdPartyLibraryPath(path)
    if path == nil then return end

    local scriptPath = QUtility:getScriptPath()
    package.path = scriptPath .. "/lib/" .. path .. "/?.lua" .. ";" .. package.path  
    print("package.path:" .. package.path)
end

function Q_ParseCommandLine()
    local input = QUtility:getCommandLine()
    print("command line:" .. input)
    local delimiter = " "
    local pos,arr = 0, {}

    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    
    local index = 1

    while index <= #arr do
        if arr[index] == "-mobdebugger" then
            require("lib.debugger.mobdebug").start("127.0.0.1")
        elseif arr[index] == "-channel-name" then
            index = index + 1
            CHANNEL_NAME = arr[index]
        elseif arr[index] == "-server-url" then
            index = index + 1
            SERVER_URL = arr[index]
        elseif arr[index] == "-static-url" then
            index = index + 1
            STATIC_URL = arr[index]
        elseif arr[index] == "-developTools" then
            ENABLE_LOAD_DEVELOP_TOOLS = true
        elseif arr[index] == "-debug=1" then
            DEBUG = 1
        elseif arr[index] == "-debug=0" then
            DEBUG = 0
        elseif arr[index] == "-quick-login" then
            index = index + 1
            QUICK_LOGIN.osdkUserId = arr[index]
            index = index + 1
            QUICK_LOGIN.gameArea = arr[index]
            QUICK_LOGIN.isQuick = true
        end
        index = index + 1
    end

    COMMANDS = arr
end

if jit then
    local isJitTurnOn = jit.status()
    if isJitTurnOn == true then
        jit.flush()
        jit.off()
    end 
end

-- if QUtility.getLuaSocketVersion then
    -- print("---s-s--s-s-s------",QUtility:getLuaSocketVersion())
    Q_AddThirdPartyLibraryPath("socketIp6")
-- else
--     Q_AddThirdPartyLibraryPath("socket")
-- end
Q_AddThirdPartyLibraryPath("protobuf")
Q_AddThirdPartyLibraryPath("XMPP")

Q_ParseCommandLine()


if jit then
    local function printLuaStatus()
        print("------------------------")
        print("jit version:" .. tostring(jit.version))
        print("jit os:" .. tostring(jit.os))
        print("jit arch:" .. tostring(jit.arch))
        local function _doPrintLuaStatus(status, ... )
            print("jit turn on:" .. tostring(status))
            local arg = { ... }
            for i = 1, #arg do
                print("arg" .. i .. ":" .. tostring(arg[i]))
            end
        end
        _doPrintLuaStatus(jit.status())
        print("------------------------")
    end
    printLuaStatus()
end

require("app.MyApp").new():start()
-- pcall(require, "test.client.test")
