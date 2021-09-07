-- 已弃用，现在的类名是ShopMainWindow

ShopWindow = ShopWindow or BaseClass(BaseWindow)

function ShopWindow:__init(model)
    self.model = model

    self.windowId = WindowConfig.WinID.shop
    self.frozen = nil

    --[[
    1: allGoodsPanel 全部商品
    2: weeklyPurchase 每周限购
    3: mysteryShop 神秘商店
    ]]--
    self.subPanelList = {nil, nil, nil}
    self.resList = {
        {file = AssetConfig.shop_window, type = AssetType.Main}
        ,{file = AssetConfig.shop_textures, type = AssetType.Dep}
    }

    self.goodsPanel = nil
    self.btnTopTabList = {nil, nil, nil}
    self.btnSideTabList = {nil, nil, nil}

    self.itemCurrecy = nil      -- 选中物品的货币样式图片
    self.itemPrice = nil        -- 选中物品的价格文本框
    self.tabShopItemObjList = {nil, nil, nil}
    self.tabPointItemObjList = nil
    self.buyNumObj = nil        -- 物品购买数量

    self.btnBuy = nil
    self.currentPage = 0
    self.hasInitPage = {}       -- 记录每一页是否已经初始化

    self.infoCurrencyType = nil
    self.pageNum = 0        -- 当前页签的页数
    self.pageTotalNum = 0   -- 驻存在内存中的页数
    self.pageObjList = {}
    self.pageItemList = {}
    self.tabMainRedPoint = {}
    self.tabSubRedPoint = {}

    self.roleAssetsListener = function() self:RoleAssetsListener() end

    EventMgr.Instance:AddListener(event_name.role_asset_change, self.roleAssetsListener)
end

function ShopWindow:__delete()
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.roleAssetsListener)
    for i,v in pairs(self.subPanelList) do
        if v ~= nil then
            v:DeleteMe()
            self.subPanelList[i] = nil
        end
    end
    if self.msgItemExt ~= nil then
        self.msgItemExt:DeleteMe()
        self.msgItemExt = nil
    end

    if self.frozen ~= nil then
        self.frozen:DeleteMe()
        self.frozen = nil
    end
    if self.boxXLayout ~= nil then
        self.boxXLayout:DeleteMe()
        self.boxXLayout = nil
    end
    if self.rtLayout ~= nil then
        self.rtLayout:DeleteMe()
        self.rtLayout = nil
    end
    if self.tabbedPanel ~= nil then
        self.tabbedPanel:DeleteMe()
        self.tabbedPanel = nil
    end
    if self.rechargeLayout ~= nil then
        self.rechargeLayout:DeleteMe()
        self.rechargeLayout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.model.selectObj = nil
        self.gameObject = nil
    end
    self.model.selectItem = nil
    self.model.selectObj = nil
    self:AssetClearAll()
    ShopManager.Instance:CheckForMainUIRedPoint()
end

function ShopWindow:InitPanel()
    self.pageTotalNum = 0
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shop_window))
    self.gameObject:SetActive(false)
    self.gameObject.name = "ShopWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    local model = self.model
    local main = self.gameObject.transform:Find("Main")
    main:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)
    self.helpBtn = main:Find("Help"):GetComponent(Button)
    self.helpBtn.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.helpBtn.gameObject, itemData = {TI18N("每天带新人完成以下任务可以获得{assets_2, 90007}","1,悬赏任务：<color=#ffff00>3-6</color>{assets_2, 90007}/场战斗","2,副本挑战：<color=#ffff00>6-12</color>{assets_2, 90007}/场战斗","3,天空之塔：<color=#ffff00>10-20</color>{assets_2, 90007}/场战斗","每天最多可获得<color=#ffff00>500</color>{assets_2, 90007}，助人为乐从我开始^_^")}})
    end)
    self.descObj = main:Find("Desc")
    self.descObj:GetComponent(Text).text = TI18N("每日<color=#e8faff>21点</color>更新神秘商店")

    self.topButtonGroup = main:Find("TopTabButtonGroup")
    self.subButtonObjList = {nil, nil, nil}
    for i=1,3 do
        self.subButtonObjList[i] = self.topButtonGroup:Find("Button"..i)
        self.subButtonObjList[i].gameObject:SetActive(false)
        self.subButtonObjList[i]:GetComponent(Button).onClick:AddListener(function ()
            self:UpdateTab(model.currentMain, i)
        end)
        self.tabSubRedPoint[i] = self.subButtonObjList[i]:Find("RedPointImage").gameObject
    end

    local sideButtonGroup = main:Find("SideTabButtonGroup")
    self.mainButtonObjList = {nil, nil}
    for i=1,3 do
        self.mainButtonObjList[i] = sideButtonGroup:Find("Btn"..i)
        self.mainButtonObjList[i]:GetComponent(Button).onClick:AddListener(function ()
            if i == 1 then
                model.currentSub = 2
            else
                model.currentSub = 1
            end
            self:UpdateTab(i, model.currentSub)
        end)
        self.tabMainRedPoint[i] = self.mainButtonObjList[i]:Find("RedPointImage").gameObject
    end

    local goodsPanel = main:Find("GoodsPanel")
    self.scrollRect = goodsPanel:Find("Panel"):GetComponent(ScrollRect)
    self.buyContainer = goodsPanel:Find("Panel/Container").gameObject
    self.buyContainerRect = self.buyContainer:GetComponent(RectTransform)
    self.pageTemplate = self.buyContainer.transform:Find("ItemPage").gameObject
    self.rechargePanel = main:Find("RechargePanel").gameObject

    self:InitRechangePanel()
    self:InitRechargeReturnPanel()
    self.rechargeReturnPanel:SetActive(false)

    if self.boxXLayout == nil then
        local setting = {
            axis = BoxLayoutAxis.X
            ,spacing = 0
        }
        self.boxXLayout = LuaBoxLayout.New(self.buyContainer, setting)
    end

    self.tabbedPanel = TabbedPanel.New(self.scrollRect.gameObject, 5, 494)
    self.tabbedPanel.MoveEndEvent:Add(function(currentPage, direction) self:OnDragEnd(currentPage, direction) end)

    local infoArea = main.transform:Find("InfoArea")
    self.guideGirl = infoArea:Find("GoodsTips/GirlGuide").gameObject
    self.goodsInfo = infoArea:Find("GoodsTips/GoodsInfo").gameObject
    local tr = self.goodsInfo.transform
    self.infoNameText = tr:Find("Name"):GetComponent(Text)
    self.infoDescText = tr:Find("Describe"):GetComponent(Text)
    self.infoLimit1Text = tr:Find("Num1"):GetComponent(Text)
    self.infoLimit2Text = tr:Find("Num2"):GetComponent(Text)
    self.infoPriceObj = tr:Find("Price").gameObject
    self.infoPricesText = tr:Find("Price/Prices"):GetComponent(Text)
    self.infoDiscountText = tr:Find("Price/Discount/Discount"):GetComponent(Text)
    self.infoOriginCurrencyImage = tr:Find("Price/OriginCurrency"):GetComponent(Image)
    self.infoNowCurrencyImage = tr:Find("Price/NowCurrency"):GetComponent(Image)

    self.gameObject:SetActive(true)

    local buyArea = infoArea:Find("BuyArea")
    local buyIt = function ()
        if self.model.selectedInfo ~= nil then
            -- BaseUtils.dump(self.model.selectedInfo, "选择的物品信息")
            local num = tonumber(self.buyNumObj:GetComponent(Text).text)
            if num > 0 then
                if self.frozen ~= nil then
                    self.frozen:OnClick()
                end
                if model.currentSub ~= 1 or model.currentSub ~= 3 then
                    ShopManager.Instance:send11303(self.model.selectedInfo.id, num)
                else
                    ShopManager.Instance:send13901(self.model.selectedInfo.id)
                end
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("最少购买一个"))
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("请选择需要购买的物品"))
        end
    end

    self.toggleGroup = main:Find("ToggleGroup")
    self.toggleList = {nil, nil, nil, nil, nil}
    for i=1,5 do
        self.toggleList[i] = self.toggleGroup:Find("Toggle"..i):GetComponent(Toggle)
    end

    self.itemPrice = buyArea:Find("BuyPrice/PriceBg/Price").gameObject:GetComponent(Text)
    self.itemCurrecy = buyArea:Find("BuyPrice/PriceBg/Currency").gameObject:GetComponent(Image)

    self.updatePrice = function(result)
        if self.selectUniprice ~= nil and result ~= nil then
            self.itemPrice.text = tostring(result * self.selectUniprice)

            local myAssets = tonumber(self.ownAssetText.text)
            if myAssets < result * self.selectUniprice then
                self.itemPrice.text = ColorHelper.Fill(ColorHelper.color[6], self.itemPrice.text)
            end
        end
    end

    self.buyNumObj = buyArea:Find("BuyCount/CountBg/Count").gameObject
    self.buyNumObj.gameObject:AddComponent(Button).onClick:AddListener(function ()
        if model.selectedInfo ~= nil and (model.currentMain ~= 1 or model.currentSub ~= 3) then
            local numText = nil
            local max_by_backpack = 100
            if self.model.selectedInfo ~= nil then
                if self.model.selectedInfo.canBuyNum ~= nil then
                    max_by_backpack = self.model.selectedInfo.canBuyNum
                end
            else
                max_by_backpack = 0
                return
            end
            if max_by_backpack == -1 then
                max_by_backpack = 100
            end
            -- local max_by_asset = math.floor(tonumber(self.ownAssetText.text) / self.selectUniprice)
            local info = {parent_obj = self.gameObject, gameObject = self.buyNumObj, min_result = 1, max_by_asset = max_by_backpack, max_result = max_by_backpack, textObject = self.buyNumObj:GetComponent(Text), show_num = false, funcReturn = function() NoticeManager.Instance:FloatTipsByString(TI18N("请确认购买")) end, callback = self.updatePrice}
            NumberpadManager.Instance:set_data(info)
            NumberpadManager.Instance:OpenWindow()
        end
    end)
    self.btnNumAdd = buyArea:Find("BuyCount/AddBtn").gameObject:GetComponent(Button)
    self.btnNumAdd.onClick:RemoveAllListeners()
    self.btnNumAdd.onClick:AddListener(function ()
        local countText = self.buyNumObj:GetComponent(Text)
        local num = tonumber(countText.text)
        local max_by_backpack = 100
        if self.model.selectedInfo ~= nil then
            if self.model.selectedInfo.canBuyNum ~= nil then
                max_by_backpack = self.model.selectedInfo.canBuyNum
            end
        else
            max_by_backpack = 0
            return
        end
        if max_by_backpack == -1 then
            max_by_backpack = 100
        end
        if num < max_by_backpack then
            num = num + 1
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("不能购买更多了"))
        end
        countText.text = tostring(num)
        self.updatePrice(num)
    end)
    self.btnNumMinus = buyArea:Find("BuyCount/MinusBtn").gameObject:GetComponent(Button)
    self.btnNumMinus.onClick:RemoveAllListeners()
    self.btnNumMinus.onClick:AddListener(function ()
        if self.model.selectedInfo == nil then
            return
        end
        local countText = self.buyNumObj:GetComponent(Text)
        local num = tonumber(countText.text)
        if num > 1 then
            num = num - 1
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("最少买一个"))
        end
        countText.text = tostring(num)
        self.updatePrice(num)
    end)

    local onwAssetObj = buyArea:Find("OwnAsset/AssetBg")
    self.ownAssetCurrencyImage = onwAssetObj:Find("Currency"):GetComponent(Image)
    self.ownAssetText = onwAssetObj:Find("Asset"):GetComponent(Text)

    self.btnBuy = buyArea:Find("BtnArea/Button").gameObject:GetComponent(Button)
    self.btnBuy.onClick:RemoveAllListeners()
    self.btnBuy.onClick:AddListener(buyIt)
    self.frozen = FrozenButton.New(self.btnBuy.gameObject)

    self.btnRecharge = buyArea:Find("BtnArea/Recharge").gameObject:GetComponent(Button)
    self.btnRecharge.onClick:RemoveAllListeners()
    self.btnRecharge.onClick:AddListener(function()
        WindowManager.Instance:OpenWindowById(self.windowId, {3, 1})
    end)

    self.goodsInfo:SetActive(false)
    self.guideGirl:SetActive(true)

    self:UpdateTab(model.currentMain, model.currentSub)
    self:ReloadBuyPanel()
    self:UpdateSelection()
end

function ShopWindow:InitRechangePanel()
    local model = self.model
    local chargeList = model:GetChargeList()

    self.rechangeContainer = self.rechargePanel.transform:Find("Panel/Container")
    self.rechargeTemplate = self.rechargePanel.transform:Find("Panel/RechargeItem").gameObject
    self.rechargeTemplate:SetActive(false)
    if self.rechargeLayout == nil then
        local setting = {
            column = 4
            ,cspacing = 5
            ,rspacing = 5
            ,cellSizeX = 172
            ,cellSizeY = 186
        }
        self.rechargeLayout = LuaGridLayout.New(self.rechangeContainer, setting)
    end

    for i=1,#chargeList do
        local rmbObj = GameObject.Instantiate(self.rechargeTemplate)
        self.rechargeLayout:AddCell(rmbObj)
        rmbObj.name = tostring(i)
    end

    for i=1,#chargeList  do
        local rmbObj = self.rechangeContainer:Find(tostring(i))
        rmbObj:Find("Diamonds"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, "Excharge"..tostring(math.ceil(6 / #chargeList * i)))
        rmbObj:Find("Money"):GetComponent(Text).text = tostring(chargeList[i].rmb)
        rmbObj:Find("AssetBg/Asset"):GetComponent(Text).text = tostring(chargeList[i].gold)
        if chargeList[i].tokes == 0 or chargeList[i].tokes == nil then
            rmbObj:Find("Tokes").gameObject:SetActive(false)
        else
            rmbObj:Find("Tokes").gameObject:SetActive(true)
            rmbObj:Find("Tokes"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, "Tokes")
            rmbObj:Find("Tokes/Value"):GetComponent(Text).text = tostring(chargeList[i].tokes)
        end
        local btn = rmbObj:GetComponent(Button)
        btn.onClick:RemoveAllListeners()
        btn.onClick:AddListener(function() self:OnClickItem(chargeList[i]) end)
    end
    self.rechargeOwnGoldText = self.rechargePanel.transform:Find("OwnGold/Gold"):GetComponent(Text)
    self.rechargeOwnGoldText.text = tostring(RoleManager.Instance.RoleData.gold)
    self.rechargePanel:SetActive(false)

    self.rechargeReturnPanel = self.gameObject.transform:Find("Main/RechargeReturnPanel").gameObject
    self.rtHadGold = self.rechargeReturnPanel.transform:Find("OwnGold/Gold"):GetComponent(Text)
    self.rechangeContainer:GetComponent(RectTransform).anchoredPosition = Vector2.zero
end

function ShopWindow:InitRechargeReturnPanel()
    local tran = self.rechargeReturnPanel.transform
    local layoutContainer = tran:Find("Content/ItemParent/ItemGrid")
    self.rtLayout = LuaBoxLayout.New(layoutContainer.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4,scrollRect = layoutContainer.parent})
    local itemTemp = layoutContainer:GetChild(0).gameObject
    itemTemp:SetActive(false)

    self.rtObjList = {}

    self.rtTplDataDic = {}
    for k,v in pairs(DataCampaign.data_list) do
        if (tonumber(v.iconid)) == CampaignEumn.Type.Rebate then
            table.insert(self.rtTplDataDic,v)
        end
    end

    table.sort(self.rtTplDataDic,function (a,b)
        -- body
        return a.group_index < b.group_index
    end)

    for i,v in ipairs(self.rtTplDataDic) do
        local obj = GameObject.Instantiate(itemTemp)
        obj:SetActive(true)
        obj.name = tostring(i)

        self.rtLayout:AddCell(obj)

        local itemDic = {
            index = i,
            value = v,
            thisObj = obj,
            isNewEffect = false,
            btn = obj.transform:Find("Button"):GetComponent(Button),
            goldTxt = obj.transform:Find("Left/Gold"):GetComponent(Text),
            curTxt = obj.transform:Find("Slider/ProgressTxt"):GetComponent(Text),
            hadGetObj = obj.transform:Find("Text").gameObject,
            images = {obj.transform:Find("Image1"):GetComponent(Image),obj.transform:Find("Image2"):GetComponent(Image),
                      obj.transform:Find("Image3"):GetComponent(Image),obj.transform:Find("Image4"):GetComponent(Image),},
            slider = obj.transform:Find("Slider"):GetComponent(Slider),
        }
        self.rtObjList[i] = itemDic

        itemDic.goldTxt.text = v.camp_cond_client
        for i=1,4 do
            local img = itemDic.images[i]
            local rewardTemp = v.reward[i]
            if rewardTemp ~= nil then
                img.gameObject:SetActive(true)

                local slot = ItemSlot.New()
                local itemdata = ItemData.New()
                local cell = DataItem.data_get[rewardTemp[1]]
                itemdata:SetBase(cell)
                slot:SetAll(itemdata, {inbag = false, nobutton = true})
                NumberpadPanel.AddUIChild(img.gameObject, slot.gameObject)
                slot:SetNum(rewardTemp[2])
            else
                img.gameObject:SetActive(false)
            end
        end

        itemDic.btn.onClick:AddListener(function ()
            --点击领取
            self:GetRTReward(itemDic)
        end)
    end
end

function ShopWindow:GetRTReward(itemDic)
    --Log.Error(itemDic.value.id)
    FirstRechargeManager.Instance:send14001(itemDic.value.id)
end

function ShopWindow:UpdateTab(main, sub)
    local model = self.model

    for _,v in pairs(self.mainButtonObjList) do
        v:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton1Normal")
    end

    self.mainButtonObjList[main]:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton1Select")

    if self.tabLayout ~= nil then
        self.tabLayout:DeleteMe()
    end
    self.tabLayout = LuaBoxLayout.New(self.topButtonGroup, {axis = BoxLayoutAxis.X, cspacing = 5})

    local subList = {}
    for k,v in pairs(model.dataTypeList[main].subList) do
        table.insert(subList, {order = v.order, index = k, value = v})
    end
    table.sort(subList, function(a,b) return a.order < b.order end)
    for i=1,3 do
        self.subButtonObjList[i].gameObject:SetActive(false)
    end
    for i,v in ipairs(subList) do
        local obj = self.subButtonObjList[i]
        obj:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton2Normal")
        if v.value.lev == nil or (v.value.lev ~= nil and RoleManager.Instance.RoleData.lev >= v.value.lev) then
            obj.gameObject:SetActive(true)
            local rect = obj:GetComponent(RectTransform)
            local centerText = obj:Find("CenterText"):GetComponent(Text)
            local iconImage = obj:Find("Icon"):GetComponent(Image)
            local nameText = obj:Find("Text"):GetComponent(Text)
            if v.value.icon == nil then
                centerText.gameObject:SetActive(true)
                centerText.text = v.value.name
                iconImage.gameObject:SetActive(false)
                nameText.gameObject:SetActive(false)
                rect.sizeDelta = Vector2(122, 38)
            else
                centerText.gameObject:SetActive(false)
                iconImage.gameObject:SetActive(true)
                if v.value.textures ~= nil and v.value.textures ~= "" then
                    iconImage.sprite = PreloadManager.Instance:GetSprite(v.value.textures, v.value.icon)
                else
                    iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, v.value.icon)
                end
                nameText.gameObject:SetActive(true)
                nameText.text = v.value.name
                rect.sizeDelta = Vector2(50 + nameText.preferredWidth, 38)
            end
            self.tabLayout:AddCell(obj.gameObject)
        else
            obj.gameObject:SetActive(false)
        end
    end

    self.subButtonObjList[sub]:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton2Select")

    self.helpBtn.gameObject:SetActive(main == 2 and sub == 3)
    if model.currentMain == main and model.currentSub == sub then
        return
    end

    model.selectedInfo = nil
    model.selectItem = nil
    model.currentMain = main
    model.currentSub = sub

    self:ReloadBuyPanel()
    if main < 3 then
        self:UpdateSelection()
    end

    local rectBuy = self.btnBuy.gameObject:GetComponent(RectTransform)
    if main == 1 then
        self.btnRecharge.gameObject:SetActive(true)
        rectBuy.anchoredPosition = Vector2(62, 0)
    else
        rectBuy.anchoredPosition = Vector2(0, 0)
        self.btnRecharge.gameObject:SetActive(false)
    end
end

function ShopWindow:isNeedShowRedPoint()
    local bo = false
    for k,v in pairs(FirstRechargeManager.Instance.rewardDic) do
        local activeItem = DataCampaign.data_list[k]
        if activeItem ~= nil and (tonumber(activeItem.iconid)) == CampaignEumn.Type.Rebate then --充值返利
            if v.status == 1 then
                bo = true
                break
            end
        end
    end
    return bo
end

function ShopWindow:CheckRedPoint()
    for k,v in pairs(self.tabSubRedPoint) do
        self.tabSubRedPoint[k]:SetActive(false)
    end
    self.tabMainRedPoint[3]:SetActive(self:isNeedShowRedPoint())    -- 充值

    local model = self.model
    local main = model.currentMain
    if main == 3 then
        self.tabSubRedPoint[2]:SetActive(self:isNeedShowRedPoint())
    else
        local redPoint = ShopManager.Instance.redPoint
        local red = false
        for i=1,#self.tabSubRedPoint do
            self.tabSubRedPoint[i]:SetActive(redPoint[main][i] == true)
        end
    end

end

function ShopWindow:ReloadBuyPanel()
    self:InitAllPages(false)

    local model = self.model
    local main = model.currentMain
    local sub = model.currentSub

    ShopManager.Instance.redPoint[main][sub] = false
    self:CheckRedPoint()

    for k,v in pairs(model.dataTypeList) do
        if k == main then
            for k1,v1 in pairs(v.subList) do
                if v1.order == sub then
                    sub = k1
                    break
                end
            end
        end
    end

    if self.descObj ~= nil then
        if main == 1 and sub == 3 then
            self.descObj.gameObject:SetActive(true)
            ShopManager.Instance:send13902()
        else
            self.descObj.gameObject:SetActive(false)
        end
    end

    if main == 1 and sub == 2 then
        PlayerPrefs.SetInt(ShopManager.Instance.TTimeLimit, BaseUtils.BASE_TIME)
    end

    -- if main == 2 then
    --     self.helpBtn.gameObject:SetActive(true)
    -- else
    --     self.helpBtn.gameObject:SetActive(false)
    -- end

    if main == 3 then
        self.tabSubRedPoint[2]:SetActive(self:isNeedShowRedPoint())
        if sub == 1 then
            self.rechargePanel:SetActive(true)
            self.rechargeReturnPanel:SetActive(false)
        elseif sub == 2 then
            self.rechargePanel:SetActive(false)
            self.rechargeReturnPanel:SetActive(true)

            self:UpdateRTPanel()
        end
        local t = self.gameObject.transform:Find("Main")
        t:Find("GoodsPanel").gameObject:SetActive(false)
        t:Find("InfoArea").gameObject:SetActive(false)
        self.toggleGroup.gameObject:SetActive(false)
        return
    else
        self.rechargePanel:SetActive(false)
        self.rechargeReturnPanel:SetActive(false)
        local t = self.gameObject.transform:Find("Main")
        t:Find("GoodsPanel").gameObject:SetActive(true)
        t:Find("InfoArea").gameObject:SetActive(true)
        self.toggleGroup.gameObject:SetActive(true)
    end

    if model.datalist[main][sub] == nil then
        if main == 1 then
            if sub ~= 3 then
                ShopManager.Instance:send11301(main)
            else
                ShopManager.Instance:send13900()
            end
            return
        elseif main == 2 then
            model:SetStoreData()
        end
    end

    if self.pageTotalNum < model.pageNum[main][sub] then
        for i=self.pageTotalNum + 1, model.pageNum[main][sub] do
            self.pageObjList[i] = GameObject.Instantiate(self.pageTemplate)
            self.pageObjList[i]:SetActive(true)
            self.pageObjList[i].name = tostring(i)
            self.boxXLayout:AddCell(self.pageObjList[i])
            self.pageObjList[i].transform.localScale = Vector3.one
        end
        self.pageTotalNum = model.pageNum[main][sub]
    end

    self.pageNum = model.pageNum[main][sub]
    self.tabbedPanel:SetPageCount(self.pageNum)

    for i=1,5 do
        self.toggleList[i].gameObject:SetActive(false)
        self.toggleList[1].isOn = false
    end
    for i=1,model.pageNum[main][sub] do
        self.toggleList[i].gameObject:SetActive(true)
    end

    if self.pageNum > 0 then
        self:InitDataPanel(main, sub, 1)
        self.toggleList[1].isOn = true
    end
    if self.pageNum > 1 then
        self:InitDataPanel(main, sub, 2)
    end
    self.tabbedPanel:SetPageCount(self.pageNum)
    self.tabbedPanel:TurnPage(1)
    self.buyContainerRect.sizeDelta = Vector2(self.pageNum * 494,394)
    -- self.buyContainerRect.anchoredPosition = Vector2.zero
end

function ShopWindow:UpdateRTPanel()
    local role_data = RoleManager.Instance.RoleData
    self.rtHadGold.text = tostring(tostring(role_data.gold))
    for i,v in ipairs(self.rtObjList) do
        --Log.Error(v.index)
        local rewardTemp = FirstRechargeManager.Instance.rewardDic[v.value.id]
        if rewardTemp ~= nil then
            if rewardTemp.status == 0 then --未完成
                v.btn.gameObject:SetActive(false)
                v.hadGetObj:SetActive(false)
                v.slider.gameObject:SetActive(true)

                v.curTxt.text = string.format("%d/%d",rewardTemp.value,rewardTemp.target_val)
                v.slider.value = rewardTemp.value / rewardTemp.target_val
            elseif rewardTemp.status == 1 then --完成未领取
                v.btn.gameObject:SetActive(true)
                v.hadGetObj:SetActive(false)
                v.slider.gameObject:SetActive(false)

                if v.isNewEffect == false then
                    v.isNewEffect = true
                    local fun2 = function(effectView)
                        local effectObject = effectView.gameObject

                        effectObject.transform:SetParent(v.btn.transform)
                        effectObject.transform.localScale = Vector3(1, 1, 1)
                        effectObject.transform.localPosition = Vector3(-50, 28, -10)
                        effectObject.transform.localRotation = Quaternion.identity

                        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                        effectObject:SetActive(true)
                    end
                    BaseEffectView.New({effectId = 20118, time = nil, callback = fun2})
                end
            else --已领取
                v.btn.gameObject:SetActive(false)
                v.hadGetObj:SetActive(true)
                v.slider.gameObject:SetActive(false)
            end
        else
            --Log.Error("---------"..tostring(v.value.id))
        end
    end
    self:CheckRedPoint()
end

function ShopWindow:OnClickClose()
    self.model.selectedInfo = nil
    self.model:CloseMain()
end

function ShopWindow:InitDataPanel(main, sub, index)
    local model = self.model
    local datalist = model.datalist[main][sub]

    -- local pageItemList = {nil, nil, nil, nil, nil, nil, nil, nil}
    local baseIndex = (index - 1) * 8

    for i=1,8 do
        if self.pageItemList[(index - 1) * 8 + i] == nil then
            self.pageItemList[(index - 1) * 8 + i] = ShopItem.New(model, self.pageObjList[index].transform:Find(tostring(i)).gameObject, function(data) self:UpdateSelection(data) end)
        end
        local item = self.pageItemList[(index - 1) * 8 + i]
        item:SetActive(false)
        local data = datalist[baseIndex + i]
        if data ~= nil then
            item:SetData(data, (index - 1) * 8 + i)
        end
    end

    self.pageObjList[index]:SetActive(true)
    self.hasInitPage[index] = true
end

function ShopWindow:InitAllPages(bool)
    for i=1,self.pageNum do
        self.pageObjList[i]:SetActive(bool)
    end
end

function ShopWindow:OnDragEnd(currentPage, direction)
    local model = self.model
    if direction == LuaDirection.Left then
        if currentPage > 1 then
            self.toggleList[currentPage - 1].isOn = false
        end
        self.toggleList[currentPage].isOn = true
        if currentPage > 1 then
            if currentPage < self.pageNum and self.hasInitPage[currentPage + 1] ~= true then
                self:InitDataPanel(model.currentMain, model.currentSub, currentPage + 1)
            end
        end
    elseif direction == LuaDirection.Right then
        if currentPage < self.pageNum then
            self.toggleList[currentPage + 1].isOn = false
        end
        self.toggleList[currentPage].isOn = true
    end
end

function ShopWindow:RoleAssetsListener()
    local role_data = RoleManager.Instance.RoleData
    if self.infoCurrencyType == "coin" then
        self.ownAssetText.text = tostring(role_data.coin)
    elseif self.infoCurrencyType == "gold" then
        self.ownAssetText.text = tostring(role_data.gold)
    elseif self.infoCurrencyType == "gold_bind" then
        self.ownAssetText.text = tostring(role_data.gold_bind)
    elseif self.infoCurrencyType == "stars_score" then
        self.ownAssetText.text = tostring(role_data.stars_score)
    elseif self.infoCurrencyType == "character" then
        self.ownAssetText.text = tostring(role_data.character)
    elseif self.infoCurrencyType == "love" then
        self.ownAssetText.text = tostring(role_data.love)
    end

    self.rechargeOwnGoldText.text = tostring(tostring(role_data.gold))
    self.rtHadGold.text = tostring(tostring(role_data.gold))

    local priceTemp = tonumber(self.itemPrice.text)
    if tonumber(self.ownAssetText.text) < priceTemp then
        self.itemPrice.text = ColorHelper.Fill(ColorHelper.color[6], tostring(priceTemp))
    end
end

function ShopWindow:UpdateSelection(data)
    local t = self.goodsInfo.transform
    local item = nil
    local info = nil
    local model = self.model
    local limitText = nil
    self.selectUniprice = nil
    local limitTextObj1 = t:Find("Num1").gameObject
    local limitTextObj2 = t:Find("Num2").gameObject
    limitTextObj1:SetActive(false)
    limitTextObj2:SetActive(false)

    local numHave = nil
    if self.msgItemExt ~= nil then
        self.msgItemExt:DeleteMe()
        self.msgItemExt = nil
    end

    local shopData  = nil
    local baseData = nil
    if data ~= nil then
        shopData = DataShop.data_goods[string.format("%s_%s_%s", tostring(data.tab), tostring(data.tab2), tostring(data.id))] -- 商城表数据
        baseData = DataItem.data_get[data.base_id]    -- 基础数据
    end
    model.selectedInfo = data

    local currencyRes = "Assets"
    local role_data = RoleManager.Instance.RoleData

    local currencyRes = 90002
    self.infoCurrencyType = "gold"  -- 期望值
    if data ~= nil then
        -- [DEBUG] data = {
        --     tab = 1,
        --     num = 1,
        --     label = 0,
        --     price = 8000,
        --     tab2 = 3,
        --     limit_role = 1,
        --     id = 27,
        --     flag = 0,
        --     base_id = 20066,
        --     asset_type = 90003,
        -- }
        if shopData == nil then
            if data.tab == 1 and data.tab2 == 3 then
                currencyRes = data.asset_type
                if data.asset_type == 90003 then
                    -- 金币
                    self.infoCurrencyType = "gold_bind"
                elseif data.asset_type == 90002 then
                    -- 钻石
                    self.infoCurrencyType = "gold"
                end
                -- self.infoCurrencyType = data.asset_type  -- 实际值 90003
            elseif data.tab == 2 and data.tab2 == 1 then
                currencyRes = KvData.assets["stars_score"]
                self.infoCurrencyType = "stars_score"
            elseif data.tab == 2 and data.tab2 == 2 then
                currencyRes = KvData.assets["character"]
                self.infoCurrencyType = "character"
            elseif data.tab == 2 and data.tab2 == 3 then
                currencyRes = KvData.assets["love"]
                self.infoCurrencyType = "love"
            else
                currencyRes = KvData.assets["gold"]
                self.infoCurrencyType = "gold"
            end
        else
            currencyRes = KvData.assets[shopData.assets_type]
            self.infoCurrencyType = shopData.assets_type
        end
    else
        if model.currentMain == 2 and model.currentSub == 1 then
            currencyRes = KvData.assets["stars_score"]
            self.infoCurrencyType = "stars_score"
        elseif model.currentMain == 2 and model.currentSub == 3 then
            currencyRes = KvData.assets["character"]
            self.infoCurrencyType = "character"
        elseif model.currentMain == 2 and model.currentSub == 2 then
            currencyRes = KvData.assets["love"]
            self.infoCurrencyType = "love"
        else
            currencyRes = KvData.assets["gold"]
            self.infoCurrencyType = "gold"
        end
    end
    currencyRes = "Assets"..currencyRes

    if data == nil then
        self.guideGirl.gameObject:SetActive(true)
        self.goodsInfo:SetActive(false)
    else
        self.guideGirl.gameObject:SetActive(false)
        self.goodsInfo:SetActive(true)
        data.canBuyNum = nil
        self.infoNameText.text = baseData.name
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
        self.msgItemExt = MsgItemExt.New(self.infoDescText, 218, 16, 20)
        self.msgItemExt:SetData(ddesc, true)

        if data.tab == 1 and data.tab2 == 3 then
            data.canBuyNum = 1
        else
            if baseData.limit_role ~= -1 and data.limit_role ~= -1 then
                if shopData.limit_type == "week" then
                    limitText = TI18N("每周限购: "..tostring(data.limit_role).."个")
                elseif shopData.limit_type == "day" then
                    limitText = TI18N("每日限购: "..tostring(data.limit_role).."个")
                end
                model.itemBuyLimitList[data.id] = data.limit_role

                if model.itemBuyLimitList[data.id] ~= nil then
                    numHave = 0
                    if model.hasBuyList ~= nil and model.hasBuyList[data.id] ~= nil then
                        numHave = model.hasBuyList[data.id]
                    end
                    if numHave ~= nil then
                        data.canBuyNum = model.itemBuyLimitList[data.id] - numHave
                    end
                end
            else
                limitText = ""
            end
        end
    end

    if model.currentMain == 1 and model.currentSub == 3 then
        if model.selectedInfo ~= nil then
            if model.selectedInfo.asset_type == 90000 then
                info = {assets_type = "coin"}
            elseif model.selectedInfo.asset_type == 90001 then
                info = {assets_type = "bind"}
            elseif model.selectedInfo.asset_type == 90002 then
                info = {assets_type = "gold"}
            elseif model.selectedInfo.asset_type == 90003 then
                info = {assets_type = "gold_bind"}
            elseif model.selectedInfo.asset_type == 90004 then
                info = {assets_type = "intelligs"}
            elseif model.selectedInfo.asset_type == 90005 then
                info = {assets_type = "pet_exp"}
            elseif model.selectedInfo.asset_type == 90006 then
                info = {assets_type = "energy"}
            elseif model.selectedInfo.asset_type == 90007 then
                info = {assets_type = "character"}
            elseif model.selectedInfo.asset_type == 90010 then
                info = {assets_type = "exp"}
            elseif model.selectedInfo.asset_type == 90011 then
                info = {assets_type = "guild"}
            elseif model.selectedInfo.asset_type == 90012 then
                info = {assets_type = "stars_score"}
            else
                info = {assets_type = "gold"}
            end
            info.price = data.price
        end
    end

    if shopData ~= nil then
        if shopData.discount ~= nil and shopData.discount > 0 then
            self.infoPriceObj:SetActive(true)
            self.infoPricesText.text = tostring(shopData.price).."\n"..tostring(math.ceil(shopData.price * shopData.discount / 1000))
            self.selectUniprice = math.ceil(shopData.price * shopData.discount / 1000)
            self.itemPrice.text = tostring(self.selectUniprice)
            t:Find("Price/Discount").gameObject:SetActive(true)
            self.infoDiscountText.text = tostring(shopData.discount / 100)
            self.infoOriginCurrencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, currencyRes)
            self.infoNowCurrencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, currencyRes)

            self.infoLimit1Text.gameObject:SetActive(true)
            self.infoLimit2Text.gameObject:SetActive(false)
            self.infoLimit1Text.text = limitText
        else
            self.infoPriceObj:SetActive(false)
            self.selectUniprice = shopData.price
            self.itemPrice.text = tostring(self.selectUniprice)
            self.infoLimit1Text.gameObject:SetActive(false)
            self.infoLimit2Text.gameObject:SetActive(true)
            self.infoLimit2Text.text = limitText
        end
    else
        -- t:Find("Price").gameObject:SetActive(false)
        self.infoPriceObj.gameObject:SetActive(false)
        if model.selectedInfo ~= nil then
            self.selectUniprice = model.selectedInfo.price
            self.itemPrice.text = tostring(self.selectUniprice)
        else
            self.selectUniprice = 0
            self.itemPrice.text = "0"
        end
    end
    self.buyNumObj:GetComponent(Text).text = "1"
    -- local priceTemp = tonumber(self.itemPrice.text)
    -- if tonumber(self.ownAssetText.text) < priceTemp then
    --     self.itemPrice.text = ColorHelper.Fill(ColorHelper.color[6], tostring(priceTemp))
    -- end
    self.ownAssetCurrencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, currencyRes)
    self.itemCurrecy.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, currencyRes)
    self:RoleAssetsListener()

end

function ShopWindow:OnClickItem(data)
    -- if self.lastTime == nil then
    --     self.lastTime = 0
    -- end

    -- if self.lastSelectTag == data.tag and BaseUtils.BASE_TIME - self.lastTime < 5 then
    --     self:ShowChargeView(data)
    -- else
    --     self.lastSelectTag = data.tag
    --     self.lastTime = BaseUtils.BASE_TIME
    --     NoticeManager.Instance:FloatTipsByString(TI18N("再次点击确认购买"))
    -- end

    self:ShowChargeView(data)
end

function ShopWindow:ShowChargeView(data)
    -- BaseUtils.dump(data)
    -- KKKSdkWrapper.Instance:Buy(data.tag, data.rmb, data.gold)
    if SdkManager.Instance:RunSdk() then
        SdkManager.Instance:ShowChargeView(data.tag, data.rmb, data.gold)
    end
end
