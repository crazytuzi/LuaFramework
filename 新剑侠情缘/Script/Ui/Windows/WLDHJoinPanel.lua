local tbUi = Ui:CreateClass("WLDHJoinPanel");
local tbDef = WuLinDaHui.tbDef

tbUi.tbTabGameTypeButtons = {"BtnDoublesManMatch","BtnThreeManMatch", "BtnFourManMatch" }
tbUi.tbAllTabButtons = {"BtnSignUpStage", "BtnMyTeam", "BtnDoublesManMatch","BtnThreeManMatch", "BtnFourManMatch" };

function tbUi:OnOpen(nGameType)
    Client:SetFlag("WLDHViewPanelTime", GetTime())
    WuLinDaHui:CheckRedPoint()

    local bRet, szActName = WuLinDaHui:IsShowTopButton()
    if not bRet  then
        me.CenterMsg("当前没有武林大会")
        return 0;
    end
    WuLinDaHui:CheckRequestTeamData()

    self.szActName = szActName
    local nActStartTime, nActEndTime = Activity:__GetActTimeInfo(szActName)
    self.nActEndTime  = nActEndTime
    self.nActStartTime = nActStartTime

    local tbUiShowItemIds = WuLinDaHui.tbDef.tbUiShowItemIds
    for j=1,16 do
        local tbItemGrid = self["itemframe" .. j]
        local i = j > 8 and  j - 8 or j
        local nItemId = tbUiShowItemIds[i]
        if nItemId then
            tbItemGrid.pPanel:SetActive("Main", true)
            tbItemGrid:SetItemByTemplate( nItemId, 1 )
            tbItemGrid.fnClick = tbItemGrid.DefaultClick
        else
            tbItemGrid.pPanel:SetActive("Main", false)
        end
    end
end

function tbUi:OnOpenEnd(nGameType)
    if not nGameType and self.szActName == WuLinDaHui.szActNameMain then
        nGameType = WuLinDaHui:GetToydayGameFormat()
    end
    if nGameType then
        for i,v in ipairs(self.tbTabGameTypeButtons) do
            self.pPanel:Toggle_SetChecked(v, nGameType == i)
        end
    end
    self:Update();
end

function tbUi:ResetTabButtonColors()
    local RepresentSetting = Ui.RepresentSetting
    local ColorOulineHas = RepresentSetting.CreateColor(0.8588, 0.4, 0.2314, 1.0);
    local ColorOulineNotHasLight = RepresentSetting.CreateColor(65/255, 170/255, 220/255, 1.0);
    local ColorOulineNotHasDark = RepresentSetting.CreateColor(0, 40/255, 80/255, 1.0);
    local ColorHas = {235 ,254, 58};
    local ColorNotHas = {255, 255, 255};
    for i, v in ipairs(WuLinDaHui.tbGameFormat) do
        local tbTeamInfo = Player:GetServerSyncData("WLDHFightTeamInfo" .. i)
        local szButtonName = self.tbTabGameTypeButtons[i]
        local pPanel = self[szButtonName].pPanel
        if tbTeamInfo and tbTeamInfo.nFightTeamID then
            pPanel:Label_SetOutlineColor("LabelLight", ColorOulineHas)
            pPanel:Label_SetOutlineColor("LabelDark", ColorOulineHas)

            pPanel:Label_SetColor("LabelLight", unpack(ColorHas))

            pPanel:Label_SetColor("LabelDark", unpack(ColorHas))
        else
            pPanel:Label_SetOutlineColor("LabelLight", ColorOulineNotHasLight)
            pPanel:Label_SetOutlineColor("LabelDark", ColorOulineNotHasDark)
            pPanel:Label_SetColor("LabelLight", unpack(ColorNotHas))
            pPanel:Label_SetColor("LabelDark", unpack(ColorNotHas))
        end
    end
end

function tbUi:Update()
    self.pPanel:SetActive("Panel1", false)
    self.pPanel:SetActive("Panel2", false)
    self.pPanel:SetActive("Panel3", false)
    self.pPanel:SetActive("Panel4", false)
    if self.szActName == WuLinDaHui.szActNameYuGao then
        self.pPanel:Texture_SetTexture("Texture", "UI/Textures/WLDH0.png");
        self.pPanel:SetActive("Tab", false)
        self.pPanel:SetActive("Panel3", true)

        self.pPanel:Label_SetText("Content3", tbDef.szYuGaoUiDesc)
        local tbTextSize2 = self.pPanel:Label_GetPrintSize("Content3");
        local tbSize = self.pPanel:Widget_GetSize("datagroup");
        self.pPanel:Widget_SetSize("datagroup", tbSize.x, 50 + tbTextSize2.y);
        self.pPanel:DragScrollViewGoTop("datagroup");
        self.pPanel:UpdateDragScrollView("datagroup");

        self:UpdateLeftTime()
    else
        self.pPanel:SetActive("Tab", true)
        local bRsetTabbuttons = false

        local tbCurHasAttachGameTypes = {};
        for i, v in ipairs(WuLinDaHui.tbGameFormat) do
            local tbTeamInfo = Player:GetServerSyncData("WLDHFightTeamInfo" .. i)
            if tbTeamInfo and tbTeamInfo.nFightTeamID then
                table.insert(tbCurHasAttachGameTypes, i)
            end
        end
        if not self.tbMyAttachGameTypes then
            bRsetTabbuttons = true
        else
            if #tbCurHasAttachGameTypes ~= #self.tbMyAttachGameTypes then
                bRsetTabbuttons = true
            else
                for i,v in ipairs(self.tbMyAttachGameTypes) do
                    if v ~= tbCurHasAttachGameTypes[i] then
                        bRsetTabbuttons = true
                        break;
                    end
                end
            end
        end

        self.tbMyAttachGameTypes = tbCurHasAttachGameTypes

        if bRsetTabbuttons then
            self:ResetTabButtonColors()
        end

        self:UpdateMatchInfo()
    end

end

function tbUi:GetCurSelectGameType()
    if self.pPanel:Toggle_GetChecked("BtnDoublesManMatch") then
        return 1
    elseif self.pPanel:Toggle_GetChecked("BtnThreeManMatch") then
        return 2
    -- elseif self.pPanel:Toggle_GetChecked("BtnThreeManDuel") then
    --     return 3
    elseif self.pPanel:Toggle_GetChecked("BtnFourManMatch") then
        return 3
    end
end

function tbUi:InitPosInfo()

    self.tbTabButtonsPos = {};
    for i,v in ipairs(self.tbAllTabButtons) do
        local tbPos = self.pPanel:GetPosition(v)
        self.tbTabButtonsPos[i] = tbPos
    end
end

function tbUi:UpdateMatchInfo()
    if not self.tbTabButtonsPos then --不能放到 OnCreate里，那时还没加载
        self:InitPosInfo()
    end
    local bOldActive = self.pPanel:IsActive("BtnSignUpStage")
    local tbCopyAllTabs = Lib:CopyTB(self.tbAllTabButtons)
    local bResetPostion = false
    if self.szActName == WuLinDaHui.szActNameBaoMing then
        self.pPanel:SetActive("BtnSignUpStage", true)
        if not bOldActive then
            bResetPostion = true
        end
    else
        self.pPanel:SetActive("BtnSignUpStage", false)
        self.pPanel:Toggle_SetChecked("BtnSignUpStage", false)
        table.remove(tbCopyAllTabs, 1)
        if  bOldActive then
            bResetPostion = true
        end
    end
    if bResetPostion then
        for i,v in ipairs(tbCopyAllTabs) do
            local tbPos = self.tbTabButtonsPos[i]
            self.pPanel:ChangePosition(v, tbPos.x, tbPos.y)
        end
    end
    --先获取队伍数吧，因为玩家最多报名两个的
    if self.pPanel:Toggle_GetChecked("BtnSignUpStage") then
        self:UpdateSignUpStage()
    elseif self.pPanel:Toggle_GetChecked("BtnMyTeam") then
        self:UpdateMyTeamPage()
    else
        local nCurGameType = self:GetCurSelectGameType()
        if nCurGameType then
            self:UpdateBattleType(nCurGameType)
        elseif self.pPanel:IsActive("BtnSignUpStage") then
            self.pPanel:Toggle_SetChecked("BtnSignUpStage", true)
            self:UpdateSignUpStage()
        else
            self:UpdateMyTeamPage()
        end

        for i,v in ipairs(self.tbTabGameTypeButtons) do
            self.pPanel:Toggle_SetChecked(v, nCurGameType == i)
        end
    end
end

function tbUi:TryRequestFightTeamData(nFightTeamID)
    local tbFightTeam = Player:GetServerSyncData("WLDHFightTeam:"..nFightTeamID);
    local bReques = true;
    if tbFightTeam then
        tbFightTeam.__RequesTime =  tbFightTeam.__RequesTime or GetTime();
        if GetTime() - tbFightTeam.__RequesTime < 60 * 30 then
            bReques = false;
        end
    end

    if bReques then
        RemoteServer.DoRequesWLDH("RequestFightTeamShow", nFightTeamID);
    end
    return tbFightTeam
end

function tbUi:UpdateMyTeamPage()
    self.pPanel:Texture_SetTexture("Texture", "UI/Textures/WLDH5.png");

    self.pPanel:SetActive("Panel4", true)
    self:CloseTimer()

    local tbHasTeamId = {};
    for i, v in ipairs(WuLinDaHui.tbGameFormat) do
        local tbTeamInfo = Player:GetServerSyncData("WLDHFightTeamInfo" .. i) or {};
        local nFightTeamID = tbTeamInfo.nFightTeamID
        if nFightTeamID then
            table.insert(tbHasTeamId, nFightTeamID)
        end
    end

    for i=1,2 do
        local nFightTeamID = tbHasTeamId[i]
        if not nFightTeamID then
            self.pPanel:Label_SetText("Title" .. i, "所属战队：无")
            self.pPanel:SetActive("State" .. i, false)
            self.pPanel:Label_SetText("TipLabel" .. i, "无战队信息")

            self.pPanel:SetActive("NoTeam" .. i, true)
            for j=(i-1)*4+1,(i-1)*4+4 do
                self.pPanel:SetActive("Member" .. j, false)
            end
        else
            self.pPanel:SetActive("NoTeam" .. i, false)
            self.pPanel:SetActive("State" .. i, true)
            local tbFightTeam = self:TryRequestFightTeamData(nFightTeamID)
            if tbFightTeam then
                local nGameType = WuLinDaHui:GetGameTypeByTeamId(nFightTeamID)
                local tbGameFormat = WuLinDaHui.tbGameFormat[nGameType]
                local tbTimeNode, nState = WuLinDaHui:GetCurTimeNode(nGameType)

                --初赛1，初赛1end， 初赛2，初赛2end， 决赛1， 决赛1end
                local nShowTxtUi = 1;
                if nState <= 1 then
                    nShowTxtUi = 1;
                elseif nState <= 8 then
                    nShowTxtUi = 4;
                elseif nState == 9 then
                    local tbTeamInfo = Player:GetServerSyncData("WLDHFightTeamInfo" .. nGameType) or {};
                    if tbTeamInfo.nRank and tbTeamInfo.nRank <= tbDef.tbFinalsGame.nFrontRank then
                        nShowTxtUi = 2;
                    else
                        nShowTxtUi = 3;
                    end
                else
                    nShowTxtUi = 3;
                end
                for j=1,4 do
                    local nIndex = (i-1)*4+j
                    self.pPanel:SetActive("StateTxt" .. nIndex, j == nShowTxtUi)
                end

                local nFightTeamCount = tbGameFormat.nFightTeamCount
                self.pPanel:Label_SetText("Title" .. i, string.format("%s战队：%s", tbGameFormat.szName, tbFightTeam.szName))

                local tbAllPlayer = {};
                for nPlayerID, tbShowInfo in pairs(tbFightTeam.tbAllPlayer) do
                    local tbInfo = {};
                    tbInfo.nPlayerID = nPlayerID;
                    tbInfo.tbShowInfo = tbShowInfo;
                    table.insert(tbAllPlayer, tbInfo);
                end
                table.sort(tbAllPlayer, function (a, b)
                    return a.nPlayerID < b.nPlayerID;
                end)
                for j=1,4 do
                    local nIndex = (i-1)*4+j
                    if j <= nFightTeamCount then
                        self.pPanel:SetActive("Member" .. nIndex, true)
                        local tbInfo = tbAllPlayer[j];
                        if tbInfo then
                            self.pPanel:SetActive("Detail" .. nIndex, true)
                            self.pPanel:SetActive("Nobody" .. nIndex, false)
                            local tbShowInfo = tbInfo.tbShowInfo
                            local szFactionIcon = Faction:GetIcon(tbShowInfo.nFaction);
                            self.pPanel:Sprite_SetSprite("Faction"..nIndex, szFactionIcon);
                            self.pPanel:Label_SetText("Level"..nIndex, tostring(tbShowInfo.nLevel));
                            local nTmpBigFace = PlayerPortrait:CheckBigFaceId(tbShowInfo.nBigFace, tbShowInfo.nPortrait,
                                tbShowInfo.nFaction, tbShowInfo.nSex);
                            local szHead, szAtlas = PlayerPortrait:GetPortraitBigIcon(nTmpBigFace);
                            self.pPanel:Sprite_SetSprite("Role"..nIndex, szHead, szAtlas);
                            self.pPanel:Label_SetText("RoleName"..nIndex, tbShowInfo.szName);
                            self.pPanel:Label_SetText("Fighting"..nIndex, string.format("战力：%s", tbShowInfo.nFightPower));
                            if tbShowInfo.nHonorLevel > 0 then
                                self.pPanel:SetActive("PlayerTitle"..nIndex, true);
                                local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbShowInfo.nHonorLevel)
                                self.pPanel:Sprite_Animation("PlayerTitle"..nIndex, ImgPrefix, Atlas);
                            else
                                self.pPanel:SetActive("PlayerTitle"..nIndex, false);
                            end
                            if tbInfo.nPlayerID ~= me.dwID then
                                self["RoleBg" .. nIndex].pPanel.OnTouchEvent = function ()
                                    FriendShip:OnChatClickRolePopup(tbInfo.nPlayerID, nil,nil,nil,tbShowInfo.szName, "RoleSelect")
                                end
                            else
                                self["RoleBg" .. nIndex].pPanel.OnTouchEvent = nil;
                            end

                        else
                            self.pPanel:SetActive("Detail" .. nIndex, false)
                            self.pPanel:SetActive("Nobody" .. nIndex, true)
                            self["RoleBg" .. nIndex].pPanel.OnTouchEvent = nil;
                        end
                    else
                        self.pPanel:SetActive("Member" .. nIndex, false)
                    end
                end
            end
        end
    end
end

function tbUi:UpdateSignUpStage()
    self.pPanel:Texture_SetTexture("Texture", "UI/Textures/WLDH0.png");
    self.pPanel:SetActive("Panel1", true)
    self:UpdateLeftTime();

    local bCanSigUp = WuLinDaHui:IsCanSigUp(me)
    if bCanSigUp then
        self.pPanel:SetActive("QualificationSituation1", true)
        self.pPanel:SetActive("QualificationSituation2", false)
        self.pPanel:SetActive("QualificationSituation3", false)
        self.pPanel:SetActive("BtnBuy", false)
    else
        self.pPanel:SetActive("QualificationSituation1", false)
        self.pPanel:SetActive("QualificationSituation2", false)
        self.pPanel:SetActive("QualificationSituation3", true)
        self.pPanel:SetActive("BtnBuy", false)
    end

    local nSignTeamNum = WuLinDaHui:GetPlayerTeamNum()
    local bFullTeam = nSignTeamNum >= WuLinDaHui.tbDef.nMaxJoinTeamNum
    for i, v in ipairs(WuLinDaHui.tbGameFormat) do
        self.pPanel:Label_SetText("MatchTitle" .. i, v.szName)
        local tbDays = WuLinDaHui:GetGameTyoePreScheDayScope(i)
        local nMatchDayTime1 = self.nActEndTime + 3600 * 24 * (tbDays[1] - 1);
        local nMatchDayTime2 = self.nActEndTime + 3600 * 24 * (tbDays[#tbDays] - 1);
        local tbTime1 = os.date("*t", nMatchDayTime1);
        local tbTime2 = os.date("*t", nMatchDayTime2);
        self.pPanel:Label_SetText("SituationTime" .. i, string.format("初赛时间：%d月%d日-%d日%s，%s", tbTime1.month, tbTime1.day, tbTime2.day, WuLinDaHui.tbDef.tbStartMatchTime[1], WuLinDaHui.tbDef.tbStartMatchTime[2]))

        --队伍信息
        local tbTeamInfo = Player:GetServerSyncData("WLDHFightTeamInfo" .. i) or {};
        if not tbTeamInfo.szName then --未报名
            self.pPanel:SetActive("MatchSituation" .. i, false)
            self.pPanel:SetActive("Team" .. i, false)
            self.pPanel:SetActive("TeamName" .. i, false)
            self.pPanel:SetActive("BtnTip" .. i, false)
            self.pPanel:SetActive("BtnSignUp" .. i, true)
            self.pPanel:SetActive("BtnCancel" .. i, false)
            self.pPanel:SetActive("Describe" .. i, true)
            self.pPanel:Label_SetText("Describe" .. i, v.szDescTip)
            self.pPanel:Button_SetEnabled("BtnSignUp" .. i, not bFullTeam)
        else

            self.pPanel:SetActive("MatchSituation" .. i, true)
            self.pPanel:SetActive("Team" .. i, true)
            self.pPanel:SetActive("TeamName" .. i, true)
            self.pPanel:SetActive("BtnTip" .. i, true)
            self.pPanel:SetActive("BtnSignUp" .. i, false)
            self.pPanel:SetActive("BtnCancel" .. i, true)
            self.pPanel:SetActive("Describe" .. i, false)

            self.pPanel:Label_SetText("TeamName" .. i, tbTeamInfo.szName)
        end
    end
end



function tbUi:UpdateBattleType(nGameType)
    self.pPanel:SetActive("Panel1", false)
    self.pPanel:SetActive("Panel2", true)
    local szDescContent = tbDef.tbMatchUiDesc[nGameType]
    self.pPanel:Label_SetText("Content2", szDescContent)
    local tbGameFormat = WuLinDaHui.tbGameFormat[nGameType]
    self.pPanel:Texture_SetTexture("Texture", tbGameFormat.szTexture );
    local tbTeamInfo = Player:GetServerSyncData("WLDHFightTeamInfo" .. nGameType) or {};

    local nToday = Lib:GetLocalDay()
    local szTimeConent = ""
    local bCurPlayIng = false
    local bShowBtnBattlefield = false;
    local bShowBtnMatchRank = false;
    if self.szActName == WuLinDaHui.szActNameBaoMing then
        local tbTimeNode = WuLinDaHui:GetMatchTimeNode(nGameType, self.nActEndTime + 3600)
        local tbTime = os.date("*t",  tbTimeNode[1]);
        szTimeConent = string.format("初赛时间：%d月%d日%s", tbTime.month, tbTime.day, WuLinDaHui.tbDef.tbStartMatchTime[1])
        if WuLinDaHui:IsHasTicket() then
            self.pPanel:SetActive("BtnTeamRelated", true)
            self.pPanel:Button_SetText("BtnTeamRelated", "战队相关")
        else
            self.pPanel:SetActive("BtnTeamRelated", false)
        end

    elseif self.szActName == WuLinDaHui.szActNameMain then
        local tbTimeNode, nState = WuLinDaHui:GetCurTimeNode(nGameType)
        if nState == 1 or  nState == 3 or nState == 5 or nState == 7 then
            local tbTime = os.date("*t", tbTimeNode[nState]);
            szTimeConent =  string.format("初赛时间：%d月%d日%02d:%02d", tbTime.month, tbTime.day, tbTime.hour, tbTime.min)
        elseif nState == 2 or  nState == 4 or nState == 6 or nState == 8 then
            szTimeConent =  string.format("初赛进行中")
            bCurPlayIng = true
        elseif nState == 9 then
            local tbTime = os.date("*t", tbTimeNode[nState]);
            szTimeConent =  string.format("决赛时间：%d月%d日%02d:%02d", tbTime.month, tbTime.day, tbTime.hour, tbTime.min)
        else
            local _, _, nWinTeamId = Player:GetServerSyncData("WLDHTopPreFightTeamList" .. nGameType) ;
            if nWinTeamId or nState == 11 then
                szTimeConent = "比赛已结束"
            else
                szTimeConent =  "决赛进行中"
            end
        end

        bShowBtnBattlefield = nState >= 9;
        bShowBtnMatchRank = nState >= 2;

        if tbGameFormat.szPKClass == "PlayDuel" and  tbTeamInfo.szName then
            self.pPanel:SetActive("BtnTeamRelated", true)
            self.pPanel:Button_SetText("BtnTeamRelated", "调整编号")
        else
            if WuLinDaHui:IsCanSigUp(me, nGameType) then
                self.pPanel:SetActive("BtnTeamRelated", true)
                self.pPanel:Button_SetText("BtnTeamRelated", "战队相关")
            else
                self.pPanel:SetActive("BtnTeamRelated", false)
            end

        end
    end
    self.pPanel:SetActive("BtnMatchRank", bShowBtnMatchRank) --大于对应的初赛开启时间才显示初赛排行
    self.pPanel:SetActive("BtnBattlefield", bShowBtnBattlefield)
    if bShowBtnBattlefield and WuLinDaHui:CanGuessing(nGameType) then
        self.pPanel:SetActive("GuessingMark", true)
    else
        self.pPanel:SetActive("GuessingMark", false)
    end

    self.pPanel:Label_SetText("MatchTime", szTimeConent)

    local szJoinBtnName = "参加比赛";

    if not tbTeamInfo.szName then --未报名
        self.pPanel:SetActive("AlreadySignUp", false)
        self.pPanel:SetActive("TeamInformation", false)
        self.pPanel:SetActive("MatchLimite", true)
        self.pPanel:SetActive("TeamTip", false)

        ----只有报名阶段可以报名  报名时首先限定了资格 和队伍数
        if not WuLinDaHui:IsBaoMingTime(nGameType) then
            self.pPanel:Label_SetText("MatchLimite", "当前不可报名")
        else
            if not WuLinDaHui:IsCanSigUp(me, nGameType) then
                self.pPanel:Label_SetText("MatchLimite", "当前不具备报名资格")
            elseif WuLinDaHui:GetPlayerTeamNum(me) >= WuLinDaHui.tbDef.nMaxJoinTeamNum then
                self.pPanel:Label_SetText("MatchLimite", "您报名的比赛已达上限") --TODO 策划确认上限是指这个
            else
                self.pPanel:Label_SetText("MatchLimite", "您还未报名该比赛！\n请通过“战队相关--创建战队”来报名")
            end
        end
    else
        self.pPanel:SetActive("AlreadySignUp", true)
        self.pPanel:SetActive("TeamInformation", true)
        self.pPanel:SetActive("MatchLimite", false)
        self.pPanel:SetActive("TeamTip", true)
        self.pPanel:Label_SetText("TeamName", tbTeamInfo.szName)
        self.pPanel:Label_SetText("TeamTime", string.format("%s/%s", tbTeamInfo.nJoinCount or 0, WuLinDaHui.tbDef.nPreMatchJoinCount) )
        local fWinPer = WuLinDaHui.tbDef.nDefWinPercent * 100;
        if tbTeamInfo.nJoinCount > 0 then
            fWinPer = math.floor(100 * tbTeamInfo.nWinCount / tbTeamInfo.nJoinCount)
        end
        self.pPanel:Label_SetText("WinningProbability", fWinPer .. "%")
    end
    if bShowBtnBattlefield and (not tbTeamInfo or tbTeamInfo.nFinals ~= nGameType) then
        szJoinBtnName = "观战"
    end
    self.pPanel:Label_SetText("LbJoin", szJoinBtnName)
end

function tbUi:UpdateLeftTime2( )
    self:CloseTimer2()
    local fnTimer = function ()
        local nGetCurMatchLeftTime = self:GetCurMatchLeftTime()
        if not nGetCurMatchLeftTime then
            self.pPanel:Label_SetText("PreparationTime", "本场准备时间：0" )
            return
        end
        self.pPanel:Label_SetText("PreparationTime", string.format("本场准备时间：%s",Lib:TimeDesc3(nGetCurMatchLeftTime)) )
        self.nGetCurMatchLeftTime = nGetCurMatchLeftTime - 1;
        return true
    end
    fnTimer()
    self.nTimer2 = Timer:Register(Env.GAME_FPS * 1, fnTimer)
end

function tbUi:UpdateLeftTime()
    self:CloseTimer()

    local fnTimer = function ()
        local nNow = GetTime()
        local nLeftTime = math.max(self.nActEndTime - nNow, 0)
        if self.szActName == WuLinDaHui.szActNameYuGao then
            self.pPanel:Label_SetText("StartTime", string.format("大会即将开始：%s", Lib:TimeDesc5(nLeftTime)))
        else
            self.pPanel:Label_SetText("SignUpTime", string.format("正在报名：%s", Lib:TimeDesc5(nLeftTime)))
        end
        return true
    end
    fnTimer()
    self.nTimer = Timer:Register(Env.GAME_FPS * 1, fnTimer)
end

function tbUi:CloseTimer()
    if self.nTimer then
        Timer:Close(self.nTimer)
        self.nTimer = nil;
    end
end

function tbUi:CloseTimer2(  )
    if self.nTimer2 then
        Timer:Close(self.nTimer2)
        self.nTimer2 = nil;
    end
end

function tbUi:OnClose()
    self:CloseTimer()
end

function tbUi:OnLeaveMap()
    Ui:CloseWindow(self.UI_NAME)
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SYNC_DATA,  self.OnSyncData},
        {UiNotify.emNOTIFY_MAP_LEAVE,           self.OnLeaveMap},
    };

    return tbRegEvent;
end

function tbUi:OnSyncData(szType)
    if type(szType) == "string" and (string.find(szType, "WLDHFightTeam:") or string.find(szType,"WLDHFightTeamInfo") )  then
        self:Update();
    elseif type(szType) == "string" and string.find(szType,"WLDHTopPreFightTeamList") then
        self:Update();
    elseif szType == "WLDHRefreshMainUi" then
        self:Update();
    elseif szType == "WLDHCreateFightTeam" then
        self:CloseFightTeamUI();
    elseif szType == "WLDHJoinFightTeam" then
        self:CloseFightTeamUI();
    elseif szType == "WLDHQuitFightTeam" then
        self:CloseFightTeamUI();
    end
end

function tbUi:CloseFightTeamUI()
    if Ui:WindowVisible("TeamRelatedPanel") == 1 then
        Ui:CloseWindow("TeamRelatedPanel");
    end

    if Ui:WindowVisible("CreateTeamPanel") == 1 then
        Ui:CloseWindow("CreateTeamPanel");
    end
end

function tbUi:OnClickBtnTip(index)
    local tbTeamInfo = Player:GetServerSyncData("WLDHFightTeamInfo" .. index) or {};
    local nFightTeamID = tbTeamInfo.nFightTeamID
    if not nFightTeamID then
        me.CenterMsg("无战队信息")
        return
    end

    Ui:OpenWindow("TeamDetailsPanel", nFightTeamID, false, index);
end

function tbUi:OnClickBtnSignUp(index)
    if not WuLinDaHui:IsCanSigUp(me, index) then
        me.CenterMsg("很遗憾，阁下不具有参与武林大会的资格！", true)
        return
    end
    Ui:OpenWindow("CreateTeamPanel", index);
end

function tbUi:OnClickBtnCancel(index)
    RemoteServer.DoRequesWLDH("DeleteFightTeam", index);
end

function tbUi:GetCurMatchLeftTime(  )
    if not self.nGetCurMatchLeftTime or self.nGetCurMatchLeftTime <= 0 then
        RemoteServer.DoRequesWLDH("GetCurMatchLeftTime");
        return
    end
    if self.nGetCurMatchLeftTime then
        return self.nGetCurMatchLeftTime
    end
end

tbUi.tbOnClick = {}

tbUi.tbOnClick.BtnClose = function (self)
    Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick.BtnSignUpStage = function (self)
    self:Update()
end

tbUi.tbOnClick.BtnDoublesManMatch = function (self)
    self:Update()
end

tbUi.tbOnClick.BtnThreeManMatch = function (self)
    self:Update()
end

tbUi.tbOnClick.BtnThreeManDuel = function (self)
    self:Update()
end

tbUi.tbOnClick.BtnFourManMatch = function (self)
    self:Update()
end

tbUi.tbOnClick.BtnMyTeam = function (self)
    self:Update()
end

tbUi.tbOnClick.BtnTeamRelated = function (self)
    local nGameType = self:GetCurSelectGameType()
    assert(nGameType)
    Ui:OpenWindow("TeamRelatedPanel", nGameType)
end

tbUi.tbOnClick.BtnBattlefield = function (self)
    --只要初赛结束到决赛结束当天有决赛战报
    local nGameType = self:GetCurSelectGameType()
    assert(nGameType)
    Ui:OpenWindow("WLDHBattlefieldPanel", nGameType)
end

tbUi.tbOnClick.BtnJoin = function (self)
    local nToDayGameType = WuLinDaHui:GetToydayGameFormat()
    if not nToDayGameType then
        me.CenterMsg("今天没有比赛")
        return
    end

    local nGameType = self:GetCurSelectGameType()
    if nGameType ~= nToDayGameType then
        local tbGameFormat = WuLinDaHui.tbGameFormat[nToDayGameType]
        me.CenterMsg(string.format("今天举行的是%s", tbGameFormat.szName))
        return
    end
    RemoteServer.DoRequesWLDH("ApplyPlayGame");
end

tbUi.tbOnClick.BtnMatchRank = function (self)
    --初赛开始后更新，使用请求版本号
    local nGameType = self:GetCurSelectGameType()
    assert(nGameType)
    Ui:OpenWindow("WLDHRankPanel", nGameType)
end

tbUi.tbOnClick.TeamTip = function (self)
    local nGameType = self:GetCurSelectGameType()
    assert(nGameType)
    self:OnClickBtnTip(nGameType)
end

tbUi.tbOnClick.BtnTip = function (self)
    Ui:OpenWindow("NewInformationPanel", WuLinDaHui.tbDef.szNewsKeyNotify)
end


for i = 1, 4 do
    tbUi.tbOnClick["BtnTip" .. i] = function (self)
        self:OnClickBtnTip(i)
    end;

    tbUi.tbOnClick["BtnSignUp" .. i] = function (self)
        self:OnClickBtnSignUp(i)
    end;
    tbUi.tbOnClick["BtnCancel" .. i] = function (self)
        self:OnClickBtnCancel(i)
    end;
end

