
local tbDoCmd = Decoration:GetClass("DoCmd");

tbDoCmd.MAX_CMD_COUNT = 5;
tbDoCmd.tbCmd = {
	ChangeShader = "ChangeShader",				--ChangeShader|15|cj_luoyang_dengzhu02|FTGame/CommonNpc
	PlayAnimation = "PlayAnimation",			--PlayAnimation|0|a02|4|1|1
	PlaySound = "PlaySound",					--PlaySound|0|110|100
	SetActive = "SetActive",					--SetActive|0|light|1
	DoNothing	= "DoNothing",					--DoNothing|0|0
	PlayHelpVoice = "PlayHelpVoice", 			--PlayHelpVoice|0|Setting/NpcVoice/Furniture/KongHou02.voice|2600
	BlackMsg = "BlackMsg"; 						--BlackMsg|0|好样的
}

tbDoCmd.tbCmdSaveType =
{
	ChangeShader = true;
	SetActive = true;
}

function tbDoCmd:LoadDoCmdSetting()
	local szType = "dsd";
	local tbTitle = {"nDecorationId", "nTypeId", "bSaveType"};
	for i = 1, self.MAX_CMD_COUNT do
		szType = szType .. "s";
		table.insert(tbTitle, "szCmd" .. i);
	end

	self.tbAllCmdSetting = {};
	local tbFile = LoadTabFile("Setting/Decoration/DecorationDoCmd.tab", szType, nil, tbTitle);
	for _, tbRow in pairs(tbFile) do
		tbRow.nTypeId = tonumber(tbRow.nTypeId) or 0;
		self.tbAllCmdSetting[tbRow.nDecorationId] = self.tbAllCmdSetting[tbRow.nDecorationId] or {};
		assert(not self.tbAllCmdSetting[tbRow.nDecorationId][tbRow.nTypeId], string.format("Setting/Decoration/DecorationDoCmd.tab DecorationId:%s, nTypeId:%s, nTypeId repeated !!!", tbRow.nDecorationId, tbRow.nTypeId));

		local tbCmdInfo = {};
		for i = 1, self.MAX_CMD_COUNT do
			local szCmd = tbRow["szCmd" .. i];
			if szCmd and szCmd ~= "" then
				local tbCmd = Lib:SplitStr(szCmd, "|");
				for k, v in pairs(tbCmd) do
					tbCmd[k] = tonumber(v) or v;
				end

				assert(self.tbCmd[tbCmd[1]] and tbCmd[2] and tbCmd[2] >= 0, string.format("Setting/Decoration/DecorationDoCmd.tab DecorationId:%s, nTypeId:%s, Error Cmd:%s !!!", tbRow.nDecorationId, tbRow.nTypeId, szCmd));

				table.insert(tbCmdInfo, tbCmd);
			end
		end
		if #tbCmdInfo > 0 then
			table.sort(tbCmdInfo, function (a, b) return a[2] < b[2]; end)
		end
		for i = #tbCmdInfo, 2, -1 do
			local nLastTime = tbCmdInfo[i - 1][2];
			tbCmdInfo[i][2] = tbCmdInfo[i][2] - nLastTime;
		end

		if #tbCmdInfo > 0 then
			self.tbAllCmdSetting[tbRow.nDecorationId][tbRow.nTypeId] = {};
			self.tbAllCmdSetting[tbRow.nDecorationId][tbRow.nTypeId].tbCmdInfo = tbCmdInfo;
			self.tbAllCmdSetting[tbRow.nDecorationId][tbRow.nTypeId].bSaveType = tbRow.bSaveType == 1 and true or false;
		end
	end
end
tbDoCmd:LoadDoCmdSetting();

function tbDoCmd:OnClientCmd(pPlayer, nId, szType, ...)
	if szType == "ServerDoCmd" then
		local nTypeId = ({...})[1];
		self:ServerDoCmd(pPlayer, nId, nTypeId);
	end
end

function tbDoCmd:ServerDoCmd(pPlayer, nId, nTypeId)
	local tbDecoration = Decoration.tbAllDecoration[nId];
	if not tbDecoration then
		return;
	end

	if pPlayer and tbDecoration.nMapId ~= pPlayer.nMapId then
		return;
	end

	local tbCmdSetting = (tbDoCmd.tbAllCmdSetting[tbDecoration.nTemplateId] or {})[nTypeId];
	if not tbCmdSetting then
		return;
	end

	local tbTemplate = Decoration.tbAllTemplate[tbDecoration.nTemplateId];
	if not tbTemplate then
		return;
	end

	if tbTemplate.szSubType == "GuiZi" and nTypeId == 0 then
		local bOK, nOtherPlayerId = Decoration:ExitPlayerActStateByDecorationId(nId, true);
		if bOK and pPlayer then
			nOtherPlayerId = nOtherPlayerId or 0;
			pPlayer.SendBlackBoardMsg(nOtherPlayerId == pPlayer.dwID and "嗨呀！竟无人能找到我。" or "咦！柜子里怎么躲了个人？");
		end
	end

	local tbParam = Lib:CopyTB(tbDecoration.tbParam or {});
	tbParam.nCmdType = tbCmdSetting.bSaveType and nTypeId or nil;

	if tbParam.nCmdType ~= (tbDecoration.tbParam or {}).nCmdType then
		Decoration:ChangeParam(nId, tbParam, true);
	end
	KPlayer.MapBoardcastScriptByFuncName(tbDecoration.nMapId, "Decoration:DoCmd", nId, nTypeId, {});
end

function tbDoCmd:SetDoCmdState(nId, nTypeId)
	local tbRepInfo = Decoration.tbClientDecoration[nId];
	if not tbRepInfo then
		Log("[Decoration] SetDoCmdState Fail !! tbRepInfo is nil !!");
		return;
	end

	local tbCmdInfo = ((self.tbAllCmdSetting[tbRepInfo.nTemplateId] or {})[nTypeId] or {}).tbCmdInfo;
	if not tbCmdInfo then
		Log("[Decoration] SetDoCmdState Fail !!!", tbRepInfo.nTemplateId, nTypeId);
		return;
	end

	for _, tbCmd in pairs(tbCmdInfo) do
		if self.tbCmdSaveType[tbCmd[1]] then
			self[tbCmd[1]](self, nId, {}, unpack(tbCmd, 3));
		end
	end
end

function Decoration:DoCmd(nId, nTypeId, tbParam)
	local tbRepInfo = Decoration.tbClientDecoration[nId];
	if not tbRepInfo then
		return;
	end

	local tbCmdSetting = (tbDoCmd.tbAllCmdSetting[tbRepInfo.nTemplateId] or {})[nTypeId];
	if not tbCmdSetting then
		Log("[Decoration] DoCmd Fail !!!", tbRepInfo.nTemplateId, nTypeId);
		return;
	end

	local tbCmdInfo = tbCmdSetting.tbCmdInfo;

	tbRepInfo.tbParam = tbRepInfo.tbParam or {};
	tbRepInfo.tbParam.nCmdType = tbCmdSetting.bSaveType and nTypeId or nil;

	tbDoCmd.tbAllCmdTimer = tbDoCmd.tbAllCmdTimer or {};
	if tbDoCmd.tbAllCmdTimer[nId] then
		tbDoCmd:StopCmd(nId);
	end

	local fnDoCmd = tbDoCmd:GetDoCmdFunc(nId, tbCmdInfo, tbParam);
	tbDoCmd.tbAllCmdTimer[nId] = Timer:Register(tbCmdInfo[1][2] + 1, fnDoCmd, fnDoCmd);
	UiNotify.OnNotify(UiNotify.emNOTIFY_DECORATION_CHANGE, nId);
end

function tbDoCmd:GetDoCmdFunc(nId, tbCmdInfo, tbParam)
	local nIdx = 0;
	return function (fnDoCmd)
		nIdx = nIdx + 1;

		self.tbAllCmdTimer[nId] = nil;

		local tbCmd = tbCmdInfo[nIdx];
		if not tbCmd then
			return;
		end

		self[tbCmd[1]](self, nId, tbParam, unpack(tbCmd, 3));

		local nNextIdx = nil;
		for i = nIdx + 1, #tbCmdInfo do
			if tbCmdInfo[i][2] > 0 then
				nNextIdx = i;
				break;
			end

			tbCmd = tbCmdInfo[i];
			self[tbCmd[1]](self, nId, tbParam, unpack(tbCmd, 3));
		end

		if nNextIdx then
			nIdx = nNextIdx - 1;
			self.tbAllCmdTimer[nId] = Timer:Register(tbCmdInfo[nIdx + 1][2], fnDoCmd, fnDoCmd);
		end
	end
end

function tbDoCmd:StopCmd(nId)

end

function tbDoCmd:DoNothing()

end

function tbDoCmd:SetActive(nId, tbParam, szName, nActive)
	local pRep = Decoration:GetDecorationRepById(nId);
	if not pRep then
		return;
	end

	pRep:SetActive(szName, nActive == 1);
end

function tbDoCmd:ChangeShader(nId, tbParam, szName, szShader)
	local pRep = Decoration:GetDecorationRepById(nId);
	if not pRep then
		return;
	end

	pRep:ChangeShader(szName, szShader);
end

function tbDoCmd:PlayAnimation(nId, tbParam, szAni, nTime, nLoop, nSpeed)
	local pRep = Decoration:GetDecorationRepById(nId);
	if not pRep then
		return;
	end

	if not nTime or nTime <= 0 then
		return;
	end

	local bLoop = (nLoop or 0) == 1;

	nSpeed = nSpeed or 1;

	self.tbPlayAnimationTimer = self.tbPlayAnimationTimer or {};
	if self.tbPlayAnimationTimer[nId] then
		return;
	end

	pRep:PlayAnimation(szAni, 0.5, false, nSpeed);

	self.tbPlayAnimationTimer[nId] = Timer:Register(math.max(nTime * Env.GAME_FPS, 1), function ()
		self:StopAnimation(nId);
	end);
end

function tbDoCmd:StopAnimation(nId)
	self.tbPlayAnimationTimer[nId] = nil;
	local pRep = Decoration:GetDecorationRepById(nId);
	if not pRep then
		return;
	end

	self.tbPlayAnimationTimer[nId] = -1;

	pRep:PlayAnimation("a01", 0.05, true, 1);
	Timer:Register(math.ceil(Env.GAME_FPS * 2.5), function ()
		if self.tbPlayAnimationTimer[nId] == -1 then
			self.tbPlayAnimationTimer[nId] = nil;
		end
	end)
end

function tbDoCmd:PlaySound(nId, tbParam, nSoundId, nRange)
	local tbDecoration = Decoration.tbClientDecoration[nId];
	if not tbDecoration then
		return;
	end

	local m, x, y = me.GetWorldPos();

	x = tbDecoration.nX - x;
	y = tbDecoration.nY - y;

	local nRangeSqr = x * x + y * y;
	if nRangeSqr > nRange * nRange then
		return;
	end

	Ui:PlayDialogueSound(nSoundId);
end

function tbDoCmd:PlayHelpVoice(nId, tbParam, szVoicePath, nRange)
	local tbDecoration = Decoration.tbClientDecoration[nId];
	if not tbDecoration then
		return;
	end
	local m, x, y = me.GetWorldPos();

	x = tbDecoration.nX - x;
	y = tbDecoration.nY - y;

	local nRangeSqr = x * x + y * y;
	if nRangeSqr > nRange * nRange then
		return;
	end
	ChatMgr:PlayNpcVoice(szVoicePath)
end

function tbDoCmd:BlackMsg(nId, tbParam, szMsg)
	if not szMsg then
		return 
	end
	me.SendBlackBoardMsg(string.format(szMsg));
end

function tbDoCmd:OnLoadEffectFinish(tbRepInfo, bIsMainRes, szEffectName)
	if not bIsMainRes then
		return;
	end

	if tbRepInfo.tbParam and tbRepInfo.tbParam.nCmdType then
		for nId, tb in pairs(Decoration.tbClientDecoration) do
			if tb == tbRepInfo then
				self:SetDoCmdState(nId, tbRepInfo.tbParam.nCmdType);
			end
		end
	end
end

function tbDoCmd:OnRepObjSimpleTap(nId, nRepId, tbRepInfo)
	local tbTemplate = Decoration.tbAllTemplate[tbRepInfo.nTemplateId];
	if not tbTemplate then
		return;
	end

	local fnOnRepObjSimpleTap = self["OnRepObjSimpleTap_" .. tbTemplate.szSubType] or self.OnRepObjSimpleTap_Default;

	fnOnRepObjSimpleTap(self, nId, nRepId, tbRepInfo, tbTemplate);
end

function tbDoCmd:OnRepObjSimpleTap_Default(nId, nRepId, tbRepInfo, tbTemplate)
	local nTypeId = 0;
	if tbRepInfo.tbParam and tbRepInfo.tbParam.nCmdType == 0 then
		nTypeId = -1;
	end
	RemoteServer.OnClientCmd(nId, "ServerDoCmd", nTypeId);
end
