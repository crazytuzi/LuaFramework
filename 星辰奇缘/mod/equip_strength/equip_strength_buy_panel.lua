-- 强化石快捷购买
-- zzl 20170221

EquipStrengthBuyPanel = EquipStrengthBuyPanel or BaseClass(BasePanel)

function EquipStrengthBuyPanel:__init(parent)
    self.parent = parent
    self.model = EquipStrengthManager.Instance.model
    self.resList = {
        {file = AssetConfig.equip_strength_buy_panel, type = AssetType.Main},
    }


    self.leftBaseId = 0
    self.rightBaseId = 0
    self.leftSinglePrice = 0
end

function EquipStrengthBuyPanel:__delete()
    if self.leftSlot ~= nil then
        self.leftSlot:DeleteMe()
        self.leftSlot = nil
    end

    if self.rightSlot ~= nil then
        self.rightSlot:DeleteMe()
        self.rightSlot = nil
    end

    if self.LeftBuyBtn ~= nil then
        self.LeftBuyBtn:DeleteMe()
        self.LeftBuyBtn = nil
    end

    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
end

function EquipStrengthBuyPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.equip_strength_buy_panel))
    self.gameObject.name = "EquipStrengthBuyPanel"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.transform:FindChild("panel"):GetComponent(Button).onClick:AddListener(function() self.model:CloseStrengthBuyUI() end)
    self.MainCon = self.transform:FindChild("MainCon")
    self.MainCon:FindChild("CloseButton"):GetComponent(Button).onClick:AddListener(function() self.model:CloseStrengthBuyUI() end)

    self.LeftCon = self.MainCon:FindChild("LeftCon")
    self.LeftTopCon = self.LeftCon:FindChild("TopCon")
    self.LeftSlotNameText = self.LeftTopCon:FindChild("Text"):GetComponent(Text)
    self.MidCon = self.LeftCon:FindChild("MidCon")
    self.LeftBuyCount = self.MidCon:FindChild("BuyCount")
    self.LeftCountTxt = self.LeftBuyCount:FindChild("CountBg/Count"):GetComponent(Text)
    self.LeftAddBtn = self.LeftBuyCount:FindChild("AddBtn"):GetComponent(Button)
    self.LeftMinusBtn = self.LeftBuyCount:FindChild("MinusBtn"):GetComponent(Button)
    self.LeftPriceAllPrice = self.MidCon:FindChild("BuyPrice/PriceBg/Price"):GetComponent(Text)
    self.LeftBtnBuyCon = self.LeftCon:FindChild("BtnBuy").gameObject
    self.LeftBuyBtn = BuyButton.New(self.LeftBtnBuyCon, TI18N("购 买"))
    self.LeftBuyBtn.key = "EquipStrengthBuy"
    self.LeftBuyBtn:Show()

    self.RightCon = self.MainCon:FindChild("RightCon")
    self.RightTopCon = self.RightCon:FindChild("TopCon")
    self.RightTopSlotCon = self.RightTopCon:FindChild("SlotCon")
    self.RightSlotNameText = self.RightTopCon:FindChild("Text"):GetComponent(Text)
    self.MidCon = self.RightCon:FindChild("MidCon")
    self.RightOriginalTxt = self.MidCon:FindChild("Price/Prices"):GetComponent(Text)
    self.RightDiscountTxt = self.MidCon:FindChild("Price/Discount/Discount"):GetComponent(Text)
    self.RightBtnBuy = self.RightCon:FindChild("BtnBuyBag"):GetComponent(Button)
    self.RightBtnBuyCon = self.RightCon:FindChild("BtnBuy").gameObject
    -- self.RightBuyBtn = BuyButton.New(self.RightBtnBuyCon, TI18N("购 买"))
    -- self.RightBuyBtn:Show()

    self.LeftAddBtn.onClick:AddListener(function()
        local curNum = tonumber(self.LeftCountTxt.text)
        if curNum < 99 then
            self.LeftPriceAllPrice.text = (curNum + 1)*self.leftSinglePrice
            self.LeftCountTxt.text = tostring(curNum + 1)
        end
    end)
    self.LeftMinusBtn.onClick:AddListener(function()
        local curNum = tonumber(self.LeftCountTxt.text)
        if curNum > 1 then
            self.LeftPriceAllPrice.text = (curNum - 1)*self.leftSinglePrice
            self.LeftCountTxt.text = tostring(curNum - 1)
        end
    end)
    self.onLeftPriceBack = function(price)
        if price[self.leftBaseId] ~= nil then
            self.leftSinglePrice = price[self.leftBaseId].allprice
            self.LeftCountTxt.text = tostring(1)
            self.LeftPriceAllPrice.text = tostring(self.leftSinglePrice)
        end
    end
    self.onClickLeftBuyBtn = function()
        MarketManager.Instance:send12401(self.leftBaseId, tonumber(self.LeftCountTxt.text))
        self.LeftBuyBtn:ReleaseFrozon()
    end

    self.onRightPriceBack =function(price)
            -- self.rightBaseId = 0
    end
    self.onClickRightBuyBtn = function()
        -- 12401
        local tempPriceData = nil
        for k, v in pairs(ShopManager.Instance.itemPriceTab) do
            if v.base_id == self.rightBaseId then
                tempPriceData = v
                break
            end
        end

        local shopModel = ShopManager.Instance.model

        -- print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkddddddddddddddddd")
        -- print(shopModel.hasBuyList ~= nil)
        -- print(shopModel.hasBuyList[tempPriceData.id] ~= nil)

        -- if  shopModel.hasBuyList ~= nil and  shopModel.hasBuyList[tempPriceData.id] ~= nil and (((tempPriceData.tab ~= 1 or tempPriceData.tab2 ~= 3) and  shopModel.hasBuyList[tempPriceData.id] >=  shopModel.itemBuyLimitList[tempPriceData.id]) or (tempPriceData.tab == 1 and tempPriceData.tab2 == 3 and tempPriceData.flag == 1)) then
        --     NoticeManager.Instance:FloatTipsByString(TI18N("已经售罄"))
        --     return
        -- end


        ShopManager.Instance:send11303(tempPriceData.id, 1)
    end

    self.RightBtnBuy.onClick:AddListener(function()
        self:onClickRightBuyBtn()
    end)

    self:UpdateLeftCon()
    self:UpdateRightCon()
end

--更新左边
function EquipStrengthBuyPanel:UpdateLeftCon()
    --12以上 是精良，20400
    --12一下，普通 20020
    local baseId = 20020
    print("-------------------ddddddddddd")
    BaseUtils.dump(self.openArgs)
    if self.openArgs >= 12 then
        baseId = 20400
    end
    self.leftBaseId = baseId
    local baseData = DataItem.data_get[baseId]
    self.LeftSlotNameText.text = baseData.name

    self.leftSlot = self:CreateSlot(self.LeftTopCon)
    self:SetSlotData(self.leftSlot,baseId)

    local buyList = {}
    buyList[baseId] = {need = 1}
    self.LeftBuyBtn:Layout(buyList, self.onClickLeftBuyBtn, self.onLeftPriceBack)
end

--更新右边
function EquipStrengthBuyPanel:UpdateRightCon()
    --12以上， 是精良，22547
    --12一下，普通 22541
    local baseId = 22541
    if self.openArgs >= 12 then
        baseId = 22547
    end
    self.rightBaseId = baseId
    local baseData = DataItem.data_get[baseId]
    self.RightSlotNameText.text = baseData.name
    self.RightOriginalTxt.text = ""

    self.rightSlot = self:CreateSlot(self.RightTopSlotCon)
    self:SetSlotData(self.rightSlot, baseId)

    -- local buyList = {}
    -- buyList[baseId] = {need = 1}
    -- self.RightBuyBtn:Layout(buyList, self.onClickRightBuyBtn, nil)

    local tempPriceData = nil
    for k, v in pairs(ShopManager.Instance.itemPriceTab) do
        if v.base_id == baseId then
            tempPriceData = v
            break
        end
    end
    local curPrice = 0
    local shopData = ShopManager.Instance.itemPriceTab[tempPriceData.id]
    if shopData.discount > 0 then
        curPrice = math.ceil(tempPriceData.price * shopData.discount / 1000)
    end
    self.RightOriginalTxt.text = string.format("%s\n%s", tempPriceData.price, curPrice)
    self.RightDiscountTxt.text = tostring(math.ceil(shopData.discount / 10) / 10)
end


--为每个武器创建slot
function EquipStrengthBuyPanel:CreateSlot(slot_con)
    local stone_slot = ItemSlot.New()
    stone_slot.gameObject.transform:SetParent(slot_con)
    stone_slot.gameObject.transform.localScale = Vector3.one
    stone_slot.gameObject.transform.localPosition = Vector3.zero
    stone_slot.gameObject.transform.localRotation = Quaternion.identity
    local rect = stone_slot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
    return stone_slot
end

--对slot设置数据
function EquipStrengthBuyPanel:SetSlotData(slot, base_id)
    local cell = ItemData.New()
    local itemData = DataItem.data_get[base_id] --设置数据
    cell:SetBase(itemData)
    slot:SetAll(cell, nil)
    slot:SetNotips(true)
end