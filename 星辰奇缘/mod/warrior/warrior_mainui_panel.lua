WarriorMainUIPanel = WarriorMainUIPanel or BaseClass(BasePanel)

function WarriorMainUIPanel:__init(model)
    self.model = model

    self.resList = {
        {file = AssetConfig.warriorMainUIPanel, type = AssetType.Main},
        {file = AssetConfig.warrior_textures, type = AssetType.Dep},
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.endFightListener = function() self.isShow = false self:Dropdown() end
    self.beginFightListener = function() self.isShow = true self:Dropdown() end


    self.isShow = true
end

function WarriorMainUIPanel:__delete()
    self.OnHideEvent:Fire()

    if self.timeId ~= nil then
        LuaTimer.Delete(self.timeId)
        self.timeId = nil
    end

    self:AssetClearAll()
end

function WarriorMainUIPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.warriorMainUIPanel))
    self.gameObject.name = "ScoreBar"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(MainUIManager.Instance.MainUICanvasView.gameObject, self.gameObject)

    local main = self.transform:Find("Main")
    self.group1Text = main:Find("Group1"):GetComponent(Text)
    self.group2Text = main:Find("Group2"):GetComponent(Text)
    self.score1Text = main:Find("Score1"):GetComponent(Text)
    self.score2Text = main:Find("Score2"):GetComponent(Text)

    self.btn = main.gameObject:GetComponent(Button)
    if self.btn == nil then
        self.btn = main.gameObject:AddComponent(Button)
    end

    self.mainObj = main.gameObject
    local btn = self.transform:Find("MapMask"):GetComponent(Button)
    self.mapMaskObj = btn.gameObject
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function()
        local phase = WarriorManager.Instance.model.phase
        if phase == 3 then
            WarriorManager.Instance:OnExit(1)
        elseif phase == 4 or phase == 5 or phase == 6 then
            WarriorManager.Instance:OnExit(2)
        end
    end)
    btn.gameObject:SetActive(false)

    self.countDownObj = main:Find("CountDown").gameObject
    self.countDownText = main:Find("CountDown/Text"):GetComponent(Text)

    self.btn.onClick:RemoveAllListeners()
    self.btn.onClick:AddListener(function()
        if (CombatManager.Instance.isFighting ~= true or CombatManager.Instance.isWatching == true) and self.model.phase == 4 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.warrior_window)
        end
    end)

    self.dropDownBtn = self.transform:Find("Dropdown"):GetComponent(Button)
    -- self.dropDownBtn.gameObject:SetActive(false)

    self.mainObj = main.gameObject
    self.dropDownBtn.transform.localScale = Vector3(1, 1, 1)
    self.dropDownBtn.onClick:AddListener(function() self:Dropdown() end)
end

function WarriorMainUIPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function WarriorMainUIPanel:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.begin_fight, self.beginFightListener)
    EventMgr.Instance:AddListener(event_name.end_fight, self.endFightListener)

    self.model:UpdateScene()
end

function WarriorMainUIPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self.beginFightListener)
    EventMgr.Instance:RemoveListener(event_name.end_fight, self.endFightListener)
end

function WarriorMainUIPanel:OnHide()
    self:RemoveListeners()
end

function WarriorMainUIPanel:ShowCountDown()
    if self.model.phase == 4 then
        self.countDownObj:SetActive(true)
        self:SetRestTime(self.model.restTime)
        if self.isShow == true then
            self.dropDownBtn.transform.anchoredPosition = Vector2(0, -90)
        else
            self.dropDownBtn.transform.anchoredPosition = Vector2(0, -13)
        end
    else
        if self.isShow == true then
            self.dropDownBtn.transform.anchoredPosition = Vector2(0, -67)
        else
            self.dropDownBtn.transform.anchoredPosition = Vector2(0, -13)
        end
        self.countDownObj:SetActive(false)
        if self.timeId ~= nil then
            LuaTimer.Delete(self.timeId)
            self.timeId = nil
        end
    end
end

function WarriorMainUIPanel:UpdateScore()
    if self.score2Text ~= nil then
        self.score2Text.text = tostring(self.model.score2)..TI18N("分")
    end
    if self.score1Text ~= nil then
        self.score1Text.text = tostring(self.model.score1)..TI18N("分")
    end
end

function WarriorMainUIPanel:SetRestTime(restTime)
    if restTime == nil then
        return
    end
    if self.timeId ~= nil then
        LuaTimer.Delete(self.timeId)
    end
    self.restTime = restTime
    self.timeId = LuaTimer.Add(0, 1000, function() self:CountDown() end)
end

function WarriorMainUIPanel:CountDown()
    if self.restTime == nil or self.restTime <= 0 then
        LuaTimer.Delete(self.timeId)
        self.timeId = nil
        return
    end
    self.countDownText.text = os.date("%M:%S", self.restTime)
    self.restTime = self.restTime - 1
end

function WarriorMainUIPanel:Dropdown()
    if self.isShow == true then
        self.mainObj:SetActive(false)
        self.dropDownBtn.transform.localScale = Vector3(1, -1, 1)
        self.dropDownBtn.transform.anchoredPosition = Vector2(0, -13)
    else
        self.mainObj:SetActive(true)
        self.dropDownBtn.transform.localScale = Vector3(1, 1, 1)
        if self.model.phase == 4 then
            self.dropDownBtn.transform.anchoredPosition = Vector2(0, -90)
        else
            self.dropDownBtn.transform.anchoredPosition = Vector2(0, -67)
        end
    end
    self.isShow = not self.isShow
end

