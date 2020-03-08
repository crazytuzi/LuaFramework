function KinEncounter:_CommonCheck()
	if self.bForceClose then
		return false
	end
	if not MODULE_ZONESERVER then
		return Activity:__IsActInProcessByType("KinEncounterAct")
	end
	return true
end

function KinEncounter:IsRunning()
	if not self:_CommonCheck() then
		return false
	end

	local nNow = GetTime()
	self.nStartTime = self.nStartTime or 0
	return nNow >= self.nStartTime and nNow <= (self.nStartTime + self.Def.nPrepareTime + self.Def.nFightTime)
end

function KinEncounter:IsPreparing()
	if not self:_CommonCheck() then
		return false
	end

	local nNow = GetTime()
	self.nStartTime = self.nStartTime or 0
	return nNow >= self.nStartTime and nNow < (self.nStartTime + self.Def.nPrepareTime)
end

function KinEncounter:IsOpenToday()
	if not self:_CommonCheck() then
		return false
	end

	local nNow = GetTime()
	for _, nOpenDate in ipairs(self.Def.tbOpenDates) do
		if not Lib:IsDiffDay(0, nNow, nOpenDate) then
			return true
		end
	end
	return false
end

function KinEncounter:WillOpen(nTime)
	if not self:_CommonCheck() then
		return false
	end

	for _, nOpenDate in ipairs(self.Def.tbOpenDates) do
		if not Lib:IsDiffDay(0, nTime, nOpenDate) then
			return true
		end
	end
	return false
end