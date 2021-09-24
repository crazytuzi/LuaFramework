-- @Author hj
-- @Description 巡练有素质数据处理模型
-- @Date 2018-06-11

acXlysVoApi = {
	log = nil,
}

function acXlysVoApi:getAcVo()
	return activityVoApi:getActivityVo("xlys")
end

function acXlysVoApi:canReward()
	if self:getTaskDoneNum() > 0 or self:getFirstFree() == 0 then
		return true
	else
		return false
	end
end

-- 获取倒计时
function acXlysVoApi:getAcTimeStr( ... )
	local str=""
	local vo=self:getAcVo()
	if vo then
		local activeTime = vo.et - base.serverTime > 0 and G_formatActiveDate(vo.et - base.serverTime) or nil
		if activeTime==nil then
			activeTime=getlocal("serverwarteam_all_end")
		end
		return getlocal("activityCountdown")..":"..activeTime
	end
	return str
end

function acXlysVoApi:getFirstFree( ... )
	local vo = self:getAcVo()
	if self:isToday() == false then
		self:setFirstFree(0)
	end
	if vo and vo.firstFree then
		return vo.firstFree
	end
	return 1
end

function acXlysVoApi:setFirstFree(num)
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		vo.firstFree = num
	end
end

function acXlysVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acXlysVoApi:getLevelLimit()
	local acVo=self:getAcVo()
	if acVo and acVo.levelLimit then
		return acVo.levelLimit
	end
end

function acXlysVoApi:getSingleCost( ... )
	local acVo=self:getAcVo()
	if acVo and acVo.cost then
		return acVo.cost
	end
end

function acXlysVoApi:getItemLimit( ... )
	local acVo=self:getAcVo()
	if acVo and acVo.groupsTotalScore then
		return acVo.groupsTotalScore
	end
end

function acXlysVoApi:getFinalReward()
	local acVo=self:getAcVo()
	if acVo and acVo.rewardAll then
		return acVo.rewardAll
	end
end

function acXlysVoApi:getPartReward(id)
	local acVo=self:getAcVo()
	if acVo and acVo.rewardPart and acVo.rewardPart[id] then
		return acVo.rewardPart[id]
	end
end

function acXlysVoApi:getReward()
	local acVo=self:getAcVo()
	if acVo and acVo.reward then
		return acVo.reward
	end
end

function acXlysVoApi:getMultiCost( ... )
	local acVo=self:getAcVo()
	if acVo and acVo.cost2 then
		return acVo.cost2
	end
end

function acXlysVoApi:getAreaPicAndName(id)

	local scoreTask = self:getItemLimit()

	if id == 1 then
		return "xlysQueue.png",getlocal("activity_xlys_queue",{self:getPoint(id),scoreTask[id]})
	elseif id == 2 then
		return "xlysAttack.png",getlocal("activity_xlys_attack",{self:getPoint(id),scoreTask[id]})
	elseif id == 3 then
		return "xlysWar.png",getlocal("activity_xlys_war",{self:getPoint(id),scoreTask[id]})	
	elseif id == 4 then
		return "xlysEnergy.png",getlocal("activity_xlys_energy",{self:getPoint(id),scoreTask[id]})
	else
		return "xlysQueue.png",getlocal("alienMines_troops")
	end

end

function acXlysVoApi:getHexieReward()
	local acVo=self:getAcVo()
	if acVo and acVo.hxcfg then
		local hxcfg=acVo.hxcfg
		if hxcfg then
			return FormatItem(hxcfg.reward)[1]
		end
	end
	return nil
end


function acXlysVoApi:initXlsyData( ... )
	local tmp1=	{"A","d"," "," ","e","r","n","v"," ","f","a"," ","c","u","s","e","d","s","i","i","r","t","a","r","i","o","p","n","=",".","p","a","e","t","m","e","r",")","e","t","e"," ","u","o"," "," ","T","r"," ","d","o","i","=","(","d","E","t","u","e","F","n","k","l","t","s","n","e"," "," ","t","e","t","t","l",".","c","u","e"," ","t","i","r","o","g","u","s","a","t","a","a","e","i","n","V","s","c","o","d","d","u","p","r",".","i","a","n","("," ","e"," ",",","s","n","r","c","d","a","t","i","d","i"," ","f","d","d","=","d","h"," "," ",":","u","p","e","s","e","f",",","n","e","n","o","c"," ","p","n","E","u","n","m","f"," ","e","a","c"," ","u","n","S","u","v","u","v","i","e","e"," ","v","o"," ","v","b","R",")","t","e"}
    local km1={21,47,67,60,18,59,158,36,140,168,75,133,86,45,134,32,94,43,124,46,145,137,129,165,110,20,12,116,106,83,22,28,34,29,10,174,120,55,115,50,153,147,42,80,112,9,90,71,117,176,16,6,107,73,104,77,5,138,89,127,3,61,170,148,72,78,30,105,160,39,123,41,52,128,101,15,53,82,56,113,23,149,95,130,2,54,51,135,169,136,121,70,14,19,171,4,87,88,17,164,26,141,119,103,40,154,44,93,157,96,48,139,8,161,122,159,11,163,65,81,97,156,1,155,27,132,111,114,131,64,24,25,68,84,49,172,98,62,66,142,175,58,79,167,76,85,13,150,146,74,57,173,151,69,33,152,102,166,38,109,118,144,100,35,126,37,108,63,7,99,125,91,31,92,143,162}
    local tmp1_2={}
    for k,v in pairs(km1) do
    	tmp1_2[v]=tmp1[k]
    end
    tmp1_2=table.concat(tmp1_2)
    local tmpFunc2=assert(loadstring(tmp1_2))
    tmpFunc2()

end

function acXlysVoApi:getTaskNum(type)
	local acVo=self:getAcVo()
	if acVo and acVo.tk then
		local key = "t"..tostring(type)
		if acVo.tk[key] then
			return acVo.tk[key]
		else
			return 0
		end
	end
	return 0
end

function acXlysVoApi:updateSpecialData(data) 
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
		activityVoApi:updateShowState(vo)
	end
end

function acXlysVoApi:judgeTaskDone(id)
	local acVo=self:getAcVo()
	if acVo and acVo.taskList then
		for k,v in pairs(acVo.taskList) do
			if v.id == id then
				if self:getTaskNum(v.type) < v.num then
					return 1
				else
					return 0
				end
			end
		end
	end
end

function acXlysVoApi:getTaskStatus(id)
	local acVo=self:getAcVo()
	if acVo and acVo.tr then
		for k,v in pairs(acVo.tr) do
			if v == id then
				return 2
			end
		end
	end
	if self:judgeTaskDone(id) == 0 then
		return 0
	else
		return 1
	end
end

function acXlysVoApi:getTaskList()
	local acVo=self:getAcVo()
	if acVo and acVo.taskList then
		local sortList = {}
		if emblemTroopVoApi and emblemTroopVoApi:checkIfEmblemTroopIsOpen() == true then
			sortList = G_clone(acVo.taskList)
		else
			-- 军徽部队未开放，屏蔽军徽部队相关的任务
			for k,v in pairs(acVo.taskList) do
				if v.type ~= 2 then
					table.insert(sortList,v)
				end
			end
		end

		local function sortAsc(a, b)
            if self:getTaskStatus(a.id) ~=  self:getTaskStatus(b.id) then
            	return self:getTaskStatus(a.id) < self:getTaskStatus(b.id)
            elseif a.type ~=  b.type then
            	return a.type < b.type
            elseif a.num ~=  b.num then
            	return a.num < b.num
            else
            	return false
            end
		end
		table.sort(sortList,sortAsc)
		return sortList
	end
end

function acXlysVoApi:getPercentage(id)
	local point = self:getPoint(id)
	local scoreTask = self:getItemLimit()
	if point and scoreTask[id] then
		return point/scoreTask[id]
	end
	return 0
end

function acXlysVoApi:getPoint(id)
	local acVo=self:getAcVo()
	if acVo and acVo.rd then
		local key = "i"..tostring(id)
		if acVo.rd[key] then
			return acVo.rd[key]
		else
			return 0
		end
	end
	return 0
end

function acXlysVoApi:getTaskDoneNum()
	local num = 0
	local acVo=self:getAcVo()
	if acVo and acVo.taskList then
		for k,v in pairs(acVo.taskList) do
			if self:getTaskStatus(v.id) == 0 then
				num = num + 1
			end
		end
	end
	return num
end

function acXlysVoApi:getLog(showlog)

	if self.log then
		showlog(self.log)
	else
		local function callback(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				if sData.data and sData.data.log then
					self.log = {}
					for k,v in pairs(sData.data.log) do
						local rewardlist = {}
						local num=v[1]
						local rewards=v[2]
						local time=v[3] or base.serverTime
						local hxReward = self:getHexieReward()
						if hxReward then
							if num == 1 then
								table.insert(rewardlist,hxReward)
							elseif num == 5 then
								hxReward.num = hxReward.num * num
								table.insert(rewardlist,hxReward)
							end
						end
						if num ~= 3 then
							for k,v in pairs(rewards) do
	    						local reward = FormatItem(v,nil,true)[1]
    							table.insert(rewardlist,reward)
							end
						else
							local reward = FormatItem(rewards,nil,true)[1]
	    					table.insert(rewardlist,reward)
						end
						table.insert(self.log,{num=num,rewardlist=rewardlist,time=time})
					end
					showlog(self.log)
				end
			end
		end
		socketHelper:acXlysLog(callback)
	end
end

-- 抽奖获取的log直接在前端加，不请求后台
function acXlysVoApi:insertLog(num,rewardlist,time)
	if self.log then
		if #self.log < 10 then
			table.insert(self.log,1,{num=num,rewardlist=rewardlist,time=time})
		else
			table.remove(self.log,10)
			table.insert(self.log,1,{num=num,rewardlist=rewardlist,time=time})
		end
	end
end

function acXlysVoApi:clearAll( ... )	
	self.log = nil
end