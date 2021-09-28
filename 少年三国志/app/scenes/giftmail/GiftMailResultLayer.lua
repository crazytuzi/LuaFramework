local GiftMailResultLayer = class("GiftMailResultLayer",UFCCSModelLayer)


function GiftMailResultLayer.create(mail)
   return GiftMailResultLayer.new("ui_layout/giftmail_GiftMailResultLayer.json", require("app.setting.Colors").modelColor, mail)
end

function GiftMailResultLayer:ctor(json, color, mail)
    self.super.ctor(self, mail)
    
    
    self:_initViews()
    self:_initButtonEvent()
   
    self:updateData(mail)
end

function GiftMailResultLayer:onLayerEnter( )
    self:closeAtReturn(true)
end

function GiftMailResultLayer:_initViews()    
    self._listView = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_list"), LISTVIEW_DIR_HORIZONTAL)
    self._listView:setCreateCellHandler(function ( list, index)
        return require("app.scenes.giftmail.GiftMailIconCell").new(list, index)
    end)
end

function GiftMailResultLayer:_initButtonEvent()
    self:registerBtnClickEvent("Button_close",function()
        self:close()
    end)
    self:registerBtnClickEvent("Button_ok",function()
        self:close()
    end)
end



function GiftMailResultLayer:updateData(mail )

    require("app.scenes.giftmail.GiftMailCell").buildIconList(self._listView, mail.awards )
end



function GiftMailResultLayer:onLayerUnload()
    uf_eventManager:removeListenerWithTarget(self)
end





return GiftMailResultLayer


