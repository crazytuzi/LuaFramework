--[[
    This module is developed by Eason
    2015/10/22
]]

local ChatFriendListCell = class("ChatFriendListCell", BaseLayer)

local localVars = {
    parentLayer = nil,
}

function ChatFriendListCell:ctor(data)
    self.super.ctor(self, data)

    -- init
    self:init("lua.uiconfig_mango_new.chat.ChatFriendListCell")
end

function ChatFriendListCell:initUI(ui)
    self.super.initUI(self, ui)

    self.button = TFDirector:getChildByPath(ui, "button")
    assert(self.button)
    self.button.parent = self

    self.text = TFDirector:getChildByPath(self.button, "label")
    assert(self.text)

    self.playerInfo = nil
    self.needShowRedPoint = false
end

function ChatFriendListCell:onShow()
    self.super.onShow(self)
end

function ChatFriendListCell:registerEvents()
    self.super.registerEvents(self)

    self.button:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onButtonClicked))
end

function ChatFriendListCell:removeEvents()
    self.button:removeMEListener(TFWIDGET_CLICK)

    self.super.removeEvents(self)
end

function ChatFriendListCell:dispose()
    self.super.dispose(self)
end

function ChatFriendListCell.onButtonClicked(sender)
    localVars.parentLayer:selectCell(sender.parent.playerInfo.playerId)
end

function ChatFriendListCell:selected()
	self.button:setTextureNormal("ui_new/chat/btn_f2.png")
    self.needShowRedPoint = false
    CommonManager:removeRedPoint(self)
    ChatManager:removeNewMessageByID(self.playerInfo.playerId)
end

function ChatFriendListCell:unselected()
	self.button:setTextureNormal("ui_new/chat/btn_f.png")
end

function ChatFriendListCell:setText(string)
	self.text:setText(string)
end

function ChatFriendListCell:setParentLayer(layer)
    localVars.parentLayer = layer
end

function ChatFriendListCell:setPlayerInfo(playerInfo)
    self.playerInfo = playerInfo
end

function ChatFriendListCell:getPlayerInfo()
    return self.playerInfo
end

function ChatFriendListCell:isNeedShowRedPoint()
    return self.needShowRedPoint
end

function ChatFriendListCell:showRedPoint()
    self.needShowRedPoint = true
    CommonManager:updateRedPoint(self, self:isNeedShowRedPoint(), ccp(70, 30))
end

return ChatFriendListCell