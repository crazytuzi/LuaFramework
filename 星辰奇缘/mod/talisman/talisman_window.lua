-- @author 黄耀聪
-- @date 2017年3月17日

TalismanWindow = TalismanWindow or BaseClass(BaseWindow)

function TalismanWindow:__init(model)
    self.model = model
    self.parent = parent
    self.name = "TalismanWindow"

    self.windowId = WindowConfig.WinID.talisman_window
    self.cacheMode = CacheMode.Visible
    self.winLinkType = WinLinkType.Link

    self.resList = {
        {file = AssetConfig.talisman_window, type = AssetType.Main},
        {file = AssetConfig.talisman_textures, type = AssetType.Dep},
    }

    self.panelList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function TalismanWindow:__delete()
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
    end
    self:AssetClearAll()
end

function TalismanWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.talisman_window))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = t

    local main = t:Find("Main")
    self.main = main

    --重塑功能屏蔽
    -- main:Find("TabButtonGroup"):GetChild(2).gameObject:SetActive(false)

    self.tabGroup = TabGroup.New(main:Find("TabButtonGroup").gameObject, function(index) self:ChangeTab(index) end, {notAutoSelect = true, noCheckRepeat = false, perWidth = 40, perHeight = 100, isVertical = true, cspacing = 5})

    self.titleText = t:Find("Main/Title/Text"):GetComponent(Text)

    main:Find("Close"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
end

function TalismanWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function TalismanWindow:OnOpen()
    self:RemoveListeners()

    TalismanManager.Instance.isShow = true
    EventMgr.Instance:Fire(event_name.talisman_item_change)


    self.openArgs = self.openArgs or {}
    local index = self.openArgs[1] or 1
    self.tabGroup:ChangeTab(index)
end

function TalismanWindow:OnHide()
    self:RemoveListeners()
    -- if self.lastIndex ~= nil and self.panelList[self.lastIndex] ~= nil then
    --     self.panelList[self.lastIndex]:Hiden()
    --     self.lastIndex = nil
    -- end
end

function TalismanWindow:RemoveListeners()
end

function TalismanWindow:ChangeTab(index)
    -- print(self.lastIndex)
    if self.lastIndex ~= nil then
        if self.panelList[self.lastIndex] ~= nil then
            self.panelList[self.lastIndex]:Hiden()
        end
    end

    if self.panelList[index] == nil then
        if index == 1 then
            self.panelList[index] = TalismanPanel.New(self.model, self.main)
        elseif index == 2 then
            self.panelList[index] = TalismanAddition.New(self.model, self.main)
        elseif index == 3 then
            self.panelList[index] = TalismanSynthesis.New(self.model,self.main)

        end
    end

    self.lastIndex = index
    if index == 1 then
        self.titleText.text = TI18N("宝物空间")
    elseif index == 2 then
        self.titleText.text = TI18N("宝物境界")
    elseif index == 3 then
        self.titleText.text = TI18N("宝物熔炉")
    end

    local args = {}
    local openArgs = self.openArgs or {}
    for i=2,#openArgs do
        args[1] = openArgs[i]
    end
    self.openArgs = nil
    self.panelList[index]:Show(args)

end
