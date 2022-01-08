--[[
******更换头像层*******

	-- by ChiKui Peng
	-- 2016/3/3
]]
local ChangeIconLayer = class("ChangeIconLayer", BaseLayer)

function ChangeIconLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.main.ChangeHead")
end

function ChangeIconLayer:initUI(ui)
	self.super.initUI(self,ui)
    self.panel_tableView = TFDirector:getChildByPath(ui, 'panel_head')
    self.img_tip = TFDirector:getChildByPath(ui, 'img_di2')
    self.panel_clickhelper = TFDirector:getChildByPath(ui, 'panel_clickhelper')
    self.panel_clickhelper:setSwallowTouch(false)
    if self.iconTableView == nil then
        local panel_size = self.panel_tableView:getContentSize()
        self.iconTableView = require('lua.logic.main.IconTableView'):new({size = panel_size})
        self.panel_tableView:addChild(self.iconTableView)
    end
end

function ChangeIconLayer:removeUI()
    self.super.removeUI(self)
end

function ChangeIconLayer:registerEvents()
    self.super.registerEvents(self)
    self.setIconHandler = function ( data )
        self:handleClose()
    end
    TFDirector:addMEGlobalListener(PlayerHeadIconManager.Set_Icon ,self.setIconHandler)
    self.panel_clickhelper:addMEListener(TFWIDGET_TOUCHBEGAN, handler(self.touchBeganHandle,self));
    self.panel_clickhelper:addMEListener(TFWIDGET_TOUCHMOVED, handler(self.touchMovedHandle,self));
    self.panel_clickhelper:addMEListener(TFWIDGET_TOUCHENDED, handler(self.touchEndedHandle,self));
end

function ChangeIconLayer:touchBeganHandle()
    return true
end

function ChangeIconLayer:touchMovedHandle()
    self.img_tip:setVisible(true)
end

function ChangeIconLayer:touchEndedHandle()
    self.img_tip:setVisible(false)
end

function ChangeIconLayer:removeEvents()
    TFDirector:removeMEGlobalListener(PlayerHeadIconManager.Set_Icon ,self.setIconHandler)
    self.super.removeEvents(self)
end

function ChangeIconLayer:dispose()
    self.super.dispose(self)
end

function ChangeIconLayer:handleClose()
    AlertManager:close(AlertManager.TWEEN_1);
end

-----断线重连支持方法
function ChangeIconLayer:onShow()
    self.super.onShow(self)
end

function ChangeIconLayer:refreshUI()

end

return ChangeIconLayer
