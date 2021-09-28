
local ShareService =  class("ShareService")

local ComSdkUtils = require("upgrade.ComSdkUtils")

local ComSdkProxyConfig = require("app.platform.comSdk.ComSdkProxyConfig")


function ShareService:ctor()
    if G_NativeProxy.platform == "windows" then
        return 
    end

    if self:canWeixinShare() then
        ComSdkUtils.call("initWeixin", {{appKey=ComSdkProxyConfig.getWeixinAppkey()}})
        
        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_NATIVE_WEIXIN_CALLBACK, function() 
            print("weixin share ok")
            if self:_isLowMemoryDevice() then

                --dispatch event already ,ignore now
            else
                uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SHARE_SUCCESS, nil, false, nil)

            end
        end, self )

    end

    if self:canWeiboShare() then
        --todo
    end
end

function ShareService:canShareImage()
    --todo only weixin ios can share image

    if G_Setting:get("open_share_image") == "0" then
        return false
    end
    

    if G_NativeProxy.platform == "windows" or G_NativeProxy.platform == "ios" then
        return self:canWeixinShare()
    end  


    return false
end

function ShareService:canShare()
    if G_Setting:get("open_share") == "1" and (G_Setting:get("open_weibo_share") == "1"  or G_Setting:get("open_wechat_share") == "1") then
        return true
    end
    return false
end

function ShareService:canWeixinShare()
    if G_Setting:get("open_share") == "1" and G_Setting:get("open_wechat_share") == "1" then
        return true
    end
    return false
end


function ShareService:canWeiboShare()
    if G_Setting:get("open_share") == "1" and G_Setting:get("open_weibo_share") == "1" then
        return true
    end
    return false
end

function ShareService:_fakeShare()
    uf_funcCallHelper:callAfterFrameCount(1, function ( ... ) 
       uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SHARE_SUCCESS, nil, false, nil)
    end) 
end

function ShareService:_saveScreen()
    
    local path = CCFileUtils:sharedFileUtils():getWritablePath()
    
    local size = CCDirector:sharedDirector():getWinSize()  
    local screen = CCRenderTexture:create(size.width, size.height, 0)  
    local temp  = CCDirector:sharedDirector():getRunningScene()  
    screen:begin()  
    temp:visit()  
    screen:endToLua()  
    local pathsave = path.."/share.jpg"  
    
    if screen:saveToFile('share.jpg', 0) == true then  
        return pathsave
    end
    return ""    
end

function ShareService:weiboShareText(str)
    if not self.canWeiboShare() then
        return
    end
    if G_NativeProxy.platform == "windows" then
        self:_fakeShare()
        return
    end
    
end




function ShareService:weiboShareScreen()
    if not self.canWeiboShare() then
        return
    end
    if G_NativeProxy.platform == "windows" then
        self:_fakeShare()
        return
    end


end



function ShareService:_checkWeixin()

    if not self.canWeixinShare() then
        return false
    end
    if G_NativeProxy.platform == "windows" then
        self:_fakeShare()
        return false
    end

    local installed = ComSdkUtils.call("isWeixinInstalled", nil, "boolean")
    if not installed then
        G_MovingTip:showMovingTip(G_lang:get("LANG_WEIXIN_NOT_INSTALLED"))
        return false
    end
    return true
end 



function ShareService:_isLowMemoryDevice()
    if G_Setting:get("open_share_wait") == "0" then
        return true
    end

    

    if G_NativeProxy.platform == "ios" then
        local deviceString, ret = G_NativeProxy.native_call("getDeviceString", nil, "string")


        if ret and deviceString then
            if deviceString == "iPhone1,1" or deviceString == "iPhone1,2" or deviceString == "iPhone3,1"
                or  deviceString == "iPod1,1" or  deviceString == "iPod2,1" or  deviceString == "iPod3,1"
                or  deviceString == "iPad1,1"  then
                return true
            end
        end 

    end



    return false
end


function ShareService:weixinShareText(str)
    if self:_checkWeixin() then

        if self:_isLowMemoryDevice() then

            self:_fakeShare()
        end

        local broadcast_url = G_Setting:get("broadcast_url")
        if broadcast_url and broadcast_url ~= "" then
            str = str .. tostring(broadcast_url)
        end

        G_PlatformProxy:delayCall( "weixinShareText", function () ComSdkUtils.call("weixinShareText", {{txt=str},{desc=" "}})  end    )


    end
end

function ShareService:weixinShareLink(url,title,desc)
    if self:_checkWeixin() then


        if self:_isLowMemoryDevice() then

            self:_fakeShare()
        end
        G_PlatformProxy:delayCall( "weixinShareLink", function () ComSdkUtils.call("weixinShareText", {{url=url},{title=title},{desc=desc}})  end    )


    end
end


function ShareService:weixinShareScreen()
    if self:_checkWeixin() then

        local path = self:_saveScreen()


        if self:_isLowMemoryDevice() then

            self:_fakeShare()
        end
        
        if path ~= "" then
            G_PlatformProxy:delayCall( "weixinShareText", function ()  ComSdkUtils.call("weixinShareImage", {{imagePath=path},{desc=" "}})  end    )

        else
            --error

        end
    end
    
   
end

return ShareService
