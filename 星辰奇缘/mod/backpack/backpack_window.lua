BackpackWindow = BackpackWindow or BaseClass(BaseWindow)

function BackpackWindow:__init(model)
    self.model = model
    self.name = "BackpackWindow"
    self.windowId = WindowConfig.WinID.backpack
    self.cacheMode = CacheMode.Visible
    self.resList = {
        {file = AssetConfig.backpack_main, type = AssetType.Main},
        -- {file = AssetConfig.strategy_textures, type = AssetType.Dep},
        {file = AssetConfig.talisman_textures, type = AssetType.Dep},
    }

    self.checkRedListener = function() self:CheckRedPoint() end

    self.OnOpenEvent:Add(function() self:OnOpen() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.currentTabIndex = 1
end

function BackpackWindow:__delete()
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    self.model:Destroy()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model = nil
    self.openArgs = nil
end

function BackpackWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.backpack_main))
    self.gameObject.name = "BackpackWindow"
    self.gameObject:GetComponent(Canvas).sortingOrder = 20
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.title = self.gameObject.transform:Find("Main/Title/Text"):GetComponent(Text)
    self:ChangeTitle(TI18N("背包"))
    self.closeBtn = self.gameObject.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)
    self.tabGroupObj = self.gameObject.transform:Find("Main/TabButtonGroup").gameObject
    local setting = {
        notAutoSelect = true,
        noCheckRepeat = true,
        openLevel = {0, 0, 12, 65},
        perWidth = 62,
        perHeight = 100,
        isVertical = true
    }
    if BaseUtils.IsVerify == true then
        setting.openLevel = {0, 999, 12, 65}
    end
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:TabChange(index) end, setting)
end

function BackpackWindow:OnInitCompleted()
    -- 非依赖资源，UI创建完就可以卸载
    self:ClearMainAsset()

    self.OnOpenEvent:Fire()
end

function BackpackWindow:OnClickClose()
    self.model:CloseMain()
end

function BackpackWindow:ChangeTitle(str)
    if str ~= nil and str ~= "" then
        self.title.text = str
    end
end

function BackpackWindow:OnOpen()
    WingsManager.Instance.onUpdateRed:RemoveListener(self.checkRedListener)
    EventMgr.Instance:RemoveListener(event_name.talisman_item_change, self.checkRedListener)
    WingsManager.Instance.onUpdateRed:AddListener(self.checkRedListener)
    EventMgr.Instance:AddListener(event_name.talisman_item_change, self.checkRedListener)

    self:CheckRedPoint()
    GuideManager.Instance.effect:Hide()
    if self.openArgs ~= nil and self.openArgs[1] ~= nil then
        self.tabGroup:ChangeTab(self.openArgs[1])
    else
        self.tabGroup:ChangeTab(self.currentTabIndex)
    end

    if self:CheckWingGuide() then
        GuideManager.Instance:OpenWindow(self.windowId)
        local btn_wing = self.tabGroupObj.transform:Find("Button3");
        GuideManager.Instance.effect:Show(btn_wing.gameObject, Vector2(30,0))
        TipsManager.Instance:ShowGuide({gameObject = btn_wing.gameObject, data = TI18N("进入翅膀界面"), forward = TipsEumn.Forward.Left})
        self.isGuide = true
    end
end

function BackpackWindow:OnHide()
    WingsManager.Instance.onUpdateRed:RemoveListener(self.checkRedListener)
    EventMgr.Instance:AddListener(event_name.talisman_item_change, self.checkRedListener)
    if self:CheckWingGuide() then
        GuideManager.Instance:Finish()
    end
    self.openArgs = nil
    self.model:Hide()
end

function BackpackWindow:ShowCloseGuide()
    GuideManager.Instance.effect:Hide()
    GuideManager.Instance.effect:Show(self.closeBtn.gameObject, Vector2(-30,-30))
    TipsManager.Instance:ShowGuide({gameObject = self.closeBtn.gameObject, data = TI18N("升到二阶就可以飞行啦,"), forward = TipsEumn.Forward.Left})
end

function BackpackWindow:TabChange(index)
    if index ~= 4 then
        self.currentTabIndex = index
    end
    self.model:SwitchTab(index)
end

function BackpackWindow:CheckRedPoint()
    if self.tabGroup ~= nil then
        -- local wing_red = false
        -- for _,v in pairs(WingsManager.Instance.redPointDic) do
        --     wing_red = wing_red or (v == true)
        -- end
        self.tabGroup.buttonTab[3].red:SetActive(WingsManager.Instance:Upgradable())-- or (WingsManager.Instance:CheckSkillRed() and not WingsManager.Instance.isCheckSkillPanel))

        self.tabGroup.buttonTab[4].red:SetActive(TalismanManager.Instance.isShow ~= true)
    end
end

function BackpackWindow:CheckWingGuide()
    local quest = QuestManager.Instance:GetQuest(22222)
    if quest ~= nil and quest.finish ~= QuestEumn.TaskStatus.Finish then
        return true
    end
    return false
end