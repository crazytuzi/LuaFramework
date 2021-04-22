--
-- zxs
-- 战斗结束
--
local QBattleDialog = import(".QBattleDialog")
local QBattleDialogFightEndRecord = class(".QBattleDialogFightEndRecord", QBattleDialog)
local QUIWidgetFightEndDetailClient = import("..widgets.QUIWidgetFightEndDetailClient")
local QUIWidgetFightEndDataClient = import("..widgets.QUIWidgetFightEndDataClient")
local QUIWidgetAgainstRecordProgressBar = import("..widgets.QUIWidgetAgainstRecordProgressBar")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QListView = import("...views.QListView")
local QBattleLog = import("...controllers.QBattleLog")
local QBattleDialogSkillData = import(".QBattleDialogSkillData")

QBattleDialogFightEndRecord.TAB_DETAIL = "TAB_DETAIL"
QBattleDialogFightEndRecord.TAB_DATA = "TAB_DATA"

function QBattleDialogFightEndRecord:ctor(options)
	local ccbFile = "ccb/Dialog_FightEnd_data.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerDetail", callback = handler(self, self._onTriggerDetail)},
		{ccbCallbackName = "onTriggerData", callback = handler(self, self._onTriggerData)},
	}
	QBattleDialogFightEndRecord.super.ctor(self, ccbFile, {}, callBacks)
	options = options or {}

	self._closeCallback = options.callback
	self._ccbOwner.sp_vs:setVisible(false)
	self._selectTab = QBattleDialogFightEndRecord.TAB_DETAIL
    self._detailInfo = {}
	self._dataRecord = {}

    ui.tabButton(self._ccbOwner.btn_detail, "战斗\n详情",18)
    ui.tabButton(self._ccbOwner.btn_data, "数据\n查看",18)
	self._tabManager = ui.tabManager({self._ccbOwner.btn_detail, self._ccbOwner.btn_data})
	self._ccbOwner.frame_tf_title:setString("战斗详情")
	self:initDetailData()
	self:selectTabs()
end

function QBattleDialogFightEndRecord:initDetailData()
	local dungeonConfig = app.battle:getDungeonConfig()
	local scoreList = {}
	local logList = {}

	-- 直接战斗
	if dungeonConfig.fightEndResponse then
		-- QKumo(dungeonConfig.fightEndResponse)
		local log, others = app.battle:getRawBattleLogFromServer()
		scoreList = dungeonConfig.fightEndResponse.gfEndResponse.scoreList
		logList = {log, others[1], others[2]}
	-- 回放战斗
	elseif dungeonConfig._newPvpMultipleScoreInfo then
		-- QKumo(dungeonConfig._newPvpMultipleScoreInfo)
		scoreList = dungeonConfig._newPvpMultipleScoreInfo.scoreList
		local battleLogList = dungeonConfig._newPvpMultipleScoreInfo.battleLogList
		for i, log in pairs(battleLogList) do
			table.insert(logList, log._log)
		end
	end
	
	local teams = dungeonConfig.pvpMultipleTeams
	-- QKumo(teams)
	local teamInfo1 = {index = 1, teamInfo = teams[1], log = logList[1]}
	table.insert(self._dataRecord, teamInfo1)
	if #scoreList >= 2 then
		local teamInfo2 = {index = 2, teamInfo = teams[2], log = logList[2]}
		table.insert(self._dataRecord, teamInfo2)
	end
	if #scoreList == 3 then
		local newTeam = {}
		if scoreList[1] == true then
			newTeam.hero = teams[2].hero
			newTeam.enemy = teams[1].enemy
		else
			newTeam.hero = teams[1].hero
			newTeam.enemy = teams[2].enemy
		end
		local teamInfo3 = {index = 3, teamInfo = newTeam, log = logList[3]}
		table.insert(self._dataRecord, teamInfo3)
	end

	local attackScore = 0
	local defenseScore = 0
	for i, v in pairs(scoreList or {}) do
		if v == true then
			attackScore = attackScore + 1
		else
			defenseScore = defenseScore + 1
		end
	end

    self._ccbOwner.sp_score1:setString(attackScore)
    self._ccbOwner.sp_score2:setString(defenseScore)

    -- self._ccbOwner.sp_score1:setDisplayFrame(QSpriteFrameByPath(QResPath("StormArena_S")[attackScore+1]))
    -- self._ccbOwner.sp_score2:setDisplayFrame(QSpriteFrameByPath(QResPath("StormArena_S")[defenseScore+1]))    
    self._ccbOwner.node_head1:removeAllChildren()
    self._ccbOwner.node_head2:removeAllChildren()

	self._ccbOwner.tf_name1:setString(dungeonConfig.team1Name)
    self._ccbOwner.tf_name2:setString(dungeonConfig.team2Name)
    local head1 = QUIWidgetAvatar.new(dungeonConfig.team1Icon)
    local head2 = QUIWidgetAvatar.new(dungeonConfig.team2Icon)
    head2:setScaleX(-1)
    self._ccbOwner.node_head1:addChild(head1)
    self._ccbOwner.node_head2:addChild(head2)


	local replayInfo = {}
    replayInfo.fighter1 = teams[1].hero.heroes
    replayInfo.userAlternateInfos = teams[1].hero.alternateInfos
    replayInfo.sub1Fighter1 = teams[1].hero.supports
    replayInfo.soulSpirits1 = teams[1].hero.soulSpirits
    replayInfo.team1GodarmList = teams[1].hero.godArmIdList
    
    replayInfo.fighter2 = teams[1].enemy.heroes
    replayInfo.enemyAlternateInfos = teams[1].enemy.alternateInfos
    replayInfo.sub1Fighter2 = teams[1].enemy.supports
    replayInfo.soulSpirits2 = teams[1].enemy.soulSpirits
	replayInfo.team1EnemyGodarmList = teams[1].enemy.godArmIdList

    replayInfo.team2HeroInfoes = teams[2].hero.heroes
    replayInfo.team2Sub1Fighter1 = teams[2].hero.supports
    replayInfo.team2SoulSpirits1 = teams[2].hero.soulSpirits
  	replayInfo.team2GodarmList = teams[2].hero.godArmIdList

    replayInfo.team2Rivals = teams[2].enemy.heroes
    replayInfo.team2Sub1Fighter2 = teams[2].enemy.supports
    replayInfo.team2SoulSpirits2 = teams[2].enemy.soulSpirits
	replayInfo.team2EnemyGodarmList = teams[2].enemy.godArmIdList

    replayInfo.team1HeroSkillIndex = teams[1].hero.supportSkillHeroIndex or 0
    replayInfo.team1HeroSkillIndex2 = teams[1].hero.supportSkillHeroIndex2 or 0
    replayInfo.team1EnemySkillIndex = teams[1].enemy.supportSkillHeroIndex or 0
    replayInfo.team1EnemySkillIndex2 = teams[1].enemy.supportSkillHeroIndex2 or 0

    replayInfo.team2HeroSkillIndex = teams[2].hero.supportSkillHeroIndex or 0
    replayInfo.team2HeroSkillIndex2 = teams[2].hero.supportSkillHeroIndex2 or 0
    replayInfo.team2EnemySkillIndex = teams[2].enemy.supportSkillHeroIndex or 0
    replayInfo.team2EnemySkillIndex2 = teams[2].enemy.supportSkillHeroIndex2 or 0
    if scoreList[1] ~= nil then
        local playerInfo = {}
        playerInfo.index = 1
        playerInfo.isWin = scoreList[1]
        playerInfo.heroFighter = replayInfo.fighter1
        playerInfo.heroAlternateFighter = replayInfo.userAlternateInfos
        playerInfo.heroSubFighter = replayInfo.sub1Fighter1
        playerInfo.heroSoulSpirit = replayInfo.soulSpirits1
        playerInfo.enemyFighter = replayInfo.fighter2
        playerInfo.enemyAlternateFighter = replayInfo.enemyAlternateInfos
        playerInfo.enemySubFighter = replayInfo.sub1Fighter2
        playerInfo.enemySoulSpirit = replayInfo.soulSpirits2
        playerInfo.teamHeroSkillIndex = replayInfo.team1HeroSkillIndex
        playerInfo.teamHeroSkillIndex2 = replayInfo.team1HeroSkillIndex2
        playerInfo.teamEnemySkillIndex = replayInfo.team1EnemySkillIndex
        playerInfo.teamEnemySkillIndex2 = replayInfo.team1EnemySkillIndex2
        playerInfo.heroGodarmList = replayInfo.team1GodarmList
        playerInfo.enemyGodarmList = replayInfo.team1EnemyGodarmList
        playerInfo.isMultiTeam = (replayInfo.team1HeroSkillIndex2 and replayInfo.team1HeroSkillIndex2 ~= 0) or (replayInfo.team1EnemySkillIndex2 and replayInfo.team1EnemySkillIndex2 ~= 0)

        table.insert(self._detailInfo, playerInfo)
    end
    if scoreList[2] ~= nil then
        local playerInfo = {}
        playerInfo.index = 2
        playerInfo.isWin = scoreList[2]
        playerInfo.heroFighter = replayInfo.team2HeroInfoes
        playerInfo.heroSubFighter = replayInfo.team2Sub1Fighter1
        playerInfo.heroSoulSpirit = replayInfo.team2SoulSpirits1
        playerInfo.enemyFighter = replayInfo.team2Rivals
        playerInfo.enemySubFighter = replayInfo.team2Sub1Fighter2
        playerInfo.enemySoulSpirit = replayInfo.team2SoulSpirits2
        playerInfo.teamHeroSkillIndex = replayInfo.team2HeroSkillIndex
        playerInfo.teamHeroSkillIndex2 = replayInfo.team2HeroSkillIndex2
        playerInfo.teamEnemySkillIndex = replayInfo.team2EnemySkillIndex
        playerInfo.teamEnemySkillIndex2 = replayInfo.team2EnemySkillIndex2

        playerInfo.heroGodarmList = replayInfo.team2GodarmList
        playerInfo.enemyGodarmList = replayInfo.team2EnemyGodarmList
        playerInfo.isMultiTeam = (replayInfo.team2HeroSkillIndex2 and replayInfo.team2HeroSkillIndex2 ~= 0) or (replayInfo.team2EnemySkillIndex2 and replayInfo.team2EnemySkillIndex2 ~= 0)

        table.insert(self._detailInfo, playerInfo)
    end
    if scoreList[3] ~= nil then
        local playerInfo = {}
        playerInfo.index = 3
        playerInfo.isWin = scoreList[3]
        if scoreList[1] == true then
            playerInfo.heroFighter = replayInfo.team2HeroInfoes
            playerInfo.heroSubFighter = replayInfo.team2Sub1Fighter1
            playerInfo.heroSoulSpirit = replayInfo.team2SoulSpirits1
            playerInfo.enemyFighter = replayInfo.fighter2
            playerInfo.enemySubFighter = replayInfo.sub1Fighter2
            playerInfo.enemySoulSpirit = replayInfo.soulSpirits2
            playerInfo.teamHeroSkillIndex = replayInfo.team2HeroSkillIndex
        	playerInfo.teamHeroSkillIndex2 = replayInfo.team2HeroSkillIndex2
        	playerInfo.teamEnemySkillIndex = replayInfo.team1EnemySkillIndex
        	playerInfo.teamEnemySkillIndex2 = replayInfo.team1EnemySkillIndex2
            playerInfo.heroGodarmList = replayInfo.team2GodarmList
            playerInfo.enemyGodarmList = replayInfo.team1EnemyGodarmList            	
        else
        	playerInfo.heroFighter = replayInfo.fighter1
        	playerInfo.heroSubFighter = replayInfo.sub1Fighter1
        	playerInfo.heroSoulSpirit = replayInfo.soulSpirits1
        	playerInfo.enemyFighter = replayInfo.team2Rivals
        	playerInfo.enemySubFighter = replayInfo.team2Sub1Fighter2
        	playerInfo.enemySoulSpirit = replayInfo.team2SoulSpirits2
        	playerInfo.teamHeroSkillIndex = replayInfo.team1HeroSkillIndex
       	 	playerInfo.teamHeroSkillIndex2 = replayInfo.team1HeroSkillIndex2
        	playerInfo.teamEnemySkillIndex = replayInfo.team2EnemySkillIndex
        	playerInfo.teamEnemySkillIndex2 = replayInfo.team2EnemySkillIndex2
            playerInfo.heroGodarmList = replayInfo.team1GodarmList
            playerInfo.enemyGodarmList = replayInfo.team2EnemyGodarmList     

        end
        table.insert(self._detailInfo, playerInfo)
    end
end

-- 重置所有
function QBattleDialogFightEndRecord:resetAll()
	self._ccbOwner.btn_detail:setEnabled(true)
	self._ccbOwner.btn_detail:setHighlighted(false)
	self._ccbOwner.btn_data:setEnabled(true)
	self._ccbOwner.btn_data:setHighlighted(false)
end

function QBattleDialogFightEndRecord:selectTabs()
	self:resetAll()
	-- QKumo(self._detailInfo)
	-- QKumo(self._dataRecord)
	if self._selectTab == QBattleDialogFightEndRecord.TAB_DETAIL then
		-- self._ccbOwner.btn_detail:setHighlighted(true)
		self._tabManager:selected(self._ccbOwner.btn_detail)
		self:showDetailRecord()
	elseif self._selectTab == QBattleDialogFightEndRecord.TAB_DATA then
		-- self._ccbOwner.btn_data:setHighlighted(true)
		self._tabManager:selected(self._ccbOwner.btn_data)
		self:showDataRecord()
	end
end

function QBattleDialogFightEndRecord:showDetailRecord()
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
	            	item = QUIWidgetFightEndDetailClient.new()
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

function QBattleDialogFightEndRecord:showDataRecord()
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
	            	item = QUIWidgetFightEndDataClient.new()
            		item:addEventListener(QUIWidgetFightEndDataClient.HERO_FIGHT_INFO, handler(self, self.heroClickHandler))
	            	isCacheNode = false
	            end
	            item:setInfo(itemData)
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

function QBattleDialogFightEndRecord:heroClickHandler(event)
	if not event.info then
		return
	end
	local stat = event.info
	local isHero = event.isHero or false
    QBattleDialogSkillData.new({skillData = stat.skill, isHero = isHero}) 
end

function QBattleDialogFightEndRecord:_backClickHandler()
	self:_onTriggerClose()
end

function QBattleDialogFightEndRecord:_onTriggerData(event)
	self._ccbOwner.btn_data:setHighlighted(true)
	if self._selectTab == QBattleDialogFightEndRecord.TAB_DATA then
		return
	end
	app.sound:playSound("common_cancel")

	self._selectTab = QBattleDialogFightEndRecord.TAB_DATA
	self:selectTabs()
end

function QBattleDialogFightEndRecord:_onTriggerDetail(event)
	self._ccbOwner.btn_detail:setHighlighted(true)
	if self._selectTab == QBattleDialogFightEndRecord.TAB_DETAIL then
		return
	end
	app.sound:playSound("common_cancel")

	self._selectTab = QBattleDialogFightEndRecord.TAB_DETAIL
	self:selectTabs()
end

function QBattleDialogFightEndRecord:_onTriggerClose(event)
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

return QBattleDialogFightEndRecord