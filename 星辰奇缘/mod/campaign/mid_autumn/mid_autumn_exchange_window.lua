-- @author 黄耀聪
-- @date 2016年9月11日

MidAutumnExchangeWindow = MidAutumnExchangeWindow or BaseClass(BaseWindow)

--type 用来区分是不是活动兑换商店
function MidAutumnExchangeWindow:__init(model)
    self.model = model
    self.name = "MidAutumnExchangeWindow"
    self.windowId = WindowConfig.WinID.mid_autumn_exchange

    self.resList = {
        {file = AssetConfig.npc_shop_window, type = AssetType.Main}
    }

    self.pageList = {}
    self.toggleList = {}

    self.assetToKey = {}
    for k,v in pairs(KvData.assets) do
        self.assetToKey[v] = k
    end
    self.item = nil

    self.assetListener = function() self:RefreshOwn(self.lastPos.page or 1, self.lastPos.index or 1) self:RefreshPrice(self.lastPos.page or 1, self.lastPos.index or 1) end
    self.updatePrice = function() self:OnUpdatePrice() end
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MidAutumnExchangeWindow:__delete()
    self.OnHideEvent:Fire()
    if self.tabbed ~= nil then
        self.tabbed:DeleteMe()
        self.tabbed = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    if self.extExt ~= nil then
        self.extExt:DeleteMe()
        self.extExt = nil
    end
    if self.ownLoader ~= nil then
        self.ownLoader:DeleteMe()
        self.ownLoader = nil
    end
    if self.pageList ~= nil then
        for _,page in ipairs(self.pageList) do
            for _,item in ipairs(page.items) do
                item.iconLoader:DeleteMe()
                item.currencyLoader:DeleteMe()
            end
        end
        self.pageList = nil
    end
    if self.priceLoader ~= nil then
        self.priceLoader:DeleteMe()
        self.priceLoader = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MidAutumnExchangeWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.npc_shop_window))

    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    self.cloner = t:Find("Main/ItemPanel/GridPanel/Container/ItemPage").gameObject
    self.container = t:Find("Main/ItemPanel/GridPanel/Container")
    self.toggleContainer = t:Find("Main/ItemPanel/ToggleGroup")
    self.toggleCloner = t:Find("Main/ItemPanel/ToggleGroup/Toggle").gameObject

    self.nameText = t:Find("Main/InfoPanel/NameBg/Name"):GetComponent(Text)
    self.limitText = t:Find("Main/InfoPanel/NoticeText"):GetComponent(Text)
    self.descExt = MsgItemExt.New(t:Find("Main/InfoPanel/ItemInfo/DescText"):GetComponent(Text), 248.2, 17, 20)
    self.numBg = t:Find("Main/InfoPanel/NumObject/NumBg").gameObject

    self.numBg.transform:GetComponent(Button).onClick:AddListener(function() self:OnNumberpad() end)

    self.numText = t:Find("Main/InfoPanel/NumObject/NumBg/Value"):GetComponent(Text)
    self.addBtn = t:Find("Main/InfoPanel/NumObject/PlusButton"):GetComponent(Button)
    self.minusBtn = t:Find("Main/InfoPanel/NumObject/MinusButton"):GetComponent(Button)
    self.priceText = t:Find("Main/InfoPanel/PriceObject/PriceBg/Value"):GetComponent(Text)
    self.priceLoader = SingleIconLoader.New(t:Find("Main/InfoPanel/PriceObject/Currency").gameObject)
    self.ownText = t:Find("Main/InfoPanel/OwnObject/OwnBg/Value"):GetComponent(Text)
    self.ownLoader = SingleIconLoader.New(t:Find("Main/InfoPanel/OwnObject/Currency").gameObject)
    self.button = t:Find("Main/InfoPanel/BuyButton"):GetComponent(Button)

    self.extExt = MsgItemExt.New(t:Find("Main/InfoPanel/Ext"):GetComponent(Text), 300, 17, 20)
    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X, cspacing = 0, border = 0})

    self.titleText = t:Find("Main/Title/Text"):GetComponent(Text)
    self.tabbed = TabbedPanel.New(self.container.parent.gameObject, 0, 456, 0.6)
    self.tabbed.MoveEndEvent:AddListener(function() self:OnDragEnd() end)
    self.cloner:SetActive(false)
    self.toggleCloner:SetActive(false)

    self.addBtn.onClick:AddListener(function() self:AddOrMinus(true) end)
    self.minusBtn.onClick:AddListener(function() self:AddOrMinus(false) end)
    self.button.onClick:AddListener(function() self:OnBuy() end)

    t:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
    self.max_result = 100
    self.numberpadSetting = {               -- 弹出小键盘的设置
        gameObject = self.numBg.gameObject,
        min_result = 1,
        max_by_asset = self.max_result,
        max_result = self.max_result,
        textObject = self.numText,
        show_num = false,
        funcReturn = function() NoticeManager.Instance:FloatTipsByString(TI18N("请确认购买")) end,
        callback = self.updatePrice
    }

end

function MidAutumnExchangeWindow:OnNumberpad()
    if self.item == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择需要购买的物品"))
    else

        self.numberpadSetting.max_result = 100
        self.numberpadSetting.max_by_asset = 100
        NumberpadManager.Instance:set_data(self.numberpadSetting)
    end
end
function MidAutumnExchangeWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MidAutumnExchangeWindow:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.role_asset_change, self.assetListener)

    self.titleText.text = self.openArgs.title
    local myDataList = {}
    if self.openArgs.id == nil then
        myDataList = self.openArgs.datalist
    else
        local shopId = self.openArgs.id
        for i, v in pairs(ShopManager.Instance.model.datalist[2][shopId]) do
            table.insert(myDataList, v)
        end
    end


    self:ReloadPage(myDataList)
    if #myDataList > 0 then
        if self.openArgs.args ~= nil then
            self:OnClick(1, self.openArgs.args[1])
        else
            self:OnClick(1, 1)
        end
        self:OnDragEnd()
    end
    if self.openArgs.extString ~= nil then
        self.extExt.contentTrans.gameObject:SetActive(true)
        self.extExt:SetData(self.openArgs.extString)
        self.button.transform.anchoredPosition = Vector2(0,-180.3)
        local size = self.extExt.contentTrans.sizeDelta
        self.extExt.contentTrans.anchoredPosition = Vector2(0-size.x / 2, -118.3)
    else
        self.extExt.contentTrans.gameObject:SetActive(false)
        self.button.transform.anchoredPosition = Vector2(0,-167.5)
    end
end

function MidAutumnExchangeWindow:OnHide()
    self:RemoveListeners()
end

function MidAutumnExchangeWindow:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.assetListener)
end

function MidAutumnExchangeWindow:ReloadPage(datalist)
    local pageCount = 0
    local itemIndex = 0

    self.layout:ReSet()
    -- BaseUtils.dump(datalist,"data_list:")
    for i,v in ipairs(datalist) do
        pageCount = math.ceil(i / 8)
        itemIndex = (i - 1) % 8 + 1
        local page = self.pageList[pageCount]
        if page == nil then
            page = {}
            page.gameObject = GameObject.Instantiate(self.cloner)
            page.gameObject.name = tostring(pageCount)
            page.transform = page.gameObject.transform
            page.items = {}
            for j=1,8 do
                page.items[j] = {}
                local tab = page.items[j]
                tab.transform = page.transform:GetChild(j - 1)
                tab.gameObject = tab.transform.gameObject
                tab.select = tab.transform:Find("Select").gameObject
                tab.priceText = tab.transform:Find("PriceBg/Value"):GetComponent(Text)
                tab.currencyLoader = SingleIconLoader.New(tab.transform:Find("CurrencyImage").gameObject)
                tab.iconLoader = SingleIconLoader.New(tab.transform:Find("Icon/Image").gameObject)
                tab.nameText = tab.transform:Find("NameText"):GetComponent(Text)
                tab.hasGet = tab.transform:Find("HasGet").gameObject
                tab.btn = tab.gameObject:GetComponent(Button)
                tab.tipsImage = tab.transform:Find("TipsImage"):GetComponent(Image)
                tab.tipsTxt = tab.transform:Find("TipsImage/Text"):GetComponent(Text)

                local k = pageCount
                tab.btn.onClick:AddListener(function() self:OnClick(k, j) end)
            end
            self.pageList[pageCount] = page

            local toggleObj = GameObject.Instantiate(self.toggleCloner)
            toggleObj.transform:SetParent(self.toggleContainer)
            toggleObj.transform.localScale = Vector3.one
            self.toggleList[pageCount] = toggleObj:GetComponent(Toggle)
        end

        self:SetItemData(page.items[itemIndex], v)
        page.gameObject:SetActive(true)
    end
    self.tabbed:SetPageCount(pageCount)
    for i=1,pageCount do
        self.layout:AddCell(self.pageList[i].gameObject)
        self.pageList[i].gameObject:SetActive(true)
        self.toggleList[i].gameObject:SetActive(true)

        if i ~= pageCount then
            for _,v in ipairs(self.pageList[i].items) do
                v.gameObject:SetActive(true)
            end
        else
            for j,v in ipairs(self.pageList[i].items) do
                if j > itemIndex then
                    v.gameObject:SetActive(false)
                else
                    v.gameObject:SetActive(true)
                end
            end
        end
    end
    for i=pageCount + 1,#self.pageList do
        self.pageList[i].gameObject:SetActive(false)
        self.toggleList[i].gameObject:SetActive(false)
    end
end

function MidAutumnExchangeWindow:SetItemData(tab, data)
    tab.select:SetActive(false)

    local baseData = DataItem.data_get[data.base_id]
    local roledata = RoleManager.Instance.RoleData
    --BaseUtils.dump(data,"datadatadatadatadata")
    self.isSuit = false
    self.isBelt = false
    for _,effect in pairs(baseData.effect) do
        if effect.effect_type == 25 then
            for k,v in pairs(effect.val) do
                local fashionData = DataFashion.data_base[v[1]]
                if (fashionData.classes == 0 or roledata.classes == fashionData.classes) and (fashionData.sex == 2 or roledata.sex == fashionData.sex) then
                    -- kvLooks[fashionData.type] = {looks_str = "", looks_val = fashionData.model_id, looks_mode = fashionData.texture_id, looks_type = fashionData.type}
                    if DataFashion.data_suit[fashionData.set_id] == nil then
                        self.isBelt = true
                    else
                        self.isSuit = true
                    end
                    self.fashion_id = fashionData.base_id
                    break
                end
            end
            break
        end
    end

    if self.isSuit then
        -- self.hasGet:SetActive(BackpackManager.Instance:GetItemCount(data.base_id) > 0 or FashionManager.Instance.model:CheckSuitIsActive(self.fashion_id))
        tab.hasGet:SetActive(FashionManager.Instance.model:CheckSuitIsActive(self.fashion_id))
    elseif self.isBelt then
        -- self.hasGet:SetActive(BackpackManager.Instance:GetItemCount(data.base_id) > 0 or FashionManager.Instance.model:CheckBeltIsActive(self.fashion_id))
        tab.hasGet:SetActive(FashionManager.Instance.model:CheckBeltIsActive(self.fashion_id))
    else
        tab.hasGet:SetActive(false)
    end

    if baseData ~= nil then
        tab.priceText.text = tostring(data.price)
        tab.nameText.text = baseData.name
        tab.iconLoader:SetSprite(SingleIconType.Item, baseData.icon)
        tab.base_id = data.base_id
        tab.protoData = data
        if data.label ~= 0 then
            tab.tipsImage.gameObject:SetActive(true)
            tab.tipsImage.transform.anchoredPosition = Vector2(-80, 18)
            if data.label == 1 then
                tab.tipsImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Tipslabel2")
                tab.tipsTxt.text = TI18N("热卖")
                tab.tipsTxt.color = Color(177/255,34/255,34/255)
            elseif data.label == 2 then
                tab.tipsImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Tipslabel1")
                tab.tipsTxt.text = TI18N("新品")
                tab.tipsTxt.color = Color(1,1,1)
            elseif data.label == 3 then
                tab.tipsImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Tipslabel3")
                tab.tipsTxt.text = TI18N("绑定")
                tab.tipsTxt.color = Color(1,1,1)
            end
        end

        if GlobalEumn.CostTypeIconName[data.assets_type] == nil then
            tab.currencyLoader:SetSprite(SingleIconType.Item, DataItem.data_get[KvData.assets[data.assets_type]].icon)

        else
            tab.currencyLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[data.assets_type]))
        end
    else
    end
end

function MidAutumnExchangeWindow:OnClick(page, index)
    local item = self.pageList[page].items[index]
    local protoData = item.protoData
    local baseData = DataItem.data_get[item.base_id]

    if self.lastPos ~= nil then
        self.pageList[self.lastPos.page].items[self.lastPos.index].select:SetActive(false)
    end
    if baseData ~= nil then
        self.descExt:SetData(baseData.desc)
        self.priceText.text = protoData.price
        if protoData.limit_role ~= -1 then
            if protoData.limit_type == "day" then
                self.limitText.text = string.format(TI18N("每日限购:%s"), protoData.limit_role)
            elseif protoData.limit_type == "week" then
                self.limitText.text = string.format(TI18N("每周限购:%s"), protoData.limit_role)
            elseif protoData.limit_type == "forever" then
                self.limitText.text = string.format(TI18N("角色限购:%s"), protoData.limit_role)
            elseif protoData.limit_type == "normal" then
                self.limitText.text = ""
            end

            self.limitText.gameObject:SetActive(true)
        else
            self.limitText.gameObject:SetActive(false)
        end

        self.nameText.text = baseData.name
        if GlobalEumn.CostTypeIconName[protoData.assets_type] == nil then
            item.currencyLoader:SetSprite(SingleIconType.Item, DataItem.data_get[KvData.assets[protoData.assets_type]].icon)
        else
            item.currencyLoader.sprite.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[protoData.assets_type])
        end
        
        local ddesc = BaseUtils.ReplacePattern(baseData)
        self.descExt:SetData(ddesc, true)
    end
    item.select:SetActive(true)

    self.lastPos = self.lastPos or {}
    self.lastPos.page = page
    self.lastPos.index = index

    self:RefreshOwn(page, index)
    self:RefreshPrice(page, index)
end

function MidAutumnExchangeWindow:OnDragEnd()
    local pageCount = #self.layout.cellList
    for i,v in ipairs(self.toggleList) do
        v.isOn = false
    end
    if self.toggleList[self.tabbed.currentPage] ~= nil then
        self.toggleList[self.tabbed.currentPage].isOn = true
    end
end

function MidAutumnExchangeWindow:OnBuy()
    self.num = self.num or 1
    local item = self.pageList[self.lastPos.page].items[self.lastPos.index]
    ShopManager.Instance:send11303(item.protoData.id, self.num)



     local protoData =self.item.protoData


    -- local assets = 0
    -- if model.infoCurrencyType == 29255 then
    --     assets = RoleManager.Instance.RoleData.gold + RoleManager.Instance.RoleData.star_gold
    -- else
    --     assets = RoleManager.Instance.RoleData[self.mgr.assetIdToKey[model.infoCurrencyType]]
    -- end
    if protoData.price * self.num > self.count then
        local itemData = ItemData.New()
        local gameObject = self.button.gameObject
        itemData:SetBase(DataItem.data_get[KvData.assets[ShopManager.Instance.itemPriceTab[item.protoData.id].assets_type]])
         TipsManager.Instance:ShowItem({gameObject = gameObject, itemData = itemData})
    end

end

function MidAutumnExchangeWindow:AddOrMinus(status)
    self.num = self.num or 1
    if status == true then  -- 加
        if self.num < 100 then
            self.num = self.num + 1
        end
    else                    -- 减
        if self.num > 1 then
            self.num = self.num - 1
        end
    end
    self:RefreshOwn(self.lastPos.page, self.lastPos.index)
    self:RefreshPrice(self.lastPos.page, self.lastPos.index)
end

function MidAutumnExchangeWindow:RefreshPrice(page, index)
    self.num = self.num or 1
    local item = self.pageList[page].items[index]
    self.item = item
    local protoData = item.protoData
    -- local baseData = DataItem.data_get[item.base_id]

    if protoData.price * self.num > self.count then
        self.priceText.text = string.format("<color='#ff0000'>%s</color>", tostring(protoData.price * self.num))
    else
        self.priceText.text = tostring(protoData.price * self.num)
    end
    if GlobalEumn.CostTypeIconName[protoData.assets_type] == nil then
        self.priceLoader:SetSprite(SingleIconType.Item, DataItem.data_get[KvData.assets[protoData.assets_type]].icon)
    else
        self.priceLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[protoData.assets_type]))
    end
    self.numText.text = tostring(self.num)
end

function MidAutumnExchangeWindow:RefreshOwn(page, index)
    local item = self.pageList[page].items[index]
    local protoData = item.protoData

    if GlobalEumn.CostTypeIconName[protoData.assets_type] == nil then
        self.ownLoader:SetSprite(SingleIconType.Item, DataItem.data_get[KvData.assets[protoData.assets_type]].icon)
    else
        self.ownLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[protoData.assets_type]))
    end
    if KvData.assets[protoData.assets_type] == KvData.assets.star_gold_or_gold then
        self.count = RoleManager.Instance.RoleData.gold + RoleManager.Instance.RoleData.star_gold
    else
        self.count = RoleManager.Instance.RoleData[protoData.assets_type] or 0
    end


    self.ownText.text = tostring(self.count)
end

function MidAutumnExchangeWindow:OnClose()
    -- WindowManager.Instance:CloseWindowById(WindowConfig.WinID.campaign_uniwin)
    WindowManager.Instance:CloseWindow(self)

end


function MidAutumnExchangeWindow:OnUpdatePrice()
    self.num = NumberpadManager.Instance:GetResult()
    local protoData =self.item.protoData


    -- local assets = 0
    -- if model.infoCurrencyType == 29255 then
    --     assets = RoleManager.Instance.RoleData.gold + RoleManager.Instance.RoleData.star_gold
    -- else
    --     assets = RoleManager.Instance.RoleData[self.mgr.assetIdToKey[model.infoCurrencyType]]
    -- end
    if protoData.price * self.num > self.count then
        self.priceText.text = string.format("<color='#ff0000'>%s</color>", tostring(protoData.price * self.num))
    else
        self.priceText.text = tostring(protoData.price * self.num)
    end

    if GlobalEumn.CostTypeIconName[protoData.assets_type] == nil then
        self.priceLoader:SetSprite(SingleIconType.Item, DataItem.data_get[KvData.assets[protoData.assets_type]].icon)
    else
        self.priceLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[protoData.assets_type]))
    end
    self.numText.text = tostring(self.num)
end
