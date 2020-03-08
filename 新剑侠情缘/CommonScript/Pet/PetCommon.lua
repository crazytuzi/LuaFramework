function Pet:CheckFeedCount(pPlayer)
	local nLastTime = pPlayer.GetUserValue(self.Def.SaveGrp, self.Def.SaveKeyTime)
	if Lib:IsDiffDay(0, nLastTime, GetTime()) then
		return true, 0
	end
	local nCount = pPlayer.GetUserValue(self.Def.SaveGrp, self.Def.SaveKeyCount)
	return nCount<self.Def.FeedCfg.nDailyLimit, nCount
end

function Pet:CheckNameAvailable(szPetName)
	local nLen = Lib:Utf8Len(szPetName)
	if nLen>self.Def.nNameLenMax or nLen<self.Def.nNameLenMin then
		return false, string.format("宠物名%d-%d字符", self.Def.nNameLenMin, self.Def.nNameLenMax)
	end

	if not CheckNameAvailable(szPetName) then
		return false, "含有非法字符，请修改后重试"
	end
	return true
end