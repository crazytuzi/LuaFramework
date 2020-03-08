-- 养护界面

local tbUi = Ui:CreateClass("PlantStatePanel");

function tbUi:OnOpen(nRepId)
	local pRep = Ui.Effect.GetObjRepresent(nRepId);
	if not pRep then
		return 0;
	end

	self.pPanel:ObjRep_SetFollow("Main", nRepId);
	pRep:SetUiLogicPos(0, 50, 0);

	self.nTimerId = nil;
	self.nGapTime = nil;
	self:Refresh();
end

function tbUi:Refresh()	
	local tbLand = HousePlant:GetLand();
	if not tbLand then
		Ui:CloseWindow(self.UI_NAME);
		return;
	end

	local szState = nil;
	self.pPanel:SetActive("Tip", false);
	self.pPanel:SetActive("Name", false);
	self.pPanel:SetActive("Time", false);
	self.pPanel:SetActive("Bar", false);

	if tbLand.nState == HousePlant.STATE_NULL then
		if House:IsInOwnHouse(me) then
			szState = "Plant4";
		end
		self:CloseTimer();
	elseif tbLand.nState == HousePlant.STATE_RIPEN then
		if House:IsInOwnHouse(me) then
			szState = "Plant5";
		end
		self:CloseTimer();
	else
		-- 策划需求，暂时不显示
		-- local nGapTime = self:GetGapTime(tbLand.nRipenTime);
		-- self:ResetTimer(nGapTime);

		-- self.pPanel:Label_SetText("Name", "树丛");
		-- self:RefreshTime(tbLand.nRipenTime);
		
		-- self.pPanel:SetActive("Name", true);
		-- self.pPanel:SetActive("Time", true);
		-- self.pPanel:SetActive("Bar", true);

		if HousePlant.tbSickStateSetting[tbLand.nState] then
			szState = "Plant6";
		end
	end
	
	if szState then
		self.pPanel:SetActive("Tip", true);
		self.pPanel:Sprite_SetSprite("Tip", szState);
	end
end

function tbUi:OnClose()
	self.nGapTime = nil;
	self:CloseTimer();
end

function tbUi:CloseTimer()
	if self.nTimerId then
		Timer:Close(self.nTimerId);
		self.nTimerId = nil;
	end
end

function tbUi:ResetTimer(nGapTime)
	self:CloseTimer();
	self.nGapTime = nGapTime;
	self.nTimerId = Timer:Register(Env.GAME_FPS * self.nGapTime, function ()
		return self:OnRefreshTimer();
	end);
end

function tbUi:GetGapTime(nRipenTime)
	local nLeftTime = nRipenTime - GetTime();
	return nLeftTime > 3600 and math.max(1, math.floor(HousePlant.RIPEN_TIME / 1000)) or 1;
end

function tbUi:OnLeaveMap()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_PLANT,	function () self:Refresh() end },
		{ UiNotify.emNOTIFY_MAP_LEAVE,	function () self:OnLeaveMap()  end },
	};
	return tbRegEvent;
end

function tbUi:OnRefreshTimer()
	local tbLand = HousePlant:GetLand();
	if not tbLand then
		return;
	end

	self:RefreshTime(tbLand.nRipenTime);

	local nGapTime = self:GetGapTime(tbLand.nRipenTime);
	if nGapTime ~= self.nGapTime then
		self:ResetTimer(nGapTime);
		return;
	end

	return true;
end

function tbUi:RefreshTime(nRipenTime)
	local nLeftTime = math.max(0, nRipenTime - GetTime());
	self.pPanel:Label_SetText("Time", Lib:TimeDesc2(nLeftTime));

	local nProgress = (HousePlant.RIPEN_TIME - nLeftTime) / HousePlant.RIPEN_TIME;
	self.pPanel:Sprite_SetFillPercent("Bar", nProgress);
end
