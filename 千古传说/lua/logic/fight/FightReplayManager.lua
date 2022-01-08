--
-- Author: Zippo
-- Date: 2013-12-05 18:13:41
--

local fightRoleMgr  = require("lua.logic.fight.FightRoleManager")
local fightRoundMgr  = require("lua.logic.fight.FightRoundManager")

local FightReplayManager = {}

function FightReplayManager:dispose()
	if self.currAction ~= nil then
		self.currAction:dispose()
		self.currAction = nil
	end
end

function FightReplayManager:OnRoundChange(roundIndex)
	self.nCurrRoundIndex = roundIndex
	TFDirector:currentScene().fightUiLayer:SetCurrRoundNum(roundIndex)
end

function FightReplayManager:ExecuteAction(actionIndex)
	local nActionCount = fightRoundMgr.actionList:length()
	if actionIndex > nActionCount then
		if fightRoundMgr.bOverTime then
			TFDirector:currentScene().fightUiLayer:PlayOverTimeEffect()
		else
			FightManager:EndFight()
		end
		return
	end

	local actionInfo = fightRoundMgr.actionList:objectAt(actionIndex)
	if actionInfo.roundIndex ~= self.nCurrRoundIndex then
		self:OnRoundChange(actionInfo.roundIndex)
		fightRoleMgr:OnRoundStart()
	end

	self.currAction = require("lua.logic.fight.FightAction"):new(actionInfo)
	self.nCurrActionIndex = actionIndex
	self.currAction:Execute()
end

function FightReplayManager:OnActionEnd()
	TFDirector:currentScene().mapLayer:ChangeDark(false)

	if self.currAction ~= nil and self.currAction.bBackAttack ~= true then
		fightRoleMgr:OnActionEnd()
	end

	self.currAction:dispose()
	self.currAction = nil

	self:ExecuteAction(self.nCurrActionIndex+1)
end

--下个action是否是反击action
function FightReplayManager:HaveBackAttackAction()
	local actionInfo = fightRoundMgr.actionList:objectAt(self.nCurrActionIndex+1)
	if actionInfo == nil then
		return false
	else
		return actionInfo.bBackAttack
	end
end

return FightReplayManager