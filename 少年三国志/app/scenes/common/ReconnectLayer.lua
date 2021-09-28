local ReconnectLayer = class("ReconnectLayer",UFCCSModelLayer)


function ReconnectLayer.create(mail)
   return ReconnectLayer.new("ui_layout/common_ReconnectLayer.json", require("app.setting.Colors").modelColor)
end

ReconnectLayer._instance = nil

function ReconnectLayer.show(str, buttons)
   if ReconnectLayer._instance ~= nil then
      ReconnectLayer._instance:close()
      ReconnectLayer._instance = nil
   end

   ReconnectLayer._instance = ReconnectLayer.create()
   ReconnectLayer._instance:setTextDesc(str)
   ReconnectLayer._instance:setButtons(buttons)
   uf_notifyLayer:getSysNode():addChild(ReconnectLayer._instance)
   ReconnectLayer._instance:showAtCenter(true)
end


function ReconnectLayer.hide()
   if ReconnectLayer._instance ~= nil then
      ReconnectLayer._instance:close()
      ReconnectLayer._instance = nil
   end
end

function ReconnectLayer:ctor(json, color, ...)
    self.super.ctor(self, ...)
    
    
    self:_initButtonEvent()
 
end


function ReconnectLayer:_initButtonEvent()
    self:attachImageTextForBtn("Button_return", "Image_return")
    self:attachImageTextForBtn("Button_reconnect", "Image_reconnect")

    self:registerBtnClickEvent("Button_return",function()
        --退到最外面,同时清空数据
        G_PlatformProxy:returnToLogin()
        
        self:close()
    end)
    self:registerBtnClickEvent("Button_reconnect",function()
        G_NetworkManager:reconnect()
        
        self:close()
    end)

 
end

--如果现在在进行一些不能重连的操作, 比如引导进行中,这个时候网络断掉后重连后用户也无法点击

function ReconnectLayer:_canReconnect()
    local canreconnect = true

    if G_GuideMgr and G_GuideMgr:isCurrentGuiding() then 
        canreconnect = false
    end
    return canreconnect
end

function ReconnectLayer:setTextDesc(str)    
    self:getLabelByName("Label_desc"):setText(str)
end

function ReconnectLayer:setButtons(buttons)    

    if buttons ~= nil and buttons['reconnect'] ~= nil then
      self:getButtonByName("Button_reconnect"):setVisible(buttons['reconnect'])
    else 
      self:getButtonByName("Button_reconnect"):setVisible(self:_canReconnect())
    end


    self:getButtonByName("Button_return"):setEnabled(true)

end

function ReconnectLayer:onLayerUnload()
    uf_eventManager:removeListenerWithTarget(self)
    ReconnectLayer._instance = nil
end

function ReconnectLayer:onLayerEnter()
  GlobalFunc.replaceForAppVersion(self:getImageViewByName("Image_23"))
    -- local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    -- if appstoreVersion or IS_HEXIE_VERSION  then 
    --   local img = self:getImageViewByName("Image_23")
    --   if img then
    --     img:loadTexture("ui/arena/xiaozhushou_hexie.png")
    --   end
    -- end
end

return ReconnectLayer


