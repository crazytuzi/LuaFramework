function TeacherStudent:LoadSettings()
	self.tbTimeFrameSettings = LoadTabFile("Setting/TeacherStudent/TimeFrameSettings.tab", "sdd", nil,
		{"szTimeFrame", "nStuLvMin", "nTeaLvMin"})
	self.tbTargets = LoadTabFile("Setting/TeacherStudent/Targets.tab", "dsddd", "nId", 
		{"nId", "szDesc", "nNeed", "nStudentExp", "nTeacherRenown"})


	local tbKey = {"Name", "WeekFlag", "TimeFrame", "CloseTimeFrame"}
    local szKey = "ssss"
    for i = 1, 15 do
        table.insert(tbKey, "Time" .. i)
        szKey = szKey .. "s"
    end
    local tbScheduleTaskSetting = LoadTabFile("Setting/ScheduleTask.tab", szKey, "Name", tbKey)

	self.tbCustomTargets = LoadTabFile("Setting/TeacherStudent/CustomTargets.tab", "dsddssd", "nId", 
		{"nId", "szDesc", "nLevelMin", "nLevelMax", "szTimeFrameOpen", "szActiveTimeFrame", "nNeed"})
	for nId, tbSetting in pairs(self.tbCustomTargets) do
		tbSetting.nLevelMax = tbSetting.nLevelMax>0 and tbSetting.nLevelMax or 99999
		tbSetting.szTimefram = tbSetting.szTimeFrameOpen
		if tbSetting.szActiveTimeFrame and tbScheduleTaskSetting[tbSetting.szActiveTimeFrame] then
			tbSetting.szTimefram = tbScheduleTaskSetting[tbSetting.szActiveTimeFrame].TimeFrame
		end
		tbSetting.szTimeFrameOpen = nil
		tbSetting.szActiveTimeFrame = nil
	end

	self.tbGraduateGiftItemIds = LoadTabFile("Setting/TeacherStudent/GraduateGifts.tab", "d", "nTemplateId", 
		{"nTemplateId"})
end
TeacherStudent:LoadSettings()

function TeacherStudent:GetCurrentTimeFrameSettings()
	local tbRet = nil
	for _, tbSetting in ipairs(self.tbTimeFrameSettings) do
		if GetTimeFrameState(tbSetting.szTimeFrame)~=1 then
			break
		end

		tbRet = tbSetting
	end

	return tbRet
end

function TeacherStudent:GetConnectLvDiff(nVipLevel)
	local nRet = math.huge
	for _, tbSetting in ipairs(Recharge.tbVipExtSetting.TeacherStudentConnectLvDiff) do
		local nVip, nLvDiff = unpack(tbSetting)
		if nVipLevel<nVip then
			break
		end
		nRet = nLvDiff
	end
	return nRet
end

-- return: teacherReward, studentReward
function TeacherStudent:GetCustomTargetRewardsByCount(nCount)
	if nCount<=0 then
		return 0, 0
	end
	local tbRewards = self.Def.tbCustomTaskRewards[nCount]
	if not tbRewards then
		Log("[x] TeacherStudent:GetCustomTargetRewardsByCount", nCount)
		return 0, 0
	end
	return tbRewards[2], tbRewards[1]
end

function TeacherStudent:GetCustomTargetRewards(tbTargets, bFinishedOnly)
	if not bFinishedOnly then
		local nCount = Lib:CountTB(tbTargets)
		return self:GetCustomTargetRewardsByCount(nCount)
	end

	local nComplete = 0
	for nTargetId, nProgress in pairs(tbTargets) do
		local tbSetting = self:GetCustomTargetSetting(nTargetId)
		if tbSetting and nProgress>=tbSetting.nNeed then
			nComplete = nComplete+1
		end
	end
	local nTeacherReward, nStudentReward = self:GetCustomTargetRewardsByCount(nComplete)
	return nTeacherReward, nStudentReward, nComplete
end

function TeacherStudent:IsCustomTargetFinished(nTargetId, nProgress)
	local tbSetting = self:GetCustomTargetSetting(nTargetId)
	if not tbSetting then
		return false
	end
	return nProgress>=tbSetting.nNeed
end

function TeacherStudent:IsCustomTargetAvaliable(nTargetId, nStudentLv)
	local tbSetting = self:GetCustomTargetSetting(nTargetId)
	if not tbSetting then
		return false
	end

	if nStudentLv>tbSetting.nLevelMax or nStudentLv<tbSetting.nLevelMin then
		return false
	end

	local szTimefram = tbSetting.szTimefram
	if szTimefram~="" and GetTimeFrameState(szTimefram)~=1 then
		return false
	end

	return true
end

function TeacherStudent:GetCustomTargetSetting(nTargetId)
	if not nTargetId or nTargetId<1 then
		Log("[x] TeacherStudent:GetCustomTargetSetting, nTargetId invalid", tostring(nTargetId))
		return nil
	end
	return self.tbCustomTargets[nTargetId]
end

function TeacherStudent:GetTargetSetting(nTargetId)
	if not nTargetId or (nTargetId<1 or nTargetId>255) then
		Log("[x] TeacherStudent:GetTargetSetting, nTargetId invalid", tostring(nTargetId))
		return nil
	end
	return self.tbTargets[nTargetId]
end

function TeacherStudent:IsStateFinished(nState)
	local tbFinished = {
		[self.Def.tbTargetStates.NotReport] = true,
		[self.Def.tbTargetStates.Reported] = true,
		[self.Def.tbTargetStates.FinishedBefore] = true,
	}
	return tbFinished[nState]
end

function TeacherStudent:_CheckBeforeTargetAddCount()
	if not MODULE_GAMESERVER or MODULE_ZONESERVER then
		return false
	end
	local tbSetting = self:GetCurrentTimeFrameSettings()
	if not tbSetting then
		return false
	end
	return true
end

function TeacherStudent:CustomTargetAddCount(pPlayer, szType, nAdd)
	if not self:_CheckBeforeTargetAddCount() then
		return
	end

	local tbIds = self.Def.tbCustomTargetTypeToIds[szType]
	if not tbIds then
		Log("[x] TeacherStudent:CustomTargetAddCount, invalid szType", pPlayer.dwID, szType, nAdd)
		return
	end

	nAdd = nAdd or 1
	for _, nId in ipairs(tbIds) do
		if not Lib:CallBack({self._CustomTargetAddCount, self, pPlayer, nId, nAdd}) then
			Log("[x] TeacherStudent:CustomTargetAddCount, script error", pPlayer.dwID, szType, nId, nAdd)
		end
	end
end

function TeacherStudent:TargetAddCount(pPlayer, szType, nAdd)
	if not self:_CheckBeforeTargetAddCount() then
		return
	end

	local tbIds = self.Def.tbTargetTypeToIds[szType]
	if not tbIds then
		Log("[x] TeacherStudent:TargetAddCount, invalid szType", pPlayer.dwID, szType, nAdd)
		return
	end

	nAdd = nAdd or 1
	for _, nId in ipairs(tbIds) do
		if not Lib:CallBack({self._TargetAddCount, self, pPlayer, nId, nAdd}) then
			Log("[x] TeacherStudent:TargetAddCount, script error", pPlayer.dwID, szType, nId, nAdd)
		end
	end
end

function TeacherStudent:OnAddHonorTitle(pPlayer, nLevel)
	local tbLevelToTypes = {
		[3] = "JingHongTitle",
		[4] = "LingYunTitle",
		[5] = "YuKongTitle",
		[6] = "QianLongTitle",
	}
	for i=1, nLevel do
		local szType = tbLevelToTypes[i]
		if szType then
			self:TargetAddCount(pPlayer, szType, 1)
		end
	end
end

function TeacherStudent:OnEquipAllStrength(pPlayer, nLevel)
	local tbLevelToTypes = {
		[20] = "AllEquipStrength20",
		[30] = "AllEquipStrength30",
		[40] = "AllEquipStrength40",
	}
	for i=1, nLevel do
		local szType = tbLevelToTypes[i]
		if szType then
			self:TargetAddCount(pPlayer, szType, 1)
		end
	end
end

function TeacherStudent:_GetEquipQualityState(pPlayer)
	local tbAllEquipPos = {
		Item.EQUIPPOS_HEAD,
		Item.EQUIPPOS_BODY,
		Item.EQUIPPOS_BELT,
		Item.EQUIPPOS_WEAPON,
		Item.EQUIPPOS_FOOT,
		Item.EQUIPPOS_CUFF,
		Item.EQUIPPOS_AMULET,
		Item.EQUIPPOS_RING,
		Item.EQUIPPOS_NECKLACE,
		Item.EQUIPPOS_PENDANT,
	}

	local bAllCC = true
	local bAllXY = true
	for _, nPos in ipairs(tbAllEquipPos) do
		local pEquip = pPlayer.GetEquipByPos(nPos)
	    if not pEquip then
	    	bAllCC = false
	    	bAllXY = false
	    	break
	    end

	    local tbItemInfo = KItem.GetItemBaseProp(pEquip.dwTemplateId)
	    local nDetailType = tbItemInfo.nDetailType
	    if nDetailType==Item.DetailType_Normal then
	    	bAllCC = false
	    	bAllXY = false
	    	break
	    end
	    if nDetailType==Item.DetailType_Inherit then
	    	bAllXY = false
		end
	end
	return bAllCC, bAllXY
end

function TeacherStudent:OnChangeEquip(pPlayer)
	local bAllCC, bAllXY = self:_GetEquipQualityState(pPlayer)
	if bAllCC then
		self:TargetAddCount(pPlayer, "AllEquipCC", 1)
	end
	if bAllXY then
		self:TargetAddCount(pPlayer, "AllEquipXY", 1)
	end
end

function TeacherStudent:OnEquipWashed(pPlayer)
	local nFullCount = Item.tbRefinement:GetFullRefineCount(pPlayer)
	if nFullCount>=1 then
		self:TargetAddCount(pPlayer, "WashEquipFull1", 1)
	end
	if nFullCount>=10 then
		self:TargetAddCount(pPlayer, "WashEquipFull10", 1)		
	end
end