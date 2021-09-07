BuyNotify = BuyNotify or BaseClass(BasePanel)

function BuyNotify:__init(idToNumPrice, baseidToNeed,  onClick, content)
    self.idToNumPrice = idToNumPrice
    self.baseidToNeed = baseidToNeed
    self.buybutton = nil
    self.content = content
    self.onClick = function() self:Hiden() onClick() end
    self.resList = {
        {file = AssetConfig.buy_notify, type = AssetType.Main},
        {file = AssetConfig.quickbuybg_textures, type = AssetType.Main},
        {file = AssetConfig.shop_textures, type = AssetType.Dep}
        -- {file = AssetConfig.dragonboat_consumebg2, type = AssetType.Main}
    }
    self.itemObj = {}
    self.slotList = {}
    self.assetString = TI18N("货币")
    self.extraString = TI18N("%s不足，可花费{assets_2, %s}兑换")
    self.descString = TI18N("系统自动在<color='#ffff00'>%s购买</color>以下道具")

    self.theAssets = nil
    self.iconloader = {}

    -- 新增礼包购买 (by zhouyijun)
    self.giftSlotList = {}
    self.giftIdList = {}
    self.giftItemList = {}
    self.isLoadedGiftList = false
    self.giftItemIcon_1 = {}
    self.giftItemIcon_2 = {}

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.OnOpenEvent:Add(self.openListener)
    self.OnHideEvent:Add(self.hideListener)

    self.on_buyResponse = function(val) self:OnBuyResult(val) end
    EventMgr.Instance:AddListener(event_name.shop_buy_result, self.on_buyResponse)
end

function BuyNotify:__delete()
    EventMgr.Instance:RemoveListener(event_name.shop_buy_result, self.on_buyResponse)
    for k,v in pairs(self.iconloader) do
        v:DeleteMe()
    end
    self.iconloader = {}

    for k,v in pairs(self.giftItemIcon_1) do
        v:DeleteMe()
    end
    self.giftItemIcon_1 = {}
    for k,v in pairs(self.giftItemIcon_2) do
        v:DeleteMe()
    end
    self.giftItemIcon_2 = {}



    if self.slotList ~= nil then
        for _,v in pairs(self.slotList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.slotList = nil
    end

    if self.giftSlotList ~= nil then
        for _,v in pairs(self.giftSlotList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.giftSlotList = nil
    end


    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
    self.OnOpenEvent:Remove(self.openListener)
    self.OnHideEvent:Remove(self.hideListener)
end

function BuyNotify:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.buy_notify))
    local t = self.gameObject.transform
    self.gameObject.name = "BuyNotify"
    -- UIUtils.AddUIChild(NoticeManager.Instance.model.noticeCanvas, self.gameObject)
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)
    local area = t:Find("Main/Area")

    self.buybutton = area:Find("Button")
    self.descText = t:Find("Main/Text"):GetComponent(Text)
    self.contentText = self.buybutton:Find("Text"):GetComponent(Text)
    self.contentExt = MsgItemExt.New(self.contentText, 300, 17, 20)
    self.buybutton:GetComponent(Button).onClick:RemoveAllListeners()
    self.buybutton:GetComponent(Button).onClick:AddListener(self.onClick)
    self.extraBg = t:Find("Main/Extra")
    self.extraExt = MsgItemExt.New(t:Find("Main/Extra/Text"):GetComponent(Text), 400, 17, 20)

    self.container = t:Find("Main/Layout/Container").gameObject
    self.itemTemplate = t:Find("Main/Layout/Container/Item").gameObject
    self.itemTemplate:SetActive(false)

    --右侧新增礼包模块—— by zhouyijun
    self.buyGiftPanel = t:Find("BuyGiftPanel").transform
    self.buyGiftPanel.anchoredPosition = Vector2(0,-20000)
    UIUtils.AddBigbg(self.buyGiftPanel:Find("Image"), GameObject.Instantiate(self:GetPrefab(AssetConfig.quickbuybg_textures)))
    self.giftItemModel = self.buyGiftPanel:Find("Layout/Container/Item").gameObject
    self.giftItemModel:SetActive(false)

    self:ResetData(self.idToNumPrice, self.baseidToNeed)
    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function ()
        self:Hiden()
    end)



    t:SetAsFirstSibling()
end

function BuyNotify:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function BuyNotify:OnOpen()
    self:Reload()
end
function BuyNotify:OnHide()
    self.isLoadedGiftList = false
    if self.giftItemList ~= nil then
        for k,v in pairs(self.giftItemList) do
            GameObject.DestroyImmediate(v.gameObject)
            -- self.giftItemList[k] = nil
        end
        self.giftItemList = {}
    end

    if self.giftIdList ~= nil then
        self.giftIdList = {}
    end
    if self.giftSlotList ~= nil then
        self.giftSlotList = {}
    end
end

function BuyNotify:ResetData(idToNumPrice, baseidToNeed)
    self.idToNumPrice = idToNumPrice

    self.baseidToNeed = baseidToNeed
    self:Reload()
end

function BuyNotify:Reload()
    local c = 1
    local money = 0
    local i = 0
    self.isNeedStarGold = false
    self.isNeedGold = false

    local star_gold = RoleManager.Instance.RoleData.star_gold
    local inMarket = false
    local inShop = false

    for k,v in pairs(self.idToNumPrice) do
        inShop = inShop or (v.source == MarketEumn.SourceType.Shop)
        inMarket = inMarket or (v.source == MarketEumn.SourceType.Market)

        i = i + 1
        local item = nil
        local t = self.container.transform:Find(tostring(c))
        if t == nil then
            item = GameObject.Instantiate(self.itemTemplate)
            item.name = tostring(c)
            item.transform:SetParent(self.container.transform)
            item.transform.localScale = Vector3.one
            t = item.transform
        else
            item = t.gameObject
        end
        item:SetActive(true)
        self.slotList[i] = self.slotList[i] or ItemSlot.New()
        self:SetItem(item, k, v, self.slotList[i])

        self.isNeedStarGold = self.isNeedStarGold or (v.isDouble == true)

        money = money + v.money
        c = c + 1
    end

    for i=c,4 do
        local obj = self.container.transform:Find(tostring(i))
        if obj ~= nil then
            obj.gameObject:SetActive(false)
        end
    end

    -- self.contentText.text = tostring(self.content)
    -- self.numText.text = tostring(money)

    local assetString = self.assetString

    if self.theAssets == KvData.assets.gold or self.theAssets == KvData.assets.star_gold or self.theAssets == KvData.assets.star_gold_or_gold then
        if self.isNeedStarGold == true then
            self.contentExt:SetData(string.format("%s{assets_2, %s}%s", tostring(money), "29255", self.content))
            self.extraExt:SetData(TI18N("购买钥匙并赠送一次抽奖机会"))
        else
            self.contentExt:SetData(string.format("%s{assets_2, %s}%s", tostring(money), "90002", self.content))
            self.extraExt:SetData(TI18N("购买钥匙并赠送一次抽奖机会"))
        end
    else
        assetString = GlobalEumn.AssetName[self.theAssets] or self.assetString

        if self.isNeedStarGold == true then
            self.contentExt:SetData(string.format("%s{assets_2, %s}%s", tostring(money), "29255", self.content))
            self.extraExt:SetData(string.format(self.extraString, assetString, "29255"))
        else
            self.contentExt:SetData(string.format("%s{assets_2, %s}%s", tostring(money), "90002", self.content))
            self.extraExt:SetData(string.format(self.extraString, assetString, "90002"))
        end
    end

    local size = self.extraExt.contentRect.sizeDelta
    self.extraExt.contentRect.anchoredPosition = Vector2(-size.x/2, -2)
    self.extraBg.transform.sizeDelta = Vector2(size.x + 10, 24)

    if inShop == true then
        if inMarket == true then
            self.descText.text = TI18N("系统自动<color='#ffff00'>购买</color>以下道具")
        else
            self.descText.text = string.format(TI18N("系统自动在<color='#ffff00'>%s购买</color>以下道具"), TI18N("商城"))
        end
    else
        if inMarket == true then
            self.descText.text = string.format(TI18N("系统自动在<color='#ffff00'>%s购买</color>以下道具"), TI18N("市场"))
        end
    end

    -- if self.isNeedGold == true then
    -- elseif self.isNeedStarGold == true then
    --     self.contentExt:SetData(string.format("%s{assets_2, %s}%s", tostring(money), "90026", self.content))
    -- end

    self:ResizeButton()

    ---------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------
    -----------------------右侧新增礼包模块—— by zhouyijun---------------------------
    ---------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------
    --判断礼包数量，显示礼包购买列表项
    if  self.giftIdList ~= nil and #self.giftIdList > 0 then
        if not self.isLoadedGiftList then
            print("<color='#ff0000'>加载对应礼包列表</color>")
            local j = 0
            for k, v in pairs(self.giftIdList) do
                if self:IsExistPriceTab(v) then
                    local item = GameObject.Instantiate(self.giftItemModel)--克隆giftNum个礼包Item
                    j = j + 1
                    item.name = tostring(j)
                    item.transform:SetParent(self.giftItemModel.transform.parent)
                    item.transform.localScale = Vector3.one
                    item.transform.localPosition =Vector3(0, 0, 0)

                    item:SetActive(true)
                    self.giftSlotList[j]  = self.giftSlotList[j]  or ItemSlot.New()
                    self:SetGiftItem(item.transform, v, self.giftSlotList[j])

                    item.transform:Find("ItemBg/Button"):GetComponent(Button).onClick:AddListener(function() self:BuyBtnClick(item, v) end)

                else

                    print("不存在商城编号：<color='#ff0000'>"..v.."</color>")

                    --------------------------------------------------------------------------------
                    --模拟商城编号------------------------------------------------------------
                    --------------------------------------------------------------------------------
                    -- local priceId = 1
                    -- local item = GameObject.Instantiate(self.giftItemModel)--克隆giftNum个礼包Item
                    -- j = j + 1
                    -- item.name = tostring(j)
                    -- item.transform:SetParent(self.giftItemModel.transform.parent)
                    -- item.transform.localScale = Vector3.one
                    -- item.transform.localPosition =Vector3(0, 0, 0)

                    -- item:SetActive(true)
                    -- self.giftSlotList[j]  = self.giftSlotList[j]  or ItemSlot.New()
                    -- self:SetGiftItem(item.transform, priceId, self.giftSlotList[j])

                    -- item.transform:Find("ItemBg/Button"):GetComponent(Button).onClick:AddListener(function() self:BuyBtnClick(item, priceId) end)
                    --------------------------------------------------------------------------------
                    --------------------------------------------------------------------------------
                    --------------------------------------------------------------------------------
                end

            end
            self.isLoadedGiftList = true

            if self:IsNullTabel(self.giftItemList) ~= nil then
                self.gameObject.transform:Find("Main").anchoredPosition = Vector2(-161,0)
                self.buyGiftPanel.anchoredPosition = Vector2(161,0)
            else
                self.gameObject.transform:Find("Main").anchoredPosition = Vector2(0,0)
                self.buyGiftPanel.anchoredPosition = Vector2(161,-20000)
            end
        end
    end
    if self.giftIdList == nil or #self.giftIdList <= 0 then

        print("<color='#ff0000'>关系表中没有对应id</color>")

        self.gameObject.transform:Find("Main").anchoredPosition = Vector2(0,0)
        self.buyGiftPanel.anchoredPosition = Vector2(161,-20000)
    end
    -- if self.buyGiftPanel.anchoredPosition.y > -20000 then
    --     self.gameObject.transform:Find("Main").anchoredPosition = Vector2(-161,0)
    -- end
end

function BuyNotify:SetItem(obj, base_id, tab, slot)
    local num = tab.num
    local money = tab.money
    local assets = tab.assets
    local t = obj.transform
    -- local iconImage = t:Find("Bg/Icon"):GetComponent(Image)
    local nameText = t:Find("Name"):GetComponent(Text)
    -- local numText = t:Find("NumBg/Num"):GetComponent(Text)
    local moneyText = t:Find("Money"):GetComponent(Text)
    local assetImage = t:Find("Money/Image"):GetComponent(Image)
    local data = ItemData.New()

    if GlobalEumn.CostTypeIconName[tab.assets] == nil then
        -- print("----------ddddddddddddddddd")
        -- print(debug.traceback())
        -- BaseUtils.dump(tab)
        -- print(tab.asset)
        -- print(DataItem.data_get[tab.asset])
        -- print(DataItem.data_get[tab.asset].icon)
        local id = assetImage.gameObject:GetInstanceID()
        if self.iconloader[id] == nil then
            self.iconloader[id] = SingleIconLoader.New(assetImage.gameObject)
        end
        self.iconloader[id]:SetSprite(SingleIconType.Item, DataItem.data_get[tab.assets].icon)
    else
        assetImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[tab.assets])
    end
    nameText.text = DataItem.data_get[base_id].name
    NumberpadPanel.AddUIChild(t:Find("Bg").gameObject, slot.gameObject)
    data:SetBase(DataItem.data_get[base_id])
    slot:SetAll(data, {inbag = false, nobutton = true})
    slot:SetNum(num)
    -- numText.text = tostring(num)
    moneyText.text = string.format("<color='#ff0000'>%s</color>", tostring(tab.assets_num))

    local width = moneyText.preferredWidth
    assetImage.transform.anchoredPosition = Vector2(0, 0)
    moneyText.transform.sizeDelta = Vector2(math.ceil(width), 30)
    moneyText.transform.anchoredPosition = Vector2((25 - width) / 2, -57.73)

    if self.theAssets == nil then
        self.theAssets = tab.assets
    elseif self.theAssets ~= tab.assets then
        self.theAssets = -1
    end

    --通过这个base_id 获取商城编号列表
    -- DataShop.data_quickshoprel[base_id].id -- 是一个table
    if nil ~= self.giftIdList then
        if DataShop.data_quickshoprel[base_id] ~= nil then
            for k,v in pairs(DataShop.data_quickshoprel[base_id].id) do
                for i,j in pairs(v) do
                    table.insert(self.giftIdList, j)
                end
            end
        end
    end
end

function BuyNotify:SetGiftItem(t, id, slot)

    local priceId = id

    --------------------------------------------------------------------------------
    --判断是否有商城编号----------------------------------------------------------------------
    --------------------------------------------------------------------------------
    -- if not self:IsExistPriceTab(id) then
    --     print("不存在商城编号：<color='#ff0000'>"..id.."</color>")
    --     return
    -- end

    local k = ShopManager.Instance.itemPriceTab[priceId].base_id
    --获得Icon
    NumberpadPanel.AddUIChild(t:Find("ItemBg/IconBg").gameObject, slot.gameObject)
    local data = ItemData.New()
    data:SetBase(DataItem.data_get[k])
    slot:SetAll(data, {inbag = false, nobutton = true})

    --名称
    local tName =t:Find("ItemBg/Name"):GetComponent(Text)
    tName.text = DataItem.data_get[k].name --DataShop.data_goods["1_18_" .. priceId].name
    -- tName.transform:GetComponent(RectTransform).anchoredPosition = Vector2(-55, -31)
    -- tName.color = Color(172/255, 60/255, 0, 1)

    --处理货币 图标
    local astype = KvData.assets[ShopManager.Instance.itemPriceTab[priceId].assets_type]
    --原价
    t:Find("ItemBg/Original_PriceBg/Original_Price"):GetComponent(Text).text = tostring(ShopManager.Instance.itemPriceTab[priceId].price)
    --现价
    local dis = ShopManager.Instance.itemPriceTab[priceId].discount
    local nowPrice = ShopManager.Instance.itemPriceTab[priceId].price * dis / 1000
    -- local strTmp = string.format(ColorHelper.ListItemStr, "现价:")
    local priceNum

    local myAssetsNum = RoleManager.Instance.RoleData:GetMyAssetById(astype)
    if myAssetsNum < nowPrice then -- player.goldNUm < nowPrice then -- 如果当前没有这么多货币，显示红色,否则显示绿色
        priceNum = "<color='#ff0000'>"..tostring(nowPrice).."</color>"
    else
        priceNum = "<color='#ffffff'>"..tostring(nowPrice).."</color>"
    end
    t:Find("ItemBg/Current_PriceBg/Current_Price"):GetComponent(Text).text = priceNum


    ---------------------------------------------------------------
    local assetImage = t:Find("ItemBg/Original_PriceBg/Image"):GetComponent(Image)
    if GlobalEumn.CostTypeIconName[astype] == nil then
        local id = assetImage.gameObject:GetInstanceID()
        if self.giftItemIcon_1[id] == nil then
            self.giftItemIcon_1[id] = SingleIconLoader.New(assetImage.gameObject)
        end
        self.giftItemIcon_1[id]:SetSprite(SingleIconType.Item, DataItem.data_get[astype].icon)
    else
        assetImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[astype])
    end
    ---------------------------------------------------------------
    local assetImage_2 = t:Find("ItemBg/Current_PriceBg/Image"):GetComponent(Image)
    if GlobalEumn.CostTypeIconName[astype] == nil then
        local id = assetImage_2.gameObject:GetInstanceID()
        if self.giftItemIcon_2[id] == nil then
            self.giftItemIcon_2[id] = SingleIconLoader.New(assetImage_2.gameObject)
        end
        self.giftItemIcon_2[id]:SetSprite(SingleIconType.Item, DataItem.data_get[astype].icon)
    else
        assetImage_2.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[astype])
    end
    ---------------------------------------------------------------
    -- t:Find("ItemBg/noPrice"):GetComponent(RectTransform).anchoredPosition = Vector2(0, 25)
    -- t:Find("ItemBg/noPrice"):GetComponent(RectTransform).sizeDelta = Vector2(100, 20)

    --折扣
    local disN = dis*1.0/100.0
    local tDis = t:Find("ItemBg/Discount")
    if disN >= 10 then
        tDis.gameObject:SetActive(false)
        t.transform:Find("ItemBg/Button"):GetComponent(RectTransform).anchoredPosition = Vector2(96, 0)
    else
        tDis.gameObject:SetActive(true)
        tDis:Find("DisTxt"):GetComponent(Text).text = tostring(disN)
        t.transform:Find("ItemBg/Button"):GetComponent(RectTransform).anchoredPosition = Vector2(96, -10)

    end

    self.giftItemList[t.gameObject.name] = t
end

--判断是否存在商城编号
function BuyNotify:IsExistPriceTab(shopPriceId)
    if ShopManager.Instance.itemPriceTab[shopPriceId] ~= nil then
        return self:IsCanBuy(shopPriceId)
        -- 可购买数量： ShopManager.Instance.itemPriceTab.limit_role + privilegeNum
        -- 已购买数量： ShopManager.Instance.model.hasBuyList[]   model.hasBuyList[v.id]
    else
        return false
    end
    -- for k,v in pairs(ShopManager.Instance.itemPriceTab) do
    --     if k == shopPriceId then -- 判断itemPriceTab中是否包含表中索引到的 商城编号
    --         return true
    --     end
    -- end
    -- return false
end

function BuyNotify:IsCanBuy( shopPriceId )
    local data = ShopManager.Instance.itemPriceTab[shopPriceId]
    local privilegeNum = 0
    if data.privilege_lev ~= nil and (PrivilegeManager.Instance.lev or 0) >= data.privilege_lev then
        local privilege_lev = PrivilegeManager.Instance.lev
        for i,v in ipairs(data.privilege_role) do
            if v.p_lev == privilege_lev then
                privilegeNum = v.p_num
            end
        end
    end
    if data.limit_role == -1 then
        return true
    else
        local canBuyNum = data.limit_role + privilegeNum
        local hasBuyNum = ShopManager.Instance.model.hasBuyList[data.id]
        if hasBuyNum == nil then
            -- print("<color=green>hasBuyNum = nil</color>")
            return true
        else
            -- print ("<colro = red>canBuyNum = ".. canBuyNum .."</color>")
            -- print ("<colro = red>shopPriceId = ".. shopPriceId .."</color>")
            -- BaseUtils.dump(ShopManager.Instance.model.hasBuyList,"<colro = red>hasBuyList")
            -- print ("<colro = red>hasBuyNum = ".. hasBuyNum .."</color>")
            return canBuyNum > hasBuyNum
        end
    end
end



--判断一个Table 是否为空
function BuyNotify:IsNullTabel(t)
    if t == nil then
        return nil
    end
    for k,v in pairs(t) do
        if v ~= nil then
            return t
        end
    end
    return nil
end

function BuyNotify:BuyBtnClick(item, v)
    -- 参数v 是对应的礼包 id
    -- 进行购买操作
    ShopManager.Instance:send11303(v, 1)
    self.clickItem = item
    self.clickV = v

    -- 处理 Item 对象
    -- self.giftItemList[item.name] = nil

    -- GameObject.DestroyImmediate(item) -- 删除Item

    -- if self:IsNullTabel(self.giftItemList) == nil then
    --     self.buyGiftPanel.anchoredPosition = Vector2(161,-20000)
    --     self.gameObject.transform:Find("Main").anchoredPosition = Vector2(0,0)
    -- end
end

function BuyNotify:OnBuyResult(val)
    if self.clickV == nil then
        return
    end
    print("<color='#00ff00'>快捷购买礼包id = ".. self.clickV .."回应</color>")
    if val == 1 then --购买成功
        --处理 Item 对象
        if not self:IsCanBuy(self.clickV) then
            self.giftItemList[self.clickItem.name] = nil
            GameObject.DestroyImmediate(self.clickItem) -- 删除Item
        end

        if self:IsNullTabel(self.giftItemList) == nil then
            self.buyGiftPanel.anchoredPosition = Vector2(161,-20000)
            self.gameObject.transform:Find("Main").anchoredPosition = Vector2(0,0)
        end
    else
        --处理货币 类型
        local astype = KvData.assets[ShopManager.Instance.itemPriceTab[self.clickV].assets_type]
        --现价
        local dis = ShopManager.Instance.itemPriceTab[self.clickV].discount
        local nowPrice = ShopManager.Instance.itemPriceTab[self.clickV].price * dis / 1000
        local myAssetsNum = RoleManager.Instance.RoleData:GetMyAssetById(astype)
        if myAssetsNum < nowPrice then
            self.onClick()
        end
    end
end


function BuyNotify:ResizeButton()
    local rect = self.buybutton.gameObject:GetComponent(RectTransform)
    -- local originHeight = rect.sizeDelta.y

    -- local contentRect = self.contentText.gameObject:GetComponent(RectTransform)
    -- local contentHeight = contentRect.sizeDelta.y
    -- local contentWidth = self.contentText.preferredWidth
    -- contentRect.sizeDelta = Vector2(contentWidth, contentHeight)

    -- local numRect = self.numText.gameObject:GetComponent(RectTransform)
    -- local numHeight = numRect.sizeDelta.y
    -- local numWidth = self.numText.preferredWidth
    -- numRect.sizeDelta = Vector2(numWidth, numHeight)

    -- local imageWidth = self.image.gameObject:GetComponent(RectTransform).sizeDelta.x

    -- local totalWidth = numWidth + imageWidth + contentWidth + 2 -- 2 是content和钻石图标之间的间距

    -- if totalWidth < 92 then
    --     rect.sizeDelta = Vector2(112, originHeight)
    -- else
    --     rect.sizeDelta = Vector2(totalWidth + 20, originHeight)
    -- end
    -- contentRect.anchoredPosition = Vector2((totalWidth - contentWidth) / 2, 0)

    rect.sizeDelta = Vector2(self.contentExt.contentRect.sizeDelta.x + 20, self.contentExt.contentRect.sizeDelta.y + 20)
    self.contentExt.contentRect.anchoredPosition = Vector2(-self.contentExt.contentRect.sizeDelta.x / 2, self.contentExt.contentRect.sizeDelta.y / 2)
end