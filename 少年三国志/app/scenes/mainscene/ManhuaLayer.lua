
local ManhuaLayer = class("ManhuaLayer",UFCCSModelLayer)
local function url_encode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w %-%_%.%~])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str    
end

function ManhuaLayer.create( )

    local layer =  ManhuaLayer.new("ui_layout/mainscene_ManhuaLayer.json")
    layer:init()





    local size = layer:getRootWidget():getContentSize()
    -- layer:setPosition(ccp((display.width - size.width )/2,  (display.height - size.height)/2  ))
    local they = display.height - size.height
    layer:setPosition(ccp(0, they ))


    local bgBlack = CCLayerColor:create(ccc4(0, 0, 0, 220), display.width,display.height)
    bgBlack:setPosition(ccp(0, size.height -display.height ))
    layer:getRootWidget():addNode(bgBlack, 0)


    uf_notifyLayer:getPopupNode():addChild(layer, 800, 0)


    local uid = G_PlatformProxy:getLoginServer().id .. "_" .. G_Me.userData.id 
    local user_name = G_Me.userData.name 
    local ui_name = 'main'
    local key = 'KJ_*)HEnnsf____0jqhfna*^HJNsdffaa9??82(HHsdsss%&'


    local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
    require("app.cfg.knight_info")
    local knightInfo = knight_info.get(baseId)
    local head= ""
    if knightInfo then
        head = knightInfo.res_id
        if knightId == G_Me.formationData:getMainKnightId() then 
            head = G_Me.dressData:getDressedPic()
        end
    end
    local serverId = G_PlatformProxy:getLoginServer().id 


    local sign =  CCCrypto:MD5(uid .. user_name .. ui_name .. key, false)


    local url = 'http://g.qingman.cc/comic.php?m=Include&a=index&t=snsgz&uid=' .. uid .. '&user_name=' .. url_encode(user_name) .. '&ui_name=' .. ui_name  .. '&head=' .. head .."&level=" .. tostring(G_Me.userData.level) .. '&server=' .. tostring(serverId)  ..'&sign=' ..sign
    
    print("url=" .. url)
    layer:open(url)

    return layer 
end




function ManhuaLayer:init( )
    self:registerBtnClickEvent("Button_ok",  function() 
         self:close()
    end)
end


function ManhuaLayer:open( url)
    if G_NativeProxy then
        local size = self:getRootWidget():getContentSize()

  
        local cx = display.cx
        local cy = (display.height - size.height)/2 + size.height

        local glView = CCDirector:sharedDirector():getOpenGLView()
        local sx = glView:getScaleX()
        local sy = glView:getScaleY()
        local w = display.width
        local h = display.height -  size.height

        if g_target == kTargetWinRT or g_target == kTargetWP8 then
            cy = (display.height - size.height)/2
        end

        G_NativeProxy.native_call("openEmbedUrl", {
            {url=url},
            {centerX= cx*sx},
            {centerY=cy*sy},
            {width=w*sx},
            {height=h*sy},

        })


    end
end



function ManhuaLayer:onLayerEnter()
    
    self:closeAtReturn(true)
    
end



function ManhuaLayer:_closeWebview( ... )

    G_NativeProxy.native_call("closeEmbedUrl")
end



function ManhuaLayer:onLayerUnload( ... )
    self:_closeWebview()
end


return ManhuaLayer
