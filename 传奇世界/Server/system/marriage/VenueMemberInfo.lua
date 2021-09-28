--VenueMemberInfo.lua
--/*-----------------------------------------------------------------
 --* Module:  VenueMemberInfo.lua
 --* Author:  goddard
 --* Modified: 2016年9月20日
 --* Purpose: 会场成员信息
 -------------------------------------------------------------------*/

VenueMemberInfo = class()

function VenueMemberInfo:__init(info, wedding, venue, SID)
	self._info = info
	self._wedding = wedding
	self._venue = venue
	self._SID = SID
	self._bonusBit = 0
	self._drinkInfo = {}
	self._drinkInfo.cupsOfWine = 0		--参与这次拼酒活动喝酒杯数
	self._drinkInfo.lastDrinkTime = 0
end

function VenueMemberInfo:getCupsOfWine()
	return self._drinkInfo.cupsOfWine
end

function VenueMemberInfo:setCupsOfWine(cups)
	self._drinkInfo.cupsOfWine = cups
end

function VenueMemberInfo:getBonusBit(value)
	if value == bit_and(self._bonusBit, value) then
		return 1
	else
		return 0
	end
end

function VenueMemberInfo:getBonus()
	return self._bonusBit
end

function VenueMemberInfo:setBonus(b)
	self._bonusBit = b
end

function VenueMemberInfo:setBonusBit(value)
	self._bonusBit = bit_or(self._bonusBit, value)
end

function VenueMemberInfo:drinkWine(player)
	if not self._drinkInfo.status or self._drinkInfo.status == DrinkStatus.Sober then
		local now  = os.time()
		local rand = math.random(1, 100)
		if rand <= DRUNK_RATIO then				--醉了
			self._drinkInfo.status = DrinkStatus.Drunk
			self._drinkInfo.endTime = now + DrinkDrunkCooling
		else									--没醉
			self._drinkInfo.status = DrinkStatus.Cooling
			self._drinkInfo.endTime = now + DrinkSoberCooling
		end
		self:setCupsOfWine(self:getCupsOfWine() + 1)
		self._drinkInfo.lastDrinkTime = now
		local ret = {}
		ret.cups = self:getCupsOfWine()
		if self._drinkInfo.status == DrinkStatus.Drunk then
			ret.status = 2
		elseif self._drinkInfo.status == DrinkStatus.Cooling then
			ret.status = 1
		end
		ret.endTime = self._drinkInfo.endTime
		fireProtoMessage(player:getID(), MARRIAGE_SC_WEDDING_DRINK_SUCC, 'MarriageSCWeddingDrinkSucc', ret)
		if 1 == self:getCupsOfWine() then
			self._venue:pushDrinkRank(player)
		end
		return true
	else
		local ret = {}
		ret.type = 2
		local drinkMemberInfo = {}
		if self._drinkInfo.status == DrinkStatus.Drunk then
			drinkMemberInfo.status = 2
		elseif self._drinkInfo.status == DrinkStatus.Cooling then
			drinkMemberInfo.status = 1
		end
		drinkMemberInfo.endTime = self._drinkInfo.endTime
		ret.drinkMemberInfo = drinkMemberInfo
		fireProtoMessage(player:getID(), MARRIAGE_SC_WEDDING_DRINK_FAILED, 'MarriageSCWeddingDrinkFailed', ret)
	end
	return false
end

function VenueMemberInfo:update(time)
	if self._drinkInfo.status == DrinkStatus.Drunk then
		if time >= self._drinkInfo.endTime then
			self._drinkInfo.status = DrinkStatus.Sober
		end
	elseif self._drinkInfo.status == DrinkStatus.Cooling then
		if time >= self._drinkInfo.endTime then
			self._drinkInfo.status = DrinkStatus.Sober
		end
	end
end

function VenueMemberInfo:stopDrink()
	self:setCupsOfWine(0)
	self._drinkInfo.lastDrinkTime = 0
	self._drinkInfo.status = DrinkStatus.Sober
end

function VenueMemberInfo:startDrink()
end