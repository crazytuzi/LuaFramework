-- ---------------------------------------
-- 子女天赋技能元素
-- hosr
-- ---------------------------------------
PetChildTelnetItem = PetChildTelnetItem or BaseClass()

function PetChildTelnetItem:__init(gameObject, parent, index)
	self.gameObject = gameObject
	self.parent = parent
	self.index = index

	self.isLock = false
	self.isAdd = false
	self:InitPanel()
	self.isFull = false
end

function PetChildTelnetItem:__delete()
	self.icon.sprite = nil
	self.gameObject = nil
	self.parent = nil
end

function PetChildTelnetItem:InitPanel()
	self.transform = self.gameObject.transform
	self.select = self.transform:Find("Select").gameObject
	self.icon = self.transform:Find("Icon"):GetComponent(Image)
	self.iconObj = self.icon.gameObject
	self.lock = self.transform:Find("Lock").gameObject
	self.add = self.transform:Find("Add").gameObject
	self.desc = self.transform:Find("Desc/Text"):GetComponent(Text)

	self.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickSelf() end)
	self:Default()
end

function PetChildTelnetItem:Default()
	self.select:SetActive(false)
	self.lock:SetActive(false)
	self.add:SetActive(false)
	self.iconObj:SetActive(false)
	self.isLock = false
	self.isAdd = false
	self.desc.text = ""
	self.data = nil
	self.isFull = false
end

function PetChildTelnetItem:SetData(data)
	self:Default()
	self.data = data
	if self.data.id == 0 then
		self:ShowAdd(true)
	else
		self.skillData = DataSkill.data_child_telent[string.format("%s_%s", self.data.id, self.data.lev)]
		self.icon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.childtelenticon, self.skillData.icon)
		self.iconObj:SetActive(true)
		self.desc.text = self.skillData.name

		if DataSkill.data_child_telent[string.format("%s_%s", self.data.id, self.data.lev + 1)] == nil then
			self.isFull = true
		else
			self.isFull = false
		end
	end
end

function PetChildTelnetItem:Select(bool)
	self.select:SetActive(bool)
end

function PetChildTelnetItem:Lock(bool)
	self.isLock = bool
	self.lock:SetActive(bool)
	self.add:SetActive(false)
	self.iconObj:SetActive(false)

	if bool then
		if self.quickShowMark then
			self.desc.text = TI18N("未习得")
		else
			self.desc.text = string.format(TI18N("%s阶开启"), self.index - 1)
		end
	else
		self.desc.text = ""
	end
end

function PetChildTelnetItem:ShowAdd(bool)
	self.add:SetActive(bool)
	self.isAdd = bool

	if bool then
		self.desc.text = TI18N("可学习")
	else
		self.desc.text = ""
	end
end

function PetChildTelnetItem:ClickSelf()
	if self.data == nil then
		return
	end

	if self.data.id == 0 then
		self.parent:ClickChange(self.index)
	else
		if self.showTips then
			TipsManager.Instance:ShowChildTelnet({gameObject = self.gameObject, data = self.data})
		else
			self:Select(true)
			self.parent:CliekOne(self.index)
		end
	end
end