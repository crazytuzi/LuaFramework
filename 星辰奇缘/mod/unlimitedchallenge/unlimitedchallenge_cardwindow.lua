--作者:hzf
--09/19/2016 15:23:40
--功能:无尽挑战翻牌

UnlimitedChallengeCardWindow = UnlimitedChallengeCardWindow or BaseClass(BasePanel)
function UnlimitedChallengeCardWindow:__init(model)
	self.model = model
	self.Effect = "prefabs/effect/20184.unity3d"
	self.resList = {
		{file = AssetConfig.unlimited_cardwindow, type = AssetType.Main}
		,{file  =  AssetConfig.unlimited_texture, type  =  AssetType.Dep}
		,{file = self.Effect, type = AssetType.Main},
	}
	self.OnOpenEvent:Add(function() self:OnOpen() end)
	self.OnHideEvent:Add(function() self:OnHide() end)
	self.isHideMainUI = true
	self.showconfirm = true
	self.OpenList = {}
	self.slotlist = {}
end

function UnlimitedChallengeCardWindow:__delete()
	for k,v in pairs(self.slotlist) do
	    v:DeleteMe()
	end
	self.slotlist = {}
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function UnlimitedChallengeCardWindow:OnHide()

end

function UnlimitedChallengeCardWindow:OnOpen()
	self.data = self.openArgs
	self:OpenCard(self.data)
end

function UnlimitedChallengeCardWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.unlimited_cardwindow))
	self.gameObject.name = "UnlimitedChallengeCardWindow"
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

	self.transform = self.gameObject.transform
	self.data = self.openArgs
	self.SingleEffect = GameObject.Instantiate(self:GetPrefab(self.Effect))
    self.SingleEffect.transform:SetParent(self.transform)
    self.SingleEffect.transform.localScale = Vector3.one
    self.SingleEffect.transform.localPosition = Vector3.zero
    Utils.ChangeLayersRecursively(self.SingleEffect.transform, "UI")
    self.SingleEffect:SetActive(false)

	self.Panel = self.transform:Find("Panel")
	self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function()
		NoticeManager.Instance:FloatTipsByString(TI18N("点击返回按钮，退出界面"))
	end)
	self.CloseButton = self.transform:Find("CloseButton"):GetComponent(Button)
	self.CloseButton.onClick:AddListener(function()
		self.model:CloseCardWindow()
	end)
	self.CardGoup = self.transform:Find("_MainCon/CardGoup")

	self.TitleText = self.transform:Find("_MainCon/_Title/TitleText"):GetComponent(Text)
	self.Cost = self.transform:Find("_MainCon/Cost")
	self.CostText = self.transform:Find("_MainCon/Cost/CostText"):GetComponent(Text)
	self.AssestImage = self.transform:Find("_MainCon/Cost/AssestImage"):GetComponent(Image)
	self.DescText = self.transform:Find("_MainCon/DescText"):GetComponent(Text)
	self.FreeText = self.transform:Find("_MainCon/FreeText"):GetComponent(Text)
	self.DescText.text = TI18N("每日<color='#ffff00'>首次</color>通关无尽第<color='#ffff00'>12</color>波，可获得无尽卡牌奖励")

	self.CardGoup.gameObject:SetActive(true)
	self:InitCardList()
	self:OpenCard(self.data)
end

function UnlimitedChallengeCardWindow:InitCardList()
	self.CardList = {}
	for i=1, 5 do
		self.CardList[i] = {}
		local trans = self.transform:Find("_MainCon/CardGoup/Card"..tostring(i))
		self.CardList[i].transform = trans
		self.CardList[i].CloseCardButton = trans:Find("Close"):GetComponent(Button)
		self.CardList[i].resultCard = trans:Find("result")
		self.CardList[i].Slot = trans:Find("result/Slot")
		self.CardList[i].NameText = trans:Find("result/Slot/NameText"):GetComponent(Text)
		self.CardList[i].CloseCardButton.onClick:AddListener(function()
			local costdata = DataEndlessChallenge.data_card_info[self.data.turn_count+1]
			if self.data.turn_count >= self.data.free_count and self.showconfirm == true and costdata.cost[1][1] == 90002 then
				-- BaseUtils.dump(costdata, "去你妈的")
				local data = NoticeConfirmData.New()
	            data.type = ConfirmData.Style.Normal
	            data.content = string.format(TI18N("是否花费{assets_1, %s, %s},获得无尽卡牌奖励？"), costdata.cost[1][1], costdata.cost[1][2])
	            data.sureLabel = TI18N("确认")
	            data.cancelLabel = TI18N("取消")
	            data.sureCallback = function()
	            	self.showconfirm = false
					self.model.Mgr:Require17214(i)
	            end
	            NoticeManager.Instance:ConfirmTips(data)
	            return
			else
				self.model.Mgr:Require17214(i)
			end
		end)
	end
end

function UnlimitedChallengeCardWindow:OpenCard(data)
	SoundManager.Instance:Play(245)
	if data.order ~= nil and data.order ~= 0 then
		if self.OpenList[data.order] ~= nil then
			for i=1, 5 do
				if self.OpenList[i] == nil then
					data.order = i
				end
			end
		end
		self.OpenList[data.order] = data.order
		local itemgetdata = data.gain_list[1]
		local slot = ItemSlot.New()
	    local info = ItemData.New()
	    local base = DataItem.data_get[itemgetdata.item_id1]
	    info:SetBase(base)
	    info.quantity = itemgetdata.num1
	    local extra = {inbag = false, nobutton = true}
	    slot:SetAll(info, extra)
	    table.insert(self.slotlist, slot)
	    UIUtils.AddUIChild(self.CardList[data.order].Slot.gameObject, slot.gameObject)
		self.CardList[data.order].NameText.text = string.format("%sx%s", ColorHelper.color_item_name(base.quality, base.name), itemgetdata.num1)

	    self.CardList[data.order].CloseCardButton.gameObject:SetActive(false)

	    self.SingleEffect.transform:SetParent(self.CardList[data.order].transform)
	    self.SingleEffect:SetActive(false)
	    self.SingleEffect:SetActive(true)
	    self.SingleEffect.transform.localPosition = Vector3(0, 0, -1000)
	    self.SingleEffect.transform.localScale = Vector3.one
	    LuaTimer.Add(600, function()
	    	if self.CardList ~= nil and not BaseUtils.isnull(self.CardList[data.order].transform) then
	    		self.CardList[data.order].resultCard.gameObject:SetActive(true)
	    	end
	    end)
	end
	if data ~= nil then
		local costdata = DataEndlessChallenge.data_card_info[data.turn_count+1]
		if costdata ~= nil then
			self.CostText.text = string.format("本次翻牌所需：<color='#ffff00'>%s</color>", costdata.cost[1][2])
			self.AssestImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, string.format("Assets%s", tostring(costdata.cost[1][1])))
			self.Cost.sizeDelta = Vector2(self.CostText.preferredWidth+40, 30.5)
		end
		self.TitleText.text = string.format(TI18N("成功击退<color='#00ff00'>%s</color>波敌人!"), data.best_wave)
		self.FreeText.text = TI18N("本次翻牌所需：<color='#00ff00'>免费</color>")
		self.CloseButton.gameObject:SetActive(data.turn_count >= data.free_count)
		-- self.Cost.gameObject:SetActive(data.turn_count >= data.free_count)
		self.AssestImage.gameObject:SetActive(data.turn_count >= data.free_count)
		if data.turn_count < data.free_count then
			self.CostText.text = TI18N("本次翻牌所需：<color='#00ff00'>免费</color>")
			self.Cost.sizeDelta = Vector2(self.CostText.preferredWidth+15, 30.5)
		end
		-- self.FreeText.gameObject:SetActive(data.turn_count < data.free_count)
	end
end