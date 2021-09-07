ChildBirthSubWindow = ChildBirthSubWindow or BaseClass(BaseWindow)

function ChildBirthSubWindow:__init(model, parent)
    self.model = model
    self.name = "OpenBetaWindow"
    self.windowId = WindowConfig.WinID.child_birth_sub_window
    self.mgr = OpenBetaManager.Instance

    self.resList = {
        {file = AssetConfig.open_beta_window, type = AssetType.Main},
        {file = AssetConfig.childbirth_textures, type = AssetType.Dep},
    }

    self.tabData = {
        {id = 395, icon = 29037},
        {id = 397, icon = 22530},
    }

    self.tabList = {}
    self.panelList = {}
    self.iconloader = {}
    self.redListener = function() self:CheckRed() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ChildBirthSubWindow:__delete()
    self.OnHideEvent:Fire()
    for k,v in pairs(self.iconloader) do
        v:DeleteMe()
    end
    self.iconloader = {}
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.panelList ~= nil then
        for _,v in pairs(self.panelList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.panelList = nil
    end
    self:AssetClearAll()
end

function ChildBirthSubWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_beta_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local main = t:Find("Main")
    self.closeBtn = main:Find("Close"):GetComponent(Button)
    self.tabContainer = main:Find("TabListPanel")
    self.tabCloner = self.tabContainer:Find("TabButton").gameObject
    self.panelContainer = main:Find("Panel")

    for i,v in ipairs(self.tabData) do
        local tab = {}
        tab.obj = GameObject.Instantiate(self.tabCloner)
        tab.obj.name = tostring(i)
        tab.trans = tab.obj.transform
        tab.text = tab.trans:Find("Text"):GetComponent(Text)
        tab.centerText = tab.trans:Find("CenterText"):GetComponent(Text)
        tab.icon = tab.trans:Find("Icon"):GetComponent(Image)
        tab.trans:SetParent(self.tabContainer)
        tab.trans.localScale = Vector3.one

        if v.icon ~= nil then
            tab.icon.gameObject:SetActive(true)
            tab.text.gameObject:SetActive(true)
            tab.centerText.gameObject:SetActive(false)
            local id = tab.icon.gameObject:GetInstanceID()
            if self.iconloader[id] == nil then
                self.iconloader[id] = SingleIconLoader.New(tab.icon.gameObject)
            end
            self.iconloader[id]:SetSprite(SingleIconType.Item, DataItem.data_get[v.icon].icon)
            tab.text.text = DataCampaign.data_list[v.id].name
        else
            tab.icon.gameObject:SetActive(false)
            tab.text.gameObject:SetActive(false)
            tab.centerText.gameObject:SetActive(true)
            tab.centerText.text = DataCampaign.data_list[v.id].name
        end
        self.tabList[i] = tab
    end
    self.tabCloner.transform:SetParent(main)
    self.tabCloner:SetActive(false)

    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    self.tabGroup = TabGroup.New(self.tabContainer, function(index) self:ChangeTab(index) end, {notAutoSelect = true, noCheckRepeat = false, perWidth = 131, perHeight = 40, isVertical = false, spacing = 0})
end

function ChildBirthSubWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ChildBirthSubWindow:OnOpen()
    self:RemoveListeners()
    self.timerId = LuaTimer.Add(0, 300, function() self:OnTick() end)
    ChildBirthManager.Instance.onCheckRed:AddListener(self.redListener)

    self.openArgs = self.openArgs or {}
    self:ReloadTab()

    local id = self.openArgs[1]
    local index = 1
    for i,v in ipairs(self.tabData) do
        if id == v.id then
            index = i
        end
    end
    self.tabGroup:ChangeTab(index)
    self:CheckRed()
end

function ChildBirthSubWindow:OnHide()
    self:RemoveListeners()
end

function ChildBirthSubWindow:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    ChildBirthManager.Instance.onCheckRed:RemoveListener(self.redListener)
end

function ChildBirthSubWindow:ChangeTab(index)
    local model = self.model
    if self.lastIndex ~= nil then
        if self.panelList[self.lastIndex] ~= nil then
            self.panelList[self.lastIndex]:Hiden()
            self.tabList[self.lastIndex].text.color = ColorHelper.TabButton2Normal
        end
    end

    local panel = self.panelList[index]
    self.tabList[index].text.color = Color(1, 1, 0)

    if panel == nil then
        if index == 1 then
            panel = ChildBirthFlowerPanel.New(model, self.panelContainer)
        elseif index == 2 then
            panel = ChildBirthHundredPanel.New(model, self.panelContainer)
        end
        self.panelList[index] = panel
    end

    self.lastIndex = index
    if panel ~= nil then
        if OpenBetaManager.Instance.redPointDic[index] == true then
            OpenBetaManager.Instance.hasOpen[index] = true
        end
        panel:Show(self.openArgs)
    end
    self.openArgs = {}
end

function ChildBirthSubWindow:OnTick()
    self.mgr.onTickTime:Fire()
end

function ChildBirthSubWindow:CheckRed()
    if self.tabGroup ~= nil and self.tabGroup.buttonTab ~= nil then
        for i,_ in ipairs(self.tabGroup.buttonTab) do
            self.tabGroup:ShowRed(i, ChildBirthManager.Instance.redPointDic[self.tabData[i].id] == true)
        end
    end
end

function ChildBirthSubWindow:ReloadTab()
    local unreachableLev = 999
    local openLevel = {}
    for i,v in ipairs(self.tabData) do
        if CampaignManager.Instance.campaignTab[v.id] == nil then
            openLevel[i] = unreachableLev
            -- openLevel[i] = 0
        else
            openLevel[i] = 0
        end
    end
    self.tabGroup.openLevel = openLevel
    self.tabGroup:Layout()
end

