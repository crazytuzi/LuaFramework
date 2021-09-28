--MarriageWedding.lua
--/*-----------------------------------------------------------------
 --* Module:  MarriageWedding.lua
 --* Author:  goddard
 --* Modified: 2016年9月16日
 --* Purpose: 婚礼信息
 -------------------------------------------------------------------*/

require ("system.marriage.WeddingCar")
require ("system.marriage.WeddingVenue")

MarriageWedding = class()

function MarriageWedding:__init(info, type, time)
	self._info = info
	self._type = type
	self._startTime = time
	self._broadcastCount = 0
	self._weddingCarBroadcast = false
	self._weddingCarStatus = WEDDINGCAR_STATUS.UnFinish
	self._weddingCar = nil
	self._weddingVenue = nil
	self._weddingVenueStatus = WEDDINGVENUE_STATUS.UnFinish
	self._createCarTime = false
	self._weddingBroadcast = WEDDINGBROADCAST_STATUS.UnFinish
	self._finished = false
end

function MarriageWedding:loadData(wedding)
	self:setWeddingCarStatus(wedding.weddingCarStatus)
	self:setWeddingVenueStatus(wedding.weddingVenueStatus)
	self._weddingBroadcast = wedding.weddingBroadcast
end

function MarriageWedding:serializeBuf()
	local wedding = {}
	wedding.weddingCarStatus = self:getWeddingCarStatus()
	wedding.weddingType = self._type
	wedding.weddingVenueStatus = self:getWeddingVenueStatus()
	wedding.weddingBroadcast = self._weddingBroadcast
	return wedding
end

function MarriageWedding:getWeddingCarStatus()
	return self._weddingCarStatus
end

function MarriageWedding:setWeddingCarStatus(s)
	self._weddingCarStatus = s
end

function MarriageWedding:getWeddingVenueStatus()
	return self._weddingVenueStatus
end

function MarriageWedding:setWeddingVenueStatus(s)
	self._weddingVenueStatus = s
end

function MarriageWedding:broadcastProcess(time)
	if self._broadcastCount >= MARRIAGE_WEDDING_BROADCAST_TOTALTIME / MARRIAGE_WEDDING_BROADCAST_PERIOD then
		self._weddingBroadcast = WEDDINGBROADCAST_STATUS.Finish
		return
	end
	local period = time - self._startTime
	local nextPeriod = self._broadcastCount * MARRIAGE_WEDDING_BROADCAST_PERIOD
	if period >= nextPeriod then
		local maleName = self._info:getMaleName()
		local femaleName = self._info:getFemaleName()
		if maleName and femaleName then
			g_marriageMgr:sendErrMsg2Client(109, 2, { maleName, femaleName })
		end
		self._broadcastCount = self._broadcastCount + 1
	end
end

function MarriageWedding:update(time)
	if self._finished then
		return
	end
	local spendTime = time - self._startTime 
	if spendTime >= WEDDING_TOTAL_TIME[self._type] then
		self:finish()
		return
	end
	if WEDDINGBROADCAST_STATUS.UnFinish == self._weddingBroadcast then
		self:broadcastProcess(time)
	end
	if WEDDINGCAR_STATUS.UnFinish == self._weddingCarStatus then
		self:weddingCarProcess(time)
	end
	if self._weddingVenue then
		local restTime = WEDDING_TOTAL_TIME[self._type] - spendTime
		self._weddingVenue:update(time, restTime)
	end
end

function MarriageWedding:weddingCarProcess(time)
	if WeddingType.LUXURY ~= self._type then
		return
	end
	if not self._weddingCar and time >= self._createCarTime then
		self._weddingCar = WeddingCar(self._info, self)
	end
	if self._weddingCar then
		if not self._weddingCarBroadcast then
			local period = time - self._startTime
			if period >= WEDDING_CAR_BROADCAST_PERIOD then
				g_marriageMgr:sendErrMsg2Client(110, 2, { maleName, femaleName })
				self._weddingCarBroadcast = true
			end
		end
		self._weddingCar:update(time)
	end
end

function MarriageWedding:stopMove(monID)
	if self._weddingCar then
		self._weddingCar:stopMove(monID)
	end
end

function MarriageWedding:weddingCarFini()
	self:setWeddingCarStatus(WEDDINGCAR_STATUS.Finish)
	self._weddingCar = nil
	self._info:saveData()
end

function MarriageWedding:start(venueID)
	local now = os.time()
	if WEDDINGCAR_STATUS.UnFinish == self._weddingCarStatus and WeddingType.LUXURY == self._type then
		local createTime = g_marriageMgr:getCreateCarTime()
		if createTime < now then
			createTime = now
			g_marriageMgr:updateCreateCarTime(now)
		else
			g_marriageMgr:updateCreateCarTime()
		end
		self._createCarTime = createTime
	end
	if WEDDINGVENUE_STATUS.UnFinish == self:getWeddingVenueStatus() then
		if not self._weddingVenue then
			self._weddingVenue = WeddingVenue(self._info, self, self._type)
			if venueID then
				self._weddingVenue:setVenueID(venueID)
			else
				print("MarriageWedding:start venueID nil")
			end
		end
	end
end

function MarriageWedding:setVenueID(id)
	if self._weddingVenue then
		self._weddingVenue:setVenueID(id)
	end
end

function MarriageWedding:enterWeddingVenue(player)
	if self._weddingVenue then
		self._weddingVenue:enter(player)
	end
end

function MarriageWedding:finish()
	if self._weddingVenue then
		self._weddingVenue:finish()
	end
	if self._weddingCar then
		self._weddingCar:finish()
	end
	self._finished = true
end

function MarriageWedding:weddingVenueFini()
	self._weddingVenue = nil
	self._info:finiWedding()
end

function MarriageWedding:weddingInvitationEnter(player)
	if self._weddingVenue then
		return self._weddingVenue:invitationEnter(player)
	else
		if WEDDINGVENUE_STATUS.Finish == self:getWeddingVenueStatus() then
			return false, MarriageErrorCode.WeddingVenueWeddingVenueFini
		else
			return false, MarriageErrorCode.WeddingVenueNoStartWeddingVenue
		end
	end
end

function MarriageWedding:reqWeddingGuestList(player)
	if self._weddingVenue then
		return self._weddingVenue:reqWeddingGuestList(player)
	else
		if WEDDINGVENUE_STATUS.Finish == self:getWeddingVenueStatus() then
			return false, MarriageErrorCode.WeddingVenueWeddingGuestListFini
		else
			return false, MarriageErrorCode.WeddingVenueWeddingGuestListNoStart
		end
	end
end

function MarriageWedding:reqWeddingSendBonus(player, bonus)
	if self._weddingVenue then
		return self._weddingVenue:reqWeddingSendBonus(player, bonus)
	else
		if WEDDINGVENUE_STATUS.Finish == self:getWeddingVenueStatus() then
			return false, MarriageErrorCode.WeddingVenueWeddingSendBonusFini
		else
			return false, MarriageErrorCode.WeddingVenueWeddingSendBonusNoStart
		end
	end
end

function MarriageWedding:paySendBonusCallback(roleSID, callBackContext)
	if self._weddingVenue then
		return self._weddingVenue:paySendBonusCallback(roleSID, callBackContext)
	else
		local context = unserialize(callBackContext)
		print("MarriageWedding:paySendBonusCallback: self._weddingVenue not found, weddingVenus status: ", self:getWeddingVenueStatus(), " , playerSerialID: ", roleSID, " bonustype: ", context.bonus, " ingot:", context.ingot)
		return TPAY_FAILED, MarriageErrorCode.WeddingVenueWeddingSendBonusFini
	end
end

function MarriageWedding:reqWeddingKickout(player, roleSID)
	if self._weddingVenue then
		return self._weddingVenue:reqWeddingKickout(player, roleSID)
	else
		if WEDDINGVENUE_STATUS.Finish == self:getWeddingVenueStatus() then
			return false, MarriageErrorCode.WeddingVenueWeddingKickoutFini
		else
			return false, MarriageErrorCode.WeddingVenueWeddingKickoutNoStart
		end
	end
end

function MarriageWedding:reqWeddingAmbience(player, ambience)
	if self._weddingVenue then
		return self._weddingVenue:reqWeddingAmbience(player, ambience)
	else
		if WEDDINGVENUE_STATUS.Finish == self:getWeddingVenueStatus() then
			return false, MarriageErrorCode.WeddingVenueWeddingAmbienceFini
		else
			return false, MarriageErrorCode.WeddingVenueWeddingAmbienceNoStart
		end
	end
end

function MarriageWedding:reqWeddingOnTheCar(player)
	if not self._weddingCar then
		if self:getWeddingCarStatus() ==  WEDDINGCAR_STATUS.UnFinish then
			return false, MarriageErrorCode.WeddingCarOnNoStart
		elseif self:getWeddingCarStatus() == WEDDINGCAR_STATUS.Finish then
			return false, MarriageErrorCode.WeddingCarOnFini
		end
	else
		return self._weddingCar:reqWeddingOnTheCar(player)
	end
end

function MarriageWedding:reqWeddingUnderTheCar(player)
	if not self._weddingCar then
		if self:getWeddingCarStatus() == WEDDINGCAR_STATUS.UnFinish then
			return false, MarriageErrorCode.WeddingCarUnderNoStart
		elseif self:getWeddingCarStatus() == WEDDINGCAR_STATUS.Finish then
			return false, MarriageErrorCode.WeddingCarUnderFini
		end
	else
		self._weddingCar:reqWeddingUnderTheCar(player)
	end
end

function MarriageWedding:reqWeddingVenueInfo(player)
	if self._weddingVenue then
		self._weddingVenue:reqWeddingVenueInfo(player)
	end
end

function MarriageWedding:onPlayerOffline(player)
	if self._weddingCar then
		self._weddingCar:onPlayerOffline(player)
	end
end

function MarriageWedding:reqWeddingPlay(player, play)
	if self._weddingVenue then
		return self._weddingVenue:reqWeddingPlay(player, play)
	else
		if WEDDINGVENUE_STATUS.Finish == self:getWeddingVenueStatus() then
			return false, MarriageErrorCode.WeddingVenuePlayFini
		else
			return false, MarriageErrorCode.WeddingVenuePlayNoStart
		end
	end
end

function MarriageWedding:reqWeddingBonusInfo(player)
	if self._weddingVenue then
		return self._weddingVenue:reqWeddingBonusInfo(player)
	else
		if WEDDINGVENUE_STATUS.Finish == self:getWeddingVenueStatus() then
			return false, MarriageErrorCode.WeddingVenueWeddingBonusInfoFini
		else
			return false, MarriageErrorCode.WeddingVenueWeddingBonusInfoNoStart
		end
	end
end

function MarriageWedding:reqWeddingVenueTimeInfo(player)
	if WEDDINGVENUE_STATUS.UnFinish == self:getWeddingVenueStatus() and self._weddingVenue then
		local ret = {}
		ret.startTime = self._startTime
		ret.endTime = self._startTime + WEDDING_TOTAL_TIME[self._type]
		fireProtoMessage(player:getID(), MARRIAGE_SC_WEDDING_VENUE_TIME_INFO, 'MarriageSCWeddingVenueTimeInfo', ret)
	end
end