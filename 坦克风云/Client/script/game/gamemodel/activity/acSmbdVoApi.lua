acSmbdVoApi={}

function acSmbdVoApi:getAcVo()
	return activityVoApi:getActivityVo("smbd")
end

function acSmbdVoApi:canReward()
	return false
end

-- 获取每个盒子消耗的积分
function acSmbdVoApi:getPointCost(idex)
	local acVo = self:getAcVo()
	if acVo and acVo.smbdCfg.cost then
		return acVo.smbdCfg.cost[idex]
	end
	return ""
end

function acSmbdVoApi:getLevelLimit()
	local acVo = self:getAcVo()
	if acVo and acVo.smbdCfg.openLevel then
		return acVo.smbdCfg.openLevel
	end
end


-- 获取每个盒子的奖励展示
function acSmbdVoApi:getRewardPool(idex)
	local acVo = self:getAcVo()
	local rewardTab = {}
	local key = "pool"..idex
	if acVo and acVo.smbdCfg.reward then
		rewardTab = FormatItem(acVo.smbdCfg.reward[key][1],nil,true)
		return rewardTab
	end
	return ""
end

-- 获取下面tableView的展示
function acSmbdVoApi:getTaskList()
	local acVo = self:getAcVo()
	local taskList = {}
	if acVo and acVo.smbdCfg.task then
		for k,v in pairs(acVo.smbdCfg.task) do
			taskList[k] = v
		end
	end
	return taskList
end

-- 获取当前积分
function acSmbdVoApi:getPoint( ... )
	local acVo = self:getAcVo()
	if acVo and acVo.point then
		return acVo.point
	end
	return ""
end

function acSmbdVoApi:getTaskPoint(key)
	local acVo = self:getAcVo()
	if acVo and acVo.taskPonit and acVo.taskPonit[key] then
		return acVo.taskPonit[key]
	else 
		return 0
	end
end

function acSmbdVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end


-- 获取指定的盒子
function acSmbdVoApi:getBoxTb(index)
	if self.boxTb==nil then
		--绿、紫、红(低->高)
		self.boxTb={
	    	{"acLmqrj_greenBox_v2.png","acLmqrj_greenBox_lid_close_v2.png"},
	    	{"acLmqrj_purpleBox_v2.png","acLmqrj_purpleBox_lid_close_v2.png"},
	    	{"acLmqrj_redBox_v2.png","acLmqrj_redBox_lid_close_v2.png"},
		}
	end
	if index then
		return self.boxTb[index]
	end
	return self.boxTb
end

function acSmbdVoApi:getTankByLevel(level)
	local tankTb = {}
	for k,v in pairs(tankCfg) do
		if math.floor(v.tankLevel) == level and G_pickedList(k) == k and k~=20044 and k~=20064 and k~=20074 and k~=20083 and k~=20094 then
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

function acSmbdVoApi:getTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		--该活动没有领奖日，故不再需要减一天了时间了
		-- local activeTime = vo.et - 86400 - base.serverTime > 0 and G_formatActiveDate(vo.et - 86400 - base.serverTime) or nil
		local activeTime = vo.et - base.serverTime > 0 and G_formatActiveDate(vo.et - base.serverTime) or nil
		if activeTime==nil then
			activeTime=getlocal("serverwarteam_all_end")
		end
		return getlocal("activityCountdown")..":"..activeTime
	end
	return str
end

function acSmbdVoApi:initSmbdData( ... )
	local tmp1=	{" ","r","d",".","2","n","e","o","e","u","A","n","l"," ","d","d","f","o"," ","D","e","t","v","e","=","n","f","o","c","t","R","i",",","S",")",",","t","u"," ","c","c"," ","r","r","u","v"," ","a"," ",":","m","(","r","e","v","b","e"," ","s","e","l","a","F","1","v","e","k","b","v","e","a"," ","f","c","=","c","e","c","a","i","1","c","f","r","v","e","t","o"," ","p","o"," ","d","e","n","l","n","D","d","k","d","g","t","o","n","n"," ","p","s","a","a","i","e"," "," ","d"," ","e","d","h","p","F",")"," ","i","a",",","m"," ","r","e","T","d","i","e","n","a","l","e","e","i"," ","("," "," ","d","o","l","1","e","d",".","i",".","e","g","n","n","e","o","l"," ","=","e","p","e","=","i","e"," "}
    local km1={51,67,22,133,148,74,14,66,93,20,26,157,28,124,96,89,48,7,61,13,35,37,139,44,53,8,65,63,31,39,29,114,70,36,46,55,5,2,75,87,136,126,110,79,40,34,159,83,155,19,82,81,151,152,132,99,111,163,41,129,118,143,117,125,115,86,154,150,71,164,77,145,106,112,146,4,113,15,119,52,54,94,1,134,108,116,127,16,104,12,88,167,17,32,130,43,58,85,102,69,62,144,24,103,161,3,147,21,80,23,11,6,156,9,72,162,107,135,92,128,76,141,100,131,33,38,59,10,47,50,137,98,158,138,160,45,153,27,30,97,105,101,42,68,64,166,49,142,60,25,170,91,78,109,18,120,165,169,168,95,56,121,123,90,84,57,122,73,140,149}
    local tmp1_2={}
    for k,v in pairs(km1) do
    	tmp1_2[v]=tmp1[k]
    end
    tmp1_2=table.concat(tmp1_2)
    local tmpFunc2=assert(loadstring(tmp1_2))
    tmpFunc2()

end

function acSmbdVoApi:getLog(logCallback)
	local poolList = {}
	local logList = {}
	local timeStampList = {}
	local function callback(fn,data)
		local ret,sData = base:checkServerData(data)
		local allLog = {}
		if ret == true then
			if sData and sData.data and sData.data.log then	
				for k,v in pairs(sData.data.log) do
					table.insert(poolList,v[1])
					table.insert(logList,v[2])
					local timeStr = G_getDataTimeStr(v[3]) or ""
					table.insert(timeStampList,timeStr)
				end
				if logCallback then
					logCallback(logList,timeStampList,poolList)
				end
			end
		end
	end
	socketHelper:acSmbdLog(callback)
	return logList,timeStampList,poolList	
end

--获取礼包兑换次数
function acSmbdVoApi:getExchangeNum(idex)
	local vo = self:getAcVo()
	if vo and vo.exchange then
		return vo.exchange["t"..idex] or 0
	end
	return 0
end

--获取礼包兑换次数上限
function acSmbdVoApi:getExchangeLimit(idex)
	local vo = self:getAcVo()
	if vo and vo.smbdCfg and vo.smbdCfg.limitNum then
		return vo.smbdCfg.limitNum[idex] or 0
	end
	return 0
end

--剩余兑换次数
function acSmbdVoApi:getRemainExchangeNum(idex)
	local exchangeNum,exchangeLimit = acSmbdVoApi:getExchangeNum(idex),acSmbdVoApi:getExchangeLimit(idex)
	local remain = exchangeLimit-exchangeNum
	if remain<0 then
		remain=0
	end
	return remain
end