CrossVoiceItem = CrossVoiceItem or BaseClass()

function CrossVoiceItem:__init(gameObject, parent, index)
    self.gameObject = gameObject
    self.parent = parent
    self.transform = self.gameObject.transform

    self.button = self.transform:GetComponent(Button)
    self.button.onClick:AddListener(function() self:OnItemClick(index) end)

    self.NameText = self.transform:Find("NameText"):GetComponent(Text)
    self.ItemSlot = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:Find("Head"), self.ItemSlot.gameObject)

    self.GoldTypeImage = self.transform:Find("gold/asset"):GetComponent(Image)
    self.GoldPrice = self.transform:Find("gold/Text"):GetComponent(Text)
    self.ItemNum = self.transform:Find("LevText"):GetComponent(Text)

    self.Select = self.transform:Find("Select")
    self.Select.gameObject:SetActive(false)

    self.data = nil
    self.Index = index
end

function CrossVoiceItem:__delete()

end

function CrossVoiceItem:InitPanel()

end

function CrossVoiceItem:update_my_self(data)
    self.data = data
    if data ~= nil and next(data) ~= nil then
        self.NameText.text = data.item_name

        local itemData = ItemData.New()
        itemData:SetBase(DataItem.data_get[data.item_id])
        self.ItemSlot:SetAll(itemData, {inbag = false, nobutton = true, noqualitybg = true})
        --self.ItemSlot:SetNum(BackpackManager.Instance:GetItemCount(data.item_id))

        self.GoldTypeImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..data.loss_type)
        self.GoldPrice.text = data.price
        self.ItemNum.text = BackpackManager.Instance:GetItemCount(data.item_id)
    end

end

function CrossVoiceItem:OnItemClick(index)
    if self.parent ~= nil then
        self.parent:ClickLeftItem(index)
    end
end

function CrossVoiceItem:SetSelected(bool)
    if self.Select ~= nil then
        self.Select.gameObject:SetActive(bool)
    end
end


