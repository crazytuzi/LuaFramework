STStoragePanel = STStoragePanel or class("STStoragePanel", WindowPanel)
local STStoragePanel = STStoragePanel

function STStoragePanel:ctor()
    self.abName = "search_treasure"
    self.assetName = "STStoragePanel"
    self.layer = "UI"

    self.panel_type = 3
    self.use_background = true
    self.change_scene_close = true
    --self.click_bg_close = true
    --self.is_hide_other_panel = true
    --self.is_hide_bottom_panel = true

    self.model = BagModel:GetInstance()
end

function STStoragePanel:dctor()
end

function STStoragePanel:Open()
    STStoragePanel.super.Open(self)
end

function STStoragePanel:LoadCallBack()
    self.nodes = {
        "ScrollView", "ScrollView/Viewport", "ScrollView/Viewport/Content", "fetch_all", "sort",
    }
    self:GetChildren(self.nodes)

    self:AddEvent()

    self:SetTileTextImage("search_treasure_image", "storage_title")
    self:SetPanelSize(680, 470)
    self:SetMask()
end

function STStoragePanel:AddEvent()
    --[[local function call_back(bag_id)
        if bag_id ~= BagModel.stHouseId then
            return
        end
        self:ShowPanel()
    end
    self.event_id = self.model:AddListener(BagEvent.LoadItemByBagId, call_back)--]]

    local function call_back(target, x, y)
        local bagItems = self.model.bags[BagModel.stHouseId].bagItems or {}
        local storage_num = 0
        for k, v in pairs(bagItems) do
            if v ~= 0 then
                storage_num = storage_num + 1
            end
        end
        if storage_num > 0 then
            SearchTreasureController:GetInstance():RequestFetch()
        else
            Notify.ShowText("No item is available")
        end
    end
    AddClickEvent(self.fetch_all.gameObject, call_back)

    local function call_back(target, x, y)
        local bagItems = self.model.bags[BagModel.stHouseId].bagItems
        local fromSortIdx, endSortIdx = self.model:ArrangeGoods(bagItems)
        if fromSortIdx > 0 and endSortIdx > 0 and fromSortIdx ~= endSortIdx then
            for idx = fromSortIdx, endSortIdx do
                self.model:Brocast(BagEvent.BagArrange, BagModel.stHouseId, idx)
            end
        end
    end
    AddClickEvent(self.sort.gameObject, call_back)
end

function STStoragePanel:OpenCallBack()
    self:UpdateView()
end

function STStoragePanel:UpdateView()
    self:ShowPanel()
end

function STStoragePanel:ShowPanel()
    local cellCount = Config.db_bag[BagModel.stHouseId].cap
    self:CreateItems(cellCount)
end

function STStoragePanel:CloseCallBack()
    if self.event_id then
        self.model:RemoveListener(self.event_id)
    end

    if self.scrollView ~= nil then
        self.scrollView:OnDestroy()
        self.scrollView = nil
    end
    self.model = nil
    if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
end

function STStoragePanel:CreateItems(cellCount)
    local param = {}
    local cellSize = { width = 80, height = 80 }
    param["scrollViewTra"] = self.ScrollView
    param["cellParent"] = self.Content
    param["cellSize"] = cellSize
    param["cellClass"] = BagItemSettor
    param["begPos"] = Vector2(0, 0)
    param["spanX"] = 4
    param["spanY"] = 10
    param["createCellCB"] = handler(self, self.CreateCellCB)
    param["updateCellCB"] = handler(self, self.UpdateCellCB)
    param["cellCount"] = cellCount
    self.scrollView = ScrollViewUtil.CreateItems(param)
end

function STStoragePanel:CreateCellCB(itemCLS)
    self:UpdateCellCB(itemCLS)
end

function STStoragePanel:UpdateCellCB(itemCLS)
    local bagItems = self.model.bags[BagModel.stHouseId].bagItems
    if bagItems ~= nil then
        local itemBase = bagItems[itemCLS.__item_index]
        if itemBase ~= nil and itemBase ~= 0 then
            local configItem = Config.db_item[itemBase.id]
            if configItem ~= nil then
                --配置表存该物品
                local param = {}
                --type,uid,id,num,bag,bind,outTime
                param["type"] = configItem.type
                param["uid"] = itemBase.uid
                param["id"] = configItem.id
                param["num"] = itemBase.num
                param["bag"] = itemBase.bag
                param["bind"] = itemBase.bind
                param["outTime"] = itemBase.etime
                param["itemSize"] = {x=80, y=80}
                param["get_item_cb"] = handler(self, self.GetItemDataByIndex)
                param["model"] = self.model
                param["itemIndex"] = itemCLS.__item_index
                param["stencil_id"] = self.StencilId
                itemCLS:DeleteItem()
                itemCLS:UpdateItem(param)
            end
        else
            --Chkprint('--chk BagShowPanel.lua,line 125-- data=',data)
            local param = {}
            param["bag"] = BagModel.stHouseId
            param["get_item_cb"] = handler(self, self.GetItemDataByIndex)
            param["model"] = self.model
            param["itemSize"] = {x=80, y=80}
            param["stencil_id"] = self.StencilId
            itemCLS:InitItem(param)
        end
    else
        local param = {}
        param["bag"] = BagModel.stHouseId
        param["model"] = self.model
        param["get_item_cb"] = handler(self, self.GetItemDataByIndex)
        param["itemSize"] = {x=80, y=80}
        param["stencil_id"] = self.StencilId
        itemCLS:InitItem(param)
    end

    itemCLS:SetCellIsLock(BagModel.stHouseId)
end

--根据格子下标获取背包的数据
function STStoragePanel:GetItemDataByIndex(index)
    return self.model.bags[BagModel.stHouseId].bagItems[index]
end

function STStoragePanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end