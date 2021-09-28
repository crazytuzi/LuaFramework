-- AICell
AICell =BaseClass()
AICell.AIStop = false

function AICell:__init(determinationId, controlTarget, parent)
	self.aiVo = AICellVo.New(tonumber(determinationId))
	self.parent = parent
	self.curCd = 0

	self.controlTarget = controlTarget
	self.fightTarget = nil
end

function AICell:SetFightTarget(fightTarget)
	self.fightTarget = fightTarget
end

function AICell:Update()
	if not self:IsCding() then
		local t = self.aiVo.determinationData.decisionType
		local ct = AICellVo.DecisionType
		if t == ct.No then --无条件
			self.parent:PushToReadyList(self)
		elseif t == ct.SelfHpLess then --自身血量低于%
			if self.controlTarget.vo.hp < self.aiVo.determinationData.decisionValue then
				self.parent:PushToReadyList(self)
			end
		elseif t == ct.PlayerHpLess then --玩家血量低于%
			if self.fightTarget and self.fightTarget.vo.hp < self.aiVo.determinationData.decisionValue then
				self.parent:PushToReadyList(self)
			end
		elseif t == ct.MonsterHpLess then --怪物血量低于%
			
			
		elseif t == ct.DistanceLess then --与玩家距离小于
			if self.fightTarget and MapUtil.GetDistanceByV3(self.controlTarget.transform.position, self.fightTarget.transform.position) < self.aiVo.determinationData.decisionValue then
				self.parent:PushToReadyList(self)
			end
		elseif t == ct.DistanceGreater then --与玩家距离大于
			if self.fightTarget and MapUtil.GetDistanceByV3(self.controlTarget.transform.position, self.fightTarget.transform.position) > self.aiVo.determinationData.decisionValue then
				self.parent:PushToReadyList(self)
			end
		end
	end
	self.curCd = self.curCd - Time.deltaTime
end

function AICell:StartRunCd()
	self.curCd = self.aiVo.determinationData.actionCd
end

function AICell:IsCding()
	return self.curCd > 0
end

function AICell:AIExcute()
	if AICell.AIStop then return end
	local executionDate = self.aiVo.executionData
	self:AIExecutionHandler(executionDate)
end

function AICell:AIExecutionHandler(executionDate)
	if not executionDate then return end
	local skillVo = nil
	if executionDate.targetType == AICellVo.TargetType.Player then --玩家
		local targetChoice = executionDate.targetChoice
		local TargetChoice = AICellVo.TargetChoice
		local actionType = executionDate.actionType
		local ActionType = AICellVo.ActionType
		if targetChoice == TargetChoice.NearSelect then --就近选取
			if actionType == ActionType.No then --释放技能
				local v = executionDate.actionValue[1]
				skillVo = SkillManager.GetStaticSkillVo(v)
				self.controlTarget:AIAction(executionDate.id, self.fightTarget, skillVo.fReleaseDist*0.01, v)
			elseif actionType == ActionType.SelfHpLess then --定点移动

			elseif actionType == ActionType.SelfHpLess then --选取移动

			elseif actionType == ActionType.SelfHpLess then --跟随玩家

			elseif actionType == ActionType.SelfHpLess then --瞬移玩家

			end
		elseif targetChoice == TargetChoice.Hatest  then --仇恨最高
			if actionType == ActionType.No then --释放技能
				local v = executionDate.actionValue[1]
				skillVo = SkillManager.GetStaticSkillVo(v)
				self.controlTarget:AIAction(executionDate.id, self.fightTarget, skillVo.fReleaseDist*0.01, v)
			elseif actionType == ActionType.SelfHpLess then --定点移动

			elseif actionType == ActionType.SelfHpLess then --选取移动

			elseif actionType == ActionType.SelfHpLess then --跟随玩家
				
			elseif actionType == ActionType.SelfHpLess then --瞬移玩家

			end
		elseif targetChoice == TargetChoice.HpLeast  then --血量最低
			if actionType == ActionType.No then --释放技能
				local v = executionDate.actionValue[1]
				skillVo = SkillManager.GetStaticSkillVo(v)
				self.controlTarget:AIAction(executionDate.id, self.fightTarget, skillVo.fReleaseDist*0.01, v)
			elseif actionType == ActionType.SelfHpLess then --定点移动

			elseif actionType == ActionType.SelfHpLess then --选取移动

			elseif actionType == ActionType.SelfHpLess then --跟随玩家
				
			elseif actionType == ActionType.SelfHpLess then --瞬移玩家

			end
		end
	end

	if executionDate.actionSwitch == 0 then --AI判定结束
		self:StartRunCd()
		return
	elseif executionDate.actionSwitch == 1 then --指定判定层ID
		return
	elseif executionDate.actionSwitch == 2 and executionDate.switchValue ~= 0 then --指定行为层ID
		self:ExecutionHandler(AICellVo.GetExecutionData(executionDate.switchValue))
	end
	
end

function AICell:__delete()
	self.aiVo = nil
	self.parent = nil

	self.controlTarget = nil
	self.fightTarget = nil
end