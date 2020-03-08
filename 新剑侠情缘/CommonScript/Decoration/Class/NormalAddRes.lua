local tbNormalAddRes = Decoration:GetClass("NormalAddRes");

tbNormalAddRes.nMax_Act_PlayerCount = 5;

function tbNormalAddRes:LoadNormalAddResSetting()
	self.tbAllTypeActSetting = {};
	local szType = "dddd";
	local tbTitle = {"nDecorationId", "nType", "nNpcResAttribId", "nMaxPlayerCount"};
	for i = 1, self.nMax_Act_PlayerCount do
		szType = szType .. "ssssssdddsss";
		table.insert(tbTitle, "nPX" .. i);
		table.insert(tbTitle, "nPY" .. i);
		table.insert(tbTitle, "nPZ" .. i);

		table.insert(tbTitle, "nRX" .. i);
		table.insert(tbTitle, "nRY" .. i);
		table.insert(tbTitle, "nRZ" .. i);

		table.insert(tbTitle, "nExtResId" .. i);
		table.insert(tbTitle, "nExtResNpcResAttribId" .. i);
		table.insert(tbTitle, "nNpcResAttribId" .. i);

		table.insert(tbTitle, "nExtPX" .. i);
		table.insert(tbTitle, "nExtPY" .. i);
		table.insert(tbTitle, "nExtPZ" .. i);
	end

	for i = 1, Faction.MAX_FACTION_COUNT do
		szType = szType .. "dd";
		table.insert(tbTitle, tostring(i));
		table.insert(tbTitle, tostring(i * 100));
	end

	local tbFile = LoadTabFile("Setting/Decoration/DecorationNormalAddRes.tab", szType, nil, tbTitle);
	for _, tbRow in pairs(tbFile) do
		assert(tbRow.nMaxPlayerCount > 0 and tbRow.nMaxPlayerCount <= self.nMax_Act_PlayerCount);

		local tbInfo = {tbFactionRes = {}, tbPlayerSetting = {}};
		for i = 1, Faction.MAX_FACTION_COUNT do
			local nResId = tbRow[tostring(i)] or -1;
			local nResId2 = tbRow[tostring(i * 100)] or -1;

			if not Decoration.tbNormalRes[nResId] then
				Log(string.format("Setting/Decoration/DecorationNormalAddRes.tab error !! nFaction:%s nResId:%s", i, nResId));
			end

			if not Decoration.tbNormalRes[nResId2] then
				Log(string.format("Setting/Decoration/DecorationNormalAddRes.tab error !! nFaction:%s nResId:%s", i * 100, nResId2));
			end

			tbInfo.tbFactionRes[i] = nResId;
			tbInfo.tbFactionRes[i * 100] = nResId2;
		end

		for i = 1, tbRow.nMaxPlayerCount do
			local szExtPosInfo = tbRow["ExtPosInfo" .. i];
			local nPX = tonumber(tbRow["nPX" .. i]) or 0;
			local nPY = tonumber(tbRow["nPY" .. i]) or 0;
			local nPZ = tonumber(tbRow["nPZ" .. i]) or 0;

			local nRX = tonumber(tbRow["nRX" .. i]) or 0;
			local nRY = tonumber(tbRow["nRY" .. i]) or 0;
			local nRZ = tonumber(tbRow["nRZ" .. i]) or 0;

			local nExtPX = tonumber(tbRow["nExtPX" .. i]) or 0;
			local nExtPZ = tonumber(tbRow["nExtPZ" .. i]) or 0;
			local nExtPY = tonumber(tbRow["nExtPY" .. i]) or 0;

			tbInfo.tbPlayerSetting[i] =
			{
				nPX = nPX,
				nPY = nPY,
				nPZ = nPZ,

				nRX = nRX,
				nRY = nRY,
				nRZ = nRZ,

				nExtPX = nExtPX,
				nExtPY = nExtPY,
				nExtPZ = nExtPZ,

				nExtResId = tbRow["nExtResId" .. i],
				nExtResNpcResAttribId = tbRow["nExtResNpcResAttribId" .. i],
				nNpcResAttribId = tbRow["nNpcResAttribId" .. i] or 0,
			};
		end

		self.tbAllTypeActSetting[tbRow.nDecorationId] = self.tbAllTypeActSetting[tbRow.nDecorationId] or {};
		self.tbAllTypeActSetting[tbRow.nDecorationId][tbRow.nType] = tbInfo;
	end
end
tbNormalAddRes:LoadNormalAddResSetting();

function tbNormalAddRes:GetActSetting(nTemplateId, nType)
	nType = nType or 0;
	if not self.tbAllTypeActSetting[nTemplateId] then
		return;
	end

	return self.tbAllTypeActSetting[nTemplateId][nType];
end

function tbNormalAddRes:OnCreateClientRep(tbRepInfo, pRep)
	if not tbRepInfo.tbParam or Lib:CountTB(tbRepInfo.tbParam.tbPlayerInfo or {}) < 1 then
		return;
	end

	local tbActSetting = self:GetActSetting(tbRepInfo.nTemplateId, tbRepInfo.tbParam.nType or 0);
	if not tbActSetting then
		return;
	end

	local tbPlayerInfo = Decoration:GetSortNpcInfo(tbRepInfo.tbParam.tbPlayerInfo or {});
	local nUseCount = 0;
	for _, nFaction in ipairs(tbPlayerInfo) do
		nUseCount = nUseCount + 1;
		if nUseCount <= #tbActSetting.tbPlayerSetting then
			local nResId = tbActSetting.tbFactionRes[nFaction];
			local szRes = Decoration.tbNormalRes[nResId].szResPath;
			local tbPlayerSetting = tbActSetting.tbPlayerSetting[nUseCount];
			pRep:AddEffectRes(szRes, tbPlayerSetting.nNpcResAttribId or 0, tostring(nUseCount));
			pRep:SetEffectPosition(szRes .. nUseCount, tbPlayerSetting.nPX, tbPlayerSetting.nPY, tbPlayerSetting.nPZ);
			pRep:SetEffectRotation(szRes .. nUseCount, tbPlayerSetting.nRX, tbPlayerSetting.nRY, tbPlayerSetting.nRZ);
		end
	end

	local nPlayerCount = Lib:CountTB(tbRepInfo.tbParam.tbPlayerInfo);
	local tbPlayerSetting = tbActSetting.tbPlayerSetting[nPlayerCount];
	if tbPlayerSetting and Decoration.tbNormalRes[tbPlayerSetting.nExtResId] then
		local szExtRes = Decoration.tbNormalRes[tbPlayerSetting.nExtResId].szResPath;
		pRep:AddEffectRes(szExtRes, tbPlayerSetting.nExtResNpcResAttribId or 0);
		pRep:SetEffectPosition(szExtRes, tbPlayerSetting.nExtPX, tbPlayerSetting.nExtPY, tbPlayerSetting.nExtPZ);
		pRep:SetEffectRotation(szExtRes, 0, 0, 0);
	end
end

function tbNormalAddRes:OnRepObjSimpleTap(nId, nRepId, tbRepInfo)
	local tbTemplate = Decoration.tbAllTemplate[tbRepInfo.nTemplateId];
	local fnOnRepObjSimpleTap = self["OnRepObjSimpleTap_" .. tbTemplate.szSubType] or self.OnRepObjSimpleTap_Default;
	fnOnRepObjSimpleTap(self, nId, nRepId, tbRepInfo, tbTemplate);
end

function tbNormalAddRes:OnRepObjSimpleTap_Default(nId, nRepId, tbRepInfo, tbTemplate)
	local function fnUse ()
		Decoration:EnterPlayerActState(me, nId, me.nFaction * (me.nSex == 1 and 1 or 100), 0);
	end

	Ui:OpenWindow("FurnitureOptUi", nRepId, {{"使用", fnUse}});
end
