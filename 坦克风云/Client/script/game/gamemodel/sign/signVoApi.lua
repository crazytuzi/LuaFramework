require "luascript/script/game/gamemodel/sign/signVo"

signVoApi={
	dailySignTab={},
	totalSignTab={},
	addSignTab={},
	signData={},
	rewardNumTab={},
	maxNum=5,
	flag=-1,
}

function signVoApi:showSignDialog(layerNum)
	if base.newSign == 1 then
		require "luascript/script/game/scene/gamedialog/newSignDialog"
		local month = G_getDate(time).month
		local nd = newSignDialog:new()
	    local tbArr={}
	    local vd = nd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("checkInAward",{month}),true,layerNum);
	    sceneGame:addChild(vd,layerNum);
	else
		require "luascript/script/game/scene/gamedialog/signDialog"
	    local nd = signDialog:new()
	    local tbArr={}
	    local vd = nd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("signTitle"),true,layerNum);
	    sceneGame:addChild(vd,layerNum);
	end
end

function signVoApi:clear()
	if self.dailySignTab then
		for k,v in pairs(self.dailySignTab) do
			self.dailySignTab[k]=nil
		end
		self.dailySignTab=nil
	end
	self.dailySignTab={}
	if self.totalSignTab then
		for k,v in pairs(self.totalSignTab) do
			self.totalSignTab[k]=nil
		end
		self.totalSignTab=nil
	end
	self.totalSignTab={}
	if self.addSignTab then
		for k,v in pairs(self.addSignTab) do
			self.addSignTab[k]=nil
		end
		self.addSignTab=nil
	end
	self.addSignTab={}
	if self.signData then
		for k,v in pairs(self.signData) do
			self.signData[k]=nil
		end
		self.signData=nil
	end
	self.signData={}
	 if self.rewardNumTab then
		for k,v in pairs(self.rewardNumTab) do
	 		self.rewardNumTab[k]=nil
		end
	 	self.rewardNumTab=nil
	end
	self.rewardNumTab={}
	self.flag=-1
end

function signVoApi:initData()
	if self.signData==nil then
		self.signData={}
	end
	if SizeOfTable(self.signData)==0 then
		self.signData.signDay=0
		self.signData.lastTime=0
		self.signData.rewardNum=0
		self.signData.totalNum=0

		-- self.signData.signDay=1
		-- self.signData.lastTime=1393430400
		-- self.signData.rewardNum=1
		-- self.signData.totalNum=22
	end
end

function signVoApi:formatData(data)
	-- mUserinfo.flags.sign = {连续签道的天数,最后一次签到的时间,当前领到的奖励（0-3档）,签到累积的天数}
	self:initData()
	if data and SizeOfTable(data)>0 then
		self.signData.signDay=tonumber(data[1]) or 0
		self.signData.lastTime=tonumber(data[2]) or 0
		self.signData.rewardNum=tonumber(data[3]) or 0
		self.signData.totalNum=tonumber(data[4]) or 0
	end
--[[
	for k,v in pairs(playerCfg.signCfg) do
		if k=="dailySign" then
			for m,n in pairs(v) do
				local dailySignCfg=n
				-- local time=0
				local award=FormatItem(dailySignCfg,nil,true)
		        local vo = signVo:new()
		        vo:initWithData(m,award)
		        self.dailySignTab[m]=vo
		        -- table.insert(self.dailySignTab,m,vo)
		    end
		end
		if k=="totalSign" then
			for m,n in pairs(v) do
				local totalSignCfg=n
				-- local num=0
				local award=FormatItem(totalSignCfg,nil,true)
		        local vo = signVo:new()
		        local id=tonumber(RemoveFirstChar(m))
		        vo:initWithData(id,award)
		        table.insert(self.totalSignTab,vo)
			end
			local function sortAsc(a, b)
				if tonumber(a.id) and tonumber(b.id) then
					return tonumber(a.id) < tonumber(b.id)
				end
			end
			table.sort(self.totalSignTab,sortAsc)
		end
		if k=="AddSign" then
			self.addSignTab=v
		end
    end
]]
	local rewardNumTab=signVoApi:getRewardNumTab()
	local maxDay=rewardNumTab[SizeOfTable(rewardNumTab)]
    if self.signData.totalNum>maxDay then
    	self.signData.totalNum=maxDay
    end
    self:setFlag(0)

 --    if self.signData.signDay>=signVoApi:getMaxNum() then
	-- 	self.signData.signDay=signVoApi:getMaxNum()
	-- end
end

function signVoApi:getFlag()
	return self.flag
end
function signVoApi:setFlag(flag)
	self.flag=flag
end

--距离上一次签到过了几天
function signVoApi:getSignLessDay()
	self:initData()
	if self.signData.lastTime==0 then
		do return 0 end
	end
	local zeroTime
	local lastZeroTime=G_getWeeTs(self.signData.lastTime)
	local nextZeroTime=G_getWeeTs(self.signData.lastTime + 86400)
	--夏令时调整问题，由于夏令时的调整不是零点，因此在零点到调整这段时间签到的玩家，调整之后他们的签到时间就会变成前一天
	--因此将签到的时间戳跟前一天和后一天的零点时间戳对比一下，距离哪个近就算哪天
	if(nextZeroTime - self.signData.lastTime <= 7200)then
		zeroTime=nextZeroTime
	else
		zeroTime=lastZeroTime
	end
	local dayNum=G_keepNumber(((G_getWeeTs(base.serverTime)-zeroTime)/86400),0)-1
	if dayNum<0 then
		dayNum=0
	end
	return dayNum
end

--几天没签到
function signVoApi:getNotSignDay()
	local lessDay=signVoApi:getSignLessDay()
	return lessDay+1
end

function signVoApi:getSignData()
    self:initData()
	-- if self.signData.signDay>=signVoApi:getMaxNum() then
	-- 	self.signData.signDay=signVoApi:getMaxNum()
	-- end
	
	local rewardNumTab=signVoApi:getRewardNumTab()
	local maxDay=rewardNumTab[SizeOfTable(rewardNumTab)]
    if self.signData.totalNum>maxDay then
    	self.signData.totalNum=maxDay
    end
    if self.signData.signDay~=0 and self:getSignLessDay()>=5 then
		self.signData.signDay=0
	end
    return self.signData
end
function signVoApi:updateData(data)
	self:initData()
	if data and SizeOfTable(data)>0 then
		if data.signDay then
			self.signData.signDay=data.signDay
		end
		if data.lastTime then
			self.signData.lastTime=data.lastTime
		end
		if data.rewardNum then
			self.signData.rewardNum=data.rewardNum
		end
		if data.totalNum then
			self.signData.totalNum=data.totalNum
		end
	end
	local rewardNumTab=signVoApi:getRewardNumTab()
	local maxDay=rewardNumTab[SizeOfTable(rewardNumTab)]
    if self.signData.totalNum>maxDay then
    	self.signData.totalNum=maxDay
    end
 --    if self.signData.signDay>=signVoApi:getMaxNum() then
	-- 	self.signData.signDay=signVoApi:getMaxNum()
	-- end
	if self.signData.signDay~=0 and self:getSignLessDay()>=5 then
		self.signData.signDay=0
	end
end

function signVoApi:getDailySign()
    if self.dailySignTab==nil then
        self.dailySignTab={}
    end
    if SizeOfTable(self.dailySignTab)==0 then
    	for k,v in pairs(playerCfg.signCfg) do
			if k=="dailySign" then
				for m,n in pairs(v) do
					local dailySignCfg=n
					local award=FormatItem(dailySignCfg,nil,true)
			        local vo = signVo:new()
			        vo:initWithData(m,award)
			        self.dailySignTab[m]=vo
			    end
			end
		end
    end
    return self.dailySignTab
end
function signVoApi:getTotalSign()
    if self.totalSignTab==nil then
        self.totalSignTab={}
    end
    if SizeOfTable(self.totalSignTab)==0 then
    	for k,v in pairs(playerCfg.signCfg) do
	    	if k=="totalSign" then
				for m,n in pairs(v) do
					local totalSignCfg=n
					-- local num=0
					local award=FormatItem(totalSignCfg,nil,true)
			        local vo = signVo:new()
			        local id=tonumber(RemoveFirstChar(m))
			        vo:initWithData(id,award)
			        table.insert(self.totalSignTab,vo)
				end
				
			end
		end
		local function sortAsc(a, b)
			if tonumber(a.id) and tonumber(b.id) then
				return tonumber(a.id) < tonumber(b.id)
			end
		end
		table.sort(self.totalSignTab,sortAsc)

    end
    return self.totalSignTab
end

function signVoApi:getRewardNumTab()
	if self.rewardNumTab==nil then
		self.rewardNumTab={}
	end
	if SizeOfTable(self.rewardNumTab)==0 then
    	for k,v in pairs(playerCfg.signCfg.totalSign) do
	    	local days=tonumber(RemoveFirstChar(k))
			table.insert(self.rewardNumTab,days)
		end
		local function sortAsc(a, b)
			if tonumber(a) and tonumber(b) then
				return tonumber(a) < tonumber(b)
			end
		end
		table.sort(self.rewardNumTab,sortAsc)
	end
	return self.rewardNumTab
end

function signVoApi:getAddSign()
	return playerCfg.signCfg.AddSign
    -- if self.addSignTab==nil then
    --     self.addSignTab={}
    -- end
    -- if SizeOfTable(self.addSignTab)==0 then
    -- 	self.addSignTab=playerCfg.signCfg.AddSign
    -- end
    -- return self.addSignTab
end

function signVoApi:getDailySignNum()
    local signs=self:getDailySign()
	return SizeOfTable(signs)
end
function signVoApi:getTotalSignNum()
    local signs=self:getTotalSign()
	return SizeOfTable(signs)
end

function signVoApi:getMaxNum()
	return self.maxNum
end

function signVoApi:getDailySignVo(id)
    local signs=self:getDailySign()
	for k,v in pairs(signs) do
		if tostring(v.id)==tostring(id) then
			return v
		end
	end
	return {}
end
function signVoApi:getTotalSignTab(id)
    local signs=self:getTotalSign()
	for k,v in pairs(signs) do
		if tostring(v.id)==tostring(id) then
			return v
		end
	end
	return {}
end

--可以签到或补签，按钮位置
function signVoApi:getCanSignDay()
	local lessDay=self:getSignLessDay()
	local maxNum=self:getMaxNum()
	local signDay=self.signData.signDay
	if signVoApi:isTodaySign()==true then
		do return -1 end
	end
	if lessDay==0 then
		if signDay+1<maxNum then
			return signDay+1
		else
			return maxNum
		end
	elseif lessDay>=maxNum or signDay==0 then
		return 1
	elseif signDay>=maxNum then
		return maxNum
	elseif lessDay+signDay>=maxNum then
		return maxNum
	elseif lessDay+signDay<maxNum then
		return lessDay+signDay+1
	end
end

--领奖
function signVoApi:isCanReward()
	local totalNum=self.signData.totalNum
	local rewardNum=self.signData.rewardNum
	local rewardNumTab=self:getRewardNumTab()

	local isCanReward=false
	if rewardNum<=0 then
		rewardNum=0
	end
	if rewardNum>=3 then
	elseif totalNum>=rewardNumTab[rewardNum+1] then
		isCanReward=true
	end

	return isCanReward
end
function signVoApi:showRewardIdx()
	local rewardNum=self.signData.rewardNum
	local nextRewardIdx=rewardNum+1
	if nextRewardIdx<=0 then
		nextRewardIdx=1
	elseif nextRewardIdx>3 then
		nextRewardIdx=3
	end
	return nextRewardIdx
end

--param isTotal: 是否是累计天数奖励
function signVoApi:getAwardStr(award,numInSign,isTotal)
	local str = ""
	local awardTab = award

    local playerHonors =playerVoApi:getHonors() --用户当前的总声望值
    local maxLevel =playerVoApi:getMaxLvByKey("roleMaxLevel") --当前服 最大等级
    local honTb =Split(playerCfg.honors,",")
    local maxHonors =honTb[maxLevel] --当前服 最大声望值
    local allGems = 0
	--vip特权，奖励翻倍
	local vipPrivilegeSwitch=base.vipPrivilegeSwitch
	local rewardPercent=1
	if(isTotal~=true and vipPrivilegeSwitch and vipPrivilegeSwitch.vsr==1)then
		if(playerCfg.vipRelatedCfg and playerCfg.vipRelatedCfg.dailySign and playerCfg.vipRelatedCfg.dailySign[2] and playerVoApi:getVipLevel()>=playerCfg.vipRelatedCfg.dailySign[1])then
			rewardPercent=playerCfg.vipRelatedCfg.dailySign[2]
		end
	end
	if awardTab and SizeOfTable(awardTab)>0 then
		str = getlocal("daily_lotto_tip_10")
		for k,v in pairs(awardTab) do
			local num=v.num
			if v.key=="honors" then
				num=playerVoApi:getRankDailyHonor(playerVoApi:getRank())
			end
			num=num*rewardPercent

			if k==SizeOfTable(awardTab) then
				str = str .. v.name .. " x" .. num
			else
				if  v.name == getlocal("honor") and base.isConvertGems==1 and tonumber(playerHonors) >=tonumber(maxHonors) then
						local gems = playerVoApi:convertGems(2,num)
						allGems =gems
				else
						str = str .. v.name .. " x" .. num .. ","
				end
			end
		end
	end
	if allGems>0 and numInSign~=nil then
		allGems =allGems*numInSign
		local name = getlocal("money")
		str = str .. ","..name .. " x" .. allGems 
	end
	return str
end


--是否是今天签到
function signVoApi:isTodaySign()
	self:initData()
	if G_isToday(self.signData.lastTime)==true then
		return true
	else
		return false
	end
end


--发送每日签到奖励
function signVoApi:signReward()
	local signDay=self.signData.signDay--连续签到天数
	local notSignday=signVoApi:getNotSignDay()--未签到天数
	local day=signDay+notSignday
	for i=notSignday,1,-1 do
		self:rewardById(day,notSignday)
		day=day-1
	end	
end


--发送每日签到奖励
function signVoApi:rewardById(id,numInSign)
	if numInSign ==nil then
		numInSign =1 
	end

    local playerHonors =playerVoApi:getHonors() --用户当前的总声望值
    local maxLevel =playerVoApi:getMaxLvByKey("roleMaxLevel") --当前服 最大等级
    local honTb =Split(playerCfg.honors,",")
    local maxHonors =honTb[maxLevel] --当前服 最大声望值

	if id<=0 then
		do return end
	end
	if id>self.maxNum then
		id=self.maxNum
	end
	local signVo=self:getDailySignVo(id)
	local award=G_clone(signVo.award)
	--vip特权，奖励翻倍
	local vipPrivilegeSwitch=base.vipPrivilegeSwitch
	local rewardPercent=1
	if(vipPrivilegeSwitch and vipPrivilegeSwitch.vsr==1)then
		if(playerCfg.vipRelatedCfg and playerCfg.vipRelatedCfg.dailySign and playerCfg.vipRelatedCfg.dailySign[2] and playerVoApi:getVipLevel()>=playerCfg.vipRelatedCfg.dailySign[1])then
			rewardPercent=playerCfg.vipRelatedCfg.dailySign[2]
		end
	end
	for k,v in pairs(award) do
		if v.key=="honors" then
			if base.isConvertGems==1 and tonumber(playerHonors) >=tonumber(maxHonors) then
				local gems = playerVoApi:convertGems(2,tonumber(playerVoApi:getRankDailyHonor(playerVoApi:getRank()))*rewardPercent)
				playerVoApi:setValue("gold",playerVoApi:getGold()+gems)
			else			
				playerVoApi:setValue("honors",playerVoApi:getHonors()+tonumber(playerVoApi:getRankDailyHonor(playerVoApi:getRank()))*rewardPercent)
			end
		end
		if v.key=="gems" then
			playerVoApi:setValue("gems",playerVoApi:getGems()+tonumber(v.num)*rewardPercent)
		end
		if v.id and v.id>0 then
			bagVoApi:addBag(v.id,tonumber(v.num)*rewardPercent)
		end
		v.num=v.num*rewardPercent
	end
	G_showRewardTip(award,true)
	-- local awardStr=self:getAwardStr(award,numInSign)
	-- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),awardStr,28)			
end


