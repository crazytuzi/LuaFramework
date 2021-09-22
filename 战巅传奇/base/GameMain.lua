
require("base.GameConfig")
require("thirdlibs.cocos.init")
require("thirdlibs.framework.init")

require("base.GameScreenInitialize")
require("base.GameGlobalVariable")
require("base.GameConst")

require("base.GameUtilBase")
require("base.GameUpdate")
require("base.GameLanguage")

CCGhostManager = cc.GhostManager:getInstance()
NetCC = cc.NetClient:getInstance()

GameCCBridge = require("base.GameCCBridge")
GameAccountCenter = require("base.GameAccountCenter")
Scheduler = require("thirdlibs.framework.scheduler")
GUIAnalysis=require("gameui.GUIAnalysis")

GameBaseLogic=require("base.GameBaseLogic")
GameBaseLogic.initVar()
GameBaseLogic.initSvrVar()

GameSetting = require("base.GameSetting")
-- GUIButton = require("gameui.GUIButton")



__G__TRACKBACK__ = function(msg)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback("", 2))
    if _G.buglyReportLuaException then
        buglyReportLuaException(tostring(msg), debug.traceback())
    end
    print("----------------------------------------")
end

local GameMain = class("GameMain", cc.mvc.AppBase)

MAIN_IS_IN_GAME=false

function GameMain:ctor()
    GameMain.super.ctor(self)

    math.randomseed(cc.SystemUtil:getTime())

    self.key_listener = cc.EventListenerKeyboard:create()
    self.key_listener:registerScriptHandler(handler(self, self.onKeyReleased), cc.Handler.EVENT_KEYBOARD_RELEASED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.key_listener, 1)
end

function GameMain:onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACK then
        print("BACK clicked!")
        if device.platform=="android" then
            GameCCBridge.doSdkExit()
        end
        GameSocket:dispatchEvent({name=GameMessageCode.EVENT_KEYBOARD_PASSED,key="back"})
    elseif keyCode == cc.KeyCode.KEY_MENU  then
        print("MENU clicked!")
        GameSocket:dispatchEvent({name=GameMessageCode.EVENT_KEYBOARD_PASSED,key="menu"})
    end
end

------------------------------------------------------------------------------------------
function GameMain:run()
    cc.FileUtils:getInstance():addSearchPath("resource/")
    cc.FileUtils:getInstance():addSearchPath("script/")

    local url1 = cc.FileUtils:getInstance():getWritablePath().."XStudio"
    local url2 = cc.FileUtils:getInstance():getWritablePath().."XStudio/script"
    local url3 = cc.FileUtils:getInstance():getWritablePath().."XStudio/resource"
    cc.FileUtils:getInstance():addSearchPath(url1, true);
    cc.FileUtils:getInstance():addSearchPath(url2, true);
    cc.FileUtils:getInstance():addSearchPath(url3, true);

    if device.platform == "android" then
        cc.DownManager:getInstance():setDownUrl("http://v10cdn.niuonline.cn/")
    elseif device.platform == "ios" then
        cc.DownManager:getInstance():setDownUrl("http://v10cdn.niuonline.cn/")
    else
        cc.DownManager:getInstance():setDownUrl("http://v10static.niuonline.cn/")
        cc.FileUtils:getInstance():addSearchPath("resource-android/")
        cc.FileUtils:getInstance():addSearchPath("net-android/")
    end
    cc.DownManager:getInstance():setSavePath(cc.FileUtils:getInstance():getWritablePath().."hot-update/")
    cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath().."hot-update/")


    if device.platform=="android" or device.platform=="ios" then
        local sceneUpdate = self:enterScene("GPageUpgrade")

        function initCallBack (args)
            print("-----initCallBack-----")
            sceneUpdate:checkUpdate()
        end

        function sdkLoginCallBack()
            if GameCCBridge  then
                print("------sdkLoginCallBack------------")
                GameBaseLogic.gameKey=GameCCBridge.getAccount()
                GameBaseLogic.loginKey=GameCCBridge.getToken() 

                asyncload_frames("ui/sprite/GPageAnnounce",".png",function ()
                    self:enterScene("GPageAnnounce")
                end)
            end
        end

        function logout ()
            MAIN_IS_IN_GAME = false
    
            --断开socket
            GameSocket:disconnect()

            GameBaseLogic.cleanGame()
            GameBaseLogic.initVar()
            GameBaseLogic.initSvrVar()
        end

        function changeAccount ()
            --cc.NetClient:getInstance():initClient()
            
            asyncload_frames("ui/sprite/GPageServerList",".png",function ()
                self:enterScene("GPageSignIn")
            end)
        end

        function sessionInvalid ()
            if GameSocket then
                GameSocket:disconnect()
            end
            if GameBaseLogic then
                GameBaseLogic.cleanGame()
            end
            cc.NetClient:getInstance():initClient()
            self:enterScene("GPageReEnter")
        end

        GameCCBridge.setSDKInitCallBack(initCallBack)
        GameCCBridge.setSDKLoginCallBack(sdkLoginCallBack)
        GameCCBridge.setSDKLoginOutCallBack(logout)
        GameCCBridge.setSDKChangeAccount(changeAccount)
        GameCCBridge.setSDKSessionInvalid(sessionInvalid)

        GameCCBridge.setPlatfromListener()
    else
        self:enterScene("GPageUpgrade")
    end
end

return GameMain
