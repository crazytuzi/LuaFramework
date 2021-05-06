local CAttrMainView = class("CAttrMainView", CViewBase)

function CAttrMainView.ctor(self, cb)
	if g_AttrCtrl.m_AttrMainLayer then
		CViewBase.ctor(self, "UI/Attr/AttrMainSecondView.prefab", cb)
	else
		CViewBase.ctor(self, "UI/Attr/AttrMainView.prefab", cb)
	end	
	--self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
end

function CAttrMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_BtnGrid = self:NewUI(2, CTabGrid)
	self.m_Container = self:NewUI(3, CBox)
	self.m_AttrMainPage = self:NewPage(4, CAttrMainPage)
	-- self.m_AttrPointPage = self:NewPage(5, CAttrPointPage)

	self:InitContent()
end

function CAttrMainView.InitContent(self)
	--UITools.ResizeToRootSize(self.m_Container)
	self.m_BtnGrid:InitChild(function(obj, idx)
		local oBtn = CButton.New(obj, false)
		oBtn:SetGroup(self:GetInstanceID())
		return oBtn
	end)
	-- self.m_AttrBtn = self.m_BtnGrid:GetChild(1):SetActive(false)
	-- self.m_PointBtn = self.m_BtnGrid:GetChild(2):SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	--self.m_AttrBtn:AddUIEvent("click", callback(self, "ShowAttrPage"))
	--self.m_PointBtn:AddUIEvent("click", callback(self, "ShowPointPage"))

	self:ShowAttrPage()

	local showPoint = g_AttrCtrl.grade >= 50
	--self.m_PointBtn:SetActive(showPoint)
end

function CAttrMainView.ShowAttrPage(self)
	--self.m_TitleLabel:SetText("人物属性")
	--self.m_BtnGrid:SetTabSelect(self.m_AttrBtn)
	self:ShowSubPage(self.m_AttrMainPage)
end

function CAttrMainView.ShowPointPage(self)
	self.m_TitleLabel:SetText("加 点")
	self.m_BtnGrid:SetTabSelect(self.m_PointBtn)
	-- self:ShowSubPage(self.m_AttrPointPage)
end


return CAttrMainView
