local tbUi = Ui:CreateClass("NewInformationPanel")
tbUi.tbEvent = tbUi.tbEvent or {} --使用方式参考tbEvent.Main，子页面的名字作为Key（不能使用Main，Main由主页面使用）
tbUi.tbEvent.Main = {[UiNotify.emNOTIFY_ONSYNC_NEWINFORMATION] = "OnSyncData",
                     [UiNotify.emNOTIFY_WND_OPENED] = "WndOpened",
                     [UiNotify.emNOTIFY_BEAUTY_VOTE_AWARD] = "OnSubPanelNotify",
                     [UiNotify.emNOTIFY_LOAD_RES_FINISH] = "LoadBodyFinish"}
tbUi.tbEvent.NYLottery = {[UiNotify.emNOTIFY_CHOUJIANG_CHECK_DATA] = "ShowUi"}
function tbUi:RegisterEvent()
    local tbEventId = {}
    local tbRegisterEvent = {}
    for _, tbInfo in pairs(self.tbEvent) do
        for nEvent in pairs(tbInfo) do
            if not tbEventId[nEvent] then
                local fnName = string.format("OnUiNotify_%d", nEvent)
                self[fnName] = function (tbMainInst, ...)
                    tbMainInst:OnUiNotify(nEvent, ...)
                end
                table.insert(tbRegisterEvent, {nEvent, self[fnName]})
                tbEventId[nEvent] = true
            end
        end
    end
    return tbRegisterEvent
end

function tbUi:OnUiNotify(nEvent, ...)
    local szMainFunc = self.tbEvent.Main[nEvent]
    if szMainFunc then
        self[szMainFunc](self, ...)
    end
    if self.szCurKey then
        local szWndcom = NewInformation:GetActivityUi(self.szCurKey)
        local szFunc = szWndcom and self.tbEvent[szWndcom] and self.tbEvent[szWndcom][nEvent]
        if szFunc and self[szWndcom] and self[szWndcom][szFunc] then
            self[szWndcom][szFunc](self[szWndcom], ...)
        end
    end
end

function tbUi:OnOpenEnd(szKey)
    RankActivity:SynLevelRankData()

    local bImperialExam = self:CheckPandoraTab("ImperialExam", szKey);
    local bLuckyStar = self:CheckPandoraTab("LuckyStar", szKey);

    if szKey or not (bImperialExam or bLuckyStar) then
        self:Update(szKey)
    end

    if not (bImperialExam or bLuckyStar) then
        self.pPanel:SetActive("BtnNew", false)
    end
end

--优先默认选中的顺序
local tbPandoraPriority =
{
    "ImperialExam",
    "LuckyStar",
}

function tbUi:GetPandoraTabPriority()
    for _, szKey in ipairs( tbPandoraPriority ) do
        if Pandora:IsShowIcon("NewInformationPanel", szKey) then
            return szKey
        end
    end
end

function tbUi:CheckPandoraTab(szKey, szOpenKey)
    if Pandora:IsShowIcon("NewInformationPanel", szKey) then
        self.pPanel:SetActive("BtnNew", true)
        self.pPanel:SetActive("Btn" .. szKey, true)

        local nDate = Client:GetFlag("NewInformationPanel_" .. szKey)
        local nToday = Lib:GetLocalDay()
        if not szOpenKey and (not nDate or nDate ~= nToday) then
            if self:GetPandoraTabPriority() == szKey then
                    Client:SetFlag("NewInformationPanel_" .. szKey, nToday)
                    self.pPanel:Toggle_SetChecked("Btn" .. szKey,true)
                    self.pPanel:Toggle_SetChecked("BtnNew",false)
                    self.tbOnClick["Btn" .. szKey](self)
                end
            else
                self.pPanel:Toggle_SetChecked("Btn" .. szKey,false)
                self.pPanel:Toggle_SetChecked("BtnNew",true)
                self:Update(szOpenKey)
            end

        return true
    end

    self.pPanel:SetActive("Btn" .. szKey, false)

    return false
end

function tbUi:Update(szKey)
    self.tbShowAct = NewInformation:GetShowActivity() or {}

    local bHaveAct2Show = #self.tbShowAct > 0
    self.pPanel:SetActive("NoInfo", not bHaveAct2Show)
    self.pPanel:SetActive("ScrollViewCatalog", bHaveAct2Show)
    self.pPanel:SetActive("Content", bHaveAct2Show)
    if not bHaveAct2Show then
        return
    end

    self.szOldKey = self.szCurKey

    if szKey then
        self.szCurKey = szKey
    end

    local bKeyValid = false --消息会过期，所以这个Key也会过期
    if self.szCurKey then
        for _, szKey in ipairs(self.tbShowAct or {}) do
            if self.szCurKey == szKey then
                bKeyValid = true
                break
            end
        end
    end
    self.szCurKey = bKeyValid and self.szCurKey or self.tbShowAct[1]

    local fnOnSelect = function (btn)
        local szUi = NewInformation:GetActivityUi(self.szCurKey)
        if self[szUi] and self[szUi].OnClose then
            self[szUi]:OnClose()
        end

        if btn.szActKeyName then
            btn.pPanel:SetActive("New", false);
            Activity:SetRedPointShow(btn.szActKeyName);
            Activity:CheckRedPoint();
        end

        if self.szCurKey ~= btn.szKey then
            NewInformation:OnSwitchTab(self.szCurKey)
        end

        self:Update(btn.szKey)
    end

    local fnSetItem = function (tbItemObj, nIdx)
        local szKey     = self.tbShowAct[nIdx]
        local tbActInfo = NewInformation:GetInfoDetail(szKey)
        local szShowName = Pandora:GetShowName(self.UI_NAME, tbActInfo[4])
        szShowName = szShowName or tbActInfo[2]

        Ui.UnRegisterRedPoint(tbActInfo[1])
        tbItemObj.pPanel:RegisterRedPoint("New", tbActInfo[1])

        local szActKeyName = Activity:GetActKeyName(tbActInfo[1]);
        if szActKeyName then
            tbItemObj.pPanel:SetActive("New", not Activity:CheckRedPointShowed(szActKeyName));
            tbItemObj.szActKeyName = szActKeyName;
        end

        tbItemObj.szKey = self.tbShowAct[nIdx]
        tbItemObj.pPanel.OnTouchEvent = fnOnSelect;

        local bCurAct = self.tbShowAct[nIdx] == self.szCurKey
        tbItemObj.pPanel:SetActive("Dark", not bCurAct)
        tbItemObj.pPanel:SetActive("Light", bCurAct)

        if NewInformation.tbGetTitle[szKey] then
            local szTitle = NewInformation.tbGetTitle[szKey]()
            if szTitle then
                szShowName = szTitle
            end
        end
        tbItemObj.pPanel:Label_SetText("Dark", szShowName)
        tbItemObj.pPanel:Label_SetText("Light", szShowName)

        tbItemObj.pPanel:Toggle_SetChecked("Main", bCurAct)

        local nType = NewInformation:GetOperationType(szKey)
        for i = 1, 9 do
            if not tbItemObj.pPanel:CheckHasChildren("Mark" .. i) then
                break
            end
            tbItemObj.pPanel:SetActive("Mark" .. i, i == nType)
        end
    end
    self.ScrollViewCatalog:Update(#self.tbShowAct, fnSetItem)

    if self.szCurKey ~= self.szOldKey then
        NewInformation:OnClickTab(self.szCurKey)
    end

    local tbData = NewInformation:GetActData(self.szCurKey)
    NewInformation:OnOpenUi(self.szCurKey)
    if tbData then
        self:OpenActivityUi(self.szCurKey, tbData)
    end
end

function tbUi:OnSyncData(szKey, tbData)
    if self.szCurKey == szKey then
        self:OpenActivityUi(self.szCurKey, tbData)
    end
end

function tbUi:OpenActivityUi(szKey, tbData)
    local szUi = NewInformation:GetActivityUi(self.szCurKey)
    self.pPanel:SwitchSubPanel("Content", szUi)
    self[szUi].szCurNewInfoKey = szKey
    self[szUi]:OnOpen(tbData)
end

function tbUi:OnClose()
    local tbUi =  self:GetCurWndPanel();
    if tbUi and tbUi.OnClose then
        tbUi:OnClose()
    end
    self.tbShowAct = {}
    self.szOldKey = nil
    self.szCurKey = nil
    self.szCurPandoraKey = nil
    Pandora:ClosePanel(self.UI_NAME)
end

function tbUi:WndOpened(szUiName)
    if szUiName == "CommonShop" then
        Ui:CloseWindow(self.UI_NAME)
    end
end

function tbUi:GetCurWndPanel()
    if not self.szCurKey then
        return
    end
    local szUi = NewInformation:GetActivityUi(self.szCurKey)
    if not szUi then
        return
    end
    return self[szUi]
end

function tbUi:OnSubPanelNotify(nEvent, ...)
    local tbUi =  self:GetCurWndPanel();
    if tbUi and type(tbUi.OnSubPanelNotify) == "function" then
        tbUi:OnSubPanelNotify(nEvent, self, ...);
    end
end

function tbUi:LoadBodyFinish(nViewId)
    local tbUi =  self:GetCurWndPanel();
    if tbUi and type(tbUi.LoadBodyFinish) == "function" then
        tbUi:LoadBodyFinish(nViewId)
    end
end

function tbUi:OnClickPandoraTab(szKey)
    self.pPanel:SetActive("NoInfo", false)
    self.pPanel:SetActive("ScrollViewCatalog", false)
    self.pPanel:SetActive("Content", false)
    Ui:ClearRedPointNotify("Btn" .. szKey)
    if self.szCurKey then
        local szUi = NewInformation:GetActivityUi(self.szCurKey)
        if szUi and self[szUi].OnClose then
            self[szUi]:OnClose()
        end

        NewInformation:OnSwitchTab(self.szCurKey)
        self.szOldKey = nil
        self.szCurKey = nil
    end

    if self.szCurPandoraKey then
        Pandora:Hide("NewInformationPanel", self.szCurPandoraKey)
        self.szCurPandoraKey = nil
    end

    Pandora:Open("NewInformationPanel", szKey)
    self.szCurPandoraKey = szKey
end


tbUi.tbOnClick = {
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end
}

tbUi.tbOnClick.BtnNew = function (self)
    if self.szCurPandoraKey then
        Pandora:Hide("NewInformationPanel", self.szCurPandoraKey)
    end

    self:Update()
end

tbUi.tbOnClick.BtnLuckyStar = function (self)
    self:OnClickPandoraTab("LuckyStar")
end

tbUi.tbOnClick.BtnImperialExam = function (self)
    self:OnClickPandoraTab("ImperialExam")
end

local tbNormalUi = Ui:CreateClass("NewInformationPanel_Normal")
function tbNormalUi:OnOpen(tbData)
	self.fnBtnCallBack = nil
    local szContent = string.gsub(tbData[1] or "", "\\n", "\n")
    self.Content:SetLinkText(szContent)

    self.tbSetting = NewInformation.tbActivity[self.szCurNewInfoKey] or NewInformation.tbLocalSetting[self.szCurNewInfoKey] or {};

    local tbTextSize = self.pPanel:Label_GetPrintSize("Content")
    local tbSize = self.pPanel:Widget_GetSize("datagroup");
    self.pPanel:Widget_SetSize("datagroup", tbSize.x, 50 + tbTextSize.y);
    self.pPanel:DragScrollViewGoTop("datagroup");
    self.pPanel:UpdateDragScrollView("datagroup");

    local bShowBtn = false;
    if self.tbSetting and not Lib:IsEmptyStr(self.tbSetting.szBtnName) and not Lib:IsEmptyStr(self.tbSetting.szBtnTrap) then
        bShowBtn = true;
        self.pPanel:Label_SetText("NormalTxt", self.tbSetting.szBtnName);
    elseif type(tbData[3])  == "function" and not Lib:IsEmptyStr(tbData[2]) then
        bShowBtn = true;
        self.pPanel:Label_SetText("NormalTxt", tbData[2]);
        self.fnBtnCallBack = tbData[3]
    end

    self.pPanel:SetActive("BtnNormal", bShowBtn);
end

tbNormalUi.tbOnClick = tbNormalUi.tbOnClick or {};
tbNormalUi.tbOnClick.BtnNormal = function (self)
    if self.fnBtnCallBack then
        self.fnBtnCallBack()
        return
    end
    if not self.tbSetting or Lib:IsEmptyStr(self.tbSetting.szBtnTrap) then
        return;
    end

    Ui.HyperTextHandle:Handle(self.tbSetting.szBtnTrap, 0, 0);
    if self.tbSetting.nBtnCloseWnd and self.tbSetting.nBtnCloseWnd == 1 then
        Ui:CloseWindow("NewInformationPanel");
    end
end