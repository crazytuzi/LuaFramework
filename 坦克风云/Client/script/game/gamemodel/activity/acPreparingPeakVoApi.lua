acPreparingPeakVoApi = {}

function acPreparingPeakVoApi:getAcVo()
	return activityVoApi:getActivityVo("preparingPeak")
end

function acPreparingPeakVoApi:canReward()
	return false
end

function acPreparingPeakVoApi:getDiscountProp()
	local vo = self:getAcVo()
	local prop = {}
	if vo ~= nil and vo.props ~= nil then
       for k,v in pairs(vo.props) do
		table.insert(prop, {id = v.gift, dis = v.discount, gemCost=math.ceil(propCfg[v.gift].gemCost*v.discount)})
	   end
	end
	--[[local function sortAsc(a, b)
		return a.gemCost > b.gemCost
	end
	table.sort(prop,sortAsc)--]]
	return prop
end

function acPreparingPeakVoApi:getDiscountMaxCountById(pid)
	local vo = self:getAcVo()
	for k,v in pairs(vo.props) do
		if v and v.gift and v.gift == pid and v.num then
           return tonumber(v.num)
		end
	end
	return 0
end

function acPreparingPeakVoApi:getDiscountCountById(pid)
	local vo = self:getAcVo()
	if type(vo.reward)=="table" then
		for k,v in pairs(vo.reward) do
		   if k and k == pid then
              return tonumber(v)
		   end
	    end
	    return 0
	end
	return 0
end

function acPreparingPeakVoApi:addBuyNum(id,num)
	local vo = self:getAcVo()
	local had = false
	if type(vo.reward)=="table" then
		for k,v in pairs(vo.reward) do
		   if k and k == id then
		   	had = true
            local maxCount = self:getDiscountMaxCountById(id)
            if vo.reward[k] < maxCount then
            	vo.reward[k] = tonumber(v) + num
            end
		   end
	    end
	else
		vo.reward = {}
	end

	if had == false then
	    local maxCount = self:getDiscountMaxCountById(id)
        if num <= maxCount then
            vo.reward[id] = num
        end
	end
end
function acPreparingPeakVoApi:updateBuyData()
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = base.serverTime
		vo.reward = {}
	end
end
--今日是否重置过
function acPreparingPeakVoApi:isToday()
	local ecVo=self:getAcVo()
	if ecVo then
		local lastTs=ecVo.lastTime or 0 --上一次重置时间
		return G_isToday(lastTs)
	end
	return true
end
