--
-- Author: Zippo
-- Date: 2014-7-17 
--

local fightRoleMgr = require("lua.logic.fight.FightRoleManager")
local fightRoundMgr = require("lua.logic.fight.FightRoundManager")

local FightAI = {}

function FightAI:Start()
	if self.updateTimerID ~= nil then
		return
	end
	
	if FightManager.isReplayFight then
		return
	end

	local updateTime = 1000
	self.updateTimerID = TFDirector:addTimer(updateTime, -1, nil, 
	function() 
		self:Update(updateTime)
	end)

	self.roleList = {}
	self.roleList[1] = TFArray:new()
	self.roleList[2] = TFArray:new()
end

function FightAI:dispose()
	if self.updateTimerID ~= nil then
		TFDirector:removeTimer(self.updateTimerID)
		self.updateTimerID = nil
	end
end

function FightAI:Update(updateTime)
	self:UpdateAI(true, updateTime)

	if FightManager.isAutoFight then
		self:UpdateAI(false, updateTime)
	end
	fightRoleMgr:isAbnormal()
	self:UpdateEnemySkillCD(updateTime)
end

function FightAI:UpdateEnemySkillCD(updateTime)
	local liveList = fightRoleMgr:GetAllLiveRole(true)
	local liveNum = liveList:length()
	for i=1,liveNum do
		local role = liveList:objectAt(i)
		if role.skillCD > 0 then
			role.skillCD = role.skillCD - updateTime * FightManager.fightSpeed
			if role.skillCD < 0 then
				role.skillCD = 0
			end
		end
	end
end

function FightAI:getRoleList( bEnemy )
	if bEnemy == true then
		return self.roleList[2]
	else
		return self.roleList[1]
	end
end

function FightAI:GetTriggerAnger(bEnemy)
	local maxAnger = 0
	local liveList = fightRoleMgr:GetAllLiveRole(bEnemy)
	local liveNum = liveList:length()
	for i=1,liveNum do
		local role = liveList:objectAt(i)
		local roleSkillAnger = role:GetSkillAnger()
		if role.skillID.skillId > 0 and role.skillCD <= 0 and role:HaveForbidManualSkillBuff() == false and roleSkillAnger > maxAnger then
			maxAnger = roleSkillAnger
		end
	end

	return maxAnger
end

local priority_tbl = {5,2,1,3}
function cmpRoleListFunc(role1, role2)
	local priority_1 = FightAI.getPrioritySpecial(role1)
	local priority_2 = FightAI.getPrioritySpecial(role2)
	if priority_1 < priority_2 then
        return true
    elseif priority_1 == priority_2 then
		if role1:GetAttrNum(EnumAttributeType.Agility) > role2:GetAttrNum(EnumAttributeType.Agility) then
			return true
		end
        return false
    end
    return false
end

function FightAI.getPriorityFangyu( role )
	local priority = priority_tbl[role.profession]
	-- local skillId = role.skillID
	-- local skillInfo = BaseDataManager:GetSkillBaseInfo(skillId)
	if role:GetActiveSkillType() == 8 then
		return priority
	end
	local manualActionNum = role.manualActionNum or 0
	if manualActionNum%2 == 0 then
		return priority
	else
		return 6
	end
end
function FightAI.getPrioritySpecial( role )
	local priority = priority_tbl[role.profession]
	if role.profession == 2 then
		return FightAI.getPriorityFangyu(role)
	end
	if role.profession ~= 3 then
		return priority
	end
	local skillId = role.skillID
	local skillInfo = BaseDataManager:GetSkillBaseInfo(skillId)
	if skillInfo == nil then
		return priority
	end
	if skillInfo.type == 2 then
		return priority
	else
		return 4
	end
end

function FightAI:addToRoleList( bEnemy )
	--local roleList = self:getRoleList(bEnemy)
	local roleList = fightRoleMgr:GetAllLiveRole(bEnemy)
	roleList:sort(cmpRoleListFunc)
	if bEnemy == true then
		self.roleList[2] = roleList
	else
		self.roleList[1] = roleList
	end
end


function FightAI:UpdateAI(bEnemy, updateTime)
	local roleList = self:getRoleList(bEnemy)
	if roleList:length() == 0 then
		self:addToRoleList(bEnemy)
		roleList = self:getRoleList(bEnemy)
	end

	local role = roleList:front()
	if role == nil then
		roleList:popFront()
		return
	end
	if role:IsAlive() == false then
		roleList:popFront()
		return
	end
	print(role.logicInfo.name.."开始技能AI")
	if role:GetActiveSkillType() == 2 then
		if self:ReleaseCureSkill(bEnemy) == false then
			print("全角色血量高于70%")
			roleList:popFront()
			return
		end
	end
	if role.profession == 4 then
		if self:NeedReleaseBadBuffSkill(role) ==false then
			print("对面控制超过一半")
			roleList:popFront()
			return
		end
	end

	local currAnger = fightRoleMgr.selfAnger
	if bEnemy then
		currAnger = fightRoleMgr.enemyAnger
	end
	local roleSkillAnger = role:GetSkillAnger()
	if currAnger < roleSkillAnger then
		print("怒气不足，返回")
		return
	end
	-- print("roleList  length = ",roleList:length())
	roleList:popFront()
	-- print("roleList  length = ",roleList:length())

	if role:GetActiveSkillType() == 8 then
		if self:ReleaseGoodBufSkill(role) == false then
			return
		end
	end

	if role:HaveForbidAttackBuff() then
		print("角色不可攻击跳过")
		return
	end

	if role.skillID.skillId > 0 and role.skillCD > 0 then
		print("技能cd中 跳过")
		return
	end

	print(role.logicInfo.name.."加入技能队列")
	fightRoundMgr:AddManualAction(role)

end

function FightAI:UpdateSelfAngerAI()

	for k,role in pairs(fightRoleMgr.map) do
		local bValidRole = true
		if role:HaveFrozenBuff() then
			bValidRole = false
		end

		if bValidRole and role:IsLive() then
			local skillInfo = role:getUseSelfAngerSkill()
			if skillInfo and role.role_anger >= skillInfo.trigger_anger then
				if role:HaveForbidAttackBuff() == false then
					fightRoundMgr:AddAngerManualAction(role)
				end
			end
		end
	end
end


function FightAI:ReleaseCureSkill(bEnemy)
	local liveList = fightRoleMgr:GetAllLiveRole(bEnemy)
	local liveNum = liveList:length()
	for i=1,liveNum do
		local role = liveList:objectAt(i)
		if role.currHp/role.logicInfo.maxhp < 0.7 then
			print(role.logicInfo.name.."角色血量低于70%")
			return true
		end
	end
	return false
end

function FightAI:ReleaseGoodBufSkill(role)
	if role.skillID.skillId == 0 then
		return false
	end
	local skillInfo = SkillLevelData:objectByID(role.skillID)
	local buff_id = skillInfo.buff_id
	if role:HaveBuff(buff_id) then
		print("已经拥有buff  buff_id ==",buff_id)
		return false
	end
	return true
end

function FightAI:NeedReleaseBadBuffSkill( role )
	if role.profession ~= 4 then
		return true
	end
	local skillInfo = SkillLevelData:objectByID(role.skillID)
	local buff_id = skillInfo.buff_id or 0
	if buff_id == 0 then
		return true
	end
	local buffInfo =SkillLevelData:getBuffInfo( buff_id , role.skillID.level)
	local isEnmey = role.logicInfo.bEnemyRole
	local totalnum ,hasBuffNum = fightRoleMgr:getHasBuffNum(not isEnmey,buffInfo.type)
	if hasBuffNum > totalnum/2 then
		return false
	end
	return true
end

-- function FightAI:UpdateAI(bEnemy, updateTime)
-- 	local triggerAnger = self:GetTriggerAnger(bEnemy)
-- 	local currAnger = fightRoleMgr.selfAnger
-- 	if bEnemy then
-- 		currAnger = fightRoleMgr.enemyAnger
-- 	end

-- 	if currAnger < triggerAnger then
-- 		return
-- 	end

-- 	if fightRoleMgr:HaveBadBuffRole(bEnemy) then
-- 		if self:ReleaseJinghuaSkill(bEnemy) then
-- 			return
-- 		end
-- 	end

-- 	if fightRoleMgr:HaveNeedCureRole(bEnemy) then
-- 		if self:ReleaseCureSkill(bEnemy) then
-- 			return
-- 		end
-- 	end

-- 	if self:ReleaseFrozenSkill(bEnemy) then
-- 		return
-- 	end

-- 	if self:ReleaseScreenAttackSkill(bEnemy) then
-- 		return
-- 	end

-- 	if self:ReleaseRowAttackSkill(bEnemy) then
-- 		return
-- 	end

-- 	if self:ReleaseColumnAttackSkill(bEnemy) then
-- 		return
-- 	end

-- 	self:ReleaseAttackSkill(bEnemy)
-- end

-- function cmpSkillAngerFun(role1, role2)
-- 	if role1:GetSkillAnger() < role2:GetSkillAnger() then
--         return false
--     else
--         return true
--     end
-- end

-- function FightAI:ReleaseJinghuaSkill(bEnemy)
-- 	local liveList = fightRoleMgr:GetAllLiveRole(bEnemy)
-- 	liveList:sort(cmpSkillAngerFun)
-- 	local liveNum = liveList:length()
-- 	for i=1,liveNum do
-- 		local role = liveList:objectAt(i)
-- 		if role:GetActiveSkillType() == 3 and fightRoundMgr:AddManualAction(role) then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end

-- function FightAI:ReleaseCureSkill(bEnemy)
-- 	local liveList = fightRoleMgr:GetAllLiveRole(bEnemy)
-- 	liveList:sort(cmpSkillAngerFun)
-- 	local liveNum = liveList:length()
-- 	for i=1,liveNum do
-- 		local role = liveList:objectAt(i)
-- 		if role:GetActiveSkillType() == 2 and fightRoundMgr:AddManualAction(role) then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end

-- function FightAI:ReleaseFrozenSkill(bEnemy)
-- 	local enemyLiveList = fightRoleMgr:GetAllLiveRole(not bEnemy)
-- 	if enemyLiveList:length() <= 1 then
-- 		return false
-- 	end

-- 	local liveList = fightRoleMgr:GetAllLiveRole(bEnemy)
-- 	liveList:sort(cmpSkillAngerFun)
-- 	local liveNum = liveList:length()
-- 	for i=1,liveNum do
-- 		local role = liveList:objectAt(i)
-- 		if role.profession == 4 and fightRoundMgr:AddManualAction(role) then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end

-- function FightAI:ReleaseScreenAttackSkill(bEnemy)
-- 	local enemyLiveList = fightRoleMgr:GetAllLiveRole(not bEnemy)
-- 	if enemyLiveList:length() < 3 then
-- 		return false
-- 	end

-- 	local liveList = fightRoleMgr:GetAllLiveRole(bEnemy)
-- 	liveList:sort(cmpSkillAngerFun)
-- 	local liveNum = liveList:length()
-- 	for i=1,liveNum do
-- 		local role = liveList:objectAt(i)
-- 		if role:GetActiveSkillType() == 1 and role:GetActiveSkillTargetType() == 2 and fightRoundMgr:AddManualAction(role) then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end

-- function FightAI:ReleaseRowAttackSkill(bEnemy)
-- 	local liveList = fightRoleMgr:GetAllLiveRole(bEnemy)
-- 	liveList:sort(cmpSkillAngerFun)
-- 	local liveNum = liveList:length()
-- 	for i=1,liveNum do
-- 		local role = liveList:objectAt(i)
-- 		if role.skillID.skillId > 0 and role:GetActiveSkillType() == 1 and role:GetActiveSkillTargetType() == 3 then
-- 			local targetList = fightRoundMgr:GetActionTargetInfo(role, role.skillID)
-- 			if targetList ~= nil and #targetList >= 2 and fightRoundMgr:AddManualAction(role) then
-- 				return true
-- 			end
-- 		end
-- 	end
-- 	return false
-- end

-- function FightAI:ReleaseColumnAttackSkill(bEnemy)
-- 	local liveList = fightRoleMgr:GetAllLiveRole(bEnemy)
-- 	liveList:sort(cmpSkillAngerFun)
-- 	local liveNum = liveList:length()
-- 	for i=1,liveNum do
-- 		local role = liveList:objectAt(i)
-- 		if role.skillID.skillId > 0 and role:GetActiveSkillType() == 1 and role:GetActiveSkillTargetType() == 4 then
-- 			local targetList = fightRoundMgr:GetActionTargetInfo(role, role.skillID)
-- 			if  targetList ~= nil and #targetList >= 2 and fightRoundMgr:AddManualAction(role) then
-- 				return true
-- 			end
-- 		end
-- 	end
-- 	return false
-- end

-- function FightAI:ReleaseAttackSkill(bEnemy)
-- 	local liveList = fightRoleMgr:GetAllLiveRole(bEnemy)
-- 	liveList:sort(cmpSkillAngerFun)
-- 	local liveNum = liveList:length()
-- 	for i=1,liveNum do
-- 		local role = liveList:objectAt(i)
-- 		if fightRoundMgr:AddManualAction(role) then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end

function FightAI:pause()
	if self.updateTimerID then
		TFDirector:stopTimer(self.updateTimerID)
	end	
end
return FightAI