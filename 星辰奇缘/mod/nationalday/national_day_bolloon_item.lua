-- --------------------------------
-- 国庆气球收集包裹
-- hosr
-- --------------------------------
NationalDayBolloonItem = NationalDayBolloonItem or BaseClass()

function NationalDayBolloonItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent
	self.transform = self.gameObject.transform
	self.pos = self.transform.localPosition
	self:InitPanel()
end

function NationalDayBolloonItem:__delete()
	self.smallIcon.sprite = nil
	self.bigIcon.sprite = nil

	 if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end

	if self.delayId ~= nil then
		LuaTimer.Delete(self.delayId)
		self.delayId = nil
	end

	self:CancalPingpong()
end

function NationalDayBolloonItem:InitPanel()
	self.SelectImage = self.transform:Find("SelectImage").gameObject
	self.Num = self.transform:Find("Num/ConDescText"):GetComponent(Text)
	self.name = self.transform:Find("Text"):GetComponent(Text)
	self.nameObj = self.name.gameObject
	self.OkImage = self.transform:Find("OkImage").gameObject
	self.CommitImage = self.transform:Find("CommitImage").gameObject
	self.FlagImage = self.transform:Find("FlagImage").gameObject
	self.smallIcon = self.transform:Find("SmallIcon"):GetComponent(Image)
	self.bigIcon = self.transform:Find("BigIcon"):GetComponent(Image)
	self.bigIconObj = self.bigIcon.gameObject
	self.bigIconRect = self.bigIconObj:GetComponent(RectTransform)
	self.bigIconObj:SetActive(false)
	self.txtBg = self.transform:Find("Image").gameObject
	self.txtBg:SetActive(false)

	self.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickItem() end)

	self.imgLoader = nil
	self.SelectImage:SetActive(false)
	self.OkImage:SetActive(false)
	self.CommitImage:SetActive(false)
	self.FlagImage:SetActive(false)
end

-- id = 23724,
-- num = 0,
-- status = 0,
function NationalDayBolloonItem:SetData(data)
	self.data = data
	self.base = DataCampaignBags.data_getBags[data.id]
	self.has = BackpackManager.Instance:GetItemCount(data.id)

	self.Num.text = self.base.need
	local itemData = DataItem.data_get[data.id]
	if itemData ~= nil then
		self.name.text = ColorHelper.color_item_name(itemData.quality, itemData.name)
		self.smallIcon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.national_day_res, string.format("NationDalBalloonQualify%s", itemData.quality))
		if self.imgLoader == nil then
			local  go = self.transform:Find("BigIcon").gameObject
			self.imgLoader = SingleIconLoader.New(go)
		end
    	self.imgLoader:SetSprite(SingleIconType.Item, itemData.icon)
	end

	if self.data.status == 1 then
		self.OkImage:SetActive(true)
		self.CommitImage:SetActive(false)
		self.bigIconObj:SetActive(true)
		self.nameObj:SetActive(false)
		self.txtBg:SetActive(false)
		self.delayId = LuaTimer.Add(math.random(10, 1000), function() self:Pingpong() end)
		-- self:Pingpong()
	else
		self.nameObj:SetActive(true)
		self.txtBg:SetActive(true)
		self.bigIconObj:SetActive(false)
		self:CancalPingpong()
		if self.has >= self.base.need then
			self.OkImage:SetActive(false)
			self.CommitImage:SetActive(true)
		else
			self.OkImage:SetActive(false)
			self.CommitImage:SetActive(false)
		end
	end
end

function NationalDayBolloonItem:CanFill()
	if self.data ~= nil and self.has >= self.base.need and self.data.status ~= 1 then
		return true
	end
	return false
end

function NationalDayBolloonItem:IsFinish()
	if self.data ~= nil and self.data.num == self.base.need and self.data.status == 1 then
		return true
	end
	return false
end

function NationalDayBolloonItem:Select(bool)
	self.SelectImage:SetActive(bool)
	self.FlagImage:SetActive(bool)
end

function NationalDayBolloonItem:ClickItem()
	if self.parent ~= nil then
		self.parent:SelectOne(self)
	end
end

function NationalDayBolloonItem:Pingpong()
	self:CancalPingpong()
	if BaseUtils.is_null(self.gameObject) then
		return
	end
	self.bigIconRect.anchoredPosition = Vector2(2, 53)
	local to = self.bigIconObj.transform.localPosition.y + 10
	self.tweenId = Tween.Instance:MoveLocalY(self.bigIconObj, to, 1.6, nil, LeanTweenType.linear):setLoopPingPong().id
end

function NationalDayBolloonItem:CancalPingpong()
	if self.tweenId ~= nil then
		Tween.Instance:Cancel(self.tweenId)
		self.tweenId = nil
	end
end

function NationalDayBolloonItem:GetPos()
	return Vector3(self.pos.x, self.pos.y, -500)
end