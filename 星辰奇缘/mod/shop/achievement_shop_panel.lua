AchievementShopPanel = AchievementShopPanel or BaseClass(BasePanel)

function AchievementShopPanel:__init(model, parent, main)
    self.model = model
    self.parent = parent
    self.main = main
    self.mgr = AchievementManager.Instance
    self.frozen = nil
    self.ChangeText = nil
    self.targetTime = nil
    self.ticker = nil

    local resList = {}
    for k,v in pairs(model.dataTypeList[self.main].subList) do
        if v ~= nil and v.textures ~= nil and resList[v.textures] == nil then
            resList[v.textures] = 1
        end
    end

    self.resList = {
        {file = AssetConfig.achievementshopbuypanel, type = AssetType.Main}
        , {file = AssetConfig.badge_icon, type = AssetType.Dep}  --徽章
        , {file = AssetConfig.photo_frame, type = AssetType.Dep}  --相框
        , {file = AssetConfig.teammark_icon, type = AssetType.Dep}  --队标
        , {file = AssetConfig.zonestyleicon, type = AssetType.Dep}  --主题图标
        , {file = AssetConfig.chat_prefix, type = AssetType.Dep}  --聊天前缀
        , {file = AssetConfig.petskinwindow_bg1, type = AssetType.Dep}
    }

    for k,v in pairs(resList) do
        table.insert(self.resList, {file = k, type = AssetType.Dep})
    end

    if resList[AssetConfig.achievementshop] == nil then
        table.insert(self.resList, {file = AssetConfig.achievementshop, type = AssetType.Dep})
    end

    self.subPanelList = {}

    self.infoObj = {}
    self.btnType = 1 --按钮状态，1.

    self.footEffect = {}
    self.footTimer = {}

    self.previewComp = nil

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.updateCurrencyListener = function() self:OnUpdateCurrency() end
    -- self.checkRedListener = function() self:CheckRedPoint() end
    self.levelChangeListener = function () self:OnLevelUp() end
    self.unfreezeListener = function() self:OnUnfreeze() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function AchievementShopPanel:__delete()
    if self.ticker ~= nil then
        LuaTimer.Delete(self.ticker)
    end
    self.ticker = nil
    self.OnHideEvent:Fire()
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.frozen ~= nil then
        self.frozen:DeleteMe()
        self.frozen = nil
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

    for i = 1, 3 do
        if self.footEffect[i] ~= nil then
            self.footEffect[i]:DeleteMe()
            self.footEffect[i] = nil
        end
        if self.footTimer[i] ~= nil then
            LuaTimer.Delete(self.footTimer[i])
        end
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function AchievementShopPanel:InitPanel()
    self.ticker = LuaTimer.Add(0, 450, function() self:OnTick() end)
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.achievementshopbuypanel))
    self.gameObject.name = "BuyPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.transform = self.gameObject.transform
    local t = self.transform
    local model = self.model

    self.goodsPanel = t:Find("GoodsPanel")
    self.tabCloner = t:Find("Button").gameObject
    self.tabContainer = t:Find("TopTabButtonGroup")
    self.infoArea = t:Find("InfoArea")

    self.girlGuideObj = self.infoArea:Find("GirlGuide").gameObject

    for i=1,6 do
        self.infoObj[i] = self.infoArea:Find("Info"..i).gameObject
        self.infoObj[i]:SetActive(false)
    end

    self.preview = self.infoArea:Find("Info4/Preview").gameObject

    self.helpBtn = t:Find("Help"):GetComponent(Button)

    self.assetsNumText = t:Find("NumBg/Text"):GetComponent(Text)
    self.totalPriceGameObject = t:Find("InfoArea/BuyPrice").gameObject
    self.totalPriceText = t:Find("InfoArea/BuyPrice/PriceBg/Price"):GetComponent(Text)
    self.totalCurrencyImage = t:Find("InfoArea/BuyPrice/PriceBg/Currency"):GetComponent(Image)
    self.buyBtn = t:Find("InfoArea/Button"):GetComponent(Button)

    self.setting = {
        noCheckRepeat = true,
        notAutoSelect = true,
        perWidth = 120,
        perHeight = 38,
        isVertical = true
    }
    self.max_result = 100

    self.tabList = {}
    self.openLevel = {}
    for k,v in pairs(model.dataTypeList[self.main].subList) do
        if v.lev ~= nil then
            table.insert(self.tabList, {name = v.name, index = k, order = v.order, lev = v.lev, icon = v.icon, textures = v.textures})
        else
            table.insert(self.tabList, {name = v.name, index = k, order = v.order, lev = 0, icon = v.icon, textures = v.textures})
        end
    end
    table.sort(self.tabList, function(a,b) return a.order < b.order end)

    local obj = nil
    local rect = nil
    for i,v in ipairs(self.tabList) do
        self.openLevel[i] = v.lev
        obj = GameObject.Instantiate(self.tabCloner)
        obj.name = tostring(i)
        obj.transform:SetParent(self.tabContainer)
        obj.transform.localScale = Vector3.one
        obj.transform.localPosition = Vector3.zero
        rect = obj:GetComponent(RectTransform)
        rect.anchoredPosition = Vector2((i - 1) * 90, 0)
        if v.icon == nil then
            obj.transform:Find("CenterText"):GetComponent(Text).text = v.name
            obj.transform:Find("CenterText").gameObject:SetActive(true)
            obj.transform:Find("Text").gameObject:SetActive(false)
            obj.transform:Find("Icon").gameObject:SetActive(false)
        else
            obj.transform:Find("Text"):GetComponent(Text).text = v.name
            if v.textures ~= nil then
                obj.transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(v.textures, v.icon)
            else
                obj.transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.achievementshop, v.icon)
            end
            obj.transform:Find("CenterText").gameObject:SetActive(false)
            obj.transform:Find("Text").gameObject:SetActive(true)
            obj.transform:Find("Icon").gameObject:SetActive(true)
        end
    end
    self.tabCloner:SetActive(false)
    -- self.setting.openLevel = openLevel

    self.tabGroup = TabGroup.New(self.tabContainer, function(index) self:ChangeTab(index) end, self.setting)


    self.buyBtn.onClick:AddListener(function() self:OnBuy() end)
    self.helpBtn.onClick:AddListener(function() self:OnHelp() end)

    self.frozen = FrozenButton.New(self.buyBtn.gameObject, {})

    self.OnOpenEvent:Fire()
end

function AchievementShopPanel:OnOpen()
    self.tabGroup:ChangeTab(self.model.shop_currentSub)

    self:OnLevelUp()

    self:RemoveListeners()
    self.mgr.onUpdateCurrency:AddListener(self.updateCurrencyListener)
    EventMgr.Instance:AddListener(event_name.role_asset_change, self.updateCurrencyListener)
    EventMgr.Instance:AddListener(event_name.role_level_change, self.levelChangeListener)
    -- self.mgr.onUpdateRedPoint:AddListener(self.checkRedListener)
    self.mgr.onUpdateUnfreeze:AddListener(self.unfreezeListener)

    self.mgr.onUpdateCurrency:Fire()
    -- self.mgr.onUpdateRedPoint:Fire()
end

function AchievementShopPanel:RemoveListeners()
    self.mgr.onUpdateCurrency:RemoveListener(self.updateCurrencyListener)
    -- self.mgr.onUpdateRedPoint:RemoveListener(self.checkRedListener)
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.updateCurrencyListener)
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.levelChangeListener)
    self.mgr.onUpdateUnfreeze:RemoveListener(self.unfreezeListener)
end

function AchievementShopPanel:OnHide()
    self:RemoveListeners()
    for _,v in pairs(self.subPanelList) do
        if v ~= nil then
            v:Hiden()
        end
    end
end

function AchievementShopPanel:ChangeTab(index)
    local panel = nil
    local currentIndex = nil
    if self.lastIndex ~= nil then
        currentIndex = self.tabList[self.lastIndex].index
        panel = self.subPanelList[currentIndex]
    end
    if panel ~= nil then
        panel:Hiden()
    end
    currentIndex = self.tabList[index].index
    panel = self.subPanelList[currentIndex]
    if panel == nil then
        self.subPanelList[currentIndex] = AchievementShopGoodsPanel.New(self.model, self.goodsPanel, self.main, currentIndex, function(data) self:OnSelectItem(data) end)
        panel = self.subPanelList[currentIndex]
    end
    self.lastIndex = currentIndex
    self.model.shop_currentSub = currentIndex
    panel:Show()
    -- self:OnSelectItem()
    self.helpBtn.gameObject:SetActive(self.main == 2)
end

function AchievementShopPanel:OnSelectItem(data)
    local model = self.model
    local numHave = nil

    if data == nil then
        for k,v in pairs(self.infoObj) do
            v:SetActive(false)
        end
        self.girlGuideObj:SetActive(true)
        self.buyBtn.gameObject:SetActive(false)
        self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = ""
        model.selectedInfo = nil
        model.selectNum = 0
        self.totalPriceText.text = "0"
        return
    else
        local infoObj = self.infoObj[1]
        local shopData = DataAchieveShop.data_list[data.id]
        if shopData.goods_type == 1 then
            infoObj = self.infoObj[1]
            self:updateItemInfo1(infoObj, data, shopData)
        elseif shopData.goods_type == 2 then
            infoObj = self.infoObj[1]
            self:updateItemInfo1(infoObj, data, shopData)
        elseif shopData.goods_type == 3 then
            infoObj = self.infoObj[2]
            self:updateItemInfo2(infoObj, data, shopData)
        elseif shopData.goods_type == 4 then
            infoObj = self.infoObj[3]
            self:updateItemInfo3(infoObj, data, shopData)
        elseif shopData.goods_type == 5 then
            infoObj = self.infoObj[4]
            self:updateItemInfo4(infoObj, data, shopData)
        elseif shopData.goods_type == 6 then
            infoObj = self.infoObj[5]
            self:updateItemInfo5(infoObj, data, shopData)
        elseif shopData.goods_type == 8 then
            infoObj = self.infoObj[6]
            self:updateItemInfo6(infoObj, data, shopData)
        end

        for k,v in pairs(self.infoObj) do
            v:SetActive(false)
        end
        infoObj:SetActive(true)
        self.girlGuideObj:SetActive(false)
        -- self.buyBtn.gameObject:SetActive(true)
    end

    -- 价格
    self:OnUpdateCurrency()
end

function AchievementShopPanel:OnBuy()
    local data = self.model.selectedInfo
    if data ~= nil then
        if self.btnType == 1 then
            AchievementManager.Instance:Send10227(data.id)
        elseif self.btnType == 2 then
            ZoneManager.Instance:OpenSelfZone()
        elseif self.btnType == 3 then
            ChatManager.Instance:Send10415(data.id)
        elseif self.btnType == 4 then
            TeamManager.Instance:Send11734(data.id)
        elseif self.btnType == 5 then
            NoticeManager.Instance:FloatTipsByString(TI18N("使用中，创建队伍后可见{face_1,36}"))
        elseif self.btnType == 6 then
            NoticeManager.Instance:FloatTipsByString(TI18N("使用中，战斗中说话可见{face_1,25}"))
        elseif self.btnType == 7 then
            -- NoticeManager.Instance:FloatTipsByString(TI18N("使用中，聊天框中可见{face_1,25}"))
            AchievementManager.Instance:Send10422(6)
        elseif self.btnType == 8 then
            AchievementManager.Instance:Send10422(data.id)
        elseif self.btnType == 9 then
            AchievementManager.Instance:Send10422(8)
        end
    end
    -- local data = self.model.selectedInfo
    -- local model = self.model
    -- if data == nil then
    --     NoticeManager.Instance:FloatTipsByString(TI18N("请选择需要购买的物品"))
    -- elseif model.hasBuyList ~= nil and model.hasBuyList[data.id] ~= nil and (((data.tab ~= 1 or data.tab2 ~= 3) and model.hasBuyList[data.id] >= model.itemBuyLimitList[data.id]) or (data.tab == 1 and data.tab2 == 3 and data.flag == 1)) then
    --     NoticeManager.Instance:FloatTipsByString(TI18N("已经售罄"))
    -- elseif self.model.selectNum > 0 then
    --     if data.tab == 1 and data.tab2 == 3 then
    --         self.frozen:OnClick()
    --         ShopManager.Instance:send13901(data.id)
    --     else
    --         self.frozen:OnClick()
    --         ShopManager.Instance:send11303(data.id, self.model.selectNum)
    --     end
    -- else
    --     NoticeManager.Instance:FloatTipsByString(TI18N("最少购买一个"))
    -- end
end

function AchievementShopPanel:OnUpdateCurrency()
    local model = self.model
    -- self.totalCurrencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[model.infoCurrencyType])
    self.totalCurrencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90008")
    -- local ownNum = RoleManager.Instance.RoleData[self.mgr.assetIdToKey[model.infoCurrencyType]]
    local ownNum = RoleManager.Instance.RoleData.achieve_score
    self.assetsNumText.text = string.format("%s/%s", ownNum, model.achNum)

    local price = self.model.uniPrice
    if price ~= nil and model.selectedInfo ~= nil then
        if price > ownNum then
            self.totalPriceText.text = string.format("<color=#FF0000>%s</color>", price)
        else
            self.totalPriceText.text = tostring(price)
        end
    else
        self.totalPriceText.text = "0"
    end

    if self.mgr.assetIdToKey[model.infoCurrencyType] ~= nil then
        self.totalCurrencyImage.gameObject:SetActive(true)
    end
end

function AchievementShopPanel:AddOrMinus(status)
    local model = self.model
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
    -- self.totalPriceText.text = tostring(self.model.uniPrice * self.model.selectNum)
    self:OnUpdateCurrency()
end

function AchievementShopPanel:CheckRedPoint()
    -- local redPoint = self.mgr.redPoint[self.main]
    -- for k,v in pairs(self.tabGroup.buttonTab) do
    --     v.red:SetActive(redPoint[k] == true)
    -- end
end

function AchievementShopPanel:OnHelp()
    local index = self.lastIndex
    if index == nil or index > 3 or index < 1 then
        index = 1
    end
    TipsManager.Instance:ShowText({gameObject = self.helpBtn.gameObject, itemData = self.model.helpRPText[self.lastIndex]})
end

function AchievementShopPanel:OnLevelUp()
    local lev = RoleManager.Instance.RoleData.lev

    for k,v in pairs(self.tabGroup.buttonTab) do
        if v ~= nil and self.openLevel[k] ~= nil then
            v.gameObject:SetActive(lev >= self.openLevel[k])
        end
    end
end

function AchievementShopPanel:OnUnfreeze()
    if self.frozen ~= nil then
        self.frozen:Release()
    end
end

function AchievementShopPanel:updateItemInfo1(infoObj, data, shopData)
    self.ChangeText = nil
    self.targetTime = nil
    if shopData.goods_type == 1 then
        infoObj.transform:Find("Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.zonestyleicon, tostring(shopData.source_id))
    else
        infoObj.transform:Find("Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.photo_frame, string.format("icon%s", shopData.source_id))
    end
    infoObj.transform:Find("Name"):GetComponent(Text).text = shopData.name
    if self.msgItemExt ~= nil then self.msgItemExt:DeleteMe() end
    self.msgItemExt = MsgItemExt.New(infoObj.transform:Find("Describe"):GetComponent(Text), 218, 16, 20)
    self.msgItemExt:SetData(shopData.desc, true)
    infoObj.transform:Find("Type"):GetComponent(Text).text = shopData.type_name

    if data.state == 0 then
        if shopData.selling == 0 then
            self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = "\n"..shopData.condition
            self.buyBtn.gameObject:SetActive(false)
        else
            self.buyBtn.gameObject:SetActive(true)
            self.btnType = 1
            self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = TI18N("未拥有")
            self.buyBtn.gameObject.transform:Find("Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton3Str, TI18N("兑 换"))
            self.buyBtn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            BaseUtils.SetGrey(self.buyBtn.gameObject:GetComponent(Image), false)
        end
    elseif data.state == 1 then
        self.btnType = 2
        self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = TI18N("已拥有")
        self.buyBtn.gameObject.transform:Find("Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton3Str, TI18N("前往空间使用"))
        self.buyBtn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        BaseUtils.SetGrey(self.buyBtn.gameObject:GetComponent(Image), false)
        if data.expire ~= nil and data.expire ~= 0 then
            self.ChangeText = self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text)
            self.targetTime = data.expire
        end
    end

    self.totalPriceGameObject:SetActive(true)
end

function AchievementShopPanel:updateItemInfo2(infoObj, data, shopData)
    self.ChangeText = nil
    self.targetTime = nil
    infoObj.transform:Find("Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.badge_icon,tostring(DataAchieveShop.data_list[ZoneManager.Instance:ResIdToId(shopData.source_id)].source_id))

    infoObj.transform:Find("Name"):GetComponent(Text).text = shopData.name
    if self.msgItemExt ~= nil then self.msgItemExt:DeleteMe() end
    self.msgItemExt = MsgItemExt.New(infoObj.transform:Find("Describe"):GetComponent(Text), 218, 16, 20)
    self.msgItemExt:SetData(shopData.desc, true)
    infoObj.transform:Find("Type"):GetComponent(Text).text = shopData.type_name

    infoObj.transform:Find("Condition"):GetComponent(Text).text = string.format(TI18N("获得条件：%s"), shopData.condition)

    if data.state == 0 then
        if shopData.selling == 0 then
            self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = "\n"..shopData.condition
            self.buyBtn.gameObject:SetActive(false)
        else
            self.buyBtn.gameObject:SetActive(true)
            self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = TI18N("未拥有")
        end
    elseif data.state == 1 then
        self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = TI18N("已拥有")
        if data.expire ~= nil and data.expire ~= 0 then
            self.ChangeText = self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text)
            self.targetTime = data.expire
        end
    end
    self.btnType = 2
    self.buyBtn.gameObject.transform:Find("Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton3Str, TI18N("前往空间使用"))
    self.buyBtn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    BaseUtils.SetGrey(self.buyBtn.gameObject:GetComponent(Image), false)

    self.totalPriceGameObject:SetActive(false)

    local badge_data = self.model:getBadgeDataById(shopData.id)
    if badge_data ~= nil then
        if badge_data.star == 0 then
            infoObj.transform:FindChild("Star").gameObject:SetActive(false)
        else
            infoObj.transform:FindChild("Star").gameObject:SetActive(true)
            local star = badge_data.star + 1
            for i=1,star - 1 do
                infoObj.transform:FindChild("Star/"..i).gameObject:SetActive(true)
            end
            if star < 4 then
                for i=star,3 do
                    infoObj.transform:FindChild("Star/"..i).gameObject:SetActive(false)
                end
            end
        end
    else
        infoObj.transform:FindChild("Star").gameObject:SetActive(false)
    end
end

function AchievementShopPanel:updateItemInfo3(infoObj, data, shopData)
    self.ChangeText = nil
    self.targetTime = nil
    local cfg_data
    for i,v in ipairs(DataFriendZone.data_bubble) do
        if v.id == data.source_id then
            cfg_data = v
        end
    end
    if cfg_data ~= nil then
        local r,g,b = CombatUtil.TryParseHtmlString("#"..cfg_data.color)
        infoObj.transform:Find("Image"):GetComponent(Image).color = Color(r/255,g/255,b/255)
        if cfg_data.outcolor ~= "" then
            local r,g,b = CombatUtil.TryParseHtmlString("#"..cfg_data.outcolor)

            if infoObj.transform:Find("Image"):GetComponent(Outline) == nil then
                infoObj.transform:Find("Image").gameObject:AddComponent(Outline)
            end
            infoObj.transform:Find("Image"):GetComponent(Outline).effectColor = Color(r/255,g/255,b/255)
            infoObj.transform:Find("Image"):GetComponent(Outline).effectDistance = Vector2(3, -3)
            infoObj.transform:Find("Image"):GetComponent(Outline).enabled = true
        else
            if infoObj.transform:Find("Image"):GetComponent(Outline) ~= nil then
                infoObj.transform:Find("Image"):GetComponent(Outline).enabled = false
            end
        end
        for i,v in ipairs(cfg_data.location) do
            local spriteid = tostring(v[1])
            local x = v[2]
            local y = v[3]
            local item = infoObj.transform:Find("Image"):Find(tostring(i))
            local sprite = PreloadManager.Instance:GetSprite(AssetConfig.bubble_icon, spriteid)
            local img = item.transform:GetComponent(Image)
            img.sprite = sprite
            img:SetNativeSize()
            item.transform.anchoredPosition = Vector2(x,y)
            item.gameObject:SetActive(true)
            if cfg_data.id == 30016 and i == 1 then
                    item.transform.sizeDelta = Vector2(50,60)
                end
        end
        for i = #cfg_data.location+1, 2 do
            local item = infoObj.transform:Find("Image"):Find(tostring(i))
            item.gameObject:SetActive(false)
        end
    end

    infoObj.transform:Find("Type"):GetComponent(Text).color = ColorHelper.DefaultButton8
    infoObj.transform:Find("Describe"):GetComponent(Text).color = ColorHelper.DefaultButton8

    infoObj.transform:Find("Name"):GetComponent(Text).text = shopData.name
    if self.msgItemExt ~= nil then self.msgItemExt:DeleteMe() end
    self.msgItemExt = MsgItemExt.New(infoObj.transform:Find("Describe"):GetComponent(Text), 218, 16, 20)
    self.msgItemExt:SetData(shopData.desc, true)
    infoObj.transform:Find("Type"):GetComponent(Text).text = shopData.type_name

    if data.state == 0 then
        if shopData.selling == 0 then
            self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = "\n"..shopData.condition
            self.buyBtn.gameObject:SetActive(false)
        else
            self.buyBtn.gameObject:SetActive(true)
            self.btnType = 1
            self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = TI18N("未拥有")
            self.buyBtn.gameObject.transform:Find("Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton3Str, TI18N("兑 换"))
            self.buyBtn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            BaseUtils.SetGrey(self.buyBtn.gameObject:GetComponent(Image), false)
        end
    elseif data.state == 1 then
        if ChatManager.Instance.model.bubble_id ~= data.id then
            self.btnType = 3
            self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = TI18N("已拥有")
            self.buyBtn.gameObject.transform:Find("Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton3Str, TI18N("使 用"))
            self.buyBtn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            BaseUtils.SetGrey(self.buyBtn.gameObject:GetComponent(Image), false)
        else
            self.btnType = 6
            self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = ""
            self.buyBtn.gameObject.transform:Find("Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton1Str, TI18N("使用中"))
            self.buyBtn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            BaseUtils.SetGrey(self.buyBtn.gameObject:GetComponent(Image), true)
        end
        if data.expire ~= nil and data.expire ~= 0 then
            self.ChangeText = self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text)
            self.targetTime = data.expire
        end
    end

    self.totalPriceGameObject:SetActive(true)
end

function AchievementShopPanel:updateItemInfo4(infoObj, data, shopData)
    self.ChangeText = nil
    self.targetTime = nil
    local callback = function(composite)
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(self.preview.transform)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        self.preview:SetActive(true)

        self.previewComp = composite
        self:showmodeleffect(shopData.source_id)
    end
    local setting = {
        name = "AchievementShopPanel"
        ,orthographicSize = 0.7
        ,width = 250
        ,height = 250
        ,offsetY = -0.65
    }
    local llooks = {}
    local mySceneData = SceneManager.Instance:MyData()
    if mySceneData ~= nil then
        llooks = mySceneData.looks
    end
    local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = llooks}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        -- self.previewComp:Reload(modelData, callback)
        self:showmodeleffect(shopData.source_id)
    end
    -- infoObj.transform:Find("Name"):GetComponent(Text).text = shopData.name
    -- if self.msgItemExt ~= nil then self.msgItemExt:DeleteMe() end
    -- self.msgItemExt = MsgItemExt.New(infoObj.transform:Find("Describe"):GetComponent(Text), 218, 16, 20)
    -- self.msgItemExt:SetData(shopData.desc, true)
    -- infoObj.transform:Find("Type"):GetComponent(Text).text = shopData.type_name

    self.buyBtn.gameObject:SetActive(true)
    if data.state == 0 then
        if shopData.selling == 0 then
            self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = "\n"..shopData.condition
            self.buyBtn.gameObject:SetActive(false)
        else
            self.buyBtn.gameObject:SetActive(true)
            self.btnType = 1
            self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = TI18N("未拥有")
            self.buyBtn.gameObject.transform:Find("Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton3Str, TI18N("兑 换"))
            self.buyBtn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            BaseUtils.SetGrey(self.buyBtn.gameObject:GetComponent(Image), false)
        end
    elseif data.state == 1 then
        if TeamManager.Instance.model.team_mark ~= data.id then
            self.btnType = 4
            self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = TI18N("已拥有")
            self.buyBtn.gameObject.transform:Find("Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton3Str, TI18N("使 用"))
            self.buyBtn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            BaseUtils.SetGrey(self.buyBtn.gameObject:GetComponent(Image), false)
        else
            self.btnType = 5
            self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = ""
            self.buyBtn.gameObject.transform:Find("Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton1Str, TI18N("使用中"))
            self.buyBtn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            BaseUtils.SetGrey(self.buyBtn.gameObject:GetComponent(Image), true)
        end
        if data.expire ~= nil and data.expire ~= 0 then
            self.ChangeText = self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text)
            self.targetTime = data.expire
        end
    end

    self.totalPriceGameObject:SetActive(true)
end

function AchievementShopPanel:updateItemInfo5(infoObj, data, shopData)
    self.ChangeText = nil
    self.targetTime = nil
    infoObj.transform:Find("Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.chat_prefix, tostring(shopData.source_id))
    infoObj.transform:Find("Image"):GetComponent(Image):SetNativeSize()

    infoObj.transform:Find("Name"):GetComponent(Text).text = shopData.name
    if self.msgItemExt ~= nil then self.msgItemExt:DeleteMe() end
    self.msgItemExt = MsgItemExt.New(infoObj.transform:Find("Describe"):GetComponent(Text), 218, 16, 20)
    self.msgItemExt:SetData(shopData.desc, true)
    infoObj.transform:Find("Type"):GetComponent(Text).text = shopData.type_name

    infoObj.transform:Find("Condition"):GetComponent(Text).text = string.format(TI18N("获得条件：%s"), shopData.condition)

    if data.state == 0 then
        if shopData.selling == 0 then
            self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = "\n"..shopData.condition
            self.buyBtn.gameObject:SetActive(false)
        else
            self.buyBtn.gameObject:SetActive(true)
            self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = TI18N("未拥有")
        end
    elseif data.state == 1 then
        self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = TI18N("已拥有")
        if data.expire ~= nil and data.expire ~= 0 then
            self.ChangeText = self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text)
            self.targetTime = data.expire
        end
    end
    if data.state == 0 then
        self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = "\n"..shopData.condition
        self.buyBtn.gameObject:SetActive(false)
    else
        self.buyBtn.gameObject:SetActive(true)
        if ChatManager.Instance.model.prefix_id ~= data.id then
            self.btnType = 8
            self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = TI18N("已拥有")
            self.buyBtn.gameObject.transform:Find("Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton3Str, TI18N("使 用"))
            self.buyBtn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            BaseUtils.SetGrey(self.buyBtn.gameObject:GetComponent(Image), false)
        else
            self.btnType = 7
            self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = ""
            self.buyBtn.gameObject.transform:Find("Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton1Str, TI18N("取消使用"))
            self.buyBtn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            BaseUtils.SetGrey(self.buyBtn.gameObject:GetComponent(Image), false)
        end
    end
    self.totalPriceGameObject:SetActive(false)
end

function AchievementShopPanel:updateItemInfo6(infoObj, data, shopData)
    self.ChangeText = nil
    self.targetTime = nil

    infoObj.transform:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.petskinwindow_bg1, "ChildSkinBg1")
    infoObj.transform:Find("Bg").gameObject:SetActive(true)
    local foot_source_id = shopData.source_id
    for i = 1, 3 do
        if self.footEffect[i] ~= nil then
            self.footEffect[i]:DeleteMe()
            self.footEffect[i] = nil
        end
        if self.footTimer[i] ~= nil then
            LuaTimer.Delete(self.footTimer[i])
        end
        if self.footEffect[i] == nil then
            local fun = function(effectView)
                local effectObject = effectView.gameObject
                effectObject.name = "Effect"..i
                effectObject.transform:SetParent(infoObj.transform)
                effectObject.transform.localScale = Vector3(0.4,0.4,0.4)
                effectObject.transform.localPosition = Vector3(90*(i-2) , 20*i-150, -400)
                effectObject.transform.localRotation = Quaternion.Euler(340,0,0)
                Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                effectObject:SetActive(false)
                self.footTimer[i] = LuaTimer.Add(500* i, 2000, function() 
                    effectObject:SetActive(false)
                    effectObject:SetActive(true)
                end)
            end
            self.footEffect[i] = BaseEffectView.New({effectId = foot_source_id, time = nil, callback = fun})
        end
    end

    infoObj.transform:Find("Condition"):GetComponent(Text).text = string.format(TI18N("获得条件：%s"), shopData.condition)

    if data.state == 0 then
        if shopData.selling == 0 then
            self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = "\n"..shopData.condition
            self.buyBtn.gameObject:SetActive(false)
        else
            self.buyBtn.gameObject:SetActive(true)
            self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = TI18N("未拥有")
        end
    elseif data.state == 1 then
        self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = TI18N("已拥有")
        if data.expire ~= nil and data.expire ~= 0 then
            self.ChangeText = self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text)
            self.targetTime = data.expire
        end
    end

    if data.state == 0 then
        self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = "\n"..shopData.condition
        self.buyBtn.gameObject:SetActive(false)
    else
        self.buyBtn.gameObject:SetActive(true)
        if RoleManager.Instance.foot_mark_id ~= data.id then
            self.btnType = 8
            self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = TI18N("已拥有")
            self.buyBtn.gameObject.transform:Find("Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton3Str, TI18N("使 用"))
            self.buyBtn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            BaseUtils.SetGrey(self.buyBtn.gameObject:GetComponent(Image), false)
        else
            self.btnType = 9
            self.gameObject.transform:Find("InfoArea/StateText"):GetComponent(Text).text = ""
            self.buyBtn.gameObject.transform:Find("Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton1Str, TI18N("取消使用"))
            self.buyBtn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            BaseUtils.SetGrey(self.buyBtn.gameObject:GetComponent(Image), false)
        end
    end
    self.totalPriceGameObject:SetActive(false)
end


function AchievementShopPanel:showmodeleffect(effectid)
    if self.previewComp ~= nil and self.previewComp.tpose ~= nil then
        local fun = function(effectView)
            local effectObject = effectView.gameObject

            effectObject.transform:SetParent(self.previewComp.tpose.transform)
            effectObject.transform.localScale = Vector3.one
            effectObject.transform.localPosition = Vector3 (0, 1, 0)
            effectObject.transform.localRotation = Quaternion.identity

            effectObject.transform:SetParent(PreviewManager.Instance.container.transform)

            Utils.ChangeLayersRecursively(effectObject.transform, "ModelPreview")

            self.modeleffect = effectView
        end
        if self.modeleffect ~= nil then
            self.modeleffect:DeleteMe()
            self.modeleffect = nil
        end
        self.modeleffect = BaseEffectView.New({effectId = effectid, callback = fun})
    end
end

function AchievementShopPanel:OnTick()
    if self.ChangeText ~= nil and self.targetTime ~= nil then
        local str = ""
        local timegap = self.targetTime - BaseUtils.BASE_TIME
        if timegap > 3600*24 then
            str = BaseUtils.formate_time_gap(timegap, nil, 1, BaseUtils.time_formate.DAY)
        elseif  timegap > 3600 then
            str = BaseUtils.formate_time_gap(timegap, nil, 1, BaseUtils.time_formate.HOUR)
        elseif timegap > 60 then
            str = BaseUtils.formate_time_gap(timegap, nil, 1, BaseUtils.time_formate.MIN)
        elseif timegap > 0 then
            str = BaseUtils.formate_time_gap(timegap, nil, 1, BaseUtils.time_formate.SEC)
        else
            str = TI18N("未拥有")
        end
        if timegap > 0 then
            str = string.format(TI18N("剩余:%s"), str)
        end
        self.ChangeText.text = str
    end
end
