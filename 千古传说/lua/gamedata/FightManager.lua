--
-- Author: Zippo
-- Date: 2013-12-02 15:36:49
--

local fightRoundMgr  = require("lua.logic.fight.FightRoundManager")
local fightReplayMgr  = require("lua.logic.fight.FightReplayManager")
local fightRoleMgr  = require("lua.logic.fight.FightRoleManager")
local fightAI = require("lua.logic.fight.FightAI")

local battleRoundMgr  = require("lua.logic.battle.BattleRoleManager")
local battleReplayMgr  = require("lua.logic.battle.BattleReplayManager")
local FightManager = class("FightManager")

FightManager.FactionBossFightLeave = "FightManager.FactionBossFightLeave"
FightManager.LeaveFightCommand = "FightManager.LeaveFightCommand"
FightManager.FactionBossFightResult = "FightManager.FactionBossFightResult"
FightManager.FactionBossFightWin 	= "FightManager.FactionBossFightWin"

function FightManager:ctor()
	self.fightSpeed = 1
	self.isAutoFight = false
	self.maxRoundNum = 10
	self.nCurrRoundNum = 0
	self.manualActionNum = 0 		--主动攻击次数
	self.ispause = false
	self:Reset()
	self:RegisterEvents()
end

function FightManager:restart()
	if self.fightBeginInfo ~= nil and self.fightBeginInfo.bGuideFight then
		return
	end
	
	self.fightSpeed = 1
	self.isAutoFight = false
	self:Reset()
end

function FightManager:Reset()
	self.bWaitResultMsg = false
	self.isFighting = false
	self.isBattle = false
	self.fightBeginInfo = nil
	self.fightResultInfo = nil
	self.lastEndFightMsg = nil
	self.nCurrRoundNum = 0
	self.manualActionNum = 0
	if self.end_timerID then
		TFDirector:removeTimer(self.end_timerID)
		self.end_timerID = nil
	end
	self.maxRoundNum = 10
	DeviceAdpter.skipMemoryWarning = false

	self.callBackInterrupt = false
end

function FightManager:RegisterEvents()
	TFDirector:addProto(s2c.FIGHT_BEGIN, self, self.FightBeginMsgHandle)
	TFDirector:addProto(s2c.FIGHT_RESULT, self, self.FightResultMsgHandle)
	TFDirector:addProto(s2c.TONG_REN_FIGHT_RESULT, self, self.FightResultMsgHandle)
	TFDirector:addProto(s2c.FIGHT_REPLAY, self, self.FightReplayMsgHandle)
	ErrorCodeManager:addProtocolListener(s2c.FIGHT_RESULT, function() self:FightErrorHandle() end)
	ErrorCodeManager:addProtocolListener(s2c.TONG_REN_FIGHT_RESULT,  function() self:FightErrorHandle() end)

	TFDirector:addProto(s2c.BATTLE_START, self, self.BattleStartMsg)
	TFDirector:addProto(s2c.ROUNDS_BATTLE, self, self.RoundsBattleMsg)
	TFDirector:addProto(s2c.BATTLE_REPLAY, self, self.BattleReplayMsg)
	TFDirector:addProto(s2c.BATTLE_RESULT, self, self.BattleResultMsgHandle)

	TFDirector:addProto(s2c.PLAY_REPLAY_ARENA_TOP_SUCCESS, self, self.FightArenaReplayMsgHandle)

	self.leaveFightCommandCallBack = function (event)
		-- local currentScene = Public:currentScene()
		-- if currentScene == nil or currentScene.__cname ~= "FightScene" then
		-- 	return
		-- end
		-- self:EndFight(false)
		-- -- self:LeaveFight()
		self.callBackInterrupt = true
	end
    TFDirector:addMEGlobalListener(FightManager.LeaveFightCommand, self.leaveFightCommandCallBack)

end

function FightManager:BeginFight()
	self.isReplayFight = false
	fightRoundMgr.actionList:clear()
	self.manualActionNum = 0

	self.maxRoundNum = 10
	if self.fightBeginInfo.fighttype == 16 then
		local floorOptionNow = NorthClimbManager:getNowFloorOption()
		for i=1,2 do
			if floorOptionNow[i] then
				local battleInfo = BattleLimitedData:objectByID(floorOptionNow[i])
				if battleInfo and battleInfo.type == 2 then
					self.maxRoundNum = battleInfo.value
				end
			end
		end
	end
	if self.fightBeginInfo.bGuideFight then
		AlertManager:changeScene(SceneType.FIGHT)
	else
		local currentScene = Public:currentScene()
	    if currentScene.__cname == "FightResultScene" or currentScene.__cname == "FightScene" then
			AlertManager:changeScene(SceneType.FIGHT)
	    else
			AlertManager:changeScene(SceneType.FIGHT, nil, TFSceneChangeType_PushBack)
	    end
	end
	self.isFighting = true

	DeviceAdpter.skipMemoryWarning = true
end

function FightManager:addManualActionNum()
	self.manualActionNum = self.manualActionNum + 1
end

function FightManager:ReplayFight(bRecordFight)
	if self.isFighting then
		return
	end
	self.isReplayFight = true
	if bRecordFight then
		local currentScene = Public:currentScene()
	    if currentScene.__cname == "FightResultScene" or currentScene.__cname == "FightScene" then
			AlertManager:changeScene(SceneType.FIGHT)
	    else
			AlertManager:changeScene(SceneType.FIGHT, nil, TFSceneChangeType_PushBack)
	    end
	else
		AlertManager:changeScene(SceneType.FIGHT)
	end
	
	self.isFighting = true

	DeviceAdpter.skipMemoryWarning = true
end

function FightManager:OnEnterFightScene()
	if self.isBattle then
		battleReplayMgr:ExecuteAction(1)		
		return
	end
	if self.isReplayFight then
		fightReplayMgr:ExecuteAction(1)
	else
		fightRoundMgr:ExecuteFirstRound()
	end
end

function FightManager:EndReplayFight()
	if self.isFighting then
		self.isFighting = false

		DeviceAdpter.skipMemoryWarning = false

		if self.end_timerID then
			TFDirector:removeTimer(self.end_timerID)
			self.end_timerID = nil
		end
		self.end_timerID = TFDirector:addTimer(1000, 1, nil, 
		function() 
			TFDirector:removeTimer(self.end_timerID)
			self.end_timerID = nil
			AlertManager:changeScene(SceneType.FIGHTRESULT)
		end)
	end
end

function FightManager:BreakFight()
	self:EndFight(true)
end

function FightManager:SwitchAutoFight()
	self.isAutoFight = not self.isAutoFight
end

function FightManager:CleanFight()
	fightAI:dispose()
	fightRoundMgr:dispose()
	fightReplayMgr:dispose()
	fightRoleMgr:dispose()
end

function FightManager:OnReConnect()
	print("战斗断线重连成功")
	if self.lastEndFightMsg ~= nil and self.isFighting == false then
		self.bWaitResultMsg = true
		TFDirector:send(c2s.FIGHT_END_REQUEST, self.lastEndFightMsg)
	end
end

function FightManager:EndFight(win)
	if self.isBattle then
		self:EndReplayBattle()
		return
	end

	if self.isReplayFight then
		self:EndReplayFight()
		return
	end

	if self.isFighting then
		self.isFighting = false

		DeviceAdpter.skipMemoryWarning = false
		if self.end_timerID then
			TFDirector:removeTimer(self.end_timerID)
			self.end_timerID = nil
		end
		self.end_timerID = TFDirector:addTimer(1000, 1, nil,
		function() 
			TFDirector:removeTimer(self.end_timerID)
			self.end_timerID = nil
			if self.fightBeginInfo.bGuideFight then
				self:OnGuideFightEnd(win)
			else
				self:SendEndFightMsg(win)
			end
		end)
	end
end

function FightManager:SendEndFightMsg(win)
	local topLayer = Public:currentScene():getTopLayer()
    if topLayer ~= nil and topLayer.__cname == "ReconnectLayer" then
    else
    	hideAllLoading()
	    for i=1,100 do
	        showLoading()
	    end
    end

	local list = {}
	local nActionCount = fightRoundMgr.actionList:length()
	for i=1,nActionCount do
		local actionInfo = fightRoundMgr.actionList:objectAt(i)
		if actionInfo ~= nil and actionInfo.unExecute == false and actionInfo.targetlist ~= nil then
			local bBackAttack = actionInfo.bBackAttack or false
			local info = {actionInfo.bManualAction, actionInfo.roundIndex, actionInfo.attackerpos,
						actionInfo.skillid.skillId,actionInfo.skillid.level, bBackAttack}

			info[8] = actionInfo.buffList
			info[9] = actionInfo.triggerType or 0
			info[7]	= {}
			for j=1, #actionInfo.targetlist do
				local actionTargetInfo = actionInfo.targetlist[j]

				local triggerBufferID = actionTargetInfo.triggerBufferID or 0
				local triggerBufferLevel = actionTargetInfo.triggerBufferLevel or 0
				local passiveEffect = actionTargetInfo.passiveEffect or 0
				local passiveEffectValue = actionTargetInfo.passiveEffectValue or 0
				local activeEffect = actionTargetInfo.activeEffect or 0
				local activeEffectValue = actionTargetInfo.activeEffectValue or 0

			  	local targetInfo = {actionTargetInfo.targetpos, actionTargetInfo.effect, actionTargetInfo.hurt,
			  						triggerBufferID, triggerBufferLevel, passiveEffect, passiveEffectValue, activeEffect, activeEffectValue}

			  	info[7][j] = targetInfo
			end	  
			list[#list+1] = info
		end
	end

	local liveList = {}
	for k,role in pairs(fightRoleMgr.map) do
		liveList[#liveList+1] = {role.logicInfo.posindex, role.currHp}
	end
	local hurtcountlist = {}
	for k,role in pairs(fightRoleMgr.map) do
		hurtcountlist[#hurtcountlist+1] = {role.logicInfo.posindex, fightRoleMgr.hurtReport[role.logicInfo.posindex] or 0}
	end

	self.lastEndFightMsg = {self.fightBeginInfo.fighttype, win, list, liveList, fightRoleMgr.selfAnger, fightRoleMgr.enemyAnger,hurtcountlist}
	self.bWaitResultMsg = true

	Lua_writeFile("FightReport/FightReport_",true,self.lastEndFightMsg)
	TFDirector:send(c2s.FIGHT_END_REQUEST, self.lastEndFightMsg)
end

function FightManager:LeaveFight()
	self:Reset()
	AlertManager:changeScene(SceneType.HOME,nil,TFSceneChangeType_PopBack)
	-- CCArmatureDataManager:purge()
end

--切换战斗两倍速
function FightManager:SwitchDoubleSpeed()
	local speed = 1.2
	if self.fightSpeed == 1 then
		self.fightSpeed = 2
		if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
			-- TFDirector:setFPS(GameConfig.FPS)
			me.Scheduler:setTimeScale(speed)
		else
			-- TFDirector:setFPS(GameConfig.FPS * 2)
			me.Scheduler:setTimeScale(speed)
		end
	else
		self.fightSpeed = 1
		-- TFDirector:setFPS(GameConfig.FPS)
		me.Scheduler:setTimeScale(1)
	end

	if self.isBattle then
		battleRoundMgr:OnFightSpeedChange()
	else
		fightRoleMgr:OnFightSpeedChange()
	end
end

function FightManager:backInitSpeed()
	me.Scheduler:setTimeScale(1)
end

function FightManager:IsRoundStart()
	if self.isBattle then
		return battleReplayMgr.nCurrRoundIndex > 0		
	end
	if self.isReplayFight then
		return fightReplayMgr.nCurrRoundIndex > 0
	else
		return fightRoundMgr.nCurrRoundIndex > 0
	end
end

function FightManager:GetCurrAction()
	if self.isBattle then
		return battleReplayMgr.currAction	
	end
	if self.isReplayFight then
		return fightReplayMgr.currAction
	else
		return fightRoundMgr.currAction
	end
end

function FightManager:OnActionEnd()
	TFDirector:currentScene():ZoomOut()
	
	if self.isBattle then
		battleReplayMgr:OnActionEnd()
		return 
	end
	if self.isReplayFight then
		fightReplayMgr:OnActionEnd()
	else
		fightRoundMgr:OnActionEnd()
	end
end

function FightManager:HaveBackAttackAction()

	if self.isBattle then
		return battleReplayMgr:HaveBackAttackAction()
	end
	if self.isReplayFight then
		return fightReplayMgr:HaveBackAttackAction()
	else
		return fightRoundMgr:HaveBackAttackAction()
	end
end

--战斗类型。1:pve推图；2:pve铜人阵；3:pvp豪杰榜；4:pvp天罡星 5:pve无量山 6:pvp大宝藏 7:pve摩柯崖 8:pve护驾
function FightManager:IsPVEFight()
	local fightType = self.fightBeginInfo.fighttype
	if fightType == 1 or fightType == 2 or fightType == 5 or fightType == 7 or fightType == 8 or fightType == 10 then
		return true
	else
		return false
	end
end

function FightManager:NeedShowText(bBenginTip)
	if self.isBattle then
		return false
	end
	if self.isReplayFight then
		return false
	end
	if self:FactorShowTest(bBenginTip) then
		return true
	end

	if self.fightBeginInfo.fighttype ~= 1 and self.fightBeginInfo.fighttype ~= 19 and self.fightBeginInfo.fighttype ~= 23 then
		return false
	end

	if self.fightBeginInfo.bSkillShowFight then
		return false
	end

	if self.fightBeginInfo.bGuideFight then
		return true
	end

	if bBenginTip then
		return MissionManager:isHaveBeginTip()
	else
		if self.fightResultInfo.result == 0 then
			return false
		end
		return MissionManager:isHaveEndTip()
	end
end


function FightManager:FactorShowTest( bBenginTip )
	if self.fightBeginInfo.fighttype ~= 17 then
		return false
	end
	if self.fightBeginInfo.bSkillShowFight then
		return false
	end

	if self.fightBeginInfo.bGuideFight then
		return true
	end
	if bBenginTip then
		return FactionManager:isHaveBeginTip()
	else
		if self.fightResultInfo.result == 0 then
			return false
		end
		return FactionManager:isHaveEndTip()
	end
end
function FightManager:isHasSecondFight()
	if self.fightBeginInfo.bSkillShowFight then
		return false
	end
	if self.fightBeginInfo.fighttype >= 19 and self.fightBeginInfo.fighttype <= 23 then
		return true
	end
	return false
end
--战斗类型。1:pve推图；2:pve铜人阵；3:pvp豪杰榜；4:pvp天罡星 5:pve无量山 6:pvp大宝藏 7:pve摩柯崖 8:pve护驾 10:世界boss 11:切磋 12:争霸赛
function FightManager:isNeedPause()
	if self.isBattle then
		return false
	end
	if self.isReplayFight then
		return false
	end

	if self.fightBeginInfo.bSkillShowFight then
		return false
	end
	if self.fightBeginInfo.fighttype == 12 then
		return false
	end
	if self.fightBeginInfo.fighttype == 17 then
		return false
	end
	if self.fightBeginInfo.fighttype == 18 then
		return false
	end
	if self.fightBeginInfo.bGuideFight then
		return false
	end
	if self.fightBeginInfo.fighttype == 19 then
		local mission = AdventureMissionManager:getMissionById(20002);
		if mission.starLevel ~= MissionManager.STARLEVEL0 then
			return true
		else
			return false
		end
	end
	local status = MissionManager:getMissionPassStatus(8);
	if status ~= MissionManager.STATUS_PASS then
		return false
	end
	return true
end

function FightManager:getFactionBossIndex()
	local data = GuildZoneCheckPointData:GetInfoByZoneIdAndPoint(HoushanManager.chapter ,HoushanManager.bossIndex)
	if data == nil  or data.boss_index == "" then
		print("boss 信息有误===",HoushanManager.chapter ,HoushanManager.bossIndex)
		return {}
	end
	if type(data.boss_index) == "number" then
		if data.boss_index <= 0 then
			return {}
		else
			return {data.boss_index}
		end
	end
	local boss_index = string.split(data.boss_index,"|")
	return boss_index
end
function FightManager:getBossIndex()
	if self.fightBeginInfo.fighttype == 17 then
		return self:getFactionBossIndex()
	end
	if self.fightBeginInfo.fighttype ~= 1 then
		return {}
	end

	if self.fightBeginInfo.bSkillShowFight then
		return {}
	end

	if self.fightBeginInfo.bGuideFight then
		return {}
	end
	local mission_info = MissionManager:getMissionById(MissionManager.attackMissionId)
	if mission_info == nil or mission_info.boss_index == "" then
		return {}
	end
	if type(mission_info.boss_index) == "number" then
		if mission_info.boss_index <= 0 then
			return {}
		else
			return {mission_info.boss_index}
		end
	end
	local boss_index = string.split(mission_info.boss_index,"|")
	return boss_index
end

function FightManager:FightBeginMsgHandle(event)
	print("FightBeginMsgHandle", event.data)
	self.fightBeginInfo = event.data

	if self.isFighting then
		return
	end

	-- modify by jin 20170321 --[
	package.loaded['lua.table.t_s_skill_display'] = nil
	SkillDisplayData = require('lua.table.t_s_skill_display')
	--]--

	self:BeginFight()
end

function FightManager:FightResultMsgHandle(event)
	print("FightResultMsgHandle", event.data)
	hideAllLoading()

	if self.bWaitResultMsg then
		self.bWaitResultMsg = false
		self.fightResultInfo = event.data
		AlertManager:changeScene(SceneType.FIGHTRESULT)
		if self.fightResultInfo.championsInfo then
			ZhengbaManager:updateChampionsInfo(self.fightResultInfo.championsInfo)
		end
	end

end


function FightManager:FightErrorHandle()
	-- print("FightManager:FightErrorHandle()")
	hideAllLoading()

	if self.bWaitResultMsg then
		self.bWaitResultMsg = false
		self.fightResultInfo = {}
		self.fightResultInfo.result = 0
		AlertManager:changeScene(SceneType.FIGHTRESULT)
	end
end

function FightManager:FightReplayMsgHandle(event)
	-- print("FightReplayMsgHandle", event.data)
	hideAllLoading()
	
	self.fightBeginInfo = event.data.beginInfo
	local liveList = {}
	for i=1,#event.data.fightData.livelist do
		local temp = event.data.fightData.livelist[i]
		liveList[i] = {temp.posindex,temp.currhp}
	end

	local roleList = self.fightBeginInfo.rolelist
	for k,roleInfo in pairs(roleList) do
		if roleInfo.posindex < 9 then
			roleInfo.posindex = roleInfo.posindex + 9
		else
			roleInfo.posindex = roleInfo.posindex - 9
		end
	end

	local hurtcountlist = {}
	if event.data.fightData.hurtcountlist then
		for i=1,#event.data.fightData.hurtcountlist do
			local temp = event.data.fightData.hurtcountlist[i]
			local pos = temp.posindex
			if temp.posindex < 9 then
				pos = temp.posindex + 9
			else
				pos = temp.posindex - 9
			end
			hurtcountlist[i] = {pos,temp.hurt}
		end
	else
		for k,v in pairs(self.fightBeginInfo.rolelist) do
			hurtcountlist[#hurtcountlist + 1] = {v.posindex , 0}
		end
	end

	self.lastEndFightMsg = {event.data.fightData.fighttype,event.data.fightData.win,event.data.fightData.actionlist,liveList, event.data.fightData.angerSelf,event.data.fightData.angerEnemy,hurtcountlist}


	self.fightResultInfo = {}
	if event.data.fightData.win then
		self.fightResultInfo.result = 0
	else
		self.fightResultInfo.result = 3
	end

	fightRoundMgr:AddReplayAction(event.data.fightData.actionlist)

	self:ReplayFight(true)
end


function FightManager:FightArenaReplayMsgHandle(event)
	print("FightReplayMsgHandle", event.data)
	hideAllLoading()
	
	self.fightBeginInfo = event.data.beginInfo
	local liveList = {}
	for i=1,#event.data.fightData.livelist do
		local temp = event.data.fightData.livelist[i]
		liveList[i] = {temp.posindex,temp.currhp}
	end


	local hurtcountlist = {}
	if event.data.fightData.hurtcountlist then
		for i=1,#event.data.fightData.hurtcountlist do
			local temp = event.data.fightData.hurtcountlist[i]
			hurtcountlist[i] = {temp.posindex,temp.hurt}
		end
	else
		for k,v in pairs(self.fightBeginInfo.rolelist) do
			hurtcountlist[#hurtcountlist + 1] = {v.posindex , 0}
		end
	end


	self.lastEndFightMsg = {event.data.fightData.fighttype,event.data.fightData.win,event.data.fightData.actionlist,liveList,event.data.fightData.angerSelf,event.data.fightData.angerEnemy,hurtcountlist}
	local roleList = self.fightBeginInfo.rolelist
	-- for k,roleInfo in pairs(roleList) do
	-- 	if roleInfo.posindex < 9 then
	-- 		roleInfo.posindex = roleInfo.posindex + 9
	-- 	else
	-- 		roleInfo.posindex = roleInfo.posindex - 9
	-- 	end
	-- end

	self.fightResultInfo = {}
	if event.data.fightData.win then
		self.fightResultInfo.result = 3
	else
		self.fightResultInfo.result = 0
	end

	fightRoundMgr:AddReplayActionNoChangPos(event.data.fightData.actionlist)

	self:ReplayFight(true)
end


function GetRoleAttr(attr, roleInfo)
	local baseAttrList = GetAttrByString(roleInfo.attribute)
	local baseAttr = baseAttrList[attr]
	baseAttr = baseAttr or 0

	baseAttr = math.floor(baseAttr)
	return baseAttr
end

function FightManager:BeginGuideFight(fightGuideInfo)
	self.fightBeginInfo = {}
	self.fightBeginInfo.bGuideFight = true
	self.fightBeginInfo.fighttype = 1
	self.fightBeginInfo.angerSelf = fightGuideInfo.role_anger
	self.fightBeginInfo.angerEnemy = fightGuideInfo.npc_anger
	self.fightBeginInfo.rolelist = {}

	local roleList = fightGuideInfo.role
    for index=1,#roleList do
    	local roleid = roleList[index]
    	if roleid ~= 0 then
	    	local fightRole = {}
	        local roleInfo = RoleData:objectByID(roleid)
			fightRole.typeid = 1
			fightRole.roleId = roleid
			fightRole.posindex = index-1
			fightRole.level = 1

			fightRole.attr = {}
			for attrIndex=1,17 do
				fightRole.attr[attrIndex] = GetRoleAttr(attrIndex, roleInfo)
			end
			fightRole.maxhp = fightRole.attr[1]

			fightRole.spellId = {}
			fightRole.spellId.skillId = roleInfo.skill
			fightRole.spellId.level = 1

			fightRole.passiveskill = {}

			local passiveskillList = string.split(roleInfo.passive_skill, ',')
			for i=1,#passiveskillList do
				if passiveskillList[i] ~= "" then
					fightRole.passiveskill[i] = {}
					fightRole.passiveskill[i].skillId = tonumber(passiveskillList[i])
					fightRole.passiveskill[i].level = 1
				end
			end

			self.fightBeginInfo.rolelist[fightRole.posindex] = fightRole
		end
    end

    local npcList = fightGuideInfo.npc
	for i=1,#npcList do
		local npcid = npcList[i]
    	if npcid ~= 0 then
	    	local fightRole = {}
	        local npcInfo = NPCData:objectByID(npcid)
	        fightRole.typeid = 2
			fightRole.roleId = npcid
			fightRole.posindex = 8+i
			fightRole.level = npcInfo.level

			fightRole.attr = {}
			for attrIndex=1,17 do
				fightRole.attr[attrIndex] = GetRoleAttr(attrIndex, npcInfo)
			end
			fightRole.maxhp = fightRole.attr[1]

			fightRole.spellId = {}
			fightRole.spellId.skillId = npcInfo.skill
			fightRole.spellId.level = npcInfo.level
			fightRole.passiveskill = {}

			self.fightBeginInfo.rolelist[fightRole.posindex] = fightRole
		end
	end

	self:BeginFight()
end

function FightManager:OnGuideFightEnd(win)
	local endTextShowEndCallBack = function(event)
		self:Reset()
		-- CCArmatureDataManager:purge()
		AlertManager:changeScene(SceneType.CREATEPLAYER)
		TFDirector:removeMEGlobalListener("MissionTipLayer.EVENT_SHOW_ENDTIP_COM")
	end
	TFDirector:addMEGlobalListener("MissionTipLayer.EVENT_SHOW_ENDTIP_COM",  endTextShowEndCallBack)

	local blackPanel = TFPanel:create()
	local nViewHeight = GameConfig.WS.height
    local nViewWidth = GameConfig.WS.width
	blackPanel:setSize(CCSize(nViewWidth,nViewHeight))
   	blackPanel:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID)
   	blackPanel:setBackGroundColor(ccc3(0,0,0))
   	blackPanel:setZOrder(100000)
	TFDirector:currentScene().fightUiLayer:addChild(blackPanel)

	local guideInfo = PlayerGuideManager:GetGuideFightInfo()
    MissionManager:showEndTipForMission(guideInfo.mission_id)
end

function FightManager:BeginSkillShowFight(typeid)
	self.fightBeginInfo = {}
	self.fightBeginInfo.bSkillShowFight = true
	self.fightBeginInfo.fighttype = 1
	self.fightBeginInfo.angerSelf = 0
	self.fightBeginInfo.angerEnemy = 0
	self.fightBeginInfo.rolelist = {}

	-- print("typeid = ", typeid)
	local skillRoleInfo = RoleData:objectByID(typeid)
	local cureRole = 0
	if skillRoleInfo.outline == 3 then
		cureRole = 2
	end
	-- print("skillRoleInfo = ", skillRoleInfo)

	local roleList = {0,0,0,0,typeid,0,cureRole,0,0}
    for index=1,#roleList do
    	local roleid = roleList[index]
    	if roleid ~= 0 then
	    	local fightRole = {}
	        local roleInfo = RoleData:objectByID(roleid)
			fightRole.typeid = 1
			fightRole.posindex = index-1
			fightRole.level = 1

			fightRole.roleId = roleid --

			fightRole.attr = {}
			for attrIndex=1,17 do
				fightRole.attr[attrIndex] = GetRoleAttr(attrIndex, roleInfo)
			end
			fightRole.maxhp = 10000-index
			fightRole.attr[5] = 100000

			fightRole.spellId = {}
			fightRole.spellId.skillId = roleInfo.skill
			fightRole.spellId.level = 1
			fightRole.passiveskill = {}

			self.fightBeginInfo.rolelist[fightRole.posindex] = fightRole
		end
    end

    local npcList = {45,0,0,45,45,45,45,0,0}
	for i=1,#npcList do
		local npcid = npcList[i]
    	if npcid ~= 0 then
	    	local fightRole = {}
	        local npcInfo = NPCData:objectByID(npcid)
			fightRole.typeid = 2
			fightRole.posindex = 8+i
			fightRole.level = 1

			fightRole.roleId = npcid--

			fightRole.attr = {}
			for attrIndex=1,17 do
				fightRole.attr[attrIndex] = GetRoleAttr(attrIndex, npcInfo)
			end
			fightRole.maxhp = fightRole.attr[1]

			fightRole.spellId = {}
			fightRole.spellId.skillId = 0
			fightRole.spellId.level = 0
			fightRole.passiveskill = {}

			self.fightBeginInfo.rolelist[fightRole.posindex] = fightRole
		end
	end

	self.fightSpeed = 1
	self:BeginFight()
end

function FightManager:ReplaySkillShow()
	fightRoleMgr:ClearAllRoleBuff()
	fightReplayMgr:ExecuteAction(1)
end

function FightManager:pause()
	self.ispause = true
	fightRoundMgr:pause()
end




function FightManager:BattleStartMsg(event)
	print("======================BattleStartMsg=====")
	self.fightBeginInfo = event.data
	self.fightResultInfo = {}
	self.fightResultInfo.round = {}
	self.fightResultInfo.packNum = 0
end
function FightManager:RoundsBattleMsg(event)
	hideAllLoading()
	local data = event.data
	-- print("data.totle",data)
	if data.rounds == nil then
		return
	end
	if self.fightResultInfo.packNum >= data.totle then
		return
	end

	for i=1,#data.rounds do
		self.fightResultInfo.round[#self.fightResultInfo.round + 1] = data.rounds[i]
	end
	if data.win then
		self.fightResultInfo.result = 3
	else
		self.fightResultInfo.result = 0
	end

	self.fightResultInfo.packNum = self.fightResultInfo.packNum + 1

	if self.fightResultInfo.packNum < data.totle then
		return
	end
	-- Lua_writeFile("battle/fightResultInfo",true,self.fightResultInfo.round)
	battleReplayMgr:AddReplayAction(self.fightResultInfo.round)

	if self.isFighting then
		return
	end
	self:battleHurtCount( self.fightResultInfo.round )



	-- 供读取输出的战斗序列使用
	-- local battleList = require("lua.table.battleList")
	-- battleReplayMgr:AddReplayAction(battleList)

	self.isBattle = true
	self.isReplayFight = true
	AlertManager:changeScene(SceneType.BATTLE, nil, TFSceneChangeType_PushBack)

	self.isFighting = true

	DeviceAdpter.skipMemoryWarning = true
end


function FightManager:battleHurtCount( roundList )
	local hurtList = {}
	print("--------------------------------------------------------->FightManager:battleHurtCount")
	for i=1,#self.fightBeginInfo.rolelist do
	print("--------------------------------------------------------->FightManager:battleHurtCount111111111")
		local role = self.fightBeginInfo.rolelist[i]
		hurtList[role.posindex] = 0
	end
	print("--------------------------------------------------------->FightManager:battleHurtCount2222222")

	local buffList = {}
	for i=1,#roundList do
		local round = roundList[i]
		if round.action then
			for j=1,#round.action do
				local action = round.action[j]
				if action.target then
					for k=1,#action.target do
						local target = action.target[k]
						if target.effectValue < 0 then
							hurtList[action.fromPos] = hurtList[action.fromPos] or 0
							hurtList[action.fromPos] = hurtList[action.fromPos] + math.abs(math.ceil(target.effectValue))
						end
						if target.newState then
							for l=1,#target.newState do
								local status = target.newState[l]
								buffList[target.position] = buffList[target.position] or {}
								buffList[target.position][status.stateId] = status.fromPos
							end
						end
						if target.stateCycle then
							for l=1,#target.stateCycle do
								local stateCycle = target.stateCycle[l]

								if stateCycle.effectValue < 0 and  buffList[stateCycle.position] and buffList[stateCycle.position][stateCycle.stateId] then
									local fromPos = buffList[stateCycle.position][stateCycle.stateId]
									hurtList[fromPos] = hurtList[fromPos] or 0
									hurtList[fromPos] = hurtList[fromPos] + math.abs(math.ceil(stateCycle.effectValue))
								end
							end
						end
					end
				end
				if action.newState then
					for l=1,#action.newState do
						local status = action.newState[l]
						buffList[action.fromPos] = buffList[action.fromPos] or {}
						buffList[action.fromPos][status.stateId] = status.fromPos
					end
				end
				if action.stateCycle then
					for l=1,#action.stateCycle do
						local stateCycle = action.stateCycle[l]

						if stateCycle.effectValue < 0 and  buffList[stateCycle.position] and buffList[stateCycle.position][stateCycle.stateId] then
							local fromPos = buffList[stateCycle.position][stateCycle.stateId]
							hurtList[fromPos] = hurtList[fromPos] or 0
							hurtList[fromPos] = hurtList[fromPos] + math.abs(math.ceil(stateCycle.effectValue))
						end
					end
				end
			end
		end
		if round.stateCycle then
			for l=1,#round.stateCycle do
				local stateCycle = round.stateCycle[l]
				if stateCycle.effectValue < 0 and  buffList[stateCycle.position] and buffList[stateCycle.position][stateCycle.stateId] then
					local fromPos = buffList[stateCycle.position][stateCycle.stateId]
					hurtList[fromPos] = hurtList[fromPos] or 0
					hurtList[fromPos] = hurtList[fromPos] + math.abs(math.ceil(stateCycle.effectValue))
				end
			end
		end
	end
	self.fightBeginInfo.hurtList = hurtList
end

function FightManager:BattleReplayMsg(event)
	hideAllLoading()
	
	self.fightBeginInfo = event.data.startMsg
	
	self.fightResultInfo = {}
	if event.data.roundMsg.win then
		self.fightResultInfo.result = 3
	else
		self.fightResultInfo.result = 0
	end
	-- self.fightResultInfo = event.data.result
	-- if self.fightResultInfo.win == false then
	-- 	self.fightResultInfo.result = 0
	-- end


	battleReplayMgr:AddReplayAction(event.data.roundMsg.round)


	if self.isFighting then
		return
	end

	self.isBattle = true
	self.isReplayFight = true
	AlertManager:changeScene(SceneType.BATTLE, nil, TFSceneChangeType_PushBack)

	self.isFighting = true

	DeviceAdpter.skipMemoryWarning = true
end

function FightManager:EndReplayBattle()
	print("self.isFighting",self.isFighting,self.isBattle)
	if self.isFighting and self.isBattle then
		self.isFighting = false
		

		DeviceAdpter.skipMemoryWarning = false

		if self.end_timerID then
			TFDirector:removeTimer(self.end_timerID)
			self.end_timerID = nil
		end
		self.end_timerID = TFDirector:addTimer(1, 1, nil, 
		function()
			TFDirector:removeTimer(self.end_timerID)
			self.end_timerID = nil
			self.isBattle = false
			AlertManager:changeScene(SceneType.BATTLERESULT)
		end)
	end
end

function FightManager:BattleResultMsgHandle(event)
	-- print("FightResultMsgHandle", event.data)
	hideAllLoading()
	self.fightResultInfo = event.data
	if self.fightResultInfo.win == false then
		self.fightResultInfo.result = 0
	end

end

function FightManager:getBattleRoundIndex()
	return battleReplayMgr.nCurrRoundIndex
end


function FightManager:GetAttackOrder()
	return battleReplayMgr:GetAttackOrder()
end


function FightManager:ReplayBattle(bRecordFight)
	if self.isFighting then
		return
	end
	self.isReplayFight = true
	self.isBattle = true

	battleReplayMgr:clear()
	if bRecordFight then
		AlertManager:changeScene(SceneType.BATTLE, nil, TFSceneChangeType_PushBack)
	else
		AlertManager:changeScene(SceneType.BATTLE)
	end
	
	self.isFighting = true

	DeviceAdpter.skipMemoryWarning = true
end


function FightManager:CleanBattle()
	battleReplayMgr:dispose()
	battleRoundMgr:dispose()
	require("lua.logic.battle.BattleRoundManager"):dispose()
	-- fightReplayMgr:dispose()
	-- fightRoleMgr:dispose()
end

function FightManager:openHurtCount()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.fight.Shanghaitongji",AlertManager.BLOCK_AND_GRAY)
	-- AlertManager:addLayer(layer)
	layer.toScene = TFDirector:currentScene()
	AlertManager:show()
end

function FightManager:openBattleHurtCount()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.battle.BattleHurtCount",AlertManager.BLOCK_AND_GRAY)
	-- AlertManager:addLayer(layer)
	layer.toScene = TFDirector:currentScene()
	AlertManager:show()
end

return FightManager:new()