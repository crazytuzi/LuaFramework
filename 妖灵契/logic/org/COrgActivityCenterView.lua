local COrgActivityCenterView = class("COrgActivityCenterView", CViewBase)

COrgActivityCenterView.TAGS = {
	FUBEN = 1,
	TERRAWAR = 2,
	ORGWAR = 3,
}

function COrgActivityCenterView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Org/OrgActivityCenterView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function COrgActivityCenterView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TagGrid = self:NewUI(2, CGrid)
	self.m_TagBtn = self:NewUI(3, CBox)
	self.m_CapitalLabel = self:NewUI(4, CLabel)
	self.m_OrgFuBenPage = self:NewPage(5, COrgFuBenPage)
	self.m_TerraWarOrgPage = self:NewPage(6, CTerraWarOrgPage)
	self.m_XiaoRenTexture = self:NewUI(7, CSpineTexture)
	self.m_OrgWarPage = self:NewPage(8, COrgWarPage)

	self.m_Tags = {
		[COrgActivityCenterView.TAGS.FUBEN] = {
			id = COrgActivityCenterView.TAGS.FUBEN,
			name = "赏\n金",
			grade = 0,
			open = true,
		},
		[COrgActivityCenterView.TAGS.TERRAWAR] = {
			id = COrgActivityCenterView.TAGS.TERRAWAR,
			name = "据\n点\n战",
			grade = data.globalcontroldata.GLOBAL_CONTROL.terrawars.open_grade,
			open = true,
		},
		[COrgActivityCenterView.TAGS.ORGWAR] = {
			id = COrgActivityCenterView.TAGS.ORGWAR,
			name = "公\n会\n战",
			grade = 0,
			open = true,
		},
	}

	self:InitContent()
end

function COrgActivityCenterView.InitContent(self)
	self.m_XiaoRenTexture:SetActive(false)
	self.m_XiaoRenTexture:ShapeOrg("XiaoRen", objcall(self, function(obj)
		obj.m_XiaoRenTexture:SetActive(true)
		obj.m_XiaoRenTexture:SetAnimation(0, "idle_1", false)
	end))
	self.m_TagBtn:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

	local orginfo = g_OrgCtrl:GetMyOrgInfo()
	self.m_CapitalLabel:SetText(orginfo.cash)
	self:InitTagGrid()
end

function COrgActivityCenterView.InitTagGrid(self)
	local grade = g_AttrCtrl.grade
	for i,v in ipairs(self.m_Tags) do
		if grade >= v.grade then
			local tagBtn = self.m_TagBtn:Clone()
			tagBtn:SetActive(true)
			tagBtn.m_TagId = v.id
			tagBtn.m_Open = v.open
			tagBtn.m_Label1 = tagBtn:NewUI(1, CLabel)
			tagBtn.m_Label2 = tagBtn:NewUI(2, CLabel)
			tagBtn.m_Label1:SetText(v.name)
			tagBtn.m_Label2:SetText(v.name)
			tagBtn:SetGroup(self.m_TagGrid:GetInstanceID())
			tagBtn:SetSelected(false)
			tagBtn:SetClickSounPath(define.Audio.SoundPath.Tab)
			tagBtn:AddUIEvent("click", callback(self, "OnClickTagBtn", tagBtn))
			self.m_TagGrid:AddChild(tagBtn)
		end
	end
	self.m_TagGrid:Reposition()
	self:DefaultTag()
end

function COrgActivityCenterView.DefaultTag(self)
	local oDefault = self.m_TagGrid:GetChild(1)
	if oDefault then
		self:OnClickTagBtn(oDefault)
	end
end

function COrgActivityCenterView.OnClickTagBtn(self, tagBtn)
	if not tagBtn.m_Open then
		g_NotifyCtrl:FloatMsg("活动未开启")
		return	
	end
	if self:SelectTag(tagBtn.m_TagId) then
		tagBtn:SetSelected(true)
	end
end

function COrgActivityCenterView.SelectTag(self, tagId)
	self.m_CurTagId = tagId
	if tagId == COrgActivityCenterView.TAGS.FUBEN then
		self:ShowSubPage(self.m_OrgFuBenPage)
		return true
	elseif tagId == COrgActivityCenterView.TAGS.TERRAWAR then
		self:ShowSubPage(self.m_TerraWarOrgPage)
		return true
		elseif tagId == COrgActivityCenterView.TAGS.ORGWAR then
		self:ShowSubPage(self.m_OrgWarPage)
		return true
	end
end

function COrgActivityCenterView.CloseView(self)
	CViewBase.CloseView(self)
end

return COrgActivityCenterView