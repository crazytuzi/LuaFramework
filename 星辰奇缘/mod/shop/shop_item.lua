ShopItem = ShopItem or BaseClass()

function ShopItem:__init(model, gameObject, callback)
    self.model = model
    self.gameObject = gameObject
    self.callback = callback
    self.mgr = ShopManager.Instance

    local t = gameObject.transform
    self.nameText = t:Find("Name"):GetComponent(Text)
    self.priceText = t:Find("PriceBg/Price"):GetComponent(Text)
    self.iconBtn = t:Find("IconBg"):GetComponent(Button)
    self.selectObj = t:Find("Select").gameObject
    self.tipsImage = t:Find("TipsLabel"):GetComponent(Image)
    self.tipsText = t:Find("TipsLabel/Text"):GetComponent(Text)

    -- self.tipsGlory = t:Find("TipsGlory"):GetComponent(Image)
    self.discountObj = t:Find("Discount").gameObject
    self.discountText = t:Find("Discount/Discount"):GetComponent(Text)
    self.soldoutObj = t:Find("SoldoutImage").gameObject
    self.numBg = t:Find("NumBg")
    self.numText = t:Find("Num"):GetComponent(Text)
    self.pieceImage = t:Find("Piece"):GetComponent(Image)
    self.hasGet = t:Find("HasGet").gameObject
    self.btn = gameObject:GetComponent(Button)

    self.iconObj = t:Find("IconBg/Icon").gameObject
    self.currencyObj = t:Find("PriceBg/Currency").gameObject
    -- self.currencyLoader = SingleIconLoader.New()

    self.iconBtn.onClick:AddListener(function() self:OnClickIcon() end)

    self.numText.gameObject:SetActive(true)
    self.hasGet:SetActive(false)
end

function ShopItem:__delete()
    self.tipsImage.sprite = nil
    self.pieceImage.sprite = nil
    self.btn.onClick:RemoveAllListeners()
    self.iconBtn.onClick:RemoveAllListeners()
    self.callback = nil
    if self.iconLoader ~= nil then
        self.iconLoader:DeleteMe()
        self.iconLoader = nil
    end
    if self.currencyLoader ~= nil then
        self.currencyLoader:DeleteMe()
        self.currencyLoader = nil
    end
end

function ShopItem:SetData(data, index) -- data 是协议数据
    -- data = DataShop.data_goods[string.format("%s_%s_%s", tostring(data.tab), tostring(data.tab2), tostring(data.id))] -- 商城表数据
    -- print(data.base_id)
    local baseData = DataItem.data_get[data.base_id]    -- 基础数据
    local roledata = RoleManager.Instance.RoleData

    if baseData == nil then
        Log.Error(string.format("找不到base_id=%s的物品基础数据", tostring(data.base_id)))
        return
    end

    local model = self.model
    local currency = nil
    if data == nil then
        if data.tab == 2 and data.tab2 == 1 then
            currency = KvData.assets["stars_score"]
        elseif data.tab == 2 and data.tab2 == 2 then
            currency = KvData.assets["love"]
        elseif data.tab == 2 and data.tab2 == 3 then
            currency = KvData.assets["character"]
        elseif data.tab == 2 and data.tab2 == 5 then
            currency = KvData.assets["tournament"]
        else
            currency = KvData.assets["gold"]
        end
    else
        currency = KvData.assets[data.assets_type] or data.asset_type
    end

    self.nameText.text = baseData.name
    if self.iconLoader == nil then
        self.iconLoader = SingleIconLoader.New(self.iconObj)
    end
    self.iconLoader:SetSprite(SingleIconType.Item, baseData.icon)
    self.selectObj:SetActive(false)

    if self.currencyLoader == nil then
        self.currencyLoader = SingleIconLoader.New(self.currencyObj)
    end
    if currency == 29255 then
        self.currencyLoader.gameObject.transform.sizeDelta = Vector2(36, 36)
    else
        self.currencyLoader.gameObject.transform.sizeDelta = Vector2(28, 28)
    end
    if GlobalEumn.CostTypeIconName[currency] ~= nil then
        self.currencyLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[currency]))
    else
        self.currencyLoader:SetSprite(SingleIconType.Item, DataItem.data_get[currency].icon)
    end

    -- 设置标签，新片or热卖
    if data ~= nil and (data.label ~= 0 or (data.privilege_lev ~= nil and data.privilege_lev > 0)) then
        if #data.achievement_limit == 0 then
            self.tipsImage.gameObject:SetActive(true)
            if data.privilege_lev == 6 then
                self.tipsImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Tipslabel3")
                self.tipsText.text = TI18N("超值")
                self.tipsText.color = Color(1,1,1)
                -- self.tipsImage.gameObject:SetActive(true)
                -- self.tipsGlory.gameObject:SetActive(false)
            elseif data.label == 1 then
                self.tipsImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Tipslabel2")
                self.tipsText.text = TI18N("热卖")
                self.tipsText.color = Color(177/255,34/255,34/255)
                -- self.tipsImage.gameObject:SetActive(true)
                -- self.tipsGlory.gameObject:SetActive(false)
            elseif data.label == 2 then
                self.tipsImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Tipslabel1")
                self.tipsText.text = TI18N("新品")
                self.tipsText.color = Color(1,1,1)
                -- self.tipsImage.gameObject:SetActive(true)
                -- self.tipsGlory.gameObject:SetActive(false)
                -- self.tipsImage.gameObject:SetActive(false)
                -- self.tipsGlory.gameObject:SetActive(true)
            end
        else
            self.tipsImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Tipslabel4")
            self.tipsImage.gameObject:SetActive(true)
            self.tipsText.text = TI18N("限定")
            self.tipsText.color = Color(1,1,1)
        end

    else
        self.tipsImage.gameObject:SetActive(false)
    end

    -- 折扣
    local price = nil

    if data.achievement_limit == nil or #data.achievement_limit == 0 then
        if data ~= nil and data.discount ~= nil and data.discount ~= 1000 then
            self.discountObj:SetActive(true)
            self.discountText.text = math.ceil(data.discount / 10) / 10
            price = math.ceil(data.price * data.discount / 1000)
        else
            self.discountObj:SetActive(false)
            price = data.price
        end
    else
        price = math.ceil(data.price * data.achievement_limit[1].discount / 1000)
    end

    -- if shopData ~= nil and shopData.id == 6 and CampaignManager.Instance.campaignTree[CampaignEumn.Type.May][CampaignEumn.MayType.Rose] ~= nil then
    --     price = 299
    -- end
    self.priceText.text = tostring(price)

    -- 可售数目
    local privilegeNum = 0
    if data ~= nil and data.privilege_lev ~= nil and (PrivilegeManager.Instance.lev or 0) >= data.privilege_lev then
        local privilege_lev = PrivilegeManager.Instance.lev
        for i,v in ipairs(data.privilege_role) do
            if v.p_lev == privilege_lev then
                privilegeNum = v.p_num
            end
        end
    end
    model.itemBuyLimitList[data.id] = nil
    if data.limit_role ~= nil and data.limit_role ~= -1 then
        model.itemBuyLimitList[data.id] = data.limit_role + privilegeNum
    end

    self.numText.text = ""
    if self.numBg ~= nil then
        self.numBg.gameObject:SetActive(false)
    end
    if data.tab == 1 and data.tab2 == 3 then
        if data.num > 1 then
            self.nameText.text = baseData.name.."×"..data.num
        end
        self.soldoutObj:SetActive(data.flag == 1)
        if data.num > 1 then
            self.nameText.text = baseData.name.."×"..data.num
        end
    else
        if model.itemBuyLimitList[data.id] ~= nil then
            if model.hasBuyList ~= nil and model.hasBuyList[data.id] ~= nil and model.hasBuyList[data.id] >= model.itemBuyLimitList[data.id] then
                self.soldoutObj:SetActive(true)
            end

            local numHave = 0
            if model.hasBuyList ~= nil and model.hasBuyList[data.id] ~= nil then
                numHave = model.hasBuyList[data.id]
            end
            if model.itemBuyLimitList[data.id] - numHave > 1 then
                self.numText.text = tostring(model.itemBuyLimitList[data.id] - numHave)
                if self.numBg ~= nil then
                    self.numBg.gameObject:SetActive(true)
                    self.numBg.sizeDelta = Vector2(self.numText.preferredWidth + 10, 23)
                end
            else
                self.numText.text = ""
                if self.numBg ~= nil then
                    self.numBg.gameObject:SetActive(false)
                end
            end
        else
            self.soldoutObj:SetActive(false)
        end
    end

    self.btn.onClick:RemoveAllListeners()
    self.btn.onClick:AddListener(function()
        if model.selectObj ~= nil then
            model.selectObj:SetActive(false)
        end
        model.selectItem = self.gameObject
        model.selectObj = self.selectObj
        model.selectObj:SetActive(true)
        model.selectedInfo = data
        model.selectNum = 1
        model.infoCurrencyType = currency
        model.uniPrice = price
        self.mgr.onUpdateCurrency:Fire()
        if self.callback ~= nil then
            self.callback(data)
        end
    end)

    if baseData.type == 135 then
        self.pieceImage.gameObject:SetActive(true)
        local val = 1
        for i,v in ipairs(baseData.effect_client) do
            if v.effect_type_client == BackpackEumn.ItemUseClient.ride_piece then
                val = v.val_client[1]
            end
        end
        self.pieceImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.slot_res, string.format("SlotPiece%s", val))
    else
        self.pieceImage.gameObject:SetActive(false)
    end

    -- 时装特殊处理

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
        self.hasGet:SetActive(FashionManager.Instance.model:CheckSuitIsActive(self.fashion_id))
    elseif self.isBelt then
        self.hasGet:SetActive(FashionManager.Instance.model:CheckBeltIsActive(self.fashion_id))
    else
        self.hasGet:SetActive(false)
    end


    self:SetActive(true)
end

function ShopItem:SetActive(bool)
    self.gameObject:SetActive(bool == true)
end

function ShopItem:OnClickIcon()
    self.btn.onClick:Invoke()
    if data ~= nil and data.tab == 1 and data.tab2 == 4 then -- 时装商店
        TipsManager.Instance:ShowItem({gameObject = self.iconBtn.gameObject, itemData = DataItem.data_get[data.base_id], extra = {nobutton = true, inbag = false}})
    end
end
