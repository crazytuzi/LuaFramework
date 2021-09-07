-- ---------------------------------
-- 国庆十连抽奖励项
-- hosr
-- ---------------------------------
NationalDayRewardItem = NationalDayRewardItem or BaseClass()

function NationalDayRewardItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent

	self:InitPanel()
end

function NationalDayRewardItem:__delete()
	self:Stop()
	if self.slot ~= nil then
		self.slot:DeleteMe()
		self.slot = nil
	end
end

function NationalDayRewardItem:InitPanel()
	self.transform = self.gameObject.transform
	self.slot = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:Find("Slot").gameObject, self.slot.gameObject)
    self.nameTxt = self.transform:Find("Name/Val"):GetComponent(Text)
    self.gameObject:SetActive(false)
end

-- {base_id = v.assets, num = v.val}
function NationalDayRewardItem:SetData(data)
	self.data = data

	if self.itemData == nil then
		self.itemData = ItemData.New()
	end
	local has = BackpackManager.Instance:GetItemCount(self.data.base_id)
	self.itemData:SetBase(DataItem.data_get[self.data.base_id])
	self.slot:SetAll(self.itemData)
	self.slot:SetNum(self.data.num)
	self.nameTxt.text = ColorHelper.color_item_name(self.itemData.quality, self.itemData.name)
	-- self.slot:ShowNum(true)

	local nationBase = DataCampNational.data_roll_reward[self.data.base_id]
	if nationBase ~= nil and nationBase.show_effect == 1 then
	    self.effect = GameObject.Instantiate(self.parent.effect)
	    local effectTransform = self.effect.transform
	    effectTransform:SetParent(self.slot.transform)
	    effectTransform.localScale = Vector3.one
	    effectTransform.localPosition = Vector3(-32, -23, -500)
	    Utils.ChangeLayersRecursively(effectTransform, "UI")
	    self.effect:SetActive(true)
	end
end

function NationalDayRewardItem:Reset()
	self.transform.localScale = Vector3.one * 0.5
	self:Stop()
end

function NationalDayRewardItem:Stop()
	if self.tweenId1 ~= nil then
		Tween.Instance:Cancel(self.tweenId1)
		self.tweenId1 = nil
	end
end

function NationalDayRewardItem:ShowTime()
	self:Reset()
    self.gameObject:SetActive(true)
	self.tweenId1 = Tween.Instance:Scale(self.gameObject, Vector3.one, 1, nil, LeanTweenType.easeOutElastic).id
end