--
-- zxs
-- 战斗结束
--
local QBattleDialog = import(".QUIDialog")
local QUIDialogTeamInfoCompare = class(".QUIDialogTeamInfoCompare", QBattleDialog)
local QUIWidgetFightEndDetailClient = import("..widgets.QUIWidgetFightEndDetailClient")
local QUIWidgetFightEndDataClient = import("..widgets.QUIWidgetFightEndDataClient")
local QUIWidgetAgainstRecordProgressBar = import("..widgets.QUIWidgetAgainstRecordProgressBar")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QListView = import("...views.QListView")
local QMyAppUtils = import("...utils.QMyAppUtils")

function QUIDialogTeamInfoCompare:ctor(options)
	local ccbFile = "ccb/Dialog_FightEnd_data.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogTeamInfoCompare._onTriggerClose)},
		{ccbCallbackName = "onTriggerDetail", callback = handler(self, QUIDialogTeamInfoCompare._onTriggerDetail)},
		{ccbCallbackName = "onTriggerData", callback = handler(self, QUIDialogTeamInfoCompare._onTriggerData)},
	}
	QUIDialogTeamInfoCompare.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

	self._fighter1 = options.fighter1
	self._fighter2 = options.fighter2
	self._ccbOwner.btn_detail:setVisible(false)
	self._ccbOwner.btn_data:setVisible(false)
	self._ccbOwner.node_detail:setVisible(true)
	self._ccbOwner.node_score:setVisible(false)
	self._ccbOwner.sp_vs:setVisible(true)

	self._ccbOwner.frame_tf_title:setString("战斗详情")
	
    self._detailInfo = {}

	self:initDetailData()
	self:showDetailRecord()
end

function QUIDialogTeamInfoCompare:initDetailData()
    self._ccbOwner.node_head1:removeAllChildren()
    self._ccbOwner.node_head2:removeAllChildren()

    local nameStr1 = "LV."..self._fighter1.level.." "..self._fighter1.name
    local nameStr2 = "LV."..self._fighter2.level.." "..self._fighter2.name
	self._ccbOwner.tf_name1:setString(nameStr1)
    self._ccbOwner.tf_name2:setString(nameStr2)

    local head1 = QUIWidgetAvatar.new(self._fighter1.avatar)
    head1:setSilvesArenaPeak(self._fighter1.championCount)
    local head2 = QUIWidgetAvatar.new(self._fighter2.avatar)
    head2:setSilvesArenaPeak(self._fighter2.championCount)
    head2:setScaleX(-1)
    self._ccbOwner.node_head1:addChild(head1)
    self._ccbOwner.node_head2:addChild(head2)
   
   	-- 援助技能
	local function tableIndexof(supports, actorId)
		for i, v in pairs(supports or {}) do
			if v.actorId == actorId then
				return i
			end
		end
		return 0
	end

	local team1GodarmList = {}
    for _, godArmInfo in ipairs(self._fighter1.godArm1List or {}) do
        table.insert(team1GodarmList,QMyAppUtils:getGodarmInfo(godArmInfo))
    end    

	local enemy1GodarmList = {}
    for _, godArmInfo in ipairs(self._fighter2.godArm1List or {}) do
        table.insert(enemy1GodarmList,QMyAppUtils:getGodarmInfo(godArmInfo))
    end  

    local playerInfo = {}
    playerInfo.index = 1
    playerInfo.heroFighter = self._fighter1.heros
    playerInfo.heroSubFighter = self._fighter1.subheros
    playerInfo.heroSoulSpirit = self._fighter1.soulSpirit or {}
    playerInfo.heroGodarmList = team1GodarmList
    playerInfo.enemyFighter = self._fighter2.heros
    playerInfo.enemySubFighter = self._fighter2.subheros
    playerInfo.enemySoulSpirit = self._fighter2.soulSpirit or {}
    playerInfo.team1GodarmList = self._fighter2.godArm1List or {}
    playerInfo.enemyGodarmList = enemy1GodarmList
    playerInfo.teamHeroSkillIndex = tableIndexof(self._fighter1.subheros, self._fighter1.activeSubActorId)
    playerInfo.teamHeroSkillIndex2 = tableIndexof(self._fighter1.subheros, self._fighter1.active1SubActorId)
    playerInfo.teamEnemySkillIndex = tableIndexof(self._fighter2.subheros, self._fighter2.activeSubActorId)
    playerInfo.teamEnemySkillIndex2 = tableIndexof(self._fighter2.subheros, self._fighter2.active1SubActorId)
    table.insert(self._detailInfo, playerInfo)
    
	local team2GodarmList = {}
    for _, godArmInfo in ipairs(self._fighter1.godArm2List or {}) do
        table.insert(team2GodarmList,QMyAppUtils:getGodarmInfo(godArmInfo))
    end    

	local enemy2GodarmList = {}
    for _, godArmInfo in ipairs(self._fighter2.godArm2List or {}) do
        table.insert(enemy2GodarmList,QMyAppUtils:getGodarmInfo(godArmInfo))
    end 

    local playerInfo = {}
    playerInfo.index = 2
    playerInfo.heroFighter = self._fighter1.main1Heros
    playerInfo.heroSubFighter = self._fighter1.sub1heros
    playerInfo.heroSoulSpirit =self._fighter1.soulSpirit2 or {}
    playerInfo.heroGodarmList = team2GodarmList
    playerInfo.enemyFighter = self._fighter2.main1Heros
    playerInfo.enemySubFighter = self._fighter2.sub1heros
    playerInfo.enemySoulSpirit = self._fighter2.soulSpirit2 or {}
    playerInfo.enemyGodarmList = enemy2GodarmList
    playerInfo.teamHeroSkillIndex = tableIndexof(self._fighter1.sub1heros, self._fighter1.activeSub2ActorId)
    playerInfo.teamHeroSkillIndex2 = tableIndexof(self._fighter1.sub1heros, self._fighter1.active1Sub2ActorId)
    playerInfo.teamEnemySkillIndex = tableIndexof(self._fighter2.sub1heros, self._fighter2.activeSub2ActorId)
    playerInfo.teamEnemySkillIndex2 = tableIndexof(self._fighter2.sub1heros, self._fighter2.active1Sub2ActorId)
    table.insert(self._detailInfo, playerInfo)
end

function QUIDialogTeamInfoCompare:showDetailRecord()
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

function QUIDialogTeamInfoCompare:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogTeamInfoCompare:_onTriggerDetail(event)
	return
end

function QUIDialogTeamInfoCompare:_onTriggerClose(event)
	if event ~= nil then 
		app.sound:playSound("common_cancel")
	end

	self:playEffectOut()
end

return QUIDialogTeamInfoCompare