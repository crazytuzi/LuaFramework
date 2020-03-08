
function ImperialTomb:IsTombMap(nMapTemplateId)
	for _,nId in ipairs(self.MAP_TEMPLATE_ID) do
		if nId == nMapTemplateId then
			return true
		end
	end

	return false
end

function ImperialTomb:GetMapType(nMapTemplateId)
	for nType,nId in ipairs(self.MAP_TEMPLATE_ID) do
		if nId == nMapTemplateId then
			return nType
		end
	end

	return nil
end

function ImperialTomb:IsNormalMapByType(nMapType)
	return nMapType == self.MAP_TYPE.FIRST_FLOOR or 
		nMapType == self.MAP_TYPE.SECOND_FLOOR or
		nMapType == self.MAP_TYPE.THIRD_FLOOR or
		nMapType == self.MAP_TYPE.FEMALE_EMPEROR_FLOOR
end

function ImperialTomb:IsNormalMapReduceStayTimeByTemplate(nMapTemplateId)
	return nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.FIRST_FLOOR] or 
		nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.SECOND_FLOOR] or
		nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.THIRD_FLOOR]
end

function ImperialTomb:IsNormalMapByTemplate(nMapTemplateId)
	return nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.FIRST_FLOOR] or 
		nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.SECOND_FLOOR] or
		nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.THIRD_FLOOR] or
		nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.FEMALE_EMPEROR_FLOOR]
end

function ImperialTomb:IsFemaleEmperorFloorByTemplate(nMapTemplateId)
	return nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.FEMALE_EMPEROR_FLOOR]
end

function ImperialTomb:IsSecretMapByType(nMapType)
	return nMapType == self.MAP_TYPE.SECRET_ROOM_FIRST_FLOOR or 
		nMapType == self.MAP_TYPE.SECRET_ROOM_SECOND_FLOOR or
		nMapType == self.MAP_TYPE.SECRET_ROOM_THIRD_FLOOR
end


function ImperialTomb:IsSecretMapByTemplate(nMapTemplateId)
	return nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.SECRET_ROOM_FIRST_FLOOR] or 
		nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.SECRET_ROOM_SECOND_FLOOR] or
		nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.SECRET_ROOM_THIRD_FLOOR]
end

function ImperialTomb:IsEmperorMapByType(nMapType)
	return nMapType == self.MAP_TYPE.EMPEROR_ROOM
end

function ImperialTomb:IsEmperorMapByTemplate(nMapTemplateId)
	return nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.EMPEROR_ROOM]
end

function ImperialTomb:IsBossMapByType(nMapType)
	return nMapType == self.MAP_TYPE.BOSS_ROOM
end

function ImperialTomb:IsBossMapByTemplate(nMapTemplateId)
	return nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.BOSS_ROOM]
end

function ImperialTomb:IsEmperorMirrorMapByType(nMapType)
	return nMapType == self.MAP_TYPE.EMPEROR_MIRROR_ROOM
end

function ImperialTomb:IsEmperorMirrorMapByTemplate(nMapTemplateId)
	return nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.EMPEROR_MIRROR_ROOM]
end

function ImperialTomb:IsFemaleEmperorMapByType(nMapType)
	return nMapType == self.MAP_TYPE.FEMALE_EMPEROR_ROOM
end

function ImperialTomb:IsFemaleEmperorMapByTemplate(nMapTemplateId)
	return nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.FEMALE_EMPEROR_ROOM]
end

function ImperialTomb:IsFemaleEmperorBossMapByType(nMapType)
	return nMapType == self.MAP_TYPE.FEMALE_EMPEROR_BOSS_ROOM
end

function ImperialTomb:IsFemaleEmperorBossMapByTemplate(nMapTemplateId)
	return nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.FEMALE_EMPEROR_BOSS_ROOM]
end

function ImperialTomb:IsFemaleEmperorMirrorMapByType(nMapType)
	return nMapType == self.MAP_TYPE.FEMALE_EMPEROR_MIRROR_ROOM
end

function ImperialTomb:IsFemaleEmperorMirrorMapByTemplate(nMapTemplateId)
	return nMapTemplateId == self.MAP_TEMPLATE_ID[self.MAP_TYPE.FEMALE_EMPEROR_MIRROR_ROOM]
end

function ImperialTomb:GetSecretMapType(nNormalFloorType)
	return self.NORMAL_FLOOR_2_SECRET_ROOM[nNormalFloorType]
end

function ImperialTomb:GetNormalMapType(nRoomType)
	return self.SECRET_ROOM_2_NORMAL_FLOOR[nRoomType]
end

function ImperialTomb:CheckEnterTomb(pPlayer, bEmperor, bOpenFemaleEmperor)
	if GetTimeFrameState(self.OPEN_TIME_FRAME) ~= 1 then
		return false, XT("尚未开启");
	end

	local nLevelLimit = self.MIN_LEVEL
	if bOpenFemaleEmperor then
		nLevelLimit = self.FEMALE_EMPEROR_MIN_LEVEL
	end

	if pPlayer.nLevel < nLevelLimit then
		return false, XT("等级不足");
	end

	if not Fuben.tbSafeMap[pPlayer.nMapTemplateId] and Map:GetClassDesc(pPlayer.nMapTemplateId) ~= "fight" then
		return false, XT("所在地图不允许进入");
	end

	if Map:GetClassDesc(pPlayer.nMapTemplateId) == "fight" and pPlayer.nFightMode ~= 0 then
		return false, XT("不在安全区，不允许进入");
	end

	if not self:CheckEnterTime() then
		return false, string.format(XT("每天%s至%s，方可进入"), self.ALLOW_ENTER_TIME[1], self.ALLOW_ENTER_TIME[2]);
	end

	if (not bEmperor and not bOpenFemaleEmperor) and self:GetStayTime(pPlayer) <= 0 then
		return false, XT("侠士体内累积的毒素过多，再入皇陵恐有危险，还请明日再来");
	end

	if bEmperor or bOpenFemaleEmperor then
		if pPlayer.dwKinId == 0 then
			return false, XT("没有家族，无法参加活动")
		end

		return self:CheckEmperorTicket(pPlayer)
	end

	return true
end

function ImperialTomb:IsPayEmperorTicket(pPlayer)
	return self.tbEmperorTikectList and self.tbEmperorTikectList[pPlayer.dwID]
end

function ImperialTomb:CheckEmperorTicket(pPlayer)
	if self:IsPayEmperorTicket(pPlayer) then
		return true
	end

	local bOpenFemaleEmperor = false
	if MODULE_GAMESERVER then
		bOpenFemaleEmperor = self.bOpenFemaleEmperor
	else
		bOpenFemaleEmperor = Calendar:IsActivityInOpenState("ImperialTombFemaleEmperor")
	end

	local nNeedCount = self.EMPEROR_TICKET_COUNT[bOpenFemaleEmperor]

	if pPlayer.GetItemCountInAllPos(self.EMPEROR_NEED_ITEM) < nNeedCount then
		return false, string.format(self.EMPEROR_TICKET_MSG[bOpenFemaleEmperor], nNeedCount)
	end

	return true
end

function ImperialTomb:GetStayTime(pPlayer)
	if GetTimeFrameState(self.OPEN_TIME_FRAME) ~= 1 or 
		pPlayer.nLevel < self.MIN_LEVEL then
		return pPlayer.GetUserValue(self.SAVE_GROUP, self.TOTAL_STAY_TIME_KEY);
	end

	local nTime = GetTime();
	local nLastTime = pPlayer.GetUserValue(self.SAVE_GROUP, self.LAST_REFRESH_TIME_KEY);
	local nParseTodayTime = Lib:ParseTodayTime(self.EVERY_DAY_REFRESH_TIME);
	local nUpdateDay = Lib:GetLocalDay((nTime - nParseTodayTime));
	local nUpdateLastDay = 0;
	if nLastTime == 0 then
		nUpdateLastDay = nUpdateDay - 1;
	else
		nUpdateLastDay  = Lib:GetLocalDay((nLastTime - nParseTodayTime));
	end

	local nStayTime = pPlayer.GetUserValue(self.SAVE_GROUP, self.TOTAL_STAY_TIME_KEY);
	local nAddDay = math.abs(nUpdateDay - nUpdateLastDay);
	if nAddDay == 0 then
		self:RefreshStayTimeNotify(pPlayer)
		return nStayTime;
	end

	local nAddTime = 0;
	
	if me.GetItemCountInAllPos(self.EMPEROR_ADD_TIME) > 0 then
        nAddTime = nAddDay * self.EVERY_DAY_STAY_TIME_ADD;
	else
	    nAddTime = nAddDay * self.EVERY_DAY_STAY_TIME;
	end

	local nOldStayTime = nStayTime
	nStayTime = nStayTime + nAddTime;
	nStayTime = math.min(nStayTime, self.MAX_STAY_TIME);

	if MODULE_GAMESERVER then
		pPlayer.SetUserValue(self.SAVE_GROUP, self.LAST_REFRESH_TIME_KEY, nTime);
		pPlayer.SetUserValue(self.SAVE_GROUP, self.TOTAL_STAY_TIME_KEY, nStayTime);
		Log("[Info]", "ImperialTomb", "RefreshStayTime", pPlayer.dwID, pPlayer.szName, nAddTime, nOldStayTime, nStayTime);
		pPlayer.TLog("ImperialTomb", Env.LogWay_ImperialTomb_StayTime, nAddTime, nOldStayTime, nStayTime);
	end

	self:RefreshStayTimeNotify(pPlayer)
	
	return nStayTime;
end

function ImperialTomb:RefreshStayTimeNotify(pPlayer)
	local nStayTime = pPlayer.GetUserValue(self.SAVE_GROUP, self.TOTAL_STAY_TIME_KEY);
	if MODULE_GAMESERVER then
		pPlayer.CallClientScript("ImperialTomb:OnStayTimeFull", nStayTime == self.MAX_STAY_TIME)
	elseif MODULE_GAMECLIENT then
		ImperialTomb:OnStayTimeFull(nStayTime == self.MAX_STAY_TIME);
	end
end

function ImperialTomb:CheckEnterTime()
	local szBegin = self.ALLOW_ENTER_TIME[1];
	local szEnd = self.ALLOW_ENTER_TIME[2];
	local nNow = Lib:GetLocalDayTime()
	if Lib:ParseTodayTime(szBegin) < nNow and nNow < Lib:ParseTodayTime(szEnd) then
		return true
	end

	return false
end

function ImperialTomb:GetBossEnterMapByIndex(nIndex)
	local nMapType = self.MAP_TYPE.FIRST_FLOOR;
	local nNpcIndex = nIndex
	if nNpcIndex > 6 then
		--7-9个是第三层的
		nMapType = self.MAP_TYPE.THIRD_FLOOR;
		nNpcIndex = nNpcIndex - 6
	elseif nNpcIndex > 3 then
		--4-6个是第二层的
		nMapType = self.MAP_TYPE.SECOND_FLOOR;
		nNpcIndex = nNpcIndex - 3
	end

	return nMapType, nNpcIndex
end

function ImperialTomb:GetNearFemaleEmperorFloorEnterIndex(nX, nY)
	local nMinDis = nil;
	local nMinIndex = 1;
	for nIndex,tbPos in pairs(self.FEMALE_EMPEROR_FLOOR_ENTER_POS) do
		local nDis = Lib:GetDistance(nX, nY, tbPos[1], tbPos[2])
		if not nMinDis or nDis < nMinDis then
			nMinDis = nDis
			nMinIndex = nIndex
		end
	end

	return nMinIndex
end