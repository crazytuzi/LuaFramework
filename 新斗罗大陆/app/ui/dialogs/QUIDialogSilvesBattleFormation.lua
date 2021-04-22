--
-- Kumo.Wang
-- 西尔维斯大斗魂场阵容界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSilvesBattleFormation = class("QUIDialogSilvesBattleFormation", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QSilvesDefenseArrangement = import("...arrangement.QSilvesDefenseArrangement")
local QUIWidgetSilvesArenaBattleFormation = import("..widgets.QUIWidgetSilvesArenaBattleFormation")

function QUIDialogSilvesBattleFormation:ctor(options)
	local ccbFile = "ccb/Dialog_SilvesArena_BattleFormation.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
    }
    QUIDialogSilvesBattleFormation.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    q.setButtonEnableShadow(self._ccbOwner.btn_ok)

    self._ccbOwner.frame_tf_title:setString("")

    if options then
    	self._module = options.module
    	self._teamId = options.teamId
    end

    self:_init()
end

function QUIDialogSilvesBattleFormation:viewDidAppear()
	QUIDialogSilvesBattleFormation.super.viewDidAppear(self)
end

function QUIDialogSilvesBattleFormation:viewAnimationInHandler()
	QUIDialogSilvesBattleFormation.super.viewAnimationInHandler(self)

	self:_update()
end

function QUIDialogSilvesBattleFormation:viewWillDisappear()
  	QUIDialogSilvesBattleFormation.super.viewWillDisappear(self)
end

function QUIDialogSilvesBattleFormation:_init()
	self._isChanged = false

	if self._module == remote.silvesArena.BATTLEFORMATION_MODULE_CAPTAINPOWER then
    	self._ccbOwner.frame_tf_title:setString("阵容设置")
		self._ccbOwner.node_btn_ok:setVisible(false)
		self._ccbOwner.tf_btn_ok:setString("保存阵容")
		self._ccbOwner.tf_team_name_title:setVisible(true)
		self._ccbOwner.tf_team_name:setVisible(true)
		self._ccbOwner.tf_team_force_title:setVisible(true)
		self._ccbOwner.tf_team_force:setVisible(true)
		self._ccbOwner.tf_tips:setVisible(false)
		-- self._ccbOwner.s9s_bg:setPreferredSize(CCSize(690, 404))
		-- self._ccbOwner.sheet_layout:setContentSize(CCSize(690, 404))
		self._ccbOwner.s9s_bg:setPreferredSize(CCSize(690, 474))
		self._ccbOwner.sheet_layout:setContentSize(CCSize(690, 474))
	elseif self._module == remote.silvesArena.BATTLEFORMATION_MODULE_PVP then
    	self._ccbOwner.frame_tf_title:setString("布  阵")
		self._ccbOwner.node_btn_ok:setVisible(false)
		self._ccbOwner.tf_btn_ok:setString("挑 战")
		self._ccbOwner.tf_team_name_title:setVisible(false)
		self._ccbOwner.tf_team_name:setVisible(false)
		self._ccbOwner.tf_team_force_title:setVisible(false)
		self._ccbOwner.tf_team_force:setVisible(false)
		self._ccbOwner.tf_tips:setVisible(true)
		-- self._ccbOwner.s9s_bg:setPreferredSize(CCSize(690, 404))
		-- self._ccbOwner.sheet_layout:setContentSize(CCSize(690, 404))
		self._ccbOwner.s9s_bg:setPreferredSize(CCSize(690, 474))
		self._ccbOwner.sheet_layout:setContentSize(CCSize(690, 474))
	elseif self._module == remote.silvesArena.BATTLEFORMATION_MODULE_NORMAL 
		or self._module == remote.silvesArena.BATTLEFORMATION_MODULE_PVP_NORMAL 
		or self._module == remote.silvesArena.BATTLEFORMATION_MODULE_RANK_NORMAL
		or self._module == remote.silvesArena.BATTLEFORMATION_MODULE_RANK_PVP then
    	self._ccbOwner.frame_tf_title:setString("阵容查看")
    	self._ccbOwner.node_btn_ok:setVisible(false)
		self._ccbOwner.tf_team_name_title:setVisible(true)
		self._ccbOwner.tf_team_name:setVisible(true)
		self._ccbOwner.tf_team_force_title:setVisible(true)
		self._ccbOwner.tf_team_force:setVisible(true)
		self._ccbOwner.tf_tips:setVisible(false)
		self._ccbOwner.s9s_bg:setPreferredSize(CCSize(690, 474))
		self._ccbOwner.sheet_layout:setContentSize(CCSize(690, 474))
	end

	if self._module ~= remote.silvesArena.BATTLEFORMATION_MODULE_PVP then
		local info = {}
		if self._module == remote.silvesArena.BATTLEFORMATION_MODULE_CAPTAINPOWER or self._module == remote.silvesArena.BATTLEFORMATION_MODULE_NORMAL then
			info = remote.silvesArena.myTeamInfo
		elseif self._module == remote.silvesArena.BATTLEFORMATION_MODULE_PVP_NORMAL 
			or self._module == remote.silvesArena.BATTLEFORMATION_MODULE_RANK_NORMAL 
			or self._module == remote.silvesArena.BATTLEFORMATION_MODULE_RANK_PVP then
			if not q.isEmpty(remote.silvesArena.teamInfo) and self._teamId then
				for _, team in ipairs(remote.silvesArena.teamInfo) do
					if team.teamId == self._teamId then
						info = team
					end
				end
			end

			if q.isEmpty(info) then
				if not q.isEmpty(remote.silvesArena.myTeamInfo) and self._teamId then
					if remote.silvesArena.myTeamInfo.teamId == self._teamId then
						info = remote.silvesArena.myTeamInfo
					end
				end
			end
		end
		if not q.isEmpty(info) then
			self._ccbOwner.tf_team_name:setVisible(false)
			if info.teamName then
				self._ccbOwner.tf_team_name:setString(info.teamName)
				self._ccbOwner.tf_team_name:setVisible(true)
			end

			local isMe = remote.silvesArena.myTeamInfo and info.teamId == remote.silvesArena.myTeamInfo.teamId
			local _totalForce, _totalNumber = remote.silvesArena:getTotalForceAndTotalNumberByTeamInfo(info, isMe)
			print("_totalForce, _totalNumber = ", _totalForce, _totalNumber, isMe)
			local averageForce = 0
			if _totalForce and _totalNumber then
				averageForce = _totalForce / _totalNumber
			else
				averageForce = 0
			end
			local num, unit = q.convertLargerNumber(averageForce)
			self._ccbOwner.tf_team_force:setString(num..(unit or ""))
			local fontInfo = db:getForceColorByForce(averageForce, true)
		    if fontInfo ~= nil then
		        local color = string.split(fontInfo.force_color, ";")
		        self._ccbOwner.tf_team_force:setColor(ccc3(color[1], color[2], color[3]))
		    end
			
			self._ccbOwner.tf_team_force:setVisible(true)
		end
	end
end

function QUIDialogSilvesBattleFormation:_update(isForce)
	local info = {}
	if self._module == remote.silvesArena.BATTLEFORMATION_MODULE_PVP_NORMAL
		or self._module == remote.silvesArena.BATTLEFORMATION_MODULE_RANK_NORMAL 
		or self._module == remote.silvesArena.BATTLEFORMATION_MODULE_RANK_PVP then
		if not q.isEmpty(remote.silvesArena.teamInfo) and self._teamId then
			for _, team in ipairs(remote.silvesArena.teamInfo) do
				if team.teamId == self._teamId then
					info = team
				end
			end
		end

		if q.isEmpty(info) then
			if not q.isEmpty(remote.silvesArena.myTeamInfo) and self._teamId then
				if remote.silvesArena.myTeamInfo.teamId == self._teamId then
					info = remote.silvesArena.myTeamInfo
				end
			end
		end
	else
		info = remote.silvesArena.myTeamInfo
	end

	if q.isEmpty(info) then
		self:_onTriggerClose()
	else
		if isForce or q.isEmpty(self._teamPlayerList) then
			local tbl = {}
			local leaderTbl = clone(info.leader)
			leaderTbl.isCaptain = true
			table.insert(tbl, leaderTbl)
			if not q.isEmpty(info.member1) then
				table.insert(tbl, clone(info.member1))
			end
			if not q.isEmpty(info.member2) then
				table.insert(tbl, clone(info.member2))
			end
			if #tbl > 1 then
				table.sort(tbl, function(a, b)
					return a.silvesArenaFightPos < b.silvesArenaFightPos
				end)
			end

			self._teamPlayerList = {}
			local hideIndeList = remote.silvesArena:getHideMemberIndexList()

			for index, info in ipairs(tbl) do
				info.module = self._module
				if self._teamId and self._module == remote.silvesArena.BATTLEFORMATION_MODULE_PVP then
					info.enemyTeamId = self._teamId
				end
				
				local isHide = false
				for _, i in ipairs(hideIndeList) do
					if i == index then
						isHide = true
						break
					end
				end
				if isHide then
					if self._module ~= remote.silvesArena.BATTLEFORMATION_MODULE_PVP_NORMAL and self._module ~= remote.silvesArena.BATTLEFORMATION_MODULE_RANK_PVP then
						table.insert(self._teamPlayerList, info)
					else
						table.insert(self._teamPlayerList, {module = remote.silvesArena.BATTLEFORMATION_MODULE_SKETCH, silvesArenaFightPos = index})
					end
				else
					table.insert(self._teamPlayerList, info)
				end
			end

			if self._module ~= remote.silvesArena.BATTLEFORMATION_MODULE_PVP 
				and self._module ~= remote.silvesArena.BATTLEFORMATION_MODULE_RANK_NORMAL
				and self._module ~= remote.silvesArena.BATTLEFORMATION_MODULE_RANK_PVP then
				table.insert(self._teamPlayerList, {module = remote.silvesArena.BATTLEFORMATION_MODULE_TIPS, silvesArenaFightPos = 0.5})
			end
		end

		table.sort(self._teamPlayerList, function(a, b)
			return a.silvesArenaFightPos < b.silvesArenaFightPos
		end)

		if self._listViewLayout then 
            self._listViewLayout:clear(true)
            self._listViewLayout = nil
        end

		self:_updateListView()
	end
end

function QUIDialogSilvesBattleFormation:_updateListView()
    if not self._listViewLayout then
        local cfg = {
            renderItemCallBack = handler(self, self._renderItemHandler),
            isVertical = true,
            ignoreCanDrag = true,
            spaceY = 0,
            enableShadow = true,
            totalNumber = #self._teamPlayerList,
        }
        self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listViewLayout:reload({#self._teamPlayerList})
    end
end

function QUIDialogSilvesBattleFormation:_renderItemHandler(list, index, info )
    local isCacheNode = true
    local itemData = self._teamPlayerList[index]

    local item = list:getItemFromCache()
    if not item then
        item = QUIWidgetSilvesArenaBattleFormation.new()
        isCacheNode = false
    end

    item:setInfo(itemData)
    info.item = item
    info.size = item:getContentSize()

    -- list:registerTouchHandler(index, "onTouchListView")
    list:registerBtnHandler(index, "btn_player_detail", handler(self, self._onTriggerPlayerDetail), nil, true)
    list:registerBtnHandler(index, "btn_enemy_detail", handler(self, self._onTriggerEnemyDetail), nil, true)
    list:registerBtnHandler(index, "btn_click", handler(self, self._onTriggerClick), nil, true)
    list:registerBtnHandler(index, "btn_my_team", handler(self, self._onTriggerSetMyDefenseTeam), nil, true)

    return isCacheNode
end


function QUIDialogSilvesBattleFormation:_onTriggerSetMyDefenseTeam( x, y, touchNode, listView )
	app.sound:playSound("common_small")
	if not q.isEmpty(remote.silvesArena.fightInfo) then
		app.tip:floatTip("战斗中")
		return
	end

    local state = remote.silvesArena:getCurState()
   	local silvesDefenseArrangement = QSilvesDefenseArrangement.new({teamKey = remote.teamManager.SILVES_ARENA_TEAM})
    if state == remote.silvesArena.STATE_PEAK then
        local peakState = remote.silvesArena:getCurPeakState()
        if peakState == remote.silvesArena.PEAK_READY_TO_16
            or peakState == remote.silvesArena.PEAK_READY_TO_4
            or peakState == remote.silvesArena.PEAK_READY_TO_FINAL then

            self:popSelf()
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTeamArrangement",
				options = {arrangement = silvesDefenseArrangement}})
		else
			app.tip:floatTip("当前时段不能修改阵容")
        end
    else
    	self:popSelf()
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTeamArrangement",
			options = {arrangement = silvesDefenseArrangement}})
    end
end


function QUIDialogSilvesBattleFormation:_onTriggerPlayerDetail( x, y, touchNode, listView )
    app.sound:playSound("common_small")
    local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)
    if item and item.getInfo then
        local info = item:getInfo()
        if not q.isEmpty(info) then
			remote.silvesArena:silvesArenaQueryUserDataRequest(info.userId, function(data)
				if self:safeCheck() then
					if data and data.silvesArenaInfoResponse and data.silvesArenaInfoResponse.fighter and not q.isEmpty(data.silvesArenaInfoResponse.fighter) then
						app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo", 
							options = {fighter = data.silvesArenaInfoResponse.fighter, forceTitle = "战力：", specialTitle1 = "服务器名：", specialValue1 = data.silvesArenaInfoResponse.fighter.game_area_name, isPVP = true}}, {isPopCurrentDialog = false})
					end
				end
			end)
		end
    end
end

function QUIDialogSilvesBattleFormation:_onTriggerEnemyDetail( x, y, touchNode, listView )
    app.sound:playSound("common_small")
    local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)
    if item and item.getInfo then
        local info = item:getInfo()
    	if self._teamId and not q.isEmpty(remote.silvesArena.teamInfo) and not q.isEmpty(info) then
	        local enemyInfo = {}
	        for _, team in ipairs(remote.silvesArena.teamInfo) do
	            if team.teamId == self._teamId then
	                if team.leader and team.leader.silvesArenaFightPos == info.silvesArenaFightPos then
	                    enemyInfo = team.leader
	                    break
	                elseif team.member1 and team.member1.silvesArenaFightPos == info.silvesArenaFightPos then
	                    enemyInfo = team.member1
	                    break
	                elseif team.member2 and team.member2.silvesArenaFightPos == info.silvesArenaFightPos then
	                    enemyInfo = team.member2
	                    break
	                end
	            end
	        end
	        if not q.isEmpty(enemyInfo) then
	        	local enemyUserId = enemyInfo.userId
				remote.silvesArena:silvesArenaQueryUserDataRequest(enemyUserId, function(data)
					if self:safeCheck() then
						if data and data.silvesArenaInfoResponse and data.silvesArenaInfoResponse.fighter and not q.isEmpty(data.silvesArenaInfoResponse.fighter) then
							app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo", 
								options = {fighter = data.silvesArenaInfoResponse.fighter, forceTitle = "战力：", specialTitle1 = "服务器名：", specialValue1 = data.silvesArenaInfoResponse.fighter.game_area_name, isPVP = true}}, {isPopCurrentDialog = false})
						end
					end
				end)
			end
		end
    end
end

function QUIDialogSilvesBattleFormation:_onTriggerClick( x, y, touchNode, listView )
    app.sound:playSound("common_small")
    
    local state = remote.silvesArena:getCurState()
    if state == remote.silvesArena.STATE_PEAK then
        local peakState = remote.silvesArena:getCurPeakState()
        if peakState == remote.silvesArena.PEAK_WAIT_TO_16
            or peakState == remote.silvesArena.PEAK_WAIT_TO_4
            or peakState == remote.silvesArena.PEAK_WAIT_TO_FINAL 
            or peakState == remote.silvesArena.PEAK_16_IN_8 
            or peakState == remote.silvesArena.PEAK_8_IN_4 
            or peakState == remote.silvesArena.PEAK_4_IN_2 
            or peakState == remote.silvesArena.PEAK_FINAL_FIGHT then
            app.tip:floatTip("当前阵容已经锁定，无法进行小队顺序的互换")
			return
        end
    end

    local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)
    if item and item.getInfo then
        local info = item:getInfo()
        if info.clickPos then
        	self._isChanged = true
        	
        	local _clickPos = info.clickPos
        	local _silvesArenaFightPos = info.silvesArenaFightPos
        	for _, player in ipairs(self._teamPlayerList) do
        		player.clickPos = nil
        		if player.userId == info.userId then
        			player.silvesArenaFightPos = _clickPos
        		elseif player.userId == info.clickPosUserId then
        			player.silvesArenaFightPos = _silvesArenaFightPos
        		end
        	end
        	self:_update()
        else
        	local index = 1
        	while true do
        		local _item = listView:getItemByIndex(index)
        		if _item then
        			if _item.getInfo then
        				local _info = _item:getInfo()
        				_info.clickPos = info.silvesArenaFightPos
        				_info.clickPosUserId = info.userId
        				if _item.update then
        					_item:update(_info)
        				end
        			end
        			index = index + 1
        		else
        			break
        		end
        	end
        end
    end
end

function QUIDialogSilvesBattleFormation:_onTriggerOK(event)
	if event then
		app.sound:playSound("common_small")
	end	
	
	local tbl = {}
	for _, player in ipairs(self._teamPlayerList) do
		if player.silvesArenaFightPos ~= 2.5 and player.silvesArenaFightPos ~= 0.5 then
			table.insert(tbl, {userId = player.userId, order = player.silvesArenaFightPos})
		end
	end
	if self._module == remote.silvesArena.BATTLEFORMATION_MODULE_PVP then
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

		--[[to be continue]]
		local skipWatch = false
		remote.silvesArena:silvesArenaGenerateFightInfoRequest(self._teamId, tbl, skipWatch, function()
			remote.user:addPropNumForKey("todaySilvesArenaChallengeFightCount")--记录今日挑战战斗次数
			if self:safeCheck() then
				self._callback = handler(remote.silvesArena, remote.silvesArena.silvesAutoFightCommandSet)
				self:_onTriggerClose()
			else
				remote.silvesArena:silvesAutoFightCommandSet()
			end
		end)
	else
		if self._isChanged then
			self._isChanged = false
			remote.silvesArena:silvesArenaChangeBattleUserPosRequest(tbl, function()
				if self:safeCheck() then
					self:_onTriggerClose()
				end
			end)
		else
			self:_onTriggerClose()
		end
	end
end

function QUIDialogSilvesBattleFormation:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSilvesBattleFormation:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSilvesBattleFormation:viewAnimationOutHandler()
	local callback = self._callback

	if self._isChanged then
		self._isChanged = false
		local tbl = {}
		for _, player in ipairs(self._teamPlayerList) do
			if player.silvesArenaFightPos ~= 2.5 and player.silvesArenaFightPos ~= 0.5 then
				table.insert(tbl, {userId = player.userId, order = player.silvesArenaFightPos})
			end
		end
		remote.silvesArena:silvesArenaChangeBattleUserPosRequest(tbl)
	end

	self:popSelf()
	
	if callback then
		callback()
	end
end

return QUIDialogSilvesBattleFormation
