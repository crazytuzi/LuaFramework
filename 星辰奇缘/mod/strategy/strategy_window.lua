-- @author 黄耀聪
-- @date 2016年7月6日
-- 攻略

StrategyWindow = StrategyWindow or BaseClass(BaseWindow)

function StrategyWindow:__init(model)
    self.model = model
    self.name = "StrategyWindow"
    self.windowId = WindowConfig.WinID.strategy_window
    self.mgr = StrategyManager.Instance
    self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.strategy_window, type = AssetType.Main},
        {file = AssetConfig.strategy_textures, type = AssetType.Dep},
    }

    self.tabData = {
        {name = TI18N("百\n科"), lev = 2, icon = "Wiki"},
        {name = TI18N("宝\n典"), lev = 12, icon = "Bible"},
        {name = TI18N("战\n力"), lev = 0, icon = "Challenge"},
        {name = TI18N("攻\n略"), lev = 0, icon = "Strategy"},
    }

    self.setting = {
        isVertical = true,
        notAutoSelect = true,
        noCheckRepeat = true,
        openLevel = {},
        perWidth = 48,
        perHeight = 100,
        spacing = 2,
    }

    self.panelList = {}
    self.txtList = {}
    self.contentList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function StrategyWindow:__delete()
    local model = self.model
    self.OnHideEvent:Fire()
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
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self.model:ClearMyList()
    self.model:ClearList()
    self:AssetClearAll()
end

function StrategyWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.strategy_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    local t = self.gameObject.transform
    self.transform = t

    local main = t:Find("Main")
    self.titleText = main:Find("Title/Text"):GetComponent(Text)
    self.closeBtn = main:Find("Close"):GetComponent(Button)
    self.tabContainer = main:Find("TabListPanel")
    self.tabCloner = self.tabContainer:Find("TabButton").gameObject
    self.mainContainer = main

    self.tabCloner.transform:SetParent(main)
    for i,v in ipairs(self.tabData) do
        local obj = GameObject.Instantiate(self.tabCloner)
        obj.name = tostring(i)
        obj.transform:SetParent(self.tabContainer)
        obj.transform.localScale = Vector3.one
        obj.transform.localPosition = Vector3.zero
        self.setting.openLevel[i] = v.lev
        obj.transform:Find("Text"):GetComponent(Text).text = string.format(ColorHelper.TabButton1NormalStr, v.name)
        obj.transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.strategy_textures, v.icon)
        table.insert(self.txtList, obj.transform:Find("Text"):GetComponent(Text))
        table.insert(self.contentList, v.name)
    end

    self.titleText.text = TI18N("帮 助")
    self.tabGroup = TabGroup.New(self.tabContainer, function(index) self:ChangeTab(index) end, self.setting)

    self.tabCloner:SetActive(false)
    self.closeBtn.onClick:AddListener(function() self:OnClose() end)
end

function StrategyWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function StrategyWindow:OnOpen()
    self:RemoveListeners()
    self.openArgs = self.openArgs or {}
    if self.openArgs[1] == nil then
        self.openArgs = {1}
    end
    local roledata = RoleManager.Instance.RoleData
    if roledata.lev < self.tabData[self.openArgs[1]].lev then
        for i,v in ipairs(self.tabData) do
            if roledata.lev >= v.lev then
                self.openArgs = {i}
                break
            end
        end
    end
    self.tabGroup:ChangeTab(self.openArgs[1])
    self.openArgs = {}
    if self.mgr.brew == true then
        self:ChangeTab(2)
        self.tabGroup:ChangeTab(2)
        self.mgr.brew = false
    end
end

function StrategyWindow:OnHide()
    self:RemoveListeners()
end

function StrategyWindow:RemoveListeners()
end

function StrategyWindow:InitTab()
    for i,v in ipairs(self.tabData) do
        self.setting.openLevel[i] = v.lev
    end
    self.tabGroup:Layout()
end

function StrategyWindow:OnClose()
    self.model:CloseWindow()
    BibleManager.Instance.type = 1
end

function StrategyWindow:ChangeTab(index)
    local model = self.model
    if self.lastIndex ~= nil then
        if self.panelList[self.lastIndex] ~= nil then
            self.panelList[self.lastIndex]:Hiden()
        end
    end

    local panel = self.panelList[index]

    if panel == nil then
        if index == 3 then
             WindowManager.Instance:OpenWindowById(WindowConfig.WinID.force_improve, {2})
        elseif index == 2 then
             panel = BibleBrewPanel.New(model.brewModel,self.mainContainer)
        elseif index == 1 then
            panel = EncyclopediaPanel.New(self.mainContainer)
        elseif index == 4 then
             panel = StrategyPanel.New(model,self.mainContainer)
        end
        self.panelList[index] = panel
    end

    if self.lastIndex ~= nil then
        self.txtList[self.lastIndex].text = string.format(ColorHelper.TabButton1NormalStr, self.contentList[self.lastIndex])
    end
    self.lastIndex = index
    self.txtList[self.lastIndex].text = string.format(ColorHelper.TabButton1SelectStr, self.contentList[self.lastIndex])

    if panel ~= nil then
        panel:Show(self.openArgs)
    end
end
