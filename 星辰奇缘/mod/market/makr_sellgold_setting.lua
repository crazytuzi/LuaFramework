MarketSellgoldSetting = MarketSellgoldSetting or BaseClass(BasePanel)

function MarketSellgoldSetting:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "MarketSellgoldSetting"

    self.resList = {
        {file = AssetConfig.market_sellgold_setting, type = AssetType.Main},
    }

    self.pageList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MarketSellgoldSetting:__delete()
    self.OnHideEvent:Fire()
    if self.pageList ~= nil then
        for _,page in pairs(self.pageList) do
            if page.items ~= nil then
                for _,item in pairs(page.items) do
                    if item.imageLoader ~= nil then
                        item.imageLoader:DeleteMe()
                    end
                end
            end
        end
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.tabbedPanel ~= nil then
        self.tabbedPanel:DeleteMe()
        self.tabbedPanel = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MarketSellgoldSetting:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.market_sellgold_setting))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)

    local main = t:Find("Main")
    self.scroll = main:Find("Scroll"):GetComponent(ScrollRect)
    self.container = self.scroll.transform:Find("Container")
    self.cloner = self.scroll.transform:Find("Page").gameObject

    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X, cspacing = 0, border = 0})
    self.tabbedPanel = TabbedPanel.New(self.scroll.gameObject, 0, 325, 0.6)
    self.toggleCroup = main:Find("ToggleGroup")
    self.option1 = main:Find("Option"):GetChild(0):GetComponent(Toggle)
    self.option1LabelText = main:Find("Option"):GetChild(0):Find("Label"):GetComponent(Text)
    self.option2 = main:Find("Option"):GetChild(1):GetComponent(Toggle)
    self.option2LabelText = main:Find("Option"):GetChild(1):Find("Label"):GetComponent(Text)

    self.tabbedPanel.MoveEndEvent:AddListener(function(pageIndex) self:OnMoveEnd(pageIndex) end)

    self.option1LabelText.text = TI18N("低级装备魂、翅膀材料")
    self.option2LabelText.text = TI18N("手动出售过的以下道具")
    self.option1.onValueChanged:AddListener(function() self:OnValueChanged(1) end)
    self.option2.onValueChanged:AddListener(function() self:OnValueChanged(2) end)

    self.gameObject:GetComponent(Button).onClick:AddListener(function() self.model:CloseSellgoldSetting() end)
end

function MarketSellgoldSetting:OnOpen()
    self:RemoveListeners()

    self:Reload()
end

function MarketSellgoldSetting:OnHide()
    self:RemoveListeners()
    self:SetHistory()
end

function MarketSellgoldSetting:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MarketSellgoldSetting:RemoveListeners()
end

function MarketSellgoldSetting:Reload()
    local model = self.model
    self.selectTab = {}
    local tab = self.model.goldHistory or {}
    local datalist = {}

    for i,base_id in ipairs(tab.list or {}) do
        if model.conditionTab[base_id] == nil then
            table.insert(datalist, base_id)
        end
    end

    local pageIndex = 0
    local itemIndex = 0
    local page = nil
    local item = nil

    for i,v in ipairs(datalist) do
        pageIndex = math.ceil(i / 20)
        itemIndex = (i - 1) % 20 + 1
        page = self.pageList[pageIndex]
        if page == nil then
            page = {items = {}}
            page.gameObject = GameObject.Instantiate(self.cloner)
            self.layout:AddCell(page.gameObject)
            page.gameObject.name = tostring(pageIndex)
            local btnList = page.gameObject:GetComponentsInChildren(Button)
            for j,btn in ipairs(btnList) do
                item = {}
                item.btn = btn
                item.gameObject = btn.gameObject
                item.transform = btn.transform
                item.imageLoader = SingleIconLoader.New(item.transform:Find("Image").gameObject)
                item.select = item.transform:Find("Select").gameObject
                item.tick = item.transform:Find("Tick").gameObject
                page.items[j] = item

                local tempTab = item
                item.btn.onClick:AddListener(function() self:OnClick(tempTab) end)

                item.imageLoader.gameObject:SetActive(false)
                item.select:SetActive(false)
                item.tick:SetActive(false)
            end
            page.toggle = self.toggleCroup:GetChild(pageIndex - 1):GetComponent(Toggle)
            self.pageList[pageIndex] = page
        end

        item = page.items[itemIndex]
        item.base_id = v
        item.imageLoader.gameObject:SetActive(true)
        item.imageLoader:SetSprite(SingleIconType.Item, DataItem.data_get[v].icon)
        self.selectTab[v] = 1
        item.select:SetActive(true)
        item.tick:SetActive(true)
        page.gameObject:SetActive(true)
        page.toggle.gameObject:SetActive(true)
    end

    for i=pageIndex + 1,#self.pageList do
        self.pageList[i].gameObject:SetActive(false)
        self.pageList[i].toggle.gameObject:SetActive(false)
    end

    if pageIndex == 0 then
        pageIndex = 1
        page = self.pageList[pageIndex]
        if page == nil then
            page = {items = {}}
            page.gameObject = GameObject.Instantiate(self.cloner)
            page.gameObject.name = tostring(pageIndex)
            self.layout:AddCell(page.gameObject)
            local btnList = page.gameObject:GetComponentsInChildren(Button)
            for j,btn in ipairs(btnList) do
                item = {}
                item.btn = btn
                item.gameObject = btn.gameObject
                item.transform = btn.transform
                item.imageLoader = SingleIconLoader.New(item.transform:Find("Image").gameObject)
                item.select = item.transform:Find("Select").gameObject
                item.tick = item.transform:Find("Tick").gameObject
                page.items[j] = item

                local tempTab = item
                item.btn.onClick:AddListener(function() self:OnClick(tempTab) end)

                item.imageLoader.gameObject:SetActive(false)
                item.select:SetActive(false)
                item.tick:SetActive(false)
            end
            self.pageList[pageIndex] = page
        end
    else
        for i=itemIndex + 1,#self.pageList[pageIndex].items do
            local tab = self.pageList[pageIndex].items[i]
            tab.select:SetActive(false)
            tab.tick:SetActive(false)
            tab.imageLoader.gameObject:SetActive(false)
        end
    end

    self.tabbedPanel:SetPageCount(pageIndex)

    self.cloner:SetActive(false)
    self.option1.isOn = (model.goldHistory.option1 == nil or model.goldHistory.option1 == 1)
    self.option2.isOn = (model.goldHistory.option2 == nil or model.goldHistory.option2 == 1)
end

function MarketSellgoldSetting:OnMoveEnd(pageIndex)
    if self.pageList ~= nil then
        for i,v in ipairs(self.pageList) do
            v.toggle.isOn = (i == pageIndex)
        end
    end
end

function MarketSellgoldSetting:OnClick(tab)
    if tab.imageLoader.gameObject.activeInHierarchy == false then
        return
    end
    if self.selectTab[tab.base_id] ~= nil then
        self.selectTab[tab.base_id] = 1 - self.selectTab[tab.base_id]
        if self.selectTab[tab.base_id] == 0 then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("{item_2, %s, 1, 1}<color='#00ff00'>不再一键出售</color>"), tostring(tab.base_id)))
        else
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("{item_2, %s, 1, 1}<color='#00ff00'>将一键出售</color>"), tostring(tab.base_id)))
        end
    else
        self.selectTab[tab.base_id] = 1
    end
    tab.select:SetActive(not tab.select.activeSelf)
    tab.tick:SetActive(not tab.tick.activeSelf)
end

function MarketSellgoldSetting:OnValueChanged(index)
    if self["option" .. index].isOn == true then
        self.model.goldHistory["option" .. index] = 1
    else
        self.model.goldHistory["option" .. index] = 0
    end
end

function MarketSellgoldSetting:SetHistory()
    local model = self.model
    model.goldHistory.list = {}
    for base_id,status in pairs(self.selectTab) do
        if status == 1 then
            table.insert(model.goldHistory.list, base_id)
        end
    end
end

