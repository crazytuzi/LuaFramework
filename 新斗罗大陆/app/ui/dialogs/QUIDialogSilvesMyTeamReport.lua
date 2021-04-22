--
-- Kumo.Wang
-- 西尔维斯大斗魂场我的队伍的今日战绩
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSilvesMyTeamReport = class("QUIDialogSilvesMyTeamReport", QUIDialog)

local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

function QUIDialogSilvesMyTeamReport:ctor(options)
	local ccbFile = "ccb/Dialog_SilvesArena_MyTeam_Report.ccbi"
    local callBacks = {}
    QUIDialogSilvesMyTeamReport.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    self:_init()
end

function QUIDialogSilvesMyTeamReport:viewDidAppear()
	QUIDialogSilvesMyTeamReport.super.viewDidAppear(self)
end

function QUIDialogSilvesMyTeamReport:viewAnimationInHandler()
	QUIDialogSilvesMyTeamReport.super.viewAnimationInHandler(self)
end

function QUIDialogSilvesMyTeamReport:viewWillDisappear()
  	QUIDialogSilvesMyTeamReport.super.viewWillDisappear(self)
end

function QUIDialogSilvesMyTeamReport:_reset()
	self._ccbOwner.sp_captain:setVisible(false)

	self._ccbOwner.node_head_1:removeAllChildren()
	self._ccbOwner.tf_name_1:setVisible(false)
	self._ccbOwner.tf_count_1:setVisible(false)
	self._ccbOwner.sp_mine_1:setVisible(false)
	self._ccbOwner.node_result_1:removeAllChildren()

	self._ccbOwner.node_head_2:removeAllChildren()
	self._ccbOwner.tf_name_2:setVisible(false)
	self._ccbOwner.tf_count_2:setVisible(false)
	self._ccbOwner.sp_mine_2:setVisible(false)
	self._ccbOwner.node_result_2:removeAllChildren()

	self._ccbOwner.node_head_3:removeAllChildren()
	self._ccbOwner.tf_name_3:setVisible(false)
	self._ccbOwner.tf_count_3:setVisible(false)
	self._ccbOwner.sp_mine_3:setVisible(false)
	self._ccbOwner.node_result_3:removeAllChildren()
end

function QUIDialogSilvesMyTeamReport:_init()
	self:_reset()

	if q.isEmpty(remote.silvesArena.todayTeamBattleInfo) or q.isEmpty(remote.silvesArena.myTeamInfo) then
		return
	end
	
	local fightCnt = db:getConfigurationValue("silves_arena_day_fight_count")

	local todayTeamBattleInfo = {}
	for _, info in ipairs(remote.silvesArena.todayTeamBattleInfo) do
		todayTeamBattleInfo[info.userId] = info
	end

	self._ccbOwner.node_head_1:removeAllChildren()
	if not q.isEmpty(remote.silvesArena.myTeamInfo.leader) then
		if remote.silvesArena.myTeamInfo.leader.avatar then
			local head = QUIWidgetAvatar.new(remote.silvesArena.myTeamInfo.leader.avatar)
			head:setSilvesArenaPeak(remote.silvesArena.myTeamInfo.leader.championCount)
			self._ccbOwner.node_head_1:addChild(head)
			self._ccbOwner.sp_captain:setVisible(true)
		end

		if remote.silvesArena.myTeamInfo.leader.name then
			self._ccbOwner.tf_name_1:setString(remote.silvesArena.myTeamInfo.leader.name)
			self._ccbOwner.tf_name_1:setVisible(true)
		end

		if remote.silvesArena.myTeamInfo.leader.userId then
			if remote.silvesArena.myTeamInfo.leader.userId == remote.user.userId then
				self._ccbOwner.sp_mine_1:setVisible(true)
			end

			local battleInfo = todayTeamBattleInfo[remote.silvesArena.myTeamInfo.leader.userId]
			if not q.isEmpty(battleInfo) then
				if q.isEmpty(battleInfo.success) then
					self._ccbOwner.tf_count_1:setString(fightCnt)
				else
					self._ccbOwner.tf_count_1:setString(fightCnt - #(battleInfo.success))
				end
				self._ccbOwner.tf_count_1:setVisible(true)

				self._ccbOwner.node_result_1:removeAllChildren()
				local resultIndex = 0
				local spaceX = 60
				if not q.isEmpty(battleInfo.success) then
					for _, isWin in ipairs(battleInfo.success) do
						local path = ""
						if isWin then
							path = QResPath("score_result_flag")[1]
						else
							path = QResPath("score_result_flag")[2]
						end

						local sp = CCSprite:create(path)
						if sp then
							sp:setPosition(ccp(spaceX * resultIndex, 0))
							self._ccbOwner.node_result_1:addChild(sp)
							resultIndex = resultIndex + 1
						end
					end
				end

				for i = resultIndex, fightCnt - 1, 1 do
					local path = QResPath("score_result_flag")[4]
					local sp = CCSprite:create(path)
					if sp then
						sp:setPosition(ccp(spaceX * i, 0))
						self._ccbOwner.node_result_1:addChild(sp)
					end
				end
			end
		end
	end

	self._ccbOwner.node_head_2:removeAllChildren()
	if not q.isEmpty(remote.silvesArena.myTeamInfo.member1) then
		if remote.silvesArena.myTeamInfo.member1.avatar then
			local head = QUIWidgetAvatar.new(remote.silvesArena.myTeamInfo.member1.avatar)
			head:setSilvesArenaPeak(remote.silvesArena.myTeamInfo.member1.championCount)
			self._ccbOwner.node_head_2:addChild(head)
		end

		if remote.silvesArena.myTeamInfo.member1.name then
			self._ccbOwner.tf_name_2:setString(remote.silvesArena.myTeamInfo.member1.name)
			self._ccbOwner.tf_name_2:setVisible(true)
		end

		if remote.silvesArena.myTeamInfo.member1.userId then
			if remote.silvesArena.myTeamInfo.member1.userId == remote.user.userId then
				self._ccbOwner.sp_mine_2:setVisible(true)
			end

			local battleInfo = todayTeamBattleInfo[remote.silvesArena.myTeamInfo.member1.userId]
			if not q.isEmpty(battleInfo) then
				if q.isEmpty(battleInfo.success) then
					self._ccbOwner.tf_count_2:setString(fightCnt)
				else
					self._ccbOwner.tf_count_2:setString(fightCnt - #(battleInfo.success))
				end
				self._ccbOwner.tf_count_2:setVisible(true)

				self._ccbOwner.node_result_2:removeAllChildren()
				local resultIndex = 0
				local spaceX = 60
				if not q.isEmpty(battleInfo.success) then
					for _, isWin in ipairs(battleInfo.success) do
						local path = ""
						if isWin then
							path = QResPath("score_result_flag")[1]
						else
							path = QResPath("score_result_flag")[2]
						end

						local sp = CCSprite:create(path)
						if sp then
							sp:setPosition(ccp(spaceX * resultIndex, 0))
							self._ccbOwner.node_result_2:addChild(sp)
							resultIndex = resultIndex + 1
						end
					end
				end

				for i = resultIndex, fightCnt - 1, 1 do
					local path = QResPath("score_result_flag")[4]
					local sp = CCSprite:create(path)
					if sp then
						sp:setPosition(ccp(spaceX * i, 0))
						self._ccbOwner.node_result_2:addChild(sp)
					end
				end
			end
		end
	end

	self._ccbOwner.node_head_3:removeAllChildren()
	if not q.isEmpty(remote.silvesArena.myTeamInfo.member2) then
		if remote.silvesArena.myTeamInfo.member2.avatar then
			local head = QUIWidgetAvatar.new(remote.silvesArena.myTeamInfo.member2.avatar)
			head:setSilvesArenaPeak(remote.silvesArena.myTeamInfo.member2.championCount)
			self._ccbOwner.node_head_3:addChild(head)
		end

		if remote.silvesArena.myTeamInfo.member2.name then
			self._ccbOwner.tf_name_3:setString(remote.silvesArena.myTeamInfo.member2.name)
			self._ccbOwner.tf_name_3:setVisible(true)
		end

		if remote.silvesArena.myTeamInfo.member2.userId then
			if remote.silvesArena.myTeamInfo.member2.userId == remote.user.userId then
				self._ccbOwner.sp_mine_3:setVisible(true)
			end

			local battleInfo = todayTeamBattleInfo[remote.silvesArena.myTeamInfo.member2.userId]
			if not q.isEmpty(battleInfo) then
				if q.isEmpty(battleInfo.success) then
					self._ccbOwner.tf_count_3:setString(fightCnt)
				else
					self._ccbOwner.tf_count_3:setString(fightCnt - #(battleInfo.success))
				end
				self._ccbOwner.tf_count_3:setVisible(true)

				self._ccbOwner.node_result_3:removeAllChildren()
				local resultIndex = 0
				local spaceX = 60
				if not q.isEmpty(battleInfo.success) then
					for _, isWin in ipairs(battleInfo.success) do
						local path = ""
						if isWin then
							path = QResPath("score_result_flag")[1]
						else
							path = QResPath("score_result_flag")[2]
						end

						local sp = CCSprite:create(path)
						if sp then
							sp:setPosition(ccp(spaceX * resultIndex, 0))
							self._ccbOwner.node_result_3:addChild(sp)
							resultIndex = resultIndex + 1
						end
					end
				end

				for i = resultIndex, fightCnt - 1, 1 do
					local path = QResPath("score_result_flag")[4]
					local sp = CCSprite:create(path)
					if sp then
						sp:setPosition(ccp(spaceX * i, 0))
						self._ccbOwner.node_result_3:addChild(sp)
					end
				end
			end
		end
	end
end

function QUIDialogSilvesMyTeamReport:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSilvesMyTeamReport:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSilvesMyTeamReport:viewAnimationOutHandler()
	local callback = self._callback

	self:popSelf()
	
	if callback then
		callback()
	end
end

return QUIDialogSilvesMyTeamReport
