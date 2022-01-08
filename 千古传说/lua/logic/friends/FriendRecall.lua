--[[
******回归提示*******
    by yao
    2016/2/17
]]

local FriendRecall = class("FriendRecall", BaseLayer)

function FriendRecall:ctor(data)
    self.super.ctor(self, data)
    self.playerId = nil
    self:init("lua.uiconfig_mango_new.friends.FriendRecall")
end

function FriendRecall:initUI(ui)
    self.super.initUI(self, ui)
    self.Btn_zhaohui= TFDirector:getChildByPath(ui, "btn_zhaohui")
    self.btn_close  = TFDirector:getChildByPath(ui, "btn_close")

    self.Btn_zhaohui.logic = self
end

function FriendRecall:setData(playerId)
    self.playerId = playerId
end

function FriendRecall:onShow()
    self.super.onShow(self)
end

function FriendRecall:registerEvents()
    self.super.registerEvents(self)
    self.Btn_zhaohui:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onZhaohui))
    self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCloseBtnCallBack))

    self.zhaohuiSuccess = function(event)
        AlertManager:close()
    end
    TFDirector:addMEGlobalListener(PlayBackManager.ZHAOHUISUCCESS ,self.zhaohuiSuccess)
end

function FriendRecall:removeEvents()
    self.Btn_zhaohui:removeMEListener(TFWIDGET_CLICK)
    self.btn_close:removeMEListener(TFWIDGET_CLICK)

    TFDirector:removeMEGlobalListener(PlayBackManager.ZHAOHUISUCCESS ,self.zhaohuiSuccess)
    self.zhaohuiSuccess = nil

    self.super.removeEvents(self)
end

function FriendRecall:dispose()
    self.super.dispose(self)
end

function FriendRecall.onZhaohui(sender)
    --print("召回")
    local self = sender.logic
    PlayBackManager:requestRecallPlayer(self.playerId) 
end

--关闭按钮回调
function FriendRecall.onCloseBtnCallBack(sender)
    AlertManager:close()
end

return FriendRecall