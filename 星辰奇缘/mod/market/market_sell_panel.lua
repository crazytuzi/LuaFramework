MarketSellPanel = MarketSellPanel or BaseClass(BasePanel)

function MarketSellPanel:__init(parent)
    self.parent = parent
    local model = parent.model

    self.resList = {
        {file = AssetConfig.market_sell_panel, type = AssetType.Main}
    }

    -- parent.subPanel[3] = self
    model.sellCellNum = nil         -- 已打开cell的数目
    self.cellObjList = {}

    self.tempInfo = {["base_id"] = nil, ["cell_id"] = nil, ["precent"] = nil, ["num"] = nil, ["numInBackpack"] = nil}
    self.slotList = {}
    self.extra = {inbag = false, nobutton = true}
    self.slot = nil

    self.openListener = function() self:OnOpen() end
    self.OnOpenEvent:Add(self.openListener)
end

function MarketSellPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.market_sell_panel))
    self.gameObject:SetActive(true)
    self.gameObject.name = "SellMarket"

    local t = self.gameObject.transform
    local model = self.parent.model

    t:SetParent(self.parent.gameObject.transform:Find("Main"))
    t.localPosition = Vector3(0, 0, 0)
    t.localScale = Vector3(1, 1, 1)

    t:Find("DescText"):GetComponent(Text).text = TI18N("注：<color='#e8faff'>24小时</color>未卖出会返回")
    self.buyPanel = t:Find("BuyPanel")
    self.itemTemplate = self.buyPanel:Find("ItemObject").gameObject
    self.itemTemplate:SetActive(false)
    self.sellWindow = t:Find("SellWindow").gameObject
    self.sellWindowMain = self.sellWindow.transform:Find("Main")
    self.sellWindowMain:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function () self.sellWindow:SetActive(false) end)
    self.sellWindow.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function () self.sellWindow:SetActive(false) end)

    local infoPanel = self.sellWindow.transform:Find("Main/InfoPanel")
    self.nameText = infoPanel:Find("Item/ItemText"):GetComponent(Text)

    -- 下架
    self.cancelBtn = infoPanel:Find("CancelButton"):GetComponent(Button)
    self.cancelBtn.onClick:AddListener(function ()
        MarketManager.Instance:send12406(self.tempInfo.cell_id)
        self.sellWindow:SetActive(false)
    end)

    -- 单个重新上架
    self.putButton = infoPanel:Find("PutButton"):GetComponent(Button)
    self.putButton.onClick:AddListener(function ()
        MarketManager.Instance:send12413(self.tempInfo.cell_id, self.tempInfo.precent, self.tempInfo.num)
        -- MarketManager.Instance:send12407()
        self.sellWindow:SetActive(false)
    end)


    local numObj = infoPanel:Find("NumObject")
    self.numText = numObj:Find("NumBg/Value"):GetComponent(Text)
    numObj:Find("PlusButton"):GetComponent(Button).onClick:AddListener(function ()
        local model = self.parent.model
        local infodata = model.sellCellItem[self.tempInfo.cell_id]
        local num = self.tempInfo.num
        if num < infodata.num and num < 5 then
            num = num + 1
        else
            if num == 5 then
                NoticeManager.Instance:FloatTipsByString(TI18N("一个摊位最多上架5个物品"))
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("没有更多了"))
            end
        end
        self.tempInfo.num = num
        self.numText.text = tostring(num)
        self.totalText.text = tostring(tonumber(self.priceText.text) * num)
        self.totalText.text = tostring(self.tempInfo.num * tonumber(self.priceText.text))
    end)
    numObj:Find("MinusButton"):GetComponent(Button).onClick:AddListener(function ( ... )
        local model = self.parent.model
        local num = self.tempInfo.num
        if num > 1 then
            num = num - 1.
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("最少上架一个物品"))
        end
        self.tempInfo.num = num
        self.numText.text = tostring(num)
        self.totalText.text = tostring(tonumber(self.priceText.text) * num)
        self.totalText.text = tostring(self.tempInfo.num * tonumber(self.priceText.text))
    end)

    local priceObj = infoPanel:Find("PriceObject")
    self.priceText = priceObj:Find("PriceBg/Value"):GetComponent(Text)
    self.currencyImage = priceObj:Find("CurrencyImage"):GetComponent(Image)
    priceObj:Find("PlusButton"):GetComponent(Button).onClick:AddListener(function ()
        local precent = self.tempInfo.precent
        local model = self.parent.model
        local infodata = DataMarketSilver.data_market_silver_item[self.tempInfo.base_id] or {max_price = 0, def_price = 0}
        local serverPrice = model.standardPriceServerByBaseId[self.tempInfo.base_id]
        if serverPrice == nil then
            serverPrice = DataMarketSilver.data_market_silver_item[self.tempInfo.base_id].def_price
        end
        if serverPrice == nil then
            if self.tempInfo.base_id ~= nil then
                MarketManager.Instance:send12408(self.tempInfo.base_id, 1)
            end
            return
        end
        local basedata = DataItem.data_get[self.tempInfo.base_id]
        if precent < 130 then
            if math.floor(serverPrice * (precent + 10) / 100) <= infodata.max_price then
                precent = precent + 10
                if precent > 130 then
                    precent = 130
                end
            elseif math.floor(serverPrice * (precent + 1) / 100) < infodata.max_price then
                precent = math.floor(infodata.max_price / serverPrice * 100)
            else
                NoticeManager.Instance:FloatTipsByString(ColorHelper.color_item_name(basedata.quality, basedata.name)..TI18N("不能再贵了{face_1,31}"))
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("不能再贵了"))
        end
        self.tempInfo.precent = precent

        if serverPrice ~= nil then
            self.priceText.text = tostring(math.floor(serverPrice * precent / 100))
        else
            self.priceText.text = tostring(math.floor(infodata.def_price * precent / 100))
        end
        self:UpdateDiscount()
        self.totalText.text = tostring(self.tempInfo.num * tonumber(self.priceText.text))
    end)
    priceObj:Find("MinusButton"):GetComponent(Button).onClick:AddListener(function ()
        local precent = self.tempInfo.precent
        local model = self.parent.model
        local base_id = self.tempInfo.base_id
        local infodata = DataMarketSilver.data_market_silver_item[base_id] or {min_price = 0, def_price = 0}
        local basedata = DataItem.data_get[base_id]
        local serverPrice = model.standardPriceServerByBaseId[self.tempInfo.base_id]
        if serverPrice == nil then
            serverPrice = DataMarketSilver.data_market_silver_item[self.tempInfo.base_id].def_price
        end
        if precent > 50 then
            if math.floor(serverPrice * (precent - 10) / 100) >= infodata.min_price then
                precent = precent - 10
                if precent % 10 ~= 0 then
                    precent = 120
                end
            else
                NoticeManager.Instance:FloatTipsByString(ColorHelper.color_item_name(basedata.quality, basedata.name)..TI18N("不能再便宜了{face_1,21}"))
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("不能再便宜了"))
        end
        self.tempInfo.precent = precent
        if serverPrice ~= nil then
            self.priceText.text = tostring(math.floor(serverPrice * precent / 100))
        else
            self.priceText.text = tostring(math.floor(infodata.def_price * precent / 100))
        end
        self:UpdateDiscount()
        self.totalText.text = tostring(self.tempInfo.num * tonumber(self.priceText.text))
    end)

    self.totalText = infoPanel:Find("TotalObject/TotalBg/Value"):GetComponent(Text)
    self.totalCurrencyImage = infoPanel:Find("TotalObject/IconImage"):GetComponent(Image)

    self.discountText = infoPanel:Find("I18N_Text"):GetComponent(Text)

    self.slot = ItemSlot.New()
    local sellWindowItem = self.sellWindow.transform:Find("Main/InfoPanel/Item")
    NumberpadPanel.AddUIChild(sellWindowItem, self.slot.gameObject)
    self.itemNameText = sellWindowItem:Find("ItemText"):GetComponent(Text).text

    self.cashImage = t:Find("CashButton"):GetComponent(Image)
    t:Find("CashButton"):GetComponent(Button).onClick:AddListener(function ()
        local num = 0
        if model.sellCellItem ~= nil then
            for k,v in pairs(model.sellCellItem) do
                if v ~= nil and (v.status == 1 or v.status == 5) then
                    num = num + 1
                    break
                end
            end
        end
        if num == 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("没有摊位可以提现"))
            return
        end
        MarketManager.Instance:send12414(2)
        SoundManager.Instance:Play(219)
        if self.cashEffect ~= nil then
            self.cashEffect:DeleteMe()
        end
        self.cashEffect = BibleRewardPanel.ShowEffect(20111, MarketManager.Instance.model.marketWin.gameObject.transform, Vector3.one, Vector3(480, -270, 0), 4000)
    end)
    self.sellImage = t:Find("SellButton"):GetComponent(Image)
    t:Find("SellButton"):GetComponent(Button).onClick:AddListener(function ()
        MarketManager.Instance:send12414(1)
    end)
end

function MarketSellPanel:__delete()
    for k,v in pairs(self.slotList) do
        v:DeleteMe()
    end
    self.slotList = nil
    self.OnOpenEvent:Remove(self.openListener)

    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end
    if self.cashEffect  ~= nil then
        self.cashEffect:DeleteMe()
        self.cashEffect = nil
    end
    if self.sellWin ~= nil then
        self.sellWin:DeleteMe()
        self.sellWin = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self.parent = nil
    self:AssetClearAll()
end

function MarketSellPanel:UpdateCells()
    if self.cellObjList == nil then
        self.cellObjList = {}
    end

    local model = self.parent.model
    MarketManager.Instance.redPointDic[3][1] = false

    for i=1,model.sellCellNum+1 do
        if i < 16 then
            self.cellObjList[i] = self:SetCell(model.sellCellItem[i], self.cellObjList[i], i)
        end
    end

    MarketManager.Instance.onUpdateRed:Fire()

    if model.currentSub == 2 then
        local maxSelectableNum = 0
        -- BaseUtils.dump(model.sellCellItem)
        for i=1, #model.sellCellItem do
            if model.sellCellItem[i].item_base_id == nil then
                maxSelectableNum = maxSelectableNum + 1
            end
        end
        for i,v in ipairs(model.sellCellItem) do
            if v.item_base_id == nil then
                model.sellCellCurrent = i
                break
            end
        end
        if maxSelectableNum > 0 then
            if self.sellWin == nil then
                self.sellWin = MarketSellSelectPanel.New(self)
            end
            self.sellWin:Show()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("当前摊位已满，无法再上架其他物品"))
        end
        model.currentSub = 1
    end

    local canCash = false
    local canReput = false
    local currentTime = BaseUtils.BASE_TIME

    for _,info in ipairs(model.sellCellItem) do
        if info.status ~= nil then
            canCash = canCash or (info.status == 5 or info.status == 1)
            canReput = canReput or (info.status == 2 or info.expiry <= currentTime or info.status == 6)
        end
    end

    if canCash then
        self.cashImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    else
        self.cashImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    end

    if canReput then
        self.sellImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    else
        self.sellImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    end
end

function MarketSellPanel:SetCell(data, obj, i)
    if obj == nil then
        obj = GameObject.Instantiate(self.itemTemplate)
        obj.transform:SetParent(self.buyPanel)
        obj.transform.localScale = Vector3.one
        obj:GetComponent(Button).onClick:AddListener(function () self:ClickItem(obj, i) end)
        local ans = i % 3
        local rect = obj:GetComponent(RectTransform)
        if ans == 1 then
            rect.anchoredPosition = Vector3(11.6, -14.6 - (i - 1) * 73 / 3, 0)
        elseif ans == 2 then
            rect.anchoredPosition = Vector3(256, -14.6 - (i - 2) * 73 / 3, 0)
        elseif ans == 0 then
            rect.anchoredPosition = Vector3(499.4, -14.6 - (i - 3) * 73 / 3, 0)
        end
        self.slotList[i] = ItemSlot.New()
        NumberpadPanel.AddUIChild(obj.transform:Find("Icon"), self.slotList[i].gameObject)
    end

    obj:SetActive(true)
    local cellPriceText = obj.transform:Find("CellPrice"):GetComponent(Text)
    local nameText = obj.transform:Find("NameText"):GetComponent(Text)
    local priceObj = obj.transform:Find("PriceBg").gameObject
    local priceText = priceObj.transform:Find("Value"):GetComponent(Text)
    local currencyImage = priceObj.transform:Find("CurrencyImage"):GetComponent(Image)
    local addIconObj = obj.transform:Find("Icon/AddImage").gameObject
    local lockIconObj = obj.transform:Find("Icon/LockImage").gameObject
    local soldoutObj = obj.transform:Find("SoldoutImage").gameObject
    local timeoutObj = obj.transform:Find("TimeoutImage").gameObject
    local cashoutObj = obj.transform:Find("CashoutImage").gameObject

    soldoutObj:SetActive(false)
    timeoutObj:SetActive(false)
    cashoutObj:SetActive(false)

    if data == nil then
        addIconObj:SetActive(false)
        lockIconObj:SetActive(true)
        cellPriceText.gameObject:SetActive(true)
        nameText.gameObject:SetActive(false)
        priceObj:SetActive(false)
        if i == 10 then
            cellPriceText.text = "50000"
        elseif i == 11 then
            cellPriceText.text = "100000"
        elseif i == 12 then
            cellPriceText.text = "200000"
        elseif i == 13 then
            cellPriceText.text = "500000"
        elseif i == 14 then
            cellPriceText.text = "800000"
        elseif i == 15 then
            cellPriceText.text = "200"
            local image = cellPriceText.transform:Find("Image"):GetComponent(Image)
            image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90002")
        end
        obj.name = "lock"
        self.slotList[i].gameObject:SetActive(false)
    else
        addIconObj:SetActive(true)
        lockIconObj:SetActive(false)
        cellPriceText.gameObject:SetActive(false)

        if data.cell_id == i then
            obj.name = data.cell_id
            local basedata = BackpackManager.Instance:GetItemBase(data.item_base_id)
            addIconObj:SetActive(false)
            lockIconObj:SetActive(false)

            local step = nil
            for _,v in pairs(data.item_attrs) do
                if v.attr == 1 then
                    if v.value > 0 then
                        step = v.value
                    end
                    break
                end
            end
            
            nameText.gameObject:SetActive(true)
            priceText.text = data.price
            if DataMarketSilver.data_market_silver_item[data.item_base_id] == nil then
                currencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90000")
            elseif DataMarketSilver.data_market_silver_item[data.item_base_id].gain_label == "coin" then
                currencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90000")
                self.totalCurrencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90000")
            elseif DataMarketSilver.data_market_silver_item[data.item_base_id].gain_label == "gold" then
                currencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90002")
                self.totalCurrencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90002")
            elseif DataMarketSilver.data_market_silver_item[data.item_base_id].gain_label == "gold_bind" then
                currencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90003")
                self.totalCurrencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90003")
            end
            priceObj:SetActive(true)

            local currentTime = BaseUtils.BASE_TIME

            if data.status == 5 then
                cashoutObj:SetActive(true)
                MarketManager.Instance:Cashout(true)
            elseif data.status == 1 then
                soldoutObj:SetActive(true)
                MarketManager.Instance:Cashout(true)
            elseif data.status == 2 or data.expiry <= currentTime or data.status == 6 then
                -- print(data.expiry - currentTime)
                timeoutObj:SetActive(true)
            end

            local cell = BackpackManager.Instance:GetItemBase(data.item_base_id)
            local itemdata = ItemData.New()
            itemdata:SetBase(cell)
            itemdata.step = step
            self.slotList[i]:SetAll(itemdata, self.extra)
            self.slotList[i].gameObject:SetActive(true)
            self.slotList[i]:SetNum(data.num)
            addIconObj.gameObject:SetActive(false)

            if basedata.type == 158 then
                step = nil
            end
            if step ~= nil then
                nameText.text = basedata.name.." <color=#FFFFFF>Lv."..step.."</color>"
            else
                nameText.text = basedata.name
            end
        else
            obj.name = "null"
            nameText.gameObject:SetActive(false)
            self.slotList[i].gameObject:SetActive(false)
            priceObj:SetActive(false)
        end
    end

    return obj
end

function MarketSellPanel:ClickItem(item, i)
    local model = self.parent.model
    if item.name == "lock" then
        local msg = ""
        local num = model.sellCellNum
        if num + 1 == 10 then
            msg = string.format(TI18N("你确定要花费<color='#00ff00'>%s</color>%s开启吗？"), 50000, "{assets_2, 90000}")
        elseif num + 1 == 11 then
            msg = string.format(TI18N("你确定要花费<color='#00ff00'>%s</color>%s开启吗？"), 100000, "{assets_2, 90000}")
        elseif num + 1 == 12 then
            msg = string.format(TI18N("你确定要花费<color='#00ff00'>%s</color>%s开启吗？"), 200000, "{assets_2, 90000}")
        elseif num + 1 == 13 then
            msg = string.format(TI18N("你确定要花费<color='#00ff00'>%s</color>%s开启吗？"), 500000, "{assets_2, 90000}")
        elseif num + 1 == 14 then
            msg = string.format(TI18N("你确定要花费<color='#00ff00'>%s</color>%s开启吗？"), 800000, "{assets_2, 90000}")
        elseif num + 1 == 15 then
            msg = string.format(TI18N("你确定要花费<color='#00ff00'>%s</color>%s开启吗？"), 200, "{assets_2, 90002}")
        end
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.content = TI18N(msg)
        confirmData.sureSecond = -1
        confirmData.cancelSecond = -1
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.sureCallback = function() MarketManager.Instance:send12412() end
        NoticeManager.Instance:ConfirmTips(confirmData)

    elseif item.name == "null" then
        model.sellCellCurrent = i
        -- MarketManager.Instance:OpenWindow({4, 1})
        if self.sellWin == nil then
            self.sellWin = MarketSellSelectPanel.New(self)
        end
        self.sellWin:Show()
    else
        -- print("status="..model.sellCellItem[i].status)
        local cell_id = tonumber(item.name)
        local info = model.sellCellItem[cell_id]

        if info.status == 5 or info.status == 1 then    -- 可提现
            MarketManager.Instance:send12411(cell_id)
            if DataMarketSilver.data_market_silver_item[info.item_base_id] == nil then
                SoundManager.Instance:Play(250)
            elseif KvData.assets[DataMarketSilver.data_market_silver_item[info.item_base_id].gain_label] == 90000 then
                SoundManager.Instance:Play(250)
            else
                SoundManager.Instance:Play(251)
            end
            if self.cashEffect ~= nil then
                self.cashEffect:DeleteMe()
            end
            self.cashEffect = BibleRewardPanel.ShowEffect(20111, MarketManager.Instance.model.marketWin.gameObject.transform, Vector3.one, Vector3(480, -270, 0), 4000)
        else
            self.sellWindow:SetActive(true)
            model.currentTab = 5
            local tempInfo = self.tempInfo
            local defInfo = DataMarketSilver.data_market_silver_item[info.item_base_id]
            tempInfo.cell_id = tonumber(item.name)
            tempInfo.base_id = info.item_base_id
            -- tempInfo.precent = math.ceil(info.price * 100 / defInfo.def_price)
            tempInfo.precent = 100
            tempInfo.num = info.num

            self:UpdateSellPanel()
            self:SetSellButton(info.item_base_id)
        end
    end
end

function MarketSellPanel:UpdateSellPanel()
    local model = self.parent.model

    local info = model.sellCellItem[self.tempInfo.cell_id]
    local basedata = DataItem.data_get[self.tempInfo.base_id]
    local serverPrice = model.standardPriceServerByBaseId[self.tempInfo.base_id]
    if serverPrice ~= nil then
        self.tempInfo.precent = math.floor(info.price * 100 / serverPrice)
    else
        MarketManager.Instance:send12408(self.tempInfo.base_id, 1)
    end
    self.tempInfo.numInBackpack = 0
    local backpackItemDic = BackpackManager.Instance.itemDic
    for k,v in pairs(backpackItemDic) do
        if v.base_id == self.tempInfo.base_id then
            self.tempInfo.numInBackpack = self.tempInfo.numInBackpack + 1
        end
    end

    local step = nil
    for _,v in pairs(info.item_attrs) do
        if v.attr == 1 then
            if v.value > 0 then
                step = v.value
            end
            break
        end
    end

    self.numText.text = tostring(self.tempInfo.num)
    self.priceText.text = tostring(info.price)

    self:UpdateDiscount()
    self.totalText.text = tostring(self.tempInfo.num * tonumber(self.priceText.text))

    if self.slot ~= nil then
        local itemdata = ItemData.New()
        local cell = DataItem.data_get[info.item_base_id]
        itemdata:SetBase(cell)
        itemdata.step = step
        self.slot:SetAll(itemdata, self.extra)
        self.itemNameText = cell.name
    end

    if basedata.type == 158 then
        step = nil
    end
    if step ~= nil then
        self.nameText.text = basedata.name.." <color=#FFFFFF>Lv."..step.."</color>"
    else
        self.nameText.text = basedata.name
    end

    if DataMarketSilver.data_market_silver_item[info.item_base_id] == nil then
        self.currencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90000")
    elseif DataMarketSilver.data_market_silver_item[info.item_base_id].gain_label == "coin" then
        self.currencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90000")
    elseif DataMarketSilver.data_market_silver_item[info.item_base_id].gain_label == "gold_bind" then
        self.currencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90003")
    else
        self.currencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90002")
    end
end

function MarketSellPanel:UpdateDiscount1()
    local model = self.parent.model
    local lastSelectId = model.lastSelectPos
    if lastSelectId == 0 then
        return
    end
    local msg = nil
    local colorRich = nil
    if model.posToPercent[lastSelectId] > 100 then
        msg = "+"..model.posToPercent[lastSelectId].."%"
        colorRich = "<color=#FF0000>"
    elseif model.posToPercent[lastSelectId] < 100 then
        msg = "-"..(100 - model.posToPercent[lastSelectId]).."%"
        colorRich = "<color=#13FFA1>"
    else
        msg = "100%"
        colorRich = ""
    end
    if colorRich == "" then
        self.discountText.text = string.format(TI18N("推荐价格%s"), msg)
    else
        self.discountText.text = string.format(TI18N("%s推荐价格%s</color", colorRich, msg))
    end
end

function MarketSellPanel:UpdateDiscount()
    local msg
    local colorRich
    local precent = self.tempInfo.precent
    if precent > 100 then
        msg = "+"..precent.."%"
        colorRich = "<color=#FF0000>"
    elseif precent < 100 then
        msg = "-"..precent.."%"
        colorRich = "<color=#13FFA1>"
    else
        msg = "100%"
        colorRich = ""
    end
    if colorRich == "" then
        self.discountText.text = string.format(TI18N("推荐价格%s"), tostring(msg))
    else
        self.discountText.text = string.format(TI18N("%s推荐价格%s </color>"), tostring(colorRich), tostring(msg))
    end
end

function MarketSellPanel:RoleAssetsListener()

end

function MarketSellPanel:OnInitCompleted()
    self:OnOpen()
end

function MarketSellPanel:OnOpen()
    local parent = self.parent
    local model = parent.model

    if model.sellCellNum == nil then        -- 首次获取
        MarketManager.Instance:send12407()
    else
        self:UpdateCells()
    end
end

function MarketSellPanel:CloseSell()
    if self.sellWin ~= nil then
        self.sellWin:DeleteMe()
        self.sellWin = nil
    end
    -- if self.sellWin ~= nil then
    --     self.sellWin:Hiden()
    -- end
end

function MarketSellPanel:SetSellButton(item_base_id)
    if DataMarketSilver.data_market_silver_item[item_base_id] == nil then
        self.cancelBtn.transform.anchoredPosition = Vector2(0, 46)
        self.putButton.gameObject:SetActive(false)
    else
        self.cancelBtn.transform.anchoredPosition = Vector2(-61, 46)
        self.putButton.gameObject:SetActive(true)
    end
end

