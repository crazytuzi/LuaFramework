--
-- Kumo.Wang
-- 1~14日活動菜單按鈕（嘉年華+半月慶典）
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityForSevenButton = class("QUIWidgetActivityForSevenButton", QUIWidget)


QUIWidgetActivityForSevenButton.EVENT_CLICK = "QUIWIDGETACTIVITYFORSEVENBUTTON.EVENT_CLICK"

function QUIWidgetActivityForSevenButton:ctor(options)
	local ccbFile = "ccb/Widget_SevenDayAcitivity_menu.ccbi"
	QUIWidgetActivityForSevenButton.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self:setRedTips(false)
	self:setUnlock(true)
end

function QUIWidgetActivityForSevenButton:setInfo(info, curActivityType)
	self._info = info
	self:refreshInfo()
end

function QUIWidgetActivityForSevenButton:refreshInfo()
	if not self._info then return end

	local titleStr = ""
	if self._info > 9 then
		titleStr = "第"..self._info.."天"
	else
		titleStr = "第"..self._info.."天"
	end
	local title = CCString:create(titleStr)

	self._ccbOwner.btn_click:setTitleForState(title, CCControlStateNormal)
	self._ccbOwner.btn_click:setTitleForState(title, CCControlStateHighlighted)
	self._ccbOwner.btn_click:setTitleForState(title, CCControlStateDisabled)
	self._ccbOwner.btn_click:setLabelAnchorPoint(ccp(0.55, 0.6))
end

function QUIWidgetActivityForSevenButton:setPreviewStated(stated)
	print("QUIWidgetActivityForSevenButton 按钮状态--------",stated)
	if stated == nil then stated = false end
	if stated then
		local title = CCString:create("明日解锁")

		self._ccbOwner.btn_click:setTitleForState(title, CCControlStateNormal)
		self._ccbOwner.btn_click:setTitleForState(title, CCControlStateHighlighted)
		self._ccbOwner.btn_click:setTitleForState(title, CCControlStateDisabled)	
		self._ccbOwner.btn_click:setLabelAnchorPoint(ccp(0.45, 0.6))	
	end
end

function QUIWidgetActivityForSevenButton:setRedTips(boo)
	self._ccbOwner.sp_tips:setVisible(boo)
end

function QUIWidgetActivityForSevenButton:setUnlock(boo)
	self._ccbOwner.sp_unlock:setVisible(boo)
end

function QUIWidgetActivityForSevenButton:getInfo()
	return self._info
end

function QUIWidgetActivityForSevenButton:setSelect(b)
	self._ccbOwner.btn_click:setHighlighted(b)
	self._ccbOwner.btn_click:setEnabled(not b)
end

function QUIWidgetActivityForSevenButton:onTriggerClick()
	self:dispatchEvent({name = QUIWidgetActivityForSevenButton.EVENT_CLICK, day = self._info})
end

function QUIWidgetActivityForSevenButton:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetActivityForSevenButton