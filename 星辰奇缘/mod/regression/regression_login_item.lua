-- 单项回归登陆奖励
-- ljh 2016119
RegressionLoginItem = RegressionLoginItem or BaseClass()

function RegressionLoginItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil

    self.parent = parent
    self.model = self.parent.model

    self.transform = self.gameObject.transform

    self.reward = self.transform:FindChild("Reward")
    self.buy = self.transform:FindChild("Buy")

    self.nametext = self.reward:FindChild("NameText"):GetComponent(Text)

	self.container = self.reward:FindChild("Mask/Container")
	self.item = self.container:FindChild("Item").gameObject
	self.item:SetActive(false)
	self.scrollRect = self.reward:FindChild("Mask"):GetComponent(ScrollRect)

	self.reward:FindChild("Mask"):GetComponent(ScrollRect).onValueChanged:AddListener(function() self:OnValueChanged() end)

    local btn = nil
	btn = self.reward:FindChild("OkButton"):GetComponent(Button)
	btn.onClick:RemoveAllListeners()
	btn.onClick:AddListener(function() self.parent:ItemOkButtonClick(self.gameObject) end)
	self.button = btn.gameObject
	self.buttonText = self.reward:FindChild("OkButton/Text"):GetComponent(Text)

	self.tag = self.reward:FindChild("Tag").gameObject
	self.tag:SetActive(false)
	self.result = self.reward:FindChild("Result").gameObject
	self.resultText = self.result.transform:FindChild("Text"):GetComponent(Text)

	self.item_list = {}
	self.itemSlot_list = {}

	self.nametext_buy = self.buy:FindChild("NameText"):GetComponent(Text)

	self.container_buy = self.buy:FindChild("Mask/Container")
	self.item_buy = self.container:FindChild("Item").gameObject
	self.item_buy:SetActive(false)
	self.scrollRect_buy = self.buy:FindChild("Mask"):GetComponent(ScrollRect)

	btn = self.buy:FindChild("OkButton"):GetComponent(Button)
	btn.onClick:RemoveAllListeners()
	btn.onClick:AddListener(function() self.parent:ItemBuyButtonClick(self.gameObject, self.nowPrice) end)
	self.button_buy = btn.gameObject
	self.button_buy_txt = btn.transform:Find("Text"):GetComponent(Text)
	self.item_list_buy = {}
	self.itemSlot_list_buy = {}

	self.oldPriceText = self.buy:FindChild("OldPriceText"):GetComponent(Text)
	self.nowPriceText = self.buy:FindChild("NowPriceText"):GetComponent(Text)

	self.limitText = self.buy:FindChild("LimitBg/Text"):GetComponent(Text)

	self.layoutElement = self.gameObject:GetComponent(LayoutElement)

	self.nowPrice = 0

	----------------------------- index == 7 抽奖时专用
	self.luckDrawItem = nil
	self.luckDrawItemSlot = nil

	self.itemEffectList = {}
end

function RegressionLoginItem:__delete()
	if self.luckDrawItemSlot ~= nil then
	    self.luckDrawItemSlot:DeleteMe()
	    self.luckDrawItemSlot = nil
	end

	for k,v in pairs(self.itemSlot_list_buy) do
        v:DeleteMe()
        v = nil
    end
 
	for k,v in pairs(self.itemSlot_list) do
        v:DeleteMe()
        v = nil
    end
end

--设置
function RegressionLoginItem:SetActive(boo)
    self.gameObject:SetActive(boo)
end

function RegressionLoginItem:Release()
end

function RegressionLoginItem:InitPanel(_data)
    self:update_my_self(_data)
end

--更新内容
function RegressionLoginItem:update_my_self(_data, _index)
	self.data = _data
	local data = _data
	self.gameObject.name = tostring(data.day)

	-- if data.receive == 4 and data.today and (_index == 3 or _index == 7) then
	if data.receive == 4 and data.time > BaseUtils.BASE_TIME and (_index == 3 or _index == 7) then
	    self.reward.gameObject:SetActive(false)
	    self.buy.gameObject:SetActive(true)
		self.layoutElement.preferredHeight = 122

		if data.buy == 4 then
	    	self.button_buy:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
	    	self.button_buy_txt.text = string.format(ColorHelper.DefaultButton1Str, TI18N("领 取"))
	    else
	    	self.button_buy:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
	    	self.button_buy_txt.text = string.format(ColorHelper.DefaultButton4Str, TI18N("领 取"))
	    end

	    self.nametext_buy.text = TI18N("今日登陆限时礼包")
	    self.oldPriceText.text = data.original[1][2]
	    self.nowPriceText.text = data.pirce[1][2]
		self.nowPrice = tonumber(data.pirce[1][2])

		for i=1, #data.limit do
			local item = self.item_list_buy[i]
			local itemSlot = self.itemSlot_list_buy[i]
			if item == nil then
				local item = GameObject.Instantiate(self.item_buy)
	            item:SetActive(true)
	            item.transform:SetParent(self.container_buy)
	            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
	            table.insert(self.item_list_buy, item)

	            itemSlot = ItemSlot.New()
	            UIUtils.AddUIChild(item, itemSlot.gameObject)
	            table.insert(self.itemSlot_list_buy, itemSlot)

	            if DataFriend.data_get_recalled_effect[data.limit[i][1]] then
					-- local fun = function(effectView)
				 --        local effectObject = effectView.gameObject
				 --        effectObject.transform:SetParent(itemSlot.transform)
				 --        effectObject.name = "Effect"
				 --        effectObject.transform.localScale = Vector3.one
				 --        effectObject.transform.localPosition = Vector3.zero
				 --        effectObject.transform.localRotation = Quaternion.identity

				 --        Utils.ChangeLayersRecursively(effectObject.transform, "UI")

				 --        self:OnValueChanged()
				 --    end
			 --    table.insert(self.itemEffectList, BaseEffectView.New({effectId = 20223, callback = fun}))
				    table.insert(self.itemEffectList, RegressionManager.Instance:CreatEffect(20223, itemSlot.transform, Vector3.one, Vector3.zero, Quaternion.identity, function() self:OnValueChanged() end))
				end
			end

			local itembase = BackpackManager.Instance:GetItemBase(data.limit[i][1])
	        local itemData = ItemData.New()
	        itemData:SetBase(itembase)
	        itemData.quantity = data.limit[i][2]

			itemSlot:SetAll(itemData, {nobutton = true})
		end

		self.scrollRect_buy.enabled = #data.limit > 5

		self.data.timeOut = (self.data.nowDay + 1) * 86400
	else
		self.reward.gameObject:SetActive(true)
	    self.buy.gameObject:SetActive(false)
	    self.layoutElement.preferredHeight = 92

	    if _index == 7 then
			if self.luckDrawItem == nil then
				self.luckDrawItem = GameObject.Instantiate(self.item)
			    self.luckDrawItem:SetActive(true)
			    self.luckDrawItem.transform:SetParent(self.container)
			    self.luckDrawItem:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)

				self.luckDrawItemSlot = ItemSlot.New()
				UIUtils.AddUIChild(self.luckDrawItem, self.luckDrawItemSlot.gameObject)

				self.luckDrawItemSlot:SetNotips(true)

				local data_list = {}
				for i = 1, #DataFriend.data_get_reward_draw do
			        table.insert(data_list, DataFriend.data_get_reward_draw[i].reward[1])
			    end
				self.luckDrawItemSlot:SetSelectSelfCallback(function()
			    		self.model:OpenGiftPreview({reward = data_list, autoMain = false, text = TI18N("神秘抽奖必定获得以下道具之一："), width = 110, height = 105, column = 6})
			    	end)

				if DataFriend.data_get_recalled_effect[24005] then
					-- local fun = function(effectView)
				 --        local effectObject = effectView.gameObject
				 --        effectObject.transform:SetParent(itemSlot.transform)
				 --        effectObject.name = "Effect"
				 --        effectObject.transform.localScale = Vector3.one
				 --        effectObject.transform.localPosition = Vector3.zero
				 --        effectObject.transform.localRotation = Quaternion.identity

				 --        Utils.ChangeLayersRecursively(effectObject.transform, "UI")

				 --        self:OnValueChanged()
				 --    end
				 --    table.insert(self.itemEffectList, BaseEffectView.New({effectId = 20223, callback = fun}))
				    table.insert(self.itemEffectList, RegressionManager.Instance:CreatEffect(20223, self.luckDrawItemSlot.transform, Vector3.one, Vector3.zero, Quaternion.identity, function() self:OnValueChanged() end))
				end
			end

			local itembase = BackpackManager.Instance:GetItemBase(24005)
			local itemData = ItemData.New()
			itemData:SetBase(itembase)
			self.luckDrawItemSlot:SetAll(itemData, {nobutton = true})
		end

	    if data.receive == 1 then
	    	self.button:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
	    	if _index == 7 then
	    		self.buttonText.text = string.format(ColorHelper.DefaultButton2Str, TI18N("抽 奖"))
	    	else
	    		self.buttonText.text = string.format(ColorHelper.DefaultButton2Str, TI18N("领 取"))
	    	end
	    	self.button:SetActive(true)
	    	self.button:GetComponent(TransitionButton).enabled = true
	    	self.result:SetActive(false)
	    elseif data.receive == 2 or data.receive == 3 or data.receive == 4 or data.receive == 5 then
	    	self.button:SetActive(false)
	    	self.result:SetActive(true)
	    	if _index == 7 then
	    		self.resultText.text = TI18N("已抽奖")
	    	else
	    		self.resultText.text = TI18N("已领取")
	    	end
	    else
	    	-- self.button:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
	    	-- self.buttonText.text = TI18N("未开启")
	    	-- self.button:GetComponent(TransitionButton).enabled = false
	    	-- self.button:SetActive(true)
	    	self.button:SetActive(false)
	    	self.result:SetActive(true)

	    	if _index == 7 then
	    		self.resultText.text = string.format(TI18N("第<color='#00ff00'>%s</color>天登陆可抽奖"), _index)
	    	else
	    		self.resultText.text = string.format(TI18N("第<color='#00ff00'>%s</color>天登陆可领取"), _index)
	    	end
	    end

	    self.nametext.text = string.format(TI18N("第%s天奖励"), data.day)

	    local index = 1
	    local roleData = RoleManager.Instance.RoleData
		for i=1, #data.reward_client do
			local rewardData = data.reward_client[i]
			if roleData.lev >=  rewardData[1] and roleData.lev <= rewardData[2]then
				local item = self.item_list[index]
				local itemSlot = self.itemSlot_list[index]
				if item == nil then
					local item = GameObject.Instantiate(self.item)
		            item:SetActive(true)
		            item.transform:SetParent(self.container)
		            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
		            table.insert(self.item_list, item)

		            itemSlot = ItemSlot.New()
		            UIUtils.AddUIChild(item, itemSlot.gameObject)
		            table.insert(self.itemSlot_list, itemSlot)

		            if DataFriend.data_get_recalled_effect[rewardData[3]] then
						-- local fun = function(effectView)
					 --        local effectObject = effectView.gameObject
					 --        effectObject.transform:SetParent(itemSlot.transform)
					 --        effectObject.name = "Effect"
					 --        effectObject.transform.localScale = Vector3.one
					 --        effectObject.transform.localPosition = Vector3.zero
					 --        effectObject.transform.localRotation = Quaternion.identity

					 --        Utils.ChangeLayersRecursively(effectObject.transform, "UI")

					 --        self:OnValueChanged()
					 --    end
					 --    table.insert(self.itemEffectList, BaseEffectView.New({effectId = 20223, callback = fun}))
					    table.insert(self.itemEffectList, RegressionManager.Instance:CreatEffect(20223, itemSlot.transform, Vector3.one, Vector3.zero, Quaternion.identity, function() self:OnValueChanged() end))
					end
				end

				local itembase = BackpackManager.Instance:GetItemBase(rewardData[3])
		        local itemData = ItemData.New()
		        itemData:SetBase(itembase)
		        itemData.quantity = rewardData[4]

				itemSlot:SetAll(itemData, {nobutton = true})

				index = index + 1
			end
		end

		if _index == 7 then
			self.scrollRect.enabled = index > 4
		else
			self.scrollRect.enabled = index > 5
		end
	end
end

function RegressionLoginItem:Refresh(args)

end

function RegressionLoginItem:OnTimer()
    -- if self.data.receive == 4 and self.data.today and (self.data.day == 3 or self.data.day == 7) then
    if self.data.receive == 4 and self.data.time > BaseUtils.BASE_TIME and (self.data.day == 3 or self.data.day == 7) then
    	-- local time = self.data.timeOut - BaseUtils.LocalTime(BaseUtils.BASE_TIME)
    	local time = self.data.time - BaseUtils.BASE_TIME
    	if time >= 0 then
	    	local timeStr = BaseUtils.formate_time_gap(time, ":", 0, BaseUtils.time_formate.HOUR)
	    	self.limitText.text = string.format(TI18N("剩余时间：%s"), timeStr)
	    else
	    	RegressionManager.Instance:Send9938()
	    end
    end
end

function RegressionLoginItem:OnValueChanged()
	local x = self.container.anchoredPosition.x
    local width = self.container.parent.rect.width
	local y = self.transform.parent.anchoredPosition.y
    local height = self.transform.parent.parent.rect.height

    for _,v in pairs(self.itemEffectList) do
        if v ~= nil and v.gameObject ~= nil and not BaseUtils.is_null(v.gameObject) then
            local item = v.gameObject.transform.parent.parent
            local outX = item.anchoredPosition.x - item.sizeDelta.x / 2 + x < 0  or item.anchoredPosition.x + item.sizeDelta.x / 2 + x > width
            item = self.gameObject.transform
            local outY = -item.anchoredPosition.y < y or -item.anchoredPosition.y + item.sizeDelta.y > y + height
        	v:SetActive(not (outX or outY))
        end
    end
end
