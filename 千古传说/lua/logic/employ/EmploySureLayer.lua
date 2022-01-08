--[[
******放置单个佣兵*******

]]


local EmploySureLayer = class("EmploySureLayer", BaseLayer)

local columnNumber = 4
function EmploySureLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.yongbing.EmployLayer")
end

function EmploySureLayer:initUI(ui)
    self.super.initUI(self,ui)

    self.txt_content= TFDirector:getChildByPath(ui, 'txt_content')
    self.txt_num= TFDirector:getChildByPath(ui, 'txt_num')
    self.txt_des= TFDirector:getChildByPath(ui, 'txt_des')
    self.checkBox= TFDirector:getChildByPath(ui, 'CheckBox_Game_1')
    self.btn_ok= TFDirector:getChildByPath(ui, 'btn_ok')
    self.btn_cancel= TFDirector:getChildByPath(ui, 'btn_cancel')

end
function EmploySureLayer:setLayerInfo( role_name,cost,okhandle )
    --self.txt_content:setText("确定雇佣玩家"..role_name.."的侠客，需支付")
    self.txt_content:setText(stringUtils.format(localizable.EmSureLayer_text1,role_name))
    --self.txt_des:setText("今天将不能雇佣来自"..role_name.."的侠客")
    self.txt_des:setText(stringUtils.format(localizable.EmSureLayer_text2,role_name))
    self.txt_num:setText(cost)
    self.btn_ok.logic       = self
    self.btn_ok:addMEListener(TFWIDGET_CLICK,audioClickfun(function()
        local data = self.checkBox:getSelectedState();
        AlertManager:close()
        okhandle(data)
    end),1)
end

function EmploySureLayer:removeUI()
    self.super.removeUI(self)
end

function EmploySureLayer:registerEvents()
    self.super.registerEvents(self)
    -- self.btn_ok:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onOkClickHandle))
    self.btn_cancel:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCancelClickHandle))
    -- self.checkBox:addMEListener(TFWIDGET_CLICK, audioClickfun(self.relationTypeClick))
end

function EmploySureLayer:removeEvents()

    self.super.removeEvents(self)
end

function EmploySureLayer:dispose()
    self.super.dispose(self)
end


-----断线重连支持方法
function EmploySureLayer:onShow()
    self.super.onShow(self)
    self:refreshUI()

end

function EmploySureLayer:refreshUI()

end


function EmploySureLayer.onCancelClickHandle(sender)
    AlertManager:close();
end
-- function EmploySureLayer.onOkClickHandle(sender)
--     AlertManager:close();
-- end

return EmploySureLayer
