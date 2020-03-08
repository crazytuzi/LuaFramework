
local tbUi = Ui:CreateClass("DomainBattleHomeInfo");
tbUi.nShowComboTime = 3;

function tbUi:OnOpen(nState, nTimeFrame, bZone)
	self.bZone = bZone
	self:SetEndTime(nState or 1, nTimeFrame)
	self:UpdateApplyData()
	self:PlayComboAni(0)
	self:UpdateAddtionAwardBtn()
end

function tbUi:ClickItem(nTemplateId)
	if not self.bZone then
		DomainBattle:UseBattleSupplys(nTemplateId);
	else
		DomainBattle.tbCross:UseSupplysRequest(nTemplateId);
	end
end

function tbUi:UpdateComboNum(nCombo)
	if nCombo > 999 then
		nCombo = 999
	end
	self.pPanel:SetActive("Lianzhan", true)
	local nHun = math.floor(nCombo / 100) 
	local nTen = math.floor((nCombo - 100 * nHun) / 10) 
	local nSingle = nCombo - 100 * nHun - 10 * nTen

	if nHun > 0 then
		self.pPanel:SetActive("SpHundred", true)
		self.pPanel:Sprite_SetSprite("SpHundred",  string.format("Deadly_Hurt_%d_a", nHun));
	else
		self.pPanel:SetActive("SpHundred", false)
	end

	if nTen > 0 or nHun > 0  then
		self.pPanel:SetActive("SpTen", true)
		self.pPanel:Sprite_SetSprite("SpTen",  string.format("Deadly_Hurt_%d_a", nTen));
	else
		self.pPanel:SetActive("SpTen", false)
	end
	self.pPanel:Sprite_SetSprite("SpSingle",  string.format("Deadly_Hurt_%d_a", nSingle));
end

function tbUi:CloseLianZhen()
    self.pPanel:SetActive("Lianzhan", false);
    self.nComboTimer = nil;
end

function tbUi:PlayComboAni(nCombo, nShowTime)
	self:CloseComboTimer();
	if nCombo == 0 then
		self.pPanel:SetActive("Lianzhan", false)
		return
	end
	if nShowTime then
		self.nComboTimer = Timer:Register(nShowTime * Env.GAME_FPS, self.CloseLianZhen, self)
	end

	self:UpdateComboNum(nCombo)
	self.pPanel:SetActive("Lianzhan", false)--重置动画的
	self.pPanel:SetActive("Lianzhan", true)
	self.pPanel:Play_Animator("Lianzhan", "lianzhan_gou1")
end

function tbUi:SetEndTime(nState, nSynEndTime)
	local tbState = DomainBattle.STATE_TRANS[nState]
	if self.bZone then
		tbState = DomainBattle.tbCrossDef.tbStateCfg[nState]
	end
	if not tbState then
		return
	end
	self.nState = nState
	if not self.bZone then
		DomainBattle.tbFightData.nState = nState
		DomainBattle:SetClientLeftTime(nSynEndTime or tbState.nSeconds)
	end

	if self.nTimerId then
		Timer:Close(self.nTimerId);
		self.nTimerId = nil;
	end

	self.pPanel:Label_SetText("InfoTxt", tbState.szDesc)

	-- if tbState.szFunc == "CloseBattle" then
	-- 	self.pPanel:Label_SetText("LastTime", "结束");
	-- 	return
	-- end
	local nEndTime
	if not self.bZone then
		nEndTime = DomainBattle:GetClientLeftTime();
	else
		nEndTime = DomainBattle.tbCross:GetStateLeftTime();
	end

	self.pPanel:Label_SetText("LastTime", string.format("%02d:%02d", math.floor(nEndTime / 60), nEndTime % 60));
	self.nTimerId = Timer:Register(Env.GAME_FPS, self.ShowTime, self)
end

function tbUi:ShowTime()
	local nEndTime
	if not self.bZone then
		DomainBattle:SetClientLeftTime(nil, -1)
		nEndTime = DomainBattle:GetClientLeftTime();
		if nEndTime <= 0 then --这时候同步了server端的 time时会错过 更改state
			self.pPanel:Label_SetText("LastTime", "00:00");
			self.nTimerId = nil;
			self:SetEndTime(self.nState + 1)
			return;
		end
	else
		nEndTime = DomainBattle.tbCross:GetStateLeftTime();
	end

	self.pPanel:Label_SetText("LastTime", string.format("%02d:%02d", math.floor(nEndTime / 60), nEndTime % 60));
	return true;
end

function tbUi:OnClose()
	if self.nTimerId then
		Timer:Close(self.nTimerId);
		self.nTimerId = nil;
	end

	self:CloseComboTimer();
end

function tbUi:CloseComboTimer()
    if self.nComboTimer then
	Timer:Close(self.nComboTimer);
		self.nComboTimer = nil;
    end
end

function tbUi:OnLeave(nTemplateID)
	if not self.bZone then
		if DomainBattle:GetMapLevel(nTemplateID) then
			Ui:CloseWindow(self.UI_NAME)
			return
		end
	end
end

function tbUi:UpdateApplyData()
	local tbBattleSupply
	if not self.bZone then
		tbBattleSupply = DomainBattle:GetCanUseBattleSupplys()
	else
		tbBattleSupply = DomainBattle.tbCross:GetCanUseBattleSupplys()
	end

	for i, nTemplateId in ipairs(DomainBattle.define.tbBattleApplyIdOrder) do
		local itemGrid = self["itemframe" .. i]
		if tbBattleSupply then
			local nNum = tbBattleSupply[nTemplateId] or 0;
			local tbControls = {}
			if nNum == 0 then
				 tbControls.bShowCDLayer = true;
			end
			itemGrid:SetItemByTemplate(nTemplateId, nNum, nil, nil, tbControls)
			itemGrid.fnClick = function ( _ )
				self:ClickItem(nTemplateId)
			end
			local  tbItem = KItem.GetItemBaseProp(nTemplateId)
			self.pPanel:Label_SetText("ItemName" .. i, tbItem.szName)
			itemGrid.pPanel:SetActive("Main", true)
			self.pPanel:SetActive("ItemName" .. i, true)
		else
			itemGrid.pPanel:SetActive("Main", false)
			self.pPanel:SetActive("ItemName" .. i, false)
		end
	end
end

function tbUi:UpdateAddtionAwardBtn()
	local bShowBtn = false
	if not self.bZone then
		local nMapLevel = DomainBattle:GetMyOwnerMapLevel()
		if nMapLevel == DomainBattle.DEFINE_TOWN or nMapLevel == DomainBattle.DEFINE_FIELD then
			bShowBtn = true
		end
	end
	self.pPanel:SetActive("BtnPrize", bShowBtn)
end

function tbUi:OnSynKinData(szType)
	if szType ~= "MemberCareer" then
		return
	end
	self:UpdateApplyData()
end

tbUi.tbOnClick = {};
tbUi.tbOnClick.BtnBattleReport = function (self)
	--查看战报
	if not self.bZone then
		Ui:OpenWindow("DomainBattleReport")
	else
		Ui:OpenWindow("TerritoryCrossBattlefieldPanel")
	end
end

tbUi.tbOnClick.BtnLeave = function (self)
	local fnYes = function ()
		if not self.bZone then
			RemoteServer.DomainBattleLeave();
		else
			RemoteServer.CrossDomainLeave();
		end
	end
	if me.nFightMode == 0 then
		Ui:OpenWindow("MessageBox",
		   "您确定要离开攻城战吗",
		 { {fnYes},{} },
		 {"确认", "取消"});
	else
		fnYes()
	end
end

tbUi.tbOnClick.BtnPrize = function (self)
	Ui:OpenWindow("TerritoryRewardAdditionPanel")
end

function tbUi:RegisterEvent()
    return
    {
        { UiNotify.emNOTIFY_MAP_LEAVE, self.OnLeave, self},
        { UiNotify.emNOTIFY_ONSYNC_DOMAIN_SUPPLY, self.UpdateApplyData, self},
        { UiNotify.emNOTIFY_SYNC_KIN_DATA, self.OnSynKinData, self},
        { UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_STATE, self.SetEndTime, self},
    };
end
