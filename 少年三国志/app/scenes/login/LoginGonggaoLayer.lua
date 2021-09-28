
local LoginGonggaoLayer = class("LoginGonggaoLayer",UFCCSModelLayer)


function LoginGonggaoLayer.create(url , callback)

    local layer =  LoginGonggaoLayer.new("ui_layout/login_GonggaoLayer.json", require("app.setting.Colors").modelColor)
    layer:init(callback)

    local size = layer:getRootWidget():getContentSize()
    layer:setPosition(ccp((display.width - size.width )/2,  (display.height - size.height)/2  ))
    uf_notifyLayer:getPopupNode():addChild(layer, 800, 0)

    layer:open(url)

    return layer 
end


function LoginGonggaoLayer:onLayerEnter( ... )
    self:closeAtReturn(true)
end

function LoginGonggaoLayer:onBackKeyEvent( ... )
    if self._callback then 
        self._callback()
        self._callback = nil
    end
end

function LoginGonggaoLayer:init( callback)
    self._callback = callback
    self:registerBtnClickEvent("Button_ok",  function() 
        if self._callback then
           self._callback()
           self._callback = nil
        end
        self:close()
    end)
end


function LoginGonggaoLayer:open( url)
    if G_NativeProxy then

        local layer = self:getPanelByName("Panel_browser")

        --中心点
        local w = layer:getContentSize().width
        local h = layer:getContentSize().height 

        -- print("w=" .. w)
        -- print("h=" .. h)



        local startPos = layer:convertToWorldSpace(ccp(0, 0))
        -- print("x=" .. startPos.x)
        -- print("y=" .. startPos.y)


        local cx = startPos.x + w/2
        local cy = startPos.y + h/2

        if g_target ~= kTargetWinRT and g_target ~= kTargetWP8 then
            cy = display.height - cy 
        end


        -- print("cx = " .. cx )
        -- print("cy = " .. cy )

        local glView = CCDirector:sharedDirector():getOpenGLView()
        local sx = glView:getScaleX()
        local sy = glView:getScaleY()


       -- local mask = CCLayerColor:create(ccc4(255, 0, 0, 255), width, height)
       -- self:addChild(mask)
       -- mask:setPosition(ccp(centerX-width/2, centerY-height/2))


        --G_NativeProxy.openEmbedUrl("http://www.baidu.com", cx*sx, cy*sy, w*sx, h*sy)
        --打开游戏内嵌入网页

        G_NativeProxy.native_call("openEmbedUrl", {
            {url=url},
            {centerX= cx*sx},
            {centerY=cy*sy},
            {width=w*sx},
            {height=h*sy},

        })


    end
end



function LoginGonggaoLayer:_closeWebview( ... )

    G_NativeProxy.native_call("closeEmbedUrl")
end



function LoginGonggaoLayer:onLayerUnload( ... )
    self:_closeWebview()
end


return LoginGonggaoLayer
