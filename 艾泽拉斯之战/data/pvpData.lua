local pvpData = class("pvpData")



 
function pvpData:ctor()
	self.win = {}
	self.lose = {}
	self.players = {}  --pvp 对战的那5个人 异步pvp
	self.RankingPlayers = {} -- 
	self.offlineReplayRecord = {}
	self.refreshNewPlayerPreTime = nil
	
	self.offlineFuchouFlag = false
	self.offlineFuchouPlayerId = nil
	self.offlineFuchouPlayer = nil
end 	


 

function pvpData:getOfflineFuchouFlag()
	return self.offlineFuchouFlag
end	

function pvpData:setOfflineFuchouFlag(f)
	     self.offlineFuchouFlag = f
end	

function pvpData:getSelectFuchouPlayerId()
	return self.offlineFuchouPlayerId
end	

function pvpData:setSelectFuchouPlayerId(id)
	     self.offlineFuchouPlayerId = id
end	


function pvpData:getFuchouSelectPlayer()
	 return self.offlineFuchouPlayer
end	

------------------------------------------------------------------------------------------


function pvpData:getNextPvpOfflineRefleshTime()
		
		 local t = 	dataConfig.configs.ConfigConfig[0].pvpOfflineRefleshTimes

		 local h, m, s = dataManager.getLocalTime();
		 local nowSecondAfterZeroClock = h * 60 * 60 + m * 60 + s;
		 
		 local newConfig = {};
		 table.insert(newConfig, dataConfig.configs.ConfigConfig[0].playerResetTime);
		 
		 for k, v in ipairs(t) do
		 	table.insert(newConfig, v);
		 end
		 
		 local resultKey = -1;
		 for k, v in ipairs(newConfig) do
		 	
		 	local hour, minute = stringToTime(v);
		 	local secondAfterZeroClock = hour * 60 * 60 + minute * 60;
		 	
		 	if nowSecondAfterZeroClock < secondAfterZeroClock then
		 		resultKey = k;
		 		break;
		 	end
		 	
		 end
		 
		 if resultKey == -1 then
		 	resultKey = 1;
		 end
		 
		 return newConfig[resultKey];
end







function pvpData:getOnlineName()
	return "pvp活动"
end	
function pvpData:getOnlineBeginTime()
	
	local time  = os.date("!*t", dataManager.getServerTime() - dataManager.timezone * 60 * 60)		
	local t = 	dataConfig.configs.ConfigConfig[0].pvpEndTime   -- 这里没错
	local findIndex = 1
	for k, v in ipairs (t) do
		local i,j = string.find(v, ":")
		local hour = tonumber( string.sub(v,1,i-1)	)	
		local min = tonumber(string.sub(v,j+1,-1))
		findIndex = k
		if(time.hour  < hour )then
			 findIndex = k
			 break 
		elseif(time.hour == hour )then
			if(time.min  < min )then
				findIndex = k
				break 	
			end	
		end			
	end		
 
	local isProcessing  = false -- 获得进行中
	
	local beginTime = 	dataConfig.configs.ConfigConfig[0].pvpBeginTime[findIndex]
	local endTime = 	dataConfig.configs.ConfigConfig[0].pvpEndTime[findIndex]
	local _i,_j = string.find(beginTime, ":")
	local i,j = string.find(endTime, ":")
	
	local ehour = tonumber( string.sub(endTime,1,i-1)	)	
	local emin = tonumber(string.sub(endTime,j+1,-1))
		
	local bhour = tonumber( string.sub(beginTime,1,_i-1)	)	
	local bmin = tonumber(string.sub(beginTime,_j+1,-1))
	
	
	local num = time.hour*60 + time.min
	
	if(num >=  (bhour*60 + bmin)  and  num < (ehour*60 + emin)  )then
		isProcessing = true
	end
	
	
	---  '11:58'    true/falses    
	return beginTime,isProcessing,endTime

end 

function pvpData:getOnlineWinNum()
	return dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_PVP_ONLINE_WIN) or 0-- 在线pvp胜利次数
end	


function pvpData:getOnlineLoseNum()
	return dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_PVP_ONLINE_FAIL) or 0-- 在线pvp失败次数
end	

function pvpData:getTotalTimes()
	return dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_PVP_ONLINE_TIMES) or 0;
end

function pvpData:isOnlineOver()
	return self:getOnlineLoseNum() >=  dataConfig.configs.ConfigConfig[0].pvpOnlineFailLimit   or self:getOnlineWinNum() >=   dataConfig.configs.ConfigConfig[0].pvpOnlineWinLimit
end	

function pvpData:isOnlineCD()
	local cd = dataManager.playerData:getPlayerAttr(enum.PLAYER_ATTR64.PLAYER_ATTR64_NEXT_PVP_ONLINE_TIME)
	cd = cd or 0
	local s = math.ceil(cd - dataManager.getServerTime())
	return s  > 0, s
end	

function pvpData:canMatching()
	
	local beginTime,isPvPing ,endTime = self:getOnlineBeginTime();
	local lose = self:isOnlineOver();
	local cd = self:isOnlineCD();
	
	return isPvPing and not lose and not cd and dataManager.getServerOpenDay() >= 1;
end


function pvpData:setBattleTime()
	self.waitBattleTime =  dataManager.getServerTime()
end

function pvpData:getBattleTime()
	return self.waitBattleTime or 0
end

function pvpData:isWaitCD()
	local cd = dataConfig.configs.ConfigConfig[0].pvpOnlineCoolDown + 1
	 
	local space = math.ceil(  cd - (dataManager.getServerTime() -  self:getBattleTime()) )
	
	return  space > 0,  space
end	


-- 排名可以获得的奖励
function pvpData:getReward(wins)
	local wins = wins or self:getOnlineWinNum()
	local size = #dataConfig.configs.PvpOnlineConfig 	
	local t ={}
	for k = size ,1 ,-1 do
		if( dataConfig.configs.PvpOnlineConfig[k].wins <= wins )then
			local reward  = dataConfig.configs.PvpOnlineConfig [k]
			for i,v in ipairs 	(reward.rewardType) do
				table.insert(t,dataManager.playerData:getRewardInfo(v, reward.rewardID[i], reward.rewardCount[i]))
			end
			break
		end
	end	
	return t 
end

function pvpData:getRewardList()
	local t ={}
	local index = 0
	for k, reward in ipairs (dataConfig.configs.PvpOnlineConfig )do
		index = index +1
		t[index] = t[index]  or {}
		t[index].rank = reward.wins
		for i,v in ipairs 	(reward.rewardType) do
			table.insert(t[index] ,dataManager.playerData:getRewardInfo(v, reward.rewardID[i], reward.rewardCount[i]))
		end
	end
	return t
end



------------------------------------------------------------------------------------------

--异步pvp


local pvpOffLinePlayer = class("pvpOffLinePlayer")

function pvpOffLinePlayer:ctor()
	self.ranking = 0
	self.power = 0
	self._playerPower = 0
	self.kingInfo = {}
	self.units = {}
	self.name = ""
	self.posIndex = nil ---数组的位置索引 0 到 4
	self.icon = 1
	self.myths = 0
end 	
 
function pvpOffLinePlayer:getUnitsData(index)
	return self.units[index]
end

function pvpOffLinePlayer:getkingInfoData()
	return self.kingInfo
end


function pvpOffLinePlayer:getOfflineRanking()
	if(self.ranking == nil or self.ranking <= 0)then
		--return dataConfig.configs.ConfigConfig[0].pvpOfflineMaxRank.."+",self.ranking
		return "未上榜"
	end
	
	return  self.ranking,self.ranking	
end	
function pvpOffLinePlayer:getHeadId()
	return self.icon
end	

function pvpOffLinePlayer:getMyths()
	return self.myths 
end	

function pvpOffLinePlayer:getName()
	local name = self.name 
	if(name == nil or name == "")then
		return    "守护者"
	end
	return  name
end	

 

function pvpOffLinePlayer:playerPower()
 
	local power = 0	
	for i,v in ipairs(self.units)do
		local star = dataConfig.configs.unitConfig[v.id].starLevel
		local quality = dataConfig.configs.unitConfig[v.id].quality
		
		local count = dataConfig.configs.unitConfig[v.id].food * v.count 		
		
		power = power +  global.getOneShipPower( star,quality, count,v['shipAttr'].attack,v['shipAttr'].defence,v['shipAttr'].critical,v['shipAttr'].resilience)
	end
	local magicStars = {}
	for i,v in ipairs(self.kingInfo.magics )do
		if(v. id > 0 )then
			table.insert(magicStars,v.level)
		end
	end	
	power = power + global.getAllMagicPower(magicStars,self.kingInfo.intelligence)	
	self._playerPower =  math.ceil(power)
	return self._playerPower
end
function pvpOffLinePlayer:setData(data)
	self.name = data['name']
	self.ranking = data['rank']
	self.playerId = data['playerID']
	self._playerPower = data['playerPower']
	local kingInfo = data['kingInfo']
	self.icon = data['icon']
	self.myths = data['miracle'];
	self.kingInfo.level = kingInfo.level
	self.kingInfo.intelligence = kingInfo.intelligence
	self.kingInfo.maxMP = kingInfo.maxMP
	self.kingInfo.force = kingInfo.force
	self.kingInfo.magics = {}
	local magics = kingInfo['magics']    
		
	for i = 1,#magics do
		self.kingInfo.magics[i] = {id = magics[i]['id'],level = magics[i]['level'] }
	end	
	 
	local units = data['units']  

	for i = 1,#units do
		local tempUnit = {};
		local data = units[i]
		tempUnit.id = data['id'] 
		tempUnit.index = data['index'] --unit在战场上的index
		tempUnit.force  = data['force'] 
		tempUnit.count  = data['count'] 
		tempUnit.pos = {x =  data['position'].x, y =  data['position'].y}   
		tempUnit.shipAttr = { attack =   data['shipAttr'].attack , defence =   data['shipAttr'].defence, critical =   data['shipAttr'].critical, resilience  =   data['shipAttr'].resilience   }
		self.units[i] = tempUnit
	end	
	

end
--index 从1开始
function pvpOffLinePlayer:getOfflineCrops(index)
	local unit  =	 self.units[index]		
	if unit then
				local info = {}
				info.unitID = unit.id
				info.starLevel = dataConfig.configs.unitConfig[unit.id].starLevel;	
				info.icon = dataConfig.configs.unitConfig[unit.id].icon;	
				return 	info		
	end		
	return 	nil
	 
end

function pvpData:setSelectPlayer(index)
	 self.selectPlayer  = index
end	

---挑战选择
function pvpData:getSelectPlayer()
	 return self:getPlayer(self.selectPlayer)
end	

function pvpData:getPlayerWithPlayerID(playerID)
	for i ,v in pairs ( self.players) do
		if(v.playerID == playerID) then
			return v
		end
	end
	return nil
end	


function pvpData:getPlayer(index)
	return self.players[index]
end	

function pvpData:refreshNewPlayer(checkCd)
	if(self.refreshNewPlayerPreTime ~= nil and checkCd == true)then
		local time  = dataManager.getServerTime()
		if(time - self.refreshNewPlayerPreTime < dataConfig.configs.ConfigConfig[0].pvpOfflineRematchCD ) then 
			eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo = "冷却中，请稍候再试..".. math.ceil(dataConfig.configs.ConfigConfig[0].pvpOfflineRematchCD -time +self.refreshNewPlayerPreTime ) });
			return
		end	
	end
	print("refreshNewPlayer  --- refreshNewPlayer  111")
		sendPvpRefresh()
		print("refreshNewPlayer  --- refreshNewPlayer 222")
		if(checkCd)then
			self.refreshNewPlayerPreTime = dataManager.getServerTime()
		end
end	
function pvpData:OncreateOfflinePlayer()
	print("OncreateOfflinePlayer  --- OncreateOfflinePlayer")
	self.players = {}
end	
function pvpData:sendAskLadderDetail(player,pos)
 
	if(self.sendAskLadderDetailFlag ~= false)then
		sendAskLadderDetail(player.playerId,player.ranking)
	    self.sendAskLadderDetailFlag = false
		self.tippos = pos
	end
end	


function pvpData:getAskedLadderDetail()
	return self.rankDetailPlayer 
	
end	
function pvpData:onAskLadderDetail(playerData)
	self.sendAskLadderDetailFlag = true
	self.rankDetailPlayer = nil
	self.rankDetailPlayer = 	pvpOffLinePlayer.new()
	self.rankDetailPlayer:setData(playerData)
 

	if(dataManager.pvpData:getOfflineFuchouFlag())then
		self.offlineFuchouPlayer = self.rankDetailPlayer
		global.gotoPvpOfflineBattle()
	else
		eventManager.dispatchEvent({name = global_event.PVPTIPS_SHOW ,pos = self.tippos})	
	end
	 
	
	
end	

function pvpData:onCheckChatPlayer(playerData, pos)

	self.rankDetailPlayer = nil
	self.rankDetailPlayer = 	pvpOffLinePlayer.new()
	self.rankDetailPlayer:setData(playerData)
	
	
	if(dataManager.buddyData:getAskPkPlayerDetail( )) then
			dataManager.buddyData:setAskPkPlayerDetail(false )
			eventManager.dispatchEvent({name = global_event.SOCIALNETWORK_HIDE});
			global.changeGameState(function() 
			sceneManager.closeScene();
			eventManager.dispatchEvent({name = global_event.MAIN_UI_CLOSE});
			local btype = enum.BATTLE_TYPE.BATTLE_TYPE_FIGHT
		
			game.EnterProcess(game.GAME_STATE_BATTLE_PREPARE, { battleType = btype, planType = enum.PLAN_TYPE.PLAN_TYPE_PVE }); 		
		end);
		return
	end

	eventManager.dispatchEvent({name = global_event.PVPTIPS_SHOW ,pos = pos});
	
end	
 
function pvpData:CheckandCleanCdOffline( )
	
	local vip = dataManager.playerData:getVipLevel()
	local configLevel = dataConfig.configs.ConfigConfig[0].pvpOfflineCDVipLevel or 0
	if(vip >= configLevel )then
		return false
	end
 
	local cd ,cost = self:getOfflineCd()	
	if(cd <=0 )then
		return  false
	end
   	eventManager.dispatchEvent({name = global_event.NOTICEDIAMOND_SHOW, 
				messageType = enum.MESSAGE_DIAMOND_TYPE.CLEAN_CD, data = {count = cost,func =  global.CleanPvpCdOffline }, 
				textInfo = "" });	
	return  true																		
end	


function pvpData:CheckResetOfflineBattleNum()
	local  BatleNum = dataManager.pvpData:getOfflineBatleNum()
	local  MaxBatleNum = dataManager.pvpData:getOfflineBatleMaxNum()
	local canBattleNum = MaxBatleNum - BatleNum
	if canBattleNum > 0 then
		return false		
	end
    local cost  = dataConfig.configs.ConfigConfig[0].pvpOfflineResetTimes
   	eventManager.dispatchEvent({name = global_event.NOTICEDIAMOND_SHOW, 
				messageType = enum.MESSAGE_DIAMOND_TYPE.RESET_NUM, data = {num = MaxBatleNum,   count = cost,func =   global.ResetOfflineBattleNum }, 
				textInfo = "" });	
	return  true						
end	

--得到玩家历史最高排名
function pvpData:getOfflinePlayerMaxRank()
	local  ranking = dataManager.playerData:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_BEST_RANK)	
	if(ranking == nil or ranking <= 0)then
		--ranking =  dataConfig.configs.ConfigConfig[0].pvpOfflineMaxRank.."+"
		ranking = "未上榜"
	end		
	return    ranking
end	
---排行榜玩家
function pvpData:createOfflineRankingPlayer(data,index)
	local player = 	pvpOffLinePlayer.new()
	player.name = data['name']
	player.ranking = data['rank']
	player.playerId = data['playerID']

	player.kingInfo ={}	
	player.kingInfo.level = data['level']

	self.RankingPlayers[index] = player	
	player.posIndex = index - 1	
	player.icon = data['icon']
	
	player.miracle = data['miracle'];
	
end


function pvpData:createOfflinePlayer(data,index)
	--print("pvpData:createOfflinePlayer "..index);
	--dump(data)
	local player = 	pvpOffLinePlayer.new()
	player:setData(data)
	self.players[index] = player	
	player.posIndex = index-1
	
end

 
-- 排名
function pvpData:getOfflineRanking()
	local  ranking = dataManager.playerData:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_RANK)
	local str = ranking
	if(ranking == nil or ranking <= 0)then
		--str =  dataConfig.configs.ConfigConfig[0].pvpOfflineMaxRank.."+"
		str = "未上榜"
		ranking = ranking or 0
	end
	
	return    str ,ranking  --  .." -- "..self:getOfflinePlayerMaxRank()
end	
 
--[[
	local rewardInfo = {
		['id'] = rewardID,
		['count'] = rewardCount,
		['icon'] = "",
		['star'] = 1,
	};
]]--
-- 排名可以获得的奖励
function pvpData:getOfflineRankReward(level)
 
	local t ={}
	
	local size = #dataConfig.configs.PvpOfflineConfig	
	if(level <= 0 or level > dataConfig.configs.PvpOfflineConfig[size].rank )then
		return t
	end
	
	local findIndex = nil
	for i ,v in ipairs (dataConfig.configs.PvpOfflineConfig )	do
		if((level) <=  tonumber (v.rank))then
			findIndex = i
			break
		end
	end 
	if(findIndex)then
		local reward  = dataConfig.configs.PvpOfflineConfig[findIndex]
		for i,v in ipairs 	(reward.rewardType) do
			table.insert(t,dataManager.playerData:getRewardInfo(v, reward.rewardID[i], reward.rewardCount[i]))
		end
	
	end
	return t 
end


function pvpData:getOfflineBatlePower()
	return global.battlePower(enum.PLAN_TYPE.PLAN_TYPE_PVP_OFFLINE_GUARD)
end	
function pvpData:getOfflineAttackBatlePower()
    -- modiy by zhouyou，策划已经舍弃这套整容，改用PVE。PVE肯定有
	--if(PLAN_CONFIG.isShipsPlanEmpty(enum.PLAN_TYPE.PLAN_TYPE_PVE))then
		return global.battlePower(enum.PLAN_TYPE.PLAN_TYPE_PVE)
	--else
	--	return global.battlePower(enum.PLAN_TYPE.PLAN_TYPE_PVP_OFFLINE_ATTACK)
	--end
end	




function pvpData:getOfflineBatleNum()
	
	local num =  dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_PVP_OFFLINE_BATTLE) or 0 	
	return num
end	

function pvpData:getOfflineTimes()
	local num =  dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_PVP_OFFLINE_TIMES) or 0 	
	return num;
end

function pvpData:getOfflineBatleMaxNum()
	return dataConfig.configs.ConfigConfig[0].pvpOfflineFightTimes
end	
 


function pvpData:getOfflineCd()
	
	local vip = dataManager.playerData:getVipLevel()
	local configLevel = dataConfig.configs.ConfigConfig[0].pvpOfflineCDVipLevel or 0
	if(vip >= configLevel )then
		return 0,0
	end	

	local  cd = dataManager.playerData:getTimeAttr(enum.PLAYER_ATTR64.PLAYER_ATTR64_PVP_OFFLINE_COOLDOWN) 
	if(cd ~= nil )then	
		if(type(cd) == "userdata")then
			cd    = cd:GetUInt() 			
		end					
	end	
	cd = cd or 0
	local d = cd  - dataManager.getServerTime()
	if(cd <= 0 or d <= 0)then
		 return 0,0	
	end		
	
	local i,j = math.modf( (d)/dataConfig.configs.ConfigConfig[0].pvpOfflineDiamondCost)
	if(j > 0 )then
		i = i + 1
	end		
    local cost  =  i
	-- dataConfig.configs.ConfigConfig[0].pvpOfflineCD
	return d,cost 			
end	

function pvpData:getOfflineSelfCrops(shipIndex)
	local cardType =	PLAN_CONFIG.getShipCardType(shipIndex, enum.PLAN_TYPE.PLAN_TYPE_PVP_OFFLINE_GUARD)-- 离线PVP进攻配置		
	if cardType > 0 then
				local info = {}		
				local card = cardData.getCardInstance(cardType)
				info.unitID = card.unitID;
				info.starLevel = card.star;				
				info.icon = dataConfig.configs.unitConfig[info.unitID].icon;	
				return 	info		
	end		
	return 	nil
	 
end

 
function pvpData:getOfflineOpenLevel()
	return dataConfig.configs.ConfigConfig[0].pvpOfflineLevelLimit	
end
function pvpData:getOnlineOpenLevel()
	return dataConfig.configs.ConfigConfig[0].pvpOnlineLevelLimit	
end
-------------------------------------------------------------------------------------------------
 

local pvpReplayRecord = class("pvpReplayRecord")

function pvpReplayRecord:ctor()
 
end 	

 
function pvpReplayRecord:setData(data)
	self.id = data['id']	-- 录像id
	self.playerLevel = data['playerLevel'] -- 玩家等级
	self.playerID = data['playerID']-- 玩家id
	
	self.name = data['playerName'] -- 玩家名称
	self.win = data['win']-- 胜利失败
	self.rankChanged = data['rankChanged']--  排名变化
	self.battleTime = data['battleTime'] -- 战斗时间
	self:setbattleTime(data['battleTime'])
	self.Challenger = data['isChallenger']-- 挑战者
end
function pvpReplayRecord:setbattleTime(t)
	if(type(t) == "userdata")then
		self.battleTime  = t:GetUInt()		
	else
		self.battleTime  = t	
	end	
end

function pvpReplayRecord:getId()
	return self.id 
end	

function pvpReplayRecord:getplayerId()
	return self.playerID 
end	

function pvpReplayRecord:getHeadId()
	return 1
end
function pvpReplayRecord:getWin()
	local win = self.win 
	if(win == false)then
		return    "您战败了"
	end
	return  "您获胜了"
end	

function pvpReplayRecord:getChallenger()
	local Challenger = self.Challenger 
	if(Challenger == true)then
		return    "您发起挑战"
	end
	return  "对方发起挑战"
end	

function pvpReplayRecord:canRevenge()
	local Challenger = self.Challenger 
	if(Challenger == true)then
		return    false
	end
	return self.win == false --and self.rankChanged ~= 0
end	


function pvpReplayRecord:getName()
	local name = self.name 
	if(name == nil or name == "")then
		return enum.DEFAULT_PLAYER_NAME;
	end
	return  name
end	

function pvpReplayRecord:getLevel()
	return self.playerLevel 
	 
end	

function pvpReplayRecord:getRankChanged()
	if(self.rankChanged  < 0)then
		return math.abs(self.rankChanged) ,0
	end
	return  self.rankChanged ,180
end	




function pvpReplayRecord:getbattleTime(t)
	local detal = dataManager.getServerTime() -  self.battleTime
	local str = "刚刚"
	if(detal >=  24*60*60)then
		str = "1天以上" 
	elseif(detal >= 60*60)then
		 str = "1小时以上" 
	elseif(detal >= 30*60)then
		  str = "30分钟以上" 
	elseif(detal >= 5*60)then
		   str = "5分钟以上" 
	end	
	return str	
end

---战斗记录
function pvpData:createPvpOfflineReplayRecord(data,index)
	local record = 	pvpReplayRecord.new()
	record:setData(data)
	self.offlineReplayRecord[index] = record	
end

function pvpData:getPvpOfflineRankConfig()
	return dataConfig.configs.PvpOfflineConfig 	
end


 


return pvpData