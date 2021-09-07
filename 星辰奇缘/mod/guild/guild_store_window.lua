-- 公会商店母窗口
-- 2017年3月6日修改 黄耀聪

GuildStoreWindow  =  GuildStoreWindow or BaseClass(BaseWindow)

function GuildStoreWindow:__init(model)
    self.name = "GuildStoreWindow"
    self.model = model

    self.windowId = WindowConfig.WinID.guildstorewindow

    self.resList = {
        {file = AssetConfig.guild_store_win, type = AssetType.Main}
    }
    self.timer_id = 0

    self.panelList = {}

    self.restoreFrozen_exchange = nil

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.imgLoader = {}
end

function GuildStoreWindow:__delete()
    for k,v in pairs(self.imgLoader) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    if self.restoreFrozen_exchange ~= nil then
        self.restoreFrozen_exchange:DeleteMe()
    end

    self.is_open  =  false
    self.selected_data = nil
    self.last_selected_item = nil
    self.is_open = false
    self.itemList = {}

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end

    for _,v in pairs(self.panelList) do
        if v ~= nil then
            v:DeleteMe()
        end
    end

    self:AssetClearAll()
end


function GuildStoreWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_store_win))
    self.gameObject.name = "GuildStoreWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.is_open = true
    self.MainCon = self.transform:FindChild("MainCon").gameObject
    local CloseBtn = self.MainCon.transform:FindChild("CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:CloseStoreUI() end)

    GuildManager.Instance:on_show_red_point()

    local tabContainer = self.transform:Find("MainCon/TabButton")
    local tabCloner = tabContainer:Find("Button").gameObject
    for i=2,2 do
        local obj = GameObject.Instantiate(tabCloner)
        obj.transform:SetParent(tabContainer)
        obj.transform.localScale = Vector3.one
    end
    for i=1,tabContainer.childCount do
        local obj = tabContainer:GetChild(i - 1).gameObject
        if obj.transform:Find("Image") ~= nil then
            local idObj = obj.transform:Find("Image").gameObject:GetInstanceID()
            if self.imgLoader[idObj] == nil then
                self.imgLoader[idObj] = SingleIconLoader.New(obj.transform:Find("Image").gameObject)
            end
            self.imgLoader[idObj]:SetSprite(SingleIconType.Item, tonumber(self.model.dataTypeList[i].icon))
        end
        if obj:GetComponent(Button) == nil then
            obj:AddComponent(Button)
        end
    end
    self.tabGroup = TabGroup.New(tabContainer.gameObject, function(index) self:ChangeTab(index) end, {isVertical = true, cspacing = 5, perWidth = 50, perHeight = 110, openLevel = {0, 65}})
    self.tabGroup:Layout()
    for i,v in ipairs(self.tabGroup.buttonTab) do
        v.normalTxt.text = self.model.dataTypeList[i].name
        v.selectTxt.text = self.model.dataTypeList[i].name
        v.red:SetActive(false)
    end
end

function GuildStoreWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildStoreWindow:OnOpen()
    local openArgs = self.openArgs or {}
    if RoleManager.Instance.RoleData.lev < 65 then
        if openArgs[1] == 2 then
            NoticeManager.Instance:FloatTipsByString(TI18N("兄弟币商店将在<color='#ffff00'>65级</color>开放"))
        end
        self.tabGroup:ChangeTab(1)
    else
        self.tabGroup:ChangeTab(openArgs[1] or self.currentIndex or 1)
    end
end

function GuildStoreWindow:ChangeTab(index)
    if self.currentIndex ~= nil then
        self.panelList[self.currentIndex]:Hiden()
    end
    self.currentIndex = index
    if self.panelList[index] == nil then
        if index == 1 then
            self.panelList[1] = GuildStorePanel.New(self.model, self.transform:Find("MainCon/Con/GuildStore").gameObject)
        elseif index == 2 then
            self.panelList[2] = ShopPanel.New(self.model, self.transform:Find("MainCon/Con").gameObject, 2)
        end
    end

    if self.panelList[index] ~= nil then
        self.panelList[index]:Show()
    end
end

function GuildStoreWindow:OnHide()
    if self.currentIndex ~= nil then
        self.panelList[self.currentIndex]:Hiden()
    end
end
