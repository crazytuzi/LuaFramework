acSmcjVoApi={
	name=nil,
	scoreRewardTb = {}
}
function acSmcjVoApi:clearAll()
	self.scoreRewardTb = nil
	self.name = nil
end
function acSmcjVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acSmcjVoApi:setActiveName(name)
	self.name=name
end

function acSmcjVoApi:getActiveName()
	return self.name or "smcj"
end

function acSmcjVoApi:getrShowNum( )
	local vo = self:getAcVo()
	if vo and vo.rShowNum then
		return vo.rShowNum
	end
	return 20
end
function acSmcjVoApi:getTimer( )--倒计时 需要时时显示
	local vo=self:getAcVo()
	local str=""
	if vo then
		local activeTime = vo.et - 86400 - base.serverTime > 0 and G_formatActiveDate(vo.et - 86400 - base.serverTime) or nil
		if activeTime==nil then
			activeTime=getlocal("serverwarteam_all_end")
		end
		str=getlocal("activityCountdown")..":"..activeTime
	end
	return str
end
function acSmcjVoApi:getRewardTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		local activeTime = G_formatActiveDate(vo.et - base.serverTime)
		if self:isRewardTime()==false then
			activeTime=getlocal("notYetStr")
		end
		return getlocal("sendReward_title_time")..activeTime
	end
	return str
end

--是否处于领奖时间
function acSmcjVoApi:isRewardTime()
	local vo = self:getAcVo()
	if vo then
		if base.serverTime > vo.acEt-86400 and base.serverTime < vo.acEt then
			return true
		end
	end
	return false
end

function acSmcjVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acSmcjVoApi:canReward( )
	-- local curScore = self:getCurScore()
	-- local allScoreReward,nodeNum = self:getScoreReward( )
	-- for i=1,nodeNum do
	-- 	local needScore = allScoreReward[i].needScore
	-- 	local isReward=self:scoreOverIsReward(i)
	-- 	if curScore>=needScore and isReward == false then
	-- 		return true
	-- 	end
	-- end

	-- for id=1,7 do
	-- 	local dailyRechargeAwardTb,limitNum,limintGold = self:getDailyRechargeNeedData(id)
	-- 	local canGetNum,lastRechrage = self:getDailyRechargeCanGetNum(id,limintGold)
	-- 	local taskData = self:getDailyTaskList(id)
	-- 	if lastRechrage >= limintGold then
	-- 		return true
	-- 	end

	-- 	for idx=1,4 do
	-- 		local curTaskKey = self:getTaskKey(id,idx)
	-- 		local curTaskUseIdx = SizeOfTable(taskData["t"..idx])
	-- 		local needNum = taskData["t"..idx][curTaskUseIdx].needNum
	-- 		local curFinshNum = self:getTaskData(id,curTaskKey)
	-- 		for k=1,curTaskUseIdx do
	-- 			local isHad = self:getCurTst(id,curTaskKey,k)
	-- 			if curFinshNum >= needNum and isHad == false then
	-- 				return true
	-- 			end
	-- 		end
	-- 	end
	-- end

	return false
end

function acSmcjVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end
function acSmcjVoApi:getFirstFree()--免费标签
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		return vo.firstFree
	end
	return 1
end
function acSmcjVoApi:setFirstFree(newfree)
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		vo.firstFree = newfree
	end
end
function acSmcjVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage2.plist")
    spriteController:addTexture("public/activeCommonImage2.png")
end
function acSmcjVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage2.plist")
    spriteController:removeTexture("public/activeCommonImage2.png")
end

function acSmcjVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end

--------------------------------------------------------

function acSmcjVoApi:getScoreReward(idx)
	local vo = self:getAcVo()
	if not vo then
		vo = activityCfg.smcj[1]
	end
	if vo and vo.scoreReward then
		if idx and vo.scoreReward[idx] then
			return vo.scoreReward[idx]
		end
		return vo.scoreReward,SizeOfTable(vo.scoreReward)
	end
	print(" ===== e r r o r in getScoreReward ===== ")
	return {}
end

function acSmcjVoApi:getNeedTopScore( )
	local vo = self:getAcVo()
	if vo and vo.needTopScore then
		return vo.needTopScore
	end
	return 99999
end

function acSmcjVoApi:getCurDayLargeScore(day)
	local vo = self:getAcVo()
	if vo and vo.daysScore and day and vo.daysScore[day] then
		return vo.daysScore[day]
	end
	return 99999
end

function acSmcjVoApi:getCurScore( )--当前获得积分
	local vo = self:getAcVo()
	if vo and vo.curScore then
		return tonumber(vo.curScore)
	end
	return 0 
end
function acSmcjVoApi:scoreOverIsReward(idx)--idx 对应 积分奖励 是否已领奖
	local vo = self:getAcVo()
	if vo and vo.scoreRewardOverTb then
		if vo.scoreRewardOverTb and idx then
			for k,v in pairs(vo.scoreRewardOverTb) do
				if v == idx then
					return true
				end
			end
		end
	end
	return false
end

function acSmcjVoApi:taskRewardSmallDialog(idx,layerNum, callback, rewardTb, curScore, needScore,isReward)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
    local titleStr = tonumber(needScore)..getlocal("shanBattleReward_tab1")
    if not self.scoreRewardTb then
    	self.scoreRewardTb = {}
    end
    if not self.scoreRewardTb[idx] then
    	self.scoreRewardTb[idx] = FormatItem(rewardTb,nil,true)
    end

    print("SizeOfTable(self.scoreRewardTb[idx])===>>>",SizeOfTable(self.scoreRewardTb[idx]))
    local needTb = {"smcjTask",titleStr,self.scoreRewardTb[idx],SizeOfTable(self.scoreRewardTb[idx]),curScore,needScore,isReward,callback,idx}
    local sd = acThrivingSmallDialog:new(layerNum,needTb)
    sd:init()
end

function acSmcjVoApi:dailyTaskRewardSmallDialog(idx,layerNum, callback, rewardTb, curNum, needNum,isReward,curTaskKey,id,score)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
    local titleStr = getlocal("taskReward")
    local taskRewardTb = FormatItem(rewardTb,nil,true)


    print("SizeOfTable(taskRewardTb)===>>>",SizeOfTable(taskRewardTb))
    local needTb = {"smcjDailyTask",titleStr,taskRewardTb,SizeOfTable(taskRewardTb),curNum,needNum,isReward,callback,idx,curTaskKey,id,score}
    local sd = acThrivingSmallDialog:new(layerNum,needTb)
    sd:init()
end

function acSmcjVoApi:socketWithScoreReward(pid,callback)
	local function requestHandler(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.smcj then
				print(" I got ScoreReward now !!!")
				self:updateSpecialData(sData.data.smcj)
				if callback then
					callback()
				end
			else
				print(" data is nil ????? ")
			end
		end
	end
	socketHelper:acSmcjSocket("getPreward",{pid=pid},requestHandler)
end


function acSmcjVoApi:getMinRecharge( )--累计充值金币最低数量
	local vo = self:getAcVo()
	if vo and vo.rechargeMin then
		return vo.rechargeMin
	end
	return 9999999999
end

function acSmcjVoApi:getCurRechargeNum()
	local vo = self:getAcVo()
	if vo and vo.curRechargeNum then
		return vo.curRechargeNum
	end
	return 0
end

function acSmcjVoApi:getRankList()
	local vo = self:getAcVo()
	if vo and vo.ranklist then
		return vo.ranklist , SizeOfTable(vo.ranklist) + 1
	end
	return {},0
end

function acSmcjVoApi:socketRank(callback)--拿排行榜数据
	local function requestHandler(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.ranklist then
				-- print(" I got ranklist now !!!")
				self:updateSpecialData(sData.data)
				if callback then
					callback()
				end
			else
				print(" data is nil ????? ")
			end
		end
	end
	socketHelper:acSmcjSocket("rank",{},requestHandler)
end

function acSmcjVoApi:getRankShowIndex()
	local index = 11
	local rankStr = "10+"
	local ranklist = self:getRankList()
	local uid = playerVoApi:getUid()
	local curIdx,curScore = 0,nil
	local addIdx = 1
 	for k,v in pairs(ranklist) do
 		if not curScore or curScore ~= v[3] then
			curIdx = curIdx + addIdx
			curScore = v[3]
			addIdx = 1
		else
			addIdx = addIdx + 1
		end

		if uid==tonumber(v[1]) then
			rankStr = ""..curIdx
			index = curIdx
			do break end
		end
	end
	if SizeOfTable(ranklist) >= self:getrShowNum() and index == 11  then
		curIdx,curScore = 0,nil
		addIdx = 1
		local selfCurScore = self:getCurScore()
		for k,v in pairs(ranklist) do
			if not curScore or curScore ~= v[3] then
				curIdx = curIdx + addIdx
				curScore = v[3]
				addIdx = 1
			else
				addIdx = addIdx + 1
			end

			if selfCurScore == v[3] then
				rankStr = ""..curIdx
				index = curIdx
			end
		end
	end

	return index, rankStr
end

function acSmcjVoApi:getRankAward(idx)
	local vo = self:getAcVo()
	if vo and vo.rankReward then
		for k,v in pairs(vo.rankReward) do
			if v.rank[1] <= idx and v.rank[2] >= idx then
				return FormatItem(v.reward,nil,true)
			end
		end
	end
	return nil
end

function acSmcjVoApi:getRankReward()
	local vo = self:getAcVo()
	if vo and vo.rankReward then
		return vo.rankReward
	end
	return {}
end

function acSmcjVoApi:getDailyTaskList(idx)
	local vo = self:getAcVo()
	if not vo then
		vo = activityCfg.smcj[1]
	end
	if vo and vo.dailyTaskList then
		if idx then
			return vo.dailyTaskList[idx]
		end
		return vo.dailyTaskList
	end
	return {}
end

function acSmcjVoApi:getNumOfDay()
	local vo = self:getAcVo()
	if vo and vo.dailyTaskList then
		return SizeOfTable(vo.dailyTaskList)
	end
	return 0
end

function acSmcjVoApi:getNumDayOfActive()
	local vo = self:getAcVo()
	local st = vo.st
	local weeTs = G_getWeeTs(st)
	if self:isRewardTime()==true then
		return 8
	end
	local currDay = math.floor(math.abs(base.serverTime-weeTs)/(24*3600)) + 1

	return currDay
end

function acSmcjVoApi:getIconSp(idx,id)
	-- print("idx===id===>>>",idx,id)
	if not self.iconTb then
		self.iconTb = {
		{"acSmcjIcon_gb.png", "heroEquipLabIcon.png", "acSmcjIcon_hu.png", "heroEquipIcon.png"},
		{"acSmcjIcon_gb.png", "sw_3.png", "sw_4.png", "sw_2.png"},
		{"acSmcjIcon_gb.png", "accessoryPurify.png", "accessoryUpgrade.png", "icon_supply_lines.png"},
		{"acSmcjIcon_gb.png", "tech_fight_exp_up.png", "acSmcjIcon_pe.png", "player_fleet.png"},
		{"acSmcjIcon_gb.png", "epdtIcon.png", "emblemTroop_icon.png", "emblemIcon.png"},
		{"acSmcjIcon_gb.png", "resourse_normal_gem.png", "acSmcjIcon_pr.png", "arenaIcon.png"},
		{"acSmcjIcon_gb.png", "acSmcjIcon_ac.png", "acSmcjIcon_ai1.png", "acSmcjIcon_ai2.png"},
		}
	end
	if self.iconTb[idx] and self.iconTb[idx][id] then
		-- print(" self.iconTb[idx][id]====>>",self.iconTb[idx][id])
		return self.iconTb[idx][id]
	end
	print(" error in getIconSp idx and id is ==>>",idx,id)
end

function acSmcjVoApi:getTaskKey(idx,id)
	local vo = self:getAcVo()
	if vo and vo.dailytask then
		if vo.dailytask[idx] and vo.dailytask[idx][id] then
			return vo.dailytask[idx][id]
		end
	end
	print(" ====== e r r o r  in getLbKey ====== idx --id -->>",idx,id)
	return nil
end

function acSmcjVoApi:getTaskIdx(idx,taskKey )
	local  vo = self:getAcVo()
	if not vo then
		vo = activityCfg.smcj[1]
	end
	if vo and vo.dailytask then
		local dayData = vo.dailytask[idx]
		for k,v in pairs(dayData) do
			if v == taskKey then
				return k
			end
		end
	end
	return nil
end

function acSmcjVoApi:getTaskData(idx,Key)
	local vo = self:getAcVo()
	if vo and vo.taskDataTb then
		if vo.taskDataTb[idx] and type(vo.taskDataTb[idx]) ~= "userdata" and vo.taskDataTb[idx][Key] and type(vo.taskDataTb[idx][Key]) ~= "userdata" then
			return vo.taskDataTb[idx][Key]
		end
	end
	return 0
end

function acSmcjVoApi:getCurTst(id,taskKey,cellIdx)
	local vo = self:getAcVo()
	if vo and vo.tst then
		if vo.tst[id] and type(vo.tst[id]) ~= "userdata" and vo.tst[id][taskKey] then
			for k,v in pairs(vo.tst[id][taskKey]) do
				if v == cellIdx then
					return true
				end
			end
		end
	end
	return false
end

function acSmcjVoApi:socketWithDailyTaskReward(tkey,tid,callback)
	local function requestHandler(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.smcj then
				-- print(" I got DailyTaskReward now !!!")
				self:updateSpecialData(sData.data.smcj)
				if callback then
					callback()
				end
			else
				print(" data is nil ????? ")
			end
		end
	end
	socketHelper:acSmcjSocket("getTreward",{tkey=tkey,tid=tid},requestHandler)
end


-------------------------------每日 充值 次数-----------------------------------

function acSmcjVoApi:getDailyRechargeNeedData(day)
	local vo = self:getAcVo()
	if vo and vo.dailyGiftList then
		if vo.dailyGiftList[day] then
			return vo.dailyGiftList[day], vo.dailyGiftLimitNum, vo.giftGoldLimit
		end
	end
	print " =========== e r r o r ============"
	return {},99999,99999
end

function acSmcjVoApi:getDailyRechargeCanGetNum(day,limitGold)
	local vo = self:getAcVo()
	local curRechage = self:getTaskData(day,"gb")
	local getNum = self:getCurRechageRewardGetNum(day)
	if curRechage > 0 then
		curNum = math.floor(curRechage / limitGold)
		local lastRechrage = curRechage
		if curRechage >= limitGold then
			if getNum == 0 then
				lastRechrage = limitGold
			else
				lastRechrage = curRechage - limitGold * getNum
				lastRechrage = lastRechrage > limitGold and limitGold or lastRechrage
			end
		end
		return curNum,lastRechrage
	end
	return 0,0
end

function acSmcjVoApi:getCurRechageRewardGetNum(day)
	local vo = self:getAcVo() 
	if vo and vo.gData then
		if vo.gData[day] and type(vo.gData[day]) ~= "userdata" then
			return vo.gData[day]
		end
	end
	return 0
end

function acSmcjVoApi:dailyRehargeRewardSmallDialog(idx,layerNum, callback, rewardTb, curNum, needNum,getNum,canGetNum,id)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
    local titleStr = getlocal("taskReward")
    local taskRewardTb = FormatItem(rewardTb,nil,true)


    -- print("SizeOfTable(taskRewardTb)===>>>",SizeOfTable(taskRewardTb))
    local needTb = {"smcjRechr",titleStr,taskRewardTb,SizeOfTable(taskRewardTb),curNum,needNum,getNum,callback,idx,canGetNum,id}
    local sd = acThrivingSmallDialog:new(layerNum,needTb)
    sd:init()
end

function acSmcjVoApi:socketWithDailyRechargeReward(callback)
	local function requestHandler(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.smcj then
				print(" I got DailyTaskReward now !!!")
				self:updateSpecialData(sData.data.smcj)
				if callback then
					callback()
				end
			else
				print(" data is nil ????? ")
			end
		end
	end
	socketHelper:acSmcjSocket("getGreward",{},requestHandler)
end

function acSmcjVoApi:socketGet(tb,callback)
	local function requestHandler(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.smcj then
				self:updateSpecialData(sData.data.smcj)
				if callback then
					callback()
				end
			end
		end
	end
	socketHelper:acSmcjSocket("get",{ctp=tb},requestHandler)
end

function acSmcjVoApi:getPercentage(curFinshNum, needData,duanW)
	local alreadyCost = curFinshNum
	local cost = needData
	local numDuan = duanW
	local per = 0
	-- print("")
	local everyPer = 100/numDuan

	local per = 0

	local diDuan=0 
	for i=1,numDuan do
		if alreadyCost<=cost[i].needNum then
			diDuan=i
			break
		end
	end

	if alreadyCost>=cost[numDuan].needNum then
		per=100
	elseif diDuan==1 then
		per=alreadyCost/cost[1].needNum/numDuan*100
	else
		per = (diDuan-1)*everyPer+(alreadyCost-cost[diDuan-1].needNum)/(cost[diDuan].needNum-cost[diDuan-1].needNum)/numDuan*100
	end
	-- print("+++++++++++")
	return per
end

function acSmcjVoApi:getDayScore(day )
	local vo = self:getAcVo()
	if vo and vo.dayScoreTb and vo.dayScoreTb[day] then
		-- print("vo.dayScoreTb[day]====>>>",vo.dayScoreTb[day])
		if type(vo.dayScoreTb[day]) ~= "userdata" then
			return vo.dayScoreTb[day]
		end
	end
	return 0 
end

function acSmcjVoApi:getPer(curValue)
	local orData = acSmcjVoApi:getScoreReward()
	local costTb = {}
	for k,v in pairs(orData) do
		costTb[k] = v.needScore
	end
	local per = G_getPercentage(curValue,costTb)
	return per
end
