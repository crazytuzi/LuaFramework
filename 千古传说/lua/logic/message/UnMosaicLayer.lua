--[[
******是否拆卸*******

    -- by Stephen.tao
    -- 2014/2/27
]]

local UnMosaicLayer = class("UnMosaicLayer", BaseLayer)

--CREATE_SCENE_FUN(UnMosaicLayer)
CREATE_PANEL_FUN(UnMosaicLayer)


function UnMosaicLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.message.UnMosaicLayer")
end


function UnMosaicLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_ok             = TFDirector:getChildByPath(ui, 'btn_ok')
    self.btn_cancel         = TFDirector:getChildByPath(ui, 'btn_cancel')

    self.btn_ok.logic       = self
    self.btn_cancel.logic   = self
end

function UnMosaicLayer:removeUI()
	self.super.removeUI(self)

    self.btn_ok             = nil
    self.btn_cancel         = nil
    self.userid             = nil
    self.pos                = nil
end

function UnMosaicLayer:setEquipIdAndPos( userid ,pos  )
    self.userid = userid
    self.pos = pos 
end

function UnMosaicLayer.onOKBtnClickHandle(sender)
    local self = sender.logic
    if self == nil then
        return
    end
    EquipmentManager:GemUnMosaic(self.userid , self.pos )
end

--长按响应
function UnMosaicLayer.onCancelBtnClickHandle(sender)
    AlertManager:close(AlertManager.TWEEN_1);
end

function UnMosaicLayer:registerEvents()
    self.super.registerEvents(self)
    self.btn_ok:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onOKBtnClickHandle),1)
    self.btn_cancel:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCancelBtnClickHandle),1)
end


return UnMosaicLayer
