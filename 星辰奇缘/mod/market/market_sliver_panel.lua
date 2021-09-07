MarketSliverPanel = MarketSliverPanel or BaseClass(BasePanel)

function MarketSliverPanel:__init(parent)
    self.parent = parent
    local model = parent.model

    self.resList = {
        {file = AssetConfig.market_sliver_panel, type = AssetType.Main}
        , {file = AssetConfig.market_textures, type = AssetType.Dep}
    }

    self.tabButtonList = {nil, nil, nil, nil, nil, nil, nil}
    self.mgr = MarketManager.Instance
    -- self.parent.subPanel[2] = self

    self.petTab = MarketManager.Instance.sliverDataType.Pet
    self.maxPageNum = 8
    -- self.theIndex = {[1] = 4, [2] = 3, [3] = 2, [4] = 7, [5] = 1, [6] = 6, [7] = 5}

    self.tabData = {
        {name = TI18N("栽  培"), icon = "OtherButton", dataType = self.mgr.sliverDataType.Plant, lev = 0, world_lev = 0},
        {name = TI18N("幻  化"), icon = "CraftsButton", dataType = self.mgr.sliverDataType.Craft, lev = 0, world_lev = 0},
        {name = TI18N("药  品"), icon = "MedicineButton", dataType = self.mgr.sliverDataType.Medicine, lev = 0, world_lev = 0},
        {name = TI18N("高级药品"), icon = "HighMed", dataType = self.mgr.sliverDataType.HightMed, lev = 50, world_lev = 50},
        {name = TI18N("装备珍宝"), icon = "BlacksmithsButton", dataType = self.mgr.sliverDataType.Equip, lev = 0, world_lev = 0},
        {name = TI18N("职业徽章"), icon = "Classes", dataType = self.mgr.sliverDataType.Classes, lev = 95, world_lev = 0},
        {name = TI18N("宠  物"), icon = "PetButton", dataType = self.mgr.sliverDataType.Pet, lev = 0, world_lev = 0},
        {name = TI18N("雕  文"), icon = "StoneButton", dataType = self.mgr.sliverDataType.Glyphs, lev = 0, world_lev = 0},
    }

    self.timerId = 0
    self.needList = {}
    self.needPetList = {}
    self.pageObjList = {}
    self.itemObjList = {}
    self.hasInitPage = {}
    self.headLoaderList = {}

    self.listener = function (items)
        if model.currentTab == 2 then
            self:GetNeedList()
            self:UpdateButtonList()
            self:UpdateBuyPanel()
        end
    end

    self.tabListener = function ()
        for i,v in ipairs(self.tabData) do
            if RoleManager.Instance.world_lev >= v.world_lev then
                self.tabGroup.openLevel[i] = v.lev
            else
                self.tabGroup.openLevel[i] = 255
            end
        end
        self.tabGroup:Layout()
    end

    self.roleLevListener = function() self:OnRoleLevelChange() end

    self.petUpdateListener = function()
        if self.buyFrozen ~= nil then
            self.buyFrozen:Release()
        end
    end

    self.openListener = function ()
        self:OnOpen()
    end

    self.hideListener = function ()
        self:OnHide()
    end

    self.OnOpenEvent:Add(self.openListener)
    self.OnHideEvent:Add(self.hideListener)
end

function MarketSliverPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.market_sliver_panel))
    self.gameObject:SetActive(true)
    self.gameObject.name = "SliverMarket"

    local t = self.gameObject.transform
    t:SetParent(self.parent.gameObject.transform:Find("Main"))
    t.localPosition = Vector3.zero
    t.localScale = Vector3.one

    local tabButtonGroup = t:Find("TabButtonGroup")
    local model = self.parent.model
    local role_assets = RoleManager.Instance.RoleData

    local role_lev = RoleManager.Instance.RoleData.lev
    local break_time = RoleManager.Instance.RoleData.lev_break_times

    local itemlist = {}
    local petData = DataPetShop.data_pet_shop
    for k,v in pairs(petData) do
        if v.actv_lev <= role_lev and DataPet.data_pet[k].need_lev_break <= break_time then
            table.insert(itemlist, v)
        end
    end
    table.sort(itemlist, function (a, b) if a.actv_lev == b.actv_lev then return a.sort > b.sort else return a.actv_lev > b.actv_lev end end)
    model.sliverItemList[self.petTab] = itemlist

    self.tabCloner = tabButtonGroup:Find("TabCloner").gameObject
    local tabContaienr = tabButtonGroup:Find("Container")
    local openLevel = {}
    for i,v in ipairs(self.tabData) do
        local tab = {}
        local obj = GameObject.Instantiate(self.tabCloner)
        obj.name = tostring(i)
        tab.obj = obj
        tab.trans = obj.transform
        tab.trans:SetParent(tabContaienr)
        tab.trans.localScale = Vector3.one
        tab.trans:Find("Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.market_textures, v.icon)
        tab.trans:Find("Normal/Text"):GetComponent(Text).text = v.name
        tab.trans:Find("Select/Text"):GetComponent(Text).text = v.name
        tab.tag = tab.trans:Find("TipsImage").gameObject
        openLevel[i] = v.lev
        self.tabButtonList[i] = tab
    end
    self.tabCloner:SetActive(false)

    self.tabGroup = TabGroup.New(tabContaienr.gameObject, function(index) self:ChangeTab(index) end, {notAutoSelect = true, noCheckRepeat = true, perWidth = 220, perHeight = 55, isVertical = true, spacing = -3, openLevel = openLevel})

    self.refreshButton = t:Find("RefreshButton"):GetComponent(Button)
    self.refreshButton.onClick:AddListener(function ()
        if model.sliverRefreshType ~= nil then
            MarketManager.Instance:send12409(model.sliverRefreshType)
            self:DoCountDown()
            -- if self.timerId ~= nil then
                -- LuaTimer.Delete(self.timerId)
            -- end
            -- self.timerId = LuaTimer.Add(0, 1000, function(id) self:ShowRestTimeToRefresh(id) end)
        end
    end)
    self.leftTimeText = t:Find("TimeText"):GetComponent(Text)
    self.leftTimeText.color = Color(232/255, 250/255, 255/255)

    self.pageText = t:Find("PageText"):GetComponent(Text)
    self.buyContainer = t:Find("Panel/Container")
    self.scrollRect = t:Find("Panel"):GetComponent(ScrollRect)
    self.pageText.text = ""
    self.buyPanel = t:Find("Panel/BuyPanel")                      -- 翻页模板
    self.itemTemplate = self.buyPanel:Find("ItemObject").gameObject         -- 物品模板
    self.itemTemplate:SetActive(false)
    self.nothingPanel = self.buyPanel:Find("Nothing").gameObject
    self.buyPanel.gameObject:SetActive(false)

    if self.boxXLayout == nil then
        local setting = {
            axis = BoxLayoutAxis.X
            ,cspacing = 0
        }
        self.boxXLayout = LuaBoxLayout.New(self.buyContainer, setting)
    end

    self.tabbedPanel = TabbedPanel.New(self.scrollRect.gameObject, self.maxPageNum, 520)
    self.tabbedPanel.MoveEndEvent:Add(function(currentPage, direction) self:OnDragEnd(currentPage, direction) end)

    -- 初始化购买列表
    for i=1,self.maxPageNum do
        local tab = {}
        tab.obj = GameObject.Instantiate(self.buyPanel.gameObject)
        tab.obj.name = tostring(i)
        tab.transform = tab.obj.transform
        self.boxXLayout:AddCell(tab.obj)
        tab.transform.localScale = Vector3.one
        tab.nothing = tab.transform:Find("Nothing").gameObject
        tab.transform:Find("Nothing/Button"):GetComponent(Button).onClick:AddListener(function ()
            model.marketWin:TabChange(3)
        end)

        local obj = tab.transform:Find("ItemObject").gameObject
        obj:SetActive(false)
        for j=1,10 do
            local tab1 = {}
            tab1.obj = GameObject.Instantiate(obj)
            tab1.transform = tab1.obj.transform
            tab1.transform:SetParent(tab.transform)
            tab1.transform.localScale = Vector3.one
            tab1.obj.name = tostring((i - 1) * 10 + j)
            tab1.obj:SetActive(false)
            tab1.select = tab1.transform:Find("Select").gameObject
            tab1.btn = tab1.obj:GetComponent(Button)
            if tab1.btn == nil then
                tab1.btn = tab1.obj:AddComponent(Button)
            end

            tab1.nameText = tab1.transform:Find("NameText"):GetComponent(Text)
            tab1.priceText = tab1.transform:Find("Image/Value"):GetComponent(Text)
            tab1.currencyImage = tab1.transform:Find("Image/CurrencyImage"):GetComponent(Image)
            tab1.iconImage = tab1.transform:Find("Icon/Image"):GetComponent(Image)
            tab1.isneedTipsObj = tab1.transform:Find("TipsImage").gameObject
            tab1.soldoutObj = tab1.transform:Find("SoldoutImage").gameObject
            tab1.levText = tab1.transform:Find("LevText"):GetComponent(Text)
            tab1.slot = ItemSlot.New()
            NumberpadPanel.AddUIChild(tab1.transform:Find("Icon"), tab1.slot.gameObject)

            if j % 2 == 1 then
                tab1.transform.anchoredPosition = Vector3(0 + 19, -10 - (j - 1) * 76 / 2, 0)
            else
                tab1.transform.anchoredPosition = Vector3(245 + 19, -10 - (j - 2) * 76 / 2, 0)
            end

            self.itemObjList[(i - 1) * 10 + j] = tab1
        end
        self.pageObjList[i] = tab
    end

    self.pageNum = 1

    self.btnNextPage = t:Find("NextPageBtn"):GetComponent(Button)
    self.btnNextPage.transform.localScale = Vector3(1.5, 1.5, 1)
    self.btnNextPage.onClick:AddListener(function ()
        if self.enableNextPage == true then
            if model.currentSliverSub[model.currentSliverMain] < self.pageNum then
                model.currentSliverSub[model.currentSliverMain] = model.currentSliverSub[model.currentSliverMain] + 1
            end

            self.tabbedPanel:TurnPage(model.currentSliverSub[model.currentSliverMain])
            self.btnPrePage.enabled = false
            self.btnNextPage.enabled = false
        end
    end)
    self.btnPrePage = t:Find("PrePageBtn"):GetComponent(Button)
    self.btnPrePage.transform.localScale = Vector3(-1.5, 1.5, 1)
    self.btnPrePage.onClick:AddListener(function ()
        if self.enablePrePage == true then
            if model.currentSliverSub[model.currentSliverMain] > 0 then
                model.currentSliverSub[model.currentSliverMain] = model.currentSliverSub[model.currentSliverMain] - 1
            end

            self.tabbedPanel:TurnPage(model.currentSliverSub[model.currentSliverMain])
            self.btnPrePage.enabled = false
            self.btnNextPage.enabled = false
        end
    end)

    self.btnBuy = t:Find("BuyButton"):GetComponent(CustomButton)
    self.noticeBtn = t:Find("Notice"):GetComponent(Button)
    self.buyFrozen = FrozenButton.New(self.btnBuy.gameObject, {})
    self.btnBuy.onClick:AddListener(function () self:OnBuy() end)
    self.btnBuy.onHold:AddListener(function() self:OnHold() end)
    self.btnBuy.onDown:AddListener(function() self:OnDown() end)
    self.btnBuy.onUp:AddListener(function() self:OnUp() end)
    self.noticeBtn.onClick:AddListener(function() self:OnNotice() end)

    self.coinText = t:Find("CoinBg/SliverVal").gameObject:GetComponent(Text)
    self.coinText.color = Color(232/255, 250/255, 255/255, 1)
    self.coinText.text = tostring(role_assets.coin)

    self.btnAddCoin = t:Find("CoinBg/AddSilverBtn"):GetComponent(Button)
    self.btnAddCoin.onClick:AddListener(function ()
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.exchange_window)
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.exchange_window, 2)
    end)

    model.sliverRefreshType = 2

    self.numberpadSetting = {               -- 弹出小键盘的设置
        gameObject = self.btnBuy.gameObject,
        min_result = 1,
        max_by_asset = 20,
        max_result = 20,
        textObject = nil,
        show_num = false,
        returnKeep = true,
        funcReturn = function(num) self:OnNumberpadReturn(num) end,
        callback = nil,
        show_num = true,
        returnText = TI18N("购买"),
    }

    self.OnOpenEvent:Fire()
end

function MarketSliverPanel:ChangeTab(index)
    local model = self.parent.model
    model.currentSliverTab = index
    model.currentSliverMain = self.tabData[index].dataType
    model.currentSliverSub[index] = 1
    if model.sliverItemList[model.currentSliverMain] ~= nil then
        local size = #model.sliverItemList[model.currentSliverMain]
        if index ~= self.petTab then
            self.pageNum = math.ceil(size / 10) + 1
        else
            self.pageNum = math.ceil(size / 10)
        end
        if self.pageNum > self.maxPageNum then self.pageNum = self.maxPageNum end
        if self.hasInitPage ~= nil then
            for k,_ in pairs(self.hasInitPage) do
                self.hasInitPage[k] = false
            end
        end
        self.tabbedPanel:SetPageCount(self.pageNum)
        model.selectPos = nil
        model.currentSliverSelectInfo = nil
        self:LocateItem()
    end
    self:UpdateBuyPanel()
    self:UpdateButtonList()
end

function MarketSliverPanel:__delete()
    -- self.OnHideEvent:Fire()
    self:OnHide()
    if self.itemObjList ~= nil then
        for _,v in pairs(self.itemObjList) do
            if v ~= nil then
                v.iconImage.sprite = nil
                v.currencyImage.sprite = nil
                v.slot:DeleteMe()
            end
        end
        self.itemObjList = nil
    end

    if self.headLoaderList ~= nil then
        for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.headLoaderList = nil
    end
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.buyFrozen ~= nil then
        self.buyFrozen:DeleteMe()
        self.buyFrozen = nil
    end
    if self.boxXLayout ~= nil then
        self.boxXLayout:DeleteMe()
        self.boxXLayout = nil
    end
    if self.tabbedPanel ~= nil then
        self.tabbedPanel:DeleteMe()
        self.tabbedPanel = nil
    end
    if self.arrowEffect ~= nil then
        self.arrowEffect:DeleteMe()
        self.arrowEffect = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self.OnOpenEvent:Remove(self.openListener)
    self.OnHideEvent:Remove(self.hideListener)
    self.parent = nil
    self:AssetClearAll()
end

function MarketSliverPanel:OnOpen()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.listener)
    EventMgr.Instance:RemoveListener(event_name.pet_update, self.petUpdateListener)
    EventMgr.Instance:RemoveListener(event_name.world_lev_change, self.tabListener)
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.roleLevListener)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.listener)
    EventMgr.Instance:AddListener(event_name.pet_update, self.petUpdateListener)
    EventMgr.Instance:AddListener(event_name.world_lev_change, self.tabListener)
    EventMgr.Instance:AddListener(event_name.role_level_change, self.roleLevListener)

    self.isOpen = true

    local model = self.parent.model
    self:GetNeedList()
    local needTypeList = {}
    local silverItems = DataMarketSilver.data_market_silver_item
    for k,_ in pairs(self.needList) do
        if silverItems[k] ~= nil then
            needTypeList[silverItems[k].type] = 1
        end
    end

    for k,v in pairs(self.needPetList) do
        needTypeList[self.petTab] = 1
    end

    if model.currentSub ~= nil then
        model.currentSliverMain = self.tabData[model.currentSub].dataType
    else
        model.currentSub = 1
        model.currentSliverMain = self.tabData[1].dataType
        for i=1,#self.tabData do
            if needTypeList[self.tabData[i].dataType] == 1 then
                model.currentSub = i
                self.parent.model.currentSliverMain = self.tabData[i].dataType
                break
            end
        end
    end
    self:OnRoleLevelChange()
    self:UpdateButtonList()

    model.currentSliverSub = {1, 1, 1, 1, 1, 1}
    model.currentSliverSub[99] = 1
    model.currentSliverSub[98] = 1
    if model.sliverItemList[1] == nil then
        MarketManager.Instance:send12409(3) -- 获取银币市场物品列表
    else
        -- self:LocateItem()
        -- self:UpdateBuyPanel()
        self.tabGroup:ChangeTab(model.currentSub)
    end

    if model.refreshTime ~= nil and self.parent.model.refreshTime <= BaseUtils.BASE_TIME then
        MarketManager.Instance:send12409(1)
    end
    self:DoCountDown()
    if gm_cmd.auto2 then
        if model.currentSliverSelectInfo ~= nil then
            LuaTimer.Add(1000, function ()
                self:OnBuy()
            end)
        end
    end
end

function MarketSliverPanel:DoCountDown()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end
    self.timerId = LuaTimer.Add(0, 1000, function(id) self:ShowRestTimeToRefresh(id) end)
end

function MarketSliverPanel:OnHide()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.listener)
    EventMgr.Instance:RemoveListener(event_name.pet_update, self.petUpdateListener)
    EventMgr.Instance:RemoveListener(event_name.world_lev_change, self.tabListener)
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.roleLevListener)

    self.isOpen = false

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end
    if self.arrowEffect ~= nil then
        self.arrowEffect:DeleteMe()
        self.arrowEffect = nil
    end
end

function MarketSliverPanel:OnDragEnd(currentPage, direction)
    if currentPage + 1 < self.pageNum then
        self.pageObjList[currentPage + 2].obj:SetActive(false)
    end
    if currentPage > 2 then
        self.pageObjList[currentPage - 2].obj:SetActive(false)
    end
    if currentPage < self.pageNum then
        self.pageObjList[currentPage + 1].obj:SetActive(true)
    end
    if currentPage > 1 then
        self.pageObjList[currentPage - 1].obj:SetActive(true)
    end

    if currentPage <= self.pageNum and currentPage > 0 then
        self.pageObjList[currentPage].obj:SetActive(true)
    else
        return
    end

    local model = self.parent.model
    if currentPage > self.pageNum then
        currentPage = self.pageNum
    end
    if currentPage < 1 then
        currentPage = 1
    end
    model.currentSliverSub[model.currentSliverMain] = currentPage
    self.pageText.text = string.format(TI18N("第%s/%s页"), tostring(currentPage), tostring(self.pageNum))
    if direction == LuaDirection.Left then
        if currentPage > 1 then
            if self.hasInitPage[currentPage + 1] ~= true then
                self:InitDataPanel(currentPage + 1)
            end
        end
    elseif direction == LuaDirection.Right then
        if currentPage < self.pageNum then
            if self.hasInitPage[currentPage - 1] ~= true then
                self:InitDataPanel(currentPage - 1)
            end
        end
    end

    self:UpdatePageButton()
    self.btnPrePage.enabled = true
    self.btnNextPage.enabled = true
end

function MarketSliverPanel:UpdateButtonList()
    local silverItems = DataMarketSilver.data_market_silver_item
    self:GetNeedList()

    local needTypeList = {}
    for k,_ in pairs(self.needList) do
        if silverItems[k] ~= nil then
            needTypeList[silverItems[k].type] = 1
        end
    end

    for k,v in pairs(self.needPetList) do
        needTypeList[self.petTab] = 1
    end

    local model = self.parent.model
    for k,v in pairs(self.tabButtonList) do
        if needTypeList[self.tabData[k].dataType] ~= nil then
            v.tag:SetActive(true)
        else
            v.tag:SetActive(false)
        end
    end
end

function MarketSliverPanel:InitDataPanel(index)
    if index < 1 or index > self.maxPageNum then
        return
    end

    local role_lev = RoleManager.Instance.RoleData.lev
    local model = self.parent.model
    local itemlist = model.sliverItemList[model.currentSliverMain] or {}

    if model.currentSliverMain == self.petTab then
        itemlist = {}
        local break_time = RoleManager.Instance.RoleData.lev_break_times
        local petData = DataPetShop.data_pet_shop
        for k,v in pairs(petData) do
            if v.actv_lev <= role_lev and DataPet.data_pet[k].need_lev_break <= break_time then
                table.insert(itemlist, v)
            end
        end
        table.sort(itemlist, function (a, b) if a.actv_lev == b.actv_lev then return a.sort > b.sort else return a.actv_lev > b.actv_lev end end)
        model.sliverItemList[model.currentSliverMain] = itemlist
    end

    local page = self.pageObjList[index]
    page.obj:SetActive(true)

    if itemlist[(index - 1) * 10 + 1] ~= nil then
        page.nothing:SetActive(false)
        for i=1,10 do
            self:SetItem(itemlist[(index - 1) * 10 + i], self.itemObjList[(index - 1) * 10 + i], i)
        end
    else
        page.nothing.gameObject:SetActive(true)
        for i=1,10 do
            self.itemObjList[(index - 1) * 10 + i].obj:SetActive(false)
        end
    end

    if model.selectPos ~= nil and model.selectPos > 0 then
        self.itemObjList[model.selectPos].select:SetActive(true)
    end
end

function MarketSliverPanel:UpdateBuyPanel()
    local model = self.parent.model
    local currentPage = model.currentSliverSub[model.currentSliverMain]
    local rect = self.buyContainer:GetComponent(RectTransform)

    local size = 0
    if model.sliverItemList[model.currentSliverMain] ~= nil then
        size = #model.sliverItemList[model.currentSliverMain]
    end
    if model.currentSliverMain == self.petTab then
        self.pageNum = math.ceil(size / 10)
    else
        self.pageNum = math.ceil(size / 10) + 1
    end
    if self.pageNum > self.maxPageNum then self.pageNum = self.maxPageNum end
    if self.hasInitPage ~= nil then
        for k,_ in pairs(self.hasInitPage) do
            self.hasInitPage[k] = false
        end
    end
    self.tabbedPanel:SetPageCount(self.pageNum)

    rect.sizeDelta = Vector2(self.pageNum * 520, 400)
    -- self.tabbedPanel:GotoPage(currentPage)
    self.tabbedPanel:TurnPage(currentPage)
    self.pageText.text = string.format(TI18N("第%s/%s页"), tostring(currentPage), tostring(self.pageNum))
    self:InitDataPanel(currentPage - 1)
    self:InitDataPanel(currentPage)
    self:InitDataPanel(currentPage + 1)

    self:UpdatePageButton()
end

-- 定位物品
function MarketSliverPanel:LocateItem()
    local model = self.parent.model
    self:GetNeedList()
    local role_lev = RoleManager.Instance.RoleData.lev
    local pos = 0

    local itemlist = model.sliverItemList[model.currentSliverMain]

    if itemlist ~= nil then
        if model.targetBaseId ~= nil then
            -- 根据传入目标bas_id定位
            for i=1,#itemlist do
                if model.currentSliverMain ~= self.petTab then
                    if itemlist[i].item_base_id == model.targetBaseId then
                        model.currentSliverSelectInfo = itemlist[i]
                        pos = i
                        break
                    end
                else
                    if itemlist[i].base_id == model.targetBaseId then
                        model.currentSliverSelectInfo = itemlist[i]
                        pos = i
                        break
                    end
                end
            end
            model.targetBaseId = nil
        else
            -- 根据需求列表定位该类商品的第一个需求物品
            for i=1,#itemlist do
                if model.currentSliverMain ~= self.petTab then
                    if self.needList[itemlist[i].item_base_id] ~= nil and self.needInBackpack[itemlist[i].item_base_id] < self.needList[itemlist[i].item_base_id] then
                        model.currentSliverSelectInfo = itemlist[i]
                        pos = i
                        break
                    end
                else
                    if self.needPetList[itemlist[i].base_id] ~= nil and self.needInPet[itemlist[i].base_id] < self.needPetList[itemlist[i].base_id] then
                        model.currentSliverSelectInfo = itemlist[i]
                        pos = i
                        break
                    end
                end
            end
        end
    end

    if pos ~= 0 then
        model.currentSliverSub[model.currentSliverMain] = math.ceil(pos / 10)
        model.selectPos = pos
    else
        model.currentSliverSub[model.currentSliverMain] = 1
        model.selectPos = nil
    end

    -- inserted by 嘉俊 自动历练，自动职业任务
    if AutoQuestManager.Instance.model.isOpen then
        -- print("AutoMode:"..AutoQuestManager.Instance.model.autoMode)
        if AutoQuestManager.Instance.model.autoMode == 1 or (AutoQuestManager.Instance.model.autoMode == 2 and model.currentSliverMain == self.petTab) then -- 自动则购买也是由系统帮玩家购买 by 嘉俊 2017/8/28 17:56
            if model.currentSliverSelectInfo ~= nil then
                LuaTimer.Add(1000, function ()
                    self:OnBuy()
                end)
            end
        elseif AutoQuestManager.Instance.model.autoMode == 2 then -- 半自动则让玩家自己购买 -- by 嘉俊 2017/8/28 17:55
            print("半自动导致自动停止")

            AutoQuestManager.Instance.disabledAutoQuest:Fire() -- 打开银币市场就停止让玩家自己选择购买哪个物品
        end
        -- if model.currentSliverSelectInfo ~= nil then
        --     LuaTimer.Add(1000, function ()
        --         self:OnBuy()
        --     end)
        -- end
    end
    -- end by 嘉俊
end

function MarketSliverPanel:SetItem(data, tab, i)
    local model = self.parent.model
    if data == nil then
        tab.obj:SetActive(false)
        return
    end
    tab.select:SetActive(false)
    tab.btn.onClick:RemoveAllListeners()
    local data1 = BaseUtils.copytab(data)
    tab.btn.onClick:AddListener(function ()
        for k,v in pairs(self.itemObjList) do
            v.select:SetActive(false)
        end
        model.selectPos = tonumber(tab.obj.name)
        self.itemObjList[model.selectPos].select:SetActive(true)
        local itemlist = model.sliverItemList[model.currentSliverMain]
        model.currentSliverSelectInfo = data1
        print("----------------------item select--------------------")
        if AutoQuestManager.Instance.model.isOpen then -- 玩家手动操作则取消自动历练 by 嘉俊 2017/9/1
            AutoQuestManager.Instance.disabledAutoQuest:Fire()
        end
        -- if model.currentSliverMain ~= self.petTab then
        --     model.currentSliverSelectInfo = data1.id
        -- else
        --     model.currentSliverSelectInfo = data1.base_id
        -- end
    end)

    tab.transform.localScale = Vector3(1, 1, 1)
    if i % 2 == 1 then
        tab.transform.anchoredPosition = Vector3(0 + 19, -10 - (i - 1) * 76 / 2, 0)
    else
        tab.transform.anchoredPosition = Vector3(245 + 19, -10 - (i - 2) * 76 / 2, 0)
    end
    tab.obj:SetActive(true)

    local itemData = nil
    if model.currentSliverMain ~= self.petTab then
        itemData = DataItem.data_get[data.item_base_id]
        --print(DataMarketSilver.data_market_silver_item[data.item_base_id].type)
    else
        itemData = DataPet.data_pet[data.base_id]
    end

    tab.transform:Find("Icon/Num").gameObject:SetActive(false)

    tab.iconImage.gameObject:SetActive(false)

    if model.currentSliverMain ~= self.petTab then
        local step = nil
        for _,v in pairs(data.item_attrs) do
            if v.attr == 1 then
                if v.value > 0 then
                    step = v.value
                end
                break
            end
        end

        local itemdata = ItemData.New()
        itemdata:SetBase(itemData)
        itemdata.step = step

        tab.slot.gameObject:SetActive(true)
        tab.slot:SetAll(itemdata, {inbag = false, nobutton = true, noselect = true, insliver = true})
        tab.slot:SetNum(data.num)

        if itemData.type == 158 then
            tab.nameText.text = string.format("%s <color=#017dd7>%s~%s</color>", itemData.name, DataExperienceBottle.data_get_exp[step].lev_min, DataExperienceBottle.data_get_exp[step].lev_max)
        elseif step ~= nil then
            tab.nameText.text = string.format("%s <color=#017dd7>Lv.%s</color>", itemData.name, step)
        else
            tab.nameText.text = itemData.name
        end
        tab.priceText.text = tostring(data.price)
        tab.soldoutObj:SetActive(not (data.status == 0))
        tab.iconImage.gameObject:SetActive(false)
        tab.levText.gameObject:SetActive(false)

        if self.needList[data.item_base_id] ~= nil and self.needInBackpack[data.item_base_id] < self.needList[data.item_base_id] then
            tab.isneedTipsObj:SetActive(true)
        else
            tab.isneedTipsObj:SetActive(false)
        end
    else
        tab.levText.gameObject:SetActive(true)
        tab.nameText.text = itemData.name
        tab.levText.text = string.format(TI18N(" (%s级)"), tostring(data.actv_lev))
        tab.priceText.text = tostring(data.def_buy_price)
        tab.iconImage.gameObject:SetActive(true)

        local loaderId = tab.iconImage.gameObject:GetInstanceID()
        if self.headLoaderList[loaderId] == nil then
            self.headLoaderList[loaderId] = SingleIconLoader.New(tab.iconImage.gameObject)
        end
        self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,itemData.head_id)
        -- tab.iconImage.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(itemData.head_id), itemData.head_id)
        tab.soldoutObj:SetActive(false)
        tab.slot.gameObject:SetActive(false)

        if self.needPetList[data.base_id] ~= nil and self.needInPet[data.base_id] < self.needPetList[data.base_id] then
            tab.isneedTipsObj:SetActive(true)
        else
            tab.isneedTipsObj:SetActive(false)
        end
    end

    if model.currentSliverMain ~= self.petTab then
        local gain_label = DataMarketSilver.data_market_silver_item[data.item_base_id].gain_label
        if gain_label == "coin" then
            tab.currencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90000")
        elseif gain_label == "gold" then
            tab.currencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90002")
        elseif gain_label == "gold_bind" then
            tab.currencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90003")
        end
    else
        tab.currencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90000")
    end

    -- return obj
end

function MarketSliverPanel:ShowRestTimeToRefresh(id)
    local model = self.parent.model
    if model.refreshTime == nil then
        return
    end

    local time = model.refreshTime - BaseUtils.BASE_TIME
    local msg = "00:00:00"

    -- print(time)

    if model.sliverRefreshType == 2 then
        if time > 0 then
            msg = os.date("00:%M:%S", time)
            self:UpdateRefreshButton(false)
        else
            model.sliverRefreshType = 1
            self:UpdateRefreshButton(true)
            LuaTimer.Delete(self.timerId)
        end
    end

    self.leftTimeText.text = msg
end

function MarketSliverPanel:UpdateRefreshButton(bool)
    local descText = self.refreshButton.transform:Find("FreeRefresh")
    descText.gameObject:SetActive(bool)
    local goldImage = self.refreshButton.transform:Find("Image")
    goldImage.gameObject:SetActive(not bool)
end

function MarketSliverPanel:RoleAssetsListener()
    if self.gameObject ~= nil and self.coinText ~= nil then
        self.coinText.text = tostring(RoleManager.Instance.RoleData.coin)
    end
end

function MarketSliverPanel:DoRefresh()
    if self.parent.model.sliverRefreshType == 1 then
        MarketManager.Instance:send12409(1)
    end
end

function MarketSliverPanel:GetNeedList()
    local needList = QuestManager.Instance:GetItemTarget()
    self.needList = {}
    self.needPetList = {}
    if needList ~= nil then
        for _,v in pairs(needList) do
            if v.type ~= 2 then
                if self.needList[v.id] == nil then
                    self.needList[v.id] = v.num
                else
                    self.needList[v.id] = self.needList[v.id] + v.num
                end
            else
                if self.needPetList[v.id] == nil then
                    self.needPetList[v.id] = v.num
                else
                    self.needPetList[v.id] = self.needPetList[v.id] + v.num
                end
            end
        end
    end

    needList = ShippingManager.Instance.shipping_need

    if needList ~= nil then
        for _,v in pairs(needList) do
            if v.type ~= 2 then
                if self.needList[v.id] == nil then
                    self.needList[v.id] = v.num
                else
                    self.needList[v.id] = self.needList[v.id] + v.num
                end
            else
                if self.needPetList[v.id] == nil then
                    self.needPetList[v.id] = v.num
                else
                    self.needPetList[v.id] = self.needPetList[v.id] + v.num
                end
            end
        end
    end

    self.needInBackpack = {}
    self.needInPet = {}
    for k,_ in pairs(self.needList) do
        self.needInBackpack[k] = BackpackManager.Instance:GetItemCount(k)
    end

    local petList = PetManager.Instance:Get_PetList()
    for k,_ in pairs(self.needPetList) do
        local c = 0
        if petList ~= nil then
            for _,v in pairs(petList) do
                if v.base_id == k and v.genre == 3 then
                    c = c + 1
                end
            end
        end
        self.needInPet[k] = c
    end
end

function MarketSliverPanel:UpdatePageButton()
    local model = self.parent.model
    local currentPage = model.currentSliverSub[model.currentSliverMain]
    local pageNum = self.pageNum

    local nextEnable = self.btnNextPage.gameObject.transform:Find("Enable").gameObject
    local nextDisable = self.btnNextPage.gameObject.transform:Find("Disable").gameObject

    local preEnable = self.btnPrePage.gameObject.transform:Find("Enable").gameObject
    local preDisable = self.btnPrePage.gameObject.transform:Find("Disable").gameObject

    if currentPage < pageNum then
        self.enableNextPage = true
        nextEnable:SetActive(true)
        nextDisable:SetActive(false)
    else
        self.enableNextPage = false
        nextEnable:SetActive(false)
        nextDisable:SetActive(true)
    end

    if currentPage > 1 then
        self.enablePrePage = true
        preDisable:SetActive(false)
        preEnable:SetActive(true)
    else
        self.enablePrePage = false
        preDisable:SetActive(true)
        preEnable:SetActive(false)
    end
end

function MarketSliverPanel:OnDown()
    self.isUp = false
    LuaTimer.Add(150, function()
        if self.isUp ~= false then
            return
        end
        if self.arrowEffect == nil then
            self.arrowEffect = BibleRewardPanel.ShowEffect(20009, self.btnBuy.gameObject.transform, Vector3(1, 1, 1), Vector3(0, 61, -400))
        else
            if not BaseUtils.is_null(self.arrowEffect.gameObject) then
                self.arrowEffect.gameObject:SetActive(false)
                self.arrowEffect.gameObject:SetActive(true)
            end
        end
    end)
end

function MarketSliverPanel:OnUp()
    self.isUp = true
    if self.arrowEffect ~= nil then
        self.arrowEffect:DeleteMe()
        self.arrowEffect = nil
    end
end

function MarketSliverPanel:OnBuy(num)
    -- if self.isUp ~= false then
    --     return
    -- end
    if BaseUtils.isnull(self.gameObject) then
        return
    end
    num = num or 1
    local model = self.parent.model
    if model.currentSliverSelectInfo ~= nil then
        if self.buyFrozen ~= nil then
            self.buyFrozen:OnClick()
        end
        if model.currentSliverMain ~= self.petTab then
            local classes = model.silverIdToClasses[model.currentSliverSelectInfo.item_base_id]
            if classes == nil or classes == RoleManager.Instance.RoleData.classes then
                for i=1,num do

                    MarketManager.Instance:send12405(model.currentSliverSelectInfo.type, model.currentSliverSelectInfo.id)
                end
            else
                local base_id = 0
                for k,v in pairs(model.silverIdToClasses) do
                    if RoleManager.Instance.RoleData.classes == v then
                        base_id = k
                        break
                    end
                end
                if DataItem.data_get[base_id] ~= nil then
                    NoticeManager.Instance:FloatTipsByString(string.format(TI18N("职业不符，<color='#00ff00'>%s</color>只能购买<color='#ffff00'>%s</color>哦{face_1,2}"), KvData.classes_name[RoleManager.Instance.RoleData.classes], tostring(DataItem.data_get[base_id].name)))
                end
                if self.buyFrozen ~= nil then
                    self.buyFrozen:Release()
                end
            end
            -- if model.currentSliverMain == self.mgr.sliverDataType.HightMed then
            -- else
            --     MarketManager.Instance:send12405(model.currentSliverMain, model.currentSliverSelectInfo)
            -- end
        else
            MarketManager.Instance:send10517(model.currentSliverSelectInfo.base_id)
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择要购买的物品"))
    end
end

function MarketSliverPanel:OnHold()
    local model = self.parent.model
    if model.currentSliverSelectInfo ~= nil then
        if model.currentSliverMain ~= self.petTab then
            local maxValue = model.currentSliverSelectInfo.num or 0
            if maxValue > 1 then
                -- self.numberpadSetting.max_result = maxValue
                -- NumberpadManager.Instance:set_data(self.numberpadSetting)
                self:OnNumberpadReturn()
            elseif maxValue == 1 then
                self:OnBuy()
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("已售罄"))
            end
        else
            self:OnBuy()
        end
        -- if self.buyFrozen ~= nil then
        --     self.buyFrozen:OnClick()
        -- end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择要购买的物品"))
    end
end

function MarketSliverPanel:OnNumberpadReturn()
    local model = self.parent.model
    local sliverData = DataMarketSilver.data_market_silver_item[model.currentSliverSelectInfo.item_base_id]
    local baseData = DataItem.data_get[sliverData.base_id]
    -- BaseUtils.dump(model.sliverItemList[sliverData.type], "model.sliverItemList[sliverData.type]")
    local info = model.sliverItemList[model.currentSliverSelectInfo.type][model.currentSliverSelectInfo.id]
    if info.num == 1 then
        self:OnBuy()
        return
    elseif info.num == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("已售罄"))
        return
    end
    local confirmData = NoticeConfirmData.New()
    confirmData.type = ConfirmData.Style.Normal
    confirmData.content = string.format(TI18N("是否消耗{assets_1, %s, %s}购买<color='#ffff00'>%s</color>个<color='#ffff00'>%s</color>？"), tostring(KvData.assets[sliverData.gain_label]), tostring(info.price * info.num), tostring(info.num), tostring(baseData.name))
    confirmData.sureCallback = function() self:OnBuy(info.num) end
    NoticeManager.Instance:ConfirmTips(confirmData)
end

function MarketSliverPanel:OnNotice()
    TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {
        TI18N("<color='#ffff00'>长按[购买]</color>可购买整个摊位的商品"),
    }})
end

function MarketSliverPanel:OnRoleLevelChange()
    if RoleManager.Instance.RoleData.lev_break_times > 0 then
        if RoleManager.Instance.RoleData.lev > 97 then
            self.tabData[6].lev = 255
        else
            self.tabData[6].lev = 95
        end
    else
        self.tabData[6].lev = 98
    end
    --    print("self.tabData[6].lev = " .. self.tabData[6].lev)
    if self.tabGroup ~= nil then
        self.tabListener()
    end
end

