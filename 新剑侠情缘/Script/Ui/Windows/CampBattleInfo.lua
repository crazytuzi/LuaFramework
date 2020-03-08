
local tbUi = Ui:CreateClass("CampBattleInfo");
local tbCampSetting = Battle.tbCampSetting

function tbUi:OnOpen(nState, nTimeFrame, tbTeamInfo)
	self:UpdateTeamInfo(tbTeamInfo)

	self.tbShowTimeSetting = nil;
	if Battle.tbCurBattleSetting then
		for i = 1, 2 do
			self.pPanel:Label_SetText("Camp" .. i, Battle.tbCurBattleSetting.tbTeamNames[i]);
		end
		self.tbShowTimeSetting = Battle.Second_StateTrans[Battle.tbCurBattleSetting.nUseSchedule]
	end
	self:SetEndTime(nState, nTimeFrame)

	local nBossNpcTeamplate = Battle.tbCampSetting.tbBossNpcTeamplate[1]
	self.szBossNpcName = KNpc.GetNameByTemplateId(nBossNpcTeamplate)
end

function tbUi:UpdateTeamInfo(tbTeamInfo)
	for i,v in ipairs(tbTeamInfo) do
		self.pPanel:Label_SetText(string.format("Camp%dNum", i), string.format("已摧毁：%d", v.nDestroyBuildNum))
	end
end

function tbUi:OnSynBattleData(tbTeamInfo, nLeftTime)
	self.nEndTime = nLeftTime
	self:UpdateTeamInfo(tbTeamInfo) 
end

function tbUi:UpdateLeftInfo()
	local nNow = GetTime()
	local szType, Param1, Prram2, Prram3 = Player:GetServerSyncData("BattleCampBossInfo")
	if Battle.nBattleRevieTime and Battle.nBattleRevieTime > nNow then
		self.pPanel:SetActive("Info1", true)
		self.pPanel:SetActive("Info2", false)
		local nLeftTime = Battle.nBattleRevieTime - nNow
		self.pPanel:Label_SetText("Txt1", string.format("[FF6464FF]你已重伤，%s秒后复活[-]", nLeftTime))

	elseif szType == "Reborn" and Param1  then
		self.pPanel:SetActive("Info1", true)
		self.pPanel:SetActive("Info2", false)
		local nLeftTime = Param1 - (tbCampSetting.nTotalFightTime - self.nEndTime)
		if nLeftTime > 0 then
			self.pPanel:Label_SetText("Txt1", string.format("%s现身时间：%s \n[FFFE0D]提示：击杀可获得协助[-]", self.szBossNpcName, Lib:TimeDesc3(nLeftTime)))
		else
			self.pPanel:Label_SetText("Txt1", string.format("%s已现身战场\n[FFFE0D]提示：击杀可获得协助[-]", self.szBossNpcName))
		end

		if nLeftTime == 10 or nLeftTime == 20 then
			Dialog:SendBlackBoardMsg(me, string.format("%s将于%d秒后现身战场", self.szBossNpcName, nLeftTime))
		end

	elseif szType == "Help" and Param1 and Prram2 then
		self.pPanel:SetActive("Info1", true)
		self.pPanel:SetActive("Info2", false)
		local nLeftTime = Param1 - (tbCampSetting.nTotalFightTime - self.nEndTime)

		self.pPanel:Label_SetText("Txt1", string.format("%s加入%s阵营\n协助时间：%s", self.szBossNpcName, Battle.tbCurBattleSetting.tbTeamNames[Prram2] , Lib:TimeDesc3(nLeftTime)))
	elseif szType == "Dmg" then
		local nSide1,nSide2 = unpack(Prram2)
		local nMySide = Battle.nTeamIndex;
		if nMySide == nSide1 or nMySide == nSide2 or (Battle.nTeamIndex and Param1[Battle.nTeamIndex] > 0) then
			local nMaxPercent = Param1[1] > Param1[2] and Param1[1] or Param1[2]
			for i=1,2 do
				local nPercent = math.floor(Param1[i] / Prram3 * 100) 
				self.pPanel:Label_SetText("OutputDamage"..i, string.format("%s%%",tostring(nPercent)));
				self.pPanel:Sprite_SetFillPercent("OutputBar"..i, Param1[i] / nMaxPercent);
			end			

			self.pPanel:Label_SetText("Txt2",string.format("正在捕获%s", self.szBossNpcName))
			self.pPanel:SetActive("Info1", false)
			self.pPanel:SetActive("Info2", true)	

		else
			self.pPanel:Label_SetText("Txt1", string.format("%s已现身战场", self.szBossNpcName))
			self.pPanel:SetActive("Info1", true)
			self.pPanel:SetActive("Info2", false)	
		end
	end
end

function tbUi:SetEndTime(nState, nSynEndTime)
	local tbState = Battle.STATE_TRANS[Battle.tbCurBattleSetting.nUseSchedule][nState] 
	if not tbState then
		return
	end
	if self.tbShowTimeSetting and nState ~= self.nState then
		local tbFuncs = self.tbShowTimeSetting[nState]
		local tbFunc = tbFuncs and tbFuncs[0]
		if tbFunc then
			self[tbFunc.szFunc](self, tbFunc.tbParam)			
		end
	end
	self.nState = nState


	self.pPanel:SetActive("Info1", false)
	self.pPanel:SetActive("Info2", false)
	if nState == 1 then
		self.pPanel:SetActive("BtnViewBattleReport", false)
	elseif nState == 2 or nState == 3 then
		self.pPanel:SetActive("BtnViewBattleReport", true)
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

	if self.nState == 2 then
		self:UpdateLeftInfo()
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

function tbUi:ShowReportUi()
	Ui:OpenWindow("CampBattlePanel")
end

function tbUi:CloseReportUi()
	Ui:CloseWindow("CampBattlePanel")
end


function tbUi:OnClose()
	self.nEndTime = 0;
	if self.nTimerId then
		Timer:Close(self.nTimerId);
		self.nTimerId = nil;
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
	Ui:OpenWindow("CampBattlePanel")
end

function tbUi:OnSyncData( szType )
	if szType == "BattleScheTime" then
		local  nState, nSynEndTime = Player:GetServerSyncData("BattleScheTime")
		self:SetEndTime(nState, nSynEndTime)
	elseif szType == "BattleCampTeamScore" then
		local  tbTeamInfo, nSynEndTime = Player:GetServerSyncData("BattleCampTeamScore")
		self:OnSynBattleData(tbTeamInfo, nSynEndTime)		
	end
end

function tbUi:RegisterEvent()
    return
    {
        { UiNotify.emNOTIFY_MAP_LEAVE,           		  self.OnLeave},
        { UiNotify.emNOTIFY_SYNC_DATA, 						self.OnSyncData, self},
    };
end
