require "luascript/script/game/gamemodel/sign/newSignInVo"

newSignInVoApi={
	addUpAwardTb =nil,
	curSignUseTb=nil,
	curReSignUseTb=nil,
	curSignsbType=nil,
	
}

function newSignInVoApi:clearAll(isSpec)
	if newSignInVo and newSignInVo.clear then
		newSignInVo:clear(isSpec)
	end
	self.addUpAwardTb = nil
	self.curSignUseTb = nil
	self.curReSignUseTb = nil
	self.curSignsbType = nil
end

function newSignInVoApi:changeVer( )

	local vo = self:getNewSignInVo()
	vo.ver = vo.ver % SizeOfTable(vo.signAwardTb) + 1
	-- print("changeVer---->",vo.ver)
	-- print("vo.ver---->>>>",vo.ver)
end

function newSignInVoApi:setVer(newVer)
	local vo = self:getNewSignInVo()
	vo.ver = newVer + 1
	-- print("vo.ver---->>>>",vo.ver)
end

function newSignInVoApi:resetData(data)
	return newSignInVo:initWithData(data)
end
function newSignInVoApi:getVer( )
	local vo = self:getNewSignInVo()
	return vo.ver
end

function newSignInVoApi:showSignDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/newSignDialog"
	newSignInVo:initWithData()
	local month = G_getDate(base.serverTime).month
	local nd = newSignDialog:new()
    local tbArr={}
    local vd = nd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("checkInAward",{month}),true,layerNum);
    sceneGame:addChild(vd,layerNum);
end

function newSignInVoApi:getNewSignInVo( )
	return newSignInVo or nil
end

function newSignInVoApi:getReSignLimit( )
	local vo = self:getNewSignInVo()
	return vo.reSignLimit or 99999
end

function newSignInVoApi:getCheckInAgainNum( )--当前月剩余补签次数
	local vo = self:getNewSignInVo()
	if vo and vo.checkInAgainNum then
		if not self:isToday() and vo.checkInAgainNum > 0 then--需要判断当天是否有签到
			vo.checkInAgainNum = vo.checkInAgainNum - 1
		end
		return vo.checkInAgainNum
	end
	return 0
end

function newSignInVoApi:getReSignLastDayNum( )--可重置剩余天数
	local monthDay=G_getMonthDay() --本月总天数
	local date=G_getDate(base.serverTime)
	-- print("date.month====>>>",date.month)
	-- print("monthDay---date.day--->>",monthDay,date.day,monthDay-date.day)
	return monthDay - date.day + 1
end

function newSignInVoApi:showInfoTipTb(layerNum)
	local tabStr = {}
	for i=1,6 do
		if i == 2 then
			table.insert(tabStr,getlocal("newSignTip"..i,{self:getReSignLimit()}))
		else
	        table.insert(tabStr,getlocal("newSignTip"..i))
	    end
    end
    local titleStr=getlocal("activity_baseLeveling_ruleTitle")
    require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
    tipShowSmallDialog:showStrInfo(layerNum,true,true,nil,titleStr,tabStr,nil,25)
end

function newSignInVoApi:getCheckInNeedGold()
	local vo = self:getNewSignInVo()
	if vo and vo.reSignGoldTb and vo.checkInAgainNum  then
		local useIdx = vo.checkInAgainNum == 0 and vo.reSignLimit or vo.resignTimes + 1
		return vo.reSignGoldTb[useIdx]
	end
	return nil
end

function newSignInVoApi:isToday( )--判断当天是否已签到的时间戳，该时间戳反馈为最近一次的签到时间
	local vo = self:getNewSignInVo()
	if vo and vo.signST then
		-- print("G_isToday(vo.signST)====>>>",G_isToday(vo.signST))
		return G_isToday(vo.signST)
	end
	return false
end

function newSignInVoApi:lastSignInMonth( )
	local vo = self:getNewSignInVo()
	if vo and vo.curMonTH then
		-- print("lastSignInMonth-->>",vo.signST,G_getDate(vo.signST).month , G_getDate(base.serverTime).month)
		-- print("base.serverTime----->>>>",vo.curMonTH,G_getDate(base.serverTime).month)
		return vo.curMonTH == G_getDate(base.serverTime).month
	end
end
function newSignInVoApi:setCurMonTH( )
	local vo = self:getNewSignInVo()
	vo.curMonTH = G_getDate(base.serverTime).month
end

function newSignInVoApi:curIsCheckInDays()--判断当月签到次数到今天为止全签
	local vo = self:getNewSignInVo()
	local date = G_getDate(base.serverTime)
	-- print("vo.signTimes == date.day + 1====>>",vo.signTimes, date.day + 1,self:isToday())
	if vo.signTimes >= date.day + 1 then
		return true
	end
	return false
end

function newSignInVoApi:isCanExchange()--兑换入口 是否可进
	local levelLimit = exteriorCfg.openlv
	return playerVoApi:getPlayerLevel() >= levelLimit
end

function newSignInVoApi:SocketCall(callBack,cmdStr,rewardId,tt)
	local function signCall(fn,data )
		local ret,sData = base:checkServerData(data)
		if ret then
			if sData.data and sData.data.newSign then
				local vo = self:getNewSignInVo( )
				vo:initWithData(sData.data.newSign)
			end
			if callBack then
				callBack()
			end
		end
	end

	socketHelper:newSignSocket(signCall,cmdStr,rewardId,tt)
end


function newSignInVoApi:getAddUpCheckInAwardTb(needDay)
	if not self.addUpAwardTb then
		self.addUpAwardTb = {}
		local totalReward = newSignInCfg.totalReward
		for k,v in pairs(totalReward) do
			local awardTb = FormatItem(v.reward,nil,true) 
			self.addUpAwardTb[k] = {}
			self.addUpAwardTb[k].reward = awardTb
			for k,v in pairs(awardTb) do
			end
			
			self.addUpAwardTb[k].needday = v.needday
		end
	end
	if needDay then
		for k,v in pairs(self.addUpAwardTb) do
			if v.needday == needDay then
				return v
			end
		end
	else
		return self.addUpAwardTb
	end
end

function newSignInVoApi:getSignTimes()--当月签到天数
	local vo = self:getNewSignInVo()
	if vo and vo.signTimes then
		return vo.signTimes
	end
	return 0
end

function newSignInVoApi:isRtb(idx)--累计签到领取标识表
	local vo = self:getNewSignInVo()
	if vo and vo.rtb then
		if idx then
			for k,v in pairs(vo.rtb) do
				if "r"..idx == v then	
					return true
				end
			end
		end
	end
	return false
end

function newSignInVoApi:addUpAwardSmallDialog(idx,layerNum, callback, rewardTb, rewardType ,isToday,isMonth)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
	--rewardtype 1 不能领取 2 可领取 3 已领取
    local titleStr = getlocal("addUpCheckInAward")
    local needTb = {"nsAddUpAward",titleStr,rewardTb,SizeOfTable(rewardTb),idx,callback,rewardType,nil,isToday,isMonth}
    local sd = acThrivingSmallDialog:new(layerNum,needTb)
    sd:init()
    return sd
end

function newSignInVoApi:signNowSmallDialog(idx,layerNum, callback, rewardTb, rewardType,isSB ,isToday,isMonth)--isSB 双倍
	require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
	--rewardtype 1 不能领取 2 可领取 3 已领取
    local titleStr = getlocal("checkInAwardStr")
    local needTb = {"nsCheckIn",titleStr,rewardTb,SizeOfTable(rewardTb),idx,callback,rewardType,isSB,isToday,isMonth}
    local sd = acThrivingSmallDialog:new(layerNum,needTb)
    sd:init()
    return sd
end
function newSignInVoApi:getCurSignData( )
	local vo = self:getNewSignInVo()
	if vo and vo.ver and vo.signAwardTb then
		local signData = {}
		for k,v in pairs(vo.signAwardTb[vo.ver]) do
			signData[k] = {}
			signData[k].reward = FormatItem(v.reward,nil,true)
			for k,v in pairs(signData[k].reward) do
				if v.key == "honors" then
					 local playerRank = playerVoApi:getRank()
					 local honors = playerCfg.daily_honor[playerRank]
					 v.num = honors
				end
			end
			
			signData[k].vip = v.vip
		end		
		return signData
	end
	return {}
end
--local beishu = newSignInVoApi:getCurSignsbType( ) and 2 or 1
function newSignInVoApi:setCurSignUse(reward)
	if reward then
		self.curSignUseTb = G_clone(reward)
		local beishu = self:getCurSignsbType( ) and 2 or 1
		for k,v in pairs(self.curSignUseTb) do
			v.num = beishu * v.num
		end
	else
		self.curSignUseTb = nil
	end
end
function newSignInVoApi:getCurSignUse( )
	return self.curSignUseTb or nil
end

function newSignInVoApi:setCurReSignUse(reward)
	if reward then
		self.curReSignUseTb = G_clone(reward)
		local beishu = self:getCurSignsbType( ) and 2 or 1
		for k,v in pairs(self.curReSignUseTb) do
			v.num = beishu * v.num
		end
	else
		self.curReSignUseTb = nil
	end
end
function newSignInVoApi:getCurReSignUse( )
	return self.curReSignUseTb or nil
end

function newSignInVoApi:setCurSignsbType(sbType)
	if sbType then
		self.curSignsbType = sbType
	else
		self.curSignsbType = nil
	end
end
function newSignInVoApi:getCurSignsbType( )
	return self.curSignsbType or nil
end