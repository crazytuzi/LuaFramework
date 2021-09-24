acArmoredStormVoApi = {
	name="",
}

function acArmoredStormVoApi:setActiveName(name)
	self.name=name
end

function acArmoredStormVoApi:getActiveName()
	return self.name
end

function acArmoredStormVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
    spriteController:addTexture("public/activeCommonImage1.png")
end

function acArmoredStormVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
    spriteController:removeTexture("public/activeCommonImage1.png")
end

function acArmoredStormVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acArmoredStormVoApi:getVersion()
	local acVo = self:getAcVo()
	if acVo and acVo.version then
		return acVo.version
	end
	return 1
end

function acArmoredStormVoApi:canReward(activeName)
	local vo=self:getAcVo(activeName)
	if not vo then
		return false
	end
	if not vo.activeCfg then
		return false
	end
	local task1=acArmoredStormVoApi:getTaskTb1(activeName)
	for k,v in pairs(task1) do
		if v.index<1000 then
			return true
		end
	end
	local task2=acArmoredStormVoApi:getTaskTb2(activeName)
	for k,v in pairs(task2) do
		if v.index<1000 then
			return true
		end
	end
	return false
end



function acArmoredStormVoApi:isFree(activeName)
	local acVo=self:getAcVo(activeName)
	if acVo.lastTime and G_isToday(acVo.lastTime)==false then
		return true
	else
		return false
	end
end

function acArmoredStormVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acArmoredStormVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end



function acArmoredStormVoApi:getTaskTbByType(flag)
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		if flag==1 then
			return vo.activeCfg.task1
		else
			return vo.activeCfg.task2
		end
	end
	return {}
end

-- 排好序
function acArmoredStormVoApi:getTaskTb1(activeName)
	local vo=self:getAcVo(activeName)
	local task1=vo.activeCfg.task1
	local r1=vo.r1 or {}
	local t1=vo.t1 or 0

	local trueTask={}
	for k,v in pairs(task1) do
		local subTb={trueIndex=v[1]}
		local index=v[1]
		local haveNum=t1 or 0
		if self:checkContent(v[1],r1) then
			index=v[1]+10000
			haveNum=v[2]
		else
			local needNum=v[2]
			-- print("haveNum---needNum---->",haveNum,needNum)
			if haveNum>=needNum then
				index=v[1]
				haveNum=needNum
			else
				index=v[1]+1000
				haveNum=haveNum
			end

		end
		subTb.index=index
		subTb.haveNum=haveNum
		table.insert(trueTask,subTb)
	end
	local function sortFunc(a,b)
		return a.index<b.index
	end
	table.sort(trueTask,sortFunc)

	return trueTask
end

function acArmoredStormVoApi:getTaskTb2(activeName)
	local vo=self:getAcVo(activeName)
	local task1=vo.activeCfg.task2
	local r1=vo.r2 or {}
	local t1=vo.v or 0

	local trueTask={}
	for k,v in pairs(task1) do
		local subTb={trueIndex=v[1]}
		local index=v[1]
		local haveNum=t1 or 0
		if self:checkContent(v[1],r1) then
			index=v[1]+10000
			haveNum=v[2]
		else
			local needNum=v[2]
			
			if haveNum>=needNum then
				index=v[1]
				haveNum=needNum
			else
				index=v[1]+1000
				haveNum=haveNum
			end

		end
		subTb.index=index
		subTb.haveNum=haveNum
		table.insert(trueTask,subTb)
	end
	local function sortFunc(a,b)
		return a.index<b.index
	end
	table.sort(trueTask,sortFunc)

	return trueTask
end

function acArmoredStormVoApi:checkContent(value,rTb)
	for k,v in pairs(rTb) do
		if value==v then
			return true
		end
	end
	return false
end

function acArmoredStormVoApi:socketReward(action,method,refreshFunc)
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
	socketHelper:acArmoredStormReward(action,method,callback)
end

function acArmoredStormVoApi:isFlick(ptype,key,value)
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.flickReward then
		local flickReward=vo.activeCfg.flickReward or {p={{p4604=1},{p4604=2}}}
		for k,v in pairs(flickReward) do
			if ptype==k then
				for kk,vv in pairs(v) do
					for kkk,vvvv in pairs(vv) do
						if key==kkk and value==vvvv then
							return true
						end
					end
				end
			end

		end
	end
	return false
end

function acArmoredStormVoApi:clearAll()
	self.name=""
end


