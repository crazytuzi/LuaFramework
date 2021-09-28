ListSkillPreview =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function ListSkillPreview:__init( ... )
	-- print("======== ListSkillPreview:__init")
	self.URL = "ui://5gey1uxru2sk12";
	self:__property(...)
	self:Config()
	resMgr:AddUIAB("Tips")
end

-- Set self property
function ListSkillPreview:SetProperty( ... )
	
end

-- Logic Starting
function ListSkillPreview:Config()
	self:InitEvent()
	self:InitData()
end

function ListSkillPreview:InitData()
	self.skillItemList = {}
	self.skillItemData = {}
	self.skillItemURL = "ui://5gey1uxru2skx"
	self.skillDescTips = nil

	self.alter = nil
end

function ListSkillPreview:OpenSkillDescTips(title, desc)
	if title and desc then
		if self.skillDescTips == nil then
			self.skillDescTips = RoleSkillTips.New()
		
		end

		self.skillDescTips:SetData(title, desc)
		self.skillDescTips:SetUI()

		UIMgr.ShowPopup(self.skillDescTips, false, 0, 0)
		self.skillDescTips = nil
	end
end


function ListSkillPreview:InitEvent()
	self.list_skill.onClickItem:Add(self.OnSkillItemClick, self)
end

-- Register UI classes to lua
function ListSkillPreview:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("RoleCreateSelect","ListSkillPreview")
	self.sprite_skill_preview = self.ui:GetChild("sprite_skill_preview")
	self.list_skill = self.ui:GetChild("list_skill")
end

-- Combining existing UI generates a class
function ListSkillPreview.Create( ui, ...)
	return ListSkillPreview.New(ui, "#", {...})
end

function ListSkillPreview:SetUI(itemDataList)
	if itemDataList == nil then return end
	self.itemDataList = itemDataList or {}
	self.list_skill:RemoveChildrenToPool()
	for index = 1, #itemDataList do
		local curSkillId = itemDataList[index]
		local  iconId = LoginModel:GetInstance():GetSkillIconId(curSkillId)
		local item = self.list_skill:AddItemFromPool(self.skillItemURL)
		local curSkillItem = ButtonSkillItem.Create(item, iconId)
		curSkillItem:SetUI()
		table.insert(self.skillItemList, item)
	end

end

function ListSkillPreview:CleanSkillItemList()
	for index = 1, #self.skillItemList do
		self.skillItemList[index]:Destroy()
		self.skillItemList[index] = nil
	end
end

function ListSkillPreview:SetSkillDescTipsState(state)
	if self.skillDescTips ~= nil then
		self.skillDescTips:SetVisible(state)
	end
end

function ListSkillPreview:OnSkillItemClick(e)
	EffectMgr.PlaySound("731001")
	local curSkillId = self.itemDataList[self.list_skill.selectedIndex + 1] or -1
	local skillName = LoginModel:GetInstance():GetSkillName(curSkillId)
	local skillDesc = LoginModel:GetInstance():GetSkillDesc(curSkillId)

	self:OpenSkillDescTips(skillName, skillDesc)
end

function ListSkillPreview:CleanEvent()
	
end

-- Dispose use ListSkillPreview obj:Destroy()
function ListSkillPreview:__delete()
	self:CleanEvent()
	if self.skillDescTips ~= nil then
		self.skillDescTips:Destroy()
	end
	self.skillDescTips = nil
	self:CleanSkillItemList()
	self.sprite_skill_preview = nil
	self.list_skill = nil
end