NationalSecondFlowerRewardItem = NationalSecondFlowerRewardItem or BaseClass()

function NationalSecondFlowerRewardItem:__init(gameObject,isHasDoubleClick,index)
    self.index = index
    self.gameObject = gameObject
    self.isHasDoubleClick = isHasDoubleClick
    -- local resources = {
    --   {file = AssetConfig.bible_rechargepanel_textures, type = AssetType.Dep}
    -- }
    -- self.assetWrapper = AssetBatchWrapper.New()
    -- self.assetWrapper:LoadAssetBundle(resources)

    self.effect = nil

    self.flashEffect = nil
    self.flashMoreEffect = nil

    self.beautifulEffect = nil

    self.extra = {inbag = false, nobutton = true}
    self.slot = ItemSlot.New(self.gameObject.transform:Find("ItemSlot"),isHasDoubleClick)
    self.slot:ShowBg(false)
    self.id = nil
    -- self.rotationTweenId = nil


    self.extra = {inbag = false, nobutton = true}
    self:Init()
end

function NationalSecondFlowerRewardItem:__delete()
     -- if self.rotationTweenId ~= nil then
     --    Tween.Instance:Cancel(self.rotationTweenId)
     --    self.rotationTweenId = nil
     -- end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end

    if self.flashEffect ~= nil then
        self.flashEffect:DeleteMe()
        self.flashEffect = nil
    end

    if self.flashMoreEffect ~= nil then
        self.flashMoreEffect:DeleteMe()
        self.flashMoreEffect = nil
    end


    if self.beautifulEffect ~= nil then
        self.beautifulEffect:DeleteMe()
        self.beautifulEffect = nil
    end

    if self.assetIconLoader2 ~= nil then
        self.assetIconLoader2:DeleteMe()
        self.assetIconLoader2 = nil
    end

    if self.assetIconLoader1 ~= nil then
        self.assetIconLoader1:DeleteMe()
        self.assetIconLoader1 = nil
    end

end


function NationalSecondFlowerRewardItem:Init()
    self.transform = self.gameObject.transform
     self.windowBg = self.transform:GetComponent(Image)
    self.windowBg.enabled = false
    self.hasGet = self.transform:Find("HasGet")
    self.hasGet.gameObject:SetActive(false)
    self.shopContainer = self.transform:Find("ShopContainer")
    self.shopContainer.gameObject:SetActive(false)

    self.shopButtonImg = self.transform:Find("ShopContainer/ShopButton"):GetComponent(Image)
    self.shopButtonText = self.transform:Find("ShopContainer/ShopButton/Text"):GetComponent(Text)

    self.nameText = self.transform:Find("Text"):GetComponent(Text)

    self.assetIconLoader1 = SingleIconLoader.New(self.transform:Find("ShopContainer/AssetIcon1").gameObject)
    self.assetIconLoader1:SetSprite(SingleIconType.Item, 90002)

    self.assetIconLoader2 = SingleIconLoader.New(self.transform:Find("ShopContainer/AssetIcon2").gameObject)
    self.assetIconLoader2:SetSprite(SingleIconType.Item, 90002)

    self.originalPriceText = self.transform:Find("ShopContainer/TopRightText"):GetComponent(Text)
    self.presentPriceText = self.transform:Find("ShopContainer/BottomRightText"):GetComponent(Text)
    self.shopButton = self.transform:Find("ShopContainer/ShopButton"):GetComponent(Button)
    self.shopButton.onClick:AddListener(function() self:ApplyShopButton() end)
end


function NationalSecondFlowerRewardItem:SetSlot(id,extra,num,data)
    self.data = data
    self.myIndex = self.data.index
    self.shopContainer.gameObject:SetActive(false)
    self.hasGet.gameObject:SetActive(false)
    self.id = id
    local data = DataItem.data_get[id]
    self.slot:SetAll(data,extra)
    self.slot.gameObject.gameObject:SetActive(true)
    if num ~= nil then
        self.slot:SetNum(num)
    end


    self.nameText.text = ColorHelper.color_item_name(data.quality, data.name)
    -- self.slot.qualityBg.gameObject:SetActive(false)
    -- self.slot:ShowBg(false)
    -- self.slot.selectObj:GetComponent(Image).color = Color(0,0,0,0)
end

function NationalSecondFlowerRewardItem:SetIsBg(t)

    if t == true then
        self.windowBg.enabled = true
    else
        self.windowBg.enabled = false
    end
end


function NationalSecondFlowerRewardItem:SetCharge(hasGet)
    self.shopContainer.gameObject:SetActive(hasGet)
    if hasGet == false then
        self.hasGet.gameObject:SetActive(false)
        self.shopContainer.gameObject:SetActive(false)
        self.nameText.gameObject:SetActive(true)
    else
        if self.data.is_get == 0 then
            self.hasGet.gameObject:SetActive(true)
            self.nameText.gameObject:SetActive(false)
            self.shopContainer.gameObject:SetActive(false)
            self.originalPriceText.text = self.data.old_price
            self.presentPriceText.text = self.data.price
        else
            self.hasGet.gameObject:SetActive(false)
            self.shopContainer.gameObject:SetActive(true)
            self.nameText.gameObject:SetActive(false)
            self.originalPriceText.text = self.data.old_price
            self.presentPriceText.text = self.data.price
        end
    end
end

function NationalSecondFlowerRewardItem:SetIsBuy(isbuy)
    self.shopButton.onClick:RemoveAllListeners()
    if isbuy == true then
        self.shopButtonImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures,"DefaultButton3")
        self.shopButtonText.color = ColorHelper.DefaultButton3
        self.shopButton.onClick:AddListener(function() self:ApplyShopButton() end)
    elseif isbuy == false then
        self.shopButtonImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures,"DefaultButton4")
        self.shopButtonText.color = ColorHelper.DefaultButton4
        self.shopButton.onClick:AddListener(function() NationalSecondManager.Instance:Send17897(self.myIndex) end)
    end
end

function NationalSecondFlowerRewardItem:ApplyShopButton()
    local itemData = DataItem.data_get[self.id]

    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = string.format(TI18N("三个珍宝<color='#FFFF00'>只能购买其中一个</color>,是否确认购买%s?"),itemData.name)
    data.sureLabel = TI18N("确认购买")
    data.cancelLabel = TI18N("再考虑下")
    data.sureCallback = function ()
        NationalSecondManager.Instance:Send17897(self.myIndex)
    end
    NoticeManager.Instance:ConfirmTips(data)
end


