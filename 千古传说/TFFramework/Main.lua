require('TFFramework.base.class')

__G_ERROR_CALLBACK__ = nil

function __G__TRACKBACK__(msg)
    print("----------------------------------------");
    local msg = "LUA ERROR: " .. tostring(msg) .. "/n"
    msg = msg .. debug.traceback()
    -- TFLOGERROR(msg)
    -- print("----------------------------------------");
    -- if __G_ERROR_CALLBACK__ and type(__G_ERROR_CALLBACK__) == "function" then 
    --     __G_ERROR_CALLBACK__() 
    -- end
    
    ErrorCodeManager:reportErrorMsg(msg)

    if VERSION_DEBUG == true then
        TFLOGERROR(msg)
    else
        print("msg = ", msg)
        -- CommonManager:showOperateSureLayer(
        --     function()
        --         AlertManager:changeSceneForce(SceneType.LOGIN)
        --     end,
        --     function()
        --         AlertManager:close()
        --     end,
        --     {
        --         title =  "温馨提示",
        --         msg   = "大侠你的程序因为戴维康的bug挂掉了"
        --     }
        -- )

        CommonManager:openWarningLayer()
    end
end

function gotoGameStart()
    collectgarbage("stop")
    require('TFFramework.init')
    collectgarbage("collect")

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
    -- if CC_TARGET_PLATFORM ~= CC_PLATFORM_WIN32 then
    --     local updateScene = require("TFFramework.update.updateScene")
    --     updateScene:run(gotoGameStart)
    -- else
    --     DEBUG = 1
    --     gotoGameStart()
    -- end

    -- DEBUG = 1
    gotoGameStart()

end
xpcall(main, __G__TRACKBACK__);
