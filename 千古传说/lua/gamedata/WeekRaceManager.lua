--[[
******周赛管理类*******
	-- by quanhuan
	-- 2015/12/4
]]

local WeekRaceManager = class("WeekRaceManager")

WeekRaceManager.refreshWindow = "WeekRaceManager.refreshWindow"
WeekRaceManager.lastChampionMsg = "WeekRaceManager.lastChampionMsg"

function WeekRaceManager:ctor()
	
	TFDirector:addProto(s2c.GAIN_CHAMPIONS_WAR_INFO_RESPONSE, self, self.raceInfoReceive)

	TFDirector:addProto(s2c.CHAMPIONS_BET_SUCESS, self, self.betReceive)

	TFDirector:addProto(s2c.LAST_CHAMPION, self, self.lastChampionReceive)

	self:restart()
end

function WeekRaceManager:restart()
	self.raceInfo = nil

	self.timeInfo = {}
	for i=1,3 do
		self.timeInfo[i] = {}

		if i == 1 then
			self.timeInfo[i].startTime = ConstantData:getValue( 'Zhengba.Time.Open' )
		else
			self.timeInfo[i].startTime = self.timeInfo[i-1].viewTime
		end

		self.timeInfo[i].yazhuTime = ConstantData:getValue( 'Zhengba.Time.Yazhu'..i )

		self.timeInfo[i].fightTime = self.timeInfo[i].yazhuTime + ConstantData:getValue( 'Zhengba.Time.ZhengbaFight' )

		self.timeInfo[i].viewTime = self.timeInfo[i].fightTime + ConstantData:getValue( 'Zhengba.Time.Zhanshi' )
	end	
	self.timeInfo[3].viewTime = ConstantData:getValue( 'Zhengba.Time.Close' )

	if self.countDownTimer then
		TFDirector:removeTimer(self.countDownTimer)
		self.countDownTimer = nil
	end
	if self.delayTimer then
		TFDirector:removeTimer(self.delayTimer)
		self.delayTimer = nil
	end
-->>>>>>>>>>>>>>>>>>>>>test data	
	-- self.timeInfo = nil
	-- self.timeInfo = {}

	-- local activity 		= string.split("13:00:00",':')
	-- for i=1,3 do
	-- 	self.timeInfo[i] = {}
	-- 	if i == 1 then
	-- 		self.timeInfo[i].startTime = (tonumber(activity[1])*60 + tonumber(activity[2]))*60 + tonumber(activity[3])
	-- 	else
	-- 		self.timeInfo[i].startTime = self.timeInfo[i-1].viewTime
	-- 	end
	-- 	self.timeInfo[i].yazhuTime = self.timeInfo[i].startTime + 10
	-- 	self.timeInfo[i].fightTime = self.timeInfo[i].yazhuTime + 10
	-- 	self.timeInfo[i].viewTime = self.timeInfo[i].fightTime + 10
	-- end
	-- self.timeInfo[1].startTime = 10*3600
	-- self.timeInfo[3].viewTime = 22*3600
-->>>>>>>>>>>>>>>>>>>>>test data end
	-- for k,v in pairs(self.timeInfo) do
	-- 	print('kkkkkkkkkkkkkkkk = ',k)
	-- 	print(FactionManager:getTimeString(v.startTime))
	-- 	print(FactionManager:getTimeString(v.yazhuTime))
	-- 	print(FactionManager:getTimeString(v.fightTime))
	-- 	print(FactionManager:getTimeString(v.viewTime))
	-- end
	-- pp.pp = 1
end

function WeekRaceManager:requestRaceInfo(isOpen)
	-- local weekDay = tonumber(os.date('%w',MainPlayer:getNowtime()))
	-- if weekDay ~= 0 then
	-- 	toastMessage("活动未开始")
	-- 	return
	-- end
	
	if ZhengbaManager:getActivityStatus() ~= 5 then
		-- toastMessage("活动未开始")
		toastMessage(localizable.WeekRaceManager_huodong_weikaishi)
		if not isOpen then
			AlertManager:closeAll()
		end
		return
	end
	self.isOpenHomeLayer = isOpen
	TFDirector:send(c2s.GAIN_CHAMPIONS_WAR_INFO,{})
	showLoading();
end

function WeekRaceManager:raceInfoReceive( event )
	hideLoading();

	if ZhengbaManager:getActivityStatus() ~= 5 then
		-- toastMessage("活动未开始")
		toastMessage(localizable.WeekRaceManager_huodong_weikaishi)
		if not self.isOpenHomeLayer then
			AlertManager:closeAll()
		end
		return 
	end

	local data = event.data
	self.raceInfo = data.infos

	print('raceInfoReceive--data = ',data)
	-- pp.pp = 1

	if self.raceInfo == nil and self.isOpenHomeLayer then
		-- toastMessage('争霸赛无参赛选手')
		toastMessage(localizable.WeekRaceManager_no_player)
		return
	end

	self:checkMembers()

	self:setStrategyInfo()

	if self.isOpenHomeLayer then
		self.isOpenHomeLayer = nil
		self:openHomeLayer()
	else
		TFDirector:dispatchGlobalEventWith(WeekRaceManager.refreshWindow,{})
	end
end

function WeekRaceManager:getCutDownByState( round, state )
	local currDate = os.date("*t", MainPlayer:getNowtime())
	local currSecond = (currDate.hour*60+currDate.min)*60+currDate.sec
	local timeInfo = self.timeInfo[round]

	local second = 0

	if state == 1 then
		second = timeInfo.yazhuTime - currSecond
	elseif state == 2 then
		second = timeInfo.fightTime - currSecond
	elseif state == 3 then
		second = timeInfo.viewTime - currSecond
	end
	return second
end
function WeekRaceManager:getCurrTimeState(round)
	--[[
		1.押注时间段
		2.战斗时间段
		3.战报预览时间段
	]]
	local currDate = os.date("*t", MainPlayer:getNowtime())
	local currSecond = (currDate.hour*60+currDate.min)*60+currDate.sec
	local timeInfo = self.timeInfo[round]

	if currSecond >= timeInfo.startTime and currSecond < timeInfo.yazhuTime then
		return 1
	elseif currSecond >= timeInfo.yazhuTime and currSecond < timeInfo.fightTime then
		return 2
	elseif currSecond >= timeInfo.fightTime and currSecond < timeInfo.viewTime then
		return 3
	end
	return 10086
end

function WeekRaceManager:getCurrRound()
	-- local round = 1
	-- if self.raceInfo then
	-- 	for k,v in pairs(self.raceInfo) do
	-- 		if v.round > round then
	-- 			round = v.round
	-- 		end
	-- 	end
	-- end
	local currDate = os.date("*t", MainPlayer:getNowtime())
	local currSecond = (currDate.hour*60+currDate.min)*60+currDate.sec
	if currSecond >= self.timeInfo[1].startTime and currSecond < self.timeInfo[2].startTime then
		return 1
	elseif currSecond >= self.timeInfo[2].startTime and currSecond < self.timeInfo[3].startTime then
		return 2
	elseif currSecond >= self.timeInfo[3].startTime then
		return 3
	end
end

function WeekRaceManager:getRaceInfoByRound( round )
	local raceInfo = {}
	if self.raceInfo then
		for k,v in pairs(self.raceInfo) do
			if v.round == round then
				local idx = #raceInfo
				raceInfo[idx+1] = v
			end
		end
	end
	return raceInfo
end

function WeekRaceManager:requestBet(roundId,index,coin,betPlayerId)
	showLoading();
	self.betMsg = {
		roundId,
		index,
		coin,
		betPlayerId
	}
	print("self.betMsg = ",self.betMsg)
	TFDirector:send(c2s.CHAMPIONS_BET,self.betMsg)
end
function WeekRaceManager:betReceive( event )

	hideLoading();

	for i=1,#self.raceInfo do
		if self.raceInfo[i].round == self.betMsg[1] and self.raceInfo[i].index == self.betMsg[2] then
			self.raceInfo[i].betPlayerId = self.betMsg[4]
			self.raceInfo[i].coin = self.betMsg[3]
		end
	end
	print("self.betMsg = ",self.betMsg)
	print("self.raceInfo = ",self.raceInfo)
	TFDirector:dispatchGlobalEventWith(WeekRaceManager.refreshWindow,{})
end

function WeekRaceManager:openHomeLayer()
	--test data
-- 	self.raceInfo = {}
-- 	local idIdx = 1
-- 	for i=1,4 do
-- 		--[[
-- required int32 round = 1;//轮次
-- 	required int32 index = 2;//索引
-- 	required int32 atkPlayerId = 3;//攻击玩家编号
-- 	optional int32 defPlayerId = 4;//防守玩家编号
-- 	required int32 winPlayerId = 5;//胜利的玩家
-- 	required int32 replayId = 6;// 录像编号
-- 	required string atkPlayerName = 7;//攻击玩家名
-- 	optional string defPlayerName = 8;//防守玩家名
-- 	optional int32 betPlayerId = 9;//押注的玩家编号
-- 	optional int32 coin = 10;//押注金额
-- 	required int32 atkProfession = 11;//攻击玩家职业
-- 	optional int32 defProfession = 12;//防守玩家职业
-- 	required int32 atkPower = 13;//攻击玩家战斗力
-- 	optional int32 defPower = 14;//防守玩家战斗力
-- 		]]
-- 		self.raceInfo[i] = {}
-- 		self.raceInfo[i].round = 1
-- 		self.raceInfo[i].index = i
-- 		self.raceInfo[i].atkPlayerId = idIdx
-- 		self.raceInfo[i].defPlayerId = idIdx + 1
-- 		self.raceInfo[i].replayId = i
-- 		self.raceInfo[i].winPlayerId = idIdx + 1
-- 		self.raceInfo[i].atkPlayerName = '攻击玩家名'..i
-- 		self.raceInfo[i].defPlayerName = '防守玩家名'..i
-- 		self.raceInfo[i].atkProfession = 77
-- 		self.raceInfo[i].defProfession = 78

-- 		idIdx = idIdx + 2
-- 	end

	--test data end
	AlertManager:addLayerToQueueAndCacheByFile("lua.logic.weekrace.WeekRaceHomeLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
	AlertManager:show()

end

function WeekRaceManager:isJoin(round)
	if self.raceInfo and self.raceInfo[round] then
		local selfId = MainPlayer:getPlayerId()
		for k,v in pairs(self.raceInfo) do
			if v.round == round and (v.atkPlayerId == selfId or v.defPlayerId == selfId) then
				return true
			end
		end
	end
	return false
end

function WeekRaceManager:getRecordList()

	local checkRound = self:getCurrRound()
	local timeState = self:getCurrTimeState(checkRound)
	if timeState == 10086 and checkRound > 1 then
		checkRound = checkRound - 1
		timeState = self:getCurrTimeState(checkRound)
	end

	local recordList = {}
	if self.raceInfo then
		for k,v in pairs(self.raceInfo) do
			if v.round < checkRound then
				local idx = #recordList
				recordList[idx+1] = v
			elseif (v.round == checkRound and timeState == 3) and (v.winPlayerId and v.winPlayerId ~= 0) then				
				local idx = #recordList
				recordList[idx+1] = v				
			end
		end		
	end
	return recordList
end

function WeekRaceManager:setStrategyInfo()
	-- body
	local strategy = nil
	if self.raceInfo then
		for k,v in pairs(self.raceInfo) do
			if v.atkPlayerId == MainPlayer:getPlayerId() then
				strategy = v.atkFormation
			elseif v.defPlayerId == MainPlayer:getPlayerId() then
				strategy = v.defFormation
			end
		end		
	end
	if strategy then
		ZhengbaManager:qunHaoDefFormationSet( EnumFightStrategyType.StrategyType_CHAMPIONS_ATK, strategy )
	end
end

function WeekRaceManager:checkRaceOpened()
	local currDate = os.date("*t", MainPlayer:getNowtime())
	local currSecond = (currDate.hour*60+currDate.min)*60+currDate.sec
	if self.timeInfo[1].startTime > currSecond then
		return false
	end
	return true
end

function WeekRaceManager:checkRaceClosed()
	local currDate = os.date("*t", MainPlayer:getNowtime())
	local currSecond = (currDate.hour*60+currDate.min)*60+currDate.sec
	local closeSecond = ConstantData:getValue( 'Zhengba.Time.Close' )
	if currSecond >= closeSecond then
		return true
	end
	return false
end

function WeekRaceManager:checkEnableYazhu( round )
	if self.raceInfo then
		for k,v in pairs(self.raceInfo) do
			if v.round == round and v.betPlayerId then
				return false
			end
		end		
	end
	return true
end
function WeekRaceManager:getStartTimeStrByRound( round )
	local str = ''
	if self.timeInfo and self.timeInfo[round] then
		local times = self.timeInfo[round].startTime
		if times <= 0 then
			str = "00:00"
		else
			local hour = math.floor(times/3600)
			local min = math.floor((times - hour*3600)/60)
			str = string.format("%02d",hour)..":"..string.format("%02d",min)
		end
	end
	return str
end

function WeekRaceManager:checkMembers()

	local function copyTab(st)
	    local tab = {}
	    for k, v in pairs(st or {}) do
	        if type(v) ~= "table" then
	            tab[k] = v
	        else
	            tab[k] = copyTab(v)
	        end
	    end
	    return tab
	end
	local function getRound()
		local currDate = os.date("*t", MainPlayer:getNowtime())
		local currSecond = (currDate.hour*60+currDate.min)*60+currDate.sec
		for i=1,#self.timeInfo do
			if currSecond < self.timeInfo[i].viewTime then
				return i
			end
		end
		return 0
	end
	local function checkInfoLen()
		local len = 0
		for k,v in pairs(self.raceInfo) do
			if v.round == 1 then
				len = len + 1
			end
		end
		return len
	end
	if self.raceInfo then
		local infoLen = checkInfoLen()
		if infoLen == 1 then			
			local currRound = getRound()
			for i=1,3 do				
				local maxLen = #self.raceInfo
				if maxLen < currRound then
					local idx = maxLen + 1					
					self.raceInfo[idx] = copyTab(self.raceInfo[1])
					self.raceInfo[idx].round = idx
					self.raceInfo[idx].winPlayerId = self.raceInfo[idx].atkPlayerId
				end
			end	
			self.raceInfo[1].winPlayerId = self.raceInfo[1].atkPlayerId
		elseif infoLen == 2 then
			local currRound = getRound()
			if currRound == 1 then
				self.raceInfo[2].index = 4
			elseif currRound == 3 then	
				self.raceInfo[4] = copyTab(self.raceInfo[3])
				if self.raceInfo[4].winPlayerId == self.raceInfo[4].atkPlayerId then
					self.raceInfo[4].round = 3
					self.raceInfo[4].defPlayerId = nil
					self.raceInfo[4].replayId = nil
					self.raceInfo[4].defPlayerName = nil
					self.raceInfo[4].betPlayerId = nil
					self.raceInfo[4].coin = nil
					self.raceInfo[4].defProfession = nil
					self.raceInfo[4].defPower = nil
					self.raceInfo[4].defFormation = nil
				else
					self.raceInfo[4].round = 3
					self.raceInfo[4].atkPlayerId = self.raceInfo[3].defPlayerId
					self.raceInfo[4].atkPlayerName = self.raceInfo[3].defPlayerName
					self.raceInfo[4].atkProfession = self.raceInfo[3].defProfession
					self.raceInfo[4].atkPower = self.raceInfo[3].defPower
					self.raceInfo[4].atkFormation = self.raceInfo[3].defFormation

					self.raceInfo[4].defPlayerId = nil
					self.raceInfo[4].replayId = nil
					self.raceInfo[4].defPlayerName = nil
					self.raceInfo[4].betPlayerId = nil
					self.raceInfo[4].coin = nil
					self.raceInfo[4].defProfession = nil
					self.raceInfo[4].defPower = nil
					self.raceInfo[4].defFormation = nil
				end
			end
		end
	end
end

function WeekRaceManager:requestLastChampion()
	TFDirector:send(c2s.GAIN_LAST_CHAMPION,{})
	showLoading();
end

function WeekRaceManager:lastChampionReceive( event )
	hideLoading();
	self.lastChampion = event.data.id

	TFDirector:dispatchGlobalEventWith(WeekRaceManager.lastChampionMsg,{event.data})
end

function WeekRaceManager:requestPlayVideo( replayId )
	print('requestPlayVideoreplayId = ',replayId)
	TFDirector:send(c2s.WATCH_SERVER_BATTLE_REPLAY,{replayId})
	showLoading();
end

function WeekRaceManager:startPlayNotice()
	
	-- local strBuff = {
	-- 	'武林大会八强赛即将开始，请参加八强赛的选手进行布阵准备，押注活动也将同步进行！',
	-- 	'武林大会半决赛即将开始，请参加半决赛的选手进行布阵准备，押注活动也将同步进行！',
	-- 	'武林大会总决赛即将开始，请参加总决赛的选手进行布阵准备，押注活动也将同步进行！'
	-- }	

	local strBuff = localizable.WeekRaceManager_notify

	local function getCurrStr()
		local currDate = os.date("*t", MainPlayer:getNowtime())
		local currSecond = (currDate.hour*60+currDate.min)*60+currDate.sec
		-- print('currSecond = ',currDate)
		local currStr = nil
		local endTimer = nil
		for i=1,3 do
			-- print('currSecond = ',currSecond)
			-- print('self.timeInfo[i].yazhuTime = ',self.timeInfo[i].yazhuTime)
			if currSecond < self.timeInfo[i].yazhuTime and currSecond > self.timeInfo[i].startTime then
				endTimer = self.timeInfo[i].yazhuTime
				currStr = strBuff[i]
				
				local strFormat =[[<p style="text-align:left margin:5px"><font color="#ffffff" fontSize="26">%s</font></p>]]
				local strFormatChat =[[<p style="text-align:left margin:5px"><font color="#000000" fontSize="26">%s</font></p>]]
				local notifyStr = string.format(strFormat, currStr)
				local notifyStrChat = string.format(strFormatChat, currStr)
				return notifyStr,notifyStrChat,endTimer
			end
		end
	end
	
	local function startPlay()
		local str,strChat,endt = getCurrStr()
		if str then	
			if self.countDownTimer then
				TFDirector:removeTimer(self.countDownTimer)
				self.countDownTimer = nil	
			end		
			self.countDownTimer = TFDirector:addTimer(600000, -1, nil, function () 
				local currDate = os.date("*t", MainPlayer:getNowtime())
				local currSecond = (currDate.hour*60+currDate.min)*60+currDate.sec
				if currSecond < (endt-60) then
					NotifyManager:sendMsgToChat(strChat)
					NotifyManager:addMessage(str, 1, 1)
				else
					TFDirector:removeTimer(self.countDownTimer)
	        		self.countDownTimer = nil
				end
			end)
		end
	end

	if self.countDownTimer then
		TFDirector:removeTimer(self.countDownTimer)
		self.countDownTimer = nil
		if self.delayTimer then
			TFDirector:removeTimer(self.delayTimer)
			self.delayTimer = nil
		end
		if self.raceInfo then
			startPlay()
		end
	else
		if self.delayTimer then
			TFDirector:removeTimer(self.delayTimer)
			self.delayTimer = nil
		end
		self:requestRaceInfo(false)
		self.delayTimer = TFDirector:addTimer(10000, -1, nil, function () 
				local str,strChat,endt = getCurrStr()
				if self.raceInfo and str then					
					local currDate = os.date("*t", MainPlayer:getNowtime())
					local currSecond = (currDate.hour*60+currDate.min)*60+currDate.sec
					print('currSecond = ',currSecond)
					print('endt-200000 = ',endt-60)
					print('endt = ',endt)
					if currSecond < (endt-60) then
						NotifyManager:sendMsgToChat(strChat)
						NotifyManager:addMessage(str, 1, 1)
						startPlay()	
					end								
				end
				TFDirector:removeTimer(self.delayTimer)
				self.delayTimer = nil
			end)
	end
end

return WeekRaceManager:new();