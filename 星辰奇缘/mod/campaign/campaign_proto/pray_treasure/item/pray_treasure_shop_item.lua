-- @author hze
-- @date #2019/09/19#
-- 祈愿宝阁兑换商店item

PrayTreasureShopItem = PrayTreasureShopItem or BaseClass()

function PrayTreasureShopItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform

    self:InitPanel()
end

function PrayTreasureShopItem:__delete()
    if self.iconLoader then 
        self.iconLoader:DeleteMe()
    end
    if self.costIconLoader then 
        self.costIconLoader:DeleteMe()
    end
end

function PrayTreasureShopItem:InitPanel()
    self.headBg = self.transform:Find("HeadBg")
    self.headBg:GetComponent(Button).onClick:AddListener(function() self:OnShowItemClick() end)
    self.iconLoader = SingleIconLoader.New(self.headBg:Find("Image").gameObject)

    self.nameTxt = self.transform:Find("Name"):GetComponent(Text)
    self.costIconLoader = SingleIconLoader.New(self.transform:Find("IconBg/gain").gameObject)
    self.numTxt = self.transform:Find("IconBg/num"):GetComponent(Text)
    self.btn = self.transform:Find("Button"):GetComponent(Button)
    self.btn.onClick:AddListener(function() self:OnClick() end)
    self.timesTxt = self.transform:Find("Times"):GetComponent(Text)
end

function PrayTreasureShopItem:SetData(data, index)
    -- BaseUtils.dump(data,"ssssss")
    self.data = data
    local baseData = DataItem.data_get[data.base_id]
    self.iconLoader:SetSprite(SingleIconType.Item, baseData.icon)
    self.nameTxt.text = baseData.name
    if RoleManager.Instance.RoleData[data.assets_type] < data.price then
        self.numTxt.text = string.format("<color='#df3435'>%d</color>", data.price)
    else
        self.numTxt.text = data.price
    end
    if data.limit_role == -1 then
        self.timesTxt.text = TI18N("剩余:不限")
    else
        local buyNum = ShopManager.Instance.model.hasBuyList[data.id] or 0
        self.timesTxt.text = TI18N("剩余:") .. (data.limit_role - buyNum)
    end
    if GlobalEumn.CostTypeIconName[data.assets_type] == nil then
        self.costIconLoader:SetSprite(SingleIconType.Item, DataItem.data_get[KvData.assets[data.assets_type]].icon)
    else
        self.costIconLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[data.assets_type]))
    end
end

function PrayTreasureShopItem:OnClick()
    ShopManager.Instance:send11303(self.data.id, 1)    
end

function PrayTreasureShopItem:OnShowItemClick()
    local itemdata = ItemData.New()
    itemdata:SetBase(BackpackManager.Instance:GetItemBase(self.data.base_id))
    TipsManager.Instance:ShowItem({["gameObject"] = self.headBg.gameObject, ["itemData"] = itemdata, ["extra"] = {nobutton = true}})
end