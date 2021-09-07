MarketGoldItem = MarketGoldItem or BaseClass()

function MarketGoldItem:__init(model, gameObject,assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper
    self.transform = gameObject.transform
    local t = self.transform
    self.nameText = t:Find("NameText"):GetComponent(Text)
    self.priceText = t:Find("PriceText"):GetComponent(Text)
    self.updownText = t:Find("UpDownText"):GetComponent(Text)
    self.updownImage = t:Find("UpDownImage"):GetComponent(Image)
    self.btn = gameObject:GetComponent(Button)
    self.bgImage = t:Find("bg"):GetComponent(Image)
    self.selectObj = t:Find("Select").gameObject
    self.rect = gameObject:GetComponent(RectTransform)
    self.limitObj = t:Find("Limit").gameObject

    self.originColor = self.bgImage.color

    self.btn.onClick:AddListener(function() self:OnClick() end)
end

function MarketGoldItem:__delete()
    if self.itemdata ~= nil then
        self.itemdata:DeleteMe()
        self.itemdata = nil
    end
    self.model = nil
end

function MarketGoldItem:update_my_self(data, index)
    self:SetActive(false)
    if data == nil then
        return
    end
    self.data = data
    self.index = index
    local itemData = DataItem.data_get[data.base_id]
    local marketData = DataMarketGold.data_market_gold_item[data.base_id]
    self.nameText.text = itemData.name
    self.priceText.text = data.cur_price
    if index % 2 == 1 then
        self.bgImage.color = Color(127/255, 178/255, 235/255)
    else
        self.bgImage.color = self.originColor
    end
    if data.margin > 1000 then
        self.updownText.color = Color(1,0,0,1)
        self.updownText.text = "+"..tostring((data.margin - 1000) / 10).."%"
        self.updownImage.sprite = self.assetWrapper:GetSprite(AssetConfig.market_textures, "UpImg2")
        self.updownImage.transform.localScale = Vector3(1, 1, 1)
        self.updownImage.gameObject:SetActive(true)
    elseif data.margin == 1000 then
        self.updownText.color = Color(1, 1, 1, 1)
        self.updownText.text = " --"
        self.updownImage.gameObject:SetActive(false)
    else
        self.updownText.color = Color(27/255,149/255,42/255,1)
        self.updownText.text = "-"..tostring((1000 - data.margin) / 10).."%"
        self.updownImage.sprite = self.assetWrapper:GetSprite(AssetConfig.market_textures, "UpImg")
        self.updownImage.transform.localScale = Vector3(1, -1, 1)
        self.updownImage.gameObject:SetActive(true)
    end
    self.selectObj:SetActive(self.model.selectPos == index)
    self.limitObj:SetActive(marketData.day_limit > 0)
    if self.model.selectPos == index then
        self.model.lastSelectObj = self.selectObj
    end

    self:SetActive(true)
end

function MarketGoldItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function MarketGoldItem:OnClick()
    local model = self.model
    if model.lastSelectObj ~= nil then
        model.lastSelectObj:SetActive(false)
    end
    self.selectObj:SetActive(true)
    model.lastSelectObj = self.selectObj

    model.goldChosenBaseId = self.data.base_id
    model.selectPos = self.index

    local cell = DataItem.data_get[self.data.base_id]
    if self.itemdata ~= nil then
        self.itemdata:DeleteMe()
    end
    self.itemdata = ItemData.New()
    self.itemdata:SetBase(cell)
    local marketData = DataMarketGold.data_market_gold_item[self.data.base_id]
    TipsManager.Instance:ShowItem({gameObject = self.gameObject, itemData = self.itemdata, extra = {nobutton = true, inbag = false, show_limit = marketData.day_limit > 0}})
    model.targetBaseId = nil
    model.lastGoldTime = nil
    model.goldBuyNum = 1
end
