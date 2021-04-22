--
-- zxs
-- 小屋助手btn
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSecretaryBtn = class("QUIWidgetSecretaryBtn", QUIWidget)

QUIWidgetSecretaryBtn.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetSecretaryBtn:ctor(options)
	local ccbFile = "ccb/Widget_Secretary_client1.ccbi"
  	local callBacks = {
  		{ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetSecretaryBtn._onTriggerClick)},
  	}
	QUIWidgetSecretaryBtn.super.ctor(self,ccbFile,callBacks,options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSecretaryBtn:setInfo(info)
	self._info = info
	self._ccbOwner.node_tips:setVisible(false)
	self._ccbOwner.node_icon:removeAllChildren()

	self._ccbOwner.btn_click:setTitleForState(CCString:create(self._info.name or ""), CCControlStateNormal)
	self._ccbOwner.btn_click:setTitleForState(CCString:create(self._info.name or ""), CCControlStateHighlighted)
	self._ccbOwner.btn_click:setTitleForState(CCString:create(self._info.name or ""), CCControlStateDisabled)
end

function QUIWidgetSecretaryBtn:setSelect(b)
	self._ccbOwner.btn_click:setHighlighted(b)
	self._ccbOwner.btn_click:setEnabled(not b)
end

function QUIWidgetSecretaryBtn:_onTriggerClick()
    app.sound:playSound("common_switch")
	self:dispatchEvent({name = QUIWidgetSecretaryBtn.EVENT_CLICK, tabId = self._info.tabId})
end

return QUIWidgetSecretaryBtn