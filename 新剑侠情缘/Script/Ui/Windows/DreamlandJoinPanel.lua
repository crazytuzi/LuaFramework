
local tbUi = Ui:CreateClass("DreamlandJoinPanel");

function tbUi:OnOpen(szBattleType)
    if not szBattleType then
        szBattleType = InDifferBattle:GetCanSingupBattleType()
    end
    if not szBattleType then
        szBattleType = "Normal"
    end
    self.szBattleType = szBattleType
	self:Update()
	RemoteServer.InDifferRequestReadyMapTime()
end

function tbUi:Update()
	local szBattleType = self.szBattleType
    local szJoinIntro = InDifferBattle:GetSettingTypeField( szBattleType, "szJoinIntro")
    local szGeneralHelp = InDifferBattle:GetSettingTypeField( szBattleType, "szGeneralHelp")
    local szTitle = InDifferBattle:GetSettingTypeField( szBattleType, "szTitle")
    
    self.pPanel:ResetGeneralHelp("BtnTip", szGeneralHelp)
    self.pPanel:Label_SetText("Title", szTitle)

    self.pPanel:Label_SetText("TipTxtDesc", szJoinIntro)
    

    local tbSetting = InDifferBattle.tbBattleTypeSetting[szBattleType]
    if tbSetting.bAct then
        self.pPanel:SetActive("MatchTxt", false)
        self.pPanel:SetActive("Mark", false)
    else
        self.pPanel:SetActive("MatchTxt", true)
        self.pPanel:Label_SetText("MatchTxt", self:GetQualifyText())
        local szQulifyType = InDifferBattle:GetCurOpenQualifyType()
        if szQulifyType and InDifferBattle:IsQualifyInBattleType(me, szQulifyType) then
            self.pPanel:SetActive("Mark", true)
            self.pPanel:Label_SetText("MarkTxt", InDifferBattle.tbBattleTypeSetting[szQulifyType].szName .. "赛")
        else
            self.pPanel:SetActive("Mark", false)
        end
    end
    
    local tbUiShowItemList = InDifferBattle:GetSettingTypeField( szBattleType, "tbUiShowItemList")
    if not tbUiShowItemList then
        local nActivityID = Calendar:GetActivityId("InDifferBattle")    
        tbUiShowItemList = Calendar:GetActivityReward(nActivityID)
    end
    for i=1,7 do
        local tbGrid = self["itemframe" .. i]
        local tbInfo = tbUiShowItemList[i]
        if tbInfo then
            tbGrid.pPanel:SetActive("Main", true)
            tbGrid:SetGenericItem(tbInfo)
            tbGrid.fnClick = tbGrid.DefaultClick
        else
            tbGrid.pPanel:SetActive("Main", false)
        end
    end

    if tbSetting.bAct then
        self.pPanel:Label_SetText("RemainTimeLb", "可领奖次数")
        local _, tbActData = Activity:GetActUiSetting(InDifferBattle.tbBattleTypeSetting.ActJueDi.szActName)
        local nPlayCount = 0
        if tbActData and tbActData.tbCustomInfo then
            if Lib:GetLocalDay() == tbActData.tbCustomInfo.nUpdateDay then
                nPlayCount = tbActData.tbCustomInfo.nPlayCount;     
            end
        end
        local nGetAwardCount = InDifferBattle.tbBattleTypeSetting.ActJueDi.nGetAwardCount
        local nRemainCount = math.max(0, nGetAwardCount - nPlayCount)
        self.pPanel:Label_SetText("RemainTime", string.format("%d/%d", nRemainCount,  nGetAwardCount))

    else
        self.pPanel:Label_SetText("RemainTimeLb", "活动次数")
        self.pPanel:Label_SetText("RemainTime", string.format("%d/%d", DegreeCtrl:GetDegree(me, "InDifferBattle"),  DegreeCtrl:GetMaxDegree("InDifferBattle", me)))
    end
    self.pPanel:SetActive("PreparationTime", false)
    
end

function tbUi:GetQualifyText()
    local tbQualifyList = {};
    for i,v in ipairs(InDifferBattle.tbBattleTypeList) do
        local tbSetting = InDifferBattle.tbBattleTypeSetting[v]
        --TODO 暂时隐藏年度
        if not tbSetting.bCostDegree and tbSetting.szOpenTimeFrame  and GetTimeFrameState(tbSetting.szOpenTimeFrame) == 1 and v ~= "Year" then
            table.insert(tbQualifyList, v)
        end
    end

    
    if #tbQualifyList == 0 then
        return ""
    end
    local str = ""
    local nNow = GetTime()
    local nToday = Lib:GetLocalDay();
    for i,v in ipairs(tbQualifyList) do
        if str ~= "" then
            str = str .. "\n\n";
        end
        local tbSetting = InDifferBattle.tbBattleTypeSetting[v]
        str = str .. string.format("[92D2FF]%s赛资格：[-]", tbSetting.szName);
        if InDifferBattle:IsQualifyInBattleType(me, v) then
           str = str .. "[00FF00]已获得[-]\n[92D2FF]比赛时间：[-]" 

           local nCurOpenBattleTime = InDifferBattle:GetNextOpenTime(v, nNow - 3600)
           local nMatchDay = Lib:GetLocalDay(nCurOpenBattleTime)
           if nMatchDay == nToday then
                str = string.format("%s今晚%d:%d", str, tbSetting.OpenTimeHour, tbSetting.OpenTimeMinute)
            else
                str = string.format("%s%s[FFFE0D](%d天后)[-]", str, Lib:GetTimeStr3(nCurOpenBattleTime), nMatchDay - nToday)
           end

        else
            str = str .. "[FF0000]未获得[-]\n[92D2FF]获得方式：[-]" 
            local szPreType = tbQualifyList[ i - 1]
            if not szPreType then
                szPreType = "Normal"
            end
            local tbPreSetting = InDifferBattle.tbBattleTypeSetting[szPreType]
            local nNeedGrade = tbSetting.nNeedGrade
            local szGrade = InDifferBattle.tbDefine.tbEvaluationSetting[nNeedGrade].szName
            str = string.format("%s%s心魔幻境获得[FFFE0D]%s[-]以上评价", str, tbPreSetting.szName, szGrade)
        end
    end
    return str
end

function tbUi:OnClose(  )
    if self.nTimerReady then
        Timer:Close(self.nTimerReady)
        self.nTimerReady = nil
    end
end

function tbUi:UpdateLeftTime()
    if self.nTimerReady then
        Timer:Close(self.nTimerReady)
    end
    local nBattelReadyMapTime = Player:GetServerSyncData("IndifferBattelReadyMapTime")
    nBattelReadyMapTime = nBattelReadyMapTime + 1;
    self.pPanel:SetActive("PreparationTime", true)
    local fnUpdate = function ( )
        nBattelReadyMapTime = nBattelReadyMapTime - 1
        if nBattelReadyMapTime < 0 then
            self.nTimerReady = nil;
            return 
        end
        self.pPanel:Label_SetText("PreparationTime", string.format("本场准备时间：[FFFE0D]%s[-]", Lib:TimeDesc(nBattelReadyMapTime)))
        return true
    end
    fnUpdate()
    self.nTimerReady = Timer:Register(Env.GAME_FPS * 1, fnUpdate)
end

function tbUi:OnSyncData( szType )
    if szType == "IndifferBattelReadyMapTime" then
        self:UpdateLeftTime()
    end
end

function tbUi:CheckAddTimes(  )
    if not self.szBattleType then
        return
    end
    local tbBattleTypeSetting = InDifferBattle.tbBattleTypeSetting[self.szBattleType]
    if not tbBattleTypeSetting.bCostDegree then
    	return
    end
    local szQulifyType = InDifferBattle:GetCurOpenQualifyType()
    if szQulifyType and InDifferBattle:IsQualifyInBattleType(me, szQulifyType) then
        return
    end

    if DegreeCtrl:GetDegree(me, "InDifferBattle") > 0 then
        return
    end
    if DegreeCtrl:GetDegree(me, "IndifferAdd") <= 0 then
    	return
    end
    local nTemplateId = Item:GetClass("CountAddProp"):GetAddDegreeItemId("InDifferBattle")
    if not nTemplateId then
    	return
    end
	local nCount, tbItem = me.GetItemCountInAllPos(nTemplateId)
	if nCount <= 0 then
		local fnAgree = function ()
			Ui:OpenWindow("MarketStallPanel", 1, nil, "item", nTemplateId);
		end
		Ui:OpenWindow("MessageBox", "是否前往摆摊购买[FFFE0D]心魔宝珠[-]来获得参与次数？",
		{{fnAgree}, {} },
		{"同意", "取消"} )
		return true
	end
	
	local fnAgree = function ()
        local pItem = tbItem[1]
		if pItem then
			RemoteServer.UseItem(pItem.dwId);
		end
	end
	Ui:OpenWindow("MessageBox", "大侠今日已无剩余参与次数，是否使用[FFFE0D]心魔宝珠[-]获得一次参与次数",
	{{fnAgree}, {} },
	{"同意", "取消"} )
	return true
end

tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnClose()
    Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnSingle()
    if TeamMgr:HasTeam() then
        me.CenterMsg("您当前已经有队伍")
        return
    end
    if self:CheckAddTimes() then
    	return
    end
    InDifferBattle:DoSignUp()
end

function tbUi.tbOnClick:BtnTeam()
    if not TeamMgr:HasTeam() then
        me.CenterMsg("您当前没有队伍")
        return
    end
    if self:CheckAddTimes() then
    	return
    end
    
    InDifferBattle:DoSignUp()
end

function tbUi:RegisterEvent()
    return
    {
        { UiNotify.emNOTIFY_SYNC_DATA,                  self.OnSyncData},
        { UiNotify.emNOTIFY_BUY_DEGREE_SUCCESS,     	self.Update},
    };
end

