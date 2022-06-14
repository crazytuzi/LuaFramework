local hurtRankData = class("hurtRankData")



 
function hurtRankData:ctor()
	self.currentStageIndex = 1
	self.battleNum = 0
	self.ranking = 0 --自己当前排名
 
	self.score = 0 --本次成绩
	self.scoreHistroy = nil--历史最哈成绩
	self.hurtRankingPlayers = {}
end 	

function hurtRankData:SetCurrentStageIndex(i)
	self.currentStageIndex = i + 1
end 	

function hurtRankData:setRank(rank)
	self.ranking = rank
end 	

function hurtRankData:getName()
	return "伤害排行"
end 	


function hurtRankData:getCloseTipDes()
	return "活动已结束，请明日再战"
end 	

function hurtRankData:getNoBattleNumTipDes()
	return "挑战次数已耗尽，请明日再战"
end 	


function hurtRankData:getNoLevelTipDes()
	return "等级不足，伤害排行"
end 	


function hurtRankData:isBattleNumEnough()
	return  self:getBattleNum() < self:getMaxBattleNum()
end 	


function hurtRankData:getOpenLevel()
	 return dataConfig.configs.ConfigConfig[0].challengeDamageLevelLimit	
end 


function hurtRankData:isLevelEnough()
	return dataManager.playerData:getLevel() >= self:getOpenLevel()
end 

function hurtRankData:getMaxBattleNum()
	 return dataConfig.configs.ConfigConfig[0].challengeDamageTimesLimit	
end 	

function hurtRankData:getBattleNum()
	return dataManager.playerData:getCounterData( enum.COUNTER_TYPE.COUNTER_TYPE_CHALLENGE_DAMAGE_TIMES)-- 今日伤害挑战次数
end 


 
function hurtRankData:getCloseTime()
	 return dataConfig.configs.ConfigConfig[0].challengeDamageCloseTime	
end 	
 
function hurtRankData:getOpenTime()
	 return "06:00"
end 	

function hurtRankData:isOpenTime()
	  	
	local time  = os.date("!*t", dataManager.getServerTime() - dataManager.timezone * 60 * 60)		
	local beginTime = self:getOpenTime()
	local endTime = self:getCloseTime()
	
	local _i,_j = string.find(beginTime, ":")
	local i,j = string.find(endTime, ":")	
	
	local ehour = tonumber( string.sub(endTime,1,i-1)	)	
	local emin = tonumber(string.sub(endTime,j+1,-1))
		
	local bhour = tonumber( string.sub(beginTime,1,_i-1)	)	
	local bmin = tonumber(string.sub(beginTime,_j+1,-1))
	
	
	local num = time.hour*60 + time.min
	
	if(num >=  (bhour*60 + bmin)  and  num < (ehour*60 + emin)  )then
		 return true
	end
	return false
end 	




function hurtRankData:getStageId()
	local stages = dataConfig.configs.ConfigConfig[0].challengeDamageStageID
	self.currentStageIndex = math.mod(self.currentStageIndex , #stages)    
	if(self.currentStageIndex < 0 or self.currentStageIndex > #stages )then
		self.currentStageIndex = 1
	end
	if(self.currentStageIndex == 0  )then
		self.currentStageIndex = #stages
	end
	return 	stages[self.currentStageIndex]
end


function hurtRankData:getBossId()
	 local stageId = 	self:getStageId()
	 local unitId = dataConfig.configs.stageConfig[stageId].units[1] 
	 return unitId
end

function hurtRankData:SetBossAtt(challengeDamageDefence,challengeDamageResilience)
	self.challengeDamageDefence = 	challengeDamageDefence 	
	self.challengeDamageResilience = 	challengeDamageResilience 	  
end	

function hurtRankData:getBossAttChallengeDamageDefence()
	return self.challengeDamageDefence or 0 
end	
function hurtRankData:getBossAttChallengeDamageResilience()
	return self.challengeDamageResilience or 0 
end	

-- 排名可以获得的奖励
function hurtRankData:getRankReward(level)
	local level = level or ( self.ranking  or 0)
	local t ={}
	local size = #dataConfig.configs.challengeDamageConfig 
	if(level <= 0 or level > dataConfig.configs.challengeDamageConfig [size].rank )then
		return t
	end
	
	local findIndex = nil
	for i ,v in ipairs (dataConfig.configs.challengeDamageConfig  )	do
		if((level) <=  tonumber (v.rank))then
			findIndex = i
			break
		end
	end 
	if(findIndex)then
		local reward  = dataConfig.configs.challengeDamageConfig [findIndex]
		for i,v in ipairs 	(reward.rewardType) do
			table.insert(t,dataManager.playerData:getRewardInfo(v, reward.rewardID[i], reward.rewardCount[i]))
		end
	end
	return t 
end

function hurtRankData:getRewardList()
	local t ={}
	local index = 0
	for k, reward in ipairs (dataConfig.configs.challengeDamageConfig )do
		index = index +1
		t[index] = t[index]  or {}
		t[index].rank = reward.rank
		for i,v in ipairs 	(reward.rewardType) do
			table.insert(t[index] ,dataManager.playerData:getRewardInfo(v, reward.rewardID[i], reward.rewardCount[i]))
		end
	end
	return t
end


-- 排名
function hurtRankData:getRanking()
	local  ranking = self.ranking 
	local str = ranking
	if(ranking == nil or ranking <= 0)then
		local t ={}
		local size = #dataConfig.configs.challengeDamageConfig 	
		--str =  dataConfig.configs.challengeDamageConfig [size].rank .."+"
		str = "未上榜"
		ranking = ranking or 0
	end
	return   str ,ranking
end	

function hurtRankData:getScore()
	return 	self.score, math.abs(dataManager.playerData:getCounterData( enum.COUNTER_TYPE.COUNTER_TYPE_CHALLENGE_DAMAGE_SCORE))--  今日伤害挑战最大得分        
	
end	
function hurtRankData:setScore(s)
		 self.score  = s
end


function hurtRankData:setHistroyScore(s)
		 self.scoreHistroy  = s
end

function hurtRankData:setServerResult(b)
		 self.serverResult  = b
end
 
function hurtRankData:getServerResultOK()
		 return self.serverResult  == true
end

function hurtRankData:getHistroyScore()
		 return  self.scoreHistroy or  math.abs(dataManager.playerData:getCounterData( enum.COUNTER_TYPE.COUNTER_TYPE_CHALLENGE_DAMAGE_SCORE))
end



local hurtPlayer = class("hurtPlayer")

function hurtPlayer:ctor()
	self.icon = 0
	self.level = 0
	self.name = ""
	self.ranking = 0 
	self.damage = 0
	self.replayID  = -1
end 

function hurtPlayer:getHeadId()
	return self.icon
end 
function hurtPlayer:getRanking()
	 if(self.ranking == nil or self.ranking <= 0)then
		local size = #dataConfig.configs.challengeDamageConfig 	
		str =  dataConfig.configs.challengeDamageConfig [size].rank .."+"
		return str,self.ranking
	end
	
	return  self.ranking,self.ranking	
end 	

function hurtPlayer:getName()
	local name = self.name 
	if(name == nil or name == "")then
		return    "风流小韵妇"
	end
	return  name
end 			

function hurtPlayer:getLevel()
	return self.level
end 
function hurtPlayer:getDamage()
	return self.damage
end 	

function hurtPlayer:getReplayID()
	return self.replayID
end 				


---排行榜玩家
function hurtRankData:createHurtPlayer(data,index)
	local player = 	hurtPlayer.new()
	player.icon  = data['iconID'] 
	player.name  = data['name'] 
	player.ranking  = data['rank'] 
	player.level  = data['level'] 
	player.damage  = data['score'] 
	player.replayID  = data['replayID']
	player.miracle = data['miracle'];
	
	self.hurtRankingPlayers[index] = player	
end	
	

return hurtRankData