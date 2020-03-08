local tbItem = Item:GetClass("RandomItemByVersion");

function tbItem:OnUse(it)
	local nParamId = KItem.GetItemExtParam(it.dwTemplateId, 1);
	local nRandomItemKindId = self.tbAllVersionInfo[nParamId]
	if not nRandomItemKindId then
		Log("[RandomItemByVersion] Error", me.dwID, me.szName, it.dwTemplateId, nParamId, nRandomItemKindId)
		return
	end
	local nRet, szMsg, tbAllAward = Item:GetClass("RandomItem"):GetRandItemAward(me, nRandomItemKindId, it.szName, false, it.dwTemplateId);
	if szMsg then
		me.CenterMsg(szMsg)
	end

	Log("[Item] RandomItemByVersion OnUse", it.dwTemplateId, it.szName, me.szName, me.szAccount, me.dwID, nRet);
	return nRet, tbAllAward;
end

function tbItem:LoadSetting()
	local szType = "dddddddd";
	local tbTitle = {"ParamId", "version_tx", "version_vn", "version_hk", "version_xm", "version_en", "version_kor", "version_th"};
	local tbFile = LoadTabFile("Setting/Item/RandomByVersion.tab", szType, nil, tbTitle);
	self.tbAllVersionInfo = {};
	for _, tbRow in pairs(tbFile) do
		self.tbAllVersionInfo[tbRow.ParamId] = self:CheckVersion(tbRow)
	end
end

function tbItem:CheckVersion(tbInfo)
	if tbInfo.version_tx > 0 and version_tx then
		return tbInfo.version_tx
	elseif tbInfo.version_vn > 0 and version_vn then
		return tbInfo.version_vn
	elseif tbInfo.version_hk > 0 and version_hk then
		return tbInfo.version_hk
	elseif tbInfo.version_xm > 0 and version_xm then
		return tbInfo.version_xm
	elseif tbInfo.version_en > 0 and version_en then
		return tbInfo.version_en
	elseif tbInfo.version_kor > 0 and version_kor then
		return tbInfo.version_kor
	elseif tbInfo.version_th > 0 and version_th then
		return tbInfo.version_th
	end
end

function tbItem:OnServerStart()
	self:LoadSetting()
end