--
-- Kumo.Wang
-- 西尔维斯大斗魂场战斗期准备战斗界面
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaAgainstClient = class("QUIWidgetSilvesArenaAgainstClient", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QUIWidgetSilvesArenaAgainstClientCell = import(".QUIWidgetSilvesArenaAgainstClientCell")

QUIWidgetSilvesArenaAgainstClient.EVENT_CLIENT = "QUIWIDGETSILVESARENAAGAINSTCLIENT.EVENT_CLIENT"

function QUIWidgetSilvesArenaAgainstClient:ctor(options)
	local ccbFile = "ccb/Widget_SilvesArena_Against.ccbi"
  	local callBacks = {
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
  	}
	QUIWidgetSilvesArenaAgainstClient.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    q.setButtonEnableShadow(self._ccbOwner.btn_set)
    q.setButtonEnableShadow(self._ccbOwner.btn_ok)

    if options then
    	self._scale = options.scale or 1
    end

	self:_init()
end

function QUIWidgetSilvesArenaAgainstClient:onEnter()
	QUIWidgetSilvesArenaAgainstClient.super.onEnter(self)
	
	self._silvesArenaProxy = cc.EventProxy.new(remote.silvesArena)
    self._silvesArenaProxy:addEventListener(remote.silvesArena.EVENT_FIGHT_START, handler(self, self._showFightEffect))
    self._silvesArenaProxy:addEventListener(remote.silvesArena.EVENT_FIGHT_END, handler(self, self._showFightEnd))

	self:update()
end

function QUIWidgetSilvesArenaAgainstClient:onExit()
	QUIWidgetSilvesArenaAgainstClient.super.onExit(self)

	self._silvesArenaProxy:removeAllEventListeners()
end

function QUIWidgetSilvesArenaAgainstClient:getClassName()
	return "QUIWidgetSilvesArenaAgainstClient"
end

function QUIWidgetSilvesArenaAgainstClient:_reset()
	self._ccbOwner.node_against_view:setScale(self._scale)

	for i = 1, remote.silvesArena.MAX_TEAM_MEMBER_COUNT , 1 do
		local enemyNode = self._ccbOwner["node_enemy_"..i]
		if enemyNode then
			enemyNode:removeAllChildren()
			enemyNode:setVisible(true)
		end

		local userNode = self._ccbOwner["node_user_"..i]
		if userNode then
			userNode:removeAllChildren()
			userNode:setVisible(true)
		end
	end
	self._ccbOwner.sp_select:setVisible(false)
end

function QUIWidgetSilvesArenaAgainstClient:update()
	if q.isEmpty(remote.silvesArena.againstTeamInfo) then
		if q.isEmpty(remote.silvesArena.fightInfo.defenseFightInfo) then
			self:_reset()
			return
		else
			remote.silvesArena.againstTeamInfo = remote.silvesArena.fightInfo.defenseFightInfo
			self:_updateView()
		end
	else
		self:_updateView()
	end
end

function QUIWidgetSilvesArenaAgainstClient:_init()
	self:_reset()
	self:_initMyInfo()
	self:_initTouchLayer()
	self._avatarDic = {userAvatar = {}, enemyAvatar = {}}
end

function QUIWidgetSilvesArenaAgainstClient:_updateView()
	self:_updateEnemyTeamView()
	self:_updateUserTeamInfo()
end

function QUIWidgetSilvesArenaAgainstClient:_updateEnemyTeamView()
	if q.isEmpty(remote.silvesArena.againstTeamInfo) then return end

	local enemyTeamList = {}
	if not q.isEmpty(remote.silvesArena.againstTeamInfo.leader) then
		table.insert(enemyTeamList, remote.silvesArena.againstTeamInfo.leader)
	end
	if not q.isEmpty(remote.silvesArena.againstTeamInfo.member1) then
		table.insert(enemyTeamList, remote.silvesArena.againstTeamInfo.member1)
	end
	if not q.isEmpty(remote.silvesArena.againstTeamInfo.member2) then
		table.insert(enemyTeamList, remote.silvesArena.againstTeamInfo.member2)
	end
	if #enemyTeamList == 0 then
		if not q.isEmpty(remote.silvesArena.againstTeamInfo[1]) then
			table.insert(enemyTeamList, remote.silvesArena.againstTeamInfo[1])
		end
		if not q.isEmpty(remote.silvesArena.againstTeamInfo[2]) then
			table.insert(enemyTeamList, remote.silvesArena.againstTeamInfo[2])
		end
		if not q.isEmpty(remote.silvesArena.againstTeamInfo[3]) then
			table.insert(enemyTeamList, remote.silvesArena.againstTeamInfo[3])
		end
	end

	table.sort(enemyTeamList, function(a, b)
		return a.silvesArenaFightPos < b.silvesArenaFightPos
	end)

	for i = 1, remote.silvesArena.MAX_TEAM_MEMBER_COUNT, 1 do
		local node = self._ccbOwner["node_enemy_"..i]
		if node then
			node:removeAllChildren()
			if enemyTeamList and enemyTeamList[i] and enemyTeamList[i].defaultActorId then
				local avatar = QUIWidgetSilvesArenaAgainstClientCell.new({ info = enemyTeamList[i], index = i, isUser = false })
				node:addChild(avatar)
				self._avatarDic.enemyAvatar[i] = avatar
			end
		end
	end
end

function QUIWidgetSilvesArenaAgainstClient:_updateUserTeamInfo(tbl)
	if self._ccbView then
		if q.isEmpty(remote.silvesArena.myTeamInfo) then return end
		if not q.isEmpty(tbl) then
			self._tempPlayerOrder = tbl
		end
		if q.isEmpty(self._tempPlayerOrder) then
			self._tempPlayerOrder = {}
			if not q.isEmpty(remote.silvesArena.myTeamInfo.leader) then
				self._tempPlayerOrder[remote.silvesArena.myTeamInfo.leader.userId] = remote.silvesArena.myTeamInfo.leader.silvesArenaFightPos
			end
			if not q.isEmpty(remote.silvesArena.myTeamInfo.member1) then
				self._tempPlayerOrder[remote.silvesArena.myTeamInfo.member1.userId] = remote.silvesArena.myTeamInfo.member1.silvesArenaFightPos
			end
			if not q.isEmpty(remote.silvesArena.myTeamInfo.member2) then
				self._tempPlayerOrder[remote.silvesArena.myTeamInfo.member2.userId] = remote.silvesArena.myTeamInfo.member2.silvesArenaFightPos
			end
		end
		local userTeamList = {}
		if not q.isEmpty(remote.silvesArena.myTeamInfo.leader) then
			table.insert(userTeamList, remote.silvesArena.myTeamInfo.leader)
		end
		if not q.isEmpty(remote.silvesArena.myTeamInfo.member1) then
			table.insert(userTeamList, remote.silvesArena.myTeamInfo.member1)
		end
		if not q.isEmpty(remote.silvesArena.myTeamInfo.member2) then
			table.insert(userTeamList, remote.silvesArena.myTeamInfo.member2)
		end

		table.sort(userTeamList, function(a, b)
			local aOrderPos = self._tempPlayerOrder and self._tempPlayerOrder[a.userId]
			local bOrderPos = self._tempPlayerOrder and self._tempPlayerOrder[b.userId]
			if aOrderPos and bOrderPos then
				return aOrderPos < bOrderPos
			else
				return a.silvesArenaFightPos < b.silvesArenaFightPos
			end
		end)

		for i = 1, remote.silvesArena.MAX_TEAM_MEMBER_COUNT, 1 do
			local node = self._ccbOwner["node_user_"..i]
			if node then
				node:removeAllChildren()
				if userTeamList and userTeamList[i] and userTeamList[i].defaultActorId then
					local avatar = QUIWidgetSilvesArenaAgainstClientCell.new({ info = userTeamList[i], index = i, isUser = true })
					node:addChild(avatar)
					self._avatarDic.userAvatar[i] = avatar
				end
			end
		end
	end
end

function QUIWidgetSilvesArenaAgainstClient:_initMyInfo()
	self._isSkipBattle = app:getUserOperateRecord():getRecordByType("SIVES_ARENA_SKIP_BATTLE")
	self._ccbOwner.sp_select:setVisible(self._isSkipBattle)
end

function QUIWidgetSilvesArenaAgainstClient:_onTriggerSelect(event)
	if event then
		app.sound:playSound("common_small")
	end
	
	if not q.isEmpty(remote.silvesArena.fightInfo) then
		app.tip:floatTip("战斗中")
		return
	end

	self._isSkipBattle = not self._isSkipBattle
	self._ccbOwner.sp_select:setVisible(self._isSkipBattle)
	app:getUserOperateRecord():setRecordByType("SIVES_ARENA_SKIP_BATTLE", self._isSkipBattle)
end

function QUIWidgetSilvesArenaAgainstClient:_onTriggerSet()
	if not q.isEmpty(remote.silvesArena.fightInfo) then
		app.tip:floatTip("战斗中")
		return
	end

	if q.isEmpty(remote.silvesArena.myTeamInfo ) then return end
	if q.isEmpty(remote.silvesArena.againstTeamInfo) then return end

	local enemyTeamList = {}
	if not q.isEmpty(remote.silvesArena.againstTeamInfo.leader) then
		table.insert(enemyTeamList, remote.silvesArena.againstTeamInfo.leader)
	end
	if not q.isEmpty(remote.silvesArena.againstTeamInfo.member1) then
		table.insert(enemyTeamList, remote.silvesArena.againstTeamInfo.member1)
	end
	if not q.isEmpty(remote.silvesArena.againstTeamInfo.member2) then
		table.insert(enemyTeamList, remote.silvesArena.againstTeamInfo.member2)
	end

	table.sort(enemyTeamList, function(a, b)
		return a.silvesArenaFightPos < b.silvesArenaFightPos
	end)

	remote.silvesArena:silvesArenaQueryTeamFighterRequest(remote.silvesArena.myTeamInfo.teamId, nil, function()
		remote.silvesArena:silvesArenaQueryTeamFighterRequest(remote.silvesArena.againstTeamInfo.teamId, nil, function()
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesBattleFormationAgainst",
				options = {enemyTeamId = remote.silvesArena.againstTeamInfo.teamId, tempPlayerOrder = self._tempPlayerOrder, callback = handler(self, self._updateUserTeamInfo)}}, {isPopCurrentDialog = false})	
		end)
	end)
end

function QUIWidgetSilvesArenaAgainstClient:_onTriggerOK(event)
	if event then
		app.sound:playSound("common_small")
	end

	if not q.isEmpty(remote.silvesArena.fightInfo) then
		app.tip:floatTip("战斗中")
		return
	end

	if q.isEmpty(remote.silvesArena.againstTeamInfo) then
		app.tip:floatTip("无效的对手，请返回")
		return
	end

	local tbl = {}
	if not q.isEmpty(self._tempPlayerOrder) then
		for userId, order in pairs(self._tempPlayerOrder) do
			table.insert(tbl, {userId = userId, order = order})
		end
	else
		local myTeamPlayerList = {}
		table.insert(myTeamPlayerList, remote.silvesArena.myTeamInfo.leader)
		table.insert(myTeamPlayerList, remote.silvesArena.myTeamInfo.member1)
		table.insert(myTeamPlayerList, remote.silvesArena.myTeamInfo.member2)

		for _, userPlayer in ipairs(myTeamPlayerList) do
			table.insert(tbl, {userId = userPlayer.userId, order = userPlayer.silvesArenaFightPos})
		end
	end

	local enemyTeamId = remote.silvesArena.againstTeamInfo.teamId
	if enemyTeamId then
		local myInfo = remote.silvesArena.userInfo

		if myInfo and myInfo.todayFightCount then
			local fightCnt = db:getConfigurationValue("silves_arena_day_fight_count")
			local count = tonumber(fightCnt) - tonumber(myInfo.todayFightCount)
			if count <= 0 then 
				app.tip:floatTip("今日战斗已达上限")
				return
			end
		end

		if myInfo and myInfo.todayFightAt then
			local cd = db:getConfigurationValue("silves_arena_user_fight_cd")
			if q.serverTime() * 1000 < tonumber(myInfo.todayFightAt) + tonumber(cd) * MIN * 1000 then
				app.tip:floatTip("挑战冷却中")
				return
			end
		end

		remote.silvesArena:silvesArenaGenerateFightInfoRequest(enemyTeamId, tbl, self._isSkipBattle, function()
			remote.user:addPropNumForKey("todaySilvesArenaChallengeFightCount")--记录今日挑战战斗次数
			remote.silvesArena:silvesAutoFightCommandSet()
			if self._ccbView and self._avatarDic and self._avatarDic.userAvatar and self._avatarDic.enemyAvatar then
				for _, cell in pairs(self._avatarDic.userAvatar) do
					if cell and cell.showEnemy then
						cell:showEnemy()
					end
				end
				for _, cell in pairs(self._avatarDic.enemyAvatar) do
					if cell and cell.showEnemy then
						cell:showEnemy()
					end
				end
			end
		end)
	else
		app.tip:floatTip("无效的对手，请返回")
		return
	end
end

function QUIWidgetSilvesArenaAgainstClient:_showFightEffect(event)
	local addActionFunc = function ( node, avatar, cell, x, y, time )
		-- if cell and cell.showEnemy then
		-- 	cell:showEnemy()
		-- end
		if cell and cell.setPlaying then
			cell:setPlaying( true )
		end
		local actions = CCArray:create()
		actions:addObject(CCMoveTo:create(time, ccp(x, y)))
	    actions:addObject(CCCallFunc:create(function() 
	    	avatar:displayWithBehavior(ANIMATION_EFFECT.COMMON_FIGHT)
    	end))

    	avatar:displayWithBehavior(ANIMATION_EFFECT.WALK)
    	node:runAction(CCSequence:create(actions))
	end
	
	if self._ccbView then
		if event and event.index then
			local index = tonumber(event.index)
			if self._avatarDic and self._avatarDic.userAvatar and self._avatarDic.enemyAvatar then
				for i = 1, index, 1 do 
					local userCell = self._avatarDic.userAvatar[i]
					if userCell then
						local node = self._ccbOwner["node_user_"..i]
						if node then
							local avatar = userCell:getAvatar()
							if avatar then
								if i < index then
									if userCell.isPlaying and not userCell:isPlaying() then
										if userCell.setPlaying then
											userCell:setPlaying( true )
										end
										node:setPositionX(-100)
										avatar:displayWithBehavior(ANIMATION_EFFECT.COMMON_FIGHT)
									end
								else
									addActionFunc(node, avatar, userCell, -100, node:getPositionY(), 1)
								end
							end
						end
					end

					local enemyCell = self._avatarDic.enemyAvatar[i]
					if enemyCell then
						local node = self._ccbOwner["node_enemy_"..i]
						if node then
							local avatar = enemyCell:getAvatar()
							if avatar then
								if i < index then
									if enemyCell.isPlaying and not enemyCell:isPlaying() then
										if enemyCell.setPlaying then
											enemyCell:setPlaying( true )
										end
										node:setPositionX(100)
										avatar:displayWithBehavior(ANIMATION_EFFECT.COMMON_FIGHT)
									end
								else
									addActionFunc(node, avatar, enemyCell, 100, node:getPositionY(), 1)
								end
							end
						end
					end
				end
			end
		end
	end
end

function QUIWidgetSilvesArenaAgainstClient:_showFightEnd(event)
	if self._ccbView then
		if event and event.index and event.isWin ~= nil then
			local index = tonumber(event.index)
			local isWin = event.isWin
			if self._avatarDic and self._avatarDic.userAvatar and self._avatarDic.enemyAvatar then
				local userCell = self._avatarDic.userAvatar[index]
				if userCell then
					local avatar = userCell:getAvatar()
					if avatar then
						if event.isWin then
							avatar:displayWithBehavior(ANIMATION_EFFECT.VICTORY)
						else
							avatar:displayWithBehavior(ANIMATION_EFFECT.DEAD)
							avatar:setAutoStand(false)
							if userCell.hideInfo then
								userCell:hideInfo()
							end
						end
					end
				end

				local enemyCell = self._avatarDic.enemyAvatar[index]
				if enemyCell then
					local avatar = enemyCell:getAvatar()
					if avatar then
						if event.isWin then
							avatar:displayWithBehavior(ANIMATION_EFFECT.DEAD)
							avatar:setAutoStand(false)
							if enemyCell.hideInfo then
								enemyCell:hideInfo()
							end
						else
							avatar:displayWithBehavior(ANIMATION_EFFECT.VICTORY)
						end
					end
				end
			end
		end
	end
end

function QUIWidgetSilvesArenaAgainstClient:_initTouchLayer()
	if not self._ccbOwner.node_touch then return end
	self._ccbOwner.node_touch:removeAllChildren()

	local touchSize = self._ccbOwner.node_touch:getContentSize()
	self._touchLayer = CCLayerColor:create(ccc4(0, 0, 0, 0), touchSize.width, touchSize.height)
    self._touchLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._onTouchLayer))
    self._touchLayer:setTouchEnabled(true)
    self._touchLayer:setPosition(0,0)
    self._ccbOwner.node_touch:addChild(self._touchLayer)
end

function QUIWidgetSilvesArenaAgainstClient:_onTouchLayer(event)
	if q.isEmpty(self._avatarDic.userAvatar) then return end
	-- print(event.name, event.x, event.y)
	if event.name == "began" then
		self._touchStartInfo = {}
		self._touchEndedInfo = {}
		local touchStartAvatar = nil
		local silvesArenaFightPos = 0
		local userId = nil
		for index, avatar in ipairs(self._avatarDic.userAvatar) do
			local pos = avatar:getParent():convertToNodeSpace(ccp(event.x, event.y))
			-- print("index = ", index, "  pos = ", pos.x, pos.y)
			if avatar:isTouchIn(pos) then
				touchStartAvatar = avatar
				silvesArenaFightPos = index
				userId = avatar:getInfo().userId
			end
		end
		if touchStartAvatar and silvesArenaFightPos ~= 0 and userId then
			print("[began in]", silvesArenaFightPos)
			self._touchStartInfo = {userId = userId, avatar = touchStartAvatar, x = event.x, y = event.y, silvesArenaFightPos = silvesArenaFightPos}
			self._touchStartInfo.avatar:setOffsetScale({x = -0.2, y = -0.2})
			return true
		end
		-- print("[began out]")
		return false
    elseif event.name == "moved" then
        if q.isEmpty(self._touchStartInfo) then return end
        local relativeX = event.x - self._touchStartInfo.x
        local relativeY = event.y - self._touchStartInfo.y
        self._touchStartInfo.avatar:setOffsetPos(ccp(relativeX, relativeY))
        for index, avatar in ipairs(self._avatarDic.userAvatar) do
    		if index ~= self._touchStartInfo.silvesArenaFightPos then
				local pos = avatar:getParent():convertToNodeSpace(ccp(event.x, event.y))
				if avatar:isTouchIn(pos) then
					print("[move in]", index)
					avatar:setOffsetScale({x = -0.2, y = -0.2})
				else
					-- print("[move out]", index)
					avatar:setOffsetScale({x = 0, y = 0})
				end
			end
		end
    elseif event.name == "ended" then
    	print("ended")
    	self._touchEndedInfo = {}
    	local touchEndedAvatar = nil
		local silvesArenaFightPos = 0
		local userId = nil
    	if q.isEmpty(self._touchStartInfo) then return end
    	for index, avatar in ipairs(self._avatarDic.userAvatar) do
    		if index ~= self._touchStartInfo.silvesArenaFightPos then
				local pos = avatar:getParent():convertToNodeSpace(ccp(event.x, event.y))
				if avatar:isTouchIn(pos) then
					touchEndedAvatar = avatar
					silvesArenaFightPos = index
					userId = avatar:getInfo().userId
				end
			end
		end
		if touchEndedAvatar and silvesArenaFightPos ~= 0 and userId then
			print("[end in]", silvesArenaFightPos)
			self._touchEndedInfo = {userId = userId, avatar = touchEndedAvatar, x = event.x, y = event.y, silvesArenaFightPos = silvesArenaFightPos}
		end
		self:_changeMyTeamFightPos()
    elseif event.name == "cancelled" then
    	print("cancelled")
        self:_onTouchEndHandler()
	end
end

function QUIWidgetSilvesArenaAgainstClient:_changeMyTeamFightPos()
	if q.isEmpty(self._touchStartInfo) or q.isEmpty(self._touchEndedInfo) then 
		self:_onTouchEndHandler()
		return 
	end
	if self._tempPlayerOrder[self._touchStartInfo.userId] and self._tempPlayerOrder[self._touchEndedInfo.userId] then
		self._tempPlayerOrder[self._touchStartInfo.userId] = self._touchEndedInfo.silvesArenaFightPos
		self._tempPlayerOrder[self._touchEndedInfo.userId] = self._touchStartInfo.silvesArenaFightPos
		self:_updateUserTeamInfo()
	end
	self:_onTouchEndHandler()
end

function QUIWidgetSilvesArenaAgainstClient:_onTouchEndHandler()
	if not q.isEmpty(self._touchStartInfo) then
		if self._touchStartInfo.avatar then
			if self._touchStartInfo.avatar.setOffsetScale then
				self._touchStartInfo.avatar:setOffsetScale({x = 0, y = 0})
			end
			if self._touchStartInfo.avatar.setOffsetPos then
				self._touchStartInfo.avatar:setOffsetPos(ccp(0, 0))
			end
		end
		self._touchStartInfo = {}
	end
	if not q.isEmpty(self._touchEndedInfo) then
		if self._touchEndedInfo.avatar then
			if self._touchEndedInfo.avatar.setOffsetScale then
				self._touchEndedInfo.avatar:setOffsetScale({x = 0, y = 0})
			end
			if self._touchEndedInfo.avatar.setOffsetPos then
				self._touchEndedInfo.avatar:setOffsetPos(ccp(0, 0))
			end
		end
		self._touchEndedInfo = {}
	end
end

return QUIWidgetSilvesArenaAgainstClient