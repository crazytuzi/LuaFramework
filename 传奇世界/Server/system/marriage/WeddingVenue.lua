--WeddingVenue.lua
--/*-----------------------------------------------------------------
 --* Module:  WeddingVenue.lua
 --* Author:  goddard
 --* Modified: 2016年9月20日
 --* Purpose: 婚礼会场信息
 -------------------------------------------------------------------*/
require ("system.marriage.VenueMemberInfo") 

WeddingVenue = class()

function WeddingVenue:__init(info, wedding, type)
	self._info = info
	self._wedding = wedding
	self._weddingVenueID = nil
	self._type = type
	self._playerCount = 0
	self._playerInfoMapBySID = {}
	self._kickOutPlayer = {}
	self._bonusInfo = {}
	self._romanticPetalsInfo = {}
	self._romanticPetalsInfo.status = AmbienceStatus.unUse
	self._musicTeacherInfo = {}
	self._musicTeacherInfo.status = AmbienceStatus.unUse

	self._hydrangeaInfo = {}
	self._hydrangeaInfo.status = PlayStatus.unUse
	self._drinkInfo = {}
	self._drinkInfo.status = PlayStatus.unUse
	self._drinkInfo.nextRankTime = 0

	self._broadcastFiniCount = 0
	self._broadcastFiniFlag = {}
end

function WeddingVenue:getPlayerCount()
	return self._playerCount
end

function WeddingVenue:setVenueID(id)
	self._weddingVenueID = id
	local scene = g_sceneMgr:getPublicScene(self._weddingVenueID)
	if scene then
		scene:setAllSafe(1)
		scene:setAllMonsterInvisible(0)
	end
	g_marriageMgr:addVenueMapMap(self._weddingVenueID, self)
end

--夫妻进入会场
function WeddingVenue:enter(player)
	player:setLastMapID(player:getMapID())
	player:setLastPosX(player:getPosition().x)
	player:setLastPosY(player:getPosition().y)
	g_marriageMgr:transmitTo(player, self._weddingVenueID, WEDDING_VENUE_INIT_POINT)
end

function WeddingVenue:finish()
	if self._weddingVenueID then
		g_marriageMgr:addWeddingAvailableVenue(self._weddingVenueID)
	end
	g_marriageMgr:delVenueMapMap(self._weddingVenueID)
	self:stopPlay()
	self:kickOutAllPlayer()
	self._wedding:weddingVenueFini()
end

--用户通过请柬进入会场
function WeddingVenue:invitationEnter(player)
	if self._playerCount > MAX_VENUE_PLAYERCOUNT then
		return false, MarriageErrorCode.WeddingVenueMaxPlayer
	end
	if MIN_VENUE_PLAYERLEVEL > player:getLevel() then
		return false, MarriageErrorCode.WeddingVenueLevelNotEnough
	end
	if self._kickOutPlayer[player:getSerialID()] then
		return false, MarriageErrorCode.WeddingVenueKickOut
	end
	player:setLastMapID(player:getMapID())
	player:setLastPosX(player:getPosition().x)
	player:setLastPosY(player:getPosition().y)
	g_marriageMgr:transmitTo(player, self._weddingVenueID, WEDDING_VENUE_INIT_POINT)
	return true
end

function WeddingVenue:addPlayer(player, member)
	self._playerInfoMapBySID[player:getSerialID()] = member
	g_marriageMgr:addVenueMap(player:getSerialID(), self)
	self._playerCount = self._playerCount + 1
end

function WeddingVenue:releasePlayer(player)
	self:releasePlayerBySID(player:getSerialID())
end

function WeddingVenue:releasePlayerBySID(roleSID)
	self._playerInfoMapBySID[roleSID] = nil
	g_marriageMgr:delVenueMap(roleSID)
	self._playerCount = self._playerCount - 1
end

function WeddingVenue:onPlayerDied(player, killerID)
	local member = self._playerInfoMapBySID[player:getSerialID()]
	if member then
		player:specialDeadSinging(500)
		player:setReliveMapID(player:getMapID())
		local pos = player:getPosition()
		player:setReliveX(pos.x)
		player:setReliveY(pos.y)
	end
	if player:getSerialID() == self._hydrangeaInfo.ownerSID then
		local killer = g_entityMgr:getPlayer(killerID)
		if killer then
			self:newHydrangeaOwner(killer:getSerialID())
		end
	end
end

function WeddingVenue:onPlayerOffLine(player)
	local member = self._playerInfoMapBySID[player:getSerialID()]
	if member then
		self:releasePlayer(player)
	end
end

function WeddingVenue:onSwitchScene(player, mapID, lastMapID)
	if lastMapID == self._weddingVenueID and mapID ~= self._weddingVenueID then	--出婚礼会场
		if self._info:getMaleSID() ~= player:getSerialID() and self._info:getFemaleSID() ~= player:getSerialID() then
			local member = self._playerInfoMapBySID[player:getSerialID()]
			if member then
				self:releasePlayer(player)
				self:playerOutterAfter(player)
			end
		end
	elseif mapID == self._weddingVenueID and lastMapID ~= self._weddingVenueID then					--进婚礼会场
		self:playerInnerAfter(player)
	end
end

function WeddingVenue:getAmbienceInfo()
	local ambienceInfo = {}
	local ambienceItem = {}

	local romanticPetalsItem = {}
	romanticPetalsItem.ambience = AmbienceType.RomanticPetals
	local musicTeacherItem = {}
	musicTeacherItem.ambience = AmbienceType.MusicTeacher

	if self._romanticPetalsInfo.status == AmbienceStatus.unUse then
		romanticPetalsItem.status = 1
	else
		romanticPetalsItem.status = 2
		romanticPetalsItem.endTime = self._romanticPetalsInfo.endTime
		romanticPetalsItem.endCoolingTime = self._romanticPetalsInfo.endCoolingTime
	end

	if self._musicTeacherInfo.status == AmbienceStatus.unUse then
		musicTeacherItem.status = 1
	else
		musicTeacherItem.status = 2
		musicTeacherItem.endTime = self._musicTeacherInfo.endTime
		musicTeacherItem.endCoolingTime = self._musicTeacherInfo.endCoolingTime
	end

	table.insert(ambienceItem, romanticPetalsItem)
	table.insert(ambienceItem, musicTeacherItem)
	ambienceInfo.ambienceItem = ambienceItem
	return ambienceInfo
end

function WeddingVenue:getPlayInfo()
	local playInfo = {}
	local playItem = {}

	local hydrangeaItem = {}
	hydrangeaItem.play = PlayType.Hydrangea
	local drinkItem = {}
	drinkItem.play = PlayType.Drink

	if self._hydrangeaInfo.status == PlayStatus.unUse then
		hydrangeaItem.status = 1
	else
		hydrangeaItem.status = 2
		hydrangeaItem.endTime = self._hydrangeaInfo.endTime
		hydrangeaItem.endCoolingTime = self._hydrangeaInfo.endCoolingTime
		hydrangeaItem.ownerSID = self._hydrangeaInfo.ownerSID
	end

	if self._drinkInfo.status == PlayStatus.unUse then
		drinkItem.status = 1
	else
		drinkItem.status = 2
		drinkItem.endTime = self._drinkInfo.endTime
		drinkItem.endCoolingTime = self._drinkInfo.endCoolingTime
	end

	table.insert(playItem, hydrangeaItem)
	table.insert(playItem, drinkItem)
	playInfo.playItem = playItem
	return playInfo
end

function WeddingVenue:pushVenueInfo(player)
	local ret = {}
	ret.ambienceInfo = self:getAmbienceInfo()
	ret.playInfo = self:getPlayInfo()
	ret.maleSID = self._info:getMaleSID()
	ret.femaleSID = self._info:getFemaleSID()
	ret.marriageID = self._info:getMarriageID()
	fireProtoMessage(player:getID(), MARRIAGE_SC_WEDDING_VENUE_INFO, 'MarriageSCWeddingVenueInfo', ret)
end

function WeddingVenue:reqWeddingGuestList(player)
	local lists = {}
	for roleSID, member in pairs(self._playerInfoMapBySID) do
		local player = g_entityMgr:getPlayerBySID(roleSID)
		if not player then
			return
		end
		local info = {}
		info.roleName = player:getName()
		info.sex = player:getSex()
		info.school = player:getSchool()
		info.level = player:getLevel()
		info.bonus1 = member:getBonusBit(MarriageBonusBit.GreetingCardBonusBit)
		info.bonus2 = member:getBonusBit(MarriageBonusBit.CelebrateWineBonusBit)
		info.bonus3 = member:getBonusBit(MarriageBonusBit.WeddingRedBonusBit)
		info.reoleSID = roleSID
		table.insert(lists, info)
	end
--	if table.size(lists) > 0 then
	fireProtoMessage(player:getID(), MARRIAGE_SC_WEDDING_GUEST_LIST, 'MarriageSCWeddingGuestList', { infoList = lists, })
--	end
	return true
end

function WeddingVenue:reqWeddingSendBonus(player, bonus)
	local member = self._playerInfoMapBySID[player:getSerialID()]
	if not member then
		return false, MarriageErrorCode.WeddingVenueWeddingSendBonusNotIn
	end
	local ingot = nil
	local bonusBit = nil
	if MarriageBonusType.GreetingCardBonus == bonus then
		ingot = GREETING_CARD_BONUS
		bonusBit = MarriageBonusBit.GreetingCardBonusBit
	elseif MarriageBonusType.CelebrateWineBonus == bonus then
		ingot = CELEBRATE_WINE_BONUS
		bonusBit = MarriageBonusBit.CelebrateWineBonusBit
	elseif MarriageBonusType.WeddingRedBonus == bonus then
		ingot = WEDDING_RED
		bonusBit = MarriageBonusBit.WeddingRedBonusBit
	else
		return false, MarriageErrorCode.WeddingVenueWeddingSendBonusType
	end

	if 1 == member:getBonusBit(bonusBit) then
		return false, MarriageErrorCode.WeddingVenueWeddingSendBonusSended
	end

	if not isIngotEnough(player, ingot) then
		return false, MarriageErrorCode.WeddingVenueWeddingSendBonusNotEnough
	end

	local context = { ingot = ingot, bonus = bonus, bonusBit = bonusBit, marriageID = self._info:getMarriageID(), sendName = player:getName()}
	local ret = g_tPayMgr:TPayScriptUseMoney(player, ingot, 236, "", 0, 0, "MarriageManager.DoYuanBaoSendBonus", serialize(context)) 
	if ret ~= 0 then
		print("WeddingVenue:reqWeddingSendBonus: g_tPayMgr:TPayScriptUseMoney return ~0, playerSerialID:", player:getSerialID(), " bonustype: ", bonus, " ingot:", ingot)
		return false, MarriageErrorCode.WeddingVenueWeddingSendBonusPay
	end
	return true
end

function WeddingVenue:paySendBonusCallback(roleSID, callBackContext)
	local context = unserialize(callBackContext)
	local member = self._playerInfoMapBySID[roleSID]
	if member then
		if 1 == member:getBonusBit(context.bonusBit) then
			print("WeddingVenue:paySendBonusCallback: BonusBit be setted, playerSerialID:", roleSID, " bonustype: ", context.bonus, " ingot:", context.ingot)
			return TPAY_FAILED, MarriageErrorCode.WeddingVenueWeddingSendBonusSended
		else
			member:setBonusBit(context.bonusBit)
			self._bonusInfo[roleSID] = member:getBonus()
		end
	else
		local tmp = VenueMemberInfo(self._info, self._wedding, self, roleSID)
		local bonusInfo = self._bonusInfo[roleSID]
		if bonusInfo then
			tmp:setBonus(bonusInfo)
		end
		if 1 == tmp:getBonusBit(context.bonusBit) then
			print("WeddingVenue:paySendBonusCallback: BonusBit be setted, playerSerialID:", roleSID, " bonustype: ", context.bonus, " ingot:", context.ingot)
			return TPAY_FAILED, MarriageErrorCode.WeddingVenueWeddingSendBonusSended
		end
		tmp:setBonusBit(context.bonusBit)
		self._bonusInfo[roleSID] = tmp:getBonus()
	end

	print("WeddingVenue:paySendBonusCallback Success: playerSerialID:", roleSID, " ingot:", context.ingot)
	self._info:addBonusTotal(context.ingot)
	self._info:saveData()
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		local ret = {}
		ret.bonus = context.bonus
		fireProtoMessage(player:getID(), MARRIAGE_SC_WEDDING_SEND_BONUS_SUCC, 'MarriageSCWeddingSendBonusSucc', ret)
	end
	local sendName = context.sendName
	local bonusName = ""
	if context.bonus == MarriageBonusType.GreetingCardBonus then
		bonusName = "祝福贺卡"
	elseif context.bonus == MarriageBonusType.CelebrateWineBonus then
		bonusName = "庆贺美酒"
	else
		bonusName = "新婚红包"
	end
	g_marriageMgr:broadCastScene2Client(self._weddingVenueID, 13140, 1, 4, {sendName, self._info:getMaleName(), self._info:getFemaleName(), bonusName})
	return TPAY_SUCESS
end

function WeddingVenue:reqWeddingKickout(player, roleSID)
	local member = self._playerInfoMapBySID[player:getSerialID()]
	if not member then
		return false, MarriageErrorCode.WeddingVenueWeddingKickoutNotIn
	end
	self._kickOutPlayer[roleSID] = true
	self:notifyKickout(player, roleSID)
	self:kickOutPlayer(roleSID)
	return true
end

function WeddingVenue:notifyKickout(player, roleSID)
	local ret = {}
	ret.roleSID = roleSID
	local kickOuter = g_entityMgr:getPlayerBySID(roleSID)
	if kickOuter then
		ret.roleName = kickOuter:getName()
	end
	local male = self._info:getMale()
	if male then
		fireProtoMessage(male:getID(), MARRIAGE_SC_WEDDING_KICKOUT, 'MarriageSCWeddingKickOut', ret)
	end
	local female = self._info:getFemale()
	if female then
		fireProtoMessage(female:getID(), MARRIAGE_SC_WEDDING_KICKOUT, 'MarriageSCWeddingKickOut', ret)
	end

	local kicker =  g_entityMgr:getPlayerBySID(roleSID)
	if kicker then
		fireProtoMessage(kicker:getID(), MARRIAGE_SC_WEDDING_KICKOUT, 'MarriageSCWeddingKickOut', ret)
	end
end

function WeddingVenue:reqWeddingAmbience(player, ambience)
	if ambience == AmbienceType.RomanticPetals then
		if self._romanticPetalsInfo.status == AmbienceStatus.unUse then
			local now = os.time()
			self._romanticPetalsInfo.status = AmbienceStatus.using
			self._romanticPetalsInfo.startTime = now
			self._romanticPetalsInfo.endTime = now + RomanticPetalsContinue
			self._romanticPetalsInfo.endCoolingTime = now + RomanticPetalsCooling
			self:broadCastInfo(MARRIAGE_SC_WEDDING_AMBIENCE_SUCC, "MarriageSCWeddingAmbienceSucc", {ambience=ambience, startTime = self._romanticPetalsInfo.startTime, endTime = self._romanticPetalsInfo.endTime})
		end
	elseif ambience == AmbienceType.MusicTeacher then
		if self._musicTeacherInfo.status == AmbienceStatus.unUse then
			local now = os.time()
			self._musicTeacherInfo.status = AmbienceStatus.using
			self._musicTeacherInfo.startTime = now
			self._musicTeacherInfo.endTime = now + MusicTeacherContinue
			self._musicTeacherInfo.endCoolingTime = now + MusicTeacherCooling
			self:broadCastInfo(MARRIAGE_SC_WEDDING_AMBIENCE_SUCC, "MarriageSCWeddingAmbienceSucc", {ambience=ambience, startTime = self._musicTeacherInfo.startTime, endTime = self._musicTeacherInfo.endTime})
		end
	end
	return true
end

function WeddingVenue:broadCastInfo(eventID, protoName, ret)
	local scene = g_sceneMgr:getPublicScene(self._weddingVenueID)
	if scene then
		boardSceneProtoMessage(scene:getID(), eventID, protoName, ret)
	end
end

function WeddingVenue:update(time, restTime)
	if self._broadcastFiniCount < #BROADCAST_FINI_TIME then
		local nextBroadCount = self._broadcastFiniCount + 1
		if restTime >= BROADCAST_FINI_TIME[nextBroadCount] and not self._broadcastFiniFlag[nextBroadCount] then			
			self._broadcastFiniCount = nextBroadCount
			self._broadcastFiniFlag[nextBroadCount] = true
			g_marriageMgr:broadCastScene2Client(self._weddingVenueID, 13140, 5, 1, {BROADCAST_FINI_TIME[nextBroadCount] / 60})
		end
	end
	if self._romanticPetalsInfo.status == AmbienceStatus.using then
		if time >= self._romanticPetalsInfo.endTime then
			self._romanticPetalsInfo.status = AmbienceStatus.cooling
			self._romanticPetalsInfo.startTime = now
		end
	elseif self._romanticPetalsInfo.status == AmbienceStatus.cooling then
		if time >= self._romanticPetalsInfo.endCoolingTime then
			self._romanticPetalsInfo.status = AmbienceStatus.unUse
		end
	end

	if self._musicTeacherInfo.status == AmbienceStatus.using then
		if time >= self._musicTeacherInfo.endTime then
			self._musicTeacherInfo.status = AmbienceStatus.cooling
			self._musicTeacherInfo.startTime = now
		end
	elseif self._musicTeacherInfo.status == AmbienceStatus.cooling then
		if time >= self._musicTeacherInfo.endCoolingTime then
			self._musicTeacherInfo.status = AmbienceStatus.unUse
		end
	end
	self:updateHydrangea(time)
	self:updateDrink(time)
end

function WeddingVenue:reqWeddingVenueInfo(player)
	self:pushVenueInfo(player)
end

function WeddingVenue:checkPlayCanOpen(play)
	if play == PlayType.Hydrangea then
		if self._hydrangeaInfo.status ~= PlayStatus.unUse or self._drinkInfo.status == PlayStatus.using then
			return false
		end
	elseif play == PlayType.Drink then
		if self._drinkInfo.status ~= PlayStatus.unUse or self._hydrangeaInfo.status == PlayStatus.using then
			return false
		end
	end
	return false
end

function WeddingVenue:reqWeddingPlay(player, play)
	if not self:checkPlayCanOpen(play) then
		return false, MarriageErrorCode.WeddingVenuePlayStatus
	end
	if 0 == self:getPlayerCount() then
		return false, MarriageErrorCode.WeddingVenuePlayNoPlayer
	end
	local playName = ""
	local startTime = nil
	local endTime = nil
	local endCoolingTime = nil
	if play == PlayType.Hydrangea then
		local now = os.time()
		self._hydrangeaInfo.status = PlayStatus.using
		self._hydrangeaInfo.startTime = now
		self._hydrangeaInfo.endTime = now + HydrangeaContinue
		self._hydrangeaInfo.endCoolingTime = now + HydrangeaCooling
		playName = "抢绣球"
		startTime = self._hydrangeaInfo.startTime
		endTime = self._hydrangeaInfo.endTime
		endCoolingTime = self._hydrangeaInfo.endCoolingTime
	elseif play == PlayType.Drink then
		local now = os.time()
		self._drinkInfo.status = PlayStatus.using
		self._drinkInfo.startTime = now
		self._drinkInfo.endTime = now + DrinkContinue
		self._drinkInfo.endCoolingTime = now + DrinkCooling
		self._drinkInfo.userInfo = {}
		playName = "拼酒"
		startTime = self._drinkInfo.startTime
		endTime = self._drinkInfo.endTime
		endCoolingTime = self._drinkInfo.endCoolingTime
	end
	g_marriageMgr:broadCastScene2Client(self._weddingVenueID, 13140, 4, 1, {playName})
	self:broadCastInfo(MARRIAGE_SC_WEDDING_PLAY_SUCC, "MarriageSCWeddingPlaySucc", {play = play, startTime = startTime, endTime = endTime, endCoolingTime = endCoolingTime})
	self:startPlay(play)
	return true
end

function WeddingVenue:randomHydrangea()
	if 0 == self:getPlayerCount() then
		return false
	end
	local index = math.random(1, self:getPlayerCount())
	local i = 1
	local sid = nil
	for SID, _ in pairs(self._playerInfoMapBySID) do
		if index == i then
			sid = SID
			break
		end
		i = i + 1
	end
	if not sid then
		return false
	end
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then
		return
	end
	self:newHydrangeaOwner(sid)
	return true
end

function WeddingVenue:newHydrangeaOwner(sid)
	self._hydrangeaInfo.ownerSID = sid
	self._hydrangeaInfo.ownerStartTime = os.time()
	self:broadCastInfo(MARRIAGE_SC_WEDDING_HYDRANGEA_RANDOM, "MarriageSCWeddingHydrangeaRandom", {SID = sid})
end

function WeddingVenue:startPlay(play)
	if play == PlayType.Hydrangea then
		if not self:randomHydrangea() then
			print("WeddingVenue:randomHydrangea failed")
		end
		local scene = g_sceneMgr:getPublicScene(self._weddingVenueID)
		if scene then
			scene:setAllSafe(0)
		end
	elseif play == PlayType.Drink then
		self:clearAllMemberWineItem()
		self:setAllMonsterInvisible(1)
		for _, member in pairs(self._playerInfoMapBySID) do
			member:startDrink()
		end
	end
end

function WeddingVenue:finiHydrangea()
	local player = g_entityMgr:getPlayerBySID(self._hydrangeaInfo.ownerSID)
	if not player then
		return
	end
	g_marriageMgr:broadCastScene2Client(self._weddingVenueID, 13140, 2, 2, {player:getName(), self._info:getFemaleName()})
	self:stopHydrangea()
end

function WeddingVenue:stopHydrangea()
	self._hydrangeaInfo.status = PlayStatus.cooling
	self._hydrangeaInfo.ownerSID = nil
	self._hydrangeaInfo.ownerStartTime = nil
	local scene = g_sceneMgr:getPublicScene(self._weddingVenueID)
	if scene then
		scene:setAllSafe(1)
	end
	self:broadCastInfo(MARRIAGE_SC_WEDDING_PLAY_FINI, "MarriageSCWeddingPlayFini", {play = PlayType.Hydrangea})
end

function WeddingVenue:updateHydrangea(time)	--抢绣球活动
	if self._hydrangeaInfo.status == PlayStatus.using then
		if time >= self._hydrangeaInfo.endTime or (time - self._hydrangeaInfo.ownerStartTime) >= HydrangeaContinueWin then
			self:finiHydrangea()
		end
	elseif self._hydrangeaInfo.status == PlayStatus.cooling then
		if time >= self._hydrangeaInfo.endCoolingTime then
			self._hydrangeaInfo.status = PlayStatus.unUse
		end
	end
end

function WeddingVenue:finiDrink()
	local winnerSID, member = self:drinkWinner()
	if winnerSID and member then
		local player = g_entityMgr:getPlayerBySID(winnerSID)
		if player then
			g_marriageMgr:broadCastScene2Client(self._weddingVenueID, 13140, 3, 2, {player:getName(), member:getCupsOfWine()})
		end
	end
	self:stopDrink()
end

function WeddingVenue:stopDrink()
	self:clearAllMemberWineItem()
	self._drinkInfo.status = PlayStatus.cooling
	self:broadCastInfo(MARRIAGE_SC_WEDDING_PLAY_FINI, "MarriageSCWeddingPlayFini", {play = PlayType.Drink})
	for _, member in pairs(self._playerInfoMapBySID) do
		member:stopDrink()
	end
	self:setAllMonsterInvisible(0)
	self:clearSceneWineItem()
end

function WeddingVenue:updateDrink(time)
	for _, member in pairs(self._playerInfoMapBySID) do
		member:update(time)
	end
	if self._drinkInfo.status == PlayStatus.using then
		if time >= self._drinkInfo.endTime then
			--self:pushDrinkRank()
			self:finiDrink()
		else
			if time >= self._drinkInfo.nextRankTime then
				self:pushDrinkRank()
				self._drinkInfo.nextRankTime = time + DRINK_RANK_INTERVAL
			end
		end
	elseif self._drinkInfo.status == PlayStatus.cooling then
		if time >= self._drinkInfo.endCoolingTime then
			self._drinkInfo.status = PlayStatus.unUse
		end
	end
end

function WeddingVenue:playerOutterAfter(player)
	if self._hydrangeaInfo.status == PlayStatus.using then
		if player:getSerialID() ==  self._hydrangeaInfo.ownerSID then
			if 0 == self:getPlayerCount() then
				self:stopHydrangea()
			else
				self:randomHydrangea()
			end
		end
	end
	if self._drinkInfo.status == PlayStatus.using then
		if 0 == self:getPlayerCount() then
			self:stopDrink()
		end
	end
	self:clearPlayerWineItem(player)
end

function WeddingVenue:playerInnerAfter(player)
	if self._info:getMaleSID() ~= player:getSerialID() and self._info:getFemaleSID() ~= player:getSerialID() then
		local member = VenueMemberInfo(self._info, self._wedding, self, player:getSerialID())
		local bonusInfo = self._bonusInfo[roleSID]
		if bonusInfo then
			member:setBonus(bonusInfo)
		end
		self:addPlayer(player, member)
	end
	self:pushVenueInfo(player)
	self:clearPlayerWineItem(player)
end

function WeddingVenue:reqWeddingBonusInfo(player)
	local member = self._playerInfoMapBySID[player:getSerialID()]
	if not member then
		return false, MarriageErrorCode.WeddingVenueWeddingBonusInfoNoVenue
	end
	local ret = {}
	ret.bonus1 = member:getBonusBit(MarriageBonusBit.GreetingCardBonusBit)
	ret.bonus2 = member:getBonusBit(MarriageBonusBit.CelebrateWineBonusBit)
	ret.bonus3 = member:getBonusBit(MarriageBonusBit.WeddingRedBonusBit)
	fireProtoMessage(player:getID(), MARRIAGE_SC_WEDDING_BONUS_INFO, 'MarriageSCWeddingBonusInfo', ret)
	return true
end

function WeddingVenue:guestDrink(player)
	local member = self._playerInfoMapBySID[player:getSerialID()]
	if self._drinkInfo.status == PlayStatus.using then
		if member then
			return member:drinkWine(player)
		else
			local ret = {}
			ret.res = MarriageErrorCode.WeddingVenueWeddingDrinkNoVenue
			fireProtoMessage(player:getID(), MARRIAGE_SC_ERROR, 'MarriageError', ret)
		end
	else
		local ret = {}
		ret.type = 1
		local drinkPlayInfo = {}
		drinkPlayInfo.endCoolingTime = self._drinkInfo.endCoolingTime
		ret.drinkPlayInfo = drinkPlayInfo
		fireProtoMessage(player:getID(), MARRIAGE_SC_WEDDING_DRINK_FAILED, 'MarriageSCWeddingDrinkFailed', ret)
	end
	return false
end

function WeddingVenue:drinkRank()
	if 0 == self:getPlayerCount() then
		return nil
	end
	local sidTable = {}
	for SID, member in pairs(self._playerInfoMapBySID) do
		if member:getCupsOfWine() > 0 then
			table.insert(sidTable, SID)
		end
	end
	if 0 == table.size(sidTable) then
		return nil
	end
	table.sort(sidTable, 
		function(a, b)
			local memberA = self._playerInfoMapBySID[a]
			local memberB = self._playerInfoMapBySID[b]
			if memberA._drinkInfo.cupsOfWine < memberB._drinkInfo.cupsOfWine then
				return true
			elseif memberA._drinkInfo.cupsOfWine > memberB._drinkInfo.cupsOfWine then
				return false
			else
				return memberA._drinkInfo.lastDrinkTime < memberB._drinkInfo.lastDrinkTime
			end
		end
	)
	return sidTable
end

function WeddingVenue:drinkWinner()
	local sidTable = self:drinkRank()
	if not sidTable then
		return nil
	end
	local winnerSID = sidTable[1]
	if winnerSID then
		return winnerSID, self._playerInfoMapBySID[winnerSID]
	end
	return nil
end

function WeddingVenue:pushDrinkRank(player)
	local sidTable = self:drinkRank()
	if not sidTable then
		return
	end
	local rankList = {}
	local i = 1
	for _, SID in ipairs(sidTable) do
		local member = self._playerInfoMapBySID[SID]
		if member then
			local tmpPlayer = g_entityMgr:getPlayerBySID(SID)
			if tmpPlayer then
				local rankItem = {}
				rankItem.name = tmpPlayer:getName()
				rankItem.cups = member:getCupsOfWine()
				table.insert(rankList, rankItem)
				i = i + 1
				if i > DRINK_RANK_LIMIT then
					break
				end
			end
		end
	end
	local ret = {}
	ret.rankList = rankList
	if player then
		fireProtoMessage(player:getID(), MARRIAGE_SC_WEDDING_DRINK_RANK, 'MarriageSCWeddingDrinkRank', ret)
	else 	--广播所有参与喝酒的宾客
		for _, SID in ipairs(sidTable) do
			local tmpPlayer = g_entityMgr:getPlayerBySID(SID)
			if tmpPlayer then
				fireProtoMessage(tmpPlayer:getID(), MARRIAGE_SC_WEDDING_DRINK_RANK, 'MarriageSCWeddingDrinkRank', ret)
			end
		end
	end
end

function WeddingVenue:clearPlayerWineItem(player)
	local itemMgr = player:getItemMgr()
	if itemMgr then
		local count = itemMgr:getItemCount(MARRIAGE_WINE_ITEM_ID)
		if count and count > 0 then
			itemMgr:destoryItem(MARRIAGE_WINE_ITEM_ID, count, 0)
		end
	end
end

function WeddingVenue:clearAllMemberWineItem()
	for SID, _ in pairs(self._playerInfoMapBySID) do
		local player = g_entityMgr:getPlayerBySID(SID)
		if player then
			self:clearPlayerWineItem(player)
		end
	end
end

function WeddingVenue:clearSceneWineItem()
	local scene = g_sceneMgr:getPublicScene(self._weddingVenueID)
	if scene then
		scene:removeMpws(MARRIAGE_WINE_ITEM_ID)
	end
end

function WeddingVenue:setAllMonsterInvisible(show)
	local scene = g_sceneMgr:getPublicScene(self._weddingVenueID)
	if scene then
		scene:setAllMonsterInvisible(show)
	end
end

function WeddingVenue:stopPlay()
	if self._drinkInfo.status == PlayStatus.using then
		self:stopDrink()
	end

	if self._hydrangeaInfo.status == PlayStatus.using then
		self:stopHydrangea()
	end
end

function WeddingVenue:kickOutPlayer(roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		g_marriageMgr:transmitTo(player, 2100, WEDDING_VENUE_KICKOUT_POINT)
	end
end

function WeddingVenue:kickOutAllPlayer()
	local male = self._info:getMale()
	if male and male:getMapID() == self._weddingVenueID then
		g_marriageMgr:transmitTo(male, 2100, WEDDING_VENUE_KICKOUT_POINT)
	end

	local female = self._info:getFemale()
	if female and female:getMapID() == self._weddingVenueID then
		g_marriageMgr:transmitTo(female, 2100, WEDDING_VENUE_KICKOUT_POINT)
	end

	for SID, _ in pairs(self._playerInfoMapBySID) do
		local player = g_entityMgr:getPlayerBySID(SID)
		if player then
			g_marriageMgr:transmitTo(player, 2100, WEDDING_VENUE_KICKOUT_POINT)
		end
	end
end