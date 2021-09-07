-- ------------------------------
-- 孩子选择职业元素
-- hosr
-- ------------------------------
ChildChossesClassesItem = ChildChossesClassesItem or BaseClass()

function ChildChossesClassesItem:__init(gameObject, parent, index)
	self.gameObject = gameObject
	self.parent = parent
	self.index = index

	self:InitPanel()
end

function ChildChossesClassesItem:__delete()
	self.icon.sprite = nil
	self.name.sprite = nil
end

function ChildChossesClassesItem:InitPanel()
	self.transform = self.gameObject.transform
	self.normal = self.transform:Find("Normal").gameObject
	self.select = self.transform:Find("Select").gameObject
	self.icon = self.transform:Find("ClassesIcon"):GetComponent(Image)
	self.name = self.transform:Find("ClassesName"):GetComponent(Image)
	if self.index == 3 then
		self.name.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.classesnamei18n, "Classes0")
		self.name:SetNativeSize()
	end

	self.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickSelf() end)
end

function ChildChossesClassesItem:SetData(data, index)
	self.index = index
	self.classes = data
	self.name.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.classesnamei18n, string.format("Classes%s", self.classes))
	self.name:SetNativeSize()
	self.icon.sprite = PreloadManager.Instance:GetClassesSprite(self.classes)
	self.icon:SetNativeSize()
end

function ChildChossesClassesItem:ClickSelf()
	self:Select(true)
	if self.index == 3 then
		ChildrenManager.Instance.model:CloseChooseClasses()
		ChildrenManager.Instance.model:OpenChangeType()
	else
		self.parent:ClickItem(self.index)
	end
end

function ChildChossesClassesItem:Select(bool)
	self.select:SetActive(bool)
	self.normal:SetActive(not bool)
end