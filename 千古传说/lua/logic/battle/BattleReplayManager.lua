--
-- Author: Zippo
-- Date: 2013-12-05 18:13:41
--

local battleRoleMgr  = require("lua.logic.battle.BattleRoleManager")
local battleRoundMgr  = require("lua.logic.battle.BattleRoundManager")

local BattleReplayManager = {}

function BattleReplayManager:dispose()
	if self.currAction ~= nil then
		self.currAction:dispose()
		self.currAction = nil
	end
end


function BattleReplayManager:OnRoundChange(roundIndex)
	self.nCurrRoundIndex = roundIndex
	TFDirector:currentScene().fightUiLayer:SetCurrRoundNum(roundIndex)
end

function BattleReplayManager:ExecuteAction()

	local battleActionList = self.battleRoundList[self.nCurrRoundIndex]
	if self.nCurrActionIndex > #battleActionList.action then
		self.nCurrRoundIndex = self.nCurrRoundIndex + 1
		self.nCurrActionIndex = 1
		if self.nCurrRoundIndex > #self.battleRoundList then
			FightManager:EndFight()
			return
		end


		local showTable = {}
		if battleActionList.stateCycle then
			for i=1,#battleActionList.stateCycle do
				local stateCycleEffect = battleActionList.stateCycle[i]
				local targetRole = battleRoleMgr:GetRoleByGirdIndex(stateCycleEffect.position)
				if targetRole then
					local hurt = targetRole:ShowHpChangeBuff(stateCycleEffect)
					showTable[stateCycleEffect.position] = showTable[stateCycleEffect.position] or 0
					showTable[stateCycleEffect.position] = showTable[stateCycleEffect.position] + hurt
				end
			end
		end
		for k,v in pairs(showTable) do
			local targetRole = battleRoleMgr:GetRoleByGirdIndex(k)
			if targetRole then
				targetRole:ShowFightText("", v)
			end
		end

		if battleActionList.lostState then
			for i=1,#battleActionList.lostState do
				local state = battleActionList.lostState[i]
				local target = battleRoleMgr:GetRoleByGirdIndex(state.position)
				if target and state.repeatNum == 0 then
					target:RemoveBuffById(state.stateId)
				end
			end
		end
		battleActionList = self.battleRoundList[self.nCurrRoundIndex]
	end
	if self.nCurrActionIndex == 1 then
		self:OnRoundChange(self.nCurrRoundIndex)

		battleRoleMgr:OnRoundStart()
	end

	local actionInfo = battleActionList.action[self.nCurrActionIndex]

	if actionInfo.type == 5 then
		self:addTargetBuff(actionInfo)
		self.nCurrActionIndex = self.nCurrActionIndex + 1
		self:ExecuteAction()
		return
	end

	if self.nCurrActionIndex < #battleActionList.action and battleActionList.action[self.nCurrActionIndex+1].type == 3 then
		actionInfo.hasTrrigerBackAttack = true
	end


	self.currAction = require("lua.logic.battle.BattleAction"):new(actionInfo)
	self.currAction:Execute()
end

function BattleReplayManager:OnActionEnd()
	TFDirector:currentScene().mapLayer:ChangeDark(false)

	if  self.currAction ~= nil and self.currAction.actionInfo ~= nil then
		self.currAction:addBuffer(2)
		self.currAction:removeBuffer()
		self.currAction:stateCycleUpdate()
	end

	if self.currAction ~= nil and self.currAction.bBackAttack ~= true then
		battleRoleMgr:OnActionEnd()
	end

	self.currAction:dispose()
	self.currAction = nil
	self.nCurrActionIndex = self.nCurrActionIndex + 1
	self:ExecuteAction()
end

--下个action是否是反击action
function BattleReplayManager:HaveBackAttackAction()
	local battleActionList = self.battleRoundList[self.nCurrRoundIndex]
	if battleActionList == nil then
		return false
	end
	local actionInfo = battleActionList.action[self.nCurrActionIndex+1]
	if actionInfo == nil then
		return false
	else
		return actionInfo.type == 3
	end
end

--[[
//回合
message BattleRound{
	required int32 roundIndex = 1;				//回合索引，从1~N
	repeated BattleAction action = 2; 			//回合内动作列表
	repeated StateCycleEffect stateCycle = 6;	//状态周期性影响，这里只可能是回合触发类型持续类型是回合的状态在回合结束时触发
}
]]
function BattleReplayManager:AddReplayAction(replayList)
	self.nCurrActionIndex = 1
	self.nCurrRoundIndex = 1

	self.battleRoundList = {}
	if replayList == nil then
		return
	end
	self.battleRoundList = clone(replayList)
end

function BattleReplayManager:clear()
	self.nCurrActionIndex = 1
	self.nCurrRoundIndex = 1
end


function BattleReplayManager:GetAttackOrder()
	local maxNum = 5
	local orderList = {}


	-- if self.currAction ~= nil and self.currAction.actionInfo.type ~= 3 then
	-- 	orderList[1] = {}
	-- 	orderList[1].fightRole = self.currAction.attackerRole
	-- 	orderList[1].bManualAction = self.currAction.actionInfo.type == 2
	-- end

	local battleActionList = self.battleRoundList[self.nCurrRoundIndex]
	if battleActionList == nil then
		return {}
	end
	for i=self.nCurrActionIndex,#battleActionList.action do
		local actionInfo = battleActionList.action[i]
		local attackRole = battleRoleMgr:GetRoleByGirdIndex(actionInfo.fromPos)
		local num = #orderList
		if actionInfo.type ~= 3 and attackRole ~= nil and attackRole:IsLive() and num < maxNum then
			orderList[num+1] = {}
			orderList[num+1].fightRole = attackRole
			orderList[num+1].bManualAction = actionInfo.type == 2
		end
	end

	return orderList

end



function BattleReplayManager:addTargetBuff(actionInfo)
	local nTargetCount = #actionInfo.target
	for i=1,nTargetCount do
		local targetInfo = actionInfo.target[i]
		local targetRole = battleRoleMgr:GetRoleByGirdIndex(targetInfo.position)

		if targetInfo.newState then
			for i=1,#targetInfo.newState do
				targetRole:AddBuff(targetInfo.newState[i].stateId,targetInfo.newState[i].stateLevel,0)
			end
		end
		if targetInfo.lostState then
			for i=1,#targetInfo.lostState do
				local state = targetInfo.lostState[i]
				local target = battleRoleMgr:GetRoleByGirdIndex(state.position)
				if target and state.repeatNum == 0 then
					target:RemoveBuffById(state.stateId)
				end
			end
		end
	end

	if actionInfo.newState == nil then
		return
	end
	
	local attackerRole = battleRoleMgr:GetRoleByGirdIndex(actionInfo.fromPos)
	for i=1,#actionInfo.newState  do
		local state = actionInfo.newState[i]
		local buffInfo = SkillBufferData:objectByID(state.stateId)
		if buffInfo ~= nil  then
			attackerRole:AddBuff(state.stateId,state.stateLevel,0)
		end
	end

end


return BattleReplayManager