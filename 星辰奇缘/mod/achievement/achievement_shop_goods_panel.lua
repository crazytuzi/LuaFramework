AchievementShopGoodsPanel = AchievementShopGoodsPanel or BaseClass(BasePanel)

function AchievementShopGoodsPanel:__init(model, parent, main, sub, callback)
    self.model = model
    self.parent = parent
    self.main = main
    self.sub = sub
    self.callback = callback
    self.mgr = AchievementManager.Instance

    self.resList = {
        {file = AssetConfig.achievementshopselectpanel, type = AssetType.Main}
        , {file = AssetConfig.badge_icon, type = AssetType.Dep}  --徽章
        , {file = AssetConfig.photo_frame, type = AssetType.Dep}  --相框
        , {file = AssetConfig.teammark_icon, type = AssetType.Dep}  --队标
        , {file = AssetConfig.zonestyleicon, type = AssetType.Dep}  --主题图标
        , {file = AssetConfig.chat_prefix, type = AssetType.Dep}  --聊天前缀
        , {file = AssetConfig.footmark_icon, type = AssetType.Dep}  --足迹
    }

    self.itemList = {}
    self.panelList = {}
    self.toggleList = {}
    self.gridLayoutList = {}
    self.hasInitPage = {}

    self.itemCloner = {}

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.updatePanelListener = function() self:UpdateBuyPanel() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function AchievementShopGoodsPanel:__delete()
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

function AchievementShopGoodsPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.achievementshopselectpanel))
    self.gameObject.name = "AchievementShopGoodsPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.transform = self.gameObject.transform
    local t = self.transform

    self.goodsPanel = t:Find("GoodsPanel")
    self.itemPanelCloner = self.goodsPanel:Find("ItemPage").gameObject
    self.panelContainer = self.goodsPanel:Find("Panel/Container")
    self.panelScrollRect = self.goodsPanel:Find("Panel"):GetComponent(ScrollRect)
    self.panelRect = self.goodsPanel:Find("Panel"):GetComponent(RectTransform)
    self.pageRect = self.itemPanelCloner:GetComponent(RectTransform)
    self.toggleContainer = t:Find("ToggleGroup")
    self.toggleCloner = self.toggleContainer:Find("Toggle").gameObject


    self.toggleCloner:SetActive(false)
    self.itemPanelCloner:SetActive(false)

    for i=1,6 do
        self.itemCloner[i] = self.goodsPanel:Find("ItemPage/Item"..i).gameObject
        self.itemCloner[i]:SetActive(false)
    end
    self.OnOpenEvent:Fire()
end

function AchievementShopGoodsPanel:OnOpen()
    local model = self.model
    local roleData = RoleManager.Instance.RoleData

    -- if model.datalist[self.main][self.sub] == {} then
    --     print(string.format("%s %s", self.main, self.sub))
    --     self.mgr:Send16200(self.sub)
    -- end

    model.infoCurrencyType = KvData.assets["gold"]
    self.mgr.onUpdateCurrency:Fire()

    self:RemoveListeners()
    self.mgr.onUpdateBuyPanel:AddListener(self.updatePanelListener)

    self:getdatalist()

    self:ReloadItemPanel()

    for i=1,self.pageNum do
        self:InitDataPanel(i)
    end
    if self.itemList[1] then
        self.itemList[1]:onClick()
    end
    if self.pageNum > 0 then
        self.tabbedPanel:TurnPage(1)
        self.toggleList[1].isOn = true
        for i=2, #self.toggleList do
            self.toggleList[i].isOn = false
        end
    end

    -- if self.main ~= 2 or self.sub ~= 2 then
    --     self.mgr.redPoint[self.main][self.sub] = false
    -- end
    -- self.mgr.specialRed[self.main][self.sub] = false
    -- self.mgr.onUpdateRedPoint:Fire()

    self.model.currentSub = 1

    PlayerPrefs.SetInt(BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id, ShopManager.Instance.TTimeLimit, self.main, self.sub), BaseUtils.BASE_TIME)
end

function AchievementShopGoodsPanel:ReloadItemPanel()
    local model = self.model
    if self.layout ~= nil then
        self.layout:DeleteMe()
    end

    self.layout = LuaBoxLayout.New(self.panelContainer, {axis = BoxLayoutAxis.X, cspacing = 4})
    self.toggleLayout = LuaBoxLayout.New(self.toggleContainer, {axis = BoxLayoutAxis.X})

    for i=1,self.pageNum do
        if self.panelList[i] == nil then
            self.panelList[i] = GameObject.Instantiate(self.itemPanelCloner)
            self.panelList[i].name = tostring(i)
            self.layout:AddCell(self.panelList[i])
            self.toggleList[i] = GameObject.Instantiate(self.toggleCloner)
            self.toggleList[i].name = tostring(i)
            self.toggleLayout:AddCell(self.toggleList[i])
            self.toggleList[i] = self.toggleList[i]:GetComponent(Toggle)
        end
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
    self.tabbedPanel.MoveEndEvent:Add(function(currentPage, direction) self:OnDragEnd(currentPage, direction) end)
end

function AchievementShopGoodsPanel:InitDataPanel(index)
    local model = self.model
    if self.gridLayoutList[index] ~= nil then
        self.gridLayoutList[index]:DeleteMe()
    end

    local column = model.goodsPanelSetting[self.main][self.sub][1]
    local cellSizeX = model.goodsPanelSetting[self.main][self.sub][2]
    local cellSizeY = model.goodsPanelSetting[self.main][self.sub][3]
    local cspacing = model.goodsPanelSetting[self.main][self.sub][4]
    local pageNum = model.goodsPanelSetting[self.main][self.sub][5]
    local itemCloner = self.itemCloner[model.goodsPanelSetting[self.main][self.sub][6]]
    local rspacing = model.goodsPanelSetting[self.main][self.sub][7]
    self.gridLayoutList[index] = LuaGridLayout.New(self.panelList[index], {column = column, cellSizeX = cellSizeX, cellSizeY = cellSizeY, cspacing = cspacing, rspacing = rspacing})
    local obj = nil

    for i=1,pageNum do
        if self.itemList[(index - 1) * pageNum + i] == nil then
            obj = GameObject.Instantiate(itemCloner)
            obj.name = tostring((index - 1) * pageNum + i)
            self.itemList[(index - 1) * pageNum + i] = AchievementShopItem.New(self, self.model, obj, self.callback)
            self.gridLayoutList[index]:AddCell(obj)
        end

        if self.datalist[(index - 1) * pageNum + i] ~= nil then
            self.itemList[(index - 1) * pageNum + i]:SetData(self.datalist[(index - 1) * pageNum + i], (index - 1) * pageNum + i)
        else
            self.itemList[(index - 1) * pageNum + i]:SetActive(false)
        end
    end

    self.panelList[index]:SetActive(true)
end

function AchievementShopGoodsPanel:OnHide()
    self:RemoveListeners()
end

function AchievementShopGoodsPanel:RemoveListeners()
    self.mgr.onUpdateBuyPanel:RemoveListener(self.updatePanelListener)
end

function AchievementShopGoodsPanel:OnDragEnd(currentPage, direction)
    local model = self.model
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

function AchievementShopGoodsPanel:UpdateBuyPanel()
    -- self.mgr.redPoint[self.main][self.sub] = false
    -- self.mgr.onUpdateRedPoint:Fire()

    self:getdatalist()

    self:ReloadItemPanel()

    for i=1,self.pageNum do
        self:InitDataPanel(i)
    end

    -- if self.itemList[1] then
    --     self.itemList[1]:onClick()
    -- end
end

function AchievementShopGoodsPanel:getdatalist()
    local model = self.model
    if self.sub == 1 then
        self.datalist = {}
        if model.datalist[self.main][1] then
            for k,v in pairs(model.datalist[self.main][1]) do
                table.insert(self.datalist, v)
            end
        end
        if model.datalist[self.main][2] then
            for k,v in pairs(model.datalist[self.main][2]) do
                table.insert(self.datalist, v)
            end
        end
        self.pageNum = math.ceil((#self.datalist) / model.goodsPanelSetting[1][1][5]) -- 计算页数
    elseif self.sub == 2 then
        self.datalist = {}
        for k,v in pairs(model.datalist[self.main][self.sub + 1]) do
            if v.id <233 or v.id >241 then
                table.insert(self.datalist,v)
            else
                if  v.state == 1  then
                      table.insert(self.datalist,v)
                end
            end
        end
        if self.datalist == nil then self.datalist = {} end
        self.pageNum = math.ceil((#self.datalist) / model.goodsPanelSetting[1][self.sub][5]) -- 计算页数
    elseif self.sub == 6 then
        self.datalist = {}
        for k,v in pairs(model.datalist[self.main][self.sub + 2]) do
            table.insert(self.datalist,v)
        end
        if self.datalist == nil then self.datalist = {} end
        self.pageNum = math.ceil((#self.datalist) / model.goodsPanelSetting[1][self.sub][5]) -- 计算页数
    else
        self.datalist = model.datalist[self.main][self.sub + 1]
        if self.datalist == nil then self.datalist = {} end
        self.pageNum = math.ceil((#self.datalist) / model.goodsPanelSetting[1][self.sub][5]) -- 计算页数
    end

    local sortfun = function(a,b)
        return a.sort_id < b.sort_id
    end
    table.sort(self.datalist, sortfun)

    if #self.datalist == 0 then
        if self.sub == 1 then
            AchievementManager.Instance:Send10226(1)
            AchievementManager.Instance:Send10226(2)
        else
            AchievementManager.Instance:Send10226(self.sub + 1)
        end
    end
end