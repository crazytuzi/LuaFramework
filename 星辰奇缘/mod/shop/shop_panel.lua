ShopPanel = ShopPanel or BaseClass(BasePanel)

function ShopPanel:__init(model, parent, main,showParent)
    self.showParent = showParent
    self.model = model
    self.parent = parent
    self.main = main
    self.mgr = ShopManager.Instance
    self.frozen = nil
    self.rechargeFrozen = nil

    local resList = {}
    for k,v in pairs(model.dataTypeList[self.main].subList) do
        if v ~= nil and v.textures ~= nil and resList[v.textures] == nil then
            resList[v.textures] = 1
        end
    end

    self.resList = {
        {file = AssetConfig.shop_panel, type = AssetType.Main},
        {file = AssetConfig.wingsbookbg, type = AssetType.Dep},
    }

    for k,v in pairs(resList) do
        table.insert(self.resList, {file = k, type = AssetType.Dep})
    end

    if resList[AssetConfig.shop_textures] == nil then
        table.insert(self.resList, {file = AssetConfig.shop_textures, type = AssetType.Dep})
    end

    self.subPanelList = {}

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.updateCurrencyListener = function() self:OnUpdateCurrency(true) end
    self.checkRedListener = function() self:CheckRedPoint() end
    self.updatePrice = function() self:OnUpdatePrice() end
    self.unfreezeListener = function() self:OnUnfreeze() end
    self.refreshListener = function() self:OnRefresh() end

    self.shopRoleShowPanel = nil

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function ShopPanel:__delete()
    self.OnHideEvent:Fire()
    if self.numberpadSetting ~= nil then
        self.numberpadSetting.textObject = nil
        self.numberpadSetting = nil
    end

    if self.shopRoleShowPanel ~= nil then
        self.shopRoleShowPanel:DeleteMe()
        self.shopRoleShowPanel = nil
    end

    if self.tabList ~= nil then
        for _,tab in pairs(self.tabList) do
            if tab ~= nil and tab.imageLoader ~= nil then
                tab.imageLoader:DeleteMe()
            end
        end
    end
    if self.ownCurrencyLoader1 ~= nil then
        self.ownCurrencyLoader1:DeleteMe()
        self.ownCurrencyLoader1 = nil
    end
    if self.ownCurrencyLoader ~= nil then
        self.ownCurrencyLoader:DeleteMe()
        self.ownCurrencyLoader = nil
    end
    if self.totalCurrencyLoader ~= nil then
        self.totalCurrencyLoader:DeleteMe()
        self.totalCurrencyLoader = nil
    end
    if self.frozen ~= nil then
        self.frozen:DeleteMe()
        self.frozen = nil
    end
    if self.rechargeFrozen ~= nil then
        self.rechargeFrozen:DeleteMe()
        self.rechargeFrozen = nil
    end
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.msgItemExt ~= nil then
        self.msgItemExt:DeleteMe()
        self.msgItemExt = nil
    end
    if self.subPanelList ~= nil then
        for k,v in pairs(self.subPanelList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.subPanelList = nil
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if  self.fashionShowObj ~= nil then
        self.fashionShowObj.transform:Find("Bg"):GetComponent(Image).sprite = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self.callback = nil
    self:AssetClearAll()
end

function ShopPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shop_panel))
    self.gameObject.name = "BuyPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.transform = self.gameObject.transform
    local t = self.transform

    self.goodsPanel = t:Find("GoodsPanel")
    self.tabCloner = t:Find("Button").gameObject
    self.tabCloner.transform.pivot = Vector2(0.5, 0.5)
    self.tabContainer = t:Find("TopTabButtonGroup")
    self.infoArea = t:Find("InfoArea")

    local goodsTips = self.infoArea:Find("GoodsTips")
    self.girlGuideObj = goodsTips:Find("GirlGuide").gameObject
    self.goodsInfoObj = goodsTips:Find("GoodsInfo").gameObject
    self.fashionShowObj = goodsTips:Find("FashionShow").gameObject
    self.fashionShowObj.transform:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.fashionLeftBtn = goodsTips:Find("FashionShow/Notice"):GetComponent(Button)
    self.fashionLeftBtn.onClick:AddListener(function() self:ApplyFashionLeftBtn() end)
    self.fashionRightBtn = goodsTips:Find("FashionShow/ShowBtn"):GetComponent(Button)
    self.fashionRightBtn.onClick:AddListener(function() self:ApplyFashionRightBtn() end)
    self.nameText = goodsTips:Find("GoodsInfo/Image/Name"):GetComponent(Text)
    self.scrollTrans = goodsTips:Find("GoodsInfo/Scroll")
    self.descText = goodsTips:Find("GoodsInfo/Scroll/Describe"):GetComponent(Text)
    self.restraintText = goodsTips:Find("GoodsInfo/Restraint"):GetComponent(Text)
    self.restraintRect = self.restraintText.transform
    self.priceObj = goodsTips:Find("GoodsInfo/Price").gameObject
    self.pricesText = goodsTips:Find("GoodsInfo/Price/Prices"):GetComponent(Text)
    self.discountObj = goodsTips:Find("GoodsInfo/Price/Discount").gameObject
    self.discountText = goodsTips:Find("GoodsInfo/Price/Discount/Discount"):GetComponent(Text)
    self.originCurrencyImage = goodsTips:Find("GoodsInfo/Price/OriginCurrency"):GetComponent(Image)
    self.nowCurrencyImage = goodsTips:Find("GoodsInfo/Price/NowCurrency"):GetComponent(Image)
    self.descObj = t:Find("Desc").gameObject
    self.refreshBtn = t:Find("Refresh"):GetComponent(Button)
    self.helpBtn = t:Find("Help"):GetComponent(Button)
    self.previewContainer = goodsTips:Find("FashionShow/Preview")
    self.fashionText = goodsTips:Find("FashionShow/Text"):GetComponent(Text)

    local buyArea = t:Find("InfoArea/BuyArea")
    self.countTrans = buyArea:Find("BuyCount")
    self.countText = buyArea:Find("BuyCount/CountBg/Count"):GetComponent(Text)
    self.countBtn = buyArea:Find("BuyCount/CountBg"):GetComponent(Button)
    self.addBtn = buyArea:Find("BuyCount/AddBtn"):GetComponent(Button)
    self.minusBtn = buyArea:Find("BuyCount/MinusBtn"):GetComponent(Button)
    self.totalPrice = buyArea:Find("BuyPrice")
    self.totalPriceText = buyArea:Find("BuyPrice/PriceBg/Price"):GetComponent(Text)
    self.totalCurrencyLoader = SingleIconLoader.New(buyArea:Find("BuyPrice/PriceBg/Currency").gameObject)
    self.ownAsset = buyArea:Find("OwnAsset")
    self.ownAssetText = buyArea:Find("OwnAsset/AssetBg/Asset"):GetComponent(Text)
    self.ownCurrencyLoader = SingleIconLoader.New(buyArea:Find("OwnAsset/AssetBg/Currency").gameObject)
    -- self.ownCurrencyLoader = buyArea:Find("OwnAsset/AssetBg/Currency"):GetComponent(Image)
    self.ownAsset1 = buyArea:Find("OwnAsset1")
    self.ownAssetText1 = buyArea:Find("OwnAsset1/AssetBg/Asset"):GetComponent(Text)
    self.ownCurrencyLoader1 = SingleIconLoader.New(buyArea:Find("OwnAsset1/AssetBg/Currency").gameObject)
    -- self.ownCurrencyLoader1 = buyArea:Find("OwnAsset1/AssetBg/Currency"):GetComponent(Image)
    self.buyBtn = buyArea:Find("BtnArea/Button"):GetComponent(Button)
    self.rechargeBtn = buyArea:Find("BtnArea/Recharge"):GetComponent(Button)
    self.rechargeImage = buyArea:Find("BtnArea/Recharge"):GetComponent(Image)
    self.rechargeText = buyArea:Find("BtnArea/Recharge/Text"):GetComponent(Text)
    self.buyRect = buyArea:Find("BtnArea/Button")
    self.descObj:GetComponent(Text).text = TI18N("每日<color=#e8faff>21点</color>更新神秘商店")
    self.noticeBtn = buyArea:Find("OwnAsset1/AssetBg/Notice"):GetComponent(Button)

    self.setting = {
        noCheckRepeat = true,
        notAutoSelect = true,
        perWidth = 122,
        perHeight = 38,
        isVertical = false
    }
    self.max_result = 100
    self.numberpadSetting = {               -- 弹出小键盘的设置
        gameObject = self.countBtn.gameObject,
        min_result = 1,
        max_by_asset = self.max_result,
        max_result = self.max_result,
        textObject = self.countText,
        show_num = false,
        funcReturn = function() NoticeManager.Instance:FloatTipsByString(TI18N("请确认购买")) end,
        callback = self.updatePrice
    }

    self.tabList = {}
    self.openLevel = {}
    for k,v in pairs(self.model.dataTypeList[self.main].subList) do
        table.insert(self.tabList, {name = v.name, index = k, order = v.order, lev = (v.lev or 0), spriteFunc = v.spriteFunc, icon = v.icon, textures = v.textures})
    end
    table.sort(self.tabList, function(a,b) return a.order < b.order end)

    local obj = nil
    local rect = nil
    for i,v in ipairs(self.tabList) do
        self.openLevel[i] = v.lev
        v.obj = GameObject.Instantiate(self.tabCloner)
        v.obj.name = tostring(i)
        v.obj.transform:SetParent(self.tabContainer)
        v.obj.transform.localScale = Vector3.one
        v.obj.transform.localPosition = Vector3.zero
        v.imageLoader = SingleIconLoader.New(v.obj.transform:Find("Icon").gameObject)
        local obj = v.obj
        local sprite = self.assetWrapper:GetSprite(v.textures or AssetConfig.shop_textures, v.icon)
        if sprite == nil and v.spriteFunc == nil then
            obj.transform:Find("CenterText"):GetComponent(Text).text = v.name
            obj.transform:Find("CenterText").gameObject:SetActive(true)
            obj.transform:Find("Text").gameObject:SetActive(false)
            obj.transform:Find("Icon").gameObject:SetActive(false)
        else
            if v.spriteFunc ~= nil then
                v.spriteFunc(v.imageLoader)
            else
                v.imageLoader:SetOtherSprite(sprite)
            end
            obj.transform:Find("Text"):GetComponent(Text).text = v.name
            obj.transform:Find("CenterText").gameObject:SetActive(false)
            obj.transform:Find("Text").gameObject:SetActive(true)
            obj.transform:Find("Icon").gameObject:SetActive(true)
        end
    end
    self.tabCloner:SetActive(false)
    self.setting.openLevel = self.openLevel

    self.tabGroup = TabGroup.New(self.tabContainer, function(index) self:ChangeTab(index) end, self.setting)


    self.buyBtn.onClick:AddListener(function() self:OnBuy() end)
    self.rechargeBtn.onClick:AddListener(function() self:OnGoRecharge() end)
    self.countBtn.onClick:AddListener(function() self:OnNumberpad() end)
    self.addBtn.onClick:AddListener(function() self:AddOrMinus(1) end)
    self.minusBtn.onClick:AddListener(function() self:AddOrMinus(0) end)
    self.helpBtn.onClick:AddListener(function() self:OnHelp() end)

    self.frozen = FrozenButton.New(self.buyBtn.gameObject, {})
    self.rechargeFrozen = FrozenButton.New(self.refreshBtn.gameObject, {})

    self.helpBtn.transform.anchoredPosition = Vector2(-100, 192)
    self.refreshBtn.onClick:AddListener(function() self:OnDoRefresh() end)

    self.noticeBtn.onClick:AddListener(function() self:OnNotice() end)

    self.OnOpenEvent:Fire()
    self.fashionText.alignment = 7

    if BaseUtils.IsVerify then
        self.girlGuideObj.transform:Find("Girl").gameObject:SetActive(false)
    end
end

function ShopPanel:OnOpen()
    local model = self.model
    self:OnSelectItem()
    local currentSub = 1
    for i,v in ipairs(self.tabList) do
        if model.currentSub == v.index then
            currentSub = i
        end
    end
    self.tabGroup:ChangeTab(currentSub)

    self:RemoveListeners()
    self.mgr.onUpdateCurrency:AddListener(self.updateCurrencyListener)
    EventMgr.Instance:AddListener(event_name.role_asset_change, self.updateCurrencyListener)
    self.mgr.onUpdateRedPoint:AddListener(self.checkRedListener)
    self.mgr.onUpdateUnfreeze:AddListener(self.unfreezeListener)
    self.mgr.onUpdateBuyPanel:AddListener(self.refreshListener)

    if self.previewComp ~= nil then
        self.previewComp:Show()
    end

    self.mgr.onUpdateCurrency:Fire()
    self.mgr.onUpdateRedPoint:Fire()
end

function ShopPanel:RemoveListeners()
    self.mgr.onUpdateCurrency:RemoveListener(self.updateCurrencyListener)
    self.mgr.onUpdateRedPoint:RemoveListener(self.checkRedListener)
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.updateCurrencyListener)
    self.mgr.onUpdateUnfreeze:RemoveListener(self.unfreezeListener)
    self.mgr.onUpdateBuyPanel:RemoveListener(self.refreshListener)
end

function ShopPanel:OnHide()
    self:RemoveListeners()
    for _,v in pairs(self.subPanelList) do
        if v ~= nil then
            v:Hiden()
        end
    end
    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
    self.model.lastId = nil
end

function ShopPanel:ChangeTab(index)
    self.model.lastId = nil
    local panel = nil
    local currentIndex = nil
    if self.lastIndex ~= nil then
        panel = self.subPanelList[self.lastIndex]
    end
    if panel ~= nil then
        panel:Hiden()
    end
    currentIndex = self.tabList[index].index
    panel = self.subPanelList[currentIndex]
    if panel == nil then
        self.subPanelList[currentIndex] = ShopGoodsPanel.New(self.model, self.goodsPanel, self.main, currentIndex, function(data) self:OnSelectItem(data) end)
        panel = self.subPanelList[currentIndex]
    end
    self.lastIndex = currentIndex
    self.model.currentSub = currentIndex
    panel:Show()
    self.descObj:SetActive(self.main == 1 and currentIndex == 3)
    self.helpBtn.gameObject:SetActive(self.main == 2 and ShopManager.Instance.model.helpRPText[self.currentIndex] ~= nil)
    self:OnRefresh()
    if self.main == 1 and currentIndex == 3 then
        self.mgr:send13900()
    end
end

function ShopPanel:OnSelectItem(data)
    self.showData = data
    local model = self.model
    local shopModel = ShopManager.Instance.model
    local numHave = nil

    if data ~= nil and model.lastId == data.id then
        return
    end

    self.fashionShowObj:SetActive(false)
    if self.previewComp ~= nil then
        self.previewComp:HideCameraOnly()
    end

    if data == nil then
        self.goodsInfoObj:SetActive(false)
        self.girlGuideObj:SetActive(true)
        model.selectedInfo = nil
        shopModel.selectNum = 0
        self.countText.text = tostring(0)
        self.totalPriceText.text = "0"
        return
    else
        model.lastId = data.id
        self.countText.text = tostring(shopModel.selectNum)

        if data.discount ~= nil and data.discount ~= 1000 and data.discount > 0 then
            self.price = math.ceil(data.price * data.discount / 1000)
        else
            self.price = data.price
        end

        if data.tab == 1 and data.tab2 == 4 then
            self:OnSelectFashion(data)
            if #data.achievement_limit ~= 0 then
                -- self.fashionLeftBtn.gameObject:SetActive(true)
                self.fashionLeftBtn.gameObject:SetActive(false)
                self.fashionRightBtn.gameObject:SetActive(true)
                self:ShowFashionRightBtnEffect()
            else
                self.fashionLeftBtn.gameObject:SetActive(false)
                self.fashionRightBtn.gameObject:SetActive(false)
            end

            return
        end

        self.goodsInfoObj:SetActive(true)
        self.girlGuideObj:SetActive(false)
    end

    local key = BaseUtils.Key(data.tab, data.tab2, data.id)
    -- local data = DataShop.data_goods[key]
    local baseData = DataItem.data_get[data.base_id]

    if baseData == nil then
        Log.Error(string.format("找不到base_id=%s的物品基础数据", tostring(data.base_id)))
        return
    end

    -- 信息
    self.nameText.text = baseData.name
    if self.msgItemExt == nil then
        self.msgItemExt = MsgItemExt.New(self.descText, 216, 16, 21)
    end
    --BaseUtils.dump(baseData,"baseData")
    --BaseUtils.dump(data,"data")
    -- self.msgItemExt:SetData(string.gsub(ShopPanel.Convert(baseData), "<.->", ""), true)
    --self.msgItemExt:SetData(baseData.desc, true)
    local ddesc = BaseUtils.ReplacePattern(baseData)
    self.msgItemExt:SetData(ddesc, true)

    local height = 150

    if data ~= nil then
        -- 折扣
        self.priceObj:SetActive(data.discount ~= nil and data.discount ~= 1000)
        if data.discount ~= nil then
            self.discountText.text = tostring(math.ceil(data.discount / 10) / 10)
        end
        if data.discount ~= nil and data.discount ~= 1000 and data.discount > 0 then
            height = height - 50
            self.restraintRect.anchoredPosition = Vector2(15, -10 - 105)
        else
            self.restraintRect.anchoredPosition = Vector2(15, -70 - 100)
        end
        self.pricesText.text = data.price.."\n"..self.price
    else
        self.priceObj:SetActive(false)
        self.restraintRect.anchoredPosition = Vector2(15, -70 - 105)
    end

    -- 限购
    local privilegeNum = 0
    if data ~= nil and data.privilege_lev ~= nil and PrivilegeManager.Instance.lev >= data.privilege_lev and data.privilege_role[1] ~= nil and data.privilege_role[1].p_num ~= nil then
        local privilege_lev = PrivilegeManager.Instance.lev
        for i,v in ipairs(data.privilege_role) do
            if v.p_lev == privilege_lev then
                privilegeNum = v.p_num
            end
        end
    end
    ShopManager.Instance.model.itemBuyLimitList[data.id] = nil
    if data.limit_role ~= nil and data.limit_role ~= -1 then
        ShopManager.Instance.model.itemBuyLimitList[data.id] = data.limit_role + privilegeNum
    end
    if data ~= nil then
        if data.limit_role ~= -1 then
            height = height - 35
            if data.limit_type == "week" then
                self.restraintText.text = TI18N("每周限购: ")..tostring(data.limit_role + privilegeNum)..TI18N("个")
            elseif data.limit_type == "day" then
                self.restraintText.text = TI18N("每日限购: ")..tostring(data.limit_role + privilegeNum)..TI18N("个")
            elseif data.limit_type == "forever" then
                self.restraintText.text = TI18N("角色限购: ")..tostring(data.limit_role + privilegeNum)..TI18N("个")
            end

            if ShopManager.Instance.model.itemBuyLimitList[data.id] ~= nil then
                numHave = 0
                if ShopManager.Instance.model.hasBuyList ~= nil and ShopManager.Instance.model.hasBuyList[data.id] ~= nil then
                    numHave = ShopManager.Instance.model.hasBuyList[data.id]
                end
                if numHave ~= nil then
                    data.canBuyNum = ShopManager.Instance.model.itemBuyLimitList[data.id] - numHave
                end
            end
        elseif data.rencounter_lev ~= 0 then
            height = height - 35
            self.restraintText.text = string.format(TI18N("英雄擂台达到<color='#ffff00'>%s阶</color>可购买"), data.rencounter_lev)
        else
            self.restraintText.text = ""
        end
    else
        data.canBuyNum = 1
        self.restraintText.text = ""
    end

    self.scrollTrans.sizeDelta = Vector2(216, height)

    self.noticeBtn.gameObject:SetActive((data ~= nil and (data.assets_type == "star_gold_or_gold" or data.assets_type == "star_gold")) or (data ~= nil and (data.asset_type == 29255 or data.asset_type == 90026)))

    if (data ~= nil and (data.assets_type == "star_gold_or_gold" or data.assets_type == "star_gold" or data.assets_type == "gold"))
     or (data ~= nil and (data.asset_type == 29255 or data.asset_type == 90002 or data.asset_type == 90026)) then
        self.ownAsset1.gameObject:SetActive(true)
        self.ownCurrencyLoader1.gameObject:SetActive(true)
        self.ownCurrencyLoader1:SetSprite(SingleIconType.Item, DataItem.data_get[90026].icon)
        self.ownAssetText1.text = tostring(RoleManager.Instance.RoleData.star_gold)
        self.countTrans.anchoredPosition = Vector2(0, -15.98)
        self.totalPrice.anchoredPosition = Vector2(0, 46.3)
        self.ownAsset.anchoredPosition = Vector2(0, 15)
    else
        self.ownAsset1.gameObject:SetActive(false)
        self.countTrans.anchoredPosition = Vector2(0, -30)
        self.totalPrice.anchoredPosition = Vector2(0, 18.54)
        self.ownAsset.anchoredPosition = Vector2(0, -15.7)
    end

    -- 价格
    self:OnUpdateCurrency()
end

function ShopPanel:OnBuy()
    local data = ShopManager.Instance.model.selectedInfo
    if data == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择需要购买的物品"))
    elseif ShopManager.Instance.model.hasBuyList ~= nil and ShopManager.Instance.model.hasBuyList[data.id] ~= nil and ShopManager.Instance.model.itemBuyLimitList[data.id] ~= nil and (((data.tab ~= 1 or data.tab2 ~= 3) and ShopManager.Instance.model.hasBuyList[data.id] >= ShopManager.Instance.model.itemBuyLimitList[data.id]) or (data.tab == 1 and data.tab2 == 3 and data.flag == 1)) then
        NoticeManager.Instance:FloatTipsByString(TI18N("已经售罄"))
    elseif ShopManager.Instance.model.selectNum > 0 then
        if data.tab == 1 and data.tab2 == 3 then
            self.frozen:OnClick()
            ShopManager.Instance:send13901(data.id)
        else
            self.frozen:OnClick()
            ShopManager.Instance:send11303(data.id, ShopManager.Instance.model.selectNum)
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("最少购买一个"))
    end
end

function ShopPanel:OnUpdateCurrency(bool)
    local model = ShopManager.Instance.model
    if model.infoCurrencyType == nil then return end

    self.totalCurrencyLoader.gameObject.transform.sizeDelta = Vector2(28, 28)

    if model.infoCurrencyType == 29255 then
        self.totalCurrencyLoader.gameObject.transform.sizeDelta = Vector2(36, 36)
        self.totalCurrencyLoader:SetSprite(SingleIconType.Item, DataItem.data_get[model.infoCurrencyType].icon)
        self.ownCurrencyLoader:SetSprite(SingleIconType.Item, 90002)
    elseif GlobalEumn.CostTypeIconName[model.infoCurrencyType] == nil then
        self.totalCurrencyLoader:SetSprite(SingleIconType.Item, DataItem.data_get[model.infoCurrencyType].icon)
        self.ownCurrencyLoader:SetSprite(SingleIconType.Item, DataItem.data_get[model.infoCurrencyType].icon)
    else
        if model.infoCurrencyType == 90002 then
            self.totalCurrencyLoader:SetSprite(SingleIconType.Item, DataItem.data_get[model.infoCurrencyType].icon)
            self.ownCurrencyLoader:SetSprite(SingleIconType.Item, DataItem.data_get[model.infoCurrencyType].icon)
        else
            self.totalCurrencyLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..model.infoCurrencyType))
            self.ownCurrencyLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..model.infoCurrencyType))
        end
    end
    local ownNum = RoleManager.Instance.RoleData[self.mgr.assetIdToKey[model.infoCurrencyType]]
    ownNum = ownNum or 0

    self.ownAssetText.text = tostring(ownNum)

    if model.infoCurrencyType == 29255 then
        ownNum = RoleManager.Instance.RoleData.gold + RoleManager.Instance.RoleData.star_gold
        self.ownAssetText.text = tostring(RoleManager.Instance.RoleData.gold)
    elseif model.infoCurrencyType == 90026 then
        ownNum = RoleManager.Instance.RoleData.star_gold
    end

    if self.price ~= nil and model.selectedInfo ~= nil then
        if model.selectNum * self.price > ownNum then
            self.totalPriceText.text = "<color=#FF0000>"..tostring(self.price * model.selectNum).."</color>"
        else
            self.totalPriceText.text = tostring(self.price * model.selectNum)
        end
    else
        self.totalPriceText.text = "0"
    end

    self.noticeBtn.gameObject:SetActive(model.infoCurrencyType == 29255 or model.infoCurrencyType == 90026)

    if model.infoCurrencyType == 29255 or model.infoCurrencyType == 90002 or model.infoCurrencyType == 90026 then
        self.ownAsset1.gameObject:SetActive(true)
        self.ownCurrencyLoader1.gameObject:SetActive(true)
        self.ownCurrencyLoader1:SetSprite(SingleIconType.Item, DataItem.data_get[90026].icon)
        self.ownAssetText1.text = tostring(RoleManager.Instance.RoleData.star_gold)
        self.countTrans.anchoredPosition = Vector2(0, -15.98)
        self.totalPrice.anchoredPosition = Vector2(0, 46.3)
        self.ownAsset.anchoredPosition = Vector2(0, 15)
    else
        self.ownAsset1.gameObject:SetActive(false)
        self.countTrans.anchoredPosition = Vector2(0, -30)
        self.totalPrice.anchoredPosition = Vector2(0, 18.54)
        self.ownAsset.anchoredPosition = Vector2(0, -15.7)
    end

    if self.mgr.assetIdToKey[model.infoCurrencyType] ~= nil then
        self.totalCurrencyLoader.gameObject:SetActive(true)
        self.ownCurrencyLoader.gameObject:SetActive(true)
    end
end

function ShopPanel:OnNumberpad()
    local model = ShopManager.Instance.model
    if model.selectedInfo == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择需要购买的物品"))
    else
        local max_result = self.max_result
        local data = model.selectedInfo
        if data.tab == 1 and data.tab2 == 3 then
            max_result = 1
        else
            if model.itemBuyLimitList[data.id] ~= nil then

                local numHave = 0
                if model.hasBuyList ~= nil and model.hasBuyList[data.id] ~= nil then
                    numHave = model.hasBuyList[data.id]
                end
                if model.itemBuyLimitList[data.id] - numHave > 1 then
                    max_result = model.itemBuyLimitList[data.id] - numHave
                else
                    max_result = 1
                end
            end
        end
        self.numberpadSetting.max_result = max_result
        self.numberpadSetting.max_by_asset = max_result
        NumberpadManager.Instance:set_data(self.numberpadSetting)
    end
end

function ShopPanel.Convert(baseData)
    local ddesc = baseData.desc
    if baseData.step ~= nil and baseData.step ~= 0 then
        local step_data = DataSkillLife.data_fight_effect[string.format("%s_%s", baseData.base_id, baseData.step)]
        if step_data ~= nil then
            ddesc = string.gsub(ddesc, "%[skill_life1%]", tostring(step_data.args[1]))
            ddesc = string.gsub(ddesc, "%[skill_life2%]", tostring(step_data.args[2]))
        else
            ddesc = string.gsub(ddesc, "%[skill_life1%]", TI18N("一定"))
            ddesc = string.gsub(ddesc, "%[skill_life2%]", TI18N("一定"))
        end
    else
        ddesc = string.gsub(ddesc, "%[skill_life1%]", TI18N("一定"))
        ddesc = string.gsub(ddesc, "%[skill_life2%]", TI18N("一定"))
    end
    return ddesc
end

function ShopPanel:OnUpdatePrice()
    local model = ShopManager.Instance.model
    model.selectNum = NumberpadManager.Instance:GetResult()
    local price = model.uniPrice * model.selectNum
    local assets = 0
    if model.infoCurrencyType == 29255 then
        assets = RoleManager.Instance.RoleData.gold + RoleManager.Instance.RoleData.star_gold
    else
        assets = RoleManager.Instance.RoleData[self.mgr.assetIdToKey[model.infoCurrencyType]]
    end
    if price > assets then
        self.totalPriceText.text = "<color=#FF0000>"..tostring(price).."</color>"
    else
        self.totalPriceText.text = tostring(price)
    end
end

function ShopPanel:AddOrMinus(status)
    local model = ShopManager.Instance.model
    local num = model.selectNum
    local max_result = self.max_result
    local data = model.selectedInfo
    if data == nil then
        return
    elseif data.tab == 1 and data.tab2 == 3 then
        max_result = 1
    else
        if model.itemBuyLimitList[data.id] ~= nil then

            local numHave = 0
            if model.hasBuyList ~= nil and model.hasBuyList[data.id] ~= nil then
                numHave = model.hasBuyList[data.id]
            end
            if model.itemBuyLimitList[data.id] - numHave > 1 then
                max_result = model.itemBuyLimitList[data.id] - numHave
            else
                max_result = 1
            end
        end
    end
    if status == 1 then
        if num < max_result then
            num = num + 1
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("不能购买更多了"))
        end
    else
        if num > 1 then
            num = num - 1
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("最少买一个"))
        end
    end
    model.selectNum = num
    self.countText.text = tostring(model.selectNum)
    self:OnUpdateCurrency(false)
end

function ShopPanel:CheckRedPoint()
    local redPoint = self.mgr.redPoint[self.main]
    for k,v in pairs(self.tabGroup.buttonTab) do
        v.red:SetActive(redPoint[k] == true)
    end
end

function ShopPanel:OnHelp()
    local index = self.lastIndex
    if index == nil or index > 3 or index < 1 then
        index = 1
    end
    TipsManager.Instance:ShowText({gameObject = self.helpBtn.gameObject, itemData = ShopManager.Instance.model.helpRPText[self.lastIndex]})
end

function ShopPanel:OnUnfreeze()
    if self.frozen ~= nil then
        self.frozen:Release()
    end
    if self.rechargeFrozen ~= nil then
        self.rechargeFrozen:Release()
    end
end

function ShopPanel:OnSelectFashion(data)
    self.girlGuideObj:SetActive(false)
    self.goodsInfoObj:SetActive(false)
    self.fashionShowObj:SetActive(true)

    local baseData = DataItem.data_get[data.base_id]
    local roledata = RoleManager.Instance.RoleData

    local callback = function(composite)
        self:SetRawImage(composite)
    end

    local str = nil

    if DataFashion.data_cloth_face[tonumber(ShopManager.Instance.itemPriceTab[data.id].ext_args)] ~= nil then
        str = string.format(TI18N("颜值+<color='%s'>%s</color>"), ColorHelper.color[1], tostring(DataFashion.data_cloth_face[tonumber(ShopManager.Instance.itemPriceTab[ data.id].ext_args)].collect_val))
    else
        str = nil
    end
    if #baseData.effect == 0 then
        -- self.fashionText.text = ""
    else
        for i,v in ipairs(baseData.effect) do
            if v.effect_type == 28 then
                if str == nil then
                    str = string.format(TI18N("属性点<color='%s'>+%s</color>"), ColorHelper.color[1], tostring(v.val[1]))
                else
                    str = str .. string.format(TI18N("，属性点<color='%s'>+%s</color>"), ColorHelper.color[1], tostring(v.val[1]))
                end
                break
            end
        end
    end
    self.fashionText.text = str or ""

    local setting = {
        name = "ShopFashionRole"
        ,orthographicSize = 0.7
        ,width = 246
        ,height = 300
        ,offsetY = -0.352
        ,offsetX = -0.02
    }

    local myData = SceneManager.Instance:MyData()
    local unitData = BaseUtils.copytab(myData)
    local kvLooks = {}
    local roledata = RoleManager.Instance.RoleData
    for _,v in pairs(unitData.looks) do
        kvLooks[v.looks_type] = v
    end
    self.has_belt = false
    for k,v in pairs(baseData.effect[1].val) do
        local fashionData = DataFashion.data_base[v[1]]
        if (fashionData.classes == 0 or roledata.classes == fashionData.classes) and (fashionData.sex == 2 or roledata.sex == fashionData.sex) then
            kvLooks[fashionData.type] = {looks_str = "", looks_val = fashionData.model_id, looks_mode = fashionData.texture_id, looks_type = fashionData.type}
            if fashionData.type == SceneConstData.lookstype_belt then
                self.has_belt = true
            end
        end
    end
    self.temp_looks = {}
    for k,v in pairs(kvLooks) do
        table.insert(self.temp_looks, v)
    end

    local roledata = RoleManager.Instance.RoleData
    local modelData = {type = PreViewType.Role, classes = roledata.classes, sex = roledata.sex, looks = self.temp_looks}
    self.modleData = modelData
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
        self.previewComp:Show()
    end


    -- 价格
    self:OnUpdateCurrency()
end

function ShopPanel:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.previewContainer)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)

    if self.has_belt then
        composite.tpose.transform.localRotation = Quaternion.identity
        composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.Backward, 0))
    end

    self.previewContainer.gameObject:SetActive(true)
end

function ShopPanel:OnGoRecharge()
    local model = self.model
    if self.main == 1 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1})
    end
end

function ShopPanel:OnRefresh()
    local model = ShopManager.Instance.model
    if self.main == 1 then
        self.rechargeBtn.gameObject:SetActive(true)
        self.buyRect.anchoredPosition = Vector2(62, 0)
        if self.lastIndex == 3 and model.mysteryRefresh - model.mysteryRefreshed > 0 then
            self.descObj:GetComponent(Text).text = string.format(TI18N("今天可刷新次数:<color='#ffff00'>%s/%s</color>"), tostring(model.mysteryRefresh - model.mysteryRefreshed), tostring(model.mysteryRefresh))
            self.descObj.transform.anchoredPosition = Vector2(213.24, 193.8)
            self.refreshBtn.gameObject:SetActive(true)
        else
            self.descObj.transform.anchoredPosition = Vector2(265, 193.8)
            self.refreshBtn.gameObject:SetActive(false)
            self.descObj:GetComponent(Text).text = TI18N("每日<color=#e8faff>21点</color>更新神秘商店")
        end
    else
        self.rechargeBtn.gameObject:SetActive(false)
        self.refreshBtn.gameObject:SetActive(false)
        self.buyRect.anchoredPosition = Vector2(0, 0)
    end
end

function ShopPanel:OnDoRefresh()
    ShopManager.Instance:send13903()
    self.rechargeFrozen:OnClick()
end

function ShopPanel:OnNotice()
    TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {TI18N("<color='#00ff00'>优先使用</color>{assets_2, 90026}<color='#00ff00'>购买</color>")}})
end

function ShopPanel:ApplyFashionLeftBtn()
    local str = string.format("<color='#01F903'>星辰荣耀，专属于你！</color>\n本时装为荣耀玩家专属，成就积分<color='#ffff00'>≥%s点</color>可购买\n您的成就积分%s点，已享受%s折优惠",self.showData.achievement_limit[1].min,RoleManager.Instance.RoleData.achieve_score,self.showData.achievement_limit[1].discount/1000)
        local cdata = NoticeConfirmData.New()
        cdata.type = ConfirmData.Style.Sure
        cdata.content = str
        cdata.sureLabel = TI18N("确认")
        NoticeManager.Instance:ConfirmTips(cdata)
     NoticeManager.Instance:ConfirmTips(cdata)
end

function ShopPanel:ApplyFashionRightBtn()
    if self.modleData ~= nil then
        if self.shopRoleShowPanel == nil then
            self.shopRoleShowPanel = ShopRoleShowPanel.New(self.model,self.showParent)
        end
        print("skdjfklsdjfk3333333333333333333")
        self.shopRoleShowPanel:Show({self.modleData,self.showData})
    end
end

function ShopPanel:ShowFashionRightBtnEffect()
    if self.fashionRightBtnEffect == nil then
        local fun = function(effectView)
            local effectObject = effectView.gameObject

            effectObject.transform:SetParent(self.fashionRightBtn.transform)
            effectObject.transform.localScale = Vector3.one
            effectObject.transform.localPosition = Vector3(0, 10, -400)
            effectObject.transform.localRotation = Quaternion.identity

            Utils.ChangeLayersRecursively(effectObject.transform, "UI")

            self.fashionRightBtnEffect = effectView
        end
        self.fashionRightBtnEffect = BaseEffectView.New({effectId = 20409, time = nil, callback = fun})
    end
end