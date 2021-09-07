-- --------------------------------
-- 诸神之战 规则说明 每项单位
-- hosr
-- --------------------------------
GodsWarRuleItem = GodsWarRuleItem or BaseClass()

function GodsWarRuleItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent

	self.height = 0
	self.width = 680
	self:InitPanel()
end

function GodsWarRuleItem:__delete()
end

function GodsWarRuleItem:InitPanel()
	self.transform = self.gameObject.transform
	self.rect = self.gameObject:GetComponent(RectTransform)

	self.title = self.transform:Find("Title/Val"):GetComponent(Text)
	self.content = self.transform:Find("Content"):GetComponent(Text)
	self.contentRect = self.transform:Find("Content"):GetComponent(RectTransform)
end

function GodsWarRuleItem:SetData(data)
	self.title.text = data.name
	self.content.text = data.desc

	self.height = self.content.preferredHeight
	self.contentRect.sizeDelta = Vector2(self.width, self.height)
	self.height = self.height + 35

	self.gameObject:SetActive(true)
end