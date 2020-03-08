
local tbUi = Ui:CreateClass("LTZHomeBattleInfo");
tbUi.nShowComboTime = 3;

function tbUi:OnOpen(nState, nTimeFrame)
	self.bZone = bZone
	self:SetEndTime(nState or 1, nTimeFrame)
	self:UpdateApplyData()
	self:PlayComboAni(0)
end

-- function tbUi:ClickItem(nTemplateId)
-- 	LingTuZhan:UseBattleSupplys( nTemplateId )
-- end

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
	local tbState = LingTuZhan.define.STATE_TRANS[nState]
	if not tbState then
		return
	end
	self.nState = nState
	LingTuZhan:SetClientLeftTime(nSynEndTime or tbState.nSeconds)

	if self.nTimerId then
		Timer:Close(self.nTimerId);
		self.nTimerId = nil;
	end

	self.pPanel:Label_SetText("InfoTxt", tbState.szDesc)
	
	local nEndTime = LingTuZhan:GetClientLeftTime();

	self.pPanel:Label_SetText("LastTime", string.format("%02d:%02d", math.floor(nEndTime / 60), nEndTime % 60));
	self.nTimerId = Timer:Register(Env.GAME_FPS, self.ShowTime, self)
end

function tbUi:ShowTime()

	LingTuZhan:SetClientLeftTime(nil, -1)
	local nEndTime = LingTuZhan:GetClientLeftTime();
	if nEndTime <= 0 then --这时候同步了server端的 time时会错过 更改state
		self.pPanel:Label_SetText("LastTime", "00:00");
		self.nTimerId = nil;
		self:SetEndTime(self.nState + 1)
		return;
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
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi:UpdateApplyData()
	--前线营地是剩余可用次数，攻城车是场上可用次数
	for i, nTemplateId in ipairs(LingTuZhan.define.tbBattleApplyIdOrder) do
		local itemGrid = self["itemframe" .. i]
		local nCanUseCount = LingTuZhan:GetSupplyItemCount(me, nTemplateId )
		itemGrid:SetItemByTemplate(nTemplateId, nCanUseCount)
		itemGrid.fnClick = itemGrid.DefaultClick
		local  tbItem = KItem.GetItemBaseProp(nTemplateId)
		self.pPanel:Label_SetText("ItemName" .. i, tbItem.szName)
		-- itemGrid.pPanel:SetActive("Main", true)
		-- self.pPanel:SetActive("ItemName" .. i, true)
	end
end

tbUi.tbOnClick = {};
tbUi.tbOnClick.BtnBattleReport = function (self)
	--查看战报
	Ui:OpenWindow("TerritorialWarPanel")
end

tbUi.tbOnClick.BtnLeave = function (self)
	local fnYes = function ()
		RemoteServer.DoRequesLTZ("RequestLeaveBattle")	--读条离开
	end
	if me.nFightMode == 0 then
		Ui:OpenWindow("MessageBox",
		   "您确定要离开跨服领土战吗",
		 { {fnYes},{} },
		 {"确认", "取消"});
	else
		fnYes()
	end
end

function tbUi:OnSynData( szType )
	if szType == "FightData" then
		self:UpdateApplyData()
	end
end

function tbUi:RegisterEvent()
    return
    {
        { UiNotify.emNOTIFY_MAP_LEAVE, self.OnLeave, self},
        { UiNotify.emNOTIFY_LTZ_SYN_DATA, self.OnSynData, self},
    };
end
