--
-- Kumo.Wang
-- 西尔维斯大斗魂场组队列表元素
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaRoomList = class("QUIWidgetSilvesArenaRoomList", QUIWidget)

local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

function QUIWidgetSilvesArenaRoomList:ctor(options)
	local ccbFile = "ccb/Widget_SilvesArena_RoomList.ccbi"
  	local callBacks = {}
	QUIWidgetSilvesArenaRoomList.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSilvesArenaRoomList:onEnter()
	QUIWidgetSilvesArenaRoomList.super.onEnter(self)
end

function QUIWidgetSilvesArenaRoomList:onExit()
	QUIWidgetSilvesArenaRoomList.super.onExit(self)
end

function QUIWidgetSilvesArenaRoomList:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetSilvesArenaRoomList:getInfo()
	return self._info
end

function QUIWidgetSilvesArenaRoomList:update(info)
	if q.isEmpty(info) then
		return
	end

	self._info = info

	if self._info.isApplied then
		self._ccbOwner.node_my_applied:setVisible(true)			
		-- self._ccbOwner.node_btn_apply:setVisible(false)
		self._ccbOwner.tf_btn_apply:setString("取 消")
	else
		self._ccbOwner.node_my_applied:setVisible(false)			
		-- self._ccbOwner.node_btn_apply:setVisible(true)
		self._ccbOwner.tf_btn_apply:setString("申 请")
	end
end

function QUIWidgetSilvesArenaRoomList:setInfo(info)
	self:update(info)

	local index = 1
	while true do
		local node = self._ccbOwner["node_player_head_"..index]
		if node then
			node:removeAllChildren()
			if index == 1 then
				if info.leader and info.leader.avatar then
					local head = QUIWidgetAvatar.new(info.leader.avatar)
					head:setSilvesArenaPeak(info.leader.championCount)
					node:addChild(head)
				else
					break
				end
			end

			if index >= 2 then
				if index == 2 and info.member1 and info.member1.avatar then
					local head = QUIWidgetAvatar.new(info.member1.avatar)
					head:setSilvesArenaPeak(info.member1.championCount)
					node:addChild(head)
				elseif info.member2 and info.member2.avatar then
					local head = QUIWidgetAvatar.new(info.member2.avatar)
					head:setSilvesArenaPeak(info.member2.championCount)
					node:addChild(head)
					break
				end
			end
			index = index + 1
		else
			break
		end
	end

	self._ccbOwner.tf_room_symbol:setVisible(false)
	if info.symbol then
		self._ccbOwner.tf_room_symbol:setString(info.symbol)
		self._ccbOwner.tf_room_symbol:setVisible(true)
	end

	self._ccbOwner.tf_team_name:setVisible(false)
	if info.teamName then
		self._ccbOwner.tf_team_name:setString(info.teamName)
		self._ccbOwner.tf_team_name:setVisible(true)
	end

	self._ccbOwner.tf_force_limit:setVisible(false)
	if info.teamMinForce then
		local num, unit = q.convertLargerNumber(info.teamMinForce)
		self._ccbOwner.tf_force_limit:setString(num..(unit or ""))
		self._ccbOwner.tf_force_limit:setVisible(true)
	end

	local totalForce = 0
	local totalNumber = 0
	if info.totalForce and info.totalForce ~= 0 then
		totalForce = info.totalForce
		if not q.isEmpty(info.leader) and info.leader.force then
			totalNumber = totalNumber + 1
		end
		if not q.isEmpty(info.member1) and info.member1.force then
			totalNumber = totalNumber + 1
		end
		if not q.isEmpty(info.member2) and info.member2.force then
			totalNumber = totalNumber + 1
		end
	else
		if not q.isEmpty(info.leader) then
			totalForce = totalForce + (info.leader.force or 0)
			if info.leader.force and info.leader.force > 0 then
				totalNumber = totalNumber + 1
			end
		end
		if not q.isEmpty(info.member1) then
			totalForce = totalForce + (info.member1.force or 0)
			if info.member1.force and info.member1.force > 0 then
				totalNumber = totalNumber + 1
			end
		end
		if not q.isEmpty(info.member2) then
			totalForce = totalForce + (info.member2.force or 0)
			if info.member2.force and info.member2.force > 0 then
				totalNumber = totalNumber + 1
			end
		end
	end

	local _totalForce = math.floor(totalForce / totalNumber)
	local num, unit = q.convertLargerNumber(_totalForce)
	self._ccbOwner.tf_team_force:setString(num..(unit or ""))
	local fontInfo = db:getForceColorByForce(_totalForce, true)
    if fontInfo ~= nil then
        local color = string.split(fontInfo.force_color, ";")
        self._ccbOwner.tf_team_force:setColor(ccc3(color[1], color[2], color[3]))
    end
	self._ccbOwner.tf_team_force:setVisible(true)

	print("[ROOM] ", info.teamName, _totalForce, totalForce, totalNumber)
end

return QUIWidgetSilvesArenaRoomList