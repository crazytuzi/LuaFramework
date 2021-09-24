-- @Author hj
-- @Date 2018-10-18
-- @Description 限时挑战数据处理模型

limitChallengeVoApi = {
	version = nil,
}

function limitChallengeVoApi:updateData(data)
	limitChallengeVo:updateData(data)
	self.version = self:getVersion()
	-- if #taskTb > 0 then
	-- 	do return end
	-- else
	-- end
end


function limitChallengeVoApi:getVo( ... )
	return dailyActivityVoApi:getActivityVo("xstz")
end

-- 获取任务对应的tank等级
function limitChallengeVoApi:getTankByLevel(level)
	local tankTb = {}
	for k,v in pairs(tankCfg) do
		if math.floor(v.tankLevel) == level and G_pickedList(k) == k and k~=20044 and k~=20064 and k~=20074 and k~=20083 and k~=20094 and k~= 10103 and k ~= 50103 and k~= 10104 and k ~= 50104 then
			local key=tonumber(k) or tonumber(RemoveFirstChar(k))
			table.insert(tankTb,{key=key,sortId=tonumber(v.sortId)})
		end
	end
	local function sortFunc(a,b)
		local fight1=a.sortId or 0
		local fight2=b.sortId or 0
		return fight1>fight2
	end
	table.sort(tankTb,sortFunc)
	return tankTb
end

-- 1->普通 2->地狱
function limitChallengeVoApi:showDialog(flag,layerNum)

	if flag == 1 then
		local titleStr = getlocal("limitNormalChanllenge")
	    local sd = normalChallengeDialog:new()
	    local dialog = sd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,titleStr,true,layerNum+5);
	    sceneGame:addChild(dialog,layerNum+5)
	else
		local titleStr = getlocal("limitHellChanllenge")
	    local sd = hellChallengeDialog:new()
	    local dialog = sd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,titleStr,true,layerNum+5);
	    sceneGame:addChild(dialog,layerNum+5)
	end
end

function limitChallengeVoApi:getTimeStr( ... )
	local str=""
	local vo=self:getVo()
	if vo and vo.ts then
		local activeTime = vo.ts - base.serverTime 
		-- print("activeTime>>>>",base.serverTime,vo.ts,activeTime)
		if activeTime <= 0 then
			str = getlocal("serverwarteam_all_end")
		elseif activeTime <= (3600*3-300) then
			str =  getlocal("limitChanllengeTime")..": ".. G_formatActiveDate(activeTime)
		else
			str =  getlocal("limitChanllengeOpenTime")..": ".. G_formatActiveDate(activeTime-10500)
		end
	end
	return str
end

function limitChallengeVoApi:refresh( ... )
	local vo=self:getVo()
	if vo and vo.ts then
		if vo.ts - base.serverTime <= 0 then
			return true
		end
	end
	return false
end

function limitChallengeVoApi:getNormalRankData( ... )
	local rankTb = {}
	if self.version then
		rankTb = xstzCfg[self.version]["rankReward1"]
		return rankTb
	end
end


function limitChallengeVoApi:getRankNum( ... )
	local rankNum = 0
	if self.version then
		rankNum = xstzCfg[self.version].rankingNum
		return rankNum
	end
end

function limitChallengeVoApi:getHellRankData( ... )
	local rankTb = {}
	if self.version then
		rankTb = xstzCfg[self.version]["rankReward2"]
		return rankTb
	end
end

function limitChallengeVoApi:getNpoint( ... )
	local vo = self:getVo()
	if vo.npoint then
		return vo.npoint
	end
end


function limitChallengeVoApi:getHpoint( ... )
	local vo = self:getVo()
	if vo.hpoint then
		return vo.hpoint
	end
end


function limitChallengeVoApi:getRewardNormalDetail( ... )
	local version = 1
	local levelGroup = 1
	local poolGroup = self:getRewardNormalTnum()
	local vo = self:getVo()
	if vo and vo.cfg then
		if vo.cfg[1] then
			version = vo.cfg[1]
		end
		if vo.cfg[2] then
			levelGroup = vo.cfg[2]
		end
	end
	if vo and vo.ninfo and vo.ninfo.i then
		poolGroup = vo.ninfo.i
	end
	return xstzCfg[version]["pool1"][poolGroup][levelGroup]
end

function limitChallengeVoApi:getRewardHellDetail( ... )
	local version = 1
	local levelGroup = 1
	local poolGroup = self:getRewardHellTnum()
	local vo = self:getVo()
	if vo and vo.cfg then
		if vo.cfg[1] then
			version = vo.cfg[1]
		end
		if vo.cfg[2] then
			levelGroup = vo.cfg[2]
		end
	end
	return xstzCfg[version]["pool2"][poolGroup][levelGroup]
end

function limitChallengeVoApi:getRewardHellTnum( ... )
	local poolGroup 
	local vo = self:getVo()
	if vo and vo.hinfo and vo.hinfo.i then
		poolGroup = vo.hinfo.i
	end
	return poolGroup
end

function limitChallengeVoApi:getRewardNormalTnum(... )
	local poolGroup 
	local vo = self:getVo()
	if vo and vo.ninfo and vo.ninfo.i then
		poolGroup = vo.ninfo.i
	end
	return poolGroup
end

function limitChallengeVoApi:getGiftStatus( ... )

end


-- 获取普通任务列表
function limitChallengeVoApi:getNormalTask( ... )

	local taskTb = {}
	local pointTb = {}
	local showTb = {}
	local vo = self:getVo()
	if vo.ninfo and vo.ninfo.t then
		for k,v in pairs(vo.ninfo.t) do
			self:formatTask(k,v,taskTb,pointTb)
		end
	end



	for k,v in pairs(taskTb) do
		table.insert(showTb,k)
	end

	local function sortAsc(a,b)
		if tonumber(RemoveFirstChar(a)) ~= tonumber(RemoveFirstChar(b)) then
			return tonumber(RemoveFirstChar(a)) < tonumber(RemoveFirstChar(b))
		end
	end
	table.sort(showTb,sortAsc)

	return taskTb,pointTb,showTb

end

-- 获取地狱务列表
function limitChallengeVoApi:getHellTask( ... )

	local showTb = {}
	local taskTb = {}
	local pointTb = {}
	local vo = self:getVo()
	if vo.hinfo and vo.hinfo.t then
		for k,v in pairs(vo.hinfo.t) do
			self:formatTask(k,v,taskTb,pointTb)
		end
	end

	for k,v in pairs(taskTb) do
		table.insert(showTb,k)
	end

	local function sortAsc(a,b)
		if tonumber(RemoveFirstChar(a)) ~= tonumber(RemoveFirstChar(b)) then
			return tonumber(RemoveFirstChar(a)) < tonumber(RemoveFirstChar(b))
		end
	end
	table.sort(showTb,sortAsc)

	return taskTb,pointTb,showTb
end

function limitChallengeVoApi:formatTask(ttype,point,taskTb,pointTb)
	local taskType = xstzCfg[1]["taskType"]	
	for k,v in pairs(taskType) do
		for kk,vv in pairs(v) do
			if vv == ttype then
				local key = "g"..k
				if taskTb[key] and pointTb[key] then
					table.insert(taskTb[key],vv)
					pointTb[key] = pointTb[key] + point
				else
 					local tempTb = {}
 					table.insert(tempTb,vv)
 					taskTb[key]=tempTb
 					local pnum = point
 					pointTb[key] = point
				end
			end 
		end
	end

end

function limitChallengeVoApi:getVersion( ... )
	local version = 1
	local vo = self:getVo()
	if vo.cfg then
		if vo.cfg[1] then
			version = vo.cfg[1]
		end
	end
	return version
end

function limitChallengeVoApi:getTaskCfg(key)
	local version = self:getVersion()
	local task = xstzCfg[version].task[key]
	return task
end


function limitChallengeVoApi:clearAll()
	if self.version then
		self.version = nil
	end
end