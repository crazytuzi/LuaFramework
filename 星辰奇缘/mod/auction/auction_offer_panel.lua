-- @author 黄耀聪
-- @date 2016年7月22日

AuctionOfferPanel = AuctionOfferPanel or BaseClass(BasePanel)

function AuctionOfferPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "AuctionOfferPanel"
    self.mgr = AuctionManager.Instance

    self.resList = {
        {file = AssetConfig.auction_offer_panel, type = AssetType.Main},
        {file = AssetConfig.stongbg, type = AssetType.Dep},
    }

    self.tabSetting = {
        noCheckRepeat = true,
        notAutoSelect = true,
        perWidth = 48,
        perHeight = 94,
        isVertical = true,
        openLevel = {0, 999},
    }
    self.offerStepValue = 0
    self.autoStepValue = 0

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function AuctionOfferPanel:__delete()
    self.OnHideEvent:Fire()
    if self.slot ~= nil then
        self.slot:DeleteMe()
    end
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function AuctionOfferPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.auction_offer_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)

    local main = t:Find("Main")

    self.slot = ItemSlot.New()
    self.itemData = ItemData.New()
    NumberpadPanel.AddUIChild(main:Find("ItemBg/Item"), self.slot.gameObject)
    self.nameText = main:Find("ItemBg/Name"):GetComponent(Text)
    -- 大图 hosr
    main:Find("ItemBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")

    self.auto = main:Find("Auto").gameObject
    self.offer = main:Find("Offer").gameObject

    self.offerAddBtn = main:Find("Offer/BuyCount/AddBtn"):GetComponent(Button)
    self.offerMinusBtn = main:Find("Offer/BuyCount/MinusBtn"):GetComponent(Button)
    self.offerStepText = main:Find("Offer/BuyCount/CountBg/Count"):GetComponent(Text)
    self.offerCurrText = main:Find("Offer/Curr/Bg/Text"):GetComponent(Text)
    self.offerPriceText = main:Find("Offer/Price/Bg/Text"):GetComponent(Text)
    self.offerBtn = main:Find("Offer/Button"):GetComponent(Button)

    self.autoAddBtn = main:Find("Auto/BuyCount/AddBtn"):GetComponent(Button)
    self.autoMinusBtn = main:Find("Auto/BuyCount/MinusBtn"):GetComponent(Button)
    self.autoStepText = main:Find("Auto/BuyCount/CountBg/Count"):GetComponent(Text)
    self.autoPriceText = main:Find("Auto/Price/Bg/Text"):GetComponent(Text)
    self.autoDescText = main:Find("Auto/Desc"):GetComponent(Text)
    self.autoBtn = main:Find("Auto/Button"):GetComponent(Button)

    self.tabGroup = TabGroup.New(main:Find("TabListPanel"), function(index) self:ChangeTab(index) end, self.tabSetting)
    self.offerAddBtn.onClick:AddListener(function() self:AddOrMinus(1, 1) end)
    self.offerMinusBtn.onClick:AddListener(function() self:AddOrMinus(1, 2) end)
    self.autoAddBtn.onClick:AddListener(function() self:AddOrMinus(2, 1) end)
    self.autoMinusBtn.onClick:AddListener(function() self:AddOrMinus(2, 2) end)

    self.autoBtn.onClick:AddListener(function()
    end)

    self.offerBtn.onClick:AddListener(function() self:OnOffer() end)
end

function AuctionOfferPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function AuctionOfferPanel:OnOpen()
    self:RemoveListeners()

    local model = self.model
    local data = model.datalist[model.selectIdx]
    local basedata = DataItem.data_get[data.item_id]
    self.itemData:SetBase(basedata)
    self.slot:SetAll(self.itemData, {inbag = false, nobutton = true})
    self.nameText.text = basedata.name
    self.offerCurrText.text = tostring(data.gold)
    self.autoPriceText.text = tostring(data.gold)

    self.autoStepText.text = "0"
    self.offerStepText.text = "0"

    self.offerStepValue = data.gold_once
    self.autoStepValue = data.gold_once

    self.autoStepText.text = tostring(self.offerStepValue)
    self.offerStepText.text =tostring(self.autoStepValue)

    self.offerPriceText.text = tostring(data.gold + self.offerStepValue)
    self.tabGroup:ChangeTab(1)
end

function AuctionOfferPanel:OnHide()
    self:RemoveListeners()
end

function AuctionOfferPanel:RemoveListeners()
end

function AuctionOfferPanel:OnClose()
    self.model:CloseOperation()
end

function AuctionOfferPanel:ChangeTab(index)
    self.auto:SetActive(index == 2)
    self.offer:SetActive(index == 1)
end

function AuctionOfferPanel:AddOrMinus(type, op)
    local model = self.model
    local step = model.datalist[model.selectIdx].gold_once
    if type == 1 then
        if op == 1 then     -- 加
            self.offerStepValue = self.offerStepValue + step
        else                -- 减
            if self.offerStepValue <= step then
            else
                self.offerStepValue = self.offerStepValue - step
            end
        end
        self.offerStepText.text = tostring(self.offerStepValue)
        self.offerPriceText.text = tostring(self.offerStepValue + model.datalist[model.selectIdx].gold)
    elseif type == 2 then
        if op == 1 then     -- 加
            self.autoStepValue = self.autoStepValue + step
        else                -- 减
            if self.autoStepValue <= step then
            else
                self.autoStepValue = self.autoStepValue - step
            end
        end
        self.autoStepText.text = tostring(self.autoStepValue)
        self.autoPriceText.text = tostring(self.autoStepValue + model.datalist[model.selectIdx].gold)
    end
end

function AuctionOfferPanel:OnOffer()
    local model = self.model
    self.mgr:send16703(model.selectIdx, self.offerStepValue, model.datalist[model.selectIdx].gold)
    model:CloseOperation()
end