--
-- Author: Kumo
-- 魂师召回主界面菜单按钮
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetUserComeBackButton = class("QUIWidgetUserComeBackButton", QUIWidget)

function QUIWidgetUserComeBackButton:ctor(options)
	local ccbFile = "ccb/Widget_ComeBack_Button.ccbi"
	QUIWidgetUserComeBackButton.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetUserComeBackButton:refreshInfo()
	self:setInfo(self._info)
end

function QUIWidgetUserComeBackButton:setInfo(info)
	self._info = info
	local titleStr = self._info.title or ""
	self._ccbOwner.btn_click:setTitleForState(CCString:create(titleStr), CCControlStateNormal)
	self._ccbOwner.btn_click:setTitleForState(CCString:create(titleStr), CCControlStateHighlighted)
	self._ccbOwner.btn_click:setTitleForState(CCString:create(titleStr), CCControlStateDisabled)
	
	local isRedTips = false
	if info.type == remote.playerRecall.TYPE_AWARD then
		isRedTips = remote.redTips:getTipsStateByName("QPlayerRecall_AwardButtonTips")
	elseif info.type == remote.playerRecall.TYPE_FEATRUE then
		isRedTips = remote.redTips:getTipsStateByName("QPlayerRecall_FeatureButtonTips")
	elseif info.type == remote.playerRecall.TYPE_PAY then
		isRedTips = remote.redTips:getTipsStateByName("QPlayerRecall_PayButtonTips")
	elseif info.type == remote.playerRecall.TYPE_BUFF then
		isRedTips = false
	elseif info.type == remote.playerRecall.TYPE_TASK then
		isRedTips = remote.redTips:getTipsStateByName("QPlayerRecall_TaskButtonTips")
	elseif info.type == remote.userComeBack.TYPE_AWARD then
		isRedTips = remote.redTips:getTipsStateByName("QUIDialogUserComeBack_AwardButtonTips")
	elseif info.type == remote.userComeBack.TYPE_PAY then
		isRedTips = remote.redTips:getTipsStateByName("QUIDialogUserComeBack_PayButtonTips")
	end

	self._ccbOwner.sp_tips:setVisible(isRedTips)
end

function QUIWidgetUserComeBackButton:getInfo()
	return self._info
end

function QUIWidgetUserComeBackButton:setSelect(b)
	if b and self._info.type == remote.playerRecall.TYPE_PAY then
		self._ccbOwner.sp_tips:setVisible(false)
	end
	self._ccbOwner.btn_click:setHighlighted(b)
	self._ccbOwner.btn_click:setEnabled(not b)
end

function QUIWidgetUserComeBackButton:getContentSize() 
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetUserComeBackButton