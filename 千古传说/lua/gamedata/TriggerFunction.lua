local tTriggerFunction = {}

-- 等级满足触发
function tTriggerFunction:getLevel( conditions )
	local teamLev = MainPlayer:getLevel()
	if conditions.level and teamLev ~= conditions.level then
		return false
	end
	return true
end
-- 等级满足触发
function tTriggerFunction:getMinLevel( conditions )
	local teamLev = MainPlayer:getLevel()
	if conditions.minLevel and teamLev < conditions.minLevel then
		return false
	end
	return true
end
-- 等级满足触发
function tTriggerFunction:getMaxLevel( conditions )
	local teamLev = MainPlayer:getLevel()
	if conditions.maxLevel and teamLev > conditions.maxLevel then
		return false
	end
	return true
end

-- 步骤满足触发
function tTriggerFunction:getStep( conditions )
	-- local guideStep = MainPlayer:getGuideStep()
	-- if conditions.Step and guideStep ~= conditions.Step then
	-- 	return false
	-- end
	-- return true
	if conditions.step then
		return PlayerGuideManager:isGuideFunctionOpen(conditions.step)
	end
	return true
end

-- 最大上阵人数满足触发
function tTriggerFunction:getMaxArmyRole( conditions )
	local armyRole = StrategyManager:getFightRoleNum()
	if conditions.maxArmyRole and armyRole > conditions.maxArmyRole then
		return false
	end
	return true
end

-- 最少上阵人数满足触发
function tTriggerFunction:getMinArmyRole( conditions )
	local armyRole = StrategyManager:getFightRoleNum()
	if conditions.minArmyRole and armyRole < conditions.minArmyRole then
		return false
	end
	return true
end

-- 步骤满足跳过
function tTriggerFunction:getMaxStep( conditions )
	-- local guideStep = MainPlayer:getGuideStep()
	-- if conditions.Step and guideStep ~= conditions.Step then
	-- 	return false
	-- end
	-- return true
	if conditions.maxStep then
		return not PlayerGuideManager:isGuideFunctionOpen(conditions.maxStep)
	end
	return true
end

-- 装备秘籍数量全满
function tTriggerFunction:getMartial( conditions )
	local armyRole = StrategyManager:getFightRoleNum()
	if conditions.martial and conditions.martial == false then
		return false
	end
	if conditions.martial and CardRoleManager:isHaveEquipBookAll() == false then
		return false
	end
	return true
end

function tTriggerFunction:getCurMission( conditions )
	if conditions.curMission then
		local status = MissionManager:getMissionPassStatus(conditions.curMission);
		if status ~= MissionManager.STATUS_CUR then
			return false
		end
	end
	return true
end
function tTriggerFunction:getCloseMission( conditions )
	if conditions.closeMission then
		local status = MissionManager:getMissionPassStatus(conditions.closeMission);
		if status ~= MissionManager.STATUS_CLOSE then
			return false
		end
	end
	return true
end
function tTriggerFunction:getPassMission( conditions )
	if conditions.passMission then
		local status = MissionManager:getMissionPassStatus(conditions.passMission);
		if status ~= MissionManager.STATUS_PASS then
			return false
		end
	end
	return true
end

-- 最大拥有人数满足触发
function tTriggerFunction:getMaxRoleNum( conditions )
	local roleNum = CardRoleManager:getRoleNum()
	if conditions.maxRoleNum and roleNum > conditions.maxRoleNum then
		return false
	end
	return true
end

-- 最低拥有人数满足触发
function tTriggerFunction:getMinRoleNum( conditions )
	local roleNum = CardRoleManager:getRoleNum()
	if conditions.minRoleNum and roleNum < conditions.minRoleNum then
		return false
	end
	return true
end

-- 拥有人数满足触发
function tTriggerFunction:getRoleNum( conditions )
	local roleNum = CardRoleManager:getRoleNum()
	if conditions.roleNum and roleNum ~= conditions.roleNum then
		return false
	end
	return true
end
function tTriggerFunction:getCycle( conditions )
	return true
end
function tTriggerFunction:getArmyIndexHas( conditions )
	if conditions.armyIndexHas then
		if StrategyManager:getRoleByIndex(conditions.armyIndexHas) == nil then
			return false
		end
	end
	return true
end
function tTriggerFunction:getArmyIndexNo( conditions )
	if conditions.armyIndexNo then
		if StrategyManager:getRoleByIndex(conditions.armyIndexNo) ~= nil then
			return false
		end
	end
	return true
end
function tTriggerFunction:getMaxTili( conditions )
	if conditions.tiliMax then
		if MainPlayer:GetChallengeTimesInfo(EnumRecoverableResType.PUSH_MAP):getLeftChallengeTimes() > conditions.tiliMax then
			return false
		end
	end
	return true
end
function tTriggerFunction:getMinTili( conditions )
	if conditions.tiliMin then
		if MainPlayer:GetChallengeTimesInfo(EnumRecoverableResType.PUSH_MAP):getLeftChallengeTimes() < conditions.tiliMin then
			return false
		end
	end
	return true
end
function tTriggerFunction:getSpecial( conditions )
	if conditions.special then
		return false
	end
	return true
end
function tTriggerFunction:notUseEquipment( conditions )
	if conditions.notUseEquip then
		if conditions.notUseEquip > 6 or conditions.notUseEquip < 0 then
			conditions.notUseEquip = 0
		end
		local equipList = EquipmentManager:GetEquipByTypeAndUsed(conditions.notUseEquip,true,true)
		if equipList:length() == 0 then
			return true
		end
		return false
	end
	return true
end
function tTriggerFunction:useEquipment( conditions )
	if conditions.useEquip then
		if conditions.useEquip > 6 or conditions.useEquip < 0 then
			conditions.useEquip = 0
		end
		local equipList = EquipmentManager:GetEquipByTypeAndUsed(conditions.useEquip,true,true)
		if equipList:length() == 0 then
			return true
		end
		return false
	end
	return true
end
function tTriggerFunction:hasEquipment( conditions )
	if conditions.hasEquip then
		if conditions.hasEquip > 6 or conditions.hasEquip < 0 then
			conditions.hasEquip = 0
		end
		local equipList = EquipmentManager:GetEquipByType(conditions.hasEquip,true,true)
		if equipList:length() == 0 then
			return false
		end
		return true
	end
	return true
end
--七日是否过期
function tTriggerFunction:getSevenDay( conditions )
	if conditions.sevenDay then
		local status = SevenDaysManager:sevenDaysOpenSatus()
		-- 判断在线奖励是否过期
		if status == 0 then
			return false
		end
	end
	return true
end
return tTriggerFunction