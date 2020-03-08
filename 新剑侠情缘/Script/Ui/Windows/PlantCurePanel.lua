-- 养护界面

local tbUi = Ui:CreateClass("PlantCurePanel");
tbUi.tbOnClick = tbUi.tbOnClick or {};

for i = 1, 3 do
	tbUi.tbOnClick["Btn" .. i] = function ()
		local tbLand = HousePlant:GetLand();
		if not tbLand then
			me.CenterMsg("未摆放苗圃");
			return;
		end

		if tbLand.nState ~= i then
			local szMsg = HousePlant.tbSickStateSetting[i].szFailedMsg;
			me.CenterMsg(szMsg);
			return;
		end

		if me.dwID ~= House.dwOwnerId and not FriendShip:IsFriend(me.dwID, House.dwOwnerId) then
			me.CenterMsg("只有好友才能协助养护哦", 1);
			FriendShip:OpenAddFriendUI({ dwID = House.dwOwnerId, szName = House.szName });
			return;
		end

		Ui:OpenWindow("PlantCureConfirmPanel", i);	
	end
end

tbUi.tbOnClick.Btn4 = function (self)
	if not House:IsInOwnHouse(me) then
		me.CenterMsg("只有家园主人才能收成哦");
		return;
	end
	RemoteServer.Crop();
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnAssist = function (self)
	Ui:OpenWindow("PlantHelpCurePanel");
	HousePlant:ClearHelpCureRedPoint();
end

function tbUi:OnOpen()
	self:Refresh();

	self:CheckPlantCure();
end

function tbUi:OnClose()
	self:CloseAllTimer();

	if self.nCheckPlantCureTimerId then
		Timer:Close(self.nCheckPlantCureTimerId);
		self.nCheckPlantCureTimerId = nil;
	end
end

function tbUi:CloseAllTimer()
	if self.nRipenTimerId then
		Timer:Close(self.nRipenTimerId);
		self.nRipenTimerId = nil;
	end
end

function tbUi:Refresh()
	self:CloseAllTimer();

	self.pPanel:Label_SetText("AssistTime", string.format("[92D2FF]剩余协助养护次数：[-]%d", DegreeCtrl:GetDegree(me, "PlantHelpCure")));
	
	local tbLand = HousePlant:GetLand();
	if not tbLand or tbLand.nState == HousePlant.STATE_NULL then
		return;
	end

	local bCanCrop = tbLand.nState == HousePlant.STATE_RIPEN;
	for i = 1, 3 do
		self.pPanel:SetActive("Btn" .. i, not bCanCrop);
	end
	self.pPanel:SetActive("Btn4", bCanCrop);

	local tbSickSetting = HousePlant.tbSickStateSetting[tbLand.nState];
	local szState = string.format("[92D2FF]植物状态：[-]%s", tbSickSetting and string.format("[FF0000]%s[-]", tbSickSetting.szDesc) or "健康");
	self.pPanel:Label_SetText("State", szState);

	local nLeftTime = bCanCrop and 0 or math.max(0, tbLand.nRipenTime - GetTime());
	self:RefreshTime(nLeftTime);
	if nLeftTime > 0 then
		self.nRipenTimerId = Timer:Register(Env.GAME_FPS, function ()
			nLeftTime = nLeftTime - 1;
			self:RefreshTime(nLeftTime);

			if nLeftTime <= 0 then
				self.nRipenTimerId = nil;
				return;
			end

			return true;
		end);
	end

	local tbRecordSet = tbLand.tbRecord;
	local fnSetRecord = function (tbRecord, nIndex)
		local tbInfo = tbRecordSet[nIndex];
		local nReduceTime = tbInfo.bCost and HousePlant.CURE_TIME_COST or HousePlant.CURE_TIME_NORMAL;
		local szTool = "**";
		local tbStateSetting = HousePlant.tbSickStateSetting[tbInfo.nState];
		if tbStateSetting then
			szTool = tbInfo.bCost and tbStateSetting.szCureToolCost or tbStateSetting.szCureTool;
		end

		local szMsg = string.format("[92D2FF][C8FF00]%s[-]使用了[%s]%s[-]，树丛的成熟时间加快了[C8FF00]%s[-][-]", tbInfo.szName, tbInfo.bCost and "FFFE0D" or "92D2FF", szTool, Lib:TimeFullDesc(nReduceTime));
		tbRecord.pPanel:Label_SetText("Main", szMsg);
	end
	self.ScrollView:Update(#tbRecordSet, fnSetRecord);
	self.ScrollView:GoBottom();
end

function tbUi:RefreshTime(nLeftTime)
	local szTime = "[92D2FF]成熟剩余：[-]";
	if nLeftTime <= 0 then
		szTime = szTime .. "[00FF00]可收成[-]";
		self.pPanel:Label_SetText("State", "[92D2FF]植物状态：[-]健康");
		for i = 1, 3 do
			self.pPanel:SetActive("Btn" .. i, false);
		end
		self.pPanel:SetActive("Btn4", true);
	else
		szTime = szTime .. Lib:TimeDesc6(nLeftTime);
	end
	self.pPanel:Label_SetText("Time", szTime);
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnLeaveMap()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:CheckPlantCure()
	RemoteServer.CheckPlayerCanCure();
	self.nCheckPlantCureTimerId = Timer:Register(Env.GAME_FPS * 5, function ()
		if DegreeCtrl:GetDegree(me, "PlantHelpCure") > 0 then
			if Ui:WindowVisible("PlantHelpCurePanel") ~= 1 then
				RemoteServer.CheckPlayerCanCure();
			end
			return true;
		end	
		HousePlant:ClearHelpCureRedPoint();
		self.nCheckPlantCureTimerId = nil;
	end)
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_PLANT_CURE_FINISHED, function () self:Refresh() end },
		{ UiNotify.emNOTIFY_MAP_LEAVE,	function () self:OnLeaveMap()  end },
	};
	return tbRegEvent;
end
