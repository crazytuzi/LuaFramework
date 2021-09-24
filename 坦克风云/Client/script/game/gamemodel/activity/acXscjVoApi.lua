acXscjVoApi = {
	name="",
}

function acXscjVoApi:setActiveName(name)
	self.name=name
end

function acXscjVoApi:getActiveName()
	return self.name
end

function acXscjVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acXscjVoApi:canReward(activeName)
	local vo=self:getAcVo(activeName)
	if not vo then
		return false
	end
	if not vo.activeCfg then
		return false
	end
	local alreadyT=vo.alreadyT or {}
	local reward=vo.activeCfg.reward
	local buildVo=buildingVoApi:getBuildingVoByBtype(7)[1]
	local nowLevel=buildVo.level or 1

	local havaNum=SizeOfTable(alreadyT)
	local num=0
	for k,v in pairs(reward) do
		if nowLevel>=v.lv then
			num=num+1
		end
		if num>havaNum then
			return true
		end

	end
	return false
end


function acXscjVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acXscjVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end

function acXscjVoApi:getReward(activeName)
	local vo=self:getAcVo(activeName)
	if vo and vo.activeCfg then
		return vo.activeCfg.reward
	end
	return {}
end

-- state:1 可以领取 10：未达到 100：已领取
function acXscjVoApi:taskState(needLevel,taskIndex)
	local buildVo=buildingVoApi:getBuildingVoByBtype(7)[1]
	local nowLevel=buildVo.level or 1
	if nowLevel>=needLevel then
		local vo=self:getAcVo()
		local alreadyT=vo.alreadyT or {}
		for k,v in pairs(alreadyT) do
			if tonumber(needLevel)==tonumber(v) then
				return 100
			end
		end
		return 1
	else
		
		return 10
	end
end

function acXscjVoApi:socketReward(level,refreshFunc)
	local function callback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data[self.name] then
				self:updateData(sData.data[self.name])
			end
			if refreshFunc then
				refreshFunc()
			end
		end
	end
	socketHelper:getXscjReward(level,callback)
end




function acXscjVoApi:addActivieIcon()
end

function acXscjVoApi:removeActivieIcon()
end

function acXscjVoApi:clearAll()
	self.name=""
end


