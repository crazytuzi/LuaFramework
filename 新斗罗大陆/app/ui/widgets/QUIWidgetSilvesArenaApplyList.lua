--
-- Kumo.Wang
-- 西尔维斯大斗魂场组队列表元素
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaApplyList = class("QUIWidgetSilvesArenaApplyList", QUIWidget)

local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

function QUIWidgetSilvesArenaApplyList:ctor(options)
	local ccbFile = "ccb/Widget_SilvesArena_PlayerList.ccbi"
  	local callBacks = {}
	QUIWidgetSilvesArenaApplyList.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.node_btn_promise:setVisible(true)
	self._ccbOwner.node_btn_refuse:setVisible(true)
	self._ccbOwner.node_btn_select_invite:setVisible(false)

	self._ccbOwner.node_type:setVisible(false)
end

function QUIWidgetSilvesArenaApplyList:onEnter()
	QUIWidgetSilvesArenaApplyList.super.onEnter(self)
end

function QUIWidgetSilvesArenaApplyList:onExit()
	QUIWidgetSilvesArenaApplyList.super.onExit(self)
end

function QUIWidgetSilvesArenaApplyList:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetSilvesArenaApplyList:getInfo()
	return self._info
end

function QUIWidgetSilvesArenaApplyList:update(info)
	if q.isEmpty(info) then
		return
	end

	self._info = info
end

function QUIWidgetSilvesArenaApplyList:setInfo(info)
	self:update(info)

	self._ccbOwner.node_player_head:removeAllChildren()
	if info.avatar then
		local head = QUIWidgetAvatar.new(info.avatar)
		head:setSilvesArenaPeak(info.championCount)
		self._ccbOwner.node_player_head:addChild(head)
	end

	self._ccbOwner.sp_soulTrial:setVisible(false)
	if info.soulTrial then
		local _, frame = remote.soulTrial:getSoulTrialTitleSpAndFrame(info.soulTrial)
		if frame then
			self._ccbOwner.sp_soulTrial:setDisplayFrame(frame)
			self._ccbOwner.sp_soulTrial:setVisible(true)
		end
	end

	self._ccbOwner.tf_player_level:setVisible(false)
	if info.level then
		self._ccbOwner.tf_player_level:setString("LV."..info.level)
		self._ccbOwner.tf_player_level:setVisible(true)
	end

	self._ccbOwner.tf_player_name:setVisible(false)
	if info.name then
		self._ccbOwner.tf_player_name:setString(info.name)
		self._ccbOwner.tf_player_name:setVisible(true)
	end

	self._ccbOwner.tf_player_vip:setVisible(false)
	if info.vip then
		self._ccbOwner.tf_player_vip:setString("VIP"..info.vip)
		self._ccbOwner.tf_player_vip:setVisible(true)
	end

	self._ccbOwner.tf_area_name:setVisible(false)
	if info.game_area_name then
		self._ccbOwner.tf_area_name:setString(info.game_area_name)
		self._ccbOwner.tf_area_name:setVisible(true)
	end

	self._ccbOwner.tf_player_force:setVisible(false)
	if info.force then
		local num, unit = q.convertLargerNumber(info.force)
		self._ccbOwner.tf_player_force:setString(num..(unit or ""))
		local fontInfo = db:getForceColorByForce(info.force, true)
	    if fontInfo ~= nil then
	        local color = string.split(fontInfo.force_color, ";")
	        self._ccbOwner.tf_player_force:setColor(ccc3(color[1], color[2], color[3]))
	    end
		self._ccbOwner.tf_player_force:setVisible(true)
	end

	self._ccbOwner.tf_warning:setVisible(false)
	if not q.isEmpty(remote.silvesArena.myTeamInfo) then
		local forceLimit = remote.silvesArena.myTeamInfo.teamMinForce or 0
		if forceLimit > info.force then
			self._ccbOwner.tf_warning:setVisible(true)
		end
	end

	q.autoLayerNode({self._ccbOwner.sp_soulTrial, self._ccbOwner.tf_player_level, self._ccbOwner.tf_player_name, self._ccbOwner.tf_player_vip}, "x", 5)
end

return QUIWidgetSilvesArenaApplyList