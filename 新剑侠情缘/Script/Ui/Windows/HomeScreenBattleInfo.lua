
local tbUi = Ui:CreateClass("HomeScreenBattleInfo");
tbUi.nShowComboTime = 3;

function tbUi:OnOpen(nState, nTimeFrame, nComboKill, bNotHide)
	if nComboKill then
		self.pPanel:SetActive("MyRank", false);
		self.pPanel:SetActive("Lianzhan", false);	
		self.pPanel:SetActive("CampBattleScore", false);
		if bNotHide then
			self:UpdateComboNum(nComboKill)
		else
			self:PlayComboAni(nComboKill, tbUi.nShowComboTime);
		end
	else	
		self.pPanel:SetActive("MyRank", false);
		self.pPanel:SetActive("Lianzhan", false);	
		self.pPanel:SetActive("CampBattleScore", true);
		self:SetEndTime(nState or 1, nTimeFrame)
		self:Update(0, 0, 0, 0)
	end

	self.tbShowTimeSetting = nil;
	if Battle.tbCurBattleSetting then
		for i = 1, 2 do
			self.pPanel:Label_SetText("Camp" .. i, Battle.tbCurBattleSetting.tbTeamNames[i]);
		end
		self.tbShowTimeSetting = Battle.Second_StateTrans[Battle.tbCurBattleSetting.nUseSchedule]
	end
end

function tbUi:Update(nTeam1Score, nTeam2Score,  nMyScore, nRank)
	self.pPanel:Label_SetText("Camp1Num", nTeam1Score)
	self.pPanel:Label_SetText("Camp2Num", nTeam2Score)
	

	self.pPanel:Label_SetText("TxtRank", string.format("个人积分: %d\n个人排名: %d", nMyScore, nRank));
end

function tbUi:OnSynData(tbBattleRank, nMyRank, tbTeamScore, nLeftTime)
	local tbMyInfo = tbBattleRank[nMyRank]
	self.nEndTime = nLeftTime
	self:Update(tbTeamScore[1], tbTeamScore[2], tbMyInfo.nScore, nMyRank) --同步不是实时的，所以不用这种方式了
end

function tbUi:UpdateComboNum(nCombo)
	self.pPanel:SetActive("Lianzhan", true)
	local szCombo = nCombo == 0 and "combo0" or ""
	while(nCombo > 0)
		do
		szCombo = string.format("combo%d%s", nCombo%10, szCombo)
		nCombo = math.floor(nCombo/10)
	end
	self.pPanel:Label_SetText("ComboNumber", szCombo)
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
	local tbState = Battle.STATE_TRANS[Battle.tbCurBattleSetting.nUseSchedule][nState] 
	if not tbState then
		return
	end
	self.nState = nState
	if nState >= 2 then
		self.pPanel:SetActive("MyRank", true)
	end

	self.nEndTime = nSynEndTime or tbState.nSeconds
	
	if self.nTimerId then
		Timer:Close(self.nTimerId);
		self.nTimerId = nil;
	end
	if tbState.szFunc == "CloseBattle" then
		self.pPanel:Label_SetText("Countdown", "结束");
		return
	end
	self.pPanel:Label_SetText("Countdown", string.format("%02d:%02d", math.floor(self.nEndTime / 60), self.nEndTime % 60));
	self.nTimerId = Timer:Register(Env.GAME_FPS, self.ShowTime, self)
end


function tbUi:ShowTime()
	self.nEndTime = self.nEndTime - 1
	if self.nEndTime <= 0 then --这时候同步了server端的 time时会错过 更改state
		self.pPanel:Label_SetText("Countdown", "00:00");
		self.nTimerId = nil;
		self:SetEndTime(self.nState + 1)
		return;
	end
	if self.tbShowTimeSetting then
		if self.tbShowTimeSetting[self.nState] then
			local tbFunc =  self.tbShowTimeSetting[self.nState][self.nEndTime] 
			if tbFunc then
				self[tbFunc.szFunc](self, tbFunc.tbParam)
			end
		end
	end
	
	self.pPanel:Label_SetText("Countdown", string.format("%02d:%02d", math.floor(self.nEndTime / 60), self.nEndTime % 60));
	return true;
end

function tbUi:ShowMsg(tbParam)
	if not tbParam then
		return
	end
	local szMsg = tbParam[1]
	if not szMsg then
		return
	end
	me.CenterMsg(szMsg)
end

function tbUi:ShowReadyInfo()
	Ui:OpenWindow("ReadyGo")
end


function tbUi:OnClose()
	self.nEndTime = 0;
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
	for i,v in ipairs(Battle.tbMapSetting) do
		if v.nMapTemplateId == nTemplateID then
			Ui:CloseWindow(self.UI_NAME)
			return
		end
	end
end

tbUi.tbOnClick = {};
tbUi.tbOnClick.BtnViewBattleReport = function (self)
	--查看战报
	Ui:OpenWindow("BattleReport")
end

function tbUi:RegisterEvent()
    return
    {
        { UiNotify.emNOTIFY_SYNC_BATTLE_REPORT,           self.OnSynData},
        { UiNotify.emNOTIFY_MAP_LEAVE,           		  self.OnLeave},
    };
end
