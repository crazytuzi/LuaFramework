ToyRewardItem = ToyRewardItem or BaseClass()

function ToyRewardItem:__init(gameObject,isHasDoubleClick)
    self.ItemSlot = ItemSlot.New(gameObject,isHasDoubleClick)

    local resources = {
     {file = AssetConfig.toyreward_textures, type = AssetType.Dep}
    }
    self.assetWrapper = AssetBatchWrapper.New()
    self.assetWrapper:LoadAssetBundle(resources)
end

function ToyRewardItem:__delete()
    self.ItemSlot.qualityBg.sprite = nil
    if self.ItemSlot ~= nil then
    	self.ItemSlot:DeleteMe()
    end
end

function ToyRewardItem:SetQualityInBag(quality)
    quality = quality or 0
    quality = quality + 1
    if quality < 5 then
        self.ItemSlot.qualityBg.gameObject:SetActive(false)
    else
        self.ItemSlot.qualityBg.sprite = self.assetWrapper:GetSprite(AssetConfig.toyreward_textures, string.format("ItemImage%s", quality))
        self.ItemSlot.gameObject:SetActive(true)
    end
end

function ToyRewardItem:SetDefaultQuality()
    self.ItemSlot.qualityBg.sprite = self.assetWrapper:GetSprite(AssetConfig.toyreward_textures, "ItemImage")
end

function ToyRewardItem:ShowEffect(t,id)
    self.ItemSlot:ShowEffect(t,id)
end