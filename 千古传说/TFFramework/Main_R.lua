require('TFFramework.base.class')

function __G__TRACKBACK__(msg)
    print("----------------------------------------");
    local msg = "LUA ERROR: " .. tostring(msg) .. "/n"
    msg = msg .. debug.traceback()
    print(msg)
    -- TFLOGERROR(msg)
    
    ErrorCodeManager:reportErrorMsg(msg)

    if VERSION_DEBUG == true then
        TFLOGERROR(msg)
    else
        print("msg = ", msg)
        CommonManager:openWarningLayer()
    end
    print("----------------------------------------");
end

function gotoGameStart()
    require('TFFramework.init')
	TFDirector:startRemoteDebug()
    TFDirector:start()
    me.Director:setDisplayStats(false)

    if TFFileUtil:existFile('LuaScript/TFGameStartup.lua') then
	    local gameStartup = require('LuaScript.TFGameStartup'):new()
	    TFLogManager:sharedLogManager():TFFtpSetUpload(false)
	    gameStartup:run(TFFramework_RestartContent)
	else
        if TFFileUtil:existFile('TFGameStartup.lua') then
            local gameStartup = require('TFGameStartup'):new()
            TFLogManager:sharedLogManager():TFFtpSetUpload(false)
            gameStartup:run(TFFramework_RestartContent)
        else
            TFLOGERROR("Can't find TFGameStartup.lua")
        end
    end
end

function main()
    -- if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
    --     local updateScene = require("TFFramework.update.updateScene")
    --     updateScene:run(gotoGameStart)
    -- else
    --     DEBUG = 1
    --     gotoGameStart()
    -- end
    gotoGameStart()
end
xpcall(main, __G__TRACKBACK__);
