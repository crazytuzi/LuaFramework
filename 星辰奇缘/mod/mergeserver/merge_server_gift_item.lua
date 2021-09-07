-- @author 黄耀聪
-- @date 2016年6月13日

MergeServerGiftItem = MergeServerGiftItem or BaseClass()

function MergeServerGiftItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform

    local t = self.transform
    self.giftString = TI18N("使用获得以下所有道具：")

    t:Find("IconBg"):GetComponent(RectTransform).sizeDelta = Vector2(64,64)
	self.iconLoader = SingleIconLoader.New(t:Find("IconBg/Icon").gameObject)
	self.nameText = t:Find("NameBg/Name"):GetComponent(Text)
	self.priceText = t:Find("PriceBg/Text"):GetComponent(Text)
	self.currencyImage = t:Find("PriceBg/Currency"):GetComponent(Image)
	self.lightRect = t:Find("IconLignt"):GetComponent(RectTransform)
	self.lightRect.transform:SetParent(t:Find("Bg"))
	self.lightRect.transform.localScale = Vector3.one
	self.lightRect.anchoredPosition = Vector2(0, 7)
	-- t:Find("Panel"):SetAsLastSibling()
	t:Find("Panel").gameObject:SetActive(false)
	self.bgBtn = t:Find("Bg"):GetComponent(Button)
	self.bgTransition = t:Find("Bg").gameObject:AddComponent(TransitionButton)
	self.bgTransition.scaleSetting = false
	if self.bgBtn == nil then
		self.bgBtn = t:Find("Bg").gameObject:AddComponent(Button)
	end
	self.iconLoader.image.gameObject:GetComponent(Button).onClick:AddListener(function() self:OnShowTips() end)
	self.bgBtn.onClick:AddListener(function() self:OnShowTips() end)
	t:Find("Buy"):GetComponent(Button).onClick:AddListener(function() self:OnClick() end)
	t:Find("Buy"):SetAsLastSibling()

	self.buyImage = t:Find("Buy"):GetComponent(Image)
	self.buyText = t:Find("Buy/Text"):GetComponent(Text)

	local nameBg = t:Find("NameBg")
	nameBg:SetParent(t:Find("Bg"))
	nameBg.localScale = Vector3.one
	local nameBgRect = nameBg:GetComponent(RectTransform)
	nameBgRect.anchorMax = Vector2(0.5, 0)
	nameBgRect.anchorMin = Vector2(0.5, 0)
	nameBgRect.anchoredPosition = Vector2(-1, 1)
	nameBgRect.sizeDelta = Vector2(150, 30)
end

function MergeServerGiftItem:SetRotation(theta)
	self.lightRect.rotation = Quaternion.Euler(0, 0, theta)
end

function MergeServerGiftItem:__delete()
    if self.iconLoader ~= nil then
        self.iconLoader:DeleteMe()
        self.iconLoader = nil
    end
end

function MergeServerGiftItem:update_my_self(data, index)
	self.data = data

	local campaignData = DataCampaign.data_list[data.id]
	local protoData = CampaignManager.Instance.campaignTab[data.id]

	local baseData = DataItem.data_get[campaignData.reward[1][1]]
	self.itemData = self.itemData or ItemData.New()
	self.itemData:SetBase(baseData)

	self.iconLoader:SetSprite(SingleIconType.Item, baseData.icon)
	self.currencyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[campaignData.loss_items[1][1]])
	self.priceText.text = tostring(campaignData.loss_items[1][2])
	self.nameText.text = baseData.name

	self:SetActive(true)

	if CampaignManager.Instance.campaignTab[self.data.id].reward_can == 0 then
		-- BaseUtils.SetGrey(self.buyImage, true)
		self.buyText.text = TI18N("已购买")
		self.buyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
	else
		-- BaseUtils.SetGrey(self.buyImage, true)
		self.buyText.text = TI18N("购 买")
		self.buyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
	end
end

function MergeServerGiftItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function MergeServerGiftItem:OnClick()
	if self.data ~= nil and self.data.id ~= nil and CampaignManager.Instance.campaignTab[self.data.id].reward_can >= 0 then
		CampaignManager.Instance:Send14001(self.data.id)
	end
end

function MergeServerGiftItem:OnShowTips()
	local model = self.model
    if model.giftPreview == nil then
        model.giftPreview = GiftPreview.New(model.mainWin.gameObject)
    end
    local rewardList = {}
    local rewardDataList = DataCampaign.data_list[self.data.id].rewardgift
    for i,v in ipairs(rewardDataList) do
        if #v == 2 then
            table.insert(rewardList, {v[1], v[2]})
        elseif (tonumber(v[1]) == 0 or tonumber(classes) == tonumber(v[1]))
            and (tonumber(v[2]) == 2 or tonumber(sex) == tonumber(v[2])) then
            table.insert(rewardList, {v[3], v[4]})
        end
    end
    model.giftPreview:Show({reward = rewardList, autoMain = true, text = self.giftString})
end



