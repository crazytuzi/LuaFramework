acLmqrjVoApi={}

function acLmqrjVoApi:getAcVo()
	return activityVoApi:getActivityVo("lmqrj")
end

function acLmqrjVoApi:getVersion()
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1
end

function acLmqrjVoApi:getBoxTb(_index)
	if self.boxTb==nil then
		--绿、紫、红(低->高)
		if self:getVersion()==2 then
			self.boxTb={
		    	{"acLmqrj_greenBox_v2.png","acLmqrj_greenBox_lid_close_v2.png","acLmqrj_greenBox_lid_open_v2.png",getlocal("activity_lmqrj_boxName1_v2")},
		    	{"acLmqrj_purpleBox_v2.png","acLmqrj_purpleBox_lid_close_v2.png","acLmqrj_purpleBox_lid_open_v2.png",getlocal("activity_lmqrj_boxName2_v2")},
		    	{"acLmqrj_redBox_v2.png","acLmqrj_redBox_lid_close_v2.png","acLmqrj_redBox_lid_open_v2.png",getlocal("activity_lmqrj_boxName3_v2")},
			}
		else
		    self.boxTb={
		    	{"acLmqrj_greenBox.png","acLmqrj_greenBox_lid_close.png","acLmqrj_greenBox_lid_open.png",getlocal("activity_lmqrj_boxName1")},
		    	{"acLmqrj_purpleBox.png","acLmqrj_purpleBox_lid_close.png","acLmqrj_purpleBox_lid_open.png",getlocal("activity_lmqrj_boxName2")},
		    	{"acLmqrj_redBox.png","acLmqrj_redBox_lid_close.png","acLmqrj_redBox_lid_open.png",getlocal("activity_lmqrj_boxName3")},
			}
		end
	end
	if _index then
		return self.boxTb[_index]
	end
	return self.boxTb
end

function acLmqrjVoApi:getInitFriendsListFlag()
	if self.isInitFriendsListFlag~=nil then
		return self.isInitFriendsListFlag
	else
		return -1
	end
end

function acLmqrjVoApi:initLmqrjData( ... )
	
	local tmp1=	{" ","i","i","d","e","l","t","T","e"," ","e"," ","=","=","t",":","v","(","o","n","e","g","s","s","e","n","l","t","S","n","e","d","m","r","t","s","n","m"," ","e","e","e"," ","n","r"," ","i"," ","c","t","f"," ","o","?","'","(","r",")","t","o","g","t","a","a","i"," ","T"," ","f","o","e","u","s","l","D","d","e","c","e","m","h","r","e",")","r","t","m"," ","c","i","i","e","u","l","t","t","r","e","f","=","=","l"," ","r","o","n","'"," ","e","c","m","'","0","a","'"," "," "," "," ","r","p","t"," "}
    local km1={76,95,53,17,59,84,31,23,14,9,68,65,75,61,66,19,91,85,16,8,18,77,43,71,121,3,41,56,27,115,34,108,33,110,44,117,107,58,46,97,26,21,70,69,73,60,32,120,39,28,54,42,81,50,49,30,114,99,118,88,20,79,83,11,24,63,94,55,87,7,111,2,103,37,13,123,78,15,106,96,67,89,92,35,93,72,25,109,4,57,6,90,113,80,22,5,45,104,1,47,62,102,105,119,38,122,98,116,101,82,10,51,64,40,86,74,100,36,48,29,12,112,52}
    local tmp1_2={}
    for k,v in pairs(km1) do
    	tmp1_2[v]=tmp1[k]
    end
    tmp1_2=table.concat(tmp1_2)
    local tmpFunc2=assert(loadstring(tmp1_2))
    tmpFunc2()

end

function acLmqrjVoApi:setInitFriendsListFlag(_flag)
	self.isInitFriendsListFlag=_flag
end

function acLmqrjVoApi:getBoxItem(_index)
	local boxData=self:getBoxTb(_index)
	return {
		icon={boxData[1],boxData[2]},
		name=getlocal("activity_lmqrj_boxReward_title",{boxData[4]}),
		desc=(self:getVersion()==2) and "activity_lmqrj_boxDesc_v2" or "activity_lmqrj_boxDesc",
	}
end

function acLmqrjVoApi:isToday()
	local vo = self:getAcVo()
	local isToday = false
	if vo and vo.todayTimer then
		-- isToday = vo.todayTimer-base.serverTime<24*60*60
		isToday = G_isToday(vo.todayTimer)
	end
	return isToday
end

function acLmqrjVoApi:getTimeStr()
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

function acLmqrjVoApi:canReward()
	if self:isToday()==false then
		return true
	end
	for i=1,3 do
		if acLmqrjVoApi:getBoxNum(i)>0 then
			return true
		end
	end
	return false
end

--检测跨天
function acLmqrjVoApi:checkIsToday(callback)
	if self:isToday()==false then
		local vo=self:getAcVo()
		if vo then
			local _index=1 --每天免费一个礼盒
			if vo.todayTimer==0 then
				vo.todayTimer=vo.st
			end
			local _num=(G_getWeeTs(base.serverTime)-G_getWeeTs(vo.todayTimer))/86400
			_num=acLmqrjVoApi:getBoxNum(_index)+_num
			acLmqrjVoApi:setBoxNum(_index,_num)
			vo.todayTimer=G_getWeeTs(base.serverTime)
			if callback then
				callback()
			end
		end
	end
end

--发送系统消息
function acLmqrjVoApi:setSystemMsg(rewards)
	local rewardStr=""
	for k,v in pairs(rewards) do
		rewardStr=rewardStr..(v.name.."x"..v.num)
        if k~=SizeOfTable(rewards) then
        	rewardStr=rewardStr..","
        end
    end
	local sysMsg
	if self:getVersion()==2 then
		sysMsg = getlocal("activity_lmqrj_systemMsg_v2", {playerVoApi:getPlayerName(),rewardStr})
	else
		sysMsg = getlocal("activity_lmqrj_systemMsg", {playerVoApi:getPlayerName(),rewardStr})
	end
	local paramTab={}
	paramTab.functionStr="lmqrj"
    paramTab.addStr="goTo_see_see"
    chatVoApi:sendSystemMessage(sysMsg,paramTab)
end

--检测是否有奖励可领取
function acLmqrjVoApi:checkIsAward(_tabIndex)
	if _tabIndex==0 then
		if acLmqrjVoApi:isCanGetCharmReward() then
			return true
		end
	elseif _tabIndex==1 then
		local vo = self:getAcVo()
		if vo and vo.taskReward then
			for k,v in pairs(vo.taskReward) do
				if self:getTaskNum(v.type)>=v.needNum and self:isAwardTask(v.id)==false then
					return true
				end
			end
		end
	end
	return false
end

function acLmqrjVoApi:setBoxNum(_index,_num)
	local vo = self:getAcVo()
	if vo then
		if vo.lh==nil then
			vo.lh={}
		end
		vo.lh["p".._index]=_num
	end
end

--获取礼盒数量
--_index:  1:绿，2:紫，3:红
function acLmqrjVoApi:getBoxNum(_index)
	local vo = self:getAcVo()
	if vo and vo.lh then
		if type(vo.lh["p".._index])=="number" then
			return vo.lh["p".._index]
		end
	end
	return 0
end

--获取魅力值
function acLmqrjVoApi:getCharmNum()
	local vo = self:getAcVo()
	if vo and vo.mlz then
		return tonumber(vo.mlz)
	end
	return 0
end

--获取当前阶段的最大魅力值(积分)
function acLmqrjVoApi:getCurMaxScore()
	local vo = self:getAcVo()
	if vo and vo.rndNumReward then
		local _maxCharm=0
		local _charmNum=self:getCharmNum()
		for k, v in pairs(vo.rndNumReward) do
			if (_charmNum==0 or _charmNum>_maxCharm) and _charmNum<=_maxCharm+v[1] then
				return _maxCharm+v[1]
			end
			_maxCharm=_maxCharm+v[1]
		end
		return _maxCharm
	end
	return 0
end

function acLmqrjVoApi:getCharmRewardBoxImage()
	local vo = self:getAcVo()
	if vo and vo.rndNumReward then
		for k, v in pairs(vo.rndNumReward) do
			if self:isGetCharmReward(v[1])==false then
				if k>6 then
					break
				end
				return "packs"..k..".png"
			end
		end
	end
	return "packs6.png"
end

--是否已领取魅力值奖励
function acLmqrjVoApi:isGetCharmReward(_charm)
	local vo = self:getAcVo()
	if vo and vo.rdm then
		for k,v in pairs(vo.rdm) do
			if tonumber(_charm)==tonumber(v) then
				return true
			end
		end
	end
	return false
end

--是否可以领取魅力值奖励
function acLmqrjVoApi:isCanGetCharmReward()
	local vo = self:getAcVo()
	if vo and vo.rndNumReward then
		local _maxCharm=0
		local _charmNum=self:getCharmNum()
		local _lastTb
		for k, v in pairs(vo.rndNumReward) do
			_maxCharm=_maxCharm+v[1]
			if _charmNum>=_maxCharm and self:isGetCharmReward(v[1])==false then
				return true,_maxCharm,v[1],v[2]
			end
			_lastTb=v
		end
		return false,_maxCharm,_lastTb[1],_lastTb[2]
	end
	return false
end

--获取当前阶段的魅力值奖励
function acLmqrjVoApi:getCurScoreReward()
	local vo = self:getAcVo()
	if vo and vo.rndNumReward then
		local _maxCharm=0
		local _charmNum=self:getCharmNum()
		local _lastTb
		for k, v in pairs(vo.rndNumReward) do
			if (_charmNum==0 or _charmNum>_maxCharm-v[1]) and _charmNum<=_maxCharm+v[1] then
				return _maxCharm+v[1],v[1],v[2]
			end
			_maxCharm=_maxCharm+v[1]
			_lastTb=v
		end
		return _maxCharm,_lastTb[1],_lastTb[2]
	end
end

function acLmqrjVoApi:getCharmReward()
	local vo = self:getAcVo()
	if vo and vo.rndNumReward then
		local _tab={}
		local _maxCharm=0
		for k, v in pairs(vo.rndNumReward) do
			_maxCharm=_maxCharm+v[1]
			table.insert(_tab,{_maxCharm,v[2]})
		end
		return _tab
	end
end

--获取送礼分数
function acLmqrjVoApi:getSendGiftScore(_index)
	local vo = self:getAcVo()
	if vo and vo.sendgift then
		if type(vo.sendgift[_index])=="number" then
			return vo.sendgift[_index]
		end
	end
	return 0
end

--获取运费(赠送价格)
function acLmqrjVoApi:getSendCost(_index)
	local vo = self:getAcVo()
	if vo and vo.sendCost then
		if type(vo.sendCost[_index])=="number" then
			return vo.sendCost[_index]
		end
	end
	return 0
end

--获取单拆价格(购买价格)
function acLmqrjVoApi:getOneCost(_index)
	local vo = self:getAcVo()
	if vo and vo.cost then
		if type(vo.cost[_index])=="number" then
			return vo.cost[_index]
		end
	end
	return 0
end

--获取5拆价格(购买价格)
function acLmqrjVoApi:getFiveCost(_index)
	local vo = self:getAcVo()
	if vo and vo.cost5 then
		if type(vo.cost5[_index])=="number" then
			return vo.cost5[_index]
		end
	end
	return 0
end

--获取赠送等级限制
function acLmqrjVoApi:getGiveLevelLimit()
	local vo = self:getAcVo()
	if vo and vo.openLevel then
		return vo.openLevel
	end
	return 0
end

--是否赠送
function acLmqrjVoApi:isGiving(_uid,_itemKey)
	if self.givingTab then
		for k, v in pairs(self.givingTab) do
			if tostring(_uid) == tostring(k) then
				for n, m in pairs(v) do
					if m == ("p".._itemKey) then
						return true
					end
				end
			end
		end
	end
	return false
end

function acLmqrjVoApi:setGivingTab(_data)
	if _data then
		self.givingTab = _data
	end
end

function acLmqrjVoApi:updateGivingTab(_uid,_itemKey)
	if self.givingTab==nil then
		self.givingTab={}
	end
	local _exisitKey = nil
	for k, v in pairs(self.givingTab) do
		if tostring(_uid) == tostring(k) then
			_exisitKey = k
			break
		end
	end
	local _key = "p".._itemKey
	if _exisitKey ~= nil then
		table.insert(self.givingTab[_exisitKey],_key)
	else
		self.givingTab[tostring(_uid)] = {}
		self.givingTab[tostring(_uid)][1] = _key
	end
end

--获取礼盒奖励
function acLmqrjVoApi:getBoxReward(_index)
	local vo = self:getAcVo()
	if vo and vo.reward then
		return vo.reward[_index]
	end
end

--获取和谐版奖励
function acLmqrjVoApi:getHxReward()
	local vo = self:getAcVo()
	if vo and vo.hxReward then
		return FormatItem(vo.hxReward)[1]
	end
end

--获取1个物品的积分
function acLmqrjVoApi:getItemScore(_index,_key)
	local vo = self:getAcVo()
	if vo and vo.point and vo.point[_index] then
		local tb = FormatItem(vo.point[_index])
		for m, n in pairs(tb) do
			if n.key==_key then
				return n.num
			end
		end
	end
	return 0
end

--获取任务奖励
function acLmqrjVoApi:getTaskReward()
	local _taskData={}
	local vo = self:getAcVo()
	if vo and vo.taskReward then
		local _tb1={} --可领取
		local _tbNil={} --未达成
		local _tb2={} --已领取
		for k,v in pairs(vo.taskReward) do
			v.state=self:isAwardTask(v.id) and 2 or ((self:getTaskNum(v.type)>=v.needNum) and 1 or nil) --领取状态 1:可领取 2:已领取 nil:未达成
			if v.state==1 then
				table.insert(_tb1,v)
			elseif v.state==nil then
				table.insert(_tbNil,v)
			elseif v.state==2 then
				table.insert(_tb2,v)
			end
		end
		table.sort(_tb1, function(a,b) return a.index<b.index end)
		table.sort(_tbNil, function(a,b) return a.index<b.index end)
		table.sort(_tb2, function(a,b) return a.index<b.index end)
		for k, v in pairs(_tb1) do table.insert(_taskData,v) end
		for k, v in pairs(_tbNil) do table.insert(_taskData,v) end
		for k, v in pairs(_tb2) do table.insert(_taskData,v) end
	end
	--[[
	if vo and vo.taskReward then
		local _tempData={}
		for k,v in pairs(vo.taskReward) do
			if _tempData[v.type]==nil then
				_tempData[v.type]={}
			end
			table.insert(_tempData[v.type],v)
		end
		local _tb1={} --可领取
		local _tbNil={} --未达成
		local _tb2={} --已领取
		local function addTab(_state,_tb)
			if _state==1 then
				table.insert(_tb1,_tb)
			elseif _state==nil then
				table.insert(_tbNil,_tb)
			elseif _state==2 then
				table.insert(_tb2,_tb)
			end
		end
		for k,v in pairs(_tempData) do
			local _size=SizeOfTable(v)
			for m,n in pairs(v) do
				n.state=self:isAwardTask(n.id) and 2 or ((self:getTaskNum(n.type)>=n.needNum) and 1 or nil) --领取状态 1:可领取 2:已领取 nil:未达成
				if m==_size then
					addTab(n.state,n)
				elseif n.state==nil or n.state==1 then
					addTab(n.state,n)
					break
				end
			end
		end
		table.sort(_tb1, function(a,b) return a.index<b.index end)
		table.sort(_tbNil, function(a,b) return a.index<b.index end)
		table.sort(_tb2, function(a,b) return a.index<b.index end)
		for k, v in pairs(_tb1) do table.insert(_taskData,v) end
		for k, v in pairs(_tbNil) do table.insert(_taskData,v) end
		for k, v in pairs(_tb2) do table.insert(_taskData,v) end
	end
	--]]
	return _taskData
end

--获取完成的任务次数
function acLmqrjVoApi:getTaskNum(taskType)
	local vo = self:getAcVo()
	if vo and vo.tk then
		if type(vo.tk[taskType])=="number" then
			return vo.tk[taskType]
		end
	end
	return 0
end

--是否已领取任务奖励
function acLmqrjVoApi:isAwardTask(_id)
	local vo = self:getAcVo()
	if vo and vo.rd then
		for k,v in pairs(vo.rd) do
			if _id==v then
				return true
			end
		end
	end
	return false
end

--格式化抽奖记录
function acLmqrjVoApi:formatLog(_data)
	local lotteryLog={}
	if _data==nil then
		do return lotteryLog end
	end
	table.sort(_data, function(a,b) return a[4]>b[4] end)
	for k,v in pairs(_data) do
		local _type=v[1] -- 1:拆礼盒, 2:领取魅力值礼盒奖励
		local _num=v[2] -- 1:单拆礼盒, 5:5拆礼盒, 魅力值(领奖对应的值)
		local rewards=v[3] --奖励物品
		local _timer=v[4] --时间戳
		local _boxData=v[5] --礼盒数据对应的积分({p1=33})

		local rewardlist={}
		if _type==1 and _num==1 then
			local reward=FormatItem(rewards,nil,true)
			table.insert(rewardlist,reward[1])
		else
			for k,v in pairs(rewards) do
				local reward=FormatItem(v,nil,true)
				table.insert(rewardlist,reward[1])
			end
		end
		local titleStr=""
		if _type==1 then
			local hxReward=self:getHxReward()
			if hxReward then
				hxReward.num=hxReward.num*_num
				table.insert(rewardlist,1,hxReward)
			end
			local _boxName,_score
			for m,n in pairs(_boxData) do
				_boxName=self:getBoxTb(tonumber(string.sub(m,2)))[4]
				_score=n
			end
			if self:getVersion()==2 then
				titleStr=getlocal("activity_lmqrj_logTitle1_v2",{_boxName,_num,_score})
			else
				titleStr=getlocal("activity_lmqrj_logTitle1",{_boxName,_num,_score})
			end
		else
			local vo = self:getAcVo()
			if vo and vo.rndNumReward then
				local _maxCharm=0
				for k, v in pairs(vo.rndNumReward) do
					_maxCharm=_maxCharm+v[1]
					if _num==v[1] then
						_num=_maxCharm
						break
					end
				end
			end
			titleStr=getlocal("activity_lmqrj_logTitle2",{_num})
		end
		local time=_timer or base.serverTime
		table.insert(lotteryLog,{titleStr=titleStr,content=rewardlist,time=time})
		if k>=10 then
			break
		end
	end
	return lotteryLog
end

--格式化赠送记录
function acLmqrjVoApi:formatZslog(_data)
	local giveLog={}
	if _data==nil then
		do return giveLog end
	end
	table.sort(_data, function(a,b) return a[4]>b[4] end)
	for k,v in pairs(_data) do
		local _type=v[1] -- 1:赠送, 2:接收
		local _name=v[2] --玩家名称
		local _boxKey=v[3] --礼盒id(p1,p2,p3)
		local _timer=v[4] --时间戳

		local _boxIndex=tonumber(string.sub(_boxKey,2))
		local _boxName=self:getBoxTb(_boxIndex)[4]
		local msgStr=getlocal("activity_lmqrj_logTitle4",{_name,_boxName})
		local msgColor
		if _type==1 then
			if self:getVersion()==2 then
				msgStr=getlocal("activity_lmqrj_logTitle3_v2",{_name,_boxName,self:getSendGiftScore(_boxIndex)})
			else
				msgStr=getlocal("activity_lmqrj_logTitle3",{_name,_boxName,self:getSendGiftScore(_boxIndex)})
			end
			msgColor=G_ColorYellowPro
		end
		local time=_timer or base.serverTime
		table.insert(giveLog,{msgStr=msgStr,msgColor=msgColor,time=time})
		if k>=10 then
			break
		end
	end
	return giveLog
end

function acLmqrjVoApi:updateData(data)
	if data then
		local vo=self:getAcVo()
		vo:updateData(data)
		activityVoApi:updateShowState(vo)
	end
end

function acLmqrjVoApi:clearAll()
	self.givingTab=nil
	self.lotteryLog=nil
	self.boxTb=nil
	self.isInitFriendsListFlag=nil
end