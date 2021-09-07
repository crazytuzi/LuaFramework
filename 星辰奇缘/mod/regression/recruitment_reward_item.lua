-- 单项回归登陆奖励
-- ljh 2016119
RecruitmentRewardItem = RecruitmentRewardItem or BaseClass()

function RecruitmentRewardItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil

    self.parent = parent
    self.model = self.parent.model

    self.transform = self.gameObject.transform

    self.nametext = self.gameObject.transform:FindChild("NameText"):GetComponent(Text)
	
	self.container = self.gameObject.transform:FindChild("Mask/Container")
	self.item = self.container:FindChild("Item").gameObject
	self.item:SetActive(false)
	
	self.transform:FindChild("Mask"):GetComponent(ScrollRect).onValueChanged:AddListener(function() self:OnValueChanged() end)

	self.tag = self.gameObject.transform:FindChild("Tag").gameObject
	self.tag:SetActive(false)
	self.result = self.gameObject.transform:FindChild("Result").gameObject
	self.resultText = self.result.transform:FindChild("Text"):GetComponent(Text)

    local btn = nil
	btn = self.gameObject.transform:FindChild("OkButton"):GetComponent(Button)
	btn.onClick:RemoveAllListeners()
	btn.onClick:AddListener(function() self.parent:ItemOkButtonClick(self.gameObject) end)
	self.buttonObject = btn.gameObject

	self.progress = self.gameObject.transform:FindChild("Progress").gameObject
	self.progress_numtext = self.gameObject.transform:FindChild("Progress/NumText"):GetComponent(Text)
	self.progress_slider = self.gameObject.transform:FindChild("Progress/Slider"):GetComponent(Slider)

	self.item_list = {}
	self.itemSlot_list = {}

	self.scrollRect = self.gameObject.transform:FindChild("Mask"):GetComponent(ScrollRect)

	self.itemEffectList = {}
end

function RecruitmentRewardItem:__delete()
	for k,v in pairs(self.itemSlot_list) do
        v:DeleteMe()
        v = nil
    end
end

--设置
function RecruitmentRewardItem:SetActive(boo)
    self.gameObject:SetActive(boo)
end

function RecruitmentRewardItem:Release()
end

function RecruitmentRewardItem:InitPanel(_data)
    self:update_my_self(_data)
end

--更新内容
function RecruitmentRewardItem:update_my_self(_data, _index)
	local data = _data
	self.gameObject.name = tostring(data.id)

	self.nametext.text = TI18N("活跃：")

	self.progress_numtext.text = string.format("%s/%s", data.activite, data.activity)
	self.progress_slider.value = data.activite / data.activity

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
	            UIUtils.AddUIChild(self.container, item)
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
	
	if index < #self.item_list then
		for i=index + 1, #self.item_list do 
			local item = self.item_list[i]
			item:SetActive(false)
		end
	end

	self.scrollRect.enabled = index > 5

	if data.receive then
		self.buttonObject:SetActive(false)
		self.result:SetActive(true)
		self.resultText.text = TI18N("已领取")
	elseif data.activite >= data.activity then
		self.buttonObject:SetActive(true)
		self.result:SetActive(false)
	else
		self.buttonObject:SetActive(false)
		self.result:SetActive(true)
		self.resultText.text = string.format(TI18N("绑定者满\n<color='#00ff00'>%s</color>活跃"), data.activity)
	end
end

function RecruitmentRewardItem:Refresh(args)
    
end

function RecruitmentRewardItem:OnValueChanged()
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
