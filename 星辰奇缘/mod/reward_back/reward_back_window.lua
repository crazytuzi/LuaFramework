RewardBackWindow = RewardBackWindow or BaseClass(BaseWindow)

function RewardBackWindow:__init(model)
    self.model = model
    self.name = "RewardBackWindow"
    self.windowId = WindowConfig.WinID.reward_back_window

    self.resList = {
        {file = AssetConfig.strategy_window, type = AssetType.Main}
        , {file = AssetConfig.reward_back_panel, type = AssetType.Main}
        , {file = AssetConfig.bible_textures, type = AssetType.Dep}
    }

    self.panelList = {}
    self.txtList = {}
    self.contentList = {}

    self.tabData = {
        {name = TI18N("奖励找回"), icon = "WelfareIcon3", index = 5, key = 1},
    }

    self.setting = {
        isVertical = true,
        notAutoSelect = true,
        noCheckRepeat = true,
        perWidth = 174.67,
        perHeight = 60,
        spacing = 0,
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function RewardBackWindow:__delete()
    self.OnHideEvent:Fire()
    if self.panelList ~= nil then
        for _,v in pairs(self.panelList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.panelList = nil
    end
    if self.ext ~= nil then
        self.ext:DeleteMe()
        self.ext = nil
    end
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    self:AssetClearAll()
end

function RewardBackWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.strategy_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    t:Find("Main/TabListPanel").gameObject:SetActive(false)
    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    t:Find("Main/Title/Text"):GetComponent(Text).text = TI18N("奖励找回")

    self.panelObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.reward_back_panel))
    NumberpadPanel.AddUIChild(t:Find("Main").gameObject, self.panelObj)
    self.panelObj.name = "Panel"
    t = self.panelObj.transform

    self.panelContainer = t:Find("MainPanel")
    self.downObj = t:Find("Down").gameObject
    self.tabContainer = t:Find("ScrollLayer/Container")
    self.tabCloner = t:Find("ScrollLayer/Cloner").gameObject

    t:Find("TextArea").gameObject:SetActive(false)
    self.ext = MsgItemExt.New(t:Find("TextArea/Ext"):GetComponent(Text), 160, 17, 18.6)

    for i,v in ipairs(self.tabData) do
        local obj = GameObject.Instantiate(self.tabCloner)
        obj.name = tostring(i)
        obj.transform:SetParent(self.tabContainer)
        obj.transform.localScale = Vector3.one
        obj.transform.localPosition = Vector3.zero
        obj.transform:Find("Text"):GetComponent(Text).text = string.format(ColorHelper.TabButton1NormalStr, v.name)
        obj.transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.bible_textures, v.icon)
        table.insert(self.txtList, obj.transform:Find("Text"):GetComponent(Text))
        table.insert(self.contentList, v.name)
    end

    self.tabCloner:SetActive(false)
    self.tabGroup = TabGroup.New(self.tabContainer.gameObject, function(index) self:ChangeTab(index) end, self.setting)
    self.tabGroup:Layout()
end

function RewardBackWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function RewardBackWindow:OnOpen()
    self:RemoveListeners()

    self.tabGroup:ChangeTab(1)
end

function RewardBackWindow:RemoveListeners()
end

function RewardBackWindow:OnHide()
    if self.panelList ~= nil then
        for _,v in pairs(self.panelList) do
            if v ~= nil then
                v:Hiden()
            end
        end
    end
    self:RemoveListeners()
end

function RewardBackWindow:ChangeTab(index)
    if self.lastIndex ~= nil and self.panelList[self.lastIndex] ~= nil then
        self.panelList[self.lastIndex]:Hiden()
    end

    if self.lastIndex ~= nil then
        self.txtList[self.lastIndex].text = string.format(ColorHelper.TabButton1NormalStr, self.contentList[self.lastIndex])
    end
    self.lastIndex = index
    self.txtList[self.lastIndex].text = string.format(ColorHelper.TabButton1SelectStr, self.contentList[self.lastIndex])

    local panel = self.panelList[index]
    if panel == nil then
        if index == 1 then
            panel = RewardBackPanel.New(self.model, self.panelContainer)
        end
        self.panelList[index] = panel
    end

    if panel ~= nil then
        panel:Show()
    end
end

