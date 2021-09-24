strategyCenterVoApi = {}

function strategyCenterVoApi:clear()
	if self == nil then
		do return end
	end
	
	--基础战略等级
	self.levelBasics = nil

	--巅峰战略等级
	self.levelPeakedness = nil

	--基础战略技能点
	self.skillPointBasics = nil

	--巅峰战略技能点
	self.skillPointPeakedness = nil

	--基础战略消耗的总技能点
	self.costSkillPointBasics = nil

	--巅峰战略消耗的总技能点
	self.costSkillPointPeakedness = nil

	--基础战略经验值
	self.expBasics = nil

	--巅峰战略经验值
	self.expPeakedness = nil

	--基础战略的每日捐献(经验转换)次数
	self.transformCount = nil

	--每日随机的派遣将领
	self.heroPool = nil

	--已派遣的将领数据
	self.dispatchEndTimer = nil --派遣结束时间戳
	self.dispatchRewardExp = nil --派遣奖励的经验
	self.dispatchRewardState = nil --派遣奖励领取状态
	self.dispatchNum = nil --已派遣的次数

	--基础战略技能
	self.skillBasics = nil

	--巅峰战略技能
	self.skillPeakedness = nil

	--巅峰buff数据
	self.buffData = nil

	--巅峰战略每日转换获得的经验
	self.todayExpPeakedness = nil
end

function strategyCenterVoApi:isOpen()
	return (base.strategyCenter == 1)
end

function strategyCenterVoApi:isCanEnter(isShowTips)
	if self:isOpen() == false then
		if isShowTips then
			G_showTipsDialog(getlocal("backstage180"))
		end
		return false
	end
	local openLv = self:getOpenLv()
	if playerVoApi:getPlayerLevel() < openLv then
		if isShowTips then
			G_showTipsDialog(getlocal("elite_challenge_unlock_level", {openLv}))
		end
		return false
	end
	return true
end

--获取基础战略开启等级
function strategyCenterVoApi:getOpenLv()
	local cfg = self:getStrategyCenterCfg()
	return cfg.strategy1.playerLevel
end

--获取巅峰战略开启等级
function strategyCenterVoApi:getPeakednessOpenLv()
	local cfg = self:getStrategyCenterCfg()
	return cfg.strategy2.playerLevel
end

--获取战略中心的配置
function strategyCenterVoApi:getStrategyCenterCfg()
	if self.strategyCenterCfg == nil then
		self.strategyCenterCfg = G_requireLua("config/gameconfig/strategyCenterCfg")
	end
	return self.strategyCenterCfg
end

--主入口界面(战略中心)
function strategyCenterVoApi:showMainDialog(layerNum)
	if self:isCanEnter(true) == true then
		strategyCenterVoApi:requestInit(function()
			require "luascript/script/game/scene/gamedialog/strategyCenter/strategyCenterDialog"
			local td = strategyCenterDialog:new(layerNum)
		    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("strategyCenter_text"), true, layerNum)
		    sceneGame:addChild(dialog, layerNum)
		end)
	end
end

--显示将领派遣小弹板
--@dispatchCallback : 派遣成功的回调函数
function strategyCenterVoApi:showHeroDispatchSmallDialog(layerNum, dispatchCallback)
	require "luascript/script/game/scene/gamedialog/strategyCenter/strategyCenterSmallDialog"
	strategyCenterSmallDialog:showHeroDispatch(layerNum, getlocal("strategyCenter_heroDispatch"), dispatchCallback)
end

--显示技能详情小弹板
--@skillId : 技能id
--@upgradeCallback : 升级按钮的回调函数
function strategyCenterVoApi:showSkillDetailsSmallDialog(layerNum, skillId, upgradeCallback)
	require "luascript/script/game/scene/gamedialog/strategyCenter/strategyCenterSmallDialog"
	strategyCenterSmallDialog:showSkillDetails(layerNum, getlocal("planeRefit_attributeDetails"), skillId, upgradeCallback)
end

--显示巅峰升级小弹板
--@upgradeCallback : 升级按钮的回调函数
function strategyCenterVoApi:showPeakednessUpgradeSmallDialog(layerNum, upgradeCallback)
	require "luascript/script/game/scene/gamedialog/strategyCenter/strategyCenterSmallDialog"
	strategyCenterSmallDialog:showPeakednessUpgrade(layerNum, getlocal("strategyCenter_peakednessUpgrade"), upgradeCallback)
end

function strategyCenterVoApi:initData(data)
	if data then
		if data.strategy then
			--基础战略等级
			if data.strategy.blvl then
				self.levelBasics = data.strategy.blvl
			end

			--巅峰战略等级
			if data.strategy.plvl then
				self.levelPeakedness = data.strategy.plvl
			end

			--基础战略技能点
			if data.strategy.bspoint then
				self.skillPointBasics = data.strategy.bspoint
			end

			--巅峰战略技能点
			if data.strategy.pspoint then
				self.skillPointPeakedness = data.strategy.pspoint
			end

			--基础战略消耗的总技能点
			if data.strategy.bcost then
				self.costSkillPointBasics = data.strategy.bcost
			end

			--巅峰战略消耗的总技能点
			if data.strategy.pcost then
				self.costSkillPointPeakedness = data.strategy.pcost
			end

			--基础战略经验值
			if data.strategy.bexp then
				self.expBasics = data.strategy.bexp
			end

			--巅峰战略经验值
			if data.strategy.pexp then
				self.expPeakedness = data.strategy.pexp
			end

			--基础战略的每日捐献(经验转换)次数
			if data.strategy.bdonate then
				self.transformCount = data.strategy.bdonate[1]
				-- data.strategy.bdonate[2] --时间戳
			end

			--每日随机的派遣将领
			if data.strategy.hero then
				self.heroPool = data.strategy.hero
			end

			--已派遣的将领数据
			if data.strategy.bhero then
				-- data.strategy.bhero[1] --已派遣的将领id
				self.dispatchEndTimer = data.strategy.bhero[2] --派遣结束时间戳
				self.dispatchRewardExp = data.strategy.bhero[3] --派遣奖励的经验
				self.dispatchRewardState = data.strategy.bhero[4] --派遣奖励领取状态
				self.dispatchNum = data.strategy.bhero[5] --已派遣的次数
			end

			--基础战略技能
			if data.strategy.bskill then
				self.skillBasics = data.strategy.bskill
			end

			--巅峰战略技能
			if data.strategy.pskill then
				self.skillPeakedness = data.strategy.pskill
			end

			--巅峰buff数据
			if data.strategy.buff then
				self.buffData = data.strategy.buff
			end

			--巅峰战略每日转换获得的经验
			if data.strategy.pmaxexp then
				self.todayExpPeakedness = data.strategy.pmaxexp[1]
			end
		end
	end
end

--请求初始化数据接口
function strategyCenterVoApi:requestInit(callback)
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	if sData and sData.data then
        		self:initData(sData.data)
        		if type(callback) == "function" then
        			callback()
        		end
        	end
        end
	end
	socketHelper:strategyCenterInit(socketCallback)
end

--基础战略经验转换接口
function strategyCenterVoApi:requestExpTransform(callback)
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	if sData and sData.data then
        		self:initData(sData.data)
        		if type(callback) == "function" then
        			callback()
        		end
        	end
        end
	end
	socketHelper:strategyCenterExpTransform(socketCallback)
end

--将领派遣的接口
--@hidTb : 要派遣的将领id
function strategyCenterVoApi:requestHeroDispatch(callback, hidTb)
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	if sData and sData.data then
        		self:initData(sData.data)
        		if type(callback) == "function" then
        			callback()
        		end
        	end
        end
	end
	socketHelper:strategyCenterHeroDispatch(socketCallback, hidTb)
end

--领取派遣奖励接口
function strategyCenterVoApi:requestRewardDispatch(callback)
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	if sData and sData.data then
        		self:initData(sData.data)
        		if type(callback) == "function" then
        			callback()
        		end
        	end
        end
	end
	socketHelper:strategyCenterRewardDispatch(socketCallback)
end

--重置技能点接口(洗点)
--@tabType : 1-基础战略，2-巅峰战略
function strategyCenterVoApi:requestResetPoint(callback, tabType)
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	if sData and sData.data then
        		self:initData(sData.data)
        		if type(callback) == "function" then
        			callback()
        		end
        	end
        end
	end
	socketHelper:strategyCenterResetPoint(socketCallback, tabType)
end

--技能升级接口
--@tabType : 1-基础战略，2-巅峰战略
--@skillId : 技能id
function strategyCenterVoApi:requestSkillUpgrade(callback, tabType, skillId)
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	if sData and sData.data then
        		self:initData(sData.data)
        		if type(callback) == "function" then
        			callback()
        		end
        	end
        end
	end
	socketHelper:strategyCenterSkillUpgrade(socketCallback, tabType, skillId)
end

--巅峰战略升级接口
function strategyCenterVoApi:requestPeakednessUpgrade(callback)
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	if sData and sData.data then
        		self:initData(sData.data)
        		if type(callback) == "function" then
        			callback()
        		end
        	end
        end
	end
	socketHelper:strategyCenterPeakednessUpgrade(socketCallback)
end

--获取战略等级
--@tabType : 1-基础战略，2-巅峰战略
function strategyCenterVoApi:getLevel(tabType)
	if tabType == 1 then
		return (self.levelBasics or 0)
	elseif tabType == 2 then
		return (self.levelPeakedness or 0)
	end
	return 0
end

--获取战略的最大等级
--@tabType : 1-基础战略，2-巅峰战略
function strategyCenterVoApi:getMaxLevel(tabType)
	local cfg = self:getStrategyCenterCfg()
	if tabType == 1 then
		return SizeOfTable(cfg.strategy1.grow)
	elseif tabType == 2 then
		return SizeOfTable(cfg.strategy2.grow)
	end
	return 99999999
end

--获取战略技能点
--@tabType : 1-基础战略，2-巅峰战略
function strategyCenterVoApi:getSkillPoint(tabType)
	if tabType == 1 then
		return (self.skillPointBasics or 0)
	elseif tabType == 2 then
		return (self.skillPointPeakedness or 0)
	end
	return 0
end

--获取战略经验值
--@tabType : 1-基础战略，2-巅峰战略
function strategyCenterVoApi:getExp(tabType)
	if tabType == 1 then
		return math.floor(self.expBasics or 0)
	elseif tabType == 2 then
		return math.floor(self.expPeakedness or 0)
	end
	return 0
end

--获取战略最大经验值
--@level : 战略等级
--@tabType : 1-基础战略，2-巅峰战略
function strategyCenterVoApi:getExpMax(level, tabType)
	local cfg = self:getStrategyCenterCfg()
	if tabType == 1 then
		local growCfg = cfg.strategy1.grow[level + 1]
		if growCfg == nil then
			growCfg = cfg.strategy1.grow[level]
		end
		if growCfg then
			return growCfg.needExp1
		end
	elseif tabType == 2 then
		local growCfg = cfg.strategy2.grow[level + 1]
		if growCfg == nil then
			growCfg = cfg.strategy2.grow[level]
		end
		if growCfg then
			return growCfg.needExp2
		end
	end
	return 0
end

--获取巅峰战略升级消耗
--@scLevel : 巅峰战略等级
function strategyCenterVoApi:getPeakednessUpgardeCost(scLevel)
	local cfg = self:getStrategyCenterCfg()
	if cfg.strategy2.grow[scLevel + 1] then
		local costResTb = {}
		for k, v in pairs(cfg.strategy2.grow[scLevel + 1].cost) do
			table.insert(costResTb, {key = k, value = v})
		end
		return costResTb
	end
end

--获取消耗的总技能点数
--@tabType : 1-基础战略，2-巅峰战略
function strategyCenterVoApi:getCostSkillPoint(tabType)
	if tabType == 1 then
		return (self.costSkillPointBasics or 0)
	elseif tabType == 2 then
		return (self.costSkillPointPeakedness or 0)
	end
	return 0
end

--获取基础战略的经验转换消耗的资源(resource*（1+战略等级*weight+int（战略等级/10）*weight*20))
--@scLevel : 基础战略等级
function strategyCenterVoApi:getBasicsCostRes(scLevel)
	local cfg = self:getStrategyCenterCfg()
	return cfg.strategy1.resourceType, cfg.strategy1.resource * (1 + scLevel * cfg.strategy1.weight + math.floor(scLevel / 10) * cfg.strategy1.weight * 20)
end

--获取基础战略中经验转换次数
function strategyCenterVoApi:getExpTransformCount()
	if self.transformCount then
		return self.transformCount
	end
	return 0
end

--获取基础战略中经验转换最大次数
function strategyCenterVoApi:getExpTransformMaxCount()
	local cfg = self:getStrategyCenterCfg()
	return cfg.strategy1.donateCount
end

--获取基础战略资源转换获得的经验值
function strategyCenterVoApi:getTransformExp()
	local cfg = self:getStrategyCenterCfg()
	return cfg.strategy1.exp
end

--获取每日派遣的将领池
function strategyCenterVoApi:getHeroPool()
	if self.heroPool then
		return self.heroPool
	end
end

--获取每日派遣的将领个数
function strategyCenterVoApi:getHeroDispatchCount()
	local cfg = self:getStrategyCenterCfg()
	return cfg.strategy1.sendNum
end

--获取派遣将领的奖励
function strategyCenterVoApi:getHeroDispatchReward()
	local reward = {}
	local cfg = self:getStrategyCenterCfg()
	local scExpNum = cfg.strategy1.sendExp
	if self.dispatchRewardExp and self.dispatchRewardExp > 0 then
		scExpNum = self.dispatchRewardExp
	end
	table.insert(reward, {name = getlocal("strategyCenter_heroDispatchExp"), num = scExpNum, pic = "scExpItemIcon.png"})
	for k, v in pairs(cfg.strategy1.serverSendReward) do
		local pid = Split(k, "_")[2]
		local rTb = FormatItem({p={[pid]=v}})
		if rTb and rTb[1] then
			table.insert(reward, rTb[1])
		end
	end
	return reward
end

--获取派遣将领经验的倍数
function strategyCenterVoApi:getHeroDispatchExpMultiple(index)
	local cfg = self:getStrategyCenterCfg()
	return (cfg.strategy1.sendWeight[index] or 1)
end

--获取将领派遣状态
--return : 0-待派遣，1-派遣中，2-待领奖，3-派遣次数已用完
function strategyCenterVoApi:getHeroDispatchState()
	if self.dispatchRewardState == 1 then --派遣奖励已领取
		local cfg = self:getStrategyCenterCfg()
		local dispatchNumMax = cfg.strategy1.sendCount
		if self.dispatchNum and self.dispatchNum >= dispatchNumMax and G_getWeeTs(base.serverTime) == G_getWeeTs(self.dispatchEndTimer or 0) then
			return 3
		end
	else
		if self.dispatchEndTimer and self.dispatchEndTimer > 0 then
			if base.serverTime <= self.dispatchEndTimer then
				return 1, self.dispatchEndTimer - base.serverTime
			else
				return 2
			end
		end
	end
	return 0
end

--获取洗点消耗的金币数
--@tabType : 1-基础战略，2-巅峰战略
function strategyCenterVoApi:getResetPointCost(tabType)
	local cfg = self:getStrategyCenterCfg()
	if tabType == 1 then
		return cfg.strategy1.resetCost
	elseif tabType == 2 then
		return cfg.strategy2.resetCost
	end
	return 0
end

--获取巅峰每日转换获取的经验
function strategyCenterVoApi:getTodayExpPeakedness()
	return (self.todayExpPeakedness or 0)
end

--获取巅峰每日转换的最大经验
function strategyCenterVoApi:getTodayMaxExpPeakedness()
	local cfg = self:getStrategyCenterCfg()
	return cfg.strategy2.expMax * cfg.strategy2.expPercent
end

--获取技能列表
--@tabType : 1-基础战略，2-巅峰战略
function strategyCenterVoApi:getSkillList(tabType)
	local cfg = self:getStrategyCenterCfg()
	if tabType == 1 then
		return cfg.strategy1.skillShow1
	elseif tabType == 2 then
		return cfg.strategy2.skillShow2
	end
end

--获取技能等级
--@skillId : 技能id
function strategyCenterVoApi:getSkillLevel(skillId)
	local skillLevel
	if self.skillBasics then
		skillLevel = self.skillBasics[skillId]
	end
	if skillLevel == nil and self.skillPeakedness then
		skillLevel = self.skillPeakedness[skillId]
	end
	return (skillLevel or 0)
end

--获取技能的配置数据
--@skillId : 技能id
function strategyCenterVoApi:getSkillCfgData(skillId)
	local cfg = self:getStrategyCenterCfg()
	local skillCfg = cfg.strategy1.skill[skillId]
	if skillCfg == nil then
		skillCfg = cfg.strategy2.skill[skillId]
		if skillCfg then
			skillCfg.tabType = 2
		end
	else
		skillCfg.tabType = 1
	end
	return skillCfg
end

--获取技能的属性值
--@skillId : 技能id
--@skillLevel : 技能等级
function strategyCenterVoApi:getSkillDesc(skillId, skillLevel)
	local skillCfg = self:getSkillCfgData(skillId)
	if skillCfg then
		local valueTb = {}
		for k, v in pairs(skillCfg.value) do
			local value = v[1] + (skillLevel - 1) * v[2]
			if skillCfg.percent[k] == 1 then
				value = value * 100
			end
			table.insert(valueTb, value)
		end
		return getlocal(skillCfg.skillDes, valueTb)
	end
	return ""
end

--获取技能升级条件
--@skillId : 技能id
--@skillLevel : 技能等级
function strategyCenterVoApi:getSkillUpgradeCondition(skillId, skillLevel)
	local skillCfg = self:getSkillCfgData(skillId)
	if skillCfg then
		local cfg = self:getStrategyCenterCfg()
		local strategyCfg = cfg["strategy" .. skillCfg.tabType]
		if strategyCfg then
			local skillCostCfg = strategyCfg.skillCost[skillLevel + 1]
			if skillCostCfg then
				local conditionTb = {}
				local v1 = skillCostCfg["needPoint" .. skillCfg.tabType]
				table.insert(conditionTb, {key = 1, value = v1}) --需要消耗的技能点
				if skillCfg.needProp == 1 then
					local propId = strategyCfg.needProp[1]
					local propNum = skillCostCfg["needPropNum" .. skillCfg.tabType] * strategyCfg.needProp[2]
					local v2 = {p = {[propId] = propNum}}
					table.insert(conditionTb, {key = 2, value = v2}) --需要消耗的道具
				end
				if skillLevel == 0 or (skillLevel + 1) % strategyCfg.needGrade == 0 then
					local costPointIndex = (skillLevel + 1) / strategyCfg.needGrade
					if skillLevel == 0 then
						costPointIndex = 1
					else
						costPointIndex = costPointIndex + 1
					end
					local v3 = skillCfg.costPoint1[costPointIndex]
					if v3 and v3 > 0 then
						table.insert(conditionTb, {key = 3, value = v3}) --需要已使用掉的基础技能点
					end
					if skillCfg.costPoint2 then
						local v4 = skillCfg.costPoint2[costPointIndex]
						if v4 and v4 > 0 then
							table.insert(conditionTb, {key = 4, value = v4}) --需要已使用掉的巅峰技能点
						end
					end
				end
				return conditionTb
			else
				--已升至满级
				return 0
			end
		end
	end
end

--判断技能是否可以升级
--@skillId : 技能id
--@skillLevel : 技能等级
function strategyCenterVoApi:isCanUpgrade(skillId, skillLevel)
	local conditionTb = self:getSkillUpgradeCondition(skillId, skillLevel)
	if conditionTb and conditionTb ~= 0 then
		local conditionTbSize, curCount = 0, 0
		for k, data in pairs(conditionTb) do
			conditionTbSize = conditionTbSize + 1
			if data.key == 1 then --需要消耗的技能点
				local skillCfg = self:getSkillCfgData(skillId)
				local skillPoint = self:getSkillPoint(skillCfg.tabType)
				if skillPoint < data.value then
					return false
				else
					curCount = curCount + 1
				end
			elseif data.key == 2 then --需要消耗的道具
				local itemData = FormatItem(data.value)[1]
				if itemData then
					local ownNum = bagVoApi:getItemNumId(itemData.id)
					if ownNum < itemData.num then
						return false
					else
						curCount = curCount + 1
					end
				end
			elseif data.key == 3 then --需要已使用掉的基础技能点
				local costSkillPoint = self:getCostSkillPoint(1)
				if costSkillPoint < data.value then
					return false
				else
					curCount = curCount + 1
				end
			elseif data.key == 4 then --需要已使用掉的巅峰技能点
				local costSkillPoint = self:getCostSkillPoint(2)
				if costSkillPoint < data.value then
					return false
				else
					curCount = curCount + 1
				end
			end
		end
		return (conditionTbSize > 0 and curCount == conditionTbSize)
	end
	return false
end

--获取buff配置数据
--@buffId : 爸父id
function strategyCenterVoApi:getBuffCfgData(buffId)
	local cfg = self:getStrategyCenterCfg()
	local buffCfg = cfg.strategy2.buff[buffId]
	if buffCfg then
		return buffCfg
	end
end

--获取buff的描述
--@buffId : 爸父id
--@buffLevel : 爸父等级
function strategyCenterVoApi:getBuffDesc(buffId, buffLevel)
	local buffCfg = self:getBuffCfgData(buffId)
	if buffCfg then
		local value = (buffCfg.value[buffLevel] or 0)
		if buffCfg.percent == 1 then
			value = value * 100
		end
		return getlocal(buffCfg.skillDes, {value})
	end
	return ""
end

--获取buff的解锁条件描述
--@buffId : 爸父id
--@buffLevel : 爸父等级
function strategyCenterVoApi:getBuffUnlockDesc(buffId, buffLevel)
	local descStr = ""
	local buffCfg = self:getBuffCfgData(buffId)
	if buffCfg then
		for k, skillId in pairs(buffCfg.needSkill2) do
			local skillCfg = self:getSkillCfgData(skillId)
			if skillCfg then
				local needSkillLv = 0
				local needGrade = buffCfg.needGrade[buffLevel + 1]
				if needGrade and needGrade[k] then
					needSkillLv = needGrade[k]
				end
				descStr = descStr .. getlocal(skillCfg.skillName) .. getlocal("fightLevel", {needSkillLv}) .. " "
			end
		end
	end
	return descStr
end

--获取buff等级
--@buffId : 爸父id
function strategyCenterVoApi:getBuffLevel(buffId)
	if self.buffData then
		return (self.buffData[buffId] or 0)
	end
	return 0
end

--是否为最大buff等级
--@buffId : 爸父id
--@buffLevel : 爸父等级
function strategyCenterVoApi:isMaxBuffLevel(buffId, buffLevel)
	if buffLevel > 0 then
		local buffCfg = self:getBuffCfgData(buffId)
		if buffCfg then
			return (buffCfg.value[buffLevel + 1] == nil)
		end
	end
	return false
end

--[[ @sType : 
1--基础属性
2--战斗经验增加百分比
3--坦克制造速度增加百分比
4--坦克属性增加
5--火炮属性增加
6--火箭车属性增加
7--歼击车属性增加
8--上阵坦克类型每增加一种，我方全体第一回合坚韧增加X%
9--上阵坦克类型每增加一种，我方全体第二回合起受到AI伤害减弱X%
10--上阵坦克类型每增加一种，我方全体命中增加X%
11--上阵坦克类型每增加一种，我方全体防护增加X
12--装备探索经验加成百分比
13--人物技能上限
14--声望上限
15--统帅上限
--]]
function strategyCenterVoApi:getAttributeValue(sType)
	local cfg = self:getStrategyCenterCfg()
	if cfg.mirror[sType] then
		local attrTb
		for k, id in pairs(cfg.mirror[sType]) do
			local skillCfg = self:getSkillCfgData(id)
			if skillCfg then
				local skillLv = self:getSkillLevel(id)
				if skillLv > 0 then
					if attrTb == nil then
						attrTb = {}
					end
					if skillCfg.attribute then
						for k, v in pairs(skillCfg.attribute) do
							local valueTb = skillCfg.value[k]
							if valueTb then
								local value = valueTb[1] + (skillLv - 1) * valueTb[2]
								-- if skillCfg.percent[k] == 1 then
								-- 	value = value * 100
								-- end
								if attrTb[v] then
									attrTb[v].value = attrTb[v].value + value
								else
									attrTb[v] = {["value"] = value, ["percent"] = skillCfg.percent[k]}
								end
							end
						end
					elseif sType == 3 then
						local value = skillCfg.value[1][1] + (skillLv - 1) * skillCfg.value[1][2]
						if attrTb["tankSpeed"] then
							attrTb["tankSpeed"].value = attrTb["tankSpeed"].value + value
						else
							attrTb["tankSpeed"] = {["value"] = value, ["percent"] = skillCfg.percent[1]}
						end
					end
				end
			else
				local buffCfg = self:getBuffCfgData(id)
				if buffCfg then
					local buffLv = self:getBuffLevel(id)
					if buffLv > 0 then
						return (buffCfg.value[buffLv] or 0)
					end
				end
			end
		end
		return attrTb
	end
end