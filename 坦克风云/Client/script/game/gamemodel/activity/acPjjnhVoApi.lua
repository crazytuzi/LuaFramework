acPjjnhVoApi = {
	name="",
	logFlag={},
}

function acPjjnhVoApi:setActiveName(name)
	self.name=name
end

function acPjjnhVoApi:getActiveName()
	return self.name
end

function acPjjnhVoApi:getVersion( )
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1
end

-- 每日进游戏检查是否需要请求log
function acPjjnhVoApi:logFlagByName()
	local flag = self.logFlag[self.name]
	if flag==nil or flag==0  then
		return 0
	end
	return flag
end

function acPjjnhVoApi:setLogFlag()
	self.logFlag[self.name]=1
end

function acPjjnhVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acPjjnhVoApi:canReward(activeName)
	local isfree=true
	local vo = self:getAcVo(activeName)
	if vo and vo.f and vo.f==1 then --是否是第一次免费
		isfree=false
	end				
	-- if self:isToday()==true then
	-- 	isfree=false
	-- end
	return isfree
end

function acPjjnhVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acPjjnhVoApi:getCostByType(type)
	local acVo = self:getAcVo()
	if acVo then
		if type==1 then
			return acVo.cost1
		else
			return acVo.cost2
		end
	end
	return 0
end

function acPjjnhVoApi:getRlog()
	local acVo = self:getAcVo()
	if acVo then
		return acVo.rlog
	end
	return 0
end

-- 任务列表，状态
function acPjjnhVoApi:getTask()
	local vo = self:getAcVo()
	if vo and vo.task then
		local task = {}
		for k,v in pairs(vo.task) do
			local taskId = v[1] -- 任务id(t1)
			local tid = k
			local taskNum = v[2] -- 任务需完成数量
			local reward = FormatItem(v[4],nil,true) --奖励
			local index = k+100
			local alreadyNum=vo[taskId] or 0
			
			local isReceive = 3 -- 1 已领取 2 可领取 3 不能领取（没有达到领取条件）
			if vo.tr then
				for kk,vv in pairs(vo.tr) do
					if k==vv then
						index=index+100
						isReceive=1
						break
					end
				end
			end
			if isReceive~=1 then
				if alreadyNum>=taskNum then
					index=index-100
					isReceive=2
				end
			end

			local des
			if isReceive==3 then
				des=getlocal("activity_pjjnh_taskDes_" .. taskId,{alreadyNum .. "/" .. taskNum})
			else
				des=getlocal("activity_pjjnh_taskDes_" .. taskId,{taskNum .. "/" .. taskNum})
			end

			local info={index=index,taskId=taskId,tid=tid,taskNum=taskNum,des=des,reward=reward,isReceive=isReceive}
			table.insert(task,info)
		end
		local function sortFunc(a,b)
			return a.index<b.index
		end
		table.sort(task,sortFunc)
		return task
	end
	return {}
end


function acPjjnhVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end

function acPjjnhVoApi:getBgImg()
	local acVo = self:getAcVo()
	if acVo then
		return acVo.bgImg
	end
	return 1
end

function acPjjnhVoApi:getAcIcon(activeName)
	-- local acVo = self:getAcVo(activeName)
	-- if acVo then
	-- 	return acVo.acIcon
	-- end
	return "Icon_novicePacks"
end

function acPjjnhVoApi:setF(flag)
	local acVo = self:getAcVo()
	if acVo then
		acVo.f=flag
	end
end

function acPjjnhVoApi:resertTask()
	local acVo = self:getAcVo()
	if acVo then
		if acVo.t1 then
			acVo.t1=0
		end
		if acVo.t2 then
			acVo.t2=0
		end
		if acVo.t3 then
			acVo.t3=0
		end
		if acVo.tr then
			acVo.tr={}
		end
	end
end

function acPjjnhVoApi:getNameType(activeName)
	local acVo = self:getAcVo(activeName)
	if acVo and acVo.nameType then
		return acVo.nameType
	end
	return 1
end

function acPjjnhVoApi:getFlickReward()
	local acVo = self:getAcVo()
	if acVo then
		return acVo.flickReward
	end
	return {}
end

function acPjjnhVoApi:showSmallDialog(layerNum,flag)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acPjjnhSmallDialog"
	local sd = acPjjnhSmallDialog:new()
	sd:init(true,true,layerNum,flag)
end

function acPjjnhVoApi:clearAll()
	self.name=""
	for k,v in pairs(self.logFlag) do
		self.logFlag[k]=nil
	end
	self.logFlag={}
end