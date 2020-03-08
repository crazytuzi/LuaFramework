
local tbUi = Ui:CreateClass("KinBattle");
tbUi.MAX_COUNT = 2;
function tbUi:OnOpen()
	if me.dwKinId <= 0 then
		me.CenterMsg("没有家族，无法参与家族战");
		return 0;
	end

	RemoteServer.KinBattleCall("GetCurrentData");
end

tbUi.tbResultSprite = 
{
	[-1] = "DrawnMark";
	[0] = "FailureMark";
	[1] = "VictoryMark";
}

function tbUi:Update()
	for i = 1, self.MAX_COUNT do
		local tbCurResult = self.tbData.tbResult[i];
		for nType = 1, KinBattle.nKinBattleTypeCount do
			local nIndex = (i - 1) * KinBattle.nKinBattleTypeCount + nType;
			self.pPanel:SetActive("PlayNumber" .. nIndex, false);
			self.pPanel:SetActive("Btnjoin" .. nIndex, false);
			
			self.pPanel:SetActive("WaitingOpen" .. nIndex, not (tbCurResult and tbCurResult.szOtherKinName));
			self.pPanel:Label_SetText("WaitingOpen" .. nIndex, tbCurResult and "已结束" or "等待开启");
			
			self.pPanel:SetActive("Family" .. nIndex, (tbCurResult and tbCurResult.szOtherKinName) and true or false);
			if tbCurResult and tbCurResult.szOtherKinName then
				self.pPanel:Label_SetText("Family" .. nIndex, tbCurResult.szOtherKinName);
			end
			
			self.pPanel:SetActive("Result" .. nIndex, (tbCurResult and tbCurResult.tbInfo and tbCurResult.tbInfo[nType]) and true or false);
			if tbCurResult and tbCurResult.tbInfo and tbCurResult.tbInfo[nType] then
				self.pPanel:Sprite_SetSprite("Result" .. nIndex, self.tbResultSprite[tbCurResult.tbInfo[nType]]);
			end

			if i == (#self.tbData.tbResult + 1) and self.tbData.nState == KinBattle.STATE_PRE then
				self.pPanel:SetActive("Btnjoin" .. nIndex, true);

				self.pPanel:Label_SetText("PlayNumber" .. nIndex, string.format("%s / %s", self.tbData.tbPreMapPlayerCount[nType], KinBattle.MAX_PLAYER_COUNT));
				self.pPanel:SetActive("PlayNumber" .. nIndex, true);
				self.pPanel:SetActive("WaitingOpen" .. nIndex, false);
			end
		end

		self.pPanel:Label_SetText("TxtFamilyDeclare", KinBattle.szTips);
		self.pPanel:Label_SetText("Time" .. i, KinBattle.tbTimeTips[i]);
		self.pPanel:SetActive("Time" .. i, not (tbCurResult and tbCurResult.bIsFinish));
		self.pPanel:SetActive("FResult" .. i, tbCurResult and true or false);
		if tbCurResult then
			self.pPanel:Sprite_SetSprite("FResult" .. i, self.tbResultSprite[tbCurResult.nFinalResult]);
		end
	end

	self.pPanel:Label_SetText("levelNeed", string.format("%s级", self.tbData.nKinBattleMinLevel or 0));
	Timer:Register(Env.GAME_FPS * 3, RemoteServer.KinBattleCall, "GetCurrentData");
end

function tbUi:OnClose()
	self.tbData = nil;
end

function tbUi:OnSyncKinBattleData(tbData)
	self.tbData = tbData;
	self:Update();
end

function tbUi:OnClickJoin(nType)
	RemoteServer.KinBattleCall("TryJoinPreMap", nType);
end

function tbUi:SetLevelLimite()
	if not self.tbData.bIsKinMaster then
		me.CenterMsg("只有族长才可以设置");
		return;
	end

	local szInfo = self.pPanel:Label_GetText("levelNeed");
	local nCount = tonumber(string.match(szInfo, "^(%d+)级$")) or 0;
	local function fnOK(nNumber)
		RemoteServer.KinBattleCall("SetLevelLimite", nNumber);
	end
	Ui:OpenWindow("SetNumber", "家族战设置", "家族成员可进入等级", nCount, 0, 200, fnOK);
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SYNC_KIN_BATTLE_DATA,		self.OnSyncKinBattleData, self},
    };
    return tbRegEvent;
end

tbUi.tbOnClick = tbUi.tbOnClick or {};
for i = 1, tbUi.MAX_COUNT do
	for nType = 1, KinBattle.nKinBattleTypeCount do
		local nIndex = (i - 1) * KinBattle.nKinBattleTypeCount + nType;
		tbUi.tbOnClick["Btnjoin" .. nIndex] = function (self)
			self:OnClickJoin(nType);
		end
	end
end

tbUi.tbOnClick.BtnSet = function (self)
	self:SetLevelLimite();
end

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end

