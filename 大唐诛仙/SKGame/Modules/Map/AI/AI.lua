-- AI
AI =BaseClass()

function AI:__init(monsterId, controlTarget)
	local monsterVo = GetCfgData( "monster" ):Get(tonumber(monsterId))
	if monsterVo == nil then 
		error("fail to get monsterVo, the monsterId is:"..monsterId)
		return 
	end
	if monsterVo.ai == nil or #monsterVo.ai < 1 then 
		error("monster["..monsterId.."] does not has any AI behavior")
		return 
	end

	self.controlTarget = controlTarget
	self.fightTarget = nil
	self.aiCellList = {}
	self.aiReadyList = {}
	local aiCell = nil
	for i = 1, #monsterVo.ai do
		 aiCell = AICell.New(tonumber(monsterVo.ai[i][1]), controlTarget, self)
		 table.insert(self.aiCellList, aiCell)
	end

	self.curAIcell = nil
	self.newReadyAICell = nil
end

function AI:PushToReadyList(aiCell)
	if aiCell then
		if not self:JudgeIfInReadyList(aiCell) then
			table.insert(self.aiReadyList, aiCell)
		end
		self.newReadyAICell = aiCell
	end
end

function AI:RemoveFromReadyList(aiCell)
	for i = 1, #self.aiReadyList do
		if self.aiReadyList[i] == aiCell then
			return table.remove(self.aiReadyList, i)
		end
	end
	return nil
end

function AI:JudgeIfInReadyList(aiCell)
	if not aiCell then return  false end
	for i = 1, #self.aiReadyList do
		if self.aiReadyList[i].aiVo.determinationData.id == aiCell.aiVo.determinationData.id then 
			return true
		end
	end
	return false
end

function AI:SetFightTarget(fightTarget)
	self.fightTarget = fightTarget
	if self.aiCellList then  
		for i = 1, #self.aiCellList do
			self.aiCellList[i]:SetFightTarget(fightTarget)
		end
	end
end

function AI:Update()
	if not self.fightTarget or not self.controlTarget or not self.controlTarget.gameObject.activeSelf or self.controlTarget:IsDie() then return end
	for i = 1, #self.aiCellList do
		self.aiCellList[i]:Update()
	end

	if self.controlTarget.IsColliding then return end

	if self.newReadyAICell and self.curAIcell then
		if self.newReadyAICell ~= self.curAIcell then
			if self.newReadyAICell.aiVo.determinationData.actionLevel > self.curAIcell.aiVo.determinationData.actionLevel then
				if not self.controlTarget.isAIExecuting then
					self.curAIcell = self:RemoveFromReadyList(self.newReadyAICell)
					if self.curAIcell then
						self.curAIcell:AIExcute()
					end
				end
			end
		end
	end

	if not self.curAIcell then
		self.curAIcell = self:SelectAI()
		if self.curAIcell then
			self.curAIcell:AIExcute()
		end
	end
end

function AI:SelectAI()
	local readyList = self.aiReadyList
	if #readyList < 1 then 
		self:Reset()
		return nil 
	end
	if #readyList < 2 then 
		self:Reset()
		return table.remove(readyList, 1)
	end

	--检测是否需要比较可能触发列表的行为级别
	local needCheckActionLevel = false
	local initActionLevel = readyList[1].aiVo.determinationData.actionLevel
	for i = 1, #readyList do
		if initActionLevel ~= readyList[i].aiVo.determinationData.actionLevel then
			needCheckActionLevel = true
			break
		end
	end
	if needCheckActionLevel then 
		local maxActionLevelDeterminationData = readyList[1]
		local maxIndex = -1
		for i = 1, #readyList do
			if readyList[i].aiVo.determinationData.actionLevel > maxActionLevelDeterminationData.aiVo.determinationData.actionLevel then
				maxActionLevelDeterminationData = readyList[i]
				maxIndex = i
			end
		end
		self:Reset()
		if maxIndex ~= -1 then
			return table.remove(readyList, maxIndex)
		end
	end
	--上一阶段不需检测行为级别,则开始检测触发权重
	if not needCheckActionLevel then
		local weightMapping = {} 
		local preWeightNumber = 0
		local weightNumber = 0
		for i = 1, #readyList do
			preWeightNumber = weightNumber + 1
			weightNumber = preWeightNumber + readyList[i].aiVo.determinationData.weight - 1
			weightMapping[i] = {}
			weightMapping[i] = {preWeightNumber, weightNumber}
		end
		local radomWeight = Mathf.Random(0, weightNumber)
		for k, v in pairs(weightMapping) do
			if radomWeight >= v[1] and radomWeight < v[2]  then 
				self:Reset()
				return table.remove(readyList, k)
			end
		end
	end
end

function AI:Reset()
	self.curAIcell = nil
	self.newReadyAICell = nil
end

function AI:__delete()
	self.controlTarget = nil
	self.fightTarget = nil
	self.aiReadyList = nil
	self.aiCellList = {}
	for i = 1, #self.aiCellList do
		self.aiCellList[i]:Destroy()
	end
	self.aiCellList = nil
end