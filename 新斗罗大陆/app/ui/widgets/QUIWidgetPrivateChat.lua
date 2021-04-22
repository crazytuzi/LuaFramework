--
-- Author: Qinyuanji
-- Date: 2015-03-20
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetPrivateChat = class("QUIWidgetPrivateChat", QUIWidget)
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

QUIWidgetPrivateChat.CLICK = "QUIWidgetPrivateChat_CLICK"

function QUIWidgetPrivateChat:ctor(options)
  	local ccbFile = "ccb/Widget_Chat_siliao.ccbi"
  	local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
  	}
  	QUIWidgetPrivateChat.super.ctor(self, ccbFile, callBacks, options)

    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setInfo(options.nickName, options.userId, options.avatar, options.championCount, options.parent)
end

function QUIWidgetPrivateChat:onExit()
    self:removeAllEventListeners()

    self.super.onExit(self)
end

function QUIWidgetPrivateChat:setInfo(nickName, userId, avatar, championCount, parent)
    if not userId then self._ccbOwner.online:setVisible(false) return end
    self._parent = parent
    self._ccbOwner.online:setVisible(true)

    self._ccbOwner["node_headPicture"]:removeAllChildren()
    local head = QUIWidgetAvatar.new(avatar)
    head:setSilvesArenaPeak(championCount)
    self._ccbOwner["node_headPicture"]:addChild(head)

    self._ccbOwner.nickName:setString(nickName)
    self._userId = userId
    self._avatar = avatar
    self._championCount = championCount
    self._nickName = nickName
end

function QUIWidgetPrivateChat:getUserId()
    return self._userId
end

function QUIWidgetPrivateChat:getAvatar()
    return self._avatar
end

function QUIWidgetPrivateChat:getChampionCount()
    return self._championCount
end

function QUIWidgetPrivateChat:getNickName()
    return self._nickName
end

function QUIWidgetPrivateChat:setHighlighted(value)
    self._ccbOwner.bg:setHighlighted(value)
    self._ccbOwner.high_light:setVisible(value)
end

function QUIWidgetPrivateChat:setRedTip(value)
    self._ccbOwner.private_tip:setVisible(value or false)
end

function QUIWidgetPrivateChat:getContentSize()
    return self._ccbOwner.bg:getContentSize()
end

function QUIWidgetPrivateChat:_onTriggerClick()
    if not self._parent or self._parent._isPMoving then return end

    app.sound:playSound("common_others")
    self:setHighlighted(true)
    self:dispatchEvent({name = QUIWidgetPrivateChat.CLICK, userId = self._userId})
end

return QUIWidgetPrivateChat