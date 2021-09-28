PowerModel =BaseClass(LuaModel)

function PowerModel:__init()
	self:InitData()
end

function PowerModel:__delete()
	self.leveingMadmanData = {} 
	self.ownLevelRewardList = {}

	self.improveBattleData = {} 
	self.ownBattleRewardList = {}

	PowerModel.inst = nil
end

function PowerModel:GetInstance()
	if PowerModel.inst == nil then
		PowerModel.inst = PowerModel.New()
	end
	return PowerModel.inst
end

function PowerModel:InitData()
	--------疯狂冲级---
	self.leveingMadmanData = {} --疯狂冲级数据
	self.ownLevelRewardList = {}
	self:InitLevelingRewardData()
	--------冲战斗力------
	self.improveBattleData = {} --疯狂冲级数据
	self.ownBattleRewardList = {}
	self:InitImproveBattleRewardData()
end

--疯狂冲级 与冲战力 活动时间
function PowerModel:GetHuoDongTime()
	local serverNo = LoginModel:GetInstance():GetLastServerNo()
	local serverTime = TimeTool.GetCurTime()
	local openServerTime = LoginModel:GetInstance():GetServerOpenDateByServerNo(serverNo)


	--时间差值
	local differTime = serverTime  - openServerTime
	if differTime < 0 then
		differTime = 0
	end
	local day = GetCfgData("constant"):Get(72).value
	local shengYuTime = day * 86400 - differTime * 0.001
	return shengYuTime
end 

--清处缓存
function PowerModel:ResetleveingMadmanData()
	if #self.leveingMadmanData ~= 0 then
		for k , v in pairs(self.leveingMadmanData) do
			if self.leveingMadmanData[k] then
				self.leveingMadmanData[k].state = PowerConst.OnLevelingRewardState.None
			end
		end
	end
	self.leveingMadmanData = {} 
	self.ownLevelRewardList = {}		
end

function PowerModel:ResetimproveBattleData()
	if #self.improveBattleData ~= 0 then
		for k , v in pairs(self.improveBattleData) do
			if self.improveBattleData[k] then
				self.improveBattleData[k].state = PowerConst.OnImproveBattleRewardState.None
			end
		end
	end
	self.improveBattleData = {} 
	self.ownBattleRewardList = {}
end

function PowerModel:IsHasOnlevelRewardCanGet()
	local isHas = false
	for id, value in pairs(self.leveingMadmanData) do
		if self.leveingMadmanData[id].state ~= PowerConst.OnLevelingRewardState.AlreadyGet then
			if self.leveingMadmanData[id].total - self.leveingMadmanData[id].num > 0  and self:GetHuoDongTime() > 0 then
			  if self:IsCanGetLeveReward(self.leveingMadmanData[id].id) == true then
				isHas = true
				break
			  end
			end
		end
	end
	return isHas
end

function PowerModel:HandleLeveGetRewardID(data)
	--获取冲级奖励ID
	if data then
		self.levelId = data
	end
	local idx = self:GetIndexByLeveRewradId(self.levelId)
	self.leveingMadmanData[idx].state = PowerConst.OnLevelingRewardState.AlreadyGet

	--print("协议升级ID=======================+++++++++++++++++++===",msg.id)
end

function PowerModel:GetIndexByLeveRewradId(rewardId)
	local rtnIndex = 0
	if rewardId ~= nil then
		for k , v in pairs(self.leveingMadmanData) do
			if v.id == rewardId then
				rtnIndex = k
				break
			end
		end
	end
	return rtnIndex
end

function PowerModel:GetLeveRewradCfgById(id)
	local rewardData = {}
	if id then
		rewardData = GetCfgData("reward"):Get(id) or {}
	end
	return rewardData
end

function PowerModel:IsCanGetLeveReward(rewardId)
	local IsCan = false
	if rewardId then
		local rewardCfg = self:GetLeveRewradCfgById(rewardId)
		
		 if self:GetCurrentRoleLeve() >= rewardCfg.condition or self:GetShengJiRoleLeve() >= rewardCfg.condition then
		    IsCan = true 
		 end		
	end
	return IsCan
end

function PowerModel:InitLevelingRewardData()
	local rewardCfg = GetCfgData("reward")
	local career = LoginModel:GetInstance():GetLoginRole().career
	for k , v in pairs(rewardCfg) do
		if type(v) ~= 'function' and v and v.type == RewardConst.Type.LevelingMadmanReward then
			self.leveRewardId = v.id			
			table.insert(self.leveingMadmanData , {id = v.id , grade = v.condition , total = v.resCondition ,rewards = v.reward ,isCanLingQuBool = true ,num = 0, state = PowerConst.OnLevelingRewardState.None})
			
		end
	end
	
	table.sort(self.leveingMadmanData, function(a, b) 
		return a.id < b.id
	end)
	--print("获取角色登录时等级----------",self:GetCurrentRoleLeve())
	--print("获取角色登录时等级----------",self:GetCurrentRolebattleValue())
end
--获取登录时人物等级
function PowerModel:GetCurrentRoleLeve()
	local lv = LoginModel:GetInstance():GetLoginRole().level or 0
	return lv
end
--获取登录时角色攻击力
function PowerModel:GetCurrentRolebattleValue()
	local battleValue = LoginModel:GetInstance():GetLoginRole().battleValue or 0
	return battleValue
end
--升级后的人物等级
function PowerModel:GetShengJiRoleLeve()
	local lv = PowerLevelCtr:GetInstance():GetChangedLevel() or 0
	return lv
end
--升级后的人物攻击力
function PowerModel:GetShengJiRoBattleValue()
	local BattleValue = PowerLevelCtr:GetInstance():GetChangedBattleValue() or 0
	return BattleValue
end

function PowerModel:GetEquipNeedJob( id )
	return GetCfgData("equipment"):Get(id).needJob
end

function PowerModel:GetleveingMadmanData()
	return self.leveingMadmanData
end

function PowerModel:HandleLeveGetRewardNum(data)
	--获取对应ID的已领取人数
	self.getAlreadyLvevelRewardNum = data
	local idx = self:GetIndexByLeveRewradId(self.levelId)
	self.leveingMadmanData[idx].num = self.getAlreadyLvevelRewardNum
	self:DispatchEvent(PowerConst.ChangeLevelNum, LevelNum)
end

function PowerModel:HandleLeveAlreadyGetRewardData(listReward)
	self.leveingMadmanData = {}
	self:InitLevelingRewardData()
	local bool = false
	if self.ownLevelRewardList then
		bool = true	
	else 
		bool = false
	end	
	if bool then
		for k,v in pairs(self.ownLevelRewardList) do
			local idx = self:GetIndexByLeveRewradId(v)
			self.leveingMadmanData[idx].state = PowerConst.OnLevelingRewardState.AlreadyGet
		end
	end
	if listReward then
		for index = 1, #listReward do
			local curRewardId = listReward[index].id
			self.levelLingQuNum = listReward[index].num
			if curRewardId ~= 0 then
				local idx = self:GetIndexByLeveRewradId(curRewardId)
				if idx ~= 0 and (not TableIsEmpty(self.leveingMadmanData[idx]))  then
					self.leveingMadmanData[idx].num = self.levelLingQuNum
				end
			end
		end
	end
	self:SetOnLevelRewardState()
	

end

function PowerModel:SetOnLevelRewardState()
	for id, value in pairs(self.leveingMadmanData) do
		if  self.leveingMadmanData[id].state ~= PowerConst.OnLevelingRewardState.AlreadyGet then
			if self:IsCanGetLeveReward(self.leveingMadmanData[id].id) == true then
				self.leveingMadmanData[id].state = PowerConst.OnLevelingRewardState.CanGet
			else
				self.leveingMadmanData[id].state = PowerConst.OnLevelingRewardState.CanNotGet
			end
		end
	end
end
--冲级狂人判断按钮状态
function PowerModel:GetLevelingMadmanBtnState(id)
	self:SetOnLevelRewardState()
	local state = PowerConst.OnLevelingRewardState.CanNotGet
	for k,v in pairs(self.leveingMadmanData) do
		if v.id == id then
			state = v.state
			--print("按钮的状态======================",state)
			return state			
		end
	end
	return state
end

-------------------------------------冲战斗力----------------------------------------------------------
function PowerModel:IsHasOnbattleRewardCanGet()
	local isHas = false
	for id, value in pairs(self.improveBattleData) do
		if self.improveBattleData[id].state ~= PowerConst.OnImproveBattleRewardState.AlreadyGet then
			if self.improveBattleData[id].total - self.improveBattleData[id].num > 0 and self:GetHuoDongTime() > 0 then
			  if self:IsCanGetBattleReward(self.improveBattleData[id].id) == true then
				isHas = true
				break
			  end
			end
		end
	end
	return isHas
end

function PowerModel:InitImproveBattleRewardData()
	local rewardCfg = GetCfgData("reward")

	for k , v in pairs(rewardCfg) do
		if type(v) ~= 'function' and v and v.type == RewardConst.Type.CombatPowerReward then
			self.ImproveRewardId = v.id			
			table.insert(self.improveBattleData , {id = v.id , battleValue = v.condition , total = v.resCondition ,rewards = v.reward ,isCanLingQuBool = true ,num = 0, state = PowerConst.OnImproveBattleRewardState.None})
			
		end
	end
	
	table.sort(self.improveBattleData, function(a, b) 
		return a.id < b.id
	end)
end

function PowerModel:GetImproveBattleData()
	return self.improveBattleData
end

function PowerModel:HandleBattleGetRewardID(data)
	--获取冲级奖励ID
	if data then
		self.battleId = data
	end
	local idx = self:GetIndexByBattleRewradId(self.battleId)
	self.improveBattleData[idx].state = PowerConst.OnImproveBattleRewardState.AlreadyGet
end

function PowerModel:HandleBattleGetRewardNum(data)
	--获取对应ID的已领取人数
	self.getAlreadyBattleRewardNum = data
	local idx = self:GetIndexByBattleRewradId(self.battleId)
	self.improveBattleData[idx].num = self.getAlreadyBattleRewardNum
	self:DispatchEvent(PowerConst.ChangeBattleNum, BattleNum)
end

function PowerModel:HandleBattleAlreadyGetRewardData(listReward)
	self.improveBattleData = {}
	self:InitImproveBattleRewardData()
	local bool = false
	if self.ownBattleRewardList then
		bool = true
	else 
		bool = false
	end	

	if bool then
		for k,v in pairs(self.ownBattleRewardList) do
			local idx = self:GetIndexByBattleRewradId(v)
			self.improveBattleData[idx].state = PowerConst.OnImproveBattleRewardState.AlreadyGet
		end					
	end

	if listReward then
		for index = 1, #listReward do
			local curRewardId = listReward[index].id
			self.battleLingQuNum = listReward[index].num
			if curRewardId ~= 0 then
				local idx = self:GetIndexByBattleRewradId(curRewardId)
				if idx ~= 0 and (not TableIsEmpty(self.improveBattleData[idx]))  then
					self.improveBattleData[idx].num = self.battleLingQuNum
				end
			end
		end
	end
	self:SetOnBattleRewardState()
end

function PowerModel:SetOnBattleRewardState()
	for id, value in pairs(self.improveBattleData) do
		if  self.improveBattleData[id].state ~= PowerConst.OnImproveBattleRewardState.AlreadyGet then
			if self:IsCanGetBattleReward(self.improveBattleData[id].id) == true then
				self.improveBattleData[id].state = PowerConst.OnImproveBattleRewardState.CanGet
			else
				self.improveBattleData[id].state = PowerConst.OnImproveBattleRewardState.CanNotGet
			end
		end
	end
end

function PowerModel:IsCanGetBattleReward(rewardId)
	local IsCan = false
	if rewardId then
		local rewardCfg = self:GetBattleRewradCfgById(rewardId)
		 if self:GetCurrentRolebattleValue() >= rewardCfg.condition or self:GetShengJiRoBattleValue() >= rewardCfg.condition then
		    IsCan = true 
		 end
	end
	return IsCan
end

function PowerModel:GetBattleRewradCfgById(id)
	local rewardData = {}
	if id then
		rewardData = GetCfgData("reward"):Get(id) or {}
	end
	return rewardData
end

function PowerModel:GetIndexByBattleRewradId(rewardId)
	local rtnIndex = 0
	if rewardId ~= nil then
		for k , v in pairs(self.improveBattleData) do
			if v.id == rewardId then
				rtnIndex = k
				break
			end
		end
	end
	return rtnIndex
end

--战力判断按钮状态
function PowerModel:GetImproveBattleBtnState(id)
	self:SetOnBattleRewardState()
	local state = PowerConst.OnImproveBattleRewardState.CanNotGet
	for k,v in pairs(self.improveBattleData) do
		if v.id == id then
			state = v.state
			return state			
		end
	end
	return state
end
