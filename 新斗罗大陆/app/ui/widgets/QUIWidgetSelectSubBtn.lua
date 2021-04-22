-- @Author: zhouxiaoshu
-- @Date:   2019-10-15 18:30:51
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-18 11:56:35
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSelectSubBtn = class("QUIWidgetSelectSubBtn", QUIWidget)

QUIWidgetSelectSubBtn.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetSelectSubBtn:ctor(options)
	local ccbFile = "ccb/Widget_Select_sub_btn.ccbi"
  	local callBacks = {
  		{ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetSelectSubBtn._onTriggerClick)},
  	}
	QUIWidgetSelectSubBtn.super.ctor(self,ccbFile,callBacks,options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSelectSubBtn:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetSelectSubBtn:setInfo(info)
	self._info = info
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.btn_click:setTitleForState(CCString:create(self._info.btnName or ""), CCControlStateNormal)
	self._ccbOwner.btn_click:setTitleForState(CCString:create(self._info.btnName or ""), CCControlStateHighlighted)
	self._ccbOwner.btn_click:setTitleForState(CCString:create(self._info.btnName or ""), CCControlStateDisabled)
	
	local btnName = self._ccbOwner.btn_click:getTitleLabelForState(CCControlStateNormal)
	if string.len(btnName:getString()) >= 25 then 
		self._ccbOwner.btn_click:setTitleTTFSizeForState(20,CCControlStateNormal)
		self._ccbOwner.btn_click:setTitleTTFSizeForState(20,CCControlStateHighlighted)
		self._ccbOwner.btn_click:setTitleTTFSizeForState(20,CCControlStateDisabled)
	end

	self:isShowTips(info.isTips or false)
	self:setSelect(info.isSelected or false)

	if info.icon then
    	local icon = CCSprite:create(info.icon)
    	icon:setScale(50/icon:getContentSize().width)
    	self._ccbOwner.node_icon:addChild(icon)
    end
end

function QUIWidgetSelectSubBtn:isShowTips(b)
	self._ccbOwner.node_tips:setVisible(b)
end

function QUIWidgetSelectSubBtn:setSelect(b)
	self._ccbOwner.btn_click:setEnabled(not b)
	self._ccbOwner.btn_click:setHighlighted(b)
end

function QUIWidgetSelectSubBtn:_onTriggerClick()
    app.sound:playSound("common_switch")
	self:dispatchEvent({name = QUIWidgetSelectSubBtn.EVENT_CLICK, info = self._info})
end

return QUIWidgetSelectSubBtn
