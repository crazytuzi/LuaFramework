CampBoxTopItem = CampBoxTopItem or BaseClass()

function CampBoxTopItem:__init(gameObject,isHasDoubleClick)
    self.ItemSlot = ItemSlot.New(gameObject,isHasDoubleClick)
    self.gameObject = gameObject

    local resources = {
     {file = AssetConfig.campbox_texture, type = AssetType.Dep}
    }
    self.assetWrapper = AssetBatchWrapper.New()
    self.assetWrapper:LoadAssetBundle(resources)

    self.firstEffect = BibleRewardPanel.ShowEffect(20392, self.gameObject.transform, Vector3(0.78,0.78,1), Vector3(32, 0,-20))
    self.firstEffect:SetActive(false)


    self.itemEffect = BibleRewardPanel.ShowEffect(20328, self.gameObject.transform, Vector3(1,1,1), Vector3(30, 2,-30))
    self.itemEffect:SetActive(false)

    self.itemEffect2 = BibleRewardPanel.ShowEffect(20327, self.gameObject.transform, Vector3(1,1,1), Vector3(30, 2,-30))
    self.itemEffect2:SetActive(false)

    self.hasReward = self.gameObject.transform:Find("HasReward")
    self.button = self.gameObject.transform:Find("Button"):GetComponent(Button)
    self.num = 0
    -- self:Init()
end

-- function CampBoxTopItem:Init()
--     self.reward = self.gameObject.transform:Find()
--     self.reward.gameObject:SetActive(false)
-- end

function CampBoxTopItem:__delete()
    if self.firstEffect ~= nil then
        self.firstEffect:DeleteMe()
        self.firstEffect = nil
    end

    if self.itemEffect ~= nil then
        self.itemEffect:DeleteMe()
        self.itemEffect = nil
    end

    if self.itemEffect2 ~= nil then
        self.itemEffect2:DeleteMe()
        self.itemEffect2 = nil
    end

    if self.ItemSlot ~= nil then
        self.ItemSlot:DeleteMe()
    end
end

function CampBoxTopItem:SetData(itemData,extra,status,n,itemId)
    self.itemId = itemId
    self.num = n or 0
    self.ItemSlot:SetAll(itemData,extra)
    self.ItemSlot:SetDefaultTalisman()
    self.ItemSlot:SetNum(self.num)
    self.ItemSlot.button.onClick:RemoveAllListeners()
    self.button.onClick:RemoveAllListeners()
    self.button.onClick:AddListener(function() self.ItemSlot:ClickSelf()  self.ItemSlot:ShowSelect(false)  end)
    self:SetStatus(status)
end

function CampBoxTopItem:SetBg(index)
    if index == 2 then
        self.ItemSlot.qualityBg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.slot_res, "Level4")
        self.itemEffect:SetActive(true)
        self.itemEffect2:SetActive(false)
    elseif index == 1 then
        self.ItemSlot.qualityBg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.slot_res, "Level3")
        self.itemEffect:SetActive(false)
        self.itemEffect2:SetActive(true)
    end
end

function CampBoxTopItem:SetStatus(t)
    if t == true then
        self.hasReward.gameObject:SetActive(true)
    else
        self.hasReward.gameObject:SetActive(false)
    end
end

function CampBoxTopItem:ShowEffect(t)
    if t == false then
        self.firstEffect:SetActive(false)
    elseif t == true then
        self.firstEffect:SetActive(true)
    end
end

