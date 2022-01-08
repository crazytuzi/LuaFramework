--[[
******战斗记录*******
    -- by yao
    -- 2016/1/12
]]

local MinimgFightRecordLayer = class("MinimgFightRecordLayer", BaseLayer)

function MinimgFightRecordLayer:ctor(data)
    self.super.ctor(self,data)

    self:init("lua.uiconfig_mango_new.mining.minimgGuardRecords")
end

function MinimgFightRecordLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_close  =  TFDirector:getChildByPath(ui, "btn_close")
end

function MinimgFightRecordLayer:loadData()
end

function MinimgFightRecordLayer:removeUI()
    self.super.removeUI(self)
end

-----断线重连支持方法
function MinimgFightRecordLayer:onShow()
    self.super.onShow(self)
end

function MinimgFightRecordLayer:registerEvents()
    self.super.registerEvents(self)  
    self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCloseCallBack))
end

function MinimgFightRecordLayer:removeEvents()
    self.btn_close:removeMEListener(TFWIDGET_CLICK)

    self.super.removeEvents(self)
end

function MinimgFightRecordLayer:dispose()
    self.super.dispose(self)
end

function MinimgFightRecordLayer:onCloseCallBack(sender)
    -- body
    AlertManager:close()
end


return MinimgFightRecordLayer