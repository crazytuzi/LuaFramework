acArmsRaceVoApi = {
	page=0,
	perPageNum=5,
	maxPage=10,
}

function acArmsRaceVoApi:getAcVo()
	return activityVoApi:getActivityVo("armsRace")
end

function acArmsRaceVoApi:getAcCfg()
	local acVo=self:getAcVo()
	if acVo and acVo.reward then
		return acVo.reward
	end
	return {}
end

-- 根据要生产的坦克类型获得某一条配置数据
function acArmsRaceVoApi:getCfgByType(tankId)
	local cfg = self:getAcCfg()
	if cfg ~= nil then
		-- return cfg[type]
		for k,v in pairs(cfg) do
			if v ~= nil and v.tankId == tankId then
				return v
			end 
		end
	end
	return nil
end

function acArmsRaceVoApi:getCfgById(id)
	local cfg = self:getAcCfg()
	if cfg ~= nil then
        for k, v in pairs(cfg) do
        	if v.id == id then
        		return v
        	end 
        end
	end
	return nil
end


function acArmsRaceVoApi:cfgSort()
	local cfg = self:getAcCfg()
	if cfg ~= nil then
		local function sortFunc(a,b)
			if a ~= nil and b ~= nil then
				local aCanReward = self:checkIfCanRewardById(a.id)
				local bCanReward = self:checkIfCanRewardById(b.id)
				if aCanReward == true and bCanReward == false then
					return true -- a 应该排在b 前头
				elseif aCanReward == false and bCanReward == true then
					return false
				elseif a.id < b.id then
					return true
				end
				return false
			end
		end
        table.sort(cfg,sortFunc)
	end
end

function acArmsRaceVoApi:getCfgByIndex(index)
	local cfg = self:getAcCfg()
	if cfg ~= nil then
		local i = 1
		for k,v in pairs(cfg) do
			if i == index then
				return v
			end
            i = i + 1
		end
	end
end

-- 是否有可以领取的奖励
function acArmsRaceVoApi:canReward()
	local cfg = self:getAcCfg()
	if cfg ~= nil then
		for k,v in pairs(cfg) do
			if v ~= nil and self:getProduceNumByType(v.tankId) >= v.n then
				return true
			end
		end
	end
	return false
end

function acArmsRaceVoApi:checkIfCanRewardById(id)
	local cfg = self:getCfgById(id)
	if cfg ~= nil then
		if self:getProduceNumByType(cfg.tankId) >= cfg.n then
			return true
		end
	end
	return false
end

-- 获得领奖记录
function acArmsRaceVoApi:getRecode()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.recode ~= nil then
		return acVo.recode
	end
	return nil
end

-- 领奖记录的个数
function acArmsRaceVoApi:getRecodeNum()
	local recode = self:getRecode()
	if recode ~= nil then
		return SizeOfTable(recode)
	end
	return 0
end

-- 得到某坦克的生产个数
function acArmsRaceVoApi:getProduceNumByType(type)
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.produceData ~= nil then
		for k,v in pairs(acVo.produceData) do
			if k ~= nil and k == tostring(type) then
				return v
			end
		end
	end
	return 0
end

function acArmsRaceVoApi:getRewardById(id)
	local cfg = self:getCfgById(id)
	if cfg ~= nil then
		local reward = {o={}}
		reward.o[1][cfg.r] = cfg.num
		return reward
	end
	return nil
end

function acArmsRaceVoApi:afterGetReward(id, num)
	local cfg = self:getCfgById(id)
	local acVo = self:getAcVo()
	local useTankNum = math.floor(num / cfg.num) * cfg.n
	if acVo ~= nil and acVo.produceData ~= nil and cfg ~= nil then
		for k,v in pairs(acVo.produceData) do
			if k and cfg.tankId ~= nil and k == cfg.tankId and v >= useTankNum then
				acVo.produceData[k] = v - useTankNum
				activityVoApi:updateShowState(acVo)
				acVo.stateChanged = true -- 强制更新数据
			end
		end
	end
end

function acArmsRaceVoApi:isHasMore()
	local msgNum=self:getRecodeNum()
	if msgNum >= self.perPageNum and self.page < self.maxPage then
		return true
	end
	return false
end

function acArmsRaceVoApi:getPage()
	return self.page
end

function acArmsRaceVoApi:afterGetMoreRecode(recodes)
	self.page = self.page + 1
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo:addMoreRecode(recodes)
	end
end


function acArmsRaceVoApi:updateLog(data)
	local acVo = self:getAcVo()
	if acVo then
		acVo:updateSpecialData(data)
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged = true
	end
end


