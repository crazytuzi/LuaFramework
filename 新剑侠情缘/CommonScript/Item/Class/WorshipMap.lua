local tbItem = Item:GetClass("WorshipMap");
tbItem.PARAM_MAPID = 1

function tbItem:OnUse(it)
	if not Activity:__IsActInProcessByType("QingMingAct") then
		me.CenterMsg("活动已经结束", true)
		return 
	end

	Activity:OnPlayerEvent(me, "Act_UseWorshipMap", it);
end

function tbItem:GetTip(it)
	local szTip
	if it and it.dwId then
		local nMapTID = self:GetMapTID(it)
		local tbMapSetting = Activity.QingMingAct:GetMapSetting(nMapTID) or {}
		szTip = tbMapSetting.szTip
	end
	return szTip or "线索地图"
end

function tbItem:GetIntrol(nTemplateId, nItemId)
	local pItem = KItem.GetItemObj(nItemId or -1);
	if not pItem then
		return ""
	end
	local nMapTID = self:GetMapTID(pItem)
	local tbMapSetting = Activity.QingMingAct:GetMapSetting(nMapTID) or {}
	return  tbMapSetting.szIntrol or ""
end

function tbItem:GetDefineName(it)
	local szName = ""
	if it and it.dwId then
		local nMapTID = self:GetMapTID(it)
		local tbMapSetting = Activity.QingMingAct:GetMapSetting(nMapTID) or {}
		szName = tbMapSetting.szName
	else
		szName = Item:GetItemTemplateShowInfo(it.dwTemplateId, me.nFaction, me.nSex);
	end
	
	return szName or ""
end

function tbItem:GetMapTID(pItem)
	return pItem.GetIntValue(self.PARAM_MAPID);
end

