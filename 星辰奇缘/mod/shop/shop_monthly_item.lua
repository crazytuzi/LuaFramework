ShopMonthlyItem = ShopMonthlyItem or BaseClass()

function ShopMonthlyItem:__init(model, gameObject, assetWrapper, callback)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper
    self.callback = callback

    local t = self.gameObject.transform
    self.labelRect = t:Find("TipsLabel"):GetComponent(RectTransform)
    self.labelImage = t:Find("TipsLabel"):GetComponent(Image)
    self.labelText = t:Find("TipsLabel/Text"):GetComponent(Text)
    self.descText = t:Find("Desc"):GetComponent(Text)
    self.descRect = self.descText.gameObject:GetComponent(RectTransform)
    self.moneyText = t:Find("Money"):GetComponent(Text)
    self.moneyIcon = t:Find("Money/Icon"):GetComponent(Image)
    self.descExt = MsgItemExt.New(self.descText, 163, 16, 18)
    self.labelExt = MsgItemExt.New(self.labelText, 163, 15, 16)
    self.btn = gameObject:GetComponent(Button)
    self.rect = gameObject:GetComponent(RectTransform)
    self.descRect = self.descText.gameObject:GetComponent(RectTransform)
end

function ShopMonthlyItem:__delete()
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    self.labelImage.sprite = nil
    self.moneyIcon.sprite = nil
    self.assetWrapper = nil
    self.btn.onClick:RemoveAllListeners()
    self.callback = nil
end

function ShopMonthlyItem:SetData(data, index)
    local model = self.model
    self.index = index
    if BaseUtils.GetLocation() == KvData.localtion_type.sg then
        self.moneyText.text = tostring(data.rmb / 100)
        self.moneyIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, "MoneyIcon_dl")
    else
        self.moneyText.text = tostring(data.rmb)
        self.moneyIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, "MoneyIcon_cn")
    end
    self.btn.onClick:RemoveAllListeners()

    self.btn.onClick:AddListener(function() self:OnClick() end)

    self.descExt:SetData(string.format(TI18N("购买即领<color='#FFFF00'>%s</color>{assets_2, 90002}"), tostring(data.gold)))
    self.descRect.anchoredPosition = Vector2(self.rect.sizeDelta.x / 2 - self.descExt.contentRect.sizeDelta.x / 2 + 3, -20.5)

    if PrivilegeManager.Instance.monthlyExcessDays > 0 then
        self.labelImage.sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, "TextBg2")
        self.labelExt:SetData(string.format(TI18N("礼包可续费，剩余<color='#ffff00'>%s</color>天"), tostring(PrivilegeManager.Instance.monthlyExcessDays)))
    else
        self.labelImage.sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, "TextBg1")
        self.labelExt:SetData(string.format(TI18N("%s天每天可领<color='#ffff00'>%s</color>{assets_2, 90003}"), tostring(DataMonthCard.data_get_reward[data.gold].day), tostring(DataMonthCard.data_get_reward[data.gold].gold_bind)))
    end

    self:SetActive(true)
end

function ShopMonthlyItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function ShopMonthlyItem:OnClick()
    local senddata = BaseUtils.copytab(self.model.chargeList[self.index])
    -- senddata.extraString = "2"
    if self.callback ~= nil then
        self.callback(senddata)
    end
end
