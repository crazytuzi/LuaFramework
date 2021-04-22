--
-- Kumo.Wang
-- 西尔维斯大斗魂场我的队伍界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSilvesArenaMyTeam = class("QUIDialogSilvesArenaMyTeam", QUIDialog)

local QUIViewController = import("..QUIViewController")

local QUIWidgetSilvesArenaMyTeamCell = import("..widgets.QUIWidgetSilvesArenaMyTeamCell")

function QUIDialogSilvesArenaMyTeam:ctor(options)
	local ccbFile = "ccb/Dialog_SilvesArena_MyTeam.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerShare", callback = handler(self, self._onTriggerShare)},
		{ccbCallbackName = "onTriggerList", callback = handler(self, self._onTriggerList)},
		{ccbCallbackName = "onTriggerLeave", callback = handler(self, self._onTriggerLeave)},
		{ccbCallbackName = "onTriggerComplete", callback = handler(self, self._onTriggerComplete)},
    }
    QUIDialogSilvesArenaMyTeam.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    q.setButtonEnableShadow(self._ccbOwner.btn_share)
    q.setButtonEnableShadow(self._ccbOwner.btn_list)
    q.setButtonEnableShadow(self._ccbOwner.btn_leave)
    q.setButtonEnableShadow(self._ccbOwner.btn_share)
    q.setButtonEnableShadow(self._ccbOwner.btn_complete)

    if options then
    	self._callback = options.callback
    end

    self._isComplete = false
    self:_init()
end

function QUIDialogSilvesArenaMyTeam:viewDidAppear()
	QUIDialogSilvesArenaMyTeam.super.viewDidAppear(self)

	self._silvesArenaProxy = cc.EventProxy.new(remote.silvesArena)
    self._silvesArenaProxy:addEventListener(remote.silvesArena.TEAM_UPDATE, handler(self, self._update))

    if remote.silvesArena.haveApply then
		self._ccbOwner.sp_list_tips:setVisible(remote.silvesArena.haveApply or (remote.silvesArena.applyInfo and not q.isEmpty(remote.silvesArena.applyInfo.applyFighter)))
	end
	
	self:_update()
end

function QUIDialogSilvesArenaMyTeam:viewWillDisappear()
  	QUIDialogSilvesArenaMyTeam.super.viewWillDisappear(self)

	self._silvesArenaProxy:removeAllEventListeners()

	if self._countdownSchedule then
		scheduler.unscheduleGlobal(self._countdownSchedule)
		self._countdownSchedule = nil
	end
end

function QUIDialogSilvesArenaMyTeam:_init()
	self._isCaptainPower = false
	if not q.isEmpty(remote.silvesArena.myTeamInfo) then
		self._ccbOwner.tf_team_symbol:setVisible(false)
		if remote.silvesArena.myTeamInfo.symbol then
			self._ccbOwner.tf_team_symbol:setString(remote.silvesArena.myTeamInfo.symbol)
			self._ccbOwner.tf_team_symbol:setVisible(true)
		end

		self._ccbOwner.tf_team_name:setVisible(false)
		if remote.silvesArena.myTeamInfo.teamName then
			self._ccbOwner.tf_team_name:setString(remote.silvesArena.myTeamInfo.teamName)
			self._ccbOwner.tf_team_name:setVisible(true)
		end

		self._widgetCellList = {}
		for i = 1, remote.silvesArena.MAX_TEAM_MEMBER_COUNT, 1 do
			local node = self._ccbOwner["node_player_"..i]
			if node then
				node:removeAllChildren()
				local widgetCell = QUIWidgetSilvesArenaMyTeamCell.new()
				widgetCell:addEventListener(QUIWidgetSilvesArenaMyTeamCell.EVENT_ADD, handler(self, self._onCellEventHandler))
				widgetCell:addEventListener(QUIWidgetSilvesArenaMyTeamCell.EVENT_KICK_OFF, handler(self, self._onCellEventHandler))
				node:addChild(widgetCell)
				self._widgetCellList[i] = widgetCell
			else
				break
			end
		end
	end
end

function QUIDialogSilvesArenaMyTeam:_update()
	if self:safeCheck() then
		local info = remote.silvesArena.myTeamInfo

		if q.isEmpty(info) or info.status == 1 then
			self:_onTriggerClose()
		else
			local index = 1
			for _, cell in ipairs(self._widgetCellList) do
				cell:update()
				if index == 1 then
					if not q.isEmpty(info.leader) then
						cell:update(info.leader, true)
					else
						break
					end
				end

				if index >= 2  and index < 4 then
					if index == 2 and not q.isEmpty(info.member1) then
						cell:update(info.member1)
					elseif not q.isEmpty(info.member2) then
						cell:update(info.member2)
						index = index + 1
					end
				end

				index = index + 1
			end

			if remote.silvesArena.myTeamInfo.leader and remote.silvesArena.myTeamInfo.leader.userId and remote.silvesArena.myTeamInfo.leader.userId == remote.user.userId then
				self._isCaptainPower = true
			end

			if self._isCaptainPower then
				self._ccbOwner.node_btn_share:setVisible(true)
				self._ccbOwner.node_btn_list:setVisible(true)
				self._ccbOwner.node_btn_complete:setVisible(true)
				self._ccbOwner.node_btn_leave:setPositionX(-140)
				self._ccbOwner.node_btn_complete:setPositionX(140)
			else
				self._ccbOwner.node_btn_share:setVisible(false)
				self._ccbOwner.node_btn_list:setVisible(false)
				self._ccbOwner.node_btn_complete:setVisible(false)
				self._ccbOwner.node_btn_leave:setPositionX(0)
			end

			self._ccbOwner.sp_list_tips:setVisible(remote.silvesArena.haveApply or (remote.silvesArena.applyInfo and not q.isEmpty(remote.silvesArena.applyInfo.applyFighter)))
		
			if self._isCaptainPower then
				local isComplete = true
				if q.isEmpty(info.leader) or q.isEmpty(info.member1) or q.isEmpty(info.member2) then
					isComplete = false
				end

				if isComplete == true and self._isComplete == false then
					local startTime = q.serverTime()
					if info.memberChangeAt then
						startTime = info.memberChangeAt / 1000
					end
    				local cd = db:getConfigurationValue("team_arena_timenum") or 0
					self._endTime = startTime + cd
					self:_updateCountdown()
				end

				self._isComplete = isComplete
			end
		end
	end
end

function QUIDialogSilvesArenaMyTeam:_updateCountdown()
	if self._countdownSchedule then
		scheduler.unscheduleGlobal(self._countdownSchedule)
		self._countdownSchedule = nil
	end
	local timeStr = self:_getCountdown()
	if timeStr ~= "" then
		makeNodeFromNormalToGray(self._ccbOwner.btn_complete)
		self._ccbOwner.tf_btn_complete:setString("报名("..timeStr..")")
		self._countdownSchedule = scheduler.scheduleGlobal(function()
			if self:safeCheck() then
				self:_updateCountdown()
			end
		end, 1)
	else
		makeNodeFromGrayToNormal(self._ccbOwner.btn_complete)
		if self._countdownSchedule then
			scheduler.unscheduleGlobal(self._countdownSchedule)
			self._countdownSchedule = nil
		end
		self._ccbOwner.tf_btn_complete:setString("队伍报名")
	end
end

function QUIDialogSilvesArenaMyTeam:_getCountdown()
	local time = (self._endTime or 0) - q.serverTime()
    if time < 0 then
        return ""
    end
    local s = math.floor(time % MIN)
    return string.format("%02d", s)
end

function QUIDialogSilvesArenaMyTeam:_onCellEventHandler(event)
	if event.name == QUIWidgetSilvesArenaMyTeamCell.EVENT_ADD then
		local silvesArenaLastInviteAt = 0
		if remote.silvesArena.myTeamInfo then
			local myTeamInfo = remote.silvesArena.myTeamInfo
			if myTeamInfo.leader and myTeamInfo.leader.userId == remote.user.userId then
				silvesArenaLastInviteAt = myTeamInfo.leader.silvesArenaLastInviteAt
			elseif myTeamInfo.member1 and myTeamInfo.member1.userId == remote.user.userId then
				silvesArenaLastInviteAt = myTeamInfo.member1.silvesArenaLastInviteAt
			elseif myTeamInfo.member2 and myTeamInfo.member2.userId == remote.user.userId then
				silvesArenaLastInviteAt = myTeamInfo.member2.silvesArenaLastInviteAt
			end
		end
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaInviteList",
			options = {callback = handler(self, self._update)}}, {isPopCurrentDialog = false})	
	elseif event.name == QUIWidgetSilvesArenaMyTeamCell.EVENT_KICK_OFF then
		if not self._isCaptainPower then
			app.tip:floatTip("只有队长有操作权限")
			return
		end
		local userId = event.userId
		if userId then
			remote.silvesArena:silvesArenaKickOffTeamRequest(userId, function()
				if self:safeCheck() then
					self:_update()
				end
			end)
		end
	end
end

function QUIDialogSilvesArenaMyTeam:_onTriggerShare(event)
	if event then
		app.sound:playSound("common_small")
	end
	if not self._isCaptainPower then
		app.tip:floatTip("只有队长有操作权限")
		return
	end

	

	local type_chat = SILVES_ARENA_CHAT_TYPE.SILVERS_ARENA_TEAM_SHARE
    local num, unit = q.convertLargerNumber(remote.silvesArena.myTeamInfo.teamMinForce or 0)
    local forceLimit = num..(unit or "")
    local msg = "##n我的小队：##e"..remote.silvesArena.myTeamInfo.teamName.."##n邀请你来和我组成队伍。最低战力要求：##e"..forceLimit.."##n，快来和我一起争夺西尔维斯斗魂场的冠军吧～"
    local btns = {}
    local btnDesc = {}
    if remote.union:checkHaveUnion() then
        btns = {ALERT_BTN.BTN_OK, ALERT_BTN.BTN_CANCEL, ALERT_BTN.BTN_OK_RED, ALERT_BTN.BTN_CLOSE}
        btnDesc = {"宗门频道", "世界频道", "西尔维斯"}
    else
        btns = {ALERT_BTN.BTN_CANCEL, ALERT_BTN.BTN_OK_RED, ALERT_BTN.BTN_CLOSE}
        btnDesc = {"世界频道", "西尔维斯"}
    end
    local options = {layer = app.topLayer, content = "魂师大人，是否要分享西尔维斯组队信息至聊天频道，便于玩家一起来组队？", title = "系统提示",
        btns = btns,
        btnDesc = btnDesc,
        callback = function (type)
        if type == ALERT_TYPE.CONFIRM then
            app:getServerChatData():sendMessage(msg, CHANNEL_TYPE.UNION_CHANNEL, nil, nil, nil, {type = type_chat, teamId = remote.silvesArena.myTeamInfo.teamId}, 
                function(state)
                    if state == 0 then
                        app.tip:floatTip("西尔维斯组队信息已分享到宗门频道~")
                    end
                end)
        elseif type == ALERT_TYPE.CANCEL then
            app:getServerChatData():sendMessage(msg, CHANNEL_TYPE.GLOBAL_CHANNEL, nil, nil, nil, {type = type_chat, teamId = remote.silvesArena.myTeamInfo.teamId},
                function(state)
                    if state == 0 then
                        app.tip:floatTip("西尔维斯组队信息已分享到世界频道~")
                    end
                end)
        elseif type == ALERT_TYPE.CONFIRM_RED then
        	local lastShareAt = remote.silvesArena.myTeamInfo and remote.silvesArena.myTeamInfo.shareAt or 0
			local cd = db:getConfigurationValue("SILVES_ARENA_SHARE_TEAM_CD")
			if lastShareAt + cd * MIN * 1000 > q.serverTime() * 1000 then
				app.tip:floatTip(cd.."分钟之内不能重复分享")
				return
			end
        	remote.silvesArena:silvesArenaChatRequest(type_chat, nil, function(response)
        		remote.silvesArena.myTeamInfo.shareAt = response.serverTime
        	end)
        end
    end}

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaShare", options = options}, {isPopCurrentDialog = false})
end

function QUIDialogSilvesArenaMyTeam:_onTriggerList(event)
	if event then
		app.sound:playSound("common_small")
	end
	if not self._isCaptainPower then
		app.tip:floatTip("只有队长有操作权限")
		return
	end
	self._ccbOwner.sp_list_tips:setVisible(false)
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaApplyList",
		options = {callback = handler(self, self._update)}}, {isPopCurrentDialog = false})	
end

function QUIDialogSilvesArenaMyTeam:_onTriggerLeave(event)
	if event then
		app.sound:playSound("common_small")
	end
	if q.isEmpty(remote.silvesArena.myTeamInfo) or remote.silvesArena.myTeamInfo.status == 1 then
		self:_onTriggerClose()
	else
		remote.silvesArena:silvesArenaQuitTeamRequest(remote.silvesArena.myTeamInfo.teamId, function()
			if self:safeCheck() then
				self:_onTriggerClose()
			end
		end, function()
			if self:safeCheck() then
				self:_onTriggerClose()
			end
		end)
	end
end

function QUIDialogSilvesArenaMyTeam:_onTriggerComplete(event)
	if event then
		app.sound:playSound("common_small")
	end	
	if not self._isCaptainPower then
		app.tip:floatTip("只有队长有操作权限")
		return
	end
	if self:_getCountdown() ~= "" then
		app.tip:floatTip("冷却中，请稍后再试")
		return
	end

	if q.isEmpty(remote.silvesArena.myTeamInfo) or remote.silvesArena.myTeamInfo.status == 1 then
		self:_onTriggerClose()
	else
		if remote.silvesArena.myTeamInfo.memberCnt == remote.silvesArena.MAX_TEAM_MEMBER_COUNT then
			remote.silvesArena:silvesArenaMatchRequest(function()
				if self:safeCheck() then
					app.tip:floatTip("报名成功")
					self:_onTriggerClose()
				end
			end, function()
				if self:safeCheck() then
					self:_onTriggerClose()
				end
			end)
		else
			app.tip:floatTip("人数不够，快去邀请队友吧～")
			return
		end
	end
end

function QUIDialogSilvesArenaMyTeam:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSilvesArenaMyTeam:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSilvesArenaMyTeam:viewAnimationOutHandler()
	local callback = self._callback

	self:popSelf()
	
	if callback then
		callback()
	end
end

return QUIDialogSilvesArenaMyTeam
