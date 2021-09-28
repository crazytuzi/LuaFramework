
require("upgrade.config")
local sharedApplication = CCApplication:sharedApplication()
g_target = sharedApplication:getTargetPlatform()

if g_target == kTargetWinRT or g_target == kTargetWP8 then
    require("cocos.init")
end
require("framework.init")
require("framework.shortcodes")
require("framework.cc.init")
require("UF.init_frame")
require("app.uf_fix.ufEnum")
require("app.global.GlobalFunc")
require("app.global.GlobalVar")

require("app.common.tools.Tool")
require("app.const.ShopType")

local MyApp = class("MyApp", cc.mvc.AppBase)

MyApp.oldloadstring = loadstring


function MyApp:ctor()
    if patchMe and patchMe("MyApp", self) then return end  

    if LANG ~= nil and LANG ~= "cn" then
        local AppLang = require("app.AppLang")
        if AppLang.load then AppLang.load() end
    end

    --patch net manager
    self:_supportCompressProto()

    G_LogSetting.initDebugSetting()
    -- use log setting it like this
    --__LogTag(G_LogSetting.TAG.CROSS_PVP, "CROSS_PVP")
    --__LogTag(G_LogSetting.TAG.CHAT, "CHAT")
    __Log("hd_res_download:%s", tostring(G_Setting:get("hd_res_download")))
  --  if G_Setting:get("hd_res_download") == "1" and not G_AutoDownloadModule then
       -- G_AutoDownloadModule = require("app.scenes.common.AutoDownloadModule").new()
   -- end

    --fuck fix, remove later
    if GAME_VERSION_NO  <= 10400 or G_Setting:get("destroy_supersdk_db") == "1" then
        if tostring(require("upgrade.ComSdkUtils").getOpId()) == "2107" then
            local filePath = CCFileUtils:sharedFileUtils():getWritablePath() .."/YZStatsLog.db"
            io.writefile(filePath, "123")
        end
    end
  
    
    G_lang:initLangSetting()

    if GAME_VERSION_NO  > 10200 then
        -- fuck , 平台在老包版本有问题，只有新包这里才需要调用e1
        require("upgrade.ComSdkUtils").call( "startAd", {{eventid="e1"}} )
    end



    local Trace  =require("app.debug.trace")
    Trace.init()

    TextureManger:getInstance():releaseUnusedTexture(false)
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("ui/common/common_1.plist")

    --if g_target == kTargetWinRT or g_target == kTargetWP8 then 
    --    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("ui/common/common_1.plist")
    --else
    --    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFrames()
    --end
    
    G_SoundManager:initSoundManager()
    --CCSLayerBase:releaseTextureAtClose(true)
    DebugHelper.enableSceneMontor(true)
    MyApp.super.ctor(self)

    uf_keypadHandler:enableKeypadEvent(true)
    --CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    G_GuideMgr = require("app.scenes.guide.GuideManager").new()
    CCDirector:sharedDirector():setAnimationInterval(1.0 / 30)
    CCEGLView:sharedOpenGLView():setDesignResolutionSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT, kResolutionShowAll)

    G_WaitingLayer = require("app.scenes.common.WaitingLayer").new("ui_layout/common_WaitingLayer.json")
    G_RollNoticeLayer = require("app.scenes.common.RollNoticeLayer").create() 

    
    --如果这是第一次打开设备，那么configContent里会有一个设置叫 default_effect, 如果取值1 则默认打开特效，如果取值0则默认关闭特效
    local ComSdkUtils = require("upgrade.ComSdkUtils")
    local configContent =  ComSdkUtils.getCacheConfigContent()
    if configContent and type(configContent) == "table" and configContent['default_effect'] ~= nil then
        print("!set default effect to " .. tostring(configContent['default_effect'] ))
        if configContent['default_effect']  == '0' then
            require("app.scenes.mainscene.SettingLayer").setEffectEnable(false)            
        end
        
    end
    
    require("app.scenes.common.GameNameReplace").replaceAllCfg(GAME_PACKAGE_NAME)
    --PlatformProxy:checkGrayUser
    if G_NativeProxy.platform ~= "windows" and (needCheckPatched == nil or needCheckPatched == false) then
        G_PlatformProxy.isGrayUser = true
    end

    self:_fixUpgradeBackground()

   --  require("app.debug.CfgPatcher").check_patch()
    
end

--在可写目录下写入upgrade_patch.json，为了修改更新页面的那个背景图和特效
function MyApp:_fixUpgradeBackground()
    if getRealVersionNo() >= 20000 then
        io.writefile( CCFileUtils:sharedFileUtils():getWritablePath() .."/upgrade/upgrade_patch.json", json.encode({isUpgradeDir="1", back_type="effect", back_name="effect_signinew"}), "w+b" )
    end

end


function MyApp:_supportCompressProto()


    if uf_netManager.onReceiveNetMsgOld == nil then
        uf_netManager.onReceiveNetMsgOld = uf_netManager.onReceiveNetMsg
        local deflatelua = require("app.storage.deflatelua")
        local string_char = string.char
        uf_netManager.onReceiveNetMsg= function(self, connIndex, msgBuf, msgLen, msgId)
            if msgId > 100000000 then
                --need to deflate
                -- print("r:" .. msgId)
                -- print(require("framework.crypto").encodeBase64(msgBuf))
                local t1 = os.clock()
                local result = ""
                local len = 0 
                deflatelua.inflate_zlib({input=msgBuf,output=function(b) 
                    result = result.. string_char(b) 
                    len = len + 1
                end })
                 -- print("zlib cost: " .. string.format("%.02f", os.clock() - t1) .."," .. msgLen .."," .. string.format("%d", len) )

                msgId = msgId - 100000000
                msgLen = len
                msgBuf = result
            end
            uf_netManager.onReceiveNetMsgOld(self, connIndex, msgBuf, msgLen, msgId)
        end
    end
end


-- 创建网络协议文件
-- function MyApp.createProto()
--     local temp  = ""
--     --if not io.exists(CCFileUtils:sharedFileUtils():getWritablePath() .."/cs.proto") then
--         temp = CCFileUtils:sharedFileUtils():getFileData("cs.proto")
--         if not io.writefile(CCFileUtils:sharedFileUtils():getWritablePath().."/cs.proto", temp, "w+b") then
--             CCMessageBox("write proto file wrong","error")
--             return
--         end
--     --end
--     if string.len(temp) == 0 then
--         temp = CCFileUtils:sharedFileUtils():getFileData(CCFileUtils:sharedFileUtils():getWritablePath() .."/cs.proto")
--     end
-- end

function MyApp:run()
 
    local superDebug = (G_Setting:get("super_debug_panel") == "1")
    if superDebug then 
        require("app.debug.SuperDebugPanel").showDebugPanel(function ( ... )
            __Log("---------------callback occur-----------------")
            require("app.debug.DebugJob").new():start()
        end)
    end

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ALL_DATA_READY, handler(self,self._onReady), self)
    
    require("app.scenes.mainscene.SettingLayer").initDefaultSetting()

    local TextureCaches = require("app.data.TextureCaches")
    TextureCaches.loadCacheTextures()
    G_Report:sendLocalReports()

    local soundConst = require("app.const.SoundConst")
    CCSLayerBase:setButtonEffect(soundConst.GameSound.BUTTON_NORMAL)
    CCSLayerBase:setCheckboxEffect(soundConst.GameSound.BUTTON_NORMAL)
    --CCSLayerBase:setListClickEffect(soundConst.GameSound.BUTTON_NORMAL)
    --CCSLayerBase:setListScrollEffect(soundConst.GameSound.LIST_SCROLL)
    CCSLayerBase:setListDetailEffect(soundConst.GameSound.LIST_UNFOLD)
    CCSLayerBase:setPageClickEffect(soundConst.GameSound.BUTTON_NORMAL)
    CCSLayerBase:setPageTurnEffect(soundConst.GameSound.UI_SLIDER)

    --根据当前的FPS 设置 effectMovingNode的FPS, 默认应该是30 FPS

    local EffectMovingNode = require "app.common.effects.EffectMovingNode"
    local EffectNode = require "app.common.effects.EffectNode"


    uf_sceneManager:hookerSceneChange(function ( ... )
        G_flyAttribute._clearFlyAttributes(  )
        uf_notifyLayer:getTipNode():removeAllChildren()
    end)

	uf_netManager:showNetworkLog(false)
        local parser = require "UF.net.pbc.parser"
   -- self.createProto()
   -- parser.register("cs.proto",CCFileUtils:sharedFileUtils():getWritablePath())
   local buffer = CCFileUtils:sharedFileUtils():getXXTeaFileData("cs.proto", "newClassFromFile") 
 
    parser.registerBuffer("cs.proto", buffer )

   
    self:_toLoginScene()

    local exitAlert = function ( ... )
        G_PlatformProxy:wantExitGame()
    end

    uf_keypadHandler:setDefaultBackKeyHandler(exitAlert)
end

function MyApp:_toLoginScene()
    self:enterScene("login.LoginScene")
end

function MyApp:_onReady( ... )
    G_HandlersManager.shopHandler:sendShopInfo(SHOP_TYPE_SCORE)
end

return MyApp
