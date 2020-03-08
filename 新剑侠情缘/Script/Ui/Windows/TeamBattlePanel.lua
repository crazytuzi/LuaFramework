local tbUi = Ui:CreateClass("TeamBattlePanel");
tbUi.tbMarkText = {"月度赛", "季度赛", "年度赛"}
function tbUi:OnOpenEnd()
	TeamBattle.nPreLastTime = nil
	RemoteServer.TeamBattleTrySynPreTime();
	self:Update()
end

function tbUi:Update()
	self.pPanel:Label_SetText("IntroducesTxt", TeamBattle.TeamBattlePanelDescribe.Describe);
	local nLastTimes = TeamBattle:GetLastTimes(me);
	self.pPanel:Label_SetText("TxtTime", nLastTimes);

	for nIndex = 1, 4 do
		local tbReward = TeamBattle.tbReward[nIndex];
		if tbReward then
			self["itemframe"..nIndex]:SetGenericItem(tbReward);
			self["itemframe"..nIndex].fnClick = self["itemframe"..nIndex].DefaultClick;
		end

		self["itemframe"..nIndex].pPanel:SetActive("Main", tbReward and true or false);
	end
	local nMarkType = Calendar:GetMarkTypeOfPlayer("TeamBattle")
	self.pPanel:SetActive("Mark", nMarkType or false)
	if nMarkType then
		self.pPanel:Label_SetText("MarkTxt", self.tbMarkText[nMarkType] or "")
	end
	self:UpdatePreTime()
end

function tbUi:GetPreTimeDes(nTime)
	return string.format("准备时间：[FFFE0D]%s[-]", Lib:TimeDesc(nTime or 0))
end

function tbUi:UpdatePreTime()
	self.nPrepareTime = TeamBattle.nPreLastTime or 0
	self.pPanel:SetActive("PreparationTime", self.nPrepareTime > 0)
	self.pPanel:Label_SetText("PreparationTime", self:GetPreTimeDes(self.nPrepareTime))
	self:CloseTimer()
	self.nPreTimer = Timer:Register(Env.GAME_FPS, function (self) 
			if self.nPrepareTime <= 0 then
				self.nPreTimer = nil
				self.pPanel:SetActive("PreparationTime", false)
				return false
			end
			self.nPrepareTime = self.nPrepareTime - 1
			self.pPanel:Label_SetText("PreparationTime", self:GetPreTimeDes(self.nPrepareTime))
			return true
		end, self)
end

function tbUi:OnClose()
	self:CloseTimer()
end

function tbUi:CloseTimer()
	if self.nPreTimer then
		Timer:Close(self.nPreTimer)
		self.nPreTimer = nil
	end
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_TEAM_BATTLE_SYN_DATA, self.UpdatePreTime, self},
	};

	return tbRegEvent;
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

tbUi.tbOnClick.BtnSingle = function (self)
	RemoteServer.TeamBattleTryJoinPreMap(true);
end

tbUi.tbOnClick.BtnTeam = function (self)
	RemoteServer.TeamBattleTryJoinPreMap(false);
end

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end
