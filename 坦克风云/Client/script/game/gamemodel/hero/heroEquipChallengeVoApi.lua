heroEquipChallengeVoApi={
	maxsid=0,--目前最大关卡
	reward={},-- 已领取的章节奖励
	star = 0, -- 目前总星数
	weets = 0, -- 上一次攻击的0点时间戳时间
	challengeVoList={},--所有关卡数据
	ifNeedSendECRequest=true--是否需要请求装备关卡信息
}

function heroEquipChallengeVoApi:clear()
	self.maxsid=0
	self.info=nil
	self.info={}
	self.reward={}
	self.star=0
	self.weets=0
	self.challengeVoList={}
	self.ifNeedSendECRequest=true
end

--partFlag是否拉取的是部分数据，比如说建筑图标显示所需数据，这样的拉取方式不能影响ifNeedSendECRequest
function heroEquipChallengeVoApi:formatData(data,partFlag)
	if partFlag==nil or partFlag==false then
		self.ifNeedSendECRequest=false
	end
	if data.maxsid then
		self.maxsid=data.maxsid

	end
	if data.reward then
		self.reward=data.reward
	end
	if data.star then
		self.star=data.star
	end
	if data.weets then
		self.weets=data.weets
	end
	if data.info then
		for k,v in pairs(data.info) do
			local cVo = heroEquipChallengeVo:new()
			cVo:initWithData(v)
			if self.challengeVoList and self.challengeVoList[k] then
				self.challengeVoList[k]=nil
			end
			self.challengeVoList[k]=cVo
		end
	end
	print("----dmj-----maxsid:"..self.maxsid)
	G_dayin(self.challengeVoList)
end

function heroEquipChallengeVoApi:setRewardFlag(sid)
	sid="s"..sid
	if self.reward and self.reward[sid]==nil then
		self.reward[sid]=1
	end
end

function heroEquipChallengeVoApi:getIfNeedSendECRequest()
	return self.ifNeedSendECRequest
end

function heroEquipChallengeVoApi:setIfNeedSendECRequest(flag)
	self.ifNeedSendECRequest=flag
end

function heroEquipChallengeVoApi:getRewardFlag(sid)
	sid="s"..sid
	if self.reward and self.reward[sid] and self.reward[sid]==1 then
	 	return 1
	end
	return 0
end

-- 判断该关卡是否解锁
function heroEquipChallengeVoApi:checkPointIsUnlock(sid,index)
	local pid = self:getChapterNum()*(sid-1)+index
	if pid==1 then
		return true
	end
	if pid>(self.maxsid+1) then
		return false
	end
	local oldPid = pid-1
	local curStar = self:getPointCurStarNumByPid(oldPid)
	if curStar<=0 then
		return false
	end
	return true
end

function heroEquipChallengeVoApi:getPointPic(sid,index)
	local sid = self:getChapterNum()*(sid-1)+index
	local pic = ""
	if hChallengeCfg and hChallengeCfg.list and hChallengeCfg.list[sid] and hChallengeCfg.list[sid].icon then
		pic=hChallengeCfg.list[sid].icon
	end
	return pic
end

function heroEquipChallengeVoApi:getPointCurStarNumByPid(pid)
	local curTotle = 0
	local pointKey = "s"..pid
	if self.challengeVoList and self.challengeVoList[pointKey] and self.challengeVoList[pointKey].s then
		curTotle=self.challengeVoList[pointKey].s
	end
	return curTotle
end

-- 获取当前关卡的星星数，pid为具体的关卡id
function heroEquipChallengeVoApi:getPointCurStarNum(sid,index)
	local curTotle = 0
	local pointKey = "s"..(self:getChapterNum()*(sid-1)+index)
	if self.challengeVoList and self.challengeVoList[pointKey] and self.challengeVoList[pointKey].s then
		curTotle=self.challengeVoList[pointKey].s
	end
	return curTotle
end

-- 获取当前关卡攻打的次数
function heroEquipChallengeVoApi:getPointAttackNum(sid,index)
	local curAttackNum = 0
	local maxAttackNum = hChallengeCfg.challengeNum
	local pointKey = "s"..(self:getChapterNum()*(sid-1)+index)
	-- 没有跨天的时候，用后台的数据，否则全部重置
	if self.weets==0 or G_isToday(self.weets)==true then
		if self.challengeVoList and self.challengeVoList[pointKey] and self.challengeVoList[pointKey].a then
			curAttackNum=self.challengeVoList[pointKey].a
		end
	end
	return maxAttackNum-curAttackNum,maxAttackNum
end

function heroEquipChallengeVoApi:getPointMaxStarNum()
	return hChallengeCfg.sweepStar
end

-- 当前总共获得的星星数,sid为当前的章节数
function heroEquipChallengeVoApi:getCurStarNum(sid)
	if sid then
		local minpid = self:getChapterNum()*(sid-1)+1
		local maxpid = self:getChapterNum()*sid
		local curTotle = 0
		for i=minpid,maxpid do
			local pointKey = "s"..i
			
			if self.challengeVoList and self.challengeVoList[pointKey] and self.challengeVoList[pointKey].s then
				curTotle=curTotle+self.challengeVoList[pointKey].s
			end
		end
		return curTotle
	end
	return self.star
end

-- 获取该关卡重置的次数，已经金币数
-- return curResetNum：当前重置的次数，maxResetNum：最大可以重置的次数，gold:本次重置需要的金币数
function heroEquipChallengeVoApi:getResetNumAndGold(sid,index)
	local pointKey = "s"..(self:getChapterNum()*(sid-1)+index)
	local curResetNum = 0
	local maxResetNum=0
	local gold = 0
	local vipLevel=playerVoApi:getVipLevel()
	local maxVipLevel = tonumber(playerVoApi:getMaxLvByKey("maxVip"))
	
	if hChallengeCfg and hChallengeCfg.resetNum and hChallengeCfg.resetNum[vipLevel+1] then
		maxResetNum=hChallengeCfg.resetNum[vipLevel+1]
	end
	-- 没有跨天的时候，用后台的数据，否则全部重置
	if self.weets==0 or G_isToday(self.weets)==true then
		if self.challengeVoList and self.challengeVoList[pointKey] and self.challengeVoList[pointKey].r then
			curResetNum=self.challengeVoList[pointKey].r
		end
		
		if curResetNum<maxResetNum then
			if hChallengeCfg and hChallengeCfg.resetGems and hChallengeCfg.resetGems[curResetNum+1] then
				gold=hChallengeCfg.resetGems[curResetNum+1]
			end
		end
	end
	return curResetNum,maxResetNum,gold,vipLevel,maxVipLevel
end

function heroEquipChallengeVoApi:getMinAndMaxPid(sid)
	local minpid = self:getChapterNum()*(sid-1)+1
	local maxpid = self:getChapterNum()*sid
	return minpid,maxpid
end

-- 总共可以获得的星星数
function heroEquipChallengeVoApi:getMaxStarNum(sid)
	if sid then
		local minpid = self:getChapterNum()*(sid-1)+1
		local maxpid = self:getChapterNum()*sid
		local curTotle = 0
		for i=minpid,maxpid do
			local pointKey = "s"..i
			
			if hChallengeCfg and hChallengeCfg.list and hChallengeCfg.list[i] then
				curTotle=curTotle+hChallengeCfg.sweepStar
			end
		end
		return curTotle
	end
	local totlaChapterNum = #hChallengeCfg.list
	return totlaChapterNum*hChallengeCfg.sweepStar
end

function heroEquipChallengeVoApi:getChapterIdByPointId(pointid)
	local chapterId = 1
	local index = 1
	if pointid then
		chapterId=math.ceil(pointid/self:getChapterNum())
		index=math.ceil(pointid%self:getChapterNum())
		if index == 0 then
			index=self:getChapterNum()
		end
	end
	return chapterId,index
end

-- 每个章节的名称
function heroEquipChallengeVoApi:getLocalChaperName(sid)
	return getlocal("equip_explore_name_"..sid)
end

-- 每个关卡的名称
function heroEquipChallengeVoApi:getLocalPointName(sid,pid)
	return getlocal("equip_explore_name_"..sid)..sid.."-"..pid
end

-- 每章节内包含多少关
function heroEquipChallengeVoApi:getChapterNum()
	return hChallengeCfg.chapterNum
end

-- 最多有多少个章节
function heroEquipChallengeVoApi:getMaxChapterNum()
	return math.ceil(SizeOfTable(hChallengeCfg.list)/self:getChapterNum())
end

-- 目前解锁到第几个章节
function heroEquipChallengeVoApi:getUnlockChapter()
	-- if self.maxsid==1 then
	-- 	return 1
	-- end
	-- maxsid是当前获得星的最大关卡
	-- local chapterId,index=self:getChapterIdByPointId(self.maxsid-1)

	
	-- local curStar = self:getPointCurStarNum(chapterId,index)
	local curChapterId = math.ceil(self.maxsid/(self:getChapterNum()))
	-- print("===dmj====1--curChapterId:"..curChapterId)
	if self.maxsid%self:getChapterNum()==0 then
		curChapterId=math.ceil((self.maxsid)/(self:getChapterNum()))+1
		-- print("===dmj====2--curChapterId:"..curChapterId)
	end
	-- print("===dmj====2--curChapterId:"..curChapterId.."---curStar:"..curStar)
	if curChapterId==0 then
		-- print("===dmj====3--curChapterId:"..curChapterId)
		curChapterId=1
	end
	-- print("===dmj====4--curChapterId:"..curChapterId.."---curStar:"..curStar)
	return curChapterId
end
-- 目前显示到第几个章节
function heroEquipChallengeVoApi:getShowMaxPointNum()
	if self:getUnlockChapter()<#hChallengeCfg.chapterReward then
		return self:getUnlockChapter()+1
	end
	return #hChallengeCfg.chapterReward
end

-- 最多有多少个关卡
function heroEquipChallengeVoApi:getMaxPointNum()
	return #hChallengeCfg.list
end

-- 该章节关卡的状态，0已通关,1已解锁，2未解锁,3前一章节未开启，4敬请期待
function heroEquipChallengeVoApi:getChapterFlag(sid)
	if sid<self:getUnlockChapter() then
		-- print("===dmj====1--getChapterFlag:"..sid)
		return 0
	end
	local needUserLevel = 1--该章节解锁需要的用户等级
	if hChallengeCfg.chapterUnlock and hChallengeCfg.chapterUnlock[sid] then
		needUserLevel=hChallengeCfg.chapterUnlock[sid]
		local playerLv = playerVoApi:getPlayerLevel()
		if playerLv<needUserLevel then
			-- print("===dmj====3--getChapterFlag:"..sid)
			return 2,needUserLevel
		end
	end
	if sid==self:getUnlockChapter() then
		-- print("===dmj====2--getChapterFlag:"..sid)
		return 1
	end
	
	-- print("===dmj====4--getChapterFlag:"..sid)
	return 3,self:getLocalChaperName(sid-1)
end

-- 每次攻打消耗的能量
function heroEquipChallengeVoApi:getUseEnergyNum()
	return hChallengeCfg.useEnergy
end

function heroEquipChallengeVoApi:openExploreDialog(chapterId,index,layerNum)
	require "luascript/script/game/scene/gamedialog/heroDialog/heroEquipExploreDialog"
    local function callbackHandler5(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.hchallenge then
                heroEquipChallengeVoApi:formatData(sData.data.hchallenge)
            end
            local td=heroEquipExploreDialog:new(chapterId,index)
            local tbArr={}
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("equip_explore_title"),true,layerNum)
            sceneGame:addChild(dialog,layerNum)
        end
    end
    local minpid,maxpid=heroEquipChallengeVoApi:getMinAndMaxPid(1)
    local maxPointNum=heroEquipChallengeVoApi:getMaxPointNum()
    socketHelper:getEquipExploreList(minpid,maxPointNum,callbackHandler5)
end

function heroEquipChallengeVoApi:openExplorePointDialog(chapterId,index,parentDialog,layerNum)
	require "luascript/script/game/scene/gamedialog/heroDialog/heroEquipExplorePointDialog"
    local vrd=heroEquipExplorePointDialog:new(chapterId,parentDialog,index)
    local vd = vrd:init(layerNum)  
end

function heroEquipChallengeVoApi:openSpecifiedPointDialog(chapterId,pointIndex,layerNum,endBattleCallBack)

	local function showPointDialog()
    	require "luascript/script/game/scene/gamedialog/heroDialog/heroEquipSmallDialog"

	    local starnum = heroEquipChallengeVoApi:getPointCurStarNum(chapterId,pointIndex)
	    local maxStarNum = heroEquipChallengeVoApi:getPointMaxStarNum()
	    local function battleHandler(allReward)
	        local curNum,maxNum = heroEquipChallengeVoApi:getPointAttackNum(chapterId,pointIndex)
	        smallDialog:showExploreSweepDialog(allReward,curNum,chapterId,pointIndex,layerNum,battleHandler)
	        if endBattleCallBack then
		        endBattleCallBack()
		    end
	    end
	    local function callBack()
	    	if endBattleCallBack then
	    		endBattleCallBack()
		    end        
	    end
	    local sid = heroEquipChallengeVoApi:getChapterNum() * (chapterId - 1) + pointIndex
	    local canGetReward = hChallengeCfg.list[sid].clientReward.rand
	    smallDialog:showExplorePointDialog(canGetReward,chapterId,pointIndex,starnum,maxStarNum,layerNum,battleHandler,callBack)
	end


    local function callbackHandler(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.hchallenge then
                heroEquipChallengeVoApi:formatData(sData.data.hchallenge)
                showPointDialog()
            end
        end
    end

    local minpid,maxpid=heroEquipChallengeVoApi:getMinAndMaxPid(chapterId)
    local maxPointNum=heroEquipChallengeVoApi:getMaxPointNum()
    socketHelper:getEquipExploreList(minpid,maxPointNum,callbackHandler)
end

--是否有关卡可以探索
function heroEquipChallengeVoApi:hasPointExplore()
	local maxPoint=self:getShowMaxPointNum()
	for chapterId=1,maxPoint do
		local state=self:getChapterFlag(chapterId)
		if state==1 or state==2 then --已解锁或者已通关状态
			local pointNum=self:getChapterNum()
			for pointId=1,pointNum do
			    local curNum,maxNum=self:getPointAttackNum(chapterId,pointId)
			    if curNum>0 then --有可以探索或者扫荡的关卡
			    	local costEnergy,ownEnergy=self:getUseEnergyNum(),playerVoApi:getEnergy()
			    	if costEnergy<=ownEnergy then --能量充足
			    		return true
			    	end
			    end
			end
		end
	end
	return false
end