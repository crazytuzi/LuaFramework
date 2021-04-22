-- @Author: zhouxiaoshu
-- @Date:   2019-10-15 18:30:51
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-03-26 10:15:51
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSelectBtn = class("QUIWidgetSelectBtn", QUIWidget)

QUIWidgetSelectBtn.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetSelectBtn:ctor(options)
	local ccbFile = "ccb/Widget_Select_btn.ccbi"
  	local callBacks = {
  		{ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetSelectBtn._onTriggerClick)},
  	}
	QUIWidgetSelectBtn.super.ctor(self,ccbFile,callBacks,options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSelectBtn:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetSelectBtn:setInfo(info)
	self._info = info
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.btn_click:setTitleForState(CCString:create(self._info.btnName or ""), CCControlStateNormal)
	self._ccbOwner.btn_click:setTitleForState(CCString:create(self._info.btnName or ""), CCControlStateHighlighted)
	self._ccbOwner.btn_click:setTitleForState(CCString:create(self._info.btnName or ""), CCControlStateDisabled)
		
	self:isShowTips(info.isTips or false)
	self:setSelect(info.isSelected or false)

	if info.icon then
    	local icon = CCSprite:create(info.icon)
    	icon:setScale(50/icon:getContentSize().width)
    	self._ccbOwner.node_icon:addChild(icon)
    end
end

function QUIWidgetSelectBtn:isShowTips(b)
	self._ccbOwner.node_tips:setVisible(b)
end
 
function QUIWidgetSelectBtn:setSelect(b)
	self._ccbOwner.btn_click:setEnabled(not b)
	self._ccbOwner.btn_click:setHighlighted(b)
end

function QUIWidgetSelectBtn:_onTriggerClick()
    app.sound:playSound("common_switch")
	self:dispatchEvent({name = QUIWidgetSelectBtn.EVENT_CLICK, info = self._info})
end

return QUIWidgetSelectBtn