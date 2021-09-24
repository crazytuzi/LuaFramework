acBanzhangshilianVoApi={
	report={},
	timeTb={},
	cFlag=1, --关卡数据是否变化
	unlockNewIndex=0, --是否解锁新的关卡，解锁第几关
}

function acBanzhangshilianVoApi:getAcVo()
	return activityVoApi:getActivityVo("banzhangshilian")
end

function acBanzhangshilianVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acBanzhangshilianVoApi:getChallengeName(index)
	return getlocal("activity_banzhangshilian_challenge_"..index)
end

function acBanzhangshilianVoApi:getCFlag()
	return self.cFlag
end
function acBanzhangshilianVoApi:setCFlag(cFlag)
	self.cFlag=cFlag
end

function acBanzhangshilianVoApi:getUnlockNewIndex()
	return self.unlockNewIndex
end
function acBanzhangshilianVoApi:setUnlockNewIndex(unlockNewIndex)
	self.unlockNewIndex=unlockNewIndex
end

--关卡面板 chapterIndex第几章节
function acBanzhangshilianVoApi:showChapterDialog(layerNum,chapterIndex)
	local td=acBanzhangshilianChapterDialog:new(chapterIndex)
    local tbArr={}
    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("activity_banzhangshilian_chapter_name_"..chapterIndex),true,layerNum)
    sceneGame:addChild(dialog,layerNum)
end

--关卡部队信息面板 index第几关卡
function acBanzhangshilianVoApi:showTroopsInfoDialog(layerNum,index)
	local cName=self:getChallengeName(index)
	local td=acBanzhangshilianTroopsInfoDialog:new(index)
    local tbArr={}
    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,cName,true,layerNum)
    sceneGame:addChild(dialog,layerNum)
end

--通关排行面板
function acBanzhangshilianVoApi:showFullStarRankDialog(layerNum,index)
	local cName=self:getChallengeName(index)
	local td=acBanzhangshilianFullStarRankDialog:new(layerNum,index)
    local tbArr={}
    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,cName,true,layerNum)
    sceneGame:addChild(dialog,layerNum)
end

--兵力部署面板
function acBanzhangshilianVoApi:showSetTroopsDialog(layerNum,index,parent)
	local cName=self:getChallengeName(index)
	local td=acBanzhangshilianSetTroopsDialog:new(index,parent)
    local tbArr={}
    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,cName,true,layerNum)
    sceneGame:addChild(dialog,layerNum)
end

function acBanzhangshilianVoApi:getScore()
	local vo = self:getAcVo()
	local star = 0
	if vo.star then
		star = vo.star
	end
	return star
end

function acBanzhangshilianVoApi:setScore(star)
	local vo = self:getAcVo()
	vo.star = star
end

function acBanzhangshilianVoApi:getLimitScore()
	local vo = self:getAcVo()
	if vo.scoreLimit then
		return vo.scoreLimit
	end
	return 0
end
--今天是否刷新过
function acBanzhangshilianVoApi:refreshIsToday()
	local vo=self:getAcVo()
	return G_isToday(vo.lastRefreshTime)
end
--今天是否攻击过
function acBanzhangshilianVoApi:attackIsToday()
	local vo=self:getAcVo()
	return G_isToday(vo.lastAttackTime)
end

function acBanzhangshilianVoApi:getAttackNumIsMax()
	local num=0
	local isMax=false
	local attackIsToday=self:attackIsToday()
    if attackIsToday==true then
		local acVo=self:getAcVo()
		num=acVo.attackNum
	    local maxNum=acVo.dailyAtt
	    if num>=maxNum then
	    	isMax=true
	    end
	end
    return isMax,num
end
function acBanzhangshilianVoApi:getUseTankInfo()
	local refreshIsToday=self:refreshIsToday()
	if refreshIsToday==true then
		local acVo=self:getAcVo()
		local useTankInfo=acVo.useTankInfo
	    if useTankInfo and SizeOfTable(useTankInfo)>0 then
	        return useTankInfo
	    end
	end
    return {}
end
function acBanzhangshilianVoApi:getChapterByCIndex(cIndex)
	local chapterIndex
	local acVo=self:getAcVo()
	if acVo and cIndex then
	    local charpter=acVo.charpter
	    chapterIndex=math.ceil(cIndex/charpter)
	end
	return chapterIndex
end
function acBanzhangshilianVoApi:getChapterIsUnlock(index)
	local acVo=self:getAcVo()
    local challengeInfo=acVo.challengeInfo
    local charpter=acVo.charpter
    local unlock=false
    if index==1 then
        unlock=true
    elseif challengeInfo and challengeInfo[index-1] and SizeOfTable(challengeInfo[index-1])>=charpter then
        unlock=true
    end
    return unlock
end
function acBanzhangshilianVoApi:getChapterIsComplete(index)
	local acVo=self:getAcVo()
    local challengeInfo=acVo.challengeInfo
    local charpter=acVo.charpter
    local isComplete=false
    if index and challengeInfo and challengeInfo[index] and SizeOfTable(challengeInfo[index])>=charpter then
        isComplete=true
    end
    return isComplete
end

function acBanzhangshilianVoApi:getTankFighting()
	local tankFighting=0
	local acVo=self:getAcVo()
	if acVo then
		local useTankInfo=self:getUseTankInfo()
	    if useTankInfo and SizeOfTable(useTankInfo)>0 then
	        for k,v in pairs(useTankInfo) do
	        	if v then
		            local id=(tonumber(v) or tonumber(RemoveFirstChar(v)))
		            if id and tankCfg[id] and tankCfg[id].fighting and tonumber(tankCfg[id].fighting) then
			            tankFighting=tankFighting+tonumber(tankCfg[id].fighting)*acVo.peakNum
			        end
			    end
	        end
	    end
	end
    return tankFighting
end
--取出坦克队列按战力从大到小排
function acBanzhangshilianVoApi:getAllTanks()
	local tanks={}
	local acVo=self:getAcVo()
	if acVo then
		local useTankInfo=self:getUseTankInfo()
		local peakNum=acVo.peakNum
	    if useTankInfo and SizeOfTable(useTankInfo)>0 then
	    	for k,v in pairs(useTankInfo) do
	        	if v then
	        		local isHas=false
	        		for m,n in pairs(tanks) do
	        			if n and n[1] and v==("a"..n[1]) then
	        				isHas=true
	        				if tanks[m][2] then
	        					tanks[m][2]=tanks[m][2]+peakNum
	        				else
	        					tanks[m][2]=peakNum
	        				end
	        			end
	        		end
	        		if isHas==false then
	        			local id=(tonumber(v) or tonumber(RemoveFirstChar(v)))
	        			table.insert(tanks,{id,peakNum})
        			end
			    end
	        end
	    end
	end
	if SizeOfTable(tanks)>0 then
		for k,v in pairs(tanks) do
			if v and v[1] and v[2] then
				local tid=v[1]
				local num=v[2]
				local id=(tonumber(tid) or tonumber(RemoveFirstChar(tid)))
	            if id and tankCfg[id] and tankCfg[id].fighting and tonumber(tankCfg[id].fighting) then
		            local tankFighting=tonumber(tankCfg[id].fighting)*num
		            tanks[k][3]=tankFighting
		            tanks[k][4]=tonumber(tankCfg[id].sortId)
		        end
		    end
		end
		local function sortFunc(a,b)
	        if a and b then
	        	if a[3] and b[3] and a[3]~=b[3] then
		        	return a[3]>b[3]
		        elseif a[4] and b[4] then
		        	return a[4]>b[4]
		        end
		    end
		end
		table.sort(tanks,sortFunc)
	end
	return tanks
end

--取出最大战斗力坦克队列
function acBanzhangshilianVoApi:getBestTanks()
	local bestTab={}
	local acVo=self:getAcVo()
	if acVo then
		local peakNum=acVo.peakNum
		local temTanks=G_clone(self:getAllTanks())
		local index=1
		while index<7 do
			if temTanks and temTanks[1] and temTanks[1][1] and temTanks[1][2] then
				local item={temTanks[1][1],peakNum}
				table.insert(bestTab,item)
				temTanks[1][2]=temTanks[1][2]-peakNum
				if temTanks[1][2]<=0 then
					table.remove(temTanks,1)
				end
			end
			index=index+1
		end
	end
	return bestTab
end

function acBanzhangshilianVoApi:getRanklist()
	return self.ranklist
end

function acBanzhangshilianVoApi:setRank()
	local ranklist=self:getRanklist()
	for k,v in pairs(ranklist) do
		if tostring(v[1])==tostring(playerVoApi:getPlayerName()) then
			self.rank=k
			self:setScore(v[4])
			return
		end
	end
end

function acBanzhangshilianVoApi:getRank()
	return self.rank
end

 -- 是否领取过排行奖励
function acBanzhangshilianVoApi:isReceive()
	local vo = self:getAcVo()
	return vo.isReceive
end

function acBanzhangshilianVoApi:setReceive(receive)
	local vo = self:getAcVo()
    vo.isReceive=receive
end

-- 是否是领奖时间
function acBanzhangshilianVoApi:acIsStop()
	local vo=self:getAcVo()
	if vo and base.serverTime<(vo.et-24*3600) then
		return false
	end
	return true
end

function acBanzhangshilianVoApi:rankCanReward()
	local vo=self:getAcVo()
	if vo and vo.isReceive==nil and self:acIsStop()==true and activityVoApi:isStart(vo) then
		if vo.star and vo.star>=self:getLimitScore() then
			if self.ranklist and SizeOfTable(self.ranklist)>0 then
				for k,v in pairs(self.ranklist) do
					if v and v[1] and tostring(v[1])==tostring(playerVoApi:getPlayerName()) then
						return tonumber(k) or 0
					end
				end
			end
		end
	end
	return 0
end

-- 排行榜奖励
function acBanzhangshilianVoApi:getrankReward()
	local vo = self:getAcVo()
	if vo.rewardCfg then
		return vo.rewardCfg
	end
end

function acBanzhangshilianVoApi:setRanklist(list)
	self.ranklist={}
	if list then
		self.ranklist=list
	end
end

-- 排行榜列表
function acBanzhangshilianVoApi:getSocketRankList(callback)
	local function getRankList(fn,data)
		local ret,sData=base:checkServerData(data)
	    if ret==true then
	        if sData and sData.data and sData.data.rankList then
	            self:setRanklist(sData.data.rankList)
	        end
	        self:setRank()
	        callback()
	    end
	end
	socketHelper:acBanzhangshilianRank(getRankList)
end

-- 每关的前5名log
function acBanzhangshilianVoApi:getSocketLog(callback,cIndex)
	local function getLog(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.report then
				self.report[cIndex]=sData.data.report
			end
			callback()
			self.timeTb[cIndex]=base.serverTime+600
		end
	end
	if self.timeTb[cIndex]==nil then
		self.timeTb[cIndex]=0
	end
	if base.serverTime>self.timeTb[cIndex] then
		socketHelper:acBanzhangshilianLog(cIndex,getLog)
	else
		callback()
	end
	
end

function acBanzhangshilianVoApi:getReport(cIndex)
	return self.report[cIndex]
end

function acBanzhangshilianVoApi:getSelectTank()
	local acVo=self:getAcVo()
	local selectTank=acVo.selectTank
	local useTankInfo=self:getUseTankInfo()
	if useTankInfo and useTankInfo[selectTank] then
		return useTankInfo[selectTank]
	end
	return nil
end

function acBanzhangshilianVoApi:getLandform(index)
	local acVo=self:getAcVo()
    local challengeCfg=acVo.challengeCfg
    local landform
    if challengeCfg and challengeCfg[index] and challengeCfg[index].land then
    	local landType=tonumber(challengeCfg[index].land) or 4
    	landform={landType,landType}
    end
    return landform
end

function acBanzhangshilianVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
	return vo
end

function acBanzhangshilianVoApi:canReward()
	if self:refreshIsToday()==false and self:acIsStop()==false then
		return true
	end
	return false
end

function acBanzhangshilianVoApi:clearAll()
	self.ranklist={}
	self.rank = nil
	self.report={}
	self.timeTb={}
	self.cFlag=1
	self.unlockNewIndex=0
end
