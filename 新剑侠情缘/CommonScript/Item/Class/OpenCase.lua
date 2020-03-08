local tbOpenCase = Item:GetClass("OpenCase");

function tbOpenCase:LoadSetting()
	local szType = "d";
	local tbTitle = {"ParamId"};
	for i = 1, 10 do
		szType = szType .. "dd";
		table.insert(tbTitle, "nKey" .. i);
		table.insert(tbTitle, "nCount" .. i);
	end

	local tbFile = LoadTabFile("Setting/Item/Other/CaseConsumeKey.tab", szType, nil, tbTitle);
	self.tbAllKeyInfo = {};
	for _, tbRow in pairs(tbFile) do
		local tbKeyInfo = {};
		for i = 1, 10 do
			if tbRow["nKey" .. i] and tbRow["nKey" .. i] > 0 and tbRow["nCount" .. i] and tbRow["nCount" .. i] > 0 then
				table.insert(tbKeyInfo, {tbRow["nKey" .. i], tbRow["nCount" .. i]});
			end
		end
		if #tbKeyInfo > 0 then
			tbKeyInfo.nCount = #tbKeyInfo;
			self.tbAllKeyInfo[tbRow["ParamId"]] = tbKeyInfo;
		end
	end
end

tbOpenCase:LoadSetting();

function tbOpenCase:OnUse(it)
	local tbKey = {};
	if self:Check(it) == 0 then
		return 0
	end
	tbKey = self.tbAllKeyInfo[it.dwTemplateId];
	local nReturn = Item:GetClass("RandomItemByLevel"):OnUse(it);

	if nReturn ~= 1 then
		return 0;
	end

	for nKey = 1, tbKey.nCount do
		me.ConsumeItemInAllPos(tbKey[nKey][1],tbKey[nKey][2], Env.LogWay_OpenCaseItem);
	end

	Achievement:AddCount(me, "TheBox_1")
	SummerGift:OnJoinAct(me, "GoldBox")
	TeacherStudent:TargetAddCount(me, "OpenGoldBox", 1)
	return 1;
end

function tbOpenCase:Check(it)
	if not self.tbAllKeyInfo then
		Log("[tbOpenCase] OnUse ERR ?? tbAllKeyInfo is nil !!", me.szName, me.dwID, it.szName, it.dwTemplateId);
		me.CenterMsg("钥匙宝箱，配置表出现错误！")
		return 0;
	end

	local tbKey = self.tbAllKeyInfo[it.dwTemplateId];
	if not tbKey then
		Log("[tbOpenCase] OnUse ERR ?? tbKey is nil !!", me.szName, me.dwID, it.szName, it.dwTemplateId);
		me.CenterMsg("很遗憾，系统检测到该道具异常，暂时无法使用!")
		return 0;
	end

	for nKey = 1, tbKey.nCount do
		local nKeyItemId = tbKey[nKey][1]
		local nCout = me.GetItemCountInAllPos(nKeyItemId);
		if nCout < tbKey[nKey][2] then
			me.CenterMsg("您的钥匙不足");
			me.CallClientScript("Shop:AutoChooseItem", nKeyItemId)
			return 0;
		end
	end
	return 1;
end