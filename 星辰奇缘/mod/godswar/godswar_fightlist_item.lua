-- ---------------------------
-- 诸神之战 分组元素
-- hosr
-- ---------------------------
GodsWarFightListItem = GodsWarFightListItem or BaseClass()

function GodsWarFightListItem:__init(gameObject, parent, index)
	self.gameObject = gameObject
	self.parent = parent
	self.index = index

	self.itemList = {}
	self:InitPanel()
end

function GodsWarFightListItem:__delete()
	for i,v in ipairs(self.itemList) do
		v:DeleteMe()
	end
	self.itemList = nil
end

function GodsWarFightListItem:InitPanel()
	self.transform = self.gameObject.transform
	self.title = self.transform:Find("Title"):GetComponent(Text)
	self.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickSelf() end)
	self.title.text = string.format(TI18N("第%s小组"), self.index)

	local container = self.transform:Find("Container")
	local len = container.childCount
	for i = 1, len do
		local item = GodsWarFightDetailItem.New(container:GetChild(i - 1).gameObject, self)
		table.insert(self.itemList, item)
	end
end

function GodsWarFightListItem:SetData(list)
	self.list = list
	for i,item in ipairs(self.itemList) do
		item:SetData(self.list[i])
	end
end

function GodsWarFightListItem:ClickSelf()
	if self.list ~= nil and #self.list > 0 then
		GodsWarManager.Instance.model:OpenDetail({list = self.list, index = self.index})
	end
end
