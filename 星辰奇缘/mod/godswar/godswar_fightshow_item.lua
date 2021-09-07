-- -----------------------
-- 诸神之战开战展示元素
-- hosr
-- -----------------------

GodsWarFightShowItem = GodsWarFightShowItem or BaseClass()

function GodsWarFightShowItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent

	self:InitPanel()
end

function GodsWarFightShowItem:__delete()
	self.head.sprite = nil
end

function GodsWarFightShowItem:InitPanel()
	self.transform = self.gameObject.transform
	self.head = self.transform:Find("Head/Img"):GetComponent(Image)
	self.name = self.transform:Find("Name"):GetComponent(Text)
	self.desc = self.transform:Find("Desc"):GetComponent(Text)
end

function GodsWarFightShowItem:SetData(data)
	self.data = data
	if self.data == nil then
		self.gameObject:SetActive(false)
	else
		self.head.sprite = PreloadManager.Instance:GetClassesHeadSprite(self.data.classes, self.data.sex)
		self.name.text = self.data.name
		self.desc.text = string.format("%s级 %s", self.data.lev, KvData.classes_name[self.data.classes])
		self.gameObject:SetActive(true)
	end
end
