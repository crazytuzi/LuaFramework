-- ----------------------------------------------------------
-- UI - 元素副本窗口
-- ljh 20161215
-- ----------------------------------------------------------
NotNamedTreasureWindow = NotNamedTreasureWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function NotNamedTreasureWindow:__init(model)
    self.model = model
    self.name = "NotNamedTreasureWindow"
    self.windowId = WindowConfig.WinID.notnamedtreasurewindow
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        { file = AssetConfig.notnamedtreasurewindow, type = AssetType.Main }
        ,{ file = AssetConfig.bigatlas_open_beta_bg3, type = AssetType.Main }
        ,{ file = AssetConfig.notnamedtreasure_textures, type = AssetType.Dep }
        ,{ file = AssetConfig.open_beta_textures, type = AssetType.Dep }
        ,{ file = AssetConfig.sing_res, type = AssetType.Dep }
        , {file = AssetConfig.turnpalte_bg1, type = AssetConfig.Main}
    }

    self.gameObject = nil
    self.transform = nil

    -- self.titleText = nil
    self.titleImage = nil

    self.descText = nil
    self.descText1 = nil
    self.descText2 = nil
    self.descText3 = nil

    self.keyImageTransform = nil
    self.keyNumText = nil

    ------------------------------------------------
    self.currentType = 62320
    self.uint_id = 0

    self.slowDownList = { }

    self.itemList = { }
    self.btnList = { }
    self.iconList = { }
    self.rewardList = { }

    self.num = 8
    self.radius = 150
    self.count = 0
    self.step = 0

    self.turnItems = { }
    self.totalTurnItems = { }
    self.typeToIndex = { }
    self.items = { }

    self.timerId = nil
    self.hasOpen = false

    self.priceByBaseid = { }
    ------------------------------------------------
    self._Update = function(item_type_id)
        if item_type_id == nil then
            self:Update()
        else
            self:Go()
            self:GetIndex(self.currentType, item_type_id)
        end
    end

    self._QuickBuyReturn = function(priceByBaseid)
        self:QuickBuyReturn(priceByBaseid)
    end
    ------------------------------------------------

    self.OnOpenEvent:Add( function() self:OnShow() end)
    self.OnHideEvent:Add( function() self:OnHide() end)

    self.loaders = { }
end

function NotNamedTreasureWindow:__delete()
    if self.itemSlot ~= nil then
        self.itemSlot:DeleteMe()
        self.itemSlot = nil
    end
    self:OnHide()

    for k, v in pairs(self.loaders) do
        v:DeleteMe()
    end
    self.loaders = nil

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil

        NotNamedTreasureManager.Instance:Send18202()
    end
    if self.itemSlot ~= nil then
        self.itemSlot:DeleteMe()
    end
    self.itemSlot = nil
    if self.iconList ~= nil then
        for i, v in ipairs(self.iconList) do
            v.sprite = nil
        end
        self.iconList = nil
    end

    if self.rewardList ~= nil then
        for _, v in pairs(self.rewardList) do
            if v ~= nil then
                if v.grid ~= nil then
                    v.grid:DeleteMe()
                end
                if v.layout ~= nil then
                    v.layout:DeleteMe()
                end
            end
        end
        self.rewardList = nil
    end
    if self.buttonEffect ~= nil then
        self.buttonEffect:DeleteMe()
        self.buttonEffect = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function NotNamedTreasureWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.notnamedtreasurewindow))
    self.gameObject.name = "NotNamedTreasureWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("Close"):GetComponent(Button)
    self.closeBtn.onClick:AddListener( function() self:OnClickClose() end)

    UIUtils.AddBigbg(self.mainTransform:Find("Panel/Turnplate"), GameObject.Instantiate(self:GetPrefab(AssetConfig.turnpalte_bg1)))

    -- UIUtils.AddBigbg(self.mainTransform:Find("Panel/Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_open_beta_bg3)))

    self.turnplate = self.mainTransform:Find("Panel/Turnplate")
    local itemContainer = self.mainTransform:Find("Panel/Container")
    self.rewardBtn = self.mainTransform:Find("Panel/RewardButton"):GetComponent(Button)

    for i = 1, itemContainer.childCount do
        self.itemList[i] = itemContainer:GetChild(i - 1)
        self.iconList[i] = self.itemList[i]:Find("Icon"):GetComponent(Image)
        self.btnList[i] = self.itemList[i]:GetComponent(Button)
    end

    self:SetItemsPosition(math.pi / 8)
    self.buttonImageTransform = self.mainTransform:Find("Panel/Pointer/OkButton")
    self.turnBtn = self.mainTransform:Find("Panel/Pointer"):GetComponent(Button)
    self.turnBtn.onClick:AddListener( function() self:OnTurn() end)
    self.rewardBtn.onClick:AddListener( function() self:OnRewardPreview() end)

    -- self.buybutton = BuyButton.New(self.buttonImageTransform.gameObject, TI18N("合 成"), WindowConfig.WinID.backpack)

    ----------------------------

    self.itemSlot = ItemSlot.New()
    UIUtils.AddUIChild(self.mainTransform:Find("Panel/Item").gameObject, self.itemSlot.gameObject)

    self.itemText = self.mainTransform:Find("Panel/Item/Text"):GetComponent(Text)

    -- self.titleText = self.mainTransform:Find("Title/Text"):GetComponent(Text)
    self.titleImage = self.mainTransform:Find("Panel/Title/Image")

    self.descText = self.mainTransform:Find("Panel/Desc"):GetComponent(Text)
    self.descText1 = self.mainTransform:Find("Panel/DescText1"):GetComponent(Text)
    self.descText2 = self.mainTransform:Find("Panel/DescText2"):GetComponent(Text)
    self.descText3 = self.mainTransform:Find("Panel/DescText3"):GetComponent(Text)
    self.keyImageTransform = self.mainTransform:Find("Panel/KeyNum/Image")
    self.keyNumText = self.mainTransform:Find("Panel/KeyNum/Text"):GetComponent(Text)

    self.noticeBtn = self.mainTransform:Find("Panel/Image/NoticeButton"):GetComponent(Button)

    self:ShowButtonEffect()

    BibleRewardPanel.ShowEffect(20223, self.itemSlot.transform, Vector3(1, 1, 1), Vector3(0, 0, 0))
    ----------------------------

    self:OnShow()
    self:ClearMainAsset()
end

function NotNamedTreasureWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function NotNamedTreasureWindow:OnShow()
    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.currentType = self.openArgs[1]
        if #self.openArgs > 1 then
            self.uint_id = self.openArgs[2]
        end
    end
    if self.currentType == 62320 then
        self.noticeBtn.onClick:AddListener(function()
            TipsManager.Instance.model:OpenChancewindow(203)
        end)
    else
        self.noticeBtn.onClick:AddListener(function()
            TipsManager.Instance.model:OpenChancewindow(204)
        end)
    end


    self:Update()

    self:GetItems()
    self:ReloadReward()

    NotNamedTreasureManager.Instance.OnUpdateList:RemoveListener(self._Update)
    NotNamedTreasureManager.Instance.OnUpdateList:AddListener(self._Update)
end

function NotNamedTreasureWindow:OnHide()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil

        NotNamedTreasureManager.Instance:Send18202()
    end


    if self.myTimerId ~= nil then
        LuaTimer.Delete(self.myTimerId)
        self.myTimerId = nil
    end

    self:HideEffect()

    self.hasOpen = false
    BaseUtils.SetGrey(self.buttonImageTransform:GetComponent(Image), false)
    self.turnBtn.transform:GetComponent(TransitionButton).enabled = true
    self:ShowButtonEffect()

    NotNamedTreasureManager.Instance.OnUpdateList:RemoveListener(self._Update)
end

function NotNamedTreasureWindow:Update()
    local data_cumulative_reward = DataSpectralBox.data_cumulative_reward[self.currentType]
    local itembase = BackpackManager.Instance:GetItemBase(data_cumulative_reward.item_list[1][1])
    local itemData = ItemData.New()
    itemData:SetBase(itembase)
    itemData.bind = data_cumulative_reward.item_list[1][2]
    itemData.quantity = data_cumulative_reward.item_list[1][3]
    self.itemSlot:SetAll(itemData)

    self.itemText.text = itemData.name

    local num
    local color
    if self.currentType == 62320 then
        -- self.titleText.text = TI18N("鸿福齐天")
        self.titleImage:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.notnamedtreasure_textures, "Title1")

        self.descText.text = TI18N("盛世承平，福满大地，购买<color='#00ff00'>鸿福齐天</color>队标，将获得一次随机福运奖励。")
        num = self.model.gold_times
        if num > 0 then
            color = "#00ff00"
        else
            color = "#ff0000"
        end
        -- self.descText1.text = string.format(TI18N("抽取<color='#00ff00'>%s次</color>额外获得:(<color='%s'>%s</color>/%s)"), data_cumulative_reward.num, color, num, data_cumulative_reward.num)
        self.descText1.text = string.format(TI18N("额外奖励:(<color='%s'>%s</color>/%s)"), color, num, data_cumulative_reward.num)
        self.descText2.text = string.format(TI18N("每转动<color='#00ff00'>%s次</color>转盘可额外获得%s"), data_cumulative_reward.num, ColorHelper.color_item_name(itemData.quality, itemData.name))
        self.buttonImageTransform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.notnamedtreasure_textures, "KeyIcon1")

        self.keyImageTransform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.notnamedtreasure_textures, "KeyIcon1")
        num = BackpackManager.Instance:GetItemCount(self.model.type1_cost)
        if num > 0 then
            color = "#00ff00"
        else
            color = "#ff0000"
        end
        self.keyNumText.text = string.format(TI18N("拥有:<color='%s'>%s</color>"), color, num)
        self.descText3.text = TI18N("（每周<color='#ffff00'>首次</color>双倍）")
        self.descText3:GetComponent(RectTransform).sizeDelta = Vector2(134.95, 25)
        self.descText2.transform:GetComponent(RectTransform).anchoredPosition = Vector2(170, -46)
    else
        -- self.titleText.text = TI18N("秘银之光")
        self.titleImage:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.notnamedtreasure_textures, "Title2")

        self.descText.text = TI18N("盛世承平，福满大地，购买<color='#00ff00'>秘银之光</color>队标，将获得一次随机福运奖励。")
        num = self.model.silver_times
        if num > 0 then
            color = "#00ff00"
        else
            color = "#ff0000"
        end
        -- self.descText1.text = string.format(TI18N("抽取<color='#00ff00'>%s次</color>额外获得:(<color='%s'>%s</color>/%s)"), data_cumulative_reward.num, color, num, data_cumulative_reward.num)
        self.descText1.text = string.format(TI18N("额外奖励:(<color='%s'>%s</color>/%s)"), color, num, data_cumulative_reward.num)
        self.descText2.text = string.format(TI18N("每转动<color='#00ff00'>%s次</color>转盘可额外获得<color='#ffff00'>礼盒奖励</color>"), data_cumulative_reward.num)
        self.buttonImageTransform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.notnamedtreasure_textures, "KeyIcon2")

        self.keyImageTransform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.notnamedtreasure_textures, "KeyIcon2")
        num = BackpackManager.Instance:GetItemCount(self.model.type2_cost)
        if num > 0 then
            color = "#00ff00"
        else
            color = "#ff0000"
        end
        self.keyNumText.text = string.format(TI18N("拥有:<color='%s'>%s</color>"), color, num)
        self.descText3.text = ""
        self.descText2.transform:GetComponent(RectTransform).anchoredPosition = Vector2(170, -60)
    end
end

function NotNamedTreasureWindow:OnTurn()
    if self.timerId ~= nil then
        return
    end
    if self.hasOpen then
        NoticeManager.Instance:FloatTipsByString(TI18N("该宝箱已经被打开过了，无法再次打开"))
        return
    end

    if self.currentType == 62320 then
        if BackpackManager.Instance:GetItemCount(self.model.type1_cost) > 0 then
            NotNamedTreasureManager.Instance:Send18201(self.uint_id)
        else
            self:GetQuickBuy(self.model.type1_cost, 1)
            -- self:ShowNotice()
        end
    else
        if BackpackManager.Instance:GetItemCount(self.model.type2_cost) > 0 then
            NotNamedTreasureManager.Instance:Send18201(self.uint_id)
        else
            self:GetQuickBuy(self.model.type2_cost, 1)
            -- self:ShowNotice()
        end
    end
end

function NotNamedTreasureWindow:Go()
    self.hasOpen = true
    BaseUtils.SetGrey(self.buttonImageTransform:GetComponent(Image), true)
    self.turnBtn.transform:GetComponent(TransitionButton).enabled = false

    self.isRotating = true
    self.doSlowDown = false
    self.step = 15

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 10, function() self:DoRotation() end)
    end

    self:ShowEffect()
    self:HideButtonEffect()
end

function NotNamedTreasureWindow:DoRotation()
    -- self:SetPointerPos(self.step)
    if self.doSlowDown then
        if self.count < self.targetTheta then
            self.count = self.count + self.step *(self.targetTheta - self.count) * 1.2 / self.distance + 0.2
        end
    else
        self.count =(self.count + self.step) % 360
    end
    self:SetTurnplatePosition(self.count + 22.5)
    -- 角度制
    self:SetItemsPosition(self.count * math.pi / 180)
    -- 弧度制

    if self.targetTheta ~= nil and self.targetTheta ~= 0 and self.count >= self.targetTheta then
        LuaTimer.Delete(self.timerId)
        self.isRotating = false
        self.timerId = nil
        NotNamedTreasureManager.Instance:Send18202()

        self.myTimerId = LuaTimer.Add(500, function()
            -- self:HideEffect()
            -- if self.currentType == 62320 then
            --     if BackpackManager.Instance:GetItemCount(self.model.type1_cost) > 0 then
            --         self:ShowButtonEffect()
            --     end
            -- else
            --     if BackpackManager.Instance:GetItemCount(self.model.type2_cost) > 0 then
            --         self:ShowButtonEffect()
            --     end
            -- end
            self:Update()

            LuaTimer.Add(2000, function() self:OnClickClose() end)
        end )
    end
end

function NotNamedTreasureWindow:SetItemsPosition(theta)
    local sin = math.sin
    local cos = math.cos
    local pi = math.pi
    theta = - theta
    for i, v in ipairs(self.itemList) do
        v.anchoredPosition = Vector2(self.radius * cos(2 * pi *(i - 1) / self.num + theta), self.radius * sin(2 * pi *(i - 1) / self.num + theta))
    end
end

function NotNamedTreasureWindow:SetTurnplatePosition(theta)
    theta = - theta
    self.turnplate.rotation = Quaternion.Euler(0, 0, theta)
end

function NotNamedTreasureWindow:GetItems()
    local lev = RoleManager.Instance.RoleData.lev
    self.turnItems = { }
    self.totalTurnItems = { }
    self.typeToIndex = { }
    self.items = { }
    local count = 1
    for _, v in pairs(DataSpectralBox.data_reward) do
        if v.box_type == self.currentType and lev >= v.lev_min and lev <= v.lev_max then
            table.insert(self.items, { base_id = v.item_id })
            if self.typeToIndex[v.type_item_id] == nil then
                self.typeToIndex[v.type_item_id] = count
                count = count + 1
                table.insert(self.turnItems, { base_id = v.type_item_id })
            end
        end
    end
    for i, v in ipairs(DataCampTurn.data_total_reward) do
        if v.box_type == self.currentType then
            table.insert(self.totalTurnItems, v)
        end
    end
    -- table.sort(self.totalTurnItems, function(a,b) return a.num < b.num end)
end

function NotNamedTreasureWindow:ReloadReward()
    for i, v in ipairs(self.turnItems) do

        local go = self.iconList[i].gameObject
        local id = go:GetInstanceID()
        local imgLoader = self.loaders[id]
        if imgLoader == nil then
            imgLoader = SingleIconLoader.New(go)
            self.loaders[id] = imgLoader
        end
        imgLoader:SetSprite(SingleIconType.Item, DataItem.data_get[v.base_id].icon)

        self.btnList[i].onClick:RemoveAllListeners()
        self.btnList[i].onClick:AddListener( function()
            TipsManager.Instance:ShowItem( { gameObject = self.itemList[i].gameObject, itemData = DataItem.data_get[v.base_id], extra = { nobutton = true, inbag = false } })
        end )
    end
end

function NotNamedTreasureWindow:GetIndex(type, id)
    if type == self.currentType then
        if id > 0 then
            for _, v in pairs(DataSpectralBox.data_reward) do
                if v.id == id then
                    if self.typeToIndex[v.type_item_id] then
                        LuaTimer.Add(1000, function() self:DoSlowDown(self.typeToIndex[v.type_item_id]) end)
                    else
                        LuaTimer.Add(1000, function() self:DoSlowDown(BaseUtils.BASE_TIME % 8 + 1) end)
                    end
                    break
                end
            end
        else
            self:DoSlowDown(BaseUtils.BASE_TIME % 8 + 1)
        end
    end
end

function NotNamedTreasureWindow:DoSlowDown(index)
    index = index - 3
    if self.timerId ~= nil then
        self.doSlowDown = true
        if index > 4 then
            self.targetTheta = 45 * index + 360 * 2 - 15 + Random.Range(0, 30)
        else
            self.targetTheta = 45 * index + 360 * 3 - 15 + Random.Range(0, 30)
        end
        self.distance = self.targetTheta - self.count
    end
end

function NotNamedTreasureWindow:OnRewardPreview()
    if self.multiItemPanel == nil then
        self.multiItemPanel = MultiItemPanel.New(self.gameObject)
    end

    local num = 0
    if self.currentType == 62320 then
        self.rewardInfo = { column = 5, list = { { title = TI18N("鸿福宝箱展示"), items = self.items } } }
        num = self.model.gold_times
    else
        self.rewardInfo = { column = 5, list = { { title = TI18N("秘银宝箱展示"), items = self.items } } }
        num = self.model.silver_times
    end
    local extra = { }
    extra.horDirection = LuaDirection.Right
    extra.verDirection = LuaDirection.Mid
    extra.fontSize = 17
    extra.context = string.format(TI18N("已抽奖:<color='#00ff00'>%s</color>"), tostring(num))
    self.rewardInfo.extra = extra
    self.multiItemPanel:Show(self.rewardInfo)
end

function NotNamedTreasureWindow:ShowEffect()
    if self.effect == nil then
        self.effect = BibleRewardPanel.ShowEffect(20175, self.mainTransform:Find("Panel/Pointer"), Vector3(0.95, 0.95, 1), Vector3(0, 0, -400))
    else
        self.effect:SetActive(false)
        self.effect:SetActive(true)
    end
end

function NotNamedTreasureWindow:HideEffect()
    if self.effect ~= nil then
        self.effect:SetActive(false)
    end
end

function NotNamedTreasureWindow:ShowButtonEffect()
    if self.buttonEffect == nil then
        self.buttonEffect = BibleRewardPanel.ShowEffect(20121, self.mainTransform:Find("Panel/Pointer/OkButton"), Vector3(1.7, 1.7, 1), Vector3(0, 0, -400))
    else
        self.buttonEffect:SetActive(true)
    end
end

function NotNamedTreasureWindow:HideButtonEffect()
    if self.buttonEffect ~= nil then
        self.buttonEffect:SetActive(false)
    end
end

function NotNamedTreasureWindow:GetQuickBuy(id, num)
    self.quickBuyId = id
    self.quickBuyNum = num
    if self.priceByBaseid[id] == nil then
        MarketManager.Instance:send12416( { base_ids = { { base_id = id } } }, self._QuickBuyReturn)
    else
        self:ShowNotice()
    end
end

function NotNamedTreasureWindow:QuickBuyReturn(priceByBaseid)
    self.priceByBaseid = priceByBaseid
    self:ShowNotice()
end

function NotNamedTreasureWindow:ShowNotice()
    local fun = function()
        NotNamedTreasureManager.Instance:Send18201(self.uint_id)
    end

    local world_lev = RoleManager.Instance.world_lev
    local glodbind_to_gold = DataMarketGold.data_market_gold_ratio[world_lev].rate
    self.idToNumPrice = {
        [self.quickBuyId] =
        {
            isDouble = true,
            asset = 90002,
            num = self.quickBuyNum,
            money = math.ceil(self.priceByBaseid[self.quickBuyId].price * self.quickBuyNum),
            assets = 90002,
            assets_num = self.priceByBaseid[self.quickBuyId].price * self.quickBuyNum,
            source = MarketEumn.SourceType.Shop,
        }
    }
    self.baseidToNeed = {
        [self.quickBuyId] =
        {
            need = self.quickBuyNum,
        }
    }

    if self.notify == nil then
        self.notify = BuyNotify.New(self.idToNumPrice, self.baseidToNeed, fun, TI18N("购买钥匙"))
    else
        self.notify.content = TI18N("购买钥匙")
        if self.notify.loading ~= true then
            self.notify:ResetData(self.idToNumPrice, self.baseidToNeed)
        end
    end
    self.notify:Show()
end
