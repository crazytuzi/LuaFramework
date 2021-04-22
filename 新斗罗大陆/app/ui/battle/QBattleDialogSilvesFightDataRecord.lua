--
-- Kumo.Wang
-- 西尔维斯大斗魂场战斗总结算数据统计界面
--

local QBattleDialog = import(".QBattleDialog")
local QBattleDialogSilvesFightDataRecord = class(".QBattleDialogSilvesFightDataRecord", QBattleDialog)

local QUIWidgetSilvesFightEndDetail = import("..widgets.QUIWidgetSilvesFightEndDetail")
local QUIWidgetSilvesFightDataClient = import("..widgets.QUIWidgetSilvesFightDataClient")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QListView = import("...views.QListView")
local QBattleDialogSkillData = import(".QBattleDialogSkillData")

QBattleDialogSilvesFightDataRecord.TAB_DETAIL = "TAB_DETAIL"
QBattleDialogSilvesFightDataRecord.TAB_DATA = "TAB_DATA"

function QBattleDialogSilvesFightDataRecord:ctor(options)
	local ccbFile = "ccb/Dialog_SilvesArena_FightData.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerDetail", callback = handler(self, self._onTriggerDetail)},
		{ccbCallbackName = "onTriggerData", callback = handler(self, self._onTriggerData)},
	}
	QBattleDialogSilvesFightDataRecord.super.ctor(self, ccbFile, {}, callBacks)
	options = options or {}

	if options then
		self._isSkipBattle = options.isSkipBattle
		self._statsDataList = options.statsDataList
 	end

	self._ccbOwner.sp_vs:setVisible(false)
	self._selectTab = QBattleDialogSilvesFightDataRecord.TAB_DETAIL
    self._detailInfo = {}
	self._dataRecord = {}

    ui.tabButton(self._ccbOwner.btn_detail, "战斗\n详情",18)
    ui.tabButton(self._ccbOwner.btn_data, "数据\n查看",18)
	self._tabManager = ui.tabManager({self._ccbOwner.btn_detail, self._ccbOwner.btn_data})
	self._ccbOwner.frame_tf_title:setString("战斗详情")
	self:initDetailData()
	self:selectTabs()
end

function QBattleDialogSilvesFightDataRecord:initDetailData()
	if q.isEmpty(remote.silvesArena.fightInfo) then
		self:_onTriggerClose()
		return
	end
 	local index = 1

	local scoreList = remote.silvesArena.fightInfo.scoreList
	local logInfoList = {}

	if self._isSkipBattle then
		logInfoList = self._statsDataList or {}
	else
		local dungeonConfig = app.battle:getDungeonConfig()
		logInfoList = dungeonConfig and dungeonConfig.statsDataList or {}
	end

	if not q.isEmpty(logInfoList) then
		for _, value in ipairs(logInfoList) do
			local content = crypto.decodeBase64(value.statsData)
            local battleStats = app:getProtocol():decodeBufferToMessage("cc.qidea.wow.client.battle.ReplayOutput", content)
            table.insert(self._dataRecord, {reportId = value.reportId, log = battleStats.battleLog})
		end

		table.sort(self._dataRecord, function(a, b)
			return a.reportId < b.reportId
		end)
	end
	
	local attackScore = 0
	local defenseScore = 0
	for _, score in ipairs(scoreList or {}) do
		if score == 1 then
			attackScore = attackScore + 1
		else
			defenseScore = defenseScore + 1
		end
	end
    self._ccbOwner.sp_score1:setString(attackScore)
    self._ccbOwner.sp_score2:setString(defenseScore)

	self._ccbOwner.tf_name1:setString(remote.silvesArena.fightInfo.team1Name or "")
    self._ccbOwner.tf_name2:setString(remote.silvesArena.fightInfo.team2Name or "")

    index = 1
    while true do
    	local node = self._ccbOwner["node_my_head"..index]
    	if node then
    		node:removeAllChildren()
    		index = index + 1
    	else
    		break
    	end
    end
    index = 1
    while true do
    	local node = self._ccbOwner["node_fight_head"..index]
    	if node then
    		node:removeAllChildren()
    		index = index + 1
    	else
    		break
    	end
    end
    table.sort(remote.silvesArena.fightInfo.attackFightInfo, function(a,b)
    	return a.silvesArenaFightPos < b.silvesArenaFightPos
	end)
	table.sort(remote.silvesArena.fightInfo.defenseFightInfo, function(a,b)
    	return a.silvesArenaFightPos < b.silvesArenaFightPos
	end)
 	if not q.isEmpty(remote.silvesArena.fightInfo.attackFightInfo) then
 		for i, fighter in ipairs(remote.silvesArena.fightInfo.attackFightInfo) do 			
 			print("[attackFightInfo] ", i, fighter.avatar)
 			local node = self._ccbOwner["node_my_head"..i]
 			if node then
 				node:removeAllChildren()
 				local head = QUIWidgetAvatar.new(fighter.avatar)
 				head:setSilvesArenaPeak(fighter.championCount)
 				head:setScaleX(1)
 				node:addChild(head)
 			else
 				break
 			end
 		end
 	end
 	if not q.isEmpty(remote.silvesArena.fightInfo.defenseFightInfo) then
 		for i, fighter in ipairs(remote.silvesArena.fightInfo.defenseFightInfo) do
 			print("[defenseFightInfo] ", i, fighter.avatar)
 			local node = self._ccbOwner["node_fight_head"..i]
 			if node then
 				node:removeAllChildren()
 				local head = QUIWidgetAvatar.new(fighter.avatar)
 				head:setSilvesArenaPeak(fighter.championCount)
 				head:setScaleX(1)
 				node:addChild(head)
 			else
 				break
 			end
 		end
 	end

 	index = 1
    local totalWave = #scoreList
 	while index <= totalWave do
 		local attackFightInfo = remote.silvesArena.fightInfo.attackFightInfo[index]
 		local defenseFightInfo = remote.silvesArena.fightInfo.defenseFightInfo[index]
 		if q.isEmpty(attackFightInfo) or q.isEmpty(defenseFightInfo) then
 			break
 		else
 			local tbl = {}
			tbl.index = index
	        tbl.isWin = scoreList[index] == 1
	        tbl.heroFighter = attackFightInfo.heros
	        tbl.heroSubFighter = attackFightInfo.subheros
	        tbl.heroSubFighter2 = attackFightInfo.sub2heros
	        tbl.heroSubFighter3 = attackFightInfo.sub3heros
	        tbl.heroSoulSpirit = attackFightInfo.soulSpirit

	        tbl.enemyFighter = defenseFightInfo.heros
	        tbl.enemySubFighter = defenseFightInfo.subheros
	        tbl.enemySubFighter2 = defenseFightInfo.sub2heros
	        tbl.enemySubFighter3 = defenseFightInfo.sub3heros
	        tbl.enemySoulSpirit = defenseFightInfo.soulSpirit

	        tbl.teamHeroSubActorId = attackFightInfo.activeSubActorId
	        tbl.teamHeroSubActorId2 = attackFightInfo.activeSub2ActorId
	        tbl.teamHeroSubActorId3 = attackFightInfo.activeSub3ActorId

	        tbl.teamEnemySubActorId = defenseFightInfo.activeSubActorId
	        tbl.teamEnemySubActorId2 = defenseFightInfo.activeSub2ActorId
	        tbl.teamEnemySubActorId3 = defenseFightInfo.activeSub3ActorId

	        tbl.heroGodarmList = attackFightInfo.godArm1List
	        tbl.enemyGodarmList = defenseFightInfo.godArm1List

	        tbl.isSilvesArena = true

	        self._detailInfo[index] = tbl

 			index = index + 1
 		end
 	end
end

-- 重置所有
function QBattleDialogSilvesFightDataRecord:resetAll()
	self._ccbOwner.btn_detail:setEnabled(true)
	self._ccbOwner.btn_detail:setHighlighted(false)
	self._ccbOwner.btn_data:setEnabled(true)
	self._ccbOwner.btn_data:setHighlighted(false)
end

function QBattleDialogSilvesFightDataRecord:selectTabs()
	self:resetAll()
	if self._selectTab == QBattleDialogSilvesFightDataRecord.TAB_DETAIL then
		-- self._ccbOwner.btn_detail:setHighlighted(true)
		self._tabManager:selected(self._ccbOwner.btn_detail)
		self:showDetailRecord()
	elseif self._selectTab == QBattleDialogSilvesFightDataRecord.TAB_DATA then
		-- self._ccbOwner.btn_data:setHighlighted(true)
		self._tabManager:selected(self._ccbOwner.btn_data)
		self:showDataRecord()
	end
end

function QBattleDialogSilvesFightDataRecord:showDetailRecord()
	self._ccbOwner.node_detail:setVisible(true)
	self._ccbOwner.node_data:setVisible(false)

    if not self._datailListView then
	    local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._detailInfo[index]
	            local item = list:getItemFromCache()
	            if not item then
	            	item = QUIWidgetSilvesFightEndDetail.new()
	            	isCacheNode = false
	            end
	            item:setInfo(itemData)
	            info.item = item
	            info.size = item:getContentSize()
				
	            return isCacheNode
	        end,
	        ignoreCanDrag = true,
	        enableShadow = false,
	        totalNumber = #self._detailInfo,
	    }  
	    self._datailListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._datailListView:refreshData()
	end
end

function QBattleDialogSilvesFightDataRecord:showDataRecord()
	self._ccbOwner.node_detail:setVisible(false)
	self._ccbOwner.node_data:setVisible(true)

    if not self._dataListView then
	    local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._dataRecord[index]
	            local item = list:getItemFromCache()
	            if not item then
	            	item = QUIWidgetSilvesFightDataClient.new()
            		item:addEventListener(QUIWidgetSilvesFightDataClient.HERO_FIGHT_INFO, handler(self, self.heroClickHandler))
	            	isCacheNode = false
	            end
	            item:setInfo(itemData, index)
	            info.item = item
	            info.size = item:getContentSize()

	            if app.battle:isInEditor() or DISPLAY_MORE_BATTLE_DETAIL then
					item:registerItemBoxPrompt(index, list)
				end
				
	            return isCacheNode
	        end,
	        ignoreCanDrag = true,
	        enableShadow = false,
	        curOffset = 20,
	        spaceY = 20,
	        totalNumber = #self._dataRecord,
	    }  
	    self._dataListView = QListView.new(self._ccbOwner.sheet_layout1, cfg)
	else
		self._dataListView:refreshData()
	end
end

function QBattleDialogSilvesFightDataRecord:heroClickHandler(event)
	if not event.info then
		return
	end
	local stat = event.info
	local isHero = event.isHero or false
    QBattleDialogSkillData.new({skillData = stat.skill, isHero = isHero}) 
end

function QBattleDialogSilvesFightDataRecord:_backClickHandler()
	self:_onTriggerClose()
end

function QBattleDialogSilvesFightDataRecord:_onTriggerData(event)
	self._ccbOwner.btn_data:setHighlighted(true)
	if self._selectTab == QBattleDialogSilvesFightDataRecord.TAB_DATA then
		return
	end
	app.sound:playSound("common_cancel")

	self._selectTab = QBattleDialogSilvesFightDataRecord.TAB_DATA
	self:selectTabs()
end

function QBattleDialogSilvesFightDataRecord:_onTriggerDetail(event)
	self._ccbOwner.btn_detail:setHighlighted(true)
	if self._selectTab == QBattleDialogSilvesFightDataRecord.TAB_DETAIL then
		return
	end
	app.sound:playSound("common_cancel")

	self._selectTab = QBattleDialogSilvesFightDataRecord.TAB_DETAIL
	self:selectTabs()
end

function QBattleDialogSilvesFightDataRecord:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end	
	self:retain()
	if app.battle:isInEditor() then
		app.battle:resume()
	end
	if event ~= nil then 
		app.sound:playSound("common_cancel")
	end
	self:close()
	if self._closeCallback then
    	self._closeCallback()
    end
    self:release()
end

return QBattleDialogSilvesFightDataRecord