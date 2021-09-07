-- ----------------------------------
-- 国庆摇奖元素
-- hosr
-- ----------------------------------
NationalDayRollItem = NationalDayRollItem or BaseClass()

function NationalDayRollItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent
	self.transform = self.gameObject.transform

	self:InitPanel()
end

function NationalDayRollItem:__delete()
	if self.slot ~= nil then
		self.slot:DeleteMe()
		self.slot = nil
	end

	if self.itemData ~= nil then
		self.itemData:DeleteMe()
		self.itemData = nil
	end
end

function NationalDayRollItem:InitPanel()
    self.slot = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:Find("Slot").gameObject, self.slot.gameObject)

    self.image = self.gameObject:GetComponent(Image)
    self.select = self.transform:Find("Select").gameObject
    self.hit = self.transform:Find("Hit").gameObject
    self.hit:SetActive(false)

    local p = self.transform.localPosition
    self.position = Vector3(p.x, p.y, -500)
end

function NationalDayRollItem:Select(bool)
	self.select:SetActive(bool)
end

-- {uint16, id, "奖励序号"}
-- ,{uint32, assets, "奖励类型"}
-- ,{uint32, val, "奖励值"}
-- ,{uint8, is_hit, "是否已经命中，0:未命中 1:已经命中"}
function NationalDayRollItem:SetData(data)
	if self.itemData == nil then
		self.itemData = ItemData.New()
	end
	local itemBase = DataItem.data_get[data.assets]
	if itemBase == nil then
		Log.Error(string.format("I can't find it. id=%s ,assets=%s ", data.id, data.assets))
	end
	self.itemData:SetBase(BaseUtils.copytab(itemBase))
	self.slot:SetAll(self.itemData)
	self.slot:SetNum(data.val)
	-- self.slot:ShowNum(true)

	if data.is_hit == 1 then
		self.image.color = Color.gray
		self.slot:SetGrey(true)
		self.hit:SetActive(true)
	else
		self.hit:SetActive(false)
		self.image.color = Color.white
		self.slot:SetGrey(false)
	end
end

function NationalDayRollItem:ShowTime()
	self.transform.localScale = Vector3.one * 1.2
	self.tweenId1 = Tween.Instance:Scale(self.gameObject, Vector3.one, 0.7, nil, LeanTweenType.easeOutElastic).id
end