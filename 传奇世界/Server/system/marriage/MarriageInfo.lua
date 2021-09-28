--MarriageInfo.lua
--/*-----------------------------------------------------------------
 --* Module:  MarriageInfo.lua
 --* Author:  goddard
 --* Modified: 2016年8月12日
 --* Purpose: 婚姻信息
 -------------------------------------------------------------------*/
require ("base.class")
require ("base.protobuf")

require "data.MarriageTourTask"
require "system.marriage.MarriageTour"
require "system.marriage.MarriageConstant"
require "system.marriage.MarriageEventHandler"
require "system.marriage.MarriageWedding"

MarriageInfo = class(nil, Timer)

local prop = Property(MarriageInfo)

prop:accessor("marriageID")
prop:accessor("maleSID")
prop:accessor("femaleSID")
prop:accessor("time")
prop:accessor("male")
prop:accessor("female")
prop:accessor("maleName")
prop:accessor("femaleName")

function MarriageInfo:__init(ID)
	prop(self, "marriageID", ID)
	self._tourInfo = nil
	self._wedding = nil
	self._status = MarriageStatus.UnTour
	self._weddingStatus = WeddingStatus.UnWedding
	self._weddingStartTime = nil
	self._eventHandler = MarriageEventHandler()
	self._bonusTotal = 0
end

function MarriageInfo:addBonusTotal(bonus)
	self._bonusTotal = self._bonusTotal + bonus
end

function MarriageInfo:setBonusTotal(bonus)
	self._bonusTotal = bonus
end

function MarriageInfo:getBonusTotal()
	return self._bonusTotal
end

function MarriageInfo:setStatus(status)
	self._status = status
end

function MarriageInfo:getStatus()
	return self._status
end

function MarriageInfo:setWeddingStatus(status)
	self._weddingStatus = status
end

function MarriageInfo:getWeddingStatus()
	return self._weddingStatus
end

function MarriageInfo:loadMarriageData(data)
	print("data len: ", #data)
	if #data > 0 then
		local datas,err = protobuf.decode("MarriageProtocol", data)
		if not datas then
			print("MarriageInfo:loadMarriageData decode error ", err, ":", data)
			return
		end
		self:setStatus(datas.status)
		self:setMaleSID(datas.maleSId)
		self:setFemaleSID(datas.femaleSId)
		self:setMaleName(datas.maleName)
		self:setFemaleName(datas.femaleName)
		self:setTime(datas.time)
		self:setWeddingStatus(datas.weddingStatus)
		self._weddingStartTime = datas.weddingStartTime
		self:setBonusTotal(datas.bonusTotal)
		g_marriageMgr:setMarriageIDMap(datas.maleSId, self:getMarriageID())
		g_marriageMgr:setMarriageIDMap(datas.femaleSId, self:getMarriageID())
		local needSave = self:loadTourData(datas)
		self:loadWeddingData(datas)

		if needSave then
			self:saveData()
		end
	end
end

function MarriageInfo:loadTourData(datas)
	if MarriageStatus.Touring == datas.status then
		local tour = datas.tour
		local needSave = false
		self._tourInfo = MarriageTour(self)
		if tour then
			self._tourInfo:setStatus(tour.taskStatus)
		else
			self._tourInfo:setStatus(MarriageTaskStep.UnFinish)
		end
		if MarriageTaskStep.UnFinish == self._tourInfo:getStatus() then
			self:setStatus(MarriageStatus.UnTour)
			needSave = true
		end
		if needSave then
			return needSave
		end
	end
end

function MarriageInfo:loadWeddingData(datas)
	if WeddingStatus.Wedding == datas.weddingStatus then
		local wedding = datas.wedding
		self._wedding = MarriageWedding(self, wedding.weddingType, datas.weddingStartTime)
		self._wedding:loadData(wedding)
		local venueID = g_marriageMgr:getWeddingAvailableVenue()
		if venueID then
			g_marriageMgr:delWeddingAvailableVenue(venueID)
		end
		self._wedding:start(venueID)
	end
end

function MarriageInfo:__release()
	gTimerMgr:unregTimer(self)
end

function MarriageInfo:onPlayerOnline(player, online)
	gTimerMgr:regTimer(self, MARRIAGE_TIMER_PERIOD, MARRIAGE_TIMER_PERIOD)
end

function MarriageInfo:serializeBuf()
	print("MarriageInfo:serializeBuf")
	local datas = {}
	if self._tourInfo then
		datas.tour = self._tourInfo:serializeBuf()
	end
	if self._wedding then
		datas.wedding = self._wedding:serializeBuf()
	end
	datas.status = self:getStatus()
	datas.maleSId = self:getMaleSID()
	datas.femaleSId = self:getFemaleSID()
	datas.time = self:getTime()
	datas.marriageId = self:getMarriageID()
	datas.weddingStatus = self:getWeddingStatus()
	datas.maleName = self:getMaleName()
	datas.femaleName = self:getFemaleName()
	datas.weddingStartTime = self._weddingStartTime
	datas.bonusTotal = self:getBonusTotal()
	return protobuf.encode("MarriageProtocol", datas)
end

function MarriageInfo:startTour()
	self._tourInfo = MarriageTour(self)
	self._status = MarriageStatus.Touring
	self:saveData()
end

function MarriageInfo:notifyFinishTask(curTaskID, nextTaskID)
	local ret = {}
	local config = g_marriageMgr:findTaskConfig(curTaskID)
	if config then
		ret.taskType = config.q_type
		ret.taskStep = config.q_step
	end
	if 0 ~= nextTaskID then
		local nextConfig = g_marriageMgr:findTaskConfig(nextTaskID)
		if nextConfig then
			ret.nextType = nextConfig.q_type
			ret.nextStep = nextConfig.q_step
		end
	else
		ret.nextType = 0
		ret.nextStep = 0
	end
	local male = self:getMale()
	if male then	
		fireProtoMessage(male:getID(), MARRIAGE_SC_FINISH_TASK, 'MarriageSCFinishTask', ret)
	end
	local female = self:getFemale()
	if female then	
		fireProtoMessage(female:getID(), MARRIAGE_SC_FINISH_TASK, 'MarriageSCFinishTask', ret)
	end
end

function MarriageInfo:recvTask()
	if not self._tourInfo then
		return false
	end
	local ret, taskId = self._tourInfo:recvTask()
	return ret, taskId
end

function MarriageInfo:tourOpt(player, taskId, step)
	if self._tourInfo then
		self._tourInfo:tourOpt(player, taskId, step)
	end
end

function MarriageInfo:update()
	local now = os.time()
	if self._wedding then
		self._wedding:update(now)
	end
end

function MarriageInfo:teamClose()
	if not self._tourInfo then
		return
	end
	self._status = MarriageStatus.UnTour
	self._tourInfo:teamClose()
	self._tourInfo = nil
end

function MarriageInfo:addWatcher(eventName, listener)
	local eventHandler = self:getEventHandler()
	if eventHandler then
		eventHandler:addWatcher(eventName, listener)
	end	
end

function MarriageInfo:removeWatcher(eventName, listener)
	local eventHandler = self:getEventHandler()
	if eventHandler then
		eventHandler:removeWatcher(eventName, listener)
	end
end

function MarriageInfo:notifyListener(eventName, ...)
	local eventHandler = self:getEventHandler()
	if eventHandler then
		eventHandler:notifyWatchers(eventName, ...)
	end
end

function MarriageInfo:getEventHandler()
	return self._eventHandler
end

function MarriageInfo:curTaskID()
	if not self._tourInfo then
		return false
	end
	local ret, taskId = self._tourInfo:curTaskID()
	return ret, taskId
end

function MarriageInfo:giveUpTask()
	self:setStatus(MarriageStatus.UnTour)
	if not self._tourInfo then
		return false
	end
	self._tourInfo:giveUpTask()
	self._tourInfo = nil
end

function MarriageInfo:canStartTour()
	if MarriageStatus.UnTour == self._status then
		return true
	end
	return false
end

function MarriageInfo:saveData()
	local buf = self:serializeBuf()
	g_entityDao:saveMarriageData(self:getMarriageID(), buf, #buf)
end

function MarriageInfo:mapProcess(player)
	if MARRIAGE_CEREMONY_MAP_ID == player:getMapID() then
		g_marriageMgr:transmitTo(player, 2100, WEDDING_VENUE_KICKOUT_POINT)
	end
end

function MarriageInfo:onPlayerOnline(player)
	local needSend = false
	local SID = player:getSerialID()
	if SID == self:getMaleSID() then
		self:setMale(player)
		needSend = true
	elseif SID == self:getFemaleSID() then
		self:setFemale(player)
		needSend = true
	end
	if needSend then
		local ret = {}
		ret.maleSID = self:getMaleSID()
		ret.femaleSID = self:getFemaleSID()
		ret.status = self:getStatus()
		ret.weddingStatus = self:getWeddingStatus()
		ret.marriageID = self:getMarriageID()
		ret.maleName = self:getMaleName()
		ret.femaleName = self:getFemaleName()
		ret.tourinfo = {}
		print("1111111111111111111111111111111:", ret.status, ":", ret.weddingStatus)
		if self._tourInfo then
			local status = self._tourInfo:getStatus()
			print("22222222222222222222222222:", status)
			if MarriageTaskStep.AllFinish == status then
				ret.tourinfo.status = 2
			else
				local taskID = self._tourInfo:getCurTaskID()
				print("333333333333333333333333333:", taskID)
				if taskID then
					print("444444444444444444444444444444444:", taskID)
					local config = g_marriageMgr:findTaskConfig(taskID)
					if config then
						print("5555555555555555555555555555:", config.q_type, ":", config.q_step)
						ret.tourinfo.taskType = config.q_type
						ret.tourinfo.taskStep = config.q_step
						if self:curTaskFini() then
							print("666666666666666666666666:", config.q_type, ":", config.q_step)
							ret.tourinfo.status = 1
						else
							ret.tourinfo.status = 0
							print("7777777777777777777777777:", config.q_type, ":", config.q_step)
						end
					end
				end
			end
		end
		self:mapProcess(player)
		print("888888888888888888:", serialize(ret))
		fireProtoMessage(player:getID(), MARRIAGE_INFO, 'MarriageInfo', ret)
	end
end

function MarriageInfo:onPlayerOffline(player)
	local SID = player:getSerialID()
	if SID == self:getMaleSID() then
		self:setMale(nil)
	elseif SID == self:getFemaleSID() then
		self:setFemale(nil)
	end
	if self._wedding then
		self._wedding:onPlayerOffline(player)
	end
end

function MarriageInfo:curTaskFini()
	if self._tourInfo then
		return self._tourInfo:curTaskFini()
	end
	return true
end

function MarriageInfo:getTour()
	return self._tourInfo
end

function MarriageInfo:taskFinish()
	if self._tourInfo then
		self._tourInfo:taskFinish()
	end
end

function MarriageInfo:allTourTaskFini()
	if self._status ~= MarriageStatus.Touring and self._status ~= MarriageStatus.UnTour then
		return true
	end
	if self._tourInfo then
		return self._tourInfo:allTaskFini()
	end
	return false
end

function MarriageInfo:answerEnterCeremony(player, res)
	if not self._tourInfo then
		return
	end
	if 0 ~= res then
		local ret = {}
		ret.res = 1
		local male = self:getMale()
		if male then
			fireProtoMessage(male:getID(), MARRIAGE_SC_ENTER_CEREMONY, 'MarriageSCEnterCeremony', ret)
		end
		local female = self:getFemale()
		if female then
			fireProtoMessage(female:getID(), MARRIAGE_SC_ENTER_CEREMONY, 'MarriageSCEnterCeremony', ret)
		end
		self._tourInfo:clearEnterCeremony()
		return
	end
	local wait = false
	if self:getMaleSID() == player:getSerialID() then
		wait = self._tourInfo:answerEnterCeremony(MarriageCeremonyBit.MaleAgreeValue)
	elseif self:getFemaleSID() == player:getSerialID() then
		wait = self._tourInfo:answerEnterCeremony(MarriageCeremonyBit.FemaleAgreeValue)
	end
	if wait then
		local ret = {}
		fireProtoMessage(player:getID(), MARRIAGE_SC_ENTER_CEREMONY_WAIT, 'MarriageSCEnterCeremonyWait', ret)
	end
end

function MarriageInfo:answerEnterCeremonyCancel(player)
	if not self._tourInfo then
		return
	end
	if self:getStatus() ~= MarriageStatus.Touring then
		return
	end
	local ret = {}
	ret.res = 1
	local male = self:getMale()
	if male then
		fireProtoMessage(male:getID(), MARRIAGE_SC_ENTER_CEREMONY, 'MarriageSCEnterCeremony', ret)
	end
	local female = self:getFemale()
	if female then
		fireProtoMessage(female:getID(), MARRIAGE_SC_ENTER_CEREMONY, 'MarriageSCEnterCeremony', ret)
	end
	self._tourInfo:clearEnterCeremony()
	return
end

function MarriageInfo:onPlayerMoveInCeremony(monID)
	local male = self:getMale()
	if not male then
		return
	end
	local female = self:getFemale()
	if not female then
		return
	end
	local malePos = male:getPosition()
	local femalePos = female:getPosition()
	print("11111111111111111111111111:", malePos.x, ":", malePos.y, ":", femalePos.x, ":", femalePos.y)
	if 20 == malePos.x and 30 == malePos.y and 24 == femalePos.x and 31 == femalePos.y then
		print("11111111111111111111111111")
		local ret = {}
		fireProtoMessage(male:getID(), MARRIAGE_SC_ARRIAVE_CEREMONY_POINT, 'MarriageSCArriaveCeremonyPoint', ret)
		fireProtoMessage(female:getID(), MARRIAGE_SC_ARRIAVE_CEREMONY_POINT, 'MarriageSCArriaveCeremonyPoint', ret)
		self:setStatus(MarriageStatus.Married)
		self:removeWatcher("onPlayerMoveInCeremony", self)
		self:saveData()
	end
end

function MarriageInfo:printself()
	print("1111111111111111:", self)
	if self._tourInfo then
		self._tourInfo:printinfo()
	end
end

function MarriageInfo:quitCeremonyBeforePoint(player)
	if self:getMaleSID() == player:getSerialID() or self:getFemaleSID() == player:getSerialID() then
		self:removeWatcher("onPlayerMoveInCeremony", self)
		local pos = {}
		pos.x = 133
		pos.y = 127
		g_marriageMgr:transmitTo(player, 2100, pos)
	end
end

function MarriageInfo:ceremonyFini(player)
	if MarriageStatus.Married ~= self:getStatus() then
		return
	end
	if self:getMaleSID() == player:getSerialID() or self:getFemaleSID() == player:getSerialID() then
		local pos = {}
		pos.x = 133
		pos.y = 127
		local male = self:getMale()
		if male then
			g_marriageMgr:transmitTo(male, 2100, pos)
		end
		local female = self:getFemale()
		if female then
			g_marriageMgr:transmitTo(female, 2100, pos)
		end
	end
end

function MarriageInfo:findWeddingConfig(type)
	for _, config in pairs(WeddingInfoConfig) do
		if config.q_type == type then
			return config
		end
	end
end

function MarriageInfo:reqStartWedding(player, type)
	local male = self:getMale()
	if male then
		local itemMgr = male:getItemMgr()
		if itemMgr:getEmptySize(Item_BagIndex_Bag) < 1 then
			return false, MarriageErrorCode.ReqWeddingBagNotEnough
		end
	end
	local female = self:getFemale()
	if female then
		local itemMgr = female:getItemMgr()
		if itemMgr:getEmptySize(Item_BagIndex_Bag) < 1 then
			return false, MarriageErrorCode.ReqWeddingBagNotEnough
		end
	end

	local venueID = g_marriageMgr:getWeddingAvailableVenue()
	if not venueID then
		return false, MarriageErrorCode.ReqWeddingNoVenue
	end
	if MarriageStatus.Married ~= self:getStatus() then
		return false, MarriageErrorCode.ReqWeddingUnMarried
	end
	if WeddingStatus.UnWedding ~= self:getWeddingStatus() then
		return false, MarriageErrorCode.ReqWeddingHasOpened
	end
	local config = false
	local weddingType
	if 1 == type then
		config = self:findWeddingConfig(WeddingType.CLASSIC)
		weddingType = WeddingType.CLASSIC
	elseif 2 == type then
		config = self:findWeddingConfig(WeddingType.LUXURY)
		weddingType = WeddingType.LUXURY
	end

	if not config then
		return false
	end
	if not isIngotEnough(player, config.q_price) then
		return false, MarriageErrorCode.ReqWeddingIngotFailed
	end

	local context = { wedding_type = weddingType, venue_id = venueID}
	local ret = g_tPayMgr:TPayScriptUseMoney(player, config.q_price, 235, "", 0, 0, "MarriageManager.DoYuanBaoMarriagePray", serialize(context)) 
	if ret ~= 0 then
		print("MarriageInfo:reqStartWedding: g_tPayMgr:TPayScriptUseMoney return ~0, playerSerialID:", player:getSerialID())
		return false, MarriageErrorCode.ReqWeddingIngotFailed
	end
	g_marriageMgr:delWeddingAvailableVenue(venueID)
	return true
end

function MarriageInfo:payWeddingCallback(player, ret, callBackContext)
	local context = unserialize(callBackContext)
	local venueID = context.venue_id
	if 0 ~= ret then
		local ret = {}
		ret.res = MarriageErrorCode.ReqWeddingIngotFailed
		fireProtoMessage(player:getID(), MARRIAGE_SC_ERROR, 'MarriageError', ret)
		g_marriageMgr:addWeddingAvailableVenue(venueID)
		print("MarriageInfo:payWeddingCallback: ret ~0, playerID:", player:getID(), " ret :", ret)
		return
	end
	local now = os.time()
	local weddingType = context.wedding_type
	--self:setWeddingStatus(WeddingStatus.Wedding)
	if self._wedding then
		print("MarriageInfo:payWeddingCallback self._wedding already exist")
		--return TPAY_FAILED
		self._wedding:finish()
		self._wedding = nil
	end
	local item = g_ActivityMgr:getItemInfo(INVITATION_CARD_ITEM_ID)
	if item then
		self._wedding = MarriageWedding(self, weddingType, now)
		self._wedding:start(venueID)
		self:saveData()
		local ret = {}
		local male = self:getMale()
		if male then
			local itemMgr = male:getItemMgr()
			local count = itemMgr:getItemCount(INVITATION_CARD_ITEM_ID)
			if count and count > 0 then
				itemMgr:destoryItem(INVITATION_CARD_ITEM_ID, count, 0)
			end
			itemMgr:addItem(Item_BagIndex_Bag, item.itemID, 1, item.bind, 0, 0, item.strength)
			fireProtoMessage(male:getID(), MARRIAGE_SC_START_WEDDING_SUCC, 'MarriageSCStartWeddingSucc', ret)
		end
		local female = self:getFemale()
		if female then
			local itemMgr = female:getItemMgr()
			local count = itemMgr:getItemCount(INVITATION_CARD_ITEM_ID)
			if count and count > 0 then
				itemMgr:destoryItem(INVITATION_CARD_ITEM_ID, count, 0)
			end
			itemMgr:addItem(Item_BagIndex_Bag, item.itemID, 1, item.bind, 0, 0, item.strength)
			fireProtoMessage(female:getID(), MARRIAGE_SC_START_WEDDING_SUCC, 'MarriageSCStartWeddingSucc', ret)
		end
		return TPAY_SUCESS
	else
		print("MarriageInfo:payWeddingCallback item get error item id:", INVITATION_CARD_ITEM_ID)
		g_marriageMgr:addWeddingAvailableVenue(venueID)
		return TPAY_FAILED
	end
end

function MarriageInfo:stopMove(monID)
	if self._wedding then
		self._wedding:stopMove(monID)
	end
end

function MarriageInfo:reqWeddingInvitation(player)
	if self._wedding then
		if self:getMaleSID() ~= player:getSerialID() and self:getFemaleSID() ~= player:getSerialID() then
			return self._wedding:weddingInvitationEnter(player)
		else
			return false, MarriageErrorCode.WeddingVenueInvitationSpouse
		end
	else
		return false, MarriageErrorCode.WeddingVenueWeddingVenueFini
	end
end

function MarriageInfo:reqEnterWeddingVenue(player)
	if self._wedding then
		if self:getMaleSID() == player:getSerialID() or self:getFemaleSID() == player:getSerialID() then
			self._wedding:enterWeddingVenue(player)
		end
	end
end

function MarriageInfo:reqWeddingGuestList(player)
	if self._wedding then
		if self:getMaleSID() == player:getSerialID() or self:getFemaleSID() == player:getSerialID() then
			return self._wedding:reqWeddingGuestList(player)
		else
			return false, WeddingVenueWeddingGuestListNoSpouse
		end
	else
		return false, MarriageErrorCode.WeddingVenueWeddingGuestListFini
	end
end

function MarriageInfo:reqWeddingSendBonus(player, bonus)
	if self._wedding then
		return self._wedding:reqWeddingSendBonus(player, bonus)
	else
		return false, MarriageErrorCode.WeddingVenueWeddingSendBonusFini
	end
end

function MarriageInfo:paySendBonusCallback(roleSID, callBackContext)
	if self._wedding then
		return self._wedding:paySendBonusCallback(roleSID, callBackContext)
	else
		local context = unserialize(callBackContext)
		print("marriage:paySendBonusCallback: self._wedding not found, wedding status: ", self:getWeddingStatus(), " , playerSerialID: ", roleSID, " bonustype: ", context.bonus, " ingot:", context.ingot)
		return TPAY_FAILED, MarriageErrorCode.WeddingVenueWeddingSendBonusFini
	end
end

function MarriageInfo:reqWeddingKickout(player, roleSID)
	if self._wedding then
		return self._wedding:reqWeddingKickout(player, roleSID)
	else
		return false, MarriageErrorCode.WeddingVenueWeddingKickoutFini
	end
end

function MarriageInfo:reqWeddingAmbience(player, ambience)
	if self._wedding then
		return self._wedding:reqWeddingAmbience(player, ambience)
	else
		return false, MarriageErrorCode.WeddingVenueWeddingAmbienceFini
	end
end

function MarriageInfo:reqWeddingOnTheCar(player)
	if self:getMaleSID() ~= player:getSerialID() and self:getFemaleSID() ~= player:getSerialID() then
		return false, MarriageErrorCode.WeddingCarOnNoSpouse
	end

	if self._wedding then
		return self._wedding:reqWeddingOnTheCar(player, ambience)
	else
		return false, MarriageErrorCode.WeddingCarOnFini
	end
end

function MarriageInfo:reqWeddingUnderTheCar(player)
	if self:getMaleSID() ~= player:getSerialID() and self:getFemaleSID() ~= player:getSerialID() then
		return false, MarriageErrorCode.WeddingCarUnderNoSpouse
	end
	if self._wedding then
		return self._wedding:reqWeddingUnderTheCar(player, ambience)
	else
		return false, MarriageErrorCode.WeddingCarUnderFini
	end
end

function MarriageInfo:reqWeddingVenueInfo(player)
	if self._wedding then
		self._wedding:reqWeddingVenueInfo(player)
	end
end

function MarriageInfo:reqWeddingPlay(player, play)
	if self:getMaleSID() ~= player:getSerialID() and self:getFemaleSID() ~= player:getSerialID() then
		return false, MarriageErrorCode.WeddingVenuePlayNoSpouse
	end
	if self._wedding then
		return self._wedding:reqWeddingPlay(player, play)
	else
		return false, MarriageErrorCode.WeddingVenuePlayFini
	end
end

function MarriageInfo:reqWeddingBonusInfo(player)
	if self:getMaleSID() == player:getSerialID() or self:getFemaleSID() == player:getSerialID() then
		return false, MarriageErrorCode.WeddingVenueWeddingBonusInfoSpouse
	end
	if self._wedding then
		self._wedding:reqWeddingBonusInfo(player)
	else
		return false, MarriageErrorCode.WeddingVenueWeddingBonusInfoFini
	end
end

function MarriageInfo:finiWedding()
	self:sendBonusEmail()
	self:setWeddingStatus(WeddingStatus.Wedded)
	self._wedding = nil
	self:saveData()
end

function MarriageInfo:sendBonusEmail()
	local email = offlineMgr:createEamil()
	email:setDescId(MARRIAGE_BONUS_EMAIL_ID)
	email:insertProto(ITEM_INGOT_ID, self:getBonusTotal(), false, 0)
	email:setType(eMarriageBonus)
	offlineMgr:recvEamil(self:getFemaleSID(), email, 243, 0)
	self:setBonusTotal(0)
end

function MarriageInfo:reqWeddingVenueTimeInfo(player)
	if self._wedding then
		self._wedding:reqWeddingVenueTimeInfo(player)
	end
end