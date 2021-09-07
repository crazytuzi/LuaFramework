-- 嘉俊 自动历练模式选择窗口
AutoModeSelectWindow  =  AutoModeSelectWindow or BaseClass(BaseWindow)

function AutoModeSelectWindow:__init(model)
    self.name  =  "AutoModeSelectWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.auto_mode_select_window, type  =  AssetType.Main}
    }

    self.currentChosenItem = nil -- 当前选择的模式，默认选择为全自动

    self.index = index  -- index为1-2，是用来区分自动模式的
    self.curSelectItem = curSelectItem

    self.ToggleGroup = nil
    self.ToggleFullAuto = nil
    self.ToggleHalfAuto = nil

    self.okBtn = nil
    self.cancelBtn = nil

    self.is_open = false
    return self
end


function AutoModeSelectWindow:__delete()

    self.currentChosenItem = nil

    self.index = nil
    self.data_table = nil

    self.ToggleGroup = nil
    self.ToggleFullAuto = nil
    self.ToggleHalfAuto = nil

    self.hasChain = false

    self.okBtn = nil
    self.cancelBtn = nil

    self.is_open = false

    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function AutoModeSelectWindow:InitPanel()
    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.auto_mode_select_window))
    self.gameObject.name  =  "AutoModeSelectWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseAutoModeSelectWindow() end)

    self.MainCon = self.transform:FindChild("MainCon")

    self.ToggleGroup = self.MainCon:FindChild("ToggleGroup")
    self.ToggleFullAuto = self.ToggleGroup:FindChild("ToggleFullAuto"):GetComponent(Toggle)
    self.FullAuto = self.ToggleGroup:FindChild("ToggleFullAuto")
    self.FullAutoBgBox = self.FullAuto:FindChild("BackgroundBox"):GetComponent(Image)
    self.ToggleHalfAuto = self.ToggleGroup:FindChild("ToggleHalfAuto"):GetComponent(Toggle)
    self.HalfAuto = self.ToggleGroup:FindChild("ToggleHalfAuto")
    self.HalfAutoBgBox = self.HalfAuto:FindChild("BackgroundBox"):GetComponent(Image)

    self.helpMsg = self.MainCon:FindChild("HelpMsg")
    self.helpTxt = self.helpMsg:FindChild("HelpTxt"):GetComponent(Text)
    self.helpTxt.text = TI18N("<color=#ffff00>全自动</color>模式下，将<color>自动随机</color>购买所需物品")

    self.okBtn = self.MainCon:FindChild("Okbtn"):GetComponent(Button)
    self.cancelBtn = self.MainCon:FindChild("CancelBtn"):GetComponent(Button)

    self.okBtn.transform:Find("Text"):GetComponent(Text).text = TI18N("确认模式")

    self.ToggleFullAuto.onValueChanged:AddListener(function()
        self.currentChosenItem = 1
        self.FullAutoBgBox.color = Color(0.5,1,1)
        self.HalfAutoBgBox.color = Color(1,1,1)
        self.helpTxt.text = TI18N("<color=#ffff00>全自动</color>模式下，将<color=#ffff00>自动随机</color>购买所需物品")
    end)
    self.ToggleHalfAuto.onValueChanged:AddListener(function()
        self.currentChosenItem = 2
        self.HalfAutoBgBox.color = Color(0.5,1,1)
        self.FullAutoBgBox.color = Color(1,1,1)
        self.helpTxt.text = TI18N("<color=#ffff00>半自动</color>模式下，将<color=#ffff00>不会自动</color>购买所需物品")
    end)

    local roleData = RoleManager.Instance.RoleData -- 往下三行 by 嘉俊 2017/8/28 17：30
    local key = BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id, "chain_automode")
    local autoMode = PlayerPrefs.GetInt(key) or 1
    if autoMode == 1 then
        self.ToggleFullAuto.isOn = true;
        self.currentChosenItem = 1; -- 默认选择全自动
        self.FullAutoBgBox.color = Color(0.5,1,1)
    else
        self.ToggleHalfAuto.isOn = true;
        self.currentChosenItem = 2
        self.HalfAutoBgBox.color = Color(0.5,1,1)
    end

    self.okBtn.onClick:AddListener(function()
        self:SetAutoMode()
        self.model:CloseAutoModeSelectWindow()
    end)

    self.cancelBtn.onClick:AddListener(function()
        self.model:CloseAutoModeSelectWindow()
    end)

    for key, value in pairs(QuestManager.Instance.questTab) do
        if value.sec_type == QuestEumn.TaskType.chain then
            self.hasChain = true
            self.MainCon:FindChild("Okbtn/Text"):GetComponent(Text).text = TI18N("继续跑环")
        end
    end
    self.helpTxt.text = TI18N("<color=#ffff00>全自动</color>模式下，将<color=#ffff00>自动随机</color>购买所需物品")

    self.is_open = true
end

function AutoModeSelectWindow:SetAutoMode()
    local roleData = RoleManager.Instance.RoleData
    local key = BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id, "chain_automode")
    if self.currentChosenItem == 1 then
        PlayerPrefs.SetInt(key,self.currentChosenItem)
        self.model.autoMode = self.currentChosenItem
        NoticeManager.Instance:FloatTipsByString(TI18N("当前跑环模式切换为：<color='#ffff00'>全自动</color>"))
    elseif self.currentChosenItem == 2 then
        PlayerPrefs.SetInt(key,self.currentChosenItem)
        self.model.autoMode = self.currentChosenItem
        NoticeManager.Instance:FloatTipsByString(TI18N("当前跑环模式切换为：<color='#ffff00'>半自动</color>"))
    end
    if self.hasChain then
        AutoQuestManager.Instance.model:AutoQuestSetting(1)
        AutoQuestManager.Instance.autoQuest:Fire()
    else
        QuestManager.Instance:Send10211(QuestEumn.TaskType.chain)
    end

end
-- function StrategyModel:SaveDraft()
--     local roleData = RoleManager.Instance.RoleData
--     local key = BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id, "strategy_draft")
--     self.draftTab = self.draftTab or {}
--     local str = BaseUtils.serialize(self.draftTab, nil, true, 0)
--     PlayerPrefs.SetString(key, str)
-- end

-- function StrategyModel:ReadDraft()
--     local roleData = RoleManager.Instance.RoleData
--     local key = BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id, "strategy_draft")
--     local str = PlayerPrefs.GetString(key)
--     if str == nil or str == "" or str == "nil" then
--         str = "{}"
--     end
--     self.draftTab = BaseUtils.unserialize(str)
--     BaseUtils.dump(self.draftTab)
-- end

