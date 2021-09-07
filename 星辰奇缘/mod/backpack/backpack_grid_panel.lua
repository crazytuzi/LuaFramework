-- ----------------------------
-- 背包道具分页，格子部分
-- 抽出让全局公用
-- 怎么管理呢
-- hosr
-- ----------------------------
BackpackGridPanel = BackpackGridPanel or BaseClass(BasePanel)

--isInStorage 是否显示存入按钮，否，则显示取出按钮
function BackpackGridPanel:__init(parentClass, showSell, storageType, isInStorage, doubleClickFunc)
    self.parentClass = parentClass
    self.resList = {
        {file = AssetConfig.backpack_grid, type = AssetType.Main},
        {file = AssetConfig.slotbg, type = AssetType.Dep},
    }
    self.parent = nil
    self.setting = {
        column = 5
        ,cspacing = 5
        ,rspacing = 1
        ,cellSizeX = 64
        ,cellSizeY = 64
    }
    self.slotItem = {}
    self.tempItem = {}
    self.initTab = {}
    self.dataList = {}
    self.lockList = {}

    self.onInitCompletedCallback = nil

    self.storageType = storageType or BackpackEumn.StorageType.Backpack --默认背包类型

    if self.storageType == BackpackEumn.StorageType.Backpack then --背包
        -- self.maxPage = math.min(5, math.ceil(BackpackManager.Instance.volumeOfItem / 25) + 1)
        if math.ceil(BackpackManager.Instance.volumeOfItem / 25) > 3 then
            -- 开过的显示5页
            self.maxPage = 5
        else
            -- 没开过的显示4页
            self.maxPage = 4
        end
        self.localPos = {x = 0, y = 44}
        if isInStorage ~= nil and isInStorage == true then
            self.extra = {inbag = true, noshowTag = (showSell ~= true),nobutton = true,white_list= {{id = TipsEumn.ButtonType.InStore,show = true}},storageType = self.storageType}
        else
            self.extra = {inbag = true, noshowTag = (showSell ~= true)}
        end
    elseif self.storageType == BackpackEumn.StorageType.Store then --仓库
        self.maxPage = 4
        if isInStorage ~= nil and isInStorage == false then
            self.localPos = {x = -185, y = 44}
            self.extra = {instore = true, inbag = false, noshowTag = (showSell ~= true),nobutton = true,white_list= {{id = TipsEumn.ButtonType.OutStore,show = true}},storageType = self.storageType}
        end
    elseif self.storageType == BackpackEumn.StorageType.Equipment then --装备

    elseif self.storageType == BackpackEumn.StorageType.HomeStore then --仓库
        self.maxPage = 5
        if isInStorage ~= nil and isInStorage == false then
            self.localPos = {x = -185, y = 44}
            self.extra = {inbag = false, noshowTag = (showSell ~= true),nobutton = true,white_list= {{id = TipsEumn.ButtonType.OutStore,show = true}},storageType = self.storageType}
        end
    end

    self.isHasDoubleClick = nil
    self.doubleClickFunc = doubleClickFunc

    if self.doubleClickFunc ~= nil then
        self.isHasDoubleClick = true
    end

    self.updateListener = function(list) self:Update(list) end
    self.updateStoreListener = function (list) self:Update(list) end
end

function BackpackGridPanel:__delete()
    if self.slotItem ~= nil then
        for _,slot in pairs(self.slotItem) do
            slot:DeleteMe()
        end
    end
    self.slotItem = nil
    if self.lockList ~= nil then
        for _,slot in pairs(self.lockList) do
            slot:DeleteMe()
        end
    end
    self.lockList = nil

    if self.tabbedPanel ~= nil then
        self.tabbedPanel:DeleteMe()
    end
    self.tabbedPanel = nil

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self.parent = nil
    self:AssetClearAll()
    self.slotItem = nil
    self.tempItem = nil
    self.layoutList = nil
    self.dataList = nil
    self.initTab = nil
    self.parentClass = nil
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.updateListener)
    EventMgr.Instance:RemoveListener(event_name.store_item_change, self.updateStoreListener)
    EventMgr.Instance:RemoveListener(event_name.home_store_item_change, self.updateStoreListener)
    EventMgr.Instance:RemoveListener(event_name.store_item_change, self.updateStoreListener)
end

function BackpackGridPanel:OnInitCompleted()
    if self.onInitCompletedCallback ~= nil then
        self.onInitCompletedCallback()
    end

    -- 非依赖资源，UI创建完就可以卸载
    self:ClearMainAsset()
end

function BackpackGridPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.backpack_grid))
    self.gameObject.name = "BackpackGrids"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3(self.localPos.x, self.localPos.y, 0)
    self.gameObject:SetActive(true)
    self.LockItem = self.transform:Find("LockItem").gameObject
    self.content = self.transform:Find("Container").gameObject.transform
    self.content.sizeDelta = Vector2(self.maxPage * 360 - 20, 324)

    self.tabbedPanel = TabbedPanel.New(self.gameObject, self.maxPage, 360)
    self.tabbedPanel.MoveEndEvent:Add(function(currentPage, direction) self:OnMoveEnd(currentPage, direction) end)

    self.layoutList = {}
    for i = 1, 5 do
        local page = self.content:GetChild(i-1).gameObject
        page.transform:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.slotbg, "SlotBg")
        page:SetActive(i<=self.maxPage)
        page.transform.anchoredPosition = Vector2((i - 1) * 360, 0)
        table.insert(self.layoutList, LuaGridLayout.New(page, self.setting))
    end

    self:FirstShow()

    if self.storageType == BackpackEumn.StorageType.Backpack then --背包
        EventMgr.Instance:AddListener(event_name.backpack_item_change, self.updateListener)
    elseif self.storageType == BackpackEumn.StorageType.Store then --仓库
        EventMgr.Instance:AddListener(event_name.store_item_change, self.updateStoreListener)
    elseif self.storageType == BackpackEumn.StorageType.Equipment then --装备

    elseif self.storageType == BackpackEumn.StorageType.HomeStore then --仓库
        EventMgr.Instance:AddListener(event_name.home_store_item_change, self.updateStoreListener)
    end
end

function BackpackGridPanel:OnMoveEnd(currentPage, direction)
    if self.parentClass ~= nil then
        self.parentClass:OnChangePage(currentPage)
    end
    if self.initTab[currentPage] == nil then
        self:InitPage(currentPage)
    end
    if currentPage < self.maxPage and self.initTab[currentPage + 1] == nil then
        self:InitPage(currentPage + 1)
    end

    MarketManager.Instance.onReloadGoldMarket:Fire()
end

function BackpackGridPanel:GetPageItem(page)
    self.dataList[page] = {}
    for _,item in pairs(BackpackManager.Instance:GetDataByStorageType(self.storageType)) do
        local a = math.floor((item.pos - 1) / 25) + 1
        if a == page then
            table.insert(self.dataList[page], item)
        end
    end
    return self.dataList[page]
end

function BackpackGridPanel:CheckItemPos(listTemp,index)
    for _,item in pairs(listTemp) do
        if item.pos == index then
            return item
        end
    end
    return nil
end

function BackpackGridPanel:InitPage(index)
    self.initTab[index] = 1
    local list = self:GetPageItem(index)
    local allListTemp = BackpackManager.Instance:GetDataByStorageType(self.storageType)
    local layout = self.layoutList[index]
    layout.panel:SetActive(true)
    table.sort(list, function(a,b) return a.pos < b.pos end)

    local maxPos = 1
    for j,cell in ipairs(list) do
        local slot = ItemSlot.New(nil,self.isHasDoubleClick)
        layout:UpdateCellIndex(slot.gameObject, cell.pos - (index - 1) * 25)
        slot:ShowBg(false)
        slot:SetAll(cell, self.extra)
        --确定下道具类型是否要显示品阶
        -- local tempData = DataMarketSilver.data_market_silver_item[cell.base_id]
        -- if tempData ~= nil and (tempData.type == 2 or tempData.type == 4) and cell.step ~= 0 then
        --     slot:SetStep(cell.step)
        -- end
        self.slotItem[cell.id] = slot
        slot.doubleClickFunc = self.doubleClickFunc
        slot:SetPos(cell.pos)

        if cell.pos > maxPos then
            maxPos = cell.pos
        end
    end



    -- self.lockList = {}
    if self.storageType == BackpackEumn.StorageType.Backpack and index <= 5 then --背包
        if index > 3 then
            local stari = 25 - (index * 25 - BackpackManager.Instance.volumeOfItem) + 1
            if stari   < 1 then
                stari = 1
            end
            -- print(stari.."==================================1122=")
            for i = stari, 25 do
                local slot = ItemSlot.New(nil,self.isHasDoubleClick)
                layout:UpdateCellIndex(slot.gameObject, i)
                slot:ShowBg(false)
                slot:SetLockCallback(function ()
                    local needData = DataItem.data_expand[BackpackManager.Instance.openedCount]
                    if needData == nil then
                        local data = NoticeConfirmData.New()
                        data.type = ConfirmData.Style.Normal
                        data.content = TI18N("通过扩展包裹增加的背包已经到达上限，可使用<color='#ffff00'>“背包扩充卷轴”</color>扩展背包<color='#ffff00'>（商城-充值返利中领取）</color>")
                        data.sureLabel = TI18N("前往查看")
                        data.cancelLabel = TI18N("取消")
                        data.sureCallback = function () WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3,2}) end
                        NoticeManager.Instance:ConfirmTips(data)
                    else
                        BackpackManager.Instance.mainModel:OpenExpand()
                    end
                end)
                slot:ShowLock(true)
                -- table.insert(self.lockList,slot)
                slot:SetPos(i + (index - 1) * 25)
                -- print(slot.pos)
                self.lockList[slot.pos] = slot
                -- -- print("--------"..BackpackManager.Instance.volumeOfItem)

                -- local lock = GameObject.Instantiate(self.LockItem)
                -- lock.transform:GetComponent(Button).onClick:AddListener(function()
                --     local needData = DataItem.data_expand[BackpackManager.Instance.openedCount]
                --     if needData == nil then
                --         local data = NoticeConfirmData.New()
                --         data.type = ConfirmData.Style.Normal
                --         data.content = "通过扩展包裹增加的背包已经到达上限，可使用<color='#ffff00'>“背包扩充卷轴”</color>扩展背包<color='#ffff00'>（商城-充值返利中领取）</color>"
                --         data.sureLabel = "前往查看"
                --         data.cancelLabel = "取消"
                --         data.sureCallback = function () WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3,2}) end
                --         NoticeManager.Instance:ConfirmTips(data)
                --     else
                --         BackpackManager.Instance.mainModel:OpenExpand()
                --     end
                -- end)
                -- layout:UpdateCellIndex(lock, i)
                -- table.insert(self.lockList, lock)
            end
        end
    elseif self.storageType == BackpackEumn.StorageType.Store then --仓库
        for i=maxPos + 1,25 * index do
            local slot = ItemSlot.New(nil,self.isHasDoubleClick)
            layout:UpdateCellIndex(slot.gameObject, i - (index - 1) * 25)
            slot:ShowBg(false)
            if i >= BackpackManager.Instance.volumeOfStorage + 1 then
                slot:SetLockCallback(function ()
                    --发协议
                    local gridPrice = DataItem.data_storegridopenprice[BackpackManager.Instance.volumeOfStorage + 5]
                    if gridPrice ~= nil then
                        local data = NoticeConfirmData.New()
                        data.type = ConfirmData.Style.Normal
                        data.content = string.format(TI18N("增加5格仓库，需要消耗{assets_1, %d,%d}"),gridPrice.coin[1][1],gridPrice.coin[1][2])
                        data.sureLabel = TI18N("确认")
                        data.cancelLabel = TI18N("取消")
                        data.sureCallback = function ()
                            BackpackManager.Instance:Send10324({num = 0})
                        end
                        NoticeManager.Instance:ConfirmTips(data)
                    end
                end)
                slot:ShowLock(true)
                -- table.insert(self.lockList,slot)
                slot:SetPos(i)
                self.lockList[slot.pos] = slot
            end
        end
    elseif self.storageType == BackpackEumn.StorageType.Equipment then --装备
    elseif self.storageType == BackpackEumn.StorageType.HomeStore then --家园仓库
        -- print("--------家园仓库-----1111111111111111111---"..BackpackManager.Instance.volumeOfHomeStorage)
        -- for i=#list + 1 + 25 * (index - 1),25 * index do
        --     local slot = ItemSlot.New(nil,self.isHasDoubleClick)
        --     layout:UpdateCellIndex(slot.gameObject, i - (index - 1) * 25)
        --     slot:ShowBg(false)
        --     if i >= BackpackManager.Instance.volumeOfHomeStorage + 1 then
        --         slot:SetLockCallback(function ()
        --             NoticeManager.Instance:FloatTipsByString(TI18N("升级储物室可获得更大空间"))
        --         end)
        --         slot:ShowLock(true)
        --         -- table.insert(self.lockList,slot)
        --         slot:SetPos(i)
        --         self.lockList[slot.pos] = slot
        --     end
        -- end
        local itemDataTemp = false
        for i= 1 + 25 * (index - 1),25 * index do
            itemDataTemp = self:CheckItemPos(allListTemp,i)
            if itemDataTemp ~= nil then
                --此格子有物品
            else
                local slot = ItemSlot.New(nil,self.isHasDoubleClick)
                layout:UpdateCellIndex(slot.gameObject, i - (index - 1) * 25)
                slot:ShowBg(false)
                if i >= BackpackManager.Instance.volumeOfHomeStorage + 1 then
                    slot:SetLockCallback(function ()
                        NoticeManager.Instance:FloatTipsByString(TI18N("升级储物室可获得更大空间"))
                    end)
                    slot:ShowLock(true)
                    -- table.insert(self.lockList,slot)
                    slot:SetPos(i)
                    self.lockList[slot.pos] = slot
                end
            end
        end
    end
end

function BackpackGridPanel:RefreshGrid(data)
    local listTemp = {}
    for k,v in pairs(self.lockList) do
        table.insert(listTemp,v)
    end
    table.sort( listTemp, function (a,b)
        return a.pos < b.pos
    end )
    for i,v in ipairs(listTemp) do
        if i <= data.newOpenGridCnt then
            v.gameObject:SetActive(false)
            table.insert(self.tempItem, v)
            self.lockList[v.pos] = nil
        end
    end
    listTemp = nil

    -- for i,v in ipairs(self.lockList) do
    --     if i <= data.newOpenGridCnt then
    --         v.gameObject:SetActive(false)
    --         table.insert(self.tempItem, v)
    --     end
    -- end
    -- for i=1,data.newOpenGridCnt do
    --     table.remove(self.lockList,1)
    -- end
end

function BackpackGridPanel:RefreshGrid_Del(data)
    -- local listTemp = {}
    -- for k,v in pairs(self.lockList) do
    --     table.insert(listTemp,v)
    -- end
    -- table.sort( listTemp, function (a,b)
    --     return a.pos > b.pos
    -- end )
    -- for i,v in ipairs(listTemp) do
    --     if i <= -data.newOpenGridCnt then
    --         v.gameObject:SetActive(false)
    --         table.insert(self.tempItem, v)
    --         self.lockList[v.pos] = nil
    --     end
    -- end
    -- listTemp = nil
end

function BackpackGridPanel:FirstShow()
    self:InitPage(1)
    self:InitPage(2)
    self:InitPage(3)
    self:InitPage(4)
end

function BackpackGridPanel:Update(list)
    if BackpackManager.Instance.needReloadGirdItem then
        self:ClearAll()
    end
    for _,data in ipairs(list) do
        local id = data.id
        local pos = data.pos
        local slot = self.slotItem[id]
        local itemData = BackpackManager.Instance:GetItemByIdAndStorageType(id,self.storageType)
        local page = math.floor((pos - 1) / 25) + 1
        -- 目标页都没创建，不管他
        if self.dataList[page] ~= nil then
            local layout = self.layoutList[page]
            if slot ~= nil then
                if itemData ~= nil then
                    -- 更新
                    slot:SetAll(itemData, self.extra)
                    slot.gameObject:SetActive(true)
                    layout:UpdateCellIndex(slot.gameObject, pos - (page - 1) * 25)
                else
                    -- 删除
                    self.slotItem[id] = nil
                    if self.storageType == BackpackEumn.StorageType.HomeStore and pos > BackpackManager.Instance.volumeOfHomeStorage  then
                        -- print(id.."--------家园仓库-----2222222222222---"..BackpackManager.Instance.volumeOfHomeStorage)
                        slot:SetAll(nil)
                        slot:ShowStep(false)
                        slot:SetLockCallback(function ()
                            NoticeManager.Instance:FloatTipsByString(TI18N("升级储物室可获得更大空间"))
                        end)
                        slot:ShowLock(true)
                        -- table.insert(self.lockList,slot)
                        self.lockList[slot.pos] = slot
                    else
                        slot.gameObject:SetActive(false)
                        table.insert(self.tempItem, slot)
                    end
                end
            else
                -- 新增
                if #self.tempItem > 0 then
                    slot = table.remove(self.tempItem, 1)
                else
                    slot = ItemSlot.New(nil,self.isHasDoubleClick)
                    table.insert(self.dataList[page], itemData)
                end
                layout:UpdateCellIndex(slot.gameObject, pos - (page - 1) * 25)
                slot:ShowBg(false)
                slot:SetAll(itemData, self.extra)
                slot.gameObject:SetActive(true)
                self.slotItem[id] = slot
            end
            if itemData ~= nil then
                slot.doubleClickFunc = self.doubleClickFunc
            end
        end
        --确定下道具类型是否要显示品阶
        -- if itemData ~= nil and slot ~= nil then
        --     local tempData = DataMarketSilver.data_market_silver_item[itemData.base_id]
        --     if tempData ~= nil and (tempData.type == 2 or tempData.type == 4) and itemData.step ~= 0 then
        --         slot:SetStep(itemData.step)
        --     end
        -- end
    end

    self:SetNew()
end

-- 重连或顶号时的处理
function BackpackGridPanel:ClearAll()
    print("背包格子全部清理")
    for id,slot in pairs(self.slotItem) do
        slot.gameObject:SetActive(false)
        table.insert(self.tempItem, slot)
    end

    self.slotItem = nil
    self.slotItem = {}
end

function BackpackGridPanel:UnlockNewSlot(changeCount)
    local listTemp = {}
    for k,v in pairs(self.lockList) do
        table.insert(listTemp,v)
    end
    table.sort( listTemp, function (a,b)
        return a.pos < b.pos
    end )


    for i,v in ipairs(listTemp) do
        if i <= changeCount then
            v:DeleteMe()
            self.lockList[v.pos] = nil
        end
    end

    -- for i = 1, changeCount do
    --     local slot = listTemp[i]
    --     local posTemp = slot.pos
    --     slot:DeleteMe()
    --     slot = nil
    --     self.lockList[posTemp] = nil
    --     -- local slotObj = self.lockList[slot.pos]
    --     -- slotObj.gameObject:SetActive(false)
    --     -- print(posTemp)
    -- end

    listTemp = nil

    -- for i = 1, changeCount do
    --     local lock = table.remove(self.lockList, 1)
    --     GameObject.DestroyImmediate(lock.gameObject)
    -- end

    if self.storageType == BackpackEumn.StorageType.Backpack then --背包
        if self.maxPage < 5 and math.ceil(BackpackManager.Instance.volumeOfItem / 25) > 3 then
            -- 开过了就显示5页
            self.maxPage = 5
            self.tabbedPanel:SetPageCount(self.maxPage)
            self.content.sizeDelta = Vector2(self.maxPage * 360 - 20, 324)
            self.parentClass:UpdateToggle()
        end
    end
end

function BackpackGridPanel:SetNew()
    if self.slotItem ~= nil then
        for _,v in pairs(self.slotItem) do
            if v.itemData ~= nil and v.itemData.id ~= nil then
                v:SetNew(BackpackManager.Instance.mainModel.newItemTab[v.itemData.id] ~= nil)
            end
        end
    end

    local newItemTab = BackpackManager.Instance.mainModel.newItemTab
    local idList = {}
    for id,v in pairs(newItemTab) do
        if v ~= nil then
            table.insert(idList, id)
        end
    end
    for _,id in ipairs(idList) do
        newItemTab[id] = nil
    end
end

