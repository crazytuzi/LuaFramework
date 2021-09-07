-- ------------------------------
-- 时装兑换
-- hosr
-- ------------------------------
FashionExchangeWindow = FashionExchangeWindow or BaseClass(BaseWindow)

function FashionExchangeWindow:__init(model)
    self.model = model
    self.name = "FashionExchangeWindow"
    self.windowId = WindowConfig.WinID.fashion_exchange

    self.resList = {
        {file = AssetConfig.npc_shop_window, type = AssetType.Main},
        {file = AssetConfig.wingsbookbg, type = AssetType.Dep},
    }

    self.pageList = {}
    self.toggleList = {}

    self.assetToKey = {}
    for k,v in pairs(KvData.assets) do
        self.assetToKey[v] = k
    end

    self.assetListener = function() self:RefreshOwn(self.lastPos.page or 1, self.lastPos.index or 1) self:RefreshPrice(self.lastPos.page or 1, self.lastPos.index or 1) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.updateListener = function() self:BackpackUpdate() end

    self.imgLoaderOnes = {}
    self.imgLoaderTwos = {}
    self.imgLoaderThree = nil
    self.imgLoaderFour = nil
end

function FashionExchangeWindow:__delete()
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

    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.pageList ~= nil then
        for _,page in ipairs(self.pageList) do
            for _,item in ipairs(page.items) do
                item.iconImage.sprite = nil
                item.currencyImage.sprite = nil
            end
        end
        self.pageList = nil
    end
    if self.imgLoaderOnes ~= nil then
        for k,v in pairs(self.imgLoaderOnes) do
            v:DeleteMe()
        end
        self.imgLoaderOnes = {}
    end

     if self.imgLoaderTwos ~= nil then
        for k,v in pairs(self.imgLoaderTwos) do
           v:DeleteMe()
        end

        self.imgLoaderTwo = {}
    end

     if self.imgLoaderThree ~= nil then
        self.imgLoaderThree:DeleteMe()
        self.imgLoaderThree = nil
    end

     if self.imgLoaderFour ~= nil then
        self.imgLoaderFour:DeleteMe()
        self.imgLoaderFour = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function FashionExchangeWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.npc_shop_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    self.transform:Find("Main/InfoPanel/FashionShow/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")

    self.cloner = t:Find("Main/ItemPanel/GridPanel/Container/ItemPage").gameObject
    self.container = t:Find("Main/ItemPanel/GridPanel/Container")
    self.toggleContainer = t:Find("Main/ItemPanel/ToggleGroup")
    self.toggleCloner = t:Find("Main/ItemPanel/ToggleGroup/Toggle").gameObject

    self.nameText = t:Find("Main/InfoPanel/NameBg/Name"):GetComponent(Text)
    self.descExt = MsgItemExt.New(t:Find("Main/InfoPanel/ItemInfo/DescText"):GetComponent(Text), 248.2, 17, 20)
    self.numBg = t:Find("Main/InfoPanel/NumObject/NumBg").gameObject
    self.numText = t:Find("Main/InfoPanel/NumObject/NumBg/Value"):GetComponent(Text)
    self.addBtn = t:Find("Main/InfoPanel/NumObject/PlusButton"):GetComponent(Button)
    self.minusBtn = t:Find("Main/InfoPanel/NumObject/MinusButton"):GetComponent(Button)
    self.priceText = t:Find("Main/InfoPanel/PriceObject/PriceBg/Value"):GetComponent(Text)
    self.priceImage = t:Find("Main/InfoPanel/PriceObject/Currency"):GetComponent(Image)
    self.ownText = t:Find("Main/InfoPanel/OwnObject/OwnBg/Value"):GetComponent(Text)
    self.ownImage = t:Find("Main/InfoPanel/OwnObject/Currency"):GetComponent(Image)
    self.button = t:Find("Main/InfoPanel/BuyButton"):GetComponent(Button)

    self.transform:Find("Main/InfoPanel/PriceObject"):GetComponent(Button).onClick:AddListener(function() self:ClickPrice() end)
    self.transform:Find("Main/InfoPanel/OwnObject"):GetComponent(Button).onClick:AddListener(function() self:ClickPrice() end)

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

    self.iteminfo = self.transform:Find("Main/InfoPanel/ItemInfo").gameObject
    self.iteminfo:SetActive(false)
    local fashion = self.transform:Find("Main/InfoPanel/FashionShow")
    self.fashioninfo = fashion.gameObject
    self.fashioninfo:SetActive(true)
    self.preview = fashion:Find("Preview").gameObject
    self.fashionDesc = fashion:Find("Text"):GetComponent(Text)
    self.fashionDesc.text = ""

    t:Find("Main/InfoPanel/NoticeText").gameObject:SetActive(false)
end

function FashionExchangeWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function FashionExchangeWindow:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.role_asset_change, self.assetListener)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.updateListener)

    self.titleText.text = TI18N("时装兑换")

    local classes = RoleManager.Instance.RoleData.classes
    local sex = RoleManager.Instance.RoleData.sex
    local list = {}
    for i,v in pairs(DataNpcShop.data_fashion) do
        if (v.classes == 0 or v.classes == classes) and (v.sex == 2 or v.sex == sex) then
            table.insert(list, v)
        end
    end

    self:ReloadPage(list)

    if #list > 0 then
        if self.openArgs ~= nil and self.openArgs.args ~= nil then
            self:OnClick(1, self.openArgs.args[1])
        else
            self:OnClick(1, 1)
        end
        self:OnDragEnd()
    end

    if self.openArgs ~= nil and self.openArgs.extString ~= nil then
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

function FashionExchangeWindow:OnHide()
    self:RemoveListeners()
end

function FashionExchangeWindow:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.assetListener)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.updateListener)
end

function FashionExchangeWindow:ReloadPage(datalist)
    local pageCount = 0
    local itemIndex = 0

    self.layout:ReSet()

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
                tab.currencyImage = tab.transform:Find("CurrencyImage"):GetComponent(Image)
                tab.iconImage = tab.transform:Find("Icon/Image"):GetComponent(Image)
                tab.nameText = tab.transform:Find("NameText"):GetComponent(Text)
                tab.hasGet = tab.transform:Find("HasGet").gameObject
                tab.btn = tab.gameObject:GetComponent(Button)

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

function FashionExchangeWindow:SetItemData(tab, data)
    tab.select:SetActive(false)

    local baseData = DataItem.data_get[data.base_id]
    local roledata = RoleManager.Instance.RoleData
    tab.hasGet:SetActive(false)

    if baseData ~= nil then
        local assets = data.item_cost[1][1]
        local price = data.item_cost[1][2]
        tab.priceText.text = price
        tab.nameText.text = data.name

        local idOne = tab.iconImage.gameObject:GetInstanceID()
        if self.imgLoaderOnes[idOne] == nil then
           local go =  tab.iconImage.gameObject
           self.imgLoaderOnes[idOne] = SingleIconLoader.New(go)
        end
        self.imgLoaderOnes[idOne]:SetSprite(SingleIconType.Item,baseData.icon)


        tab.base_id = data.base_id
        tab.protoData = data

        if GlobalEumn.CostTypeIconName[assets] == nil then
              local idTwo = tab.currencyImage.gameObject:GetInstanceID()
              if self.imgLoaderTwos[idTwo] == nil then
                  local go =  tab.currencyImage.gameObject
                  self.imgLoaderTwos[idTwo] = SingleIconLoader.New(go)
              end
              self.imgLoaderTwos[idTwo]:SetSprite(SingleIconType.Item,DataItem.data_get[assets].icon)
        else
            tab.currencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[assets])
        end
    end

    local isSuit = false
    local isBelt = false
    local fashion_id = 0
    for _,effect in pairs(baseData.effect) do
        if effect.effect_type == 25 then
            for k,v in pairs(effect.val) do
                local fashionData = DataFashion.data_base[v[1]]
                if (fashionData.classes == 0 or roledata.classes == fashionData.classes) and (fashionData.sex == 2 or roledata.sex == fashionData.sex) then
                    if DataFashion.data_suit[fashionData.set_id] == nil then
                        isBelt = true
                    else
                        isSuit = true
                    end
                    fashion_id = fashionData.base_id
                    break
                end
            end
            break
        end
    end

    if isSuit and fashion_id ~= 0 then
        tab.hasGet:SetActive(FashionManager.Instance.model:CheckSuitIsActive(fashion_id))
    elseif isBelt and fashion_id ~= 0 then
        tab.hasGet:SetActive(FashionManager.Instance.model:CheckBeltIsActive(fashion_id))
    else
        tab.hasGet:SetActive(false)
    end
end

function FashionExchangeWindow:OnClick(page, index)
    local item = self.pageList[page].items[index]
    local protoData = item.protoData
    local baseData = DataItem.data_get[item.base_id]

    local looks_val_head = 0
    local looks_val_dress = 0
    local looks_val_belt = 0
    local looks_val_headsub = 0

    local looks_type_head = 0
    local looks_type_dress = 0
    local looks_type_belt = 0
    local looks_type_headsub = 0

    local looks_model_head = 0
    local looks_model_dress = 0
    local looks_model_belt = 0
    local looks_model_headsub = 0

    self.isBelt = false
    for _,effect in pairs(baseData.effect) do
        if effect.effect_type == 25 then
            for k,v in pairs(effect.val) do
                local fashionData = DataFashion.data_base[v[1]]
                if fashionData.type == 2 then
                    looks_val_head = fashionData.model_id
                    looks_type_head = fashionData.type
                    looks_model_head = fashionData.texture_id
                elseif fashionData.type == 3 then
                    looks_val_dress = fashionData.model_id
                    looks_type_dress = fashionData.type
                    looks_model_dress = fashionData.texture_id
                elseif fashionData.type == 4 then
                    self.isBelt = true
                    looks_val_belt = fashionData.model_id
                    looks_type_belt = fashionData.type
                    looks_model_belt = fashionData.texture_id
                elseif fashionData.type == 6 then
                    looks_val_headsub = fashionData.model_id
                    looks_type_headsub = fashionData.type
                    looks_model_headsub = fashionData.texture_id
                end
            end
        end
    end

    if self.lastPos ~= nil then
        self.pageList[self.lastPos.page].items[self.lastPos.index].select:SetActive(false)
    end
    if baseData ~= nil then
        self.descExt:SetData(baseData.desc)
        local assets = protoData.item_cost[1][1]
        local price = protoData.item_cost[1][2]
        self.priceText.text = price
        self.nameText.text = baseData.name
        if GlobalEumn.CostTypeIconName[assets] == nil then
            local id = item.currencyImage.gameObject:GetInstanceID()
            self.imgLoaderTwos[id]:SetSprite(SingleIconType.Item,DataItem.data_get[assets].icon)
        else
            item.currencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[assets])
        end
    end
    item.select:SetActive(true)

    self.lastPos = self.lastPos or {}
    self.lastPos.page = page
    self.lastPos.index = index

    self:RefreshOwn(page, index)
    self:RefreshPrice(page, index)

    local myData = SceneManager.Instance:MyData()
    local unitData = BaseUtils.copytab(myData)
    local looks = unitData.looks

    local hasHead = false
    local hasDress = false
    local hasBelt = false
    local hasHeadSub = false

    for k,v in pairs(looks) do
        if v.looks_type == SceneConstData.looktype_hair then
            -- 头
            hasHead = true
            if looks_val_head ~= 0 then
                v.looks_val = looks_val_head
            end
            if looks_type_head ~= 0 then
                v.looks_type = looks_type_head
            end
            if looks_model_head ~= 0 then
                v.looks_mode = looks_model_head
            end
        elseif v.looks_type == SceneConstData.looktype_dress then
            -- 身
            hasDress = true
            if looks_val_dress ~= 0 then
                v.looks_val = looks_val_dress
            end
            if looks_type_dress ~= 0 then
                v.looks_type = looks_type_dress
            end
            if looks_model_dress ~= 0 then
                v.looks_mode = looks_model_dress
            end
        elseif v.looks_type == SceneConstData.lookstype_belt then
            -- 背饰
            hasBelt = true
            if looks_val_belt ~= 0 then
                v.looks_val = looks_val_belt
            end
            if looks_type_belt ~= 0 then
                v.looks_type = looks_type_belt
            end
            if looks_model_belt ~= 0 then
                v.looks_mode = looks_model_belt
            end
        elseif v.looks_type == SceneConstData.lookstype_headsurbase then
            -- 头饰
            hasHeadSub = true
            if looks_val_headsub ~= 0 then
                v.looks_val = looks_val_headsub
            end
            if looks_type_headsub ~= 0 then
                v.looks_type = looks_type_headsub
            end
            if looks_model_headsub ~= 0 then
                v.looks_mode = looks_model_headsub
            end
        end
    end

    if not hasHead and looks_val_head ~= 0 then
        table.insert(looks, {looks_str = "", looks_val = looks_val_head, looks_mode = looks_model_head, looks_type = looks_type_head})
    end

    if not hasDress and looks_val_dress ~= 0 then
        table.insert(looks, {looks_str = "", looks_val = looks_val_dress, looks_mode = looks_model_dress, looks_type = looks_type_dress})
    end

    if not hasBelt and looks_val_belt ~= 0 then
        table.insert(looks, {looks_str = "", looks_val = looks_val_belt, looks_mode = looks_model_belt, looks_type = looks_type_belt})
    end

    if not hasHeadSub and looks_val_headsub ~= 0 then
        table.insert(looks, {looks_str = "", looks_val = looks_val_headsub, looks_mode = looks_model_headsub, looks_type = looks_type_headsub})
    end

    self:UpdatePreview(looks)
end

function FashionExchangeWindow:OnDragEnd()
    local pageCount = #self.layout.cellList
    for i,v in ipairs(self.toggleList) do
        v.isOn = false
    end
    self.toggleList[self.tabbed.currentPage].isOn = true
end

function FashionExchangeWindow:OnBuy()
    self.num = self.num or 1
    local item = self.pageList[self.lastPos.page].items[self.lastPos.index]
    NpcshopManager.Instance:send11400(4, item.protoData.base_id, self.num)
end

function FashionExchangeWindow:AddOrMinus(status)
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

function FashionExchangeWindow:RefreshPrice(page, index)
    self.num = self.num or 1
    local item = self.pageList[page].items[index]
    local protoData = item.protoData
    local assets = protoData.item_cost[1][1]
    local price = protoData.item_cost[1][2]
    -- local baseData = DataItem.data_get[item.base_id]

    if price * self.num > self.count then
        self.priceText.text = string.format("<color='#ff0000'>%s</color>", tostring(price * self.num))
    else
        self.priceText.text = tostring(price * self.num)
    end
    if GlobalEumn.CostTypeIconName[assets] == nil then
        if self.imgLoaderThree == nil then
           local go = self.priceImage.gameObject
           self.imgLoaderThree = SingleIconLoader.New(go)
        end
        self.imgLoaderThree:SetSprite(SingleIconType.Item,DataItem.data_get[assets].icon)
    else
        self.priceImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[assets])
    end
    self.numText.text = tostring(self.num)
end

function FashionExchangeWindow:RefreshOwn(page, index)
    local item = self.pageList[page].items[index]
    local protoData = item.protoData
    local assets = protoData.item_cost[1][1]
    local price = protoData.item_cost[1][2]

    if GlobalEumn.CostTypeIconName[assets] == nil then
        if self.imgLoaderFour == nil then
           local go = self.ownImage.gameObject
           self.imgLoaderFour = SingleIconLoader.New(go)
        end
        self.imgLoaderFour:SetSprite(SingleIconType.Item,DataItem.data_get[assets].icon)
    else
        self.ownImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[assets])
    end

    if assets >= 90000 then
        if KvData.assets[assets] == KvData.assets.star_gold_or_gold then
            self.count = RoleManager.Instance.RoleData.gold + RoleManager.Instance.RoleData.star_gold
        else
            self.count = RoleManager.Instance.RoleData[assets] or 0
        end
    else
        self.count = BackpackManager.Instance:GetItemCount(assets)
    end
    self.ownText.text = tostring(self.count)
end

function FashionExchangeWindow:OnClose()
    WindowManager.Instance:CloseWindow(self)
end

--更新模型
function FashionExchangeWindow:UpdatePreview(_looks)
    self.last_looks = _looks
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "FashionExchangeWindowRole"
        ,orthographicSize = 0.7
        ,width = 300
        ,height = 300
        ,offsetY = -0.25
    }

    local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = _looks}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
end


function FashionExchangeWindow:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)

    if self.isBelt then
        composite.tpose.transform.localRotation = Quaternion.identity
        composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.Backward, 0))
    end

    self.preview:SetActive(true)
end

function FashionExchangeWindow:BackpackUpdate()
    self:RefreshOwn(self.lastPos.page or 1, self.lastPos.index or 1)
end

function FashionExchangeWindow:ClickPrice()
    local info = {}
    local item = ItemData.New()
    item:SetBase(BaseUtils.copytab(DataItem.data_get[24022]))
    info.itemData = item
    TipsManager.Instance:ShowItem(info)
end