CarnivalData = CarnivalData or BaseClass()
CarnivalData.activityType = {
	CarnivalRank = 1,
	CarnivalPool = 2,
	CarnivalBoss = 3,
	CarnivalLease = 4,
	CarnivalCost = 5,
}
CarnivalData.RankType = {
	Level = 1,
	Swing = 2,
	Hero = 3,
	Soul = 4,
	Stone = 5,
	Fight = 6,
}
function CarnivalData:__init()
	if CarnivalData.Instance then
		ErrorLog("[CarnivalData]:Attempt to create singleton twice!")
	end
	CarnivalData.Instance = self
	self:InitCarnivalRankMenu()
	self:InitCarnivalPool()
	self:InitCarnivaGoldBoss()
	self:InitCarnivaLease()
	self.welfare_num =0
end

function CarnivalData:__delete()
	CarnivalData.Instance = nil
end

function CarnivalData:InitCarnivalRankMenu()
	self.menuTemp = {}
	self.menuTempAward = {}
	self.rankData = {}
	self.my_rank = {}
	for i,v in ipairs(CarnivalConfig.OpenServerRank.Theme) do
		self.menuTemp[i] ={name =v.name}
		self.menuTempAward[i] = {rankShowNum = v.rankShowNum,rankMinValue = v.rankMinValue, RankAward = v.RankAward,desc= v.desc,startDay = v.startDay,endDay=v.endDay}
	end
	for i,v in ipairs(CarnivalData.RankType) do
		self.rankData[i] = {}
		self.my_rank[i] = {}
	end
end

function CarnivalData:InitCarnivalPool()
	self.InPoolData = {}
	self.PoolTemp = CarnivalConfig.WishingPool
end

function CarnivalData:getCarnivalPool()
	return self.PoolTemp
end

function CarnivalData:InitCarnivaGoldBoss()
	self.activity_state = 0
	self.boss_state = 0
	self.bossTemp = CarnivalConfig.Boss
end

function CarnivalData:MyDecInso(index)
	local str = ""
	if index == 1 then
		local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
		local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
		str = string.format(Language.Carnival.RichRankTxt[index],circle,level)
	elseif index == 2 then
		local wing = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_ID) or 0
		str = string.format(Language.Carnival.RichRankTxt[index],wing)
	elseif index == 3 then
		local fuwen_lv = RoleData.Instance:GetAttr(OBJ_ATTR.HERO_FUWEN_LEVEL)
		local step, star = ZhanjiangData.GetFuWenStepStar(fuwen_lv)
		str = string.format(Language.Carnival.RichRankTxt[index],step,star)
	elseif index == 4 then
		local equip = EquipData.Instance:GetEquipByType(ItemData.ItemType.itStoveDiamond)--检测是否有血符装备
		local step, star = 0,0
		if equip then
			local level = equip.compose_level
			step,star = ComposeData.Instance:GetStepStar(level)
		end
		str = string.format(Language.Carnival.RichRankTxt[index],step,star)
	elseif index == 5 then
		local equip = EquipData.Instance:GetEquipByType(ItemData.ItemType.itStoveSealBead)
		local step, star = 0,0
		if equip then
			local level = equip.compose_level
			step,star = ComposeData.Instance:GetStepStar(level)
		end
		str = string.format(Language.Carnival.RichRankTxt[index],step,star)
	elseif index == 6 then		
		str = string.format(Language.Carnival.RichRankTxt[index],RoleData.Instance:GetBattle())
	end
	return str
end

function CarnivalData:InitCarnivaLease()
	self.leaseInfo = {}
	for i,v in ipairs(CarnivalConfig.rentBuff.BuffList) do
		self.leaseInfo[i] = {
		name = v.name,
		buffDesc = v.buffDesc,
		yb = v.yb,
		BuffId = v.BuffId,
		isBuy = 0,
		index = i
	}
	end
end

function CarnivalData:setCarnivaGoldLeaseInfo(data)
	for i,v in ipairs(data.lease_state) do
		if self.leaseInfo[i] then
			self.leaseInfo[i].isBuy = v.isBuy
		end
	end
end

function CarnivalData:setCarnivaWelfareInfo(data)
	self.welfare_num = data.welfare_num
end

function CarnivalData:getCarnivaWelfareInfo()
	return self.welfare_num
end

function CarnivalData:getCarnivaGoldLease()
	return self.leaseInfo
end

function CarnivalData:IsopenCarnivaGoldLease()
	
end

function CarnivalData:getCarnivaGoldBoss()
	return self.bossTemp
end

function CarnivalData:getRankMenuData()
	return self.menuTemp
end

function CarnivalData:setRankData(data)
	self.rankData[data.rank_type] = {}
	self.rankData[data.rank_type] = data.reward_state
	self.my_rank[data.rank_type] = data.my_rank or 0
end

function CarnivalData:setPoolData(data)
	self.InPoolData = data.pool_state
end

function CarnivalData:setBossData(data)
	self.activity_state = data.activity_state
	self.boss_state = data.boss_state
end

function CarnivalData:getBossData()
	return self.activity_state,self.boss_state
end

function CarnivalData:getPoolData()
	return self.InPoolData
end

function CarnivalData:AllActivityOpen()
	local minindex = self:MinOpenActivity()
	if minindex <= 0 then
		return false
	else
		return true
	end
end

function CarnivalData:MinOpenActivity()
	if self:getIsOpenRankAct() then
		return TabIndex.carnival_rank
	elseif self:PoolIsOpen() then
		return TabIndex.carnival_pool
	elseif self:BossIsOpen() then
		return TabIndex.carnival_goldBoss
	elseif self:LeaseIsOpen() then
		return TabIndex.carnival_goldLease
	elseif self:WelfareIsOpen() then
		return TabIndex.carnival_returnWelfare
	end
	return 0
end

function CarnivalData:IsShowTabbarToggleByIndex(index)
	if index ==TabIndex.carnival_rank then
		return self:getIsOpenRankAct()
	elseif index == TabIndex.carnival_pool then 
		return self:PoolIsOpen()
	elseif index ==	TabIndex.carnival_goldBoss then
		return self:BossIsOpen()
	elseif index == TabIndex.carnival_goldLease then
		return self:LeaseIsOpen()
	elseif index == TabIndex.carnival_returnWelfare then
		return self:WelfareIsOpen()
	end
end

function CarnivalData:RemindData()
	if self:PoolIsOpen() then
		local data = self:getPoolData()
		if next(data)then
			if #data <3 then
				return 1
			end
		else
			return 1
		end
	end
	return 0
end

function CarnivalData:BossIsOpen()
	local open_days =  OtherData.Instance:GetOpenServerDays()
	if  open_days<self.bossTemp.startDay then
		return false
	end
	if  open_days<=self.bossTemp.endDay then
		return true
	end
	return false
end

function CarnivalData:PoolIsOpen()
	local open_days =  OtherData.Instance:GetOpenServerDays()
	if  open_days<self.PoolTemp.startDay then
		return false
	end
	if self.PoolTemp then
		if  open_days<=self.PoolTemp.endDay then
			return true
		end
	end
	return false
end

function CarnivalData:LeaseIsOpen()
	local open_days =  OtherData.Instance:GetRoleCreatDay()
	if  open_days<CarnivalConfig.rentBuff.createRoleStartDay then
		return false
	end
	if  open_days<=CarnivalConfig.rentBuff.createRoleEndDay then
		return true
	end
	return false
end

function CarnivalData:WelfareIsOpen()
	local open_days =  OtherData.Instance:GetRoleCreatDay()
	if  open_days<CarnivalConfig.ConsumeReturn.createRoleStartDay then
		return false
	end
	if open_days<=CarnivalConfig.ConsumeReturn.createRoleEndDay then
		return true
	end
	return false
end

function CarnivalData:getRankData(index)
	return self.rankData[index]	,self.my_rank[index]
end

function CarnivalData:getRankMenuAward()
	return self.menuTempAward
end

function CarnivalData:getIsOpenRankAct()
	local open_days =  OtherData.Instance:GetOpenServerDays()
	if open_days<self.menuTempAward[1].startDay then
		return false
	end	
	local maxDay = self.menuTempAward[#self.menuTempAward]
	if maxDay and  maxDay.endDay>=open_days then
		return true
	end
	return false
end




