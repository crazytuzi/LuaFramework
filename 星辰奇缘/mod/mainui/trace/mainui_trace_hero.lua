MainuiTraceHero = MainuiTraceHero or BaseClass(BaseTracePanel)

function MainuiTraceHero:__init(main)
    self.main = main
    self.mgr = HeroManager.Instance
    self.model = self.mgr.model

    self.mgr.panel = self

    self.gameObject = nil
    self.tabObj = nil
    self.isInit = false

    self.phaseHandler = {
        [HeroEumn.Phase.Nostart] = function(self) self:PhaseNoBegin() end
        , [HeroEumn.Phase.Broadcast] = function(self) self:PhaseBroadcast() end
        , [HeroEumn.Phase.Ready] = function(self) self:PhaseReady() end
        , [HeroEumn.Phase.Battle] = function(self) self:PhaseBattle() end
        , [HeroEumn.Phase.Settle] = function(self) self:PhaseSettle() end
        , [HeroEumn.Phase.Reward] = function(self) self:PhaseReward() end
    }

    self.resList = {
        {file = AssetConfig.hero_content, type = AssetType.Main}
    }

    self.timeListener = function() self:OnTime() end
    self.infoListener = function() self:OnInfo() end

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiTraceHero:__delete()
    self.OnHideEvent:Fire()
end

function MainuiTraceHero:OnShow()
    self:RemoveListeners()
    self.mgr.onUpdateTime:AddListener(self.timeListener)
    self.mgr.onUpdateInfo:AddListener(self.infoListener)

    self:GotoPhase(self.mgr.phase)
end

function MainuiTraceHero:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MainuiTraceHero:OnHide()
    self:RemoveListeners()
end

function MainuiTraceHero:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.hero_content))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(0, -45, 0)

    local t = self.transform:Find("Panel")
    self.toggle = t:Find("Toggle"):GetComponent(Toggle)
    self.toggle.transform:Find("Background/Checkmark").gameObject:SetActive(true)
    self.toggle.transform:Find("Background/Checkmark"):GetComponent(RectTransform).anchoredPosition = Vector2(0, 3.15)
    local rect = t:Find("Toggle/Label"):GetComponent(RectTransform)
    rect.anchorMin = Vector2(0,0.5)
    rect.anchorMax = Vector2(0,0.5)
    rect.anchoredPosition = Vector2(92, 0)
    rect.sizeDelta = Vector2(150, 50)
    rect.gameObject:GetComponent(Text).alignment = 5
    self.titleText = t:Find("Title/Text"):GetComponent(Text)
    self.box1Obj = t:Find("BtnArea/Box1").gameObject
    self.box2Obj = t:Find("BtnArea/Box2").gameObject
    self.button1 = t:Find("BtnArea/Box1/Button"):GetComponent(Button)
    self.button2 = t:Find("BtnArea/Box2/Button"):GetComponent(Button)
    self.button1Text = t:Find("BtnArea/Box1/Button/Text"):GetComponent(Text)
    self.button2Text = t:Find("BtnArea/Box2/Button/Text"):GetComponent(Text)
    self.campBgObj = t:Find("CampBg").gameObject
    self.campText = t:Find("CampBg/Text"):GetComponent(Text)
    self.mainRect = t:GetComponent(RectTransform)

    t:Find("PhaseSettle").gameObject:SetActive(false)
    t:Find("PhaseReward").gameObject:SetActive(false)

    self.phaseObjList = {
        [HeroEumn.Phase.Ready] = t:Find("PhaseReady").gameObject,
        [HeroEumn.Phase.Battle] = t:Find("PhaseBattle").gameObject,
        [HeroEumn.Phase.Settle] = t:Find("PhaseBattle").gameObject,
        [HeroEumn.Phase.Reward] = t:Find("PhaseBattle").gameObject,
    }

    t = self.phaseObjList[HeroEumn.Phase.Ready].transform
    self.readyDescText = t:Find("Desc"):GetComponent(Text)
    self.readyTimeText = t:Find("TimeBg/Desc"):GetComponent(Text)

    t = self.phaseObjList[HeroEumn.Phase.Battle].transform
    self.battleReviveText = t:Find("Revive/Value"):GetComponent(Text)
    self.battleScoreText = t:Find("Score/Value"):GetComponent(Text)
    self.battleStatusText = t:Find("Status"):GetComponent(Text)
    t:Find("Score/Desc"):GetComponent(Text).text = TI18N("荣耀积分")

    -- t = self.phaseObjList[HeroEumn.Phase.Settle].transform
    -- self.settleVicImage = t:Find("Vic"):GetComponent(Image)
    -- self.settleTimeText = t:Find("Time"):GetComponent(Text)
    -- self.settleCampText = t:Find("Group"):GetComponent(Text)
    -- self.settleCampImage = t:Find("Image"):GetComponent(Image)

    t = self.phaseObjList[HeroEumn.Phase.Reward].transform
    self.titleText.text = self.mgr.name
    self.toggle.onValueChanged:RemoveAllListeners()
    self.toggle.isOn = self.model.hideStatus
    self.toggle.onValueChanged:AddListener(function(status) self:SetHide(status) end)
    -- self:SetHide(self.model.hideStatus)

    self.campBgObj:SetActive(true)
    self.isInit = true
end

function MainuiTraceHero:GotoPhase(phase)
    if self.isInit then
        -- print(debug.traceback())
        for k,v in pairs(self.phaseObjList) do
            v:SetActive(false)
        end
        if phase == nil or self.phaseObjList[phase] == nil then
            return
        end
        self.phaseObjList[phase]:SetActive(true)
        self.phaseHandler[phase](self)
        self:OnTime()
        self:OnInfo()
        -- print("<color=#FF0000>---------------------------</color> "..tostring(phase))
    end
end

function MainuiTraceHero:PhaseNoBegin()
end

function MainuiTraceHero:PhaseBroadcast()
end

function MainuiTraceHero:PhaseReady()
    self.box1Obj:SetActive(true)
    self.box2Obj:SetActive(true)
    self.button1Text.text = TI18N("组队")
    self.button2Text.text = TI18N("退出")
    self.readyDescText.text = self.mgr.ruleDesc
    self.toggle.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(5, 46)

    self.titleText.text = self.mgr.name
    -- if self.model.myInfo.series ~= nil then
    --     self.titleText.text = DataHeroData.data_series[self.model.myInfo.series].name
    -- else
    -- end

    if self.model.myInfo.group ~= nil then
        self.campText.text = self.mgr.campNames[self.model.myInfo.group]..TI18N("代表队")
    else
        self.campText.text = ""
    end
    self.button2.onClick:RemoveAllListeners()
    self.button2.onClick:AddListener(function() self.mgr:OnQuit() end)
    self.button1.onClick:RemoveAllListeners()
    self.button1.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team) end)
    self.mainRect.sizeDelta = Vector2(230, 250)
end

function MainuiTraceHero:PhaseBattle()
    self.box1Obj:SetActive(true)
    self.box2Obj:SetActive(true)
    self.button1Text.text = TI18N("组队")
    self.button2Text.text = TI18N("退出")

    self.battleStatusText.text = self.mgr.statusDesc[1]
    if self.model.myInfo.group ~= nil then
        self.campText.text = self.mgr.campNames[self.model.myInfo.group]..TI18N("代表队")
    else
        self.campText.text = ""
    end
    self.toggle.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(5, 10)
    self.button2.onClick:RemoveAllListeners()
    self.button2.onClick:AddListener(function() self.mgr:OnQuit() end)
    self.button1.onClick:RemoveAllListeners()
    self.button1.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team) end)
    self.mainRect.sizeDelta = Vector2(230, 220)
end

function MainuiTraceHero:PhaseReward()
    self.box1Obj:SetActive(false)
    self.box2Obj:SetActive(true)
    self.button2Text.text = TI18N("退出")

    self.battleStatusText.text = self.mgr.statusDesc[2]
    if self.model.myInfo.group ~= nil then
        self.campText.text = self.mgr.campNames[self.model.myInfo.group]..TI18N("代表队")
    else
        self.campText.text = ""
    end

    self.button2.onClick:RemoveAllListeners()
    self.button2.onClick:AddListener(function() self.mgr:OnQuit() end)
    self.mainRect.sizeDelta = Vector2(230, 220)
end

function MainuiTraceHero:PhaseSettle()
    self.box1Obj:SetActive(false)
    self.box2Obj:SetActive(true)
    self.button2Text.text = TI18N("退出")

    self.battleStatusText.text = self.mgr.statusDesc[2]
    if self.model.myInfo.group ~= nil then
        self.campText.text = self.mgr.campNames[self.model.myInfo.group]..TI18N("代表队")
    else
        self.campText.text = ""
    end

    self.button2.onClick:RemoveAllListeners()
    self.button2.onClick:AddListener(function() self.mgr:OnQuit() end)
    self.mainRect.sizeDelta = Vector2(230, 220)
end

function MainuiTraceHero:PhaseEnded()
end

function MainuiTraceHero:RemoveListeners()
    self.mgr.onUpdateTime:RemoveListener(self.timeListener)
    self.mgr.onUpdateInfo:RemoveListener(self.infoListener)
end

function MainuiTraceHero:OnTime()
    local restTime = self.model.restTime
    if restTime == nil or restTime < 0 then restTime = 0 end

    if self.mgr.phase == HeroEumn.Phase.Ready then
        self.readyTimeText.text = string.format(self.mgr.readyDescPattern, tostring(os.date("%M:%S",restTime)))
    end
end

function MainuiTraceHero:OnInfo()
    local model = self.model

    self.titleText.text = self.mgr.name
    -- if self.model.myInfo.series ~= nil then
    --     self.titleText.text = DataHeroData.data_series[model.myInfo.series].name
    -- else
    -- end

    -- self:GotoPhase(self.mgr.phase)

    if self.model.myInfo.group == nil then
        return
    end

    if self.mgr.phase == HeroEumn.Phase.Ready then
    elseif self.mgr.phase == HeroEumn.Phase.Battle then
        if self.model.myInfo ~= nil then
            self.battleReviveText.text = tostring(model.myInfo.die - 1)
            self.battleScoreText.text = tostring(model.myInfo.score)
        end
    elseif self.mgr.phase == HeroEumn.Phase.Settle then
        if self.model.myInfo ~= nil then
            self.battleReviveText.text = tostring(model.myInfo.die - 1)
            self.battleScoreText.text = tostring(model.myInfo.score)
        end
    elseif self.mgr.phase == HeroEumn.Phase.Reward then
        if self.model.myInfo ~= nil then
            self.battleReviveText.text = tostring(model.myInfo.die - 1)
            self.battleScoreText.text = tostring(model.myInfo.score)
        end
    end

    if self.model.myInfo ~= nil then
        self.campText.text = self.mgr.campNames[self.model.myInfo.group]..TI18N("代表队")
    else
        self.campText.text = ""
    end
end

function MainuiTraceHero:SetHide(isHide)
    self.mgr:SetHeroHide(isHide)
end

