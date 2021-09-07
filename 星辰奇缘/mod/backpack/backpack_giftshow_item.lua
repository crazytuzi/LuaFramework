-- ---------------------------
-- 礼包打开展示元素
-- hosr
-- ---------------------------
BackpackGiftShowItem = BackpackGiftShowItem or BaseClass()

function BackpackGiftShowItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent
	self.gameObject:SetActive(false)
	self:InitPanel()
end

function BackpackGiftShowItem:__delete()
	if self.slot then
		self.slot:DeleteMe()
	end
	self.slot = nil
end

function BackpackGiftShowItem:InitPanel()
	self.transform = self.gameObject.transform
	self.name = self.transform:Find("Name"):GetComponent(Text)

    self.slot = ItemSlot.New()
    self.slot.button.interactable = false
    UIUtils.AddUIChild(self.transform:Find("Slot").gameObject, self.slot.gameObject)
end

-- {item_id = 10312,bind = 0,num = 1}
function BackpackGiftShowItem:SetData(data)
	self.data = data
	local myId = self.data.id or self.data.item_id or self.data.base_id
    local myNum = self.data.number or self.data.num or self.data.val
    local myBind = self.data.bind

	local base = BaseUtils.copytab(DataItem.data_get[myId])
	if base == nil then
		self.slot:SetAll(nil)
		self.name.text = ""
	else
		local item = ItemData.New()
		item:SetBase(base)
		item.bind = myBind
		item.quantity = myNum
		self.slot:SetAll(item, {nobutton = true})
		self.slot:SetNum(myNum)
		self.name.text = ColorHelper.color_item_name(item.quality, item.name)
	end
	self.slot.transform.localScale = Vector3.one * 2.5
	self.gameObject:SetActive(false)
end

function BackpackGiftShowItem:Show()
	Tween.Instance:Scale(self.slot.gameObject, Vector3.one, 0.2, nil, LeanTweenType.linear)
	self.gameObject:SetActive(true)
end