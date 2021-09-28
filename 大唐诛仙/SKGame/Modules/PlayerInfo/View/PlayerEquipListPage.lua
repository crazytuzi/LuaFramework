PlayerEquipListPage =BaseClass(LuaUI)
function PlayerEquipListPage:__init( ... )
	self.URL = "ui://0oudtuxpe0wd42";
	self:__property(...)
	self:Config()
end

function PlayerEquipListPage:SetProperty( ... )
end

function PlayerEquipListPage:Config()
	self.model = PlayerInfoModel:GetInstance()
end

function PlayerEquipListPage:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("PlayerInfo","PlayerEquipListPage");

	self.state = self.ui:GetController("state")
	self.page = self.ui:GetChild("page")

	self.page = PlayerEquipSkepList.Create(self.page, self)

	self.page.closeBtn.onClick:Add(self.OnCloseBtnClick, self)
	self.state.selectedIndex = 1
	self:SetEnabled(false)
end

function PlayerEquipListPage:AddEvents()
	self.handler = self.model:AddEventListener(PlayerInfoConst.EventName_ReFreshPlayerSkepEquipList, function ()
		if not self.pos then return end
		local list = PkgModel:GetInstance():GetRoleEquipByType(self.pos, true)
		self:Refresh(list)
	end)
end

function PlayerEquipListPage:RemoveEvents()
	self.model:RemoveEventListener(self.handler)
	self.handler = nil
end

function PlayerEquipListPage:OnCloseBtnClick()
	self:Hide()
end

function PlayerEquipListPage.Create( ui, ...)
	return PlayerEquipListPage.New(ui, "#", {...})
end

function PlayerEquipListPage:Show(pos, list, isChange)
	self.pos = pos
	self.page:Show(list, isChange)
	self.state.selectedIndex = 0
	self:SetEnabled(true)
	self:AddEvents()
end

function PlayerEquipListPage:Update(isChange)
	if not self.pos then return end
	local list = PkgModel:GetInstance():GetRoleEquipByType(self.pos, true)
	if list and #list > 0 then
		self:Show(self.pos, list, isChange)
	else
		self:Hide()
	end
end

function PlayerEquipListPage:Hide()
	self.pos = nil
	self:RemoveEvents()
	self.page:Hide()
	self.state.selectedIndex = 1
	self:SetEnabled(false)
end

function PlayerEquipListPage:__delete()
	self.pos = nil
	self:RemoveEvents()
	self.page:Destroy()
	self.ZhuangTai = nil
	self.page = nil
end