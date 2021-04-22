local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogblackRockBattleLost = class("QUIDialogblackRockBattleLost", QUIDialog)
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogblackRockBattleLost:ctor(options)
	local ccbFile = "ccb/Dialog_Black_mountain_jssl.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerNext", callback = handler(self, self._onTriggerNext)},
	}
	QUIDialogblackRockBattleLost.super.ctor(self,ccbFile,callBacks,options)

	self._info = options.info
	self._callBack = options.callBack
	
    CalculateUIBgSize(self._ccbOwner.ly_bg)

	self._ccbOwner.node_win_star_title:setVisible(false)
	self._ccbOwner.node_lost:setVisible(true)
	self._ccbOwner.node_no:setVisible(false)
	self._ccbOwner.node_btn_next:setPositionX(0)
	self._ccbOwner.tf_next:setString("确 定")
	self._ccbOwner.node_btn_double:setVisible(false)
	self._ccbOwner.node_btn_notget:setVisible(false)
	local passInfo = {}
	if self._info then
		for _,progress in ipairs(self._info.teamProgress.allProgress) do
			passInfo[progress.memberId] = {isWin = progress.isWin, pos = progress.memberPos}
		end

	    if self._info.leader ~= nil then
	    	local passInfo = passInfo[self._info.leader.userId]
	    	local fighterWidget = self:generateFighter(self._info.leader, passInfo.isWin)
			self._ccbOwner["hero_node"..passInfo.pos]:addChild(fighterWidget)
	    end

	    if self._info.member1 ~= nil then
	    	local passInfo = passInfo[self._info.member1.userId]
	    	local fighterWidget = self:generateFighter(self._info.member1, passInfo.isWin)
			self._ccbOwner["hero_node"..passInfo.pos]:addChild(fighterWidget)
	    end  

	    if self._info.member2 ~= nil then
	    	local passInfo = passInfo[self._info.member2.userId]
	    	local fighterWidget = self:generateFighter(self._info.member2, passInfo.isWin)
			self._ccbOwner["hero_node"..passInfo.pos]:addChild(fighterWidget)
	    end
    end 
end

function QUIDialogblackRockBattleLost:generateFighter(fighter, isWin)
	local widget = QUIWidget.new("Widget_Black_mountain_jssl.ccbi")

	widget._ccbOwner.node_pass:setVisible(isWin)
	widget._ccbOwner.node_fail:setVisible(not isWin)
	local num,uint = q.convertLargerNumber(fighter.topnForce or 0)
	widget._ccbOwner.tf_force:setString(num..(uint or ""))
	
    local fontInfo = QStaticDatabase:sharedDatabase():getForceColorByForce(tonumber(fighter.topnForce),true)
	local color = string.split(fontInfo.force_color, ";")
	widget._ccbOwner.tf_force:setColor(ccc3(color[1], color[2], color[3]))	

	widget._ccbOwner.tf_name:setString("LV."..fighter.level.." "..fighter.name)

	makeNodeFromNormalToGray(widget._ccbOwner.hero_node)
	
	local avatar = QUIWidgetAvatar.new(fighter.avatar)
	avatar:setSilvesArenaPeak(fighter.championCount)
	widget._ccbOwner.node_head:addChild(avatar)

	return widget
end

function QUIDialogblackRockBattleLost:_backClickHandler()
	self:viewAnimationOutHandler()
end

function QUIDialogblackRockBattleLost:_onTriggerNext(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_next) == false then return end
	self:viewAnimationOutHandler()
end

function QUIDialogblackRockBattleLost:viewAnimationOutHandler()
	local callBack = self._callBack
	self:popSelf()
	if callBack ~= nil then
		callBack()
	end
end

return QUIDialogblackRockBattleLost