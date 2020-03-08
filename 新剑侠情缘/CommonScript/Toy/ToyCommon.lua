function Toy:LoadSetting()
	self.tbSetting = LoadTabFile("Setting/Toy/Toy.tab", "dssssssssd", "nId",
		{"nId", "szName", "szClass", "szIcon", "szAtlas", "szFrameColor", "szNameColor", "szDesc", "szOutput", "nSort"})
	self.tbClass2Id = {}
	for nId, tb in pairs(self.tbSetting) do
		self.tbClass2Id[tb.szClass] = nId
	end
end
Toy:LoadSetting()

function Toy:GetSetting(nId)
	return self.tbSetting[nId]
end

function Toy:GetId(szClass)
	return self.tbClass2Id[szClass]
end

function Toy:GetClass(nId)
	local tbSetting = self:GetSetting(nId)
	if not tbSetting then
		return ""
	end
	return tbSetting.szClass or ""
end

function Toy:IsUnlocked(pPlayer, nId)
	local szClass = self:GetClass(nId)
	local nItemId = self.Def.tbMustHaveItem[szClass]
	if nItemId and nItemId > 0 then
		return pPlayer.GetItemCountInBags(nItemId) > 0
	else
		return pPlayer.GetUserValue(self.Def.nUnlockSaveGrp, nId) > 0
	end
end

function Toy:IsMapValid(pPlayer)
	return Lib:IsInArray(self.Def.tbValidMaps, pPlayer.nMapTemplateId)
end

function Toy:CanUse(pPlayer)
	--return self:IsMapValid(pPlayer) and GetTimeFrameState(self.Def.szOpenTimeframe) == 1
	return false
end

function Toy:GetUseCount(pPlayer, nId)
	return pPlayer.GetUserValue(self.Def.nUseCountSaveGrp, nId) or 0
end

function Toy:IsFree()
	return true
end

