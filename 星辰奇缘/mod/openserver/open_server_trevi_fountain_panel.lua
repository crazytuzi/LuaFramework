OpenServerTreviFountainPanel = OpenServerTreviFountainPanel or BaseClass(BasePanel)

function OpenServerTreviFountainPanel:__init(model, parent)
    self.model = ThanksgivingManager.Instance.model
    self.parent = parent
    self.name = "OpenServerTreviFountainPanel"

    self.resList = {
        {file = AssetConfig.openservertrevifountainpanel, type = AssetType.Main},
        {file = AssetConfig.trevifountain_i18N, type = AssetType.Main},
        {file = AssetConfig.blue_light, type = AssetType.Dep},
    }

    self.wishEffect1 = nil
    self.wishEffect2 = nil
    self.buttonEffect = nil

    ---------------------------------------
    -- self.updateListener = function(type, gold) self:ShowRewardPanel(type, gold) end
	self.updateListener = function(type, gold) self:Update(type, gold) end
	
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function OpenServerTreviFountainPanel:__delete()
    self.OnHideEvent:Fire()
    if self.timerId ~= nil then
    	LuaTimer.Delete(self.timerId)
    	self.timerId = nil
    end
    if self.wishEffect1 ~= nil then
        self.wishEffect1:DeleteMe()
        self.wishEffect1 = nil
    end
    if self.wishEffect2 ~= nil then
        self.wishEffect2:DeleteMe()
        self.wishEffect2 = nil
    end
    if self.buttonEffect ~= nil then
        self.buttonEffect:DeleteMe()
        self.buttonEffect = nil
    end
    
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function OpenServerTreviFountainPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.openservertrevifountainpanel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    self.transform = t

    UIUtils.AddBigbg(t:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.trevifountain_i18N)))
    self.transform:Find("RewardPanel/MainCon"):GetChild(3):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.blue_light, "blue_light")

    self.rewardPanel = self.transform:Find("RewardPanel").gameObject
    self.rewardPanel.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:HideRewardPanel() end)
    self.rewardPanel.transform:Find("MainCon/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:HideRewardPanel() end)
    self.rewardPanel.transform:Find("MainCon/OkButton"):GetComponent(Button).onClick:AddListener(function() self:HideRewardPanel() end)
    self.rewardPanel:SetActive(false)

    self.numImage1 = self.transform:Find("NumImage/Num1").gameObject
    self.numImage2 = self.transform:Find("NumImage/Num2").gameObject
    self.numImage3 = self.transform:Find("NumImage/Num3").gameObject
    self.numImage4 = self.transform:Find("NumImage/Num4").gameObject

    self.nextText = self.transform:Find("NextText"):GetComponent(Text)
    self.numText = self.transform:Find("NumText"):GetComponent(Text)
    self.numText.gameObject:SetActive(false)
    self.timesText  = self.transform:Find("TimesText"):GetComponent(Text)

    self.button = self.transform:Find("Button"):GetComponent(Button)
    self.button.onClick:AddListener(function() self:ButtonClick() end)
    self.buttonText = self.button.transform:Find("PriceText"):GetComponent(Text)

    self.button2 = self.transform:Find("Button2").gameObject

    self.buttonEffect = BibleRewardPanel.ShowEffect(20053, self.transform, Vector3(2.3, 0.75, 1), Vector3(115,-195, -100))
    self.wishEffect1 = BibleRewardPanel.ShowEffect(20235, self.transform, Vector3(1, 1, 1), Vector3(-115, -133, -100))
    self.wishEffect2 = BibleRewardPanel.ShowEffect(20236, self.transform, Vector3(1, 1, 1), Vector3(65, -40, -100))
end

function OpenServerTreviFountainPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function OpenServerTreviFountainPanel:OnOpen()
    self:RemoveListeners()
    CampaignManager.Instance.OnUpdate:AddListener(self.updateListener)

    self:Update()
    self:ShowEffect(1)
    self:HideRewardPanel()
end

function OpenServerTreviFountainPanel:OnHide()
    self:RemoveListeners()
    if self.timerId ~= nil then
    	LuaTimer.Delete(self.timerId)
    	self.timerId = nil
    end
end

function OpenServerTreviFountainPanel:RemoveListeners()
    CampaignManager.Instance.OnUpdate:RemoveListener(self.updateListener)
end

function OpenServerTreviFountainPanel:Update()
	local data = DataCampaignWish.data_times[CampaignManager.Instance.campaignWishTimes + 1]
	if data == nil then
		data = DataCampaignWish.data_times[#DataCampaignWish.data_times]

		self.button.gameObject:SetActive(false)
		self.button2:SetActive(true)
		self.buttonEffect:SetActive(false)

		-- self.numText.text = tostring(data.gain_min)
		self:UpdateNumImage(data.gain_min)
		self.nextText.text = tostring(data.loss[1][2])
	else
		self.button.gameObject:SetActive(true)
		self.button2:SetActive(false)
		self.buttonEffect:SetActive(true)

		self.buttonText.text = tostring(data.loss[1][2])
		-- self.numText.text = tostring(data.gain_min)
		self:UpdateNumImage(data.gain_min)
		local nextData = DataCampaignWish.data_times[CampaignManager.Instance.campaignWishTimes + 2]
		if nextData == nil then
			self.nextText.text = tostring(data.loss[1][2])
		else
			self.nextText.text = tostring(nextData.loss[1][2])
		end
	end
	if CampaignManager.Instance.campaignWishTimes < #DataCampaignWish.data_times then
		self.timesText.text = string.format(TI18N("剩余次数：<color='#00ff00'>%s</color>/%s"), #DataCampaignWish.data_times - CampaignManager.Instance.campaignWishTimes, #DataCampaignWish.data_times)
	else
		self.timesText.text = string.format(TI18N("剩余次数：<color='#ff0000'>%s</color>/%s"), #DataCampaignWish.data_times - CampaignManager.Instance.campaignWishTimes, #DataCampaignWish.data_times)
	end
end

function OpenServerTreviFountainPanel:ShowEffect(effectStep)
	if effectStep == 1 then
		-- self.buttonEffect:SetActive(true)
		self.wishEffect1:SetActive(true)
		self.wishEffect2:SetActive(false)
	elseif effectStep == 2 then
		self.buttonEffect:SetActive(false)
		self.wishEffect1:SetActive(false)
		self.wishEffect2:SetActive(true)

		self.timerId = LuaTimer.Add(1500, function() self:ShowEffect(3) end)
	elseif effectStep == 3 then
		self.buttonEffect:SetActive(false)
		self.wishEffect1:SetActive(false)
		self.wishEffect2:SetActive(false)

		self.button.enabled = true
		CampaignManager.Instance:Send14096()
	end
end

function OpenServerTreviFountainPanel:ButtonClick()
	if CampaignManager.Instance.campaignWishTimes < #DataCampaignWish.data_times then
		local data = DataCampaignWish.data_times[CampaignManager.Instance.campaignWishTimes + 1]
		if data.loss[1][2] > RoleManager.Instance.RoleData.gold then
			NoticeManager.Instance:FloatTipsByString(TI18N("钻石不足"))
			WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1})
		else
			self:ShowEffect(2)
			self.button.enabled = false
		end
	else
		NoticeManager.Instance:FloatTipsByString(TI18N("今天没有剩余许愿次数了"))
	end
end

function OpenServerTreviFountainPanel:UpdateNumImage(num)
	local firstNumMark = true
	local tempNum = math.floor(num / 1000)
	if tempNum > 0 then
		self.numImage1:SetActive(true)
		self.numImage1:GetComponent(Image).sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_8, string.format("Num8_%s", tempNum))
		firstNumMark = false
	else
		self.numImage1:SetActive(false)
	end

	tempNum = math.floor(num / 100 % 10)
	if tempNum > 0 or not firstNumMark then
		self.numImage2:SetActive(true)
		self.numImage2:GetComponent(Image).sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_8, string.format("Num8_%s", tempNum))
		firstNumMark = false
	else
		self.numImage2:SetActive(false)
	end

	tempNum = math.floor(num / 10 % 10)
	if tempNum > 0 or not firstNumMark then
		self.numImage3:SetActive(true)
		self.numImage3:GetComponent(Image).sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_8, string.format("Num8_%s", tempNum))
		firstNumMark = false
	else
		self.numImage3:SetActive(false)
	end

	tempNum = math.floor(num % 10)
	self.numImage4:SetActive(true)
	self.numImage4:GetComponent(Image).sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_8, string.format("Num8_%s", tempNum))
end

function OpenServerTreviFountainPanel:ShowRewardPanel(type, gold)
	if type == "OpenServerTreviFountainPanel:ShowRewardPanel" then
		self.rewardPanel:SetActive(true)

		local item1 = self.rewardPanel.transform:FindChild("MainCon/Item1")
		
		local itembase = BackpackManager.Instance:GetItemBase(90026)
	    local itemData = ItemData.New()
	    itemData:SetBase(itembase)
	    itemData.quantity = gold
	    local itemSlot = ItemSlot.New()
	    UIUtils.AddUIChild(item1, itemSlot.gameObject)
	    itemSlot:SetAll(itemData, {nobutton = true})

	    item1.transform:FindChild("Text"):GetComponent(Text).text = itemData.name

	    self:Update()
	end
end

function OpenServerTreviFountainPanel:HideRewardPanel()
	self.rewardPanel:SetActive(false)
end
