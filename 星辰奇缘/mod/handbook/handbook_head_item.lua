-- ----------------------------------------
-- 幻化手册组合头像
-- hosr
-- ----------------------------------------
HandbookHeamItem = HandbookHeamItem or BaseClass()

function HandbookHeamItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent
	self.transform = gameObject.transform
	self:InitPanel()
end

function HandbookHeamItem:__delete()
	if self.img ~= nil then
		self.img.sprite = nil
	end
end

function HandbookHeamItem:InitPanel()
	self.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickSelf() end)
	self.select = self.transform:Find("Select").gameObject
	self.select:SetActive(false)
	self.img = self.transform:Find("Head/Img"):GetComponent(Image)
	self.name = self.transform:Find("Name"):GetComponent(Text)
end

function HandbookHeamItem:update_my_self(data)
	self.data = data
	self.status = ""

	-- local max_lev = 1
	-- for _,id in pairs(data.book_list) do
	-- 	if max_lev < DataHandbook.data_base[id].level_limit then
	-- 		max_lev = DataHandbook.data_base[id].level_limit
	-- 	end
	-- end
	if self.data.num < self.data.max_num then
		self.status = string.format("\n%s", TI18N("(未激活)"))
	end

	-- self.isAllActice = true
	self.isAllOne = true
	local isActive = nil
	for i,id in ipairs(self.data.book_list) do
		local handbook = HandbookManager.Instance:GetDataById(id)
		isActive = false
		if handbook ~= nil then
			isActive = (handbook.status == HandbookEumn.Status.Active)
			self.isAllOne = self.isAllOne and (handbook.star_step >= 1)
		end
		-- self.isAllActice = self.isAllActice and isActive
	end

	if self.data.num < self.data.max_num or RoleManager.Instance.RoleData.lev < data.level_limit then
		-- self.name.text = string.format("%s\n%s", self.data.name, TI18N("(未激活)"))
		self.name.text = string.format("%s\n%s级可激活", self.data.name, data.level_limit)
	elseif not self.isAllOne then
		self.name.text = string.format("%s\n<color='%s'>%s</color>", self.data.name, ColorHelper.color[1], TI18N("(可激活★加成)"))
	else
		self.name.text = self.data.name
	end

	self.img.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.handbookmatch, tostring(self.data.set_id))
end

function HandbookHeamItem:ClickSelf()
	if self.parent ~= nil then
		self.parent:SelectOne(self)
	end
end

function HandbookHeamItem:Select(bool)
	self.select:SetActive(bool)
	-- if bool then
	-- 	if self.isAllActice and self.isAllOne then
	-- 		self.name.text = string.format("<color='#ffff9a'>%s★</color>%s", self.data.name, self.status)
	-- 	else
	-- 		self.name.text = string.format("<color='#ffff9a'>%s</color>%s", self.data.name, self.status)
	-- 	end
	-- else
	-- 	if self.isAllActice and self.isAllOne then
	-- 		self.name.text = string.format("<color='#2fc823'>%s★</color>%s", self.data.name, self.status)
	-- 	else
	-- 		self.name.text = string.format("<color='#2fc823'>%s</color>%s", self.data.name, self.status)
	-- 	end
	-- end
end