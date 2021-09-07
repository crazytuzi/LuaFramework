-- @author 黄耀聪
-- @date 2016年5月24日

SellGoldWindow = SellGoldWindow or BaseClass(BaseWindow)

function SellGoldWindow:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "SellGoldWindow"
    self.windowId = WindowConfig.WinID.sell_gold

    self.resList = {
        {file = AssetConfig.market_sellgold_window, type = AssetType.Main},
        {file = AssetConfig.slotbg, type = AssetType.Main},
    }

    self.pageList = {}
    self.toggleList = {}
    self.selectList = {}    -- 存放select对象的线性表
    self.chooseTab = {}     -- 用于购买的字典，背包id->购买数量
    self.posToId = {}       -- 字典，格子位置->背包id
    self.idToPos = {}       -- 字典，背包id->位置
    self.idToOrder = {}     -- 字典，背包id->顺序
    self.orderToId = {}     -- 字典，顺序->背包id
    self.currentId = nil    -- 当前选中的背包id
    self.maxSelectOrder = 0 -- 当前最大选中顺序
    self.sellSelectOrder = 1   -- 选中顺序
    self.sellSelectNum = 0

    self.buyNum = 0

    model:GetConditions()

    self.updateListener = function() self:Reload() end
    model:ReadHistoryGold()

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function SellGoldWindow:__delete()
    self.OnHideEvent:Fire()
    if self.pageList ~= nil then
        for _,page in pairs(self.pageList) do
            if page.items ~= nil then
                for _,item in pairs(page.items) do
                    if item.slot ~= nil then
                        item.slot:DeleteMe()
                    end
                end
            end
        end
        self.pageList = nil
    end
    -- if self.tabbedPanel ~= nil then
    --     self.tabbedPanel:DeleteMe()
    --     self.tabbedPanel = nil
    -- end
    if self.onepressExt ~= nil then
        self.onepressExt:DeleteMe()
        self.onepressExt = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.showSlot ~= nil then
        self.showSlot:DeleteMe()
        self.showSlot = nil
    end
    if self.showDescExt ~= nil then
        self.showDescExt:DeleteMe()
        self.showDescExt = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self.model:SetHistoryGold()
    self:AssetClearAll()
end

function SellGoldWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.market_sellgold_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    local main = t:Find("Main")
    self.scroll = main:Find("SellPanel/ScrollView"):GetComponent(ScrollRect)
    self.container = self.scroll.transform:Find("Container")
    self.container:Find("ItemPage").sizeDelta = Vector2(281.5, 273.7)
    self.pageCloner = self.container:Find("ItemPage").gameObject
    self.pageCloner:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.slotbg, "SlotBg")

    -- local toggleGroup = main:Find("SellPanel/ToggleGroup")
    -- for i=1,5 do
    --     self.toggleList[i] = toggleGroup:GetChild(i - 1):GetComponent(Toggle)
    -- end

    local infoPanel = main:Find("InfoPanel")
    self.showSlot = ItemSlot.New()
    NumberpadPanel.AddUIChild(infoPanel:Find("Item").gameObject, self.showSlot.gameObject)
    self.showNameText = infoPanel:Find("NameText"):GetComponent(Text)
    self.DescText2 = infoPanel:Find("DescText2"):GetComponent(Text)
    self.DescText2.text = TI18N("请点击左侧的物品，选择多个物品可批量出售")
    self.DescText2.transform.sizeDelta = Vector2(180.42, 38)
    self.DescText2.transform.anchoredPosition3D = Vector2(38.79002, -90)

    -- self.showDescExt = MsgItemExt.New(infoPanel:Find("DescText2"):GetComponent(Text), 270, 16, 18.17)
    self.addBtn = infoPanel:Find("NumObject/PlusButton"):GetComponent(Button)
    self.minusBtn = infoPanel:Find("NumObject/MinusButton"):GetComponent(Button)
    self.numpadBtn = infoPanel:Find("NumObject/NumBg"):GetComponent(Button)
    self.numText = infoPanel:Find("NumObject/NumBg/Value"):GetComponent(Text)
    self.singlePriceText = infoPanel:Find("SingleObject/NumBg/Value"):GetComponent(Text)
    self.AllText = infoPanel:Find("AllObject/NumBg/Value"):GetComponent(Text)
    self.totalPriceText = infoPanel:Find("RefineryAfterObject/NumBg/Value"):GetComponent(Text)

    -- self.tabbedPanel = TabbedPanel.New(self.scroll.gameObject, 0, 350, 0.6)
    -- self.tabbedPanel.MoveEndEvent:AddListener(function(index) self:MoveEnd(index) end)

    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 5, border = 8})

    -- self.singlePriceExt = MsgItemExt.New(infoPanel:Find("SingleRefineryDescTxt"):GetComponent(Text), 300, 17, 19)
    -- self.singlePriceExt.contentRect.anchoredPosition = Vector2(-132.6, 0)
    -- self.singlePriceExt:SetData(TI18N("出售当前可获{assets_2, 90003}:"))
    -- self.refineryAfterDescExt = MsgItemExt.New(infoPanel:Find("RefineryAfterDescTxt"):GetComponent(Text), 300, 17, 19)
    -- self.refineryAfterDescExt:SetData(TI18N("出售道具总价{assets_2, 90003}:"))
    -- self.refineryAfterDescExt.contentRect.anchoredPosition = Vector2(-132.5, -102.7)
    infoPanel:Find("SingleObject/Assets"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90003")
    infoPanel:Find("RefineryAfterObject/Assets"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90003")

    -- for i,v in ipairs(self.toggleList) do
    --     v.gameObject:SetActive(false)
    -- end

    -- infoPanel:Find("OnePressButton/Image").gameObject:SetActive(false)
    self.onepressExt = MsgItemExt.New(infoPanel:Find("OnePressButton/Text"):GetComponent(Text), 110, 17, 19)
    self.onepressExt:SetData(TI18N("一键出售"))
    infoPanel:Find("OnePressButton"):GetComponent(Button).onClick:AddListener(function() self:SellAll() end)
    local size = self.onepressExt.contentRect.sizeDelta
    self.onepressExt.contentRect.anchoredPosition = Vector2(-size.x / 2, size.y / 2)

    infoPanel:Find("PutButton"):GetComponent(Button).onClick:AddListener(function() self:Sell() end)
    self.putButtonImage = infoPanel:Find("PutButton"):GetComponent(Image)
    self.putButtonText = infoPanel:Find("PutButton/Text"):GetComponent(Text)
    self.putButtonText.text = TI18N("出 售")

    self.addBtn.onClick:AddListener(function() self:AddOrMinus(true) end)
    self.minusBtn.onClick:AddListener(function() self:AddOrMinus(false) end)
    self.numpadBtn.onClick:AddListener(function() self:OnNumberpad() end)

    main:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    main:Find("Title/Text"):GetComponent(Text).text = TI18N("出售道具")
    main:Find("SellPanel/Image/Text"):GetComponent(Text).text = TI18N("可出售道具")
    infoPanel:Find("Setting"):GetComponent(Button).onClick:AddListener(function() self.model:OpenSellgoldSetting(self.gameObject) end)
end

function SellGoldWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SellGoldWindow:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.updateListener)

    self:ShowDetail()
    self:Reload((self.openArgs or {})[1])
end

function SellGoldWindow:OnHide()
    self:RemoveListeners()
end

function SellGoldWindow:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.updateListener)
end

function SellGoldWindow:Reload(id_backpack)
    local itemDic = BaseUtils.copytab(BackpackManager.Instance.itemDic)
    
    self.datalist = {}
    local tab = {}
    local tmplist = {}

    for _,v in pairs(itemDic) do
        if v.bind == BackpackEumn.BindType.unbind then
            for _,data in ipairs(v.tips_type) do
                if data.tips == TipsEumn.ButtonType.Sell then
                    if data.val ~= nil and data.val ~= "[]" then
                        local icon = StringHelper.MatchBetweenSymbols(data.val, "%[", "%]")[1]
                        if icon == "1" then
                            table.insert(tmplist, {id = v.id, pos = v.pos})
                            break
                        end
                    end
                end
            end
        end
    end

    table.sort(tmplist,function(a,b) return a.pos < b.pos end)
    for i,v in ipairs(tmplist) do
        self.datalist[i] = v.id 
    end

    local pageIndex = 0
    local itemIndex = 1
    local page = nil
    local item = nil
    for i,id in ipairs(self.datalist) do
        pageIndex = math.ceil(i / 16)
        itemIndex = (i - 1) % 16 + 1
        page = self.pageList[pageIndex]
        if page == nil then     -- 创建新空白页
            page = {items = {}, count = 0}
            page.gameObject = GameObject.Instantiate(self.pageCloner)
            self.layout:AddCell(page.gameObject)
            page.gameObject.name = tostring(pageIndex)
            page.transform = page.gameObject.transform
            self.pageList[pageIndex] = page
        end
        page.gameObject:SetActive(true)
        -- self.toggleList[pageIndex].gameObject:SetActive(true)
        page.count = itemIndex
        item = page.items[itemIndex]
        if item == nil then
            item = {}
            item.transform = page.transform:GetChild(itemIndex - 1)
            item.gameObject = item.transform.gameObject
            item.select = item.transform:Find("Select").gameObject
            item.slot = ItemSlot.New()
            NumberpadPanel.AddUIChild(item.gameObject, item.slot.gameObject)
            item.slot.transform:SetAsFirstSibling()
            page.items[itemIndex] = item
            item.select = item.transform:Find("Select").gameObject
            local j = i
            item.slot.clickSelfFunc = function(data) self:ClickSlot(data, j) end
            self.selectList[j] = item.select
            item.slot.noTips = true
            local slot = item.slot
            slot.numTxt.transform:SetParent(slot.numBgRect.transform)
            slot.numTxt.transform.anchorMax = Vector2(0.5, 0.5)
            slot.numTxt.transform.anchorMin = Vector2(0.5, 0.5)
            slot.numTxt.transform.pivot = Vector2(0.5, 0.5)
            slot.numTxt.transform.anchoredPosition = Vector2.zero
            item.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickSlot(slot.itemData, j) end)
        end
        item.transform:Find("Slot").gameObject:SetActive(false)
        item.gameObject:SetActive(true)

        -- if id_backpack ~= nil and itemDic[id_backpack] ~= nil  then
        --     if id_backpack == id then
        --         self.currentData = itemDic[id_backpack]
        --         self.buyNum = self.currentData.quantity
        --         item.select:SetActive(true)
        --         self.chooseTab[id_backpack] = self.buyNum
        --         self:ShowDetail()
        --     end
        -- end
        item.slot:SetAll(itemDic[id], {inbag = true, nobutton = true})

        if self.chooseTab[id] ~= nil and self.chooseTab[id] ~= 0 then
            self:SetSlotNum(item.slot, itemDic[id].quantity, self.chooseTab[id])
        else
            self:SetSlotNum(item.slot, itemDic[id].quantity, itemDic[id].quantity)
        end
        -- item.slot.noTips = true

        self.posToId[i] = id
        self.idToPos[id] = i
    end

    if pageIndex == 0 then
        pageIndex = 1
        itemIndex = 0
        if self.pageList[1] == nil then
            self.pageList[1] = {items = {}, count = 0}
        end
        page = self.pageList[1]
        page.gameObject = GameObject.Instantiate(self.pageCloner)
        self.layout:AddCell(page.gameObject)
        page.gameObject.name = tostring(pageIndex)
        page.transform = page.gameObject.transform
        self.pageList[pageIndex] = page
        -- self.toggleList[1].gameObject:SetActive(true)
        -- self.toggleList[1].isOn = true
    end

    for i=pageIndex + 1,#self.pageList do
        self.pageList[i].gameObject:SetActive(false)
        -- self.toggleList[i].gameObject:SetActive(false)
    end
    if page ~= nil then
        for i=itemIndex + 1,#page.items do
            -- BaseUtils.dump(page.items)
            page.items[i].slot.gameObject:SetActive(false)
            page.items[i].transform:Find("Slot").gameObject:SetActive(true)
        end
    end
    self.container.sizeDelta = Vector2(281.5, 278.2*math.ceil(#self.datalist / 16)+5)
    -- self.tabbedPanel:SetPageCount(pageIndex)
    self.pageCloner:SetActive(false)

    -- if self.tabbedPanel.currentPage < 1 then
    --     self:MoveEnd(1)
    -- elseif self.tabbedPanel.currentPage > pageIndex then
    --     self:MoveEnd(pageIndex)
    -- else
    --     self:MoveEnd(self.tabbedPanel.currentPage)
    -- end

    if id_backpack ~= nil then
        self:ClickSlot(itemDic[id_backpack], self.idToPos[id_backpack])
    end
end

function SellGoldWindow:MoveEnd(index)
    -- for i,v in ipairs(self.toggleList) do
    --     v.isOn = (i == index)
    -- end
end

function SellGoldWindow:ClickSlot(itemData, i)
    if self.datalist[i] == nil or itemData == nil then
        return
    end
    local id = itemData.id
    local world_lev = RoleManager.Instance.world_lev
    if DataMarketGold.data_market_gold_item[itemData.base_id] ~= nil and DataMarketGold.data_market_gold_item[itemData.base_id].world_lev > world_lev then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("世界等级不足%s级，{item_2, %s, 0, 1}无法出售"), DataMarketGold.data_market_gold_item[itemData.base_id].world_lev, itemData.base_id))
        return
    end

    if BackpackManager.Instance:GetPreciousItem(itemData.base_id) then 
            local confirm_dat = {
                titleTop = TI18N("贵重物品")
                , title = string.format( "%s%s", ColorHelper.color_item_name(itemData.quality ,string.format("[%s]", itemData.name)), TI18N("十分珍贵，<color='#df3435'>出售后无法找回</color>"))
                , password = TI18N(tostring(math.random(100, 999)))
                , confirm_str = TI18N("出 售")
                , cancel_str = TI18N("取 消")
                , confirm_callback = function() MarketManager.Instance:send12402(itemData.id, 1) end
            }
            TipsManager.Instance.model:OpentwiceConfirmPanel(confirm_dat)
            return
    end

    -- 确定当前选中的item的选中顺序
    if self.lastSelectId == nil then      -- 首次选中
        self.selectList[i]:SetActive(true)
        self.lastSelectId = id
        self.idToOrder[id] = self.sellSelectOrder
        self.sellSelectOrder = self.sellSelectOrder + 1

        self.sellSelectNum = 1

        self.currentData = itemData
        self.buyNum = itemData.quantity
        self.chooseTab[id] = itemData.quantity
    else
        if self.lastSelectId == 0 then
            self.selectList[i]:SetActive(true)
            self.lastSelectId = id
            self.idToOrder[id] = self.sellSelectOrder
            self.sellSelectOrder = self.sellSelectOrder + 1
            self.sellSelectNum = self.sellSelectNum + 1
            self.currentData = itemData
            self.buyNum = itemData.quantity
            self.chooseTab[id] = itemData.quantity
        elseif self.idToOrder[id] == nil then      -- 点击未选中的物品
            self.selectList[i]:SetActive(true)
            self.idToOrder[id] = self.sellSelectOrder
            self.sellSelectOrder = self.sellSelectOrder + 1
            self.lastSelectId = id
            self.sellSelectNum = self.sellSelectNum + 1
            self.currentData = itemData
            self.buyNum = itemData.quantity
            self.chooseTab[id] = itemData.quantity
        else                                        -- 点击已选中的物品，即取消选择
            self.selectList[i]:SetActive(false)
            self.idToOrder[id] = nil
            local lastSelectId = 0
            for k,v in pairs(self.idToOrder) do
                if v ~= nil then
                    if self.idToOrder[lastSelectId] == nil or self.idToOrder[k] > self.idToOrder[lastSelectId] then
                        lastSelectId = k
                    end
                end
            end
            self.lastSelectId = lastSelectId
            self.sellSelectNum = self.sellSelectNum - 1
            self.currentData = BackpackManager.Instance.itemDic[lastSelectId]
            self.buyNum = (self.currentData or {}).quantity or 0
            self.chooseTab[id] = 0
        end
    end


    local index = self.idToPos[id]
    local pageIndex = math.ceil(index / 16)
    local itemIndex = (index - 1) % 16 + 1
    if self.pageList[pageIndex].items[itemIndex] ~= nil and id ~= nil then
        self:SetSlotNum(self.pageList[pageIndex].items[itemIndex].slot, BackpackManager.Instance.itemDic[id].quantity, BackpackManager.Instance.itemDic[id].quantity)
    end
    self:ShowDetail()
end

function SellGoldWindow:ShowDetail()
    local data = nil
    if self.currentData ~= nil then
        data = self.currentData
    end
    if data == nil then
        self.showSlot:Default()
        self.showSlot.noTips = true
        self.showNameText.text = ""
        -- self.showDescExt:SetData(TI18N("请点击左侧的物品，选择多个物品可批量出售"))
        self.DescText2.gameObject:SetActive(true)
        self.singlePriceText.text = "0"
        self.numText.text = "0"
        self.buyNum = 0
    else
        local goldData = DataMarketGold.data_market_gold_item[data.base_id]
        self.singlePriceText.text = tostring(BackpackEumn.GetSellPrice(data))
        self.numText.text = tostring(data.quantity)
        self.showSlot:SetAll(data, {inbag = true, nobutton = true})
        self.showSlot.noTips = false
        self.showNameText.text = data.name
        self.DescText2.gameObject:SetActive(false)
        -- self.showDescExt:SetData(data.desc)
        self.buyNum = data.quantity
    end

    local num1 = 0
    for id,num in pairs(self.chooseTab) do
        if num ~= nil and num ~= 0 then
            num1 = num1 + 1
        end
    end
    if num1 == 0 then
        self.putButtonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.putButtonText.color = ColorHelper.DefaultButton1
    else
        self.putButtonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        self.putButtonText.color = ColorHelper.DefaultButton2
    end

    self:GroupTotalPrice()
end

function SellGoldWindow:AddOrMinus(bool)
    if self.currentData == nil then
        return
    end

    if bool == true then    -- 加
        if self.buyNum < self.currentData.quantity then
            self.buyNum = self.buyNum + 1
        else
            NoticeManager.Instance:FloatTipsByString("不能超过物品数量")
        end
    else                    -- 减
        if self.buyNum > 1 then
            self.buyNum = self.buyNum - 1
        else
            NoticeManager.Instance:FloatTipsByString("最少出售一个")
        end
    end

    self.numText.text = tostring(self.buyNum)
    self.chooseTab[self.currentData.id] = self.buyNum
    self:GroupTotalPrice()

    local index = self.idToPos[self.currentData.id]
    local pageIndex = math.ceil(index / 16)
    local itemIndex = (index - 1) % 16 + 1
    self:SetSlotNum(self.pageList[pageIndex].items[itemIndex].slot, BackpackManager.Instance.itemDic[self.currentData.id].quantity, self.buyNum)
end

function SellGoldWindow:SellAll()
    local itemDic = BackpackManager.Instance.itemDic
    local model = self.model
    local sell_nameList = {}
    local world_lev = RoleManager.Instance.world_lev
    local defaultselect = BaseUtils.copytab(self.chooseTab)

    local absoluteNotTab = {}

    if model.goldHistory.option1 == nil or model.goldHistory.option1 == 1 then
        local equip_min_level = 1000
        for _,v in pairs(BackpackManager.Instance.equipDic) do
            -- BaseUtils.dump(v)
            if v ~= nil and v.lev < equip_min_level then
                equip_min_level = v.lev
            end
        end
        local wing_lev = WingsManager.Instance.grade

        local classes = RoleManager.Instance.RoleData.classes
        local sex = RoleManager.Instance.RoleData.sex

        if self.datalist ~= nil then
            for _,id in ipairs(self.datalist) do
                if self.chooseTab[id] == 0 or self.chooseTab[id] == nil then
                    local itemData = itemDic[id]
                    local base_id = itemData.base_id
                    local conditionList = (model.conditionTab[base_id] or {}).condition
                                        -- BaseUtils.dump(itemData, "大局数据")
                    if conditionList ~= nil then
                        for _,tab in ipairs(conditionList) do
                            if (tab[3] == 0 or tab[3] == classes) and (tab[4] == 2 or tab[4] == sex) then
                                if tab[1] == MarketEumn.ConditionType.EquipMinLevel then
                                    if equip_min_level >= tab[2] then    -- 我的装备等级>物品装备等级
                                        self.chooseTab[id] = itemData.quantity
                                    else
                                        break
                                    end
                                elseif tab[1] == MarketEumn.ConditionType.WingLevel then
                                    if wing_lev >= tab[2] then           -- 我的翅膀等级>物品翅膀等级
                                        self.chooseTab[id] = itemData.quantity
                                    else
                                        break
                                    end
                                elseif tab[1] == MarketEumn.ConditionType.Absolute then
                                    absoluteNotTab[id] = 1
                                    self.chooseTab[id] = 0
                                    break
                                end
                            else
                                self.chooseTab[id] = itemData.quantity
                            end
                        end
                    end
                end
            end
        end
    end
    if model.goldHistory.option2 == nil or model.goldHistory.option2 == 1 then
        local tab = {}
        for _,base_id in ipairs(model.goldHistory.list or {}) do
            tab[base_id] = 1
        end

        for _,v in pairs(itemDic) do
            if v.bind == BackpackEumn.BindType.unbind then
                for _,data in ipairs(v.tips_type) do
                    if data.tips == TipsEumn.ButtonType.Sell then
                        if data.val ~= nil and data.val ~= "[]" then
                            local icon = StringHelper.MatchBetweenSymbols(data.val, "%[", "%]")[1]
                            if icon == "1" then
                                if tab[v.base_id] == 1 and (self.chooseTab[v.id] == nil or self.chooseTab[v.id] == 0) and absoluteNotTab[v.id] == nil then
                                    self.chooseTab[v.id] = v.quantity
                                end
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    -- 检查不能一键出售的物品
    local tab1 = {}
    for id,num in pairs(self.chooseTab) do
        if num ~= 0 and num ~= nil then
            if model.noQuickSellTab[itemDic[id].base_id] ~= nil
                or (DataMarketGold.data_market_gold_hide[itemDic[id].base_id] ~= nil                -- 隐藏商品
                or (DataMarketGold.data_market_gold_exchange[itemDic[id].base_id] ~= nil)           -- 转换道具
                or DataMarketGold.data_market_gold_item[itemDic[id].base_id].world_lev > world_lev) -- 世界等级
                then
                table.insert(tab1, id)
            end
        end
    end
    for _,id in ipairs(tab1) do
        self.chooseTab[id] = nil
    end

    local list = {}
    for id,num in pairs(self.chooseTab) do
        if num ~= 0 and num ~= nil then
            local baseData = DataItem.data_get[itemDic[id].base_id]
            table.insert(list, {
                    quality = baseData.quality,
                    str1 = ColorHelper.color_item_name(baseData.quality , string.format("%sx%s", baseData.name, num)),
                    str3 = tostring(num * BackpackEumn.GetSellPrice(itemDic[id]))
                })
        end
    end

    table.sort(list, function(a,b) return a.quality > b.quality end)

    -- 统计部分，一定要放在处理chooseTab之后

    local num1 = 0
    local allprice = 0

    for id,num in pairs(self.chooseTab) do
        if num ~= nil and num ~= 0 then
            num1 = num1 + 1
            local backpackdata = itemDic[id]
            allprice = allprice + BackpackEumn.GetSellPrice(itemDic[id]) * num
            if sell_nameList[backpackdata.base_id] == nil then
                sell_nameList[backpackdata.base_id] = {name = DataItem.data_get[backpackdata.base_id].name, lev = backpackdata.quality, num = backpackdata.quantity}
            else
                sell_nameList[backpackdata.base_id].num = sell_nameList[backpackdata.base_id].num + backpackdata.quantity
            end
        end
    end
    if num1 == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("没有符合一键出售的道具"))
        return
    end
    local nameList = ""
    local first = true
    for id,v in pairs(sell_nameList) do
        if first then
            nameList = ColorHelper.color_item_name(v.lev, v.name)
            first = false
        else
            nameList = string.format("%s、%s", nameList, ColorHelper.color_item_name(v.lev, v.name))
        end
    end

    -- BaseUtils.dump(self.chooseTab, "self.chooseTab")

    self.model:OpenConfirm({
            title = string.format(TI18N("一键出售将获得<color='#ffff00'>%s</color>{assets_2, 90003}"), allprice),
            items = list,
            extra = TI18N("点击按钮旁边的“齿轮”，可设置一键出售的道具"),
            sureCallback = function() self:Sell() end,
            cancelCallback = function() self.chooseTab = defaultselect end,
        })
end

function SellGoldWindow:Sell()
    local model = self.model
    local tab = {}
    for i,v in ipairs(model.goldHistory.list or {}) do
        tab[v] = 1
    end

    local itemDic = BackpackManager.Instance.itemDic
    if self.chooseTab ~= nil then
        local hadSellList = {}
        local num1 = 0
        for id,num in pairs(self.chooseTab) do
            if num ~= 0 and num ~= nil then
                num1 = num1 + 1
                tab[itemDic[id].base_id] = 1
                table.insert(hadSellList, id)
                MarketManager.Instance:send12402(id, num)
            end
        end
        if num1 == 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("请选择要出售的道具"))
        else
            -- SoundManager.Instance:Play(250)
        end
        for _,id in ipairs(hadSellList) do
            self.chooseTab[id] = nil
        end
        for _,v in ipairs(self.selectList) do
            if v ~= nil then
                v:SetActive(false)
            end
        end
    end
    model.goldHistory.list = {}
    for id,_ in pairs(tab) do
        table.insert(model.goldHistory.list, id)
    end
    if self.currentData ~= nil then
        self:ClickSlot(itemDic[self.currentData.id], self.idToPos[self.currentData.id])
    end
    -- self:ShowDetail()
end

function SellGoldWindow:OnNumberpad()
    if self.currentData == nil then
        return
    end

    local numberpadConfig = {
        gameObject = self.numpadBtn.gameObject,
        textObject = self.numText,
        max_result = self.currentData.quantity,
        min_result = 1,
        max_by_asset = self.currentData.quantity,
        -- show_num = false,
        callback = function(num)
                if num == 0 then
                    num = 1
                end
                self.buyNum = num
                self.chooseTab[self.currentData.id] = num
                self.numText.text = tostring(self.buyNum)
                self:GroupTotalPrice()
                local index = self.idToPos[self.currentData.id]
                local pageIndex = math.ceil(index / 16)
                local itemIndex = (index - 1) % 16 + 1
                self:SetSlotNum(self.pageList[pageIndex].items[itemIndex].slot, BackpackManager.Instance.itemDic[self.currentData.id].quantity, self.buyNum)
            end,
    }
    NumberpadManager.Instance:set_data(numberpadConfig)
end

function SellGoldWindow:GroupTotalPrice()
    local sum = 0
    local sumnum = 0
    local itemDic = BackpackManager.Instance.itemDic
    for id,num in pairs(self.chooseTab) do
        if num ~= 0 and num ~= nil then
            sum = sum + BackpackEumn.GetSellPrice(itemDic[id]) * num
            sumnum = sumnum + num
        end
    end
    self.totalPriceText.text = string.format("<color='#ffff00'>%s</color>", tostring(sum))
    self.AllText.text = string.format("<color='#ffff00'>%s</color>", tostring(sumnum))
end

function SellGoldWindow:SetSlotNum(slot, num, need)
    slot.numTxt.gameObject:SetActive(true)
    slot.numBgRect.gameObject:SetActive(true)
    slot.numTxt.text = string.format("%s/%s", tostring(need), tostring(num))
    slot.numBgRect.sizeDelta = Vector2(math.ceil(slot.numTxt.preferredWidth + 8), 22)
end
