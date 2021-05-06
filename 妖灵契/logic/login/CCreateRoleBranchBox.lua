local CCreateRoleBranchBox = class("CCreateRoleBranchBox", CBox)

function CCreateRoleBranchBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Btn = self:NewUI(1, CSprite)
	self.m_WeaponSprite = self:NewUI(2, CSprite)
	self.m_BranchTextSprite = self:NewUI(3, CSprite)
	self.m_DescTextSprite = self:NewUI(4, CSprite)
	self.m_LockSprite = self:NewUI(5, CBox)
	self.m_Panel = self:NewUI(6, CPanel)
	self.m_Btn:AddUIEvent("click", callback(self, "OnChooseBranch"))
	self.m_ClickCB = nil
	self.m_HideAlpha = 0.5
end

function CCreateRoleBranchBox.OnChooseBranch(self)
	-- g_CreateRoleCtrl:SetCreateData("branch", self.m_Branch)
	if self.m_ClickCB then
		self.m_ClickCB(self)
	end
end

function CCreateRoleBranchBox.SetInitData(self, iSchool, dData, cb)
	self.m_School = iSchool
	self.m_Branch = dData.branch
	self.m_ClickCB = cb
	self.m_WeaponSprite:SetSpriteName(string.format("pic_wuqi_%s_%s_1", self.m_School, self.m_Branch))
	self.m_BranchTextSprite:SetSpriteName(string.format("text_school_%s_%s", self.m_School, self.m_Branch))
	self.m_DescTextSprite:SetSpriteName(string.format("text_desc_%s_%s", self.m_School, self.m_Branch))
	if dData.create == 1 then
		-- self.m_WeaponSprite:SetGrey(false)
		-- self.m_LockLabel:SetText("")
		self.m_LockSprite:SetActive(false)
	else
		-- self.m_WeaponSprite:SetGrey(true)
		self.m_LockSprite:SetActive(true)
		-- self.m_LockLabel:SetText(string.format("%d级开启#n", data.globalcontroldata.GLOBAL_CONTROL.switchschool.open_grade))
	end
end

function CCreateRoleBranchBox.SetSelect(self, bValue)
	if bValue then
		self.m_BranchTextSprite:SetAlpha(1)
		self.m_DescTextSprite:SetAlpha(1)
		self.m_LockSprite:SetAlpha(1)
		self.m_Btn:SetAlpha(1)
		self.m_WeaponSprite:SetSpriteName(string.format("pic_wuqi_%s_%s_1", self.m_School, self.m_Branch))
	else
		self.m_BranchTextSprite:SetAlpha(self.m_HideAlpha)
		self.m_DescTextSprite:SetAlpha(self.m_HideAlpha)
		self.m_LockSprite:SetAlpha(self.m_HideAlpha)
		self.m_Btn:SetAlpha(self.m_HideAlpha)
		self.m_WeaponSprite:SetSpriteName(string.format("pic_wuqi_%s_%s_2", self.m_School, self.m_Branch))
	end
end

return CCreateRoleBranchBox