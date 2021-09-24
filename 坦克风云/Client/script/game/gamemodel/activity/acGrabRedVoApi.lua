acGrabRedVoApi={}

function acGrabRedVoApi:getAcVo()
	return activityVoApi:getActivityVo("grabRed")
end

function acGrabRedVoApi:getAcRewardCfg()
	local acVo=self:getAcVo()
	if acVo ~= nil and acVo.reward ~= nil then
		return acVo.reward
	end
	return {}
end

function acGrabRedVoApi:getVersion( )
	local acVo = self:getAcVo()
	if acVo and acVo.version then
		return acVo.version
	end
	return 1
end
function acGrabRedVoApi:getPackageCost()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.cost
	end
	return 99999
end

function acGrabRedVoApi:getInitPoint()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.conditiongems
	end
	return 0
end

function acGrabRedVoApi:getPointUseDiscount()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.value
	end
	return 0
end

-- 得到当前用户的代币数
function acGrabRedVoApi:getCurrentPoint()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.v
	end
	return 0
end

-- 抢红包后添加获得的代币数
function acGrabRedVoApi:addCurrentPoint(addValue)
	local acVo = self:getAcVo()
	if acVo ~= nil then
	    acVo.v = acVo.v + addValue
	end
end

-- 判断该红包是否已经抢夺到了
function acGrabRedVoApi:checkIfGrabedByRedid(redid)
	local acVo = self:getAcVo()
	if acVo ~= nil then
	    local grabed = acVo.grabed
	    if grabed ~= nil then
	    	for k,v in pairs(grabed) do
	    		if tonumber(v) == tonumber(redid) then
	    			return true
	    		end
	    	end
	    end
	end
	return false
end

-- 更新已抢夺红包id集合
function acGrabRedVoApi:updateGrabed(redid)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		if redid > 0 then
			table.insert(acVo.grabed, redid)
		end
	end
end

-- 得到当前用户购买礼包的现价
function acGrabRedVoApi:getNowCost()
	local costGems=tonumber(self:getPackageCost())
    local hadPoints = tonumber(self:getCurrentPoint())
    if hadPoints > 0 then
        local pointDiscount = costGems * self:getPointUseDiscount()
        if hadPoints > pointDiscount then
            costGems = costGems - pointDiscount
        else
            costGems = costGems - hadPoints
        end
    end
    return costGems
end

function acGrabRedVoApi:getPropId()
	-- "reward":{"p":[{"p1075":1,"index":1}]}
	local cfg = self:getAcRewardCfg()
	local pCfg = cfg.p
	if pCfg ~= nil then
		local pCfg2 = pCfg[1]
		if pCfg2 ~= nil then
			for k,v in pairs(pCfg2) do
				if k ~= "index" then
					return k,v
				end
			end
		end
	end
	return nil,nil
end

-- 得到宝箱中所有的奖励，用于显示
function acGrabRedVoApi:getRewardsInPackage()
	local propId = self:getPropId()
    local packageCfg = propCfg[propId]
    if packageCfg ~= nil then
    	local useGetProp = packageCfg.useGetProp
    	local useGetTroops = packageCfg.useGetTroops
    	local rewards = {}
    	if useGetProp ~= nil then
    		local props = {}
    		local i = 1
    		for k,v in pairs(useGetProp) do
    			local prop = {}
    			prop["p"..RemoveFirstChar(v[1])] = v[2]
    			prop["index"] = i
    			table.insert(props, prop)
    			i = i + 1
    		end
    		rewards["p"] = props
    	end

    	if useGetTroops ~= nil then
    		local troops = {}
    		local i = 1
    		for k,v in pairs(useGetTroops) do
    			local troop = {}
    			troop["a"..RemoveFirstChar(k)] = v
    			troop["index"] = i
    			table.insert(troops, troop)
    			i = i + 1
    		end
    		rewards["o"] = troops
    	end
    	return rewards
    end
    return {}    
end

function acGrabRedVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.et)
	return timeStr
end


function acGrabRedVoApi:canReward()
	return false
end


function acGrabRedVoApi:afterBuyPackage()
	local costGems=tonumber(self:getPackageCost())
    local hadPoints = tonumber(self:getCurrentPoint())
    local costPoints = 0
    if hadPoints > 0 then
        local pointDiscount = costGems * self:getPointUseDiscount()
        if hadPoints > pointDiscount then
        	costPoints = pointDiscount
        else
        	costPoints = hadPoints
        end
        costGems = costGems - costPoints
    end

	local playerGem=playerVoApi:getGems()
	playerGem=playerGem - costGems
	playerVoApi:setGems(playerGem)

    

	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.v >= costPoints then
		acVo.v = acVo.v - costPoints
	end
end

function acGrabRedVoApi:getGrabMaxNum()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.maxcount
	end
	return 0
end

function acGrabRedVoApi:updateLog(data)
	if data.grablog ~= nil then
		self.grablog = data.grablog
	else
		self.grablog = {}
	end

	if data.useredbag ~= nil then
		self.useredbag = data.useredbag
	else
		self.useredbag = {}
	end
end

function acGrabRedVoApi:getGrabSharer()
	return self.useredbag
end
-- 获取红包领取记录
function acGrabRedVoApi:getGrabRecode()
	-- return {{name = "张三", get = 33},{name = "李四", get = 67},{name = "王五", get = 50},{name = "王六", get = 55},{name = "王七", get = 60}} -- todo 测试数据
	return self.grablog
end

function acGrabRedVoApi:checkIfGrabOver()
	local recode = self:getGrabRecode()
	if recode ~= nil then
		local len = SizeOfTable(recode)
		if len >= self:getGrabMaxNum() then
			return true
		end
	end
	return false
end