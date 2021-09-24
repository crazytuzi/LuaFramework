acXssdVoApi = {
	name="",
}

function acXssdVoApi:setActiveName(name)
	self.name=name
end

function acXssdVoApi:getActiveName()
	return self.name
end

function acXssdVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acXssdVoApi:canReward(activeName)
	local vo=self:getAcVo(activeName)
	if not vo then
		return false
	end
	if not vo.activeCfg then
		return false
	end
	return false
end


function acXssdVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acXssdVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end

function acXssdVoApi:getShop(activeName)
	local vo=self:getAcVo(activeName)
	if vo and vo.activeCfg then
		return vo.activeCfg.shop
	end
	return {}
end

function acXssdVoApi:getSortShop(activeName)
	local vo=self:getAcVo(activeName)
	local shop=vo.activeCfg.shop
	local buyLog=vo.b or {}
	local trueShop={}
	-- RemoveFirstChar(prop.key)
	for k,v in pairs(shop) do
		local index=tonumber(RemoveFirstChar(k))
		local limit=v[1]
		local buyNum=buyLog[k] or 0
		if buyNum>=limit then
			index=index+1000
		end
		local subTb={index=index,id=k}
		table.insert(trueShop,subTb)
	end
	local function sortFunc(a,b)
		return a.index<b.index
	end
	table.sort(trueShop,sortFunc)


	return trueShop
end

function acXssdVoApi:socketReward(id,refreshFunc)
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
	socketHelper:acxssdReward(id,callback)
end

function acXssdVoApi:refreshClear()
	local vo=self:getAcVo()
	vo.b={}
	vo.lastTime=base.serverTime
end

function acXssdVoApi:addActivieIcon()
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/bubbleImage.plist")
end

function acXssdVoApi:removeActivieIcon()
end

function acXssdVoApi:clearAll()
	self.name=""
end


