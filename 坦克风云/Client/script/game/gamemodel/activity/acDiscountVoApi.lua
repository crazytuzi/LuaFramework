acDiscountVoApi = {}

function acDiscountVoApi:getAcVo()
	return activityVoApi:getActivityVo("discount")
end

function acDiscountVoApi:canReward()
	return false
end

function acDiscountVoApi:getVersion()
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1
end

function acDiscountVoApi:getDiscountProp()
	local vo = self:getAcVo()
	local prop = {}
	if vo ~= nil and vo.props ~= nil then
       for k,v in pairs(vo.props) do
		table.insert(prop, {id = k, dis = v, gemCost=propCfg[k].gemCost*v })
	   end
	end
	local function sortAsc(a, b)
		return a.gemCost > b.gemCost
	end
	table.sort(prop,sortAsc)
	return prop
end

function acDiscountVoApi:getDiscountMaxCountById(pid)
	local vo = self:getAcVo()
	for k,v in pairs(vo.maxCount) do
		if k and k == pid then
           return tonumber(v)
		end
	end
	return 0
end

function acDiscountVoApi:getDiscountCountById(pid)
	local vo = self:getAcVo()
	if type(vo.t)=="table" then
		for k,v in pairs(vo.t) do
		   if k and k == pid then
              return tonumber(v)
		   end
	    end
	    return 0
	end
	return 0
end

function acDiscountVoApi:addBuyNum(id,num)
	local vo = self:getAcVo()
	local had = false
	if type(vo.t)=="table" then
		for k,v in pairs(vo.t) do
		   if k and k == id then
		   	had = true
            local maxCount = self:getDiscountMaxCountById(id)
            if vo.t[k] < maxCount then
            	vo.t[k] = tonumber(v) + num
            end
		   end
	    end
	else
		vo.t = {}
	end

	if had == false then
	    local maxCount = self:getDiscountMaxCountById(id)
        if num <= maxCount then
            vo.t[id] = num
        end
	end
end
