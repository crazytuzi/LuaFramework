local tbUi = Ui:CreateClass("DomainBattleReport");
local nMaxField = 2
local nMaxRankNum = 11
local nTopNum = 10

function tbUi:OnOpen(bNotSync)
	if  not bNotSync then
		DomainBattle:SynFightData()
	end
end

function tbUi:OnOpenEnd()
	self:RefreshUi()
end

function tbUi:RefreshUi()
	local tbKinBaseInfo = Kin:GetBaseInfo() or {}

	local szMyKinName = tbKinBaseInfo.szName or "-"
	self.pPanel:Label_SetText("FamilyName","家族：" ..szMyKinName)
	local szMyField = "领地：-"
	if DomainBattle.nMyOwnerMapId then
		szMyField = "领地：" .. Map:GetMapName(DomainBattle.nMyOwnerMapId)
	end
	self.pPanel:Label_SetText("TerritoryName",szMyField)

	self:UpdateTime()
	if not DomainBattle.tbFightData.tbScore then
		self:ClearLongZhu()
		self:HideAllRank()
		return 
	end
	self:RefreshLongZhu()
	self:RefreshRank()

	self:RefreshAttackCamp()
end

function tbUi:RefreshAttackCamp()
	if DomainBattle.tbFightData.nAttackCampIndex and DomainBattle.tbFightData.nAttackMapId and  DomainBattle.tbFightData.nState ~= 3 then
		self.pPanel:SetActive("CurrentTerritory", true)
		self.pPanel:SetActive("BtnChange", true)
		local tbInfo = DomainBattle:GetMapSetting(DomainBattle.tbFightData.nAttackMapId)
		local tbCampInfo = tbInfo.tbAtackPos[DomainBattle.tbFightData.nAttackCampIndex]
		self.pPanel:Label_SetText("CurrentTerritory", tbCampInfo[4] or "营地".. DomainBattle.tbFightData.nAttackCampIndex)
		
	else
		self.pPanel:SetActive("CurrentTerritory", false)
		self.pPanel:SetActive("BtnChange", false)
	end
end

function tbUi:UpdateTime()
	self:CloseTimer();
	self:UpdateTimeStr()	
    self.nTimeTimer = Timer:Register(Env.GAME_FPS, self.UpdateTimeStr,self);
    if DomainBattle.tbFightData.nState == 3 then
    	self.pPanel:SetActive("BtnAward", true)
    else
    	self.pPanel:SetActive("BtnAward", false)
    end
end

function tbUi:UpdateTimeStr()
	local tbState = DomainBattle.STATE_TRANS[DomainBattle.tbFightData.nState]
	local szDesc = tbState and tbState.szDesc or ""
	local nLeftTime = DomainBattle:GetClientLeftTime()
	self.pPanel:Label_SetText("ResidualTime",  szDesc .. "剩余时间：" ..Lib:TimeDesc(nLeftTime))
	
	if nLeftTime <= 0 then
		self.nTimeTimer = nil;
		return false
	end

	return true
end

function tbUi:ClearLongZhu()
	self.pPanel:SetActive("Content1",false)
	self.pPanel:SetActive("Content2",false)
end

function tbUi:RefreshLongZhu()
	self:ClearLongZhu()

	local nFieldCount = #DomainBattle.tbFightData.tbField
	if nFieldCount > nMaxField then
		return
	end

	for i=1,nFieldCount do
		local szContent = "Content" ..i
		self.pPanel:SetActive(szContent,true)
		local pPanel = self[szContent].pPanel;


		local tbFieldInfo = DomainBattle.tbFightData.tbField[i] or {}

		local nMapId = tbFieldInfo.nMapId
		local tbAttackMapSetting = Map:GetMapSetting(nMapId) or {}
		local szMapName = tbAttackMapSetting.MapName or "-"
		pPanel:Label_SetText("CampaignName", szMapName);
		pPanel:Label_SetText("LabelCity" .. i, nMapId == DomainBattle.tbFightData.nAttackMapId and "征战领地：" or "防守领地：" )

		local tbKinInfo = tbFieldInfo.tbKinInfo or {}

		local tbWinInfo = DomainBattle:GetWinKin(tbKinInfo, nMapId) 

		local szWinKinName = tbWinInfo and tbWinInfo[2] or "-"

		pPanel:Label_SetText("LeadingFamilyName", szWinKinName);

		for nIndex = 1, 3 do
			local tbkin = tbKinInfo[nIndex]
			if tbkin then
				pPanel:SetActive("LongZhuName" ..nIndex, true);
				pPanel:SetActive("Family" ..nIndex, true);	
				local szLongZhuName =  DomainBattle:GetFlogNpcName(nMapId, nIndex) or "-"
				local szBelongKinName = tbkin[1] == -1 and  "-" or tbkin[2] ;
				pPanel:Label_SetText("LongZhuName" ..nIndex, szLongZhuName);
				pPanel:Label_SetText("Family" ..nIndex, szBelongKinName);	
			else
				pPanel:SetActive("LongZhuName" ..nIndex, false);
				pPanel:SetActive("Family" ..nIndex, false);	
			end
		end
	end
end

function tbUi:RefreshRank()
	local tbTime = os.date("*t",GetTime());
	self.pPanel:Label_SetText("PersonalIntegration",string.format("个人积分排行(%s月%s日)",tbTime.month,tbTime.day))

	self:HideAllRank()

	local nMyRank = DomainBattle:MyRank(me)

	for nRank=1,nTopNum do
		local tbPlayerInfo = DomainBattle.tbFightData.tbScore[nRank]
		if tbPlayerInfo then
			local szName = tbPlayerInfo.szRoleName or "-"
			local nScore = tbPlayerInfo.nScore or 0
			local nKillNum = tbPlayerInfo.nKillNum or 0

			self.pPanel:SetActive("RankItem" ..nRank,true)
			self.pPanel:Label_SetText("RoleName" ..nRank,szName)
			self.pPanel:Label_SetText("Integral" ..nRank,nScore)
			self.pPanel:Label_SetText("KillNumber" ..nRank,nKillNum)
			
			local szBG = (nMyRank and nMyRank == nRank) and "ListBgLight" or "ListBgDark"
			self.pPanel:Sprite_SetSprite("RankItem" ..nRank, szBG);
		end
	end

	if nMyRank and nMyRank > 10 then
		local tbMyPlayerInfo = DomainBattle.tbFightData.tbScore[nMyRank]
		if tbMyPlayerInfo then
			local szMyName = tbMyPlayerInfo.szRoleName or "-"
			local nMyScore = tbMyPlayerInfo.nScore or 0
			local nMyKillNum = tbMyPlayerInfo.nKillNum or 0

			self.pPanel:SetActive("RankItem11",true)
			self.pPanel:Label_SetText("RoleName11",szMyName)
			self.pPanel:Label_SetText("Integral11",nMyScore)
			self.pPanel:Label_SetText("KillNumber11",nMyKillNum)
			self.pPanel:Label_SetText("Number11",nMyRank)
		end
	end
end

function tbUi:HideAllRank()
	for i=1,nMaxRankNum do
		self.pPanel:SetActive("RankItem" ..i,false)
	end
end

function tbUi:CloseTimer()
    if self.nTimeTimer then
        Timer:Close(self.nTimeTimer);
        self.nTimeTimer = nil;
    end    
end

function tbUi:OnClose()
	self:CloseTimer()
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_ONSYNC_DOMAIN_REPORT,   self.RefreshUi, self },
    };

    return tbRegEvent;
end

tbUi.tbOnClick =
{
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME);
	end;

	BtnAward = function (self)
		Ui:OpenWindow("ChatLargePanel", ChatMgr.nChannelMail);
		Ui:CloseWindow(self.UI_NAME)
	end;

	BtnChange = function (self)
		if not DomainBattle:CanUseBattleSupplys()  then
			me.CenterMsg("您的权限不够")
			return 
		end 	

		local nMapTemplateId = me.nMapTemplateId
		
		if not DomainBattle:GetMapSetting(nMapTemplateId) then
			me.CenterMsg("请在攻城战地图操作")
			return
		end

		if not DomainBattle.tbFightData.nAttackCampIndex then
			return
		end

		local tbInfo = DomainBattle:GetMapSetting(DomainBattle.tbFightData.nAttackMapId) 
		
		local fnSelectCamp = function (nIndex)
			RemoteServer.DomainBattleSelectCamp(nIndex)
		end
		local OptList = {};
		for i,v in ipairs(tbInfo.tbAtackPos) do
			table.insert(OptList,{Text = string.format("更换为：%s", v[4] and v[4] or "营地"..i), Callback = fnSelectCamp, Param = {i}  } )
		end

		Dialog:Show({Text = "被围堵了吗？没关系，更改征战营地吧！家族成员下次重生时将出现在更改后的征战营地。", OptList = OptList }, me, {szName = "家族总管", nTemplateId = 627 } );

	end;

}