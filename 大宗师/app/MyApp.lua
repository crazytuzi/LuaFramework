require("app.init")
require("framework.init")
require("framework.shortcodes")
require("framework.cc.init")
require("app.config")
require("constant.version")
require("constant.url")


local MyApp = class("MyApp", cc.mvc.AppBase)

local GameDevice = require("sdk.GameDevice")
require("data.data_msg_push_msg_push")

GameState = require(cc.PACKAGE_NAME .. ".api.GameState") 


function MyApp:ctor()
    MyApp.super.ctor(self) 

    local function eventListen(param)
        -- dump(param)
        local returnValue = {}
        if param.errorCode then 
            dump("读取存储文件失败error:" .. param.errorCode) 
        else 
            if param.name == "save" then 
                dump("save:") 
                returnValue = param.values 

            elseif param.name == "load" then 
                dump("load:") 
                returnValue = param.values 
            end 
        end 

        return returnValue 
    end 

    GameState.init(eventListen, "chatData.txt") 
end


function MyApp:run()
--
--    CCFileUtils:sharedFileUtils():addSearchPath("res/")
--    CCFileUtils:sharedFileUtils():addSearchPath("res/ui/")
--    CCFileUtils:sharedFileUtils():addSearchPath("res/ccbi/")
--    CCFileUtils:sharedFileUtils():addSearchPath("res/fonts/")
    for _, v in ipairs(SearchPath) do
        CCFileUtils:sharedFileUtils():addSearchPath(v)
    end
    self:enterScene("LogoScene")
    local notificationCenter = CCNotificationCenter:sharedNotificationCenter()
    notificationCenter:registerScriptObserver(nil, handler(self, self.onGameEnterBackground), "GAME_EVENT_ENTER_BACKGROUND")
    notificationCenter:registerScriptObserver(nil, handler(self, self.onGameEnterForeground), "GAME_EVENT_ENTER_FOREGROUND")
end

function MyApp:onEnterBackground()
	-- MyApp:RestNotification()

end

function MyApp:onEnterForeground()
	-- GameDevice.CancelAllNotifications( )

end


function MyApp:onGameEnterForeground( ... )
    GameDevice.CancelAllNotifications()
end

function MyApp:onGameEnterBackground( ... )
      self:RestNotification()
      CSDKShell.pause()
end


function MyApp:RestNotification( ... )
    GameDevice.CancelAllNotifications( )
    for k,v in pairs(data_msg_push_msg_push) do
        local time_table = os.date("*t")
        -- dump(v)
        -- if time_table["hour"] < v.time then
            
        time_table["hour"] = v.time - 1
        time_table["min"] = 60 - v.shift
        local dur =  (os.time( time_table ) - os.time())

        if(dur > 0) then
            dump(dur)
            GameDevice.AddNotification({ dt = dur , cont = v.text , bt_txt = "好的" })
        else
            dur = (os.time(time_table) + 3600 * 24 - os.time())
            GameDevice.AddNotification({ dt = dur , cont = v.text , bt_txt = "好的" })
        end
        -- end
    end

end



return MyApp
