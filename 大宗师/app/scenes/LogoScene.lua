

local LogoScene = class("LogoScene", function()
    return display.newScene("LogoScene")
end)


function LogoScene:ctor()

    local colorBg = display.newColorLayer(ccc4(0,0,0,255))
    -- colorBg:setPosition(display.width/2, display.height/2)
    self:addChild(colorBg)

    GameAudio.init()
    -- 第三方sdk 初始化
    CSDKShell.init()
    -- gameWorks 初始化
    SDKGameWorks.InitGameWorks()

    -- talking data onstart
    SDKTKData.onStart()

    -- 在此之前必须确定是什么渠道 
    if device.platform == "ios" then 
        if CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_KUAIYONG then 
            if device.model == "iphone" then 
                self._logo = display.newSprite("logo/logo_ky_iphone.png")     
            elseif device.model == "ipad" then 
                self._logo = display.newSprite("logo/logo_ky_ipad.png")     
            end
        end 
    end

    if self._logo == nil then
        self._logo = display.newSprite("logo/logo.png")
    end

    if self._logo ~= nil then 
        self._logo:setPosition(display.width/2, display.height/2)
        self:addChild(self._logo)
    end 

end

function LogoScene:onEnter()
    if device.platform == "android" then
        -- avoid unmeant back
        self:performWithDelay(function()
            -- keypad layer, for android
            local layer = display.newLayer()
            layer:addKeypadEventListener(function(event)
                if event == "back" then app.exit() end
            end)
            self:addChild(layer)
            layer:setKeypadEnabled(true)
        end, 0.5)
    end

    local function update()
--        local scene = require("app.scenes.LoginScene").new()
--        display.replaceScene(scene, "fade", 0.5 )
        local scene = require("app.scenes.VersionCheckScene").new()
        display.replaceScene(scene, "fade", 0.5)
    end

    if CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_KUAIYONG then 
        local function doUpdateLogo()
            self._logo:removeFromParentAndCleanup(true) 
            self._logo = display.newSprite("logo/logo.png")
            self._logo:setPosition(display.width/2, display.height/2)
            self:addChild(self._logo) 
            self:performWithDelay(update, 2) 
        end 
        self:performWithDelay(doUpdateLogo, 2)
    else
        self:performWithDelay(update, 2) 
    end 
    print("enter logo scene")
end

function LogoScene:onExit()
    CCTextureCache:sharedTextureCache():removeTextureForKey("logo/logo.png")
end

return LogoScene
