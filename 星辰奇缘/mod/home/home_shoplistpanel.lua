HomeShopListPanel = HomeShopListPanel or BaseClass(BasePanel)

function HomeShopListPanel:__init(model, parent, dataList, main)
    self.model = model
    self.parent = parent
    self.dataList = dataList
    self.main = main
    self.isinit = false
    self.resList = {
        {file = AssetConfig.shoplistpanel, type = AssetType.Main}
        ,{file = AssetConfig.shop_textures, type = AssetType.Dep}
    }

    self.itemList = {}
    self.panelList = {}
    self.toggleList = {}
    self.gridLayoutList = {}
    self.hasInitPage = {}

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.updatePanelListener = function() self:UpdateBuyPanel() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
    self.loaders = {}
end

function HomeShopListPanel:__delete()
    for k,v in pairs(self.loaders) do
        v:DeleteMe()
    end
    self.loaders = nil

    self.OnHideEvent:Fire()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.gridLayoutList ~= nil then
        for k,v in pairs(self.gridLayoutList) do
            if v ~= nil then
                v:DeleteMe()
                self.gridLayoutList[k] = nil
                v = nil
            end
        end
    end
    if self.itemList ~= nil then
        for k,v in pairs(self.itemList) do
            if v ~= nil then
                self.itemList[k]:DeleteMe()
                self.itemList[k] = nil
                v = nil
            end
        end
        self.itemList = nil
    end
    if self.toggleLayout ~= nil then
        self.toggleLayout:DeleteMe()
        self.toggleLayout = nil
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

function HomeShopListPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shoplistpanel))
    self.gameObject.name = "SelectPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.transform = self.gameObject.transform
    local t = self.transform

    self.goodsPanel = t:Find("GoodsPanel")
    self.itemPanelCloner = self.goodsPanel:Find("ItemPage").gameObject
    -- self.itemCloner = self.goodsPanel:Find("ItemPage/Item").gameObject
    self.panelContainer = self.goodsPanel:Find("Panel/Container")
    self.panelScrollRect = self.goodsPanel:Find("Panel"):GetComponent(ScrollRect)
    self.panelRect = self.goodsPanel:Find("Panel"):GetComponent(RectTransform)
    self.pageRect = self.itemPanelCloner:GetComponent(RectTransform)
    self.toggleContainer = t:Find("ToggleGroup")
    self.toggleCloner = self.toggleContainer:Find("Toggle").gameObject
    self.layout = LuaBoxLayout.New(self.panelContainer, {Top = 10, axis = BoxLayoutAxis.X, cspacing = 4})
    self.toggleLayout = LuaBoxLayout.New(self.toggleContainer, {axis = BoxLayoutAxis.X})

    -- self.itemPanelCloner:SetActive(false)
    self.toggleCloner:SetActive(false)
    self.itemPanelCloner:SetActive(false)
    self.isinit = true
    self:ReloadItemPanel()
    self.OnOpenEvent:Fire()
end

function HomeShopListPanel:OnOpen()
    local model = self.model
    local roleData = RoleManager.Instance.RoleData

end

function HomeShopListPanel:ReloadItemPanel()
    if self.isinit == false then
        return
    end
    local pagenum = math.ceil(#self.dataList/8)
    self.pageNum = pagenum
    for k,v in pairs(self.panelList) do
        v:SetActive(false)
    end
    self.layout:ReSet()
    self.toggleLayout:ReSet()
    for i=1, pagenum do
        if self.panelList[i] == nil then
            local pageitem = GameObject.Instantiate(self.itemPanelCloner)
            self.panelList[i] = pageitem
            self.panelList[i].name = tostring(i)
        end
        self.layout:AddCell(self.panelList[i])
        self:SetItemPanel(self.panelList[i], i)
        if self.toggleList[i] == nil then
            self.toggleList[i] = GameObject.Instantiate(self.toggleCloner)
            self.toggleList[i].name = tostring(i)
        end
        self.toggleLayout:AddCell(self.toggleList[i])
        -- self.toggleList[i] = self.toggleList[i]:GetComponent(Toggle)
        self.toggleList[i]:GetComponent(Toggle).isOn = i==1
    end
    if self.tabbedPanel == nil then
        self.tabbedPanel = TabbedPanel.New(self.panelScrollRect.gameObject, pagenum, self.pageRect.sizeDelta.x)
    else
        self.tabbedPanel:SetPageCount(pagenum)
    end
    self.tabbedPanel.MoveEndEvent:Add(function(currentPage, direction) self:OnDragEnd(currentPage, direction) end)
end


function HomeShopListPanel:OnHide()
    self:RemoveListeners()
end

function HomeShopListPanel:RemoveListeners()
end

function HomeShopListPanel:OnDragEnd(currentPage, direction)
    if direction == LuaDirection.Left then
        if currentPage > 1 then
            self.toggleList[currentPage - 1]:GetComponent(Toggle).isOn = false
        end
        self.toggleList[currentPage]:GetComponent(Toggle).isOn = true
    elseif direction == LuaDirection.Right then
        if currentPage < self.pageNum then
            self.toggleList[currentPage + 1]:GetComponent(Toggle).isOn = false
        end
        self.toggleList[currentPage]:GetComponent(Toggle).isOn = true
    end
end


function HomeShopListPanel:SetItemPanel(panel, pageindex)
    for i= 1, 8 do
        local basedata = self.dataList[(pageindex-1)*8+i]
        local item = panel.transform:GetChild(i-1)
        if basedata ~= nil then
            item.gameObject:SetActive(true)
            self:SetItem(item, basedata)
        else
            item.gameObject:SetActive(false)
        end
    end
end


function HomeShopListPanel:SetItem(Item, data)
    if DataFamily.data_unit[data.base_id] == nil then
        Log.Error("这个家具商品信息不对啊？？"..tostring(data.base_id))
    end
    local itemid = DataFamily.data_unit[data.base_id].item_id
    local baseItemData = DataItem.data_get[itemid]
    Item:Find("Name"):GetComponent(Text).text = baseItemData.name
    Item:Find("PriceBg/Price"):GetComponent(Text).text = data.val
    Item:Find("PriceBg/Currency"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..tostring(data.type))
    Item:Find("TipsLabel").gameObject:SetActive(false)

    local go = Item:Find("IconBg/Icon").gameObject
    local id = go:GetInstanceID()
    local imgLoader = self.loaders[id]
    if imgLoader == nil then
        imgLoader = SingleIconLoader.New(go)
        self.loaders[id] = imgLoader
    end
    imgLoader:SetSprite(SingleIconType.Item, baseItemData.icon)

    Item:Find("SoldoutImage").gameObject:SetActive(data.count == 0)
    if data.count > 1 then
        Item:Find("Num").gameObject:SetActive(true)
        Item:Find("Num"):GetComponent(Text).text = tostring(data.count)
        Item:Find("SoldoutImage").gameObject:SetActive(false)
    else
        Item:Find("Num").gameObject:SetActive(false)
        if data.count <= 0 then
            Item:Find("SoldoutImage").gameObject:SetActive(true)
        end
    end


    local SelectImg = Item:Find("Select").gameObject
    SelectImg:SetActive(false)
    Item:GetComponent(Button).onClick:RemoveAllListeners()
    Item:GetComponent(Button).onClick:AddListener(function()
        if self.main.SelectObj ~= nil then
            self.main.SelectObj:SetActive(false)
        end
        self.main.SelectObj = SelectImg
        self.main.SelectObj:SetActive(true)
        self.main:OnClickItem(Item,data)
    end)
    if self.main.SelectObj == nil then
        -- self.main.SelectObj = SelectImg
        -- self.main.SelectObj:SetActive(true)
        -- self.main:OnClickItem(Item,data)
    elseif self.main.SelectObj == SelectImg then
        self.main:OnClickItem(Item,data)
    end
end

function HomeShopListPanel:ReloadData(dataList)
    self.dataList = dataList
    self:ReloadItemPanel()
end