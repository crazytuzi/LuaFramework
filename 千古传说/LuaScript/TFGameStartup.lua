--[[--
	游戏启动器:

	--By: yun.bo
	--2013/7/8
]]

--1、使用测试资源服务器，外网服务器 
--2、使用本地服务器列表
IS_TEST_GAME = false;

CCLog_setDebugFileEnabled(0)

-- 是否使用本地的服务器列表
USE_LOCAL_SERVERLIST = false

-- 测试版本 true为调试版本  false为发布版本
VERSION_DEBUG = true

if VERSION_DEBUG == true then
	HeitaoSdk = nil
    CCLog_setDebugFileEnabled(1) --开启调试模式
    USE_LOCAL_SERVERLIST = false
end

local __addMEListener = CCNode.addMEListener
local function addMEListener(sender, nType, handle, clickEffectType)
    local self = sender
    if nType == TFWIDGET_CLICK then

        if sender.haveAddMEListener == nil then
            -- 判断是否在滚动页面中
            local function isInScrl(node)
                local parent = node:getParent();
                if parent then
                    local nodetype = tolua.type(parent)
                    -- print("nodetype",nodetype,sender:getName())
                    if nodetype == 'TFScrollView' or nodetype == 'TFTableViewCell' or nodetype == 'TFPageView' then
                        -- print("isInScrl true")
                        return true;
                    else
                        return isInScrl(parent);
                    end
                else
                    -- print("isInScrl false")
                    return false;
                end
            end


            if isInScrl(sender) then
                -- sender:setClickAreaLength(10);
            else
                sender:setClickAreaLength(100);
            end


            clickEffectType = clickEffectType or 0;
            if tolua.type(sender) == 'TFButton' and clickEffectType == 1 then
                sender:setClickScaleEnabled(true)
                sender:setClickHighLightEnabled(false)
            end

            sender.haveAddMEListener = true;
        end

        local function tHandle(sender, ...)
            -- sender:setTouchEnabled(false)
            -- TFDirector:setTouchEnabled(false);
            -- if sender.timeOut then
            --     local nDT  = 0
            --     sender:timeOut(function()
            --         sender:setTouchEnabled(true)
            --     end, nDT)
            -- end

            local function timerCom()
                TFDirector:setTouchEnabled(true);
            end
            -- TFDirector:addTimer(0, 1, nil, timerCom);

            handle(sender, ...)
        end
        __addMEListener(self, nType, tHandle)
    else
        __addMEListener(self, nType, handle)
    end
end
rawset(CCNode, "addMEListener", addMEListener)


if CC_TARGET_PLATFORM ~= CC_PLATFORM_IOS then
    --重写TFLabel setFontSize方法
    --处理跨平台字体大小不一致的情况

    local ios_width = 528;
    local ios_height = 29;

    local testLabel = TFLabel:create()
    testLabel:setText("中中中中中中中中中中中中中中中中中中中中中中")
    testLabel:setFontSize(24)
    local testSize = testLabel:getSize();

    local scale_width = ios_width/testSize.width;
    local scale_height = ios_height/testSize.height;
    scale_width = math.min(1,scale_width);
    scale_height = math.min(1,scale_height);
    
    local scale = math.min(scale_width,scale_height);

    local __MELabel_setFontSize = TFLabel.setFontSize
    local function TFLabel_setFontSize(obj,size)
        __MELabel_setFontSize(obj,math.floor(size * scale))
    end
    rawset(TFLabel, "setFontSize", TFLabel_setFontSize)


    local __METextArea_setFontSize = TFTextArea.setFontSize
    local function TFTextArea_setFontSize(obj,size)
        __METextArea_setFontSize(obj,math.floor(size * scale))
    end
    rawset(TFTextArea, "setFontSize", TFTextArea_setFontSize)


    local __METextField_setFontSize = TFTextField.setFontSize
    local function TFTextField_setFontSize(obj,size)
        __METextField_setFontSize(obj,math.floor(size * scale))
    end
    rawset(TFTextField, "setFontSize", TFTextField_setFontSize)

    local __MERichText_create = TFRichText.create
    local function TFRichText_create(obj,size)
        local obj_new = __MERichText_create(obj,size)
        obj_new:setScale(scale);
        return obj_new;
    end
    rawset(TFRichText, "create", TFRichText_create) 

    local __MERichText_setScale = CCNode.setScale
    local function TFRichText_setScale(obj,_scale)
        __MERichText_setScale(obj,_scale * scale)
    end
    rawset(TFRichText, "setScale", TFRichText_setScale) 
end

function setClickScaleEnabled(sender,isEnabled)
    -- sender:setClickScaleEnabled(isEnabled)
    -- sender:setClickHighLightEnabled(not isEnabled)
end

local TFGameStartup = class('TFGameStartup')

function TFGameStartup:startGame1()
  CCDirector:sharedDirector():setDisplayStats(true)
  TFResolution:setResolutionRect(960, 640, 960, 640)
  TFDirector:changeScene(SceneType.LOGIN)
end

function TFGameStartup:startGame()
  CCDirector:sharedDirector():setDisplayStats(true)
  TFResolution:setResolutionRect(1300, 780, 1300, 780)
  TFDirector:changeScene('M_pro.LuaScript.scene.server.ServerScene')
end

function TFGameStartup.completeHandle(szversion, szName , nLen ,nLeft, nMax)
    if nLeft == 0 then
        TFGameStartup:startGame1()
        return
    end
end

function TFGameStartup:run(strrest)
    TFDirector:setTouchEnabled(true);

    if TFClientResourceUpdate == nil then 
        print("---TFGameStartup:run 没有最新的资源更新功能")

    else
        print("---TFGameStartup:run 有最新的资源更新功能")
    end

    -- SCREEN_ORIENTATION_PORTRAIT --竖屏
    -- SCREEN_ORIENTATION_LANDSCAPE --横屏
	if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
		-- TFLuaOcJava.setScreenOrientation(SCREEN_ORIENTATION_LANDSCAPE)
	end

    -- TFClientUpdate:SetUpdateDefaultVersion("1.2.0")

    local pDirector = CCDirector:sharedDirector();

    -- local frameSize = pDirector:getOpenGLView():getFrameSize()
    -- print("frameSize = ", frameSize)

    if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
        -- pDirector:getOpenGLView():setFrameSize(1136, 640);
        -- pDirector:getOpenGLView():setFrameSize(1024, 768);
        -- pDirector:getOpenGLView():setFrameSize(1280, 720);
        pDirector:getOpenGLView():setFrameSize(1136, 640);
        -- pDirector:getOpenGLView():setFrameSize(960, 640);
        -- mi pad
        -- pDirector:getOpenGLView():setFrameSize(2048 * 0.6, 1536 * 0.6);
    end

    --适配方案实现  by ghd
    local frameSize = pDirector:getOpenGLView():getFrameSize();
    local baseSize = CCSize(960 , 640);


    local realSize = CCSize(math.ceil(frameSize.width * baseSize.height / frameSize.height) , baseSize.height);

    if (realSize.width >= 1136)  then
       --背景图片最长为1136，所以设置上限
       pDirector:getOpenGLView():setDesignResolutionSize(1136, realSize.height, kResolutionShowAll);
    elseif (realSize.width >= baseSize.width) then
        --960 - 1136，通过对齐等方案，实现适配
        pDirector:getOpenGLView():setDesignResolutionSize(realSize.width, realSize.height, kResolutionShowAll);
    else
        -- realSize = CCSize(baseSize.width, math.ceil(frameSize.height * baseSize.width / frameSize.width));
        -- pDirector:getOpenGLView():setDesignResolutionSize(realSize.width, realSize.height, kResolutionShowAll);
        
        --UI制作安全大小为960，所以设置下限
        pDirector:getOpenGLView():setDesignResolutionSize(baseSize.width, realSize.height, kResolutionShowAll);
    end

    -- pDirector:getOpenGLView():setDesignResolutionSize(baseSize.width, baseSize.height, kResolutionShowAll);
   
	-- use multiple touch event
	TFDirector:setTouchSingled(true)

    -- turn on display FPS
    pDirector:setDisplayStats(false);

    --set FPS. the default value is 1.0/60 if you don't call this
    pDirector:setAnimationInterval(1.0 / 30.0);


    -- -- TF_DEBUG_UPDATE_FLAG == 1 or 
    -- -- if TF_DEBUG_UPDATE_FLAG == 1 or  CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 or strrest == "CompleteUpdate" then
     --    collectgarbage("stop")
    	-- TFLuaTime:b()
     --    require('lua.gameinit')
    	-- TFLuaTime:e("Init: ")
     --    collectgarbage("collect")
     --    TFDirector:changeScene(SceneType.LOGIN)
    -- -- else  
    -- --     self:initSDK()
    -- -- end

    -- self:enterGameWithUpdate()

    self:initSDK()
    
    -- 资源更新检查完成走这个逻辑
    if strrest == "CompleteUpdate" then
        print("============检查更新完成 CompleteUpdate==============")
        
        collectgarbage("stop")
        TFLuaTime:b()
        require('lua.gameinit')
        TFLuaTime:e("Init: ")
        collectgarbage("collect")
        TFDirector:changeScene(SceneType.LOGIN)
        return
    elseif strrest == "EnterGame" then
        print("============显示完默认界面马上进入游戏 EnterGame==============")
        
        -- self:enterGameWithUpdate()
        collectgarbage("stop")
        TFLuaTime:b()
        require('lua.gameinit')
        TFLuaTime:e("Init: ")
        collectgarbage("collect")
        -- local UpdateLayer   = require("lua.logic.login.UpdateLayer")
        -- TFDirector:changeScene(UpdateLayer:scene())
        TFDirector:changeScene(SceneType.LOGIN)
        return    

    elseif strrest == "loginOut" then
        print("============游戏注销回到登录界面 loginOut==============")
        
        -- self:enterGameWithUpdate()
        collectgarbage("stop")
        TFLuaTime:b()
        require('lua.gameinit')
        TFLuaTime:e("Init: ")
        collectgarbage("collect")
        local LoginNoticePage = require("lua.logic.login.LoginNoticePage")

        TFDirector:changeScene(LoginNoticePage:scene())
        return


    else
        print("============进入游戏 默认界面 ==============")
        collectgarbage("stop")
        TFLuaTime:b()
        require('lua.gameinit')
        TFLuaTime:e("Init: ")
        collectgarbage("collect")

        -- 有配置文件则进行闪屏
        if TFFileUtil:existFile("default/defultdisplay.lua") then
            print("进入默认界面")
           TFDirector:changeScene(SceneType.DEFAULT)
            -- TFDirector:changeScene(SceneType.TESTBATTLE)

        -- 直接进入游戏逻辑
        else
            print("进入游戏界面")
            -- local UpdateLayer   = require("lua.logic.login.UpdateLayer")
            -- TFDirector:changeScene(UpdateLayer:scene())
            
            if TFClientResourceUpdate == nil then 
                local UpdateLayer   = require("lua.logic.login.UpdateLayer")
                AlertManager:changeScene(UpdateLayer:scene())
            else
                local UpdateLayer   = require("lua.logic.login.UpdateLayer_new")
                AlertManager:changeScene(UpdateLayer:scene())
            end
        end
    end

    -- if TFPlugins.isPluginExist() then
    -- -- if TFPlugins.getChannelId() ~= "" then
    --     self:initSDK()
    -- elseif HeitaoSdk then
    --     self:initSDK()

        
    --     collectgarbage("stop")
    --     TFLuaTime:b()
    --     require('lua.gameinit')
    --     TFLuaTime:e("Init: ")
    --     collectgarbage("collect")
    --     TFDirector:changeScene(SceneType.DEFAULT)

    --     -- self:enterGameWithUpdate()
    -- else

    --     self:enterGameWithUpdate()

    --     -- collectgarbage("stop")
    --     -- TFLuaTime:b()
    --     -- require('lua.gameinit')
    --     -- TFLuaTime:e("Init: ")
    --     -- collectgarbage("collect")
    --     -- TFDirector:changeScene(SceneType.LOGIN)
    -- end



    if me.Director.setAutoFreeEnabled and me.platform == "android" then 
        me.isAutoFreeRes = true
        me.Director:setAutoFreeEnabled(true, 150, 33)
    end

end


function TFGameStartup:initSDK()

    --showLoading()
    local function onSdkPlatformLogout()
        print("onSdkPlatformLogout")
        -- CommonManager:closeConnection()
        -- restartLuaEngine("CompleteUpdate")
        MainPlayer:reset()
 
        AlertManager:clearAllCache()
        CommonManager:closeConnection()
        local LoginNoticePage = require("lua.logic.login.LoginNoticePage")

        -- TFDirector:changeScene(LoginNoticePage:scene())
        if Public:currentScene().__cname == "FightScene" then
            FightManager:Reset()
            GameResourceManager:MemoryWarning()
            
            -- AlertManager:changeScene(SceneType.LOGINNOTICE, nil, TFSceneChangeType_PopBack)
            AlertManager:changeScene(SceneType.LOGINNOTICE)

        -- elseif Public:currentScene().__cname == "LoginScene" then

        --     local currentScene = Public:currentScene()
        --     if currentScene ~= nil and currentScene.getTopLayer then
        --         currentScene:getTopLayer()::CloseGameBeginVideo()
        --     end

        else
            if TFWebView then
                TFWebView.removeWebView()
            end

            AlertManager:changeScene(SceneType.LOGINNOTICE)
        end

        -- TFLOGERROR("onSdkPlatformLogout")
        -- TFDirector:dispatchGlobalEventWith("onSdkPlatformLogout", {})
        -- print('TFDirector:dispatchGlobalEventWith("onSdkPlatformLogout", {})')
    end

    local function onSdkPlatformLeave()
        TFLuaTime:begin()
        TFLuaTime:endToLua("onSdkPlatformLeave")
        TFDirector:dispatchGlobalEventWith("onSdkPlatformLeave", {})
        print('TFDirector:dispatchGlobalEventWith("onSdkPlatformLeave", {})')
    end



    local function onSdkPlatformInited(code, msg)
        if code == UserActionResultCode.kInitSuccess then  --初始化SDK成功回调
            -- if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
            if 1 then
                require('lua.gameinit')
                TFDirector:changeScene(SceneType.LOGIN)
            else
                print("检测资源更新1")
                require('lua.table.TFMapArray')
                LoadingLayer        = require("lua.logic.common.AudioFun")
                AlertManager        = require('lua.public.AlertManager')
                Public              = require("lua.public.Public")
                BaseLayer           = require('lua.logic.BaseLayer')
                BaseScene           = require('lua.logic.BaseScene')
                SceneType           = require('lua.logic.SceneType');
                GameConfig          = require('lua.logic.common.GameConfig');
                LoadingLayer        = require("lua.logic.common.LoadingLayer")
                ToastMessage        = require("lua.logic.common.ToastMessage")
                local UpdateLayer   = require("lua.logic.login.UpdateLayer")
                TFDirector:changeScene(UpdateLayer:scene())
            end
            --sdk初始化成功，游戏相关处理
        elseif code == UserActionResultCode.kInitFail  then   --初始化SDK失败回调
            --sdk初始化失败，游戏相关处理
            
        end


    end
    
    if TFPlugins.isPluginExist() then
        TFPlugins.setInitCallBack(onSdkPlatformInited)
        TFPlugins.setLoginOutCallBack(onSdkPlatformLogout)
        TFPlugins.setLeaveCallBack(onSdkPlatformLeave)

        TFPlugins.InitPlugins()

    elseif HeitaoSdk then
        print("---TFGameStartup setLoginOutCallBack ----")
        HeitaoSdk.setLoginOutCallBack(onSdkPlatformLogout)
    end
end

return TFGameStartup
