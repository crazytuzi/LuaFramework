ShopGoodsPanel = ShopGoodsPanel or BaseClass(BasePanel)

function ShopGoodsPanel:__init(model, parent, main, sub, callback)
    self.model = ShopManager.Instance.model
    self.parent = parent
    self.main = main
    self.sub = sub
    self.callback = callback
    self.mgr = ShopManager.Instance

    self.resList = {
        {file = AssetConfig.shop_select_panel, type = AssetType.Main}
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
end

function ShopGoodsPanel:__delete()
    self.OnHideEvent:Fire()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.gridLayoutList ~= nil then
        for k,v in pairs(self.gridLayoutList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.gridLayoutList = nil
    end
    if self.itemList ~= nil then
        for k,v in pairs(self.itemList) do
            if v ~= nil then
                self.itemList[k]:DeleteMe()
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
    self.model.selectObj = nil
    self:AssetClearAll()
end

function ShopGoodsPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shop_select_panel))
    self.gameObject.name = "SelectPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.transform = self.gameObject.transform
    local t = self.transform

    self.goodsPanel = t:Find("GoodsPanel")
    self.itemPanelCloner = self.goodsPanel:Find("ItemPage").gameObject
    self.itemCloner = self.goodsPanel:Find("ItemPage/Item").gameObject
    self.panelContainer = self.goodsPanel:Find("Panel/Container")
    self.panelScrollRect = self.goodsPanel:Find("Panel"):GetComponent(ScrollRect)
    self.panelRect = self.goodsPanel:Find("Panel")
    self.pageRect = self.itemPanelCloner.transform
    self.toggleContainer = t:Find("ToggleGroup")
    self.toggleCloner = self.toggleContainer:Find("Toggle").gameObject

    self.itemCloner:SetActive(false)
    self.toggleCloner:SetActive(false)
    self.itemPanelCloner:SetActive(false)

    -- self.OnOpenEvent:Fire()
end

function ShopGoodsPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ShopGoodsPanel:OnOpen()
    local model = self.model
    local roleData = RoleManager.Instance.RoleData

    self:ReloadItemPanel()
    if self.main == 1 then
        model.infoCurrencyType = KvData.assets["gold"]
        if self.sub == 3 then
            ShopManager.Instance:send13902()
        elseif self.sub == 5 then
            model.infoCurrencyType = KvData.assets["star_gold"]
        end
    elseif self.main == 2 then
        if self.sub == 1 then
            model.infoCurrencyType = KvData.assets["stars_score"]
        elseif self.sub == 2 then
            model.infoCurrencyType = KvData.assets["character"]
        elseif self.sub == 3 then
            model.infoCurrencyType = KvData.assets["love"]
        elseif self.sub == 4 then
            model.infoCurrencyType = KvData.assets["teacher_score"]
        elseif self.sub == 5 then
            model.infoCurrencyType = KvData.assets["tournament"]
        elseif self.sub == 16 then
            model.infoCurrencyType = KvData.assets["brother"]
        else
            model.infoCurrencyType = KvData.assets["gold"]
        end
    else
        model.infoCurrencyType = KvData.assets["gold"]
    end
    self.mgr.onUpdateCurrency:Fire()

    for i=1,self.pageNum do
        self:InitDataPanel(i)
    end
    if self.pageNum > 0 then
        self.tabbedPanel:TurnPage(1)
        self.toggleList[1].isOn = true
    end

    self:RemoveListeners()
    self.mgr.onUpdateBuyPanel:AddListener(self.updatePanelListener)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.updatePanelListener)

    if self.main ~= 2 or self.sub ~= 2 then
        self.mgr.redPoint[self.main][self.sub] = false
    end
    self.mgr.specialRed[self.main][self.sub] = false
    self.mgr.onUpdateRedPoint:Fire()

    self.model.currentSub = 1

    PlayerPrefs.SetInt(BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id, ShopManager.Instance.TTimeLimit, self.main, self.sub), BaseUtils.BASE_TIME)

    if self.model.autoSelect == 1 then
        if self.itemList[1] ~= nil then
            self.itemList[1].btn.onClick:Invoke()
        end
        self.model.autoSelect = nil
    else
        self.callback()
    end
end

function ShopGoodsPanel:ReloadItemPanel()
    local model = self.model

    if self.layout == nil then
        self.layout = LuaBoxLayout.New(self.panelContainer, {axis = BoxLayoutAxis.X, cspacing = 4})
        self.toggleLayout = LuaBoxLayout.New(self.toggleContainer, {axis = BoxLayoutAxis.X})
    else
        self.layout:ReSet()
        self.toggleLayout:ReSet()
    end

    self.pageNum = ShopManager.Instance.model.pageNum[self.main][self.sub]
    if self.pageNum == nil then self.pageNum = 0 end
    for i=1,self.pageNum do
        if self.panelList[i] == nil then
            self.panelList[i] = GameObject.Instantiate(self.itemPanelCloner)
            self.panelList[i].name = tostring(i)
            self.toggleList[i] = GameObject.Instantiate(self.toggleCloner)
            self.toggleList[i].name = tostring(i)
            self.toggleList[i] = self.toggleList[i]:GetComponent(Toggle)
        end
        self.layout:AddCell(self.panelList[i])
        self.toggleLayout:AddCell(self.toggleList[i].gameObject)
        self.toggleList[i].isOn = false
    end
    for i=self.pageNum + 1, #self.panelList do
        self.panelList[i]:SetActive(false)
        self.toggleList[i].gameObject:SetActive(false)
    end
    if self.tabbedPanel == nil then
        self.tabbedPanel = TabbedPanel.New(self.panelScrollRect.gameObject, self.pageNum, self.pageRect.sizeDelta.x)
    else
        self.tabbedPanel:SetPageCount(self.pageNum)
    end
    if self.toggleList[1] ~= nil then
        self.toggleList[1].isOn = true
    end
    self.tabbedPanel.MoveEndEvent:Add(function(currentPage, direction) self:OnDragEnd(currentPage, direction) end)
end

function ShopGoodsPanel:InitDataPanel(index)
    local model = self.model
    if self.gridLayoutList[index] ~= nil then
        self.gridLayoutList[index]:ReSet()
    else
        self.gridLayoutList[index] = LuaGridLayout.New(self.panelList[index], {column = 2, cellSizeX = 239, cellSizeY = 87, cspacing = 4})
    end
    self.datalist = model.datalist[self.main][self.sub]
    if self.datalist == nil then self.datalist = {} end
    local obj = nil
    local j = nil
    for i=1,8 do
        j = (index - 1) * 8 + i
        if self.itemList[j] == nil then
            obj = GameObject.Instantiate(self.itemCloner)
            obj.name = tostring(j)
            self.itemList[j] = ShopItem.New(self.model, obj, self.callback)
            self.gridLayoutList[index]:AddCell(obj)
        end
        if self.datalist[j] ~= nil then
            self.itemList[j]:SetData(self.datalist[j], j)
        else
            self.itemList[j]:SetActive(false)
        end
    end

    self.panelList[index]:SetActive(true)
end

function ShopGoodsPanel:OnHide()
    self:RemoveListeners()
end

function ShopGoodsPanel:RemoveListeners()
    self.mgr.onUpdateBuyPanel:RemoveListener(self.updatePanelListener)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.updatePanelListener)
end

function ShopGoodsPanel:OnDragEnd(currentPage, direction)
    local model = self.model
    if currentPage < 1 or currentPage > self.pageNum then
        return
    end
    if direction == LuaDirection.Left then
        if currentPage > 1 then
            self.toggleList[currentPage - 1].isOn = false
        end
        self.toggleList[currentPage].isOn = true
    elseif direction == LuaDirection.Right then
        if currentPage < self.pageNum then
            self.toggleList[currentPage + 1].isOn = false
        end
        self.toggleList[currentPage].isOn = true
    end
end

function ShopGoodsPanel:UpdateBuyPanel()
    self.mgr.redPoint[self.main][self.sub] = false
    self.mgr.onUpdateRedPoint:Fire()

    self:ReloadItemPanel()
    for i=1,self.pageNum do
        self:InitDataPanel(i)
    end
end

