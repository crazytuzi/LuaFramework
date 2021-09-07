MarketWindow = MarketWindow or BaseClass(BaseWindow)

function MarketWindow:__init(model)
    self.model = model
    self.name = "MarketWindow"
    self.windowId = WindowConfig.WinID.market
    self.cacheMode = CacheMode.Visible
    -- self.winLinkType = WinLinkType.Link

    self.resList = {
        {file = AssetConfig.market_window, type = AssetType.Main}
        , {file = AssetConfig.market_textures, type = AssetType.Dep}
    }
    self.subPanel = {nil, nil, nil}
    self.btnTabSide = {nil, nil, nil}
    self.nameSubPanel = {TI18N("金币市场"), TI18N("交易市场"), TI18N("出售物品")}
    self.txtList = {}

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.roleassetschangeListener = function() self:RoleAssetsListener() end
    self.redListener = function() self:CheckRed() end
    self.OnOpenEvent:Add(self.openListener)
    self.OnHideEvent:Add(self.hideListener)

    EventMgr.Instance:AddListener(event_name.role_asset_change, self.roleassetschangeListener)
end

function MarketWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.market_window))
    --self.gameObject.transform:SetParent(ctx.CanvasContainer.transform)
    self.gameObject.name = "MarketWindow"
    -- self.subPanel[1] = MarketGoldPanel.New(self)
    -- self.subPanel[2] = MarketSliverPanel.New(self)
    -- self.subPanel[3] = MarketSellPanel.New(self)
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    local mainObj = self.gameObject.transform:Find("Main")
    local tabButtonGroup = mainObj:Find("TabButtonGroup")

    self.titleText = mainObj:Find("Title/Text"):GetComponent(Text)

    for i=1,3 do
        local child = tabButtonGroup:GetChild(i - 1)
        self.btnTabSide[i] = child:GetComponent(Button)
        self.btnTabSide[i].onClick:AddListener(function ()
            self.model.currentSub = 1
            self:TabChange(i)
        end)
        table.insert(self.txtList, child:Find("Text"):GetComponent(Text))
    end

    self.txtList[2].text = TI18N("交易市场")

    self.btnClose = mainObj:Find("CloseButton"):GetComponent(Button)
    self.btnClose.onClick:AddListener(function () self:OnClickClose() end)

    if RoleManager.Instance.RoleData.lev < 20 then
        self.btnTabSide[3].gameObject:SetActive(false)
    else
        self.btnTabSide[3].gameObject:SetActive(true)
    end

    self.OnOpenEvent:Fire()
end

function MarketWindow:OnOpen()
    -- NoticeManager.Instance:FloatTipsByString("又打开了啊啊啊啊啊")
    self:RemoveListeners()
    MarketManager.Instance.onUpdateRed:AddListener(self.redListener)
    if self.model.currentTab > 3 then
        self.model.currentTab = 3
    end
    self:TabChange(self.model.currentTab)
    self:CheckRed()
end

function MarketWindow:TabChange(i)
    if i == 2 and self.subPanel[2] ~= nil and self.subPanel[2].isOpen == true then
        return
    end

    if self.subPanel == nil then
        return
    end
    self.model.currentTab = i
    self:UpdateTab()


    for j=1,3 do
        if self.subPanel[j] ~= nil then
            self.subPanel[j]:Hiden()
        end
    end
    self.titleText.text = self.nameSubPanel[i]
    if self.subPanel[i] == nil then
        if i == 1 then
            self.subPanel[i] = MarketGoldPanel.New(self)
        elseif i == 2 then
            self.subPanel[i] = MarketSliverPanel.New(self)
        elseif i == 3 then
            self.subPanel[i] = MarketSellPanel.New(self)
        end
    end
    if self.subPanel[i] == nil then
        Log.Error("Why is the panel a nil !!! ------------------- i=" .. tostring(i))
    end
    self.subPanel[i]:Show()
end

function MarketWindow:__delete()
    self.OnHideEvent:Fire()
    EventMgr.Instance:RemoveListener(self.roleassetschangeListener)
    for i,v in pairs(self.subPanel) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.subPanel = nil

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MarketWindow:OnClickClose()
    MarketManager.Instance.onUpdateRed:Fire()
    self.model:CloseWin()
end

function MarketWindow:UpdateTab()
    for i=1,3 do
        self.btnTabSide[i]:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton1Normal")
        self.txtList[i].color = ColorHelper.TabButton1Normal
    end
    if self.model.currentTab == nil or self.btnTabSide[self.model.currentTab] == nil then
        self.model.currentTab = 1
        self.model.currentSub = 6
    end
    self.btnTabSide[self.model.currentTab]:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton1Select")
    self.txtList[self.model.currentTab].color = ColorHelper.TabButton1Select
end

function MarketWindow:RoleAssetsListener()
    if self.subPanel ~= nil then
        for i = 1, 3 do
            if self.subPanel[i] ~= nil then
                self.subPanel[i]:RoleAssetsListener()
            end
        end
    end
end

function MarketWindow:OnHide()
    self:RemoveListeners()
    for k,v in pairs(self.subPanel) do
        if v ~= nil then
            v:Hiden()
        end
    end
end

function MarketWindow:CheckRed()
    local red = false

    -- 检查金币市场
    for _,dic in pairs(MarketManager.Instance.redPointDic[1]) do
        if dic ~= nil then
            for _,v in pairs(dic) do
                red = red or v
            end
        end
    end
    if self.btnTabSide ~= nil and self.btnTabSide[1] ~= nil then
        self.btnTabSide[1].transform:Find("RedPoint").gameObject:SetActive(red == true)
    end

    red = false
    -- 检查银币市场
    for _,dic in pairs(MarketManager.Instance.redPointDic[2]) do
        if dic ~= nil then
            for _,v in pairs(dic) do
                red = red or v
            end
        end
    end
    if self.btnTabSide ~= nil and self.btnTabSide[2] ~= nil then
        self.btnTabSide[2].transform:Find("RedPoint").gameObject:SetActive(red == true)
    end

    red = false
    -- 检查出售
    red = red or MarketManager.Instance.redPointDic[3][1]
    if self.btnTabSide ~= nil and self.btnTabSide[3] ~= nil then
        self.btnTabSide[3].transform:Find("RedPoint").gameObject:SetActive(red == true)
    end
end

function MarketWindow:RemoveListeners()
    MarketManager.Instance.onUpdateRed:RemoveListener(self.redListener)
end
