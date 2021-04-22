--
-- Kumo.Wang
-- 西尔维斯大斗魂场巅峰赛头像
--

local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetSilvesArenaPeakHead = class("QUIWidgetSilvesArenaPeakHead", QUIWidget)
local QUIWidgetAvatar = import("...widgets.QUIWidgetAvatar")
local QUIViewController = import("....ui.QUIViewController")

function QUIWidgetSilvesArenaPeakHead:ctor(options)
	local ccbFile = "ccb/Widget_Group_Head.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetSilvesArenaPeakHead.super.ctor(self,ccbFile,callBacks,options)

	self:resetAll()
end

function QUIWidgetSilvesArenaPeakHead:resetAll()
	self._ccbOwner.tf_nickname:setVisible(false)
	self._ccbOwner.node_self:setVisible(false)
    self._ccbOwner.node_win:setVisible(false)
    self._ccbOwner.node_lose:setVisible(false)
    self._ccbOwner.node_top:setVisible(false)
    self._ccbOwner.node_headPicture:removeAllChildren()
	makeNodeFromGrayToNormal(self._ccbOwner.node_headPicture)
	self._info = {}
	self._avatar = nil
end

function QUIWidgetSilvesArenaPeakHead:setInfo(info, isFail, isClipping)
	self:resetAll()

	self._info = info
	if self._info.leader == nil then
		return
	end

	self._avatar = QUIWidgetAvatar.new()
	if isClipping then
		self._avatar:setSpecialInfo(info.leader.avatar)
	else
		self._avatar:setInfo(info.leader.avatar)
	end
	self._avatar:setSilvesArenaPeak(info.leader.championCount)
    self._ccbOwner.node_headPicture:addChild(self._avatar)

	self._ccbOwner.tf_nickname:setVisible(true)
	self._ccbOwner.tf_nickname:setString(info.teamName or "")

	local fontColor = EQUIPMENT_COLOR[6]
	local isMe = self._info.teamId == remote.silvesArena.myTeamInfo.teamId
    if isMe then
		self._ccbOwner.node_self:setVisible(true)
		fontColor = EQUIPMENT_COLOR[7]
	else
		self._ccbOwner.node_self:setVisible(false)
		fontColor = EQUIPMENT_COLOR[6]
	end
	
	self._ccbOwner.tf_nickname:setColor(fontColor)
	self._ccbOwner.tf_nickname = setShadowByFontColor(self._ccbOwner.tf_nickname, fontColor)

	if isFail ~= nil then
    	self._ccbOwner.node_win:setVisible(not isFail)
    	self._ccbOwner.node_lose:setVisible(isFail)
    	if isFail then
			makeNodeFromNormalToGray(self._ccbOwner.node_headPicture)
		end
    end
end

function QUIWidgetSilvesArenaPeakHead:setIsTopForce(isTop)
    --self._ccbOwner.node_top:setVisible(isTop)
end

function QUIWidgetSilvesArenaPeakHead:setHeadFlipX()
	if self._avatar then
		local scaleX = self._avatar:getScaleX()
		return self._avatar:setScaleX(-scaleX)
	end
end

function QUIWidgetSilvesArenaPeakHead:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetSilvesArenaPeakHead:_onTriggerClick()
	if self._info == nil or self._info.leader == nil then return end


	local _module = remote.silvesArena.BATTLEFORMATION_MODULE_RANK_PVP
	local isMe = self._info.teamId == remote.silvesArena.myTeamInfo.teamId
	if isMe or not remote.silvesArena:isTimeToHideThirdTeam() then
		_module = remote.silvesArena.BATTLEFORMATION_MODULE_RANK_NORMAL
	end
	remote.silvesArena:silvesArenaQueryTeamFighterRequest(self._info.teamId, nil, function()
		if self:safeCheck() then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesBattleFormation",
				options = {teamId = self._info.teamId, module = _module}}, {isPopCurrentDialog = false})
		end
	end)
end

return QUIWidgetSilvesArenaPeakHead