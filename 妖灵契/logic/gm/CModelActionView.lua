local CModelActionView = class("CModelActionView", CViewBase)

function CModelActionView.ctor(self, cb)
	CViewBase.ctor(self, "UI/GM/ModelActionView.prefab", cb)
end

function CModelActionView.OnCreateView(self)
	self.m_AttackBtn = self:NewUI(2, CButton)
	self.m_AttackBtn:SetActive(false)
	self.m_Input = self:NewUI(3, CInput)
	self.m_ConfirmBtn = self:NewUI(4, CButton)
	self.m_CloseBtn = self:NewUI(5, CButton)
	self.m_Grid = self:NewUI(6, CGrid)
	self.m_Container = self:NewUI(7, CWidget)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "ChangeShape"))
	self.m_Input:SetPermittedChars("0", "9")
	self:InitActionBtn(g_AttrCtrl.model_info.shape)

	CGmView:CloseView()
end

function CModelActionView.InitActionBtn(self, shape)
	local fileTable = IOTools.GetFiles(IOTools.GetGameResPath("/Model/Character/130/Anim/"), "*.anim",false)
	local actionTable = {}
	for k,v in ipairs(fileTable) do
		local _, _, action = string.find(v, "/(%w+).anim")
		if action then
			table.insert(actionTable, action)
		end
	end

	self.m_Grid:Clear()
	for k, v in ipairs(actionTable) do
		local oBtn = self.m_AttackBtn:Clone(false)
		oBtn:SetActive(true)
		oBtn:SetText(v)
		oBtn:AddUIEvent("click", callback(self, "SetAction", v))
		self.m_Grid:AddChild(oBtn)
	end
end

function CModelActionView.SetAction(self, action)
	local oHero = g_MapCtrl:GetHero()
	oHero:CrossFade(action, 0.1)
end

function CModelActionView.ChangeShape(self)
	local shape = tonumber(self.m_Input:GetText())
	local oHero = g_MapCtrl:GetHero()
	if shape then
		oHero:ChangeShape(shape)
		self:InitActionBtn(shape)
	end
end

return CModelActionView