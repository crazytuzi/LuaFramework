local CAttrRoleSkinView = class("CAttrRoleSkinView", CViewBase)

function CAttrRoleSkinView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Attr/AttrRoleSkinView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CAttrRoleSkinView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_SkinGrid = self:NewUI(3, CGrid)
	self.m_SkinBox = self:NewUI(4, CBox)
	self:InitContent()
end

function CAttrRoleSkinView.InitContent(self)
	self.m_SkinBox:SetActive(false)
	self:InitSkinGrid()
	self:CheckRedDot()
end

function CAttrRoleSkinView.CheckRedDot(self)
	local redDot = g_AttrCtrl:GetSkinRedDot()
	if redDot and #redDot > 0 then
		for i,v in ipairs(redDot) do
			local key = "roleskin".."_"..v
			local roleData = IOTools.SetRoleData(key, true)
			g_AttrCtrl:SetSkinRedDot(nil)
		end
	end
end

--~printc(g_AttrCtrl.model_info.shape, g_AttrCtrl.sex)
function CAttrRoleSkinView.InitSkinGrid(self)
	local dData = data.roleskindata.DATA
	local school = g_AttrCtrl.school
	local sex = g_AttrCtrl.sex
	local list = {}
	for k,v in pairs(dData) do
		if v.school == school and v.sex == sex then
			table.insert(list, v)
		end
	end
	table.sort(list, function (a, b)
		return a.shape < b.shape
	end)
	local skins = g_AttrCtrl:GetSkinList()
	for i,v in ipairs(list) do
		local oBox = self.m_SkinBox:Clone()
		oBox:SetActive(true)
		oBox.m_SkinTexture = oBox:NewUI(1, CTexture)
		oBox.m_SelectSpr = oBox:NewUI(3, CSprite)
		oBox.m_OperateBtn = oBox:NewUI(4, CButton)
		oBox.m_DescLabel = oBox:NewUI(5, CLabel)
		oBox:SetGroup(self.m_SkinGrid:GetInstanceID())
		oBox.m_Shape = v.shape
		if table.index(skins, v.shape) or v.shape == g_AttrCtrl.model_info.shape then
			oBox.m_Have = v.shape
		end
		if oBox.m_Have then
			oBox.m_OperateBtn:SetText("替换")
		else
			oBox.m_OperateBtn:SetText("获取")
		end
		oBox.m_SkinTexture:LoadCardPhoto(v.shape)
		oBox:SetSelected(v.shape == g_AttrCtrl.model_info.shape)
		oBox.m_DescLabel:SetText(v.name)
		oBox.m_SkinTexture:AddUIEvent("click", callback(self, "OnSkinTexture", oBox))
		oBox.m_OperateBtn:AddUIEvent("click", callback(self, "OnOperate", oBox))
		self.m_SkinGrid:AddChild(oBox)
	end
	self.m_SkinGrid:Reposition()
end

function CAttrRoleSkinView.OnOperate(self, oBox)
	--替换
	if oBox.m_Have then
		netplayer.C2GSChangeShape(oBox.m_Have)
	else
		--获取
		--g_NpcShopCtrl:OpenShop(define.Store.Page.PartnerSkin)
		g_OpenUICtrl:OpenTotalPay()
	end
	self:CloseView()
	CAttrMainView:CloseView()
end

function CAttrRoleSkinView.OnSkinTexture(self, oBox)
	oBox:SetSelected(true)
	g_WindowTipCtrl:SetWindowRoleSkinInfo(oBox.m_Shape, {widget = self})				
end

return CAttrRoleSkinView
