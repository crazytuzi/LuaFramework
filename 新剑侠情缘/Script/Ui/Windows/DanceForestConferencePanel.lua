local tbUi = Ui:CreateClass("DanceForestConferencePanel");
local tbSetting = Activity.DanceMatch.tbSetting

function tbUi:OnOpen()
    self.tbData = {};
    self:UpdateUi()
    self:UpdateRankUi()
    self.pPanel:SetActive("Integral1", false)
    self.pPanel:SetActive("Integral2", false)
    self.pPanel:SetActive("Perfect2", false)
    self.pPanel:SetActive("Perfect4", false)
    
    self.pPanel:SetActive("LianJi", false)
    self.pPanel:SetActive("LianJiFraction", false)
end

function tbUi:GetCurData()
    return self.tbData
end

function tbUi:UpdateRankUi()
    local tbData = self:GetCurData()
    local szRank = "当前积分：-\n当前排名：-"
    if tbData.nMyScore and tbData.nMyRank then
        szRank = string.format("当前积分：%d\n当前排名：%d", tbData.nMyScore, tbData.nMyRank)
    end
    self.pPanel:Label_SetText("TxtRank", szRank)
end

function tbUi:UpdateUi()
    for i=1,10 do
        self.pPanel:SetActive("Arrow" .. i, false)
    end
    self.pPanel:SetActive("SliderFail", false)
    self.pPanel:SetActive("Sliderbar", true)
    local tbData = self:GetCurData()
    if tbData.nValidTimeTo and GetTime() > tbData.nValidTimeTo + 2 then
        self.pPanel:SetActive("ArrowGroup", false)
        return
    end

    if not tbData.tbCMDList then
        self.pPanel:SetActive("SliderFail", false)
        self.pPanel:ProgressBar_SetValue("SliderBg", 1)
        self.pPanel:SetActive("ArrowGroup", false)
       return 
    end
    self.pPanel:SetActive("ArrowGroup", true)
    
    local tbCmdStrToImg = tbSetting.tbCmdStrToImg
    local nFrom = math.floor( (10 - #tbData.tbCMDList) / 2)
    for i=1,10 do
        local szCmd = tbData.tbCMDList[i]
        if not szCmd then
            break;
        end
        local szArrow = "Arrow" .. (nFrom + i)
        self.pPanel:SetActive(szArrow, true)
        local szSprite = tbCmdStrToImg[szCmd]
        local szMyInput = tbData.tbInputList[i]
        self.pPanel:Sprite_SetSprite(szArrow, szSprite)
        if szMyInput and szMyInput == szCmd then
            self.pPanel:Sprite_SetColor(szArrow, 255,136,0)
        else
            self.pPanel:Sprite_SetColor(szArrow, 255,255,255)
            if szMyInput and szMyInput ~= szCmd then
                self.pPanel:SetActive("SliderFail", true)        
                self.pPanel:SetActive("Sliderbar", false)
            end
        end
    end

    local nNow = GetTime()
    if nNow > tbData.nValidTimeTo then
        if not tbData.bCommit then
            self.pPanel:SetActive("SliderFail", true)
            self.pPanel:SetActive("Sliderbar", false)
        end
    end

end

function tbUi:UpdateData()
    local tbData = self.tbData
    tbData.tbInputList = {}
    tbData.bCommit = nil;

    local tbCMDList, nValidTimeFrom, nValidTimeTo = Player:GetServerSyncData("DanceActCMD")
    local nNow = GetTime()
    nValidTimeFrom = math.max(nValidTimeFrom, nNow) --测试发现客户度的now会小于服务端
    tbData.tbCMDList = tbCMDList
    tbData.nValidTimeFrom = nValidTimeFrom
    tbData.nValidTimeTo = nValidTimeTo

    self:UpdateUi()

    if self.nTimer4 then
        Timer:Close(self.nTimer4)
        self.nTimer4 = nil;
    end

    if nNow < tbData.nValidTimeTo then
        local nDuraTime = math.max(tbData.nValidTimeTo - nNow -1, 0.1)
        self.pPanel:Tween_ProgressBarWhithCallback("SliderBg", 1, 0, nDuraTime, function () end)

        self.nTimer4 = Timer:Register(Env.GAME_FPS * (tbData.nValidTimeTo - nNow + 4), function ()
            self:UpdateUi()
            self.nTimer4 = nil; --没有指令后3秒就隐藏输入栏
        end)
        
    end
end

function tbUi:CloseTimer()
    if self.nTimer1 then
        Timer:Close(self.nTimer1)
        self.nTimer1 = nil
    end
    if self.nTimer2 then
        Timer:Close(self.nTimer2)
        self.nTimer2 = nil
    end
    if self.nTimer3 then
        Timer:Close(self.nTimer3)
        self.nTimer3 = nil
    end
    if self.nTimer4 then
        Timer:Close(self.nTimer4)
        self.nTimer4 = nil;
    end
    if self.nTimer5 then
        Timer:Close(self.nTimer5)
        self.nTimer5 = nil;
    end
    
end

function tbUi:OnSyncData(szType)
    if szType == "DanceActCMD" then
        self:UpdateData()
    elseif szType == "DanceActRankData" then
        local tbScoreRank = Player:GetServerSyncData("DanceActRankData")
        for i,v in ipairs(tbScoreRank) do
            if v[1] == me.dwID then
                self.tbData.nMyRank = i;
                self.tbData.nMyScore = v[2];
                break;
            end
        end
        self:UpdateRankUi();
    elseif szType == "DanceActGetScore" then
        local tbSynData = Player:GetServerSyncData("DanceActGetScore") 
        local nToTalScore, nWinAddScore, bPerfect = tbSynData.nToTalScore, tbSynData.nWinAddScore, tbSynData.bPerfect
        self.tbData.nMyScore = nToTalScore
        self:UpdateRankUi();
        self:ShowGetScore(nWinAddScore, bPerfect)
        self:ShowCombo(tbSynData.nComboAddScore, tbSynData.nCombo)
        
    end
end

function tbUi:ShowGetScore(nScore, bPerfect)
    local szPrefix = bPerfect and "Perfect" or "Integral"
    local szWnd = szPrefix .. nScore
    self.pPanel:SetActive(szWnd, true)
    self.pPanel:Tween_Play(szWnd)
    
    self.nTimer3 = Timer:Register(Env.GAME_FPS, function ( ... )
        self.nTimer3 = nil
        self.pPanel:SetActive(szWnd, false)
    end)
end

function tbUi:GetStrTuPianZi(nCombo)
    local szCombo = nCombo == 0 and "combo0" or ""
    while(nCombo > 0)
        do
        szCombo = string.format("combo%d%s", nCombo%10, szCombo)
        nCombo = math.floor(nCombo/10)
    end    
    return szCombo
end

function tbUi:ShowCombo(nComboAddScore, nCombo)
    self.pPanel:SetActive("LianJi", true)
    self.pPanel:Tween_Play("LianJi")
    local szCombo = self:GetStrTuPianZi(nCombo)
    self.pPanel:Label_SetText("ComboNumber", szCombo)
    if nComboAddScore then
        self.pPanel:SetActive("LianJiFraction", true)
        self.pPanel:Tween_Play("LianJiFraction")
        if self.nTimer5 then
            Timer:Close(self.nTimer5)
            self.nTimer5 = nil;
        end
        local szComboAddScore = self:GetStrTuPianZi(nComboAddScore)
        self.pPanel:Label_SetText("ComboNumber2", szComboAddScore)
        self.nTimer5 = Timer:Register(Env.GAME_FPS * 1, function ()
            self.nTimer5 = nil;
            self.pPanel:SetActive("LianJiFraction", false)
        end)
    end
end

function tbUi:OnRefreshUi( szType, ... )
    if szType == "OnError" then
        self.pPanel:SetActive("LianJi", false);
    end
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SYNC_DATA,  self.OnSyncData},
        { UiNotify.emNOTIFY_MAP_LEAVE,           self.OnLeaveMap},
        { UiNotify.emNOTIFY_REFRESH_DACNE_ACT_UI,           self.OnRefreshUi},
    };

    return tbRegEvent;
end

function tbUi:OnLeaveMap()
    Ui:CloseWindow(self.UI_NAME)
end

function tbUi:OnClose()
    self:CloseTimer()
    self.tbData = nil;
end

function tbUi:CheckCommit()
    local tbData = self:GetCurData()
    local tbInputList = tbData.tbInputList
    local tbCMDList = tbData.tbCMDList
    --在限定时间内 输完了或者中间错了就提交
    local nNow = GetTime()
    if nNow < tbData.nValidTimeFrom or nNow > tbData.nValidTimeTo then
        return
    end
    local bCOmmit = false
    local bInputError
    if #tbInputList == #tbCMDList then
        bCOmmit = true
    elseif #tbInputList < #tbCMDList then
        for i,v in ipairs(tbInputList) do
            if tbCMDList[i] ~= v then
                bCOmmit = true
                bInputError = true
                break
            end
        end        
    end
    if bCOmmit then
        return table.concat( tbInputList, ""), bInputError
    end
end

tbUi.tbOnClick = {};

function tbUi:OnClickDir( szCmd )
    local tbData = self:GetCurData()
    local tbInputList = tbData.tbInputList
    if not tbInputList then
        return
    end
    if tbData.bCommit then
        return
    end
    table.insert(tbInputList, szCmd)
    self:UpdateUi()
    local szDanceCmd,bInputError = self:CheckCommit()
    
    if szDanceCmd then
        tbData.bCommit  = true
        RemoteServer.DanceActRequest("CommitDanceCMD", szDanceCmd)
    end
    if bInputError then
        self.nTimer1 = Timer:Register(8, function ()
            self.pPanel:SetActive("SliderFail", false)
            self.nTimer1 = nil
        end)
        self.nTimer2 = Timer:Register(16, function ()
            self.pPanel:SetActive("SliderFail", true)
            self.nTimer2 = nil
        end)
    end
    
end

function tbUi.tbOnClick:BtnUpper()
    self:OnClickDir("3")
end

function tbUi.tbOnClick:BtnDown()
    self:OnClickDir("1")
end

function tbUi.tbOnClick:BtnLeft()
    self:OnClickDir("2")
end

function tbUi.tbOnClick:BtnRight()
    self:OnClickDir("4")
end