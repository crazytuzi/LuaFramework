--
-- Kumo.Wang
-- 西尔维斯大斗魂场出战布阵界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSilvesBattleFormationAgainst = class("QUIDialogSilvesBattleFormationAgainst", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")

local QUIWidgetSilvesBattleFormationAgainst = import("..widgets.QUIWidgetSilvesBattleFormationAgainst")

function QUIDialogSilvesBattleFormationAgainst:ctor(options)
	local ccbFile = "ccb/Dialog_SilvesArena_Battle_Against.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogSilvesBattleFormationAgainst.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._ccbOwner.frame_tf_title:setString("对战阵容")

    if options then
    	self._enemyTeamId = options.enemyTeamId
        self._tempPlayerOrder = options.tempPlayerOrder
    	self._callback = options.callback
    end

    self:_init()
end

function QUIDialogSilvesBattleFormationAgainst:viewDidAppear()
	QUIDialogSilvesBattleFormationAgainst.super.viewDidAppear(self)
end

function QUIDialogSilvesBattleFormationAgainst:viewAnimationInHandler()
	QUIDialogSilvesBattleFormationAgainst.super.viewAnimationInHandler(self)

	self:_update()
end

function QUIDialogSilvesBattleFormationAgainst:viewWillDisappear()
  	QUIDialogSilvesBattleFormationAgainst.super.viewWillDisappear(self)
end

function QUIDialogSilvesBattleFormationAgainst:_init()
	self._isChanged = false
end

function QUIDialogSilvesBattleFormationAgainst:_update(isForce)
	local enemyInfo = {}
	if not q.isEmpty(remote.silvesArena.teamInfo) and self._enemyTeamId then
		for _, team in ipairs(remote.silvesArena.teamInfo) do
			if team.teamId == self._enemyTeamId then
				enemyInfo = team
			end
		end
	end
	local playerInfo = remote.silvesArena.myTeamInfo

	if q.isEmpty(playerInfo) or q.isEmpty(enemyInfo) then
		self:_onTriggerClose()
	else
		if isForce or q.isEmpty(self._playerHeadList) then
			local tbl = {}
			local leaderTbl = clone(playerInfo.leader)
			leaderTbl.isCaptain = true
			table.insert(tbl, leaderTbl)
			table.insert(tbl, clone(playerInfo.member1))
			table.insert(tbl, clone(playerInfo.member2))

			self._playerHeadList = tbl
            if not q.isEmpty(self._tempPlayerOrder) then
                for userId, pos in pairs(self._tempPlayerOrder) do
                    for _, player in ipairs(self._playerHeadList) do
                        if player.userId == userId then
                            player.silvesArenaFightPos = pos
                        end
                    end
                end
            end
		end

		if isForce or q.isEmpty(self._enemyHeadList) then
			local tbl = {}
			local leaderTbl = clone(enemyInfo.leader)
			leaderTbl.isCaptain = true
			table.insert(tbl, leaderTbl)
			table.insert(tbl, clone(enemyInfo.member1))
			table.insert(tbl, clone(enemyInfo.member2))

			self._enemyHeadList = tbl
		end

		table.sort(self._playerHeadList, function(a, b)
            return a.silvesArenaFightPos < b.silvesArenaFightPos
		end)

		table.sort(self._enemyHeadList, function(a, b)
			return a.silvesArenaFightPos < b.silvesArenaFightPos
		end)

		if self._listViewLayout then 
            self._listViewLayout:clear(true)
            self._listViewLayout = nil
        end

		self:_updateListView()
	end
end

function QUIDialogSilvesBattleFormationAgainst:_updateListView()
    if not self._listViewLayout then
        local cfg = {
            renderItemCallBack = handler(self, self._renderItemHandler),
            isVertical = true,
            ignoreCanDrag = true,
            spaceY = 0,
            enableShadow = true,
            totalNumber = #self._playerHeadList,
        }
        self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listViewLayout:reload({#self._playerHeadList})
    end
end

function QUIDialogSilvesBattleFormationAgainst:_renderItemHandler(list, index, info )
    local isCacheNode = true
    local playerData = self._playerHeadList[index]
    local enemyData = self._enemyHeadList[index]

    local item = list:getItemFromCache()
    if not item then
        item = QUIWidgetSilvesBattleFormationAgainst.new()
        isCacheNode = false
    end

    item:setInfo(playerData, enemyData)
    info.item = item
    info.size = item:getContentSize()

    list:registerTouchHandler(index, "onTouchListView")
    list:registerBtnHandler(index, "btn_player_detail", handler(self, self._onTriggerPlayerDetail), nil, true)
    list:registerBtnHandler(index, "btn_enemy_detail", handler(self, self._onTriggerEnemyDetail), nil, true)
    list:registerBtnHandler(index, "btn_click", handler(self, self._onTriggerClick), nil, true)

    return isCacheNode
end

function QUIDialogSilvesBattleFormationAgainst:_onTriggerPlayerDetail( x, y, touchNode, listView )
    app.sound:playSound("common_small")
    local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)
    if item and item.getPlayerInfo then
        local info = item:getPlayerInfo()
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

function QUIDialogSilvesBattleFormationAgainst:_onTriggerEnemyDetail( x, y, touchNode, listView )
    app.sound:playSound("common_small")
    local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)
    if item and item.getEnemyInfo then
        local info = item:getEnemyInfo()
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

function QUIDialogSilvesBattleFormationAgainst:_onTriggerClick( x, y, touchNode, listView )
    app.sound:playSound("common_small")
    local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)
    if item and item.getPlayerInfo then
        local info = item:getPlayerInfo()
        if info.clickPos then
        	self._isChanged = true
        	
        	local _clickPos = info.clickPos
        	local _silvesArenaFightPos = info.silvesArenaFightPos
        	for _, player in ipairs(self._playerHeadList) do
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
        			if _item.getPlayerInfo then
        				local _info = _item:getPlayerInfo()
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

function QUIDialogSilvesBattleFormationAgainst:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSilvesBattleFormationAgainst:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSilvesBattleFormationAgainst:viewAnimationOutHandler()
	local callback = self._callback
	local tbl = {}
	for _, info in ipairs(self._playerHeadList) do
		tbl[info.userId] = info.silvesArenaFightPos
	end

	self:popSelf()
	
	if callback then
		callback(tbl)
	end
end

return QUIDialogSilvesBattleFormationAgainst
