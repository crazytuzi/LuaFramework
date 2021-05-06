local CJoinOrgBox = class("COrgApplyBox", CBox)

function CJoinOrgBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self:InitContent()
end

function CJoinOrgBox.InitContent(self)
	-- self.m_FlagSprite = self:NewUI(1, CSprite)
	self.m_NameBtn = self:NewUI(2, CLabel)
	self.m_GradeLabel = self:NewUI(3, CLabel)
	self.m_MemberLabel = self:NewUI(4, CLabel)
	self.m_PresidentNameLabel = self:NewUI(5, CLabel)
	self.m_ApplyBtn = self:NewUI(6, CButton)
	self.m_FlagBgSprite = self:NewUI(7, CSprite)
	self.m_CantApplyBtn = self:NewUI(8, CButton)
	self.m_IDLabel = self:NewUI(9, CLabel)
	self.m_OnSelectSprite = self:NewUI(10, CSprite)
	self.m_SpreadMark = self:NewUI(11, CBox)

	-- self.m_NameBtn:AddUIEvent("click", callback(self, "OnClickName"))
	self.m_ApplyBtn:AddUIEvent("click", callback(self, "OnClickApply"))
	self.m_CantApplyBtn:AddUIEvent("click", callback(self, "OnClickApply"))
end

function CJoinOrgBox.OnClickName(self)
	self.m_ParentView:OnSelectInfoBox(self)
	g_OrgCtrl:GetOrgInfo(self.m_Data.info.orgid)
end

function CJoinOrgBox.OnClickApply(self)
	self.m_ParentView:OnSelectInfoBox(self)
	if self.m_CantApplyBtn:GetActive() and self.m_CantApplyBtn:GetText() == "已申请" then
		return
	end
	if self.m_Data.info.aim ~= nil and self.m_Data.info.aim ~= "" then
		self.m_ParentView.m_ApplyInfo:SetData(self.m_Data)
	else
		netorg.C2GSGetAim(self.m_Data.info.orgid)
	end
end

function CJoinOrgBox.SetParentView(self, parentView)
	self.m_ParentView = parentView
end

function CJoinOrgBox.SetSelect(self, status)
	self.m_OnSelectSprite:SetActive(status)
end

function CJoinOrgBox.SetData(self, oData)
	self.m_Data = oData
	-- self.m_FlagSprite:SetSpriteName(g_OrgCtrl:GetFlagIcon(oData.info.flagid))
	-- self.m_FlagBgSprite:SetSpriteName(g_OrgCtrl:GetFlagIcon(oData.info.flagbgid))
	self.m_NameBtn:SetText(oData.info.name)
	self.m_GradeLabel:SetText(oData.info.level)
	self.m_MemberLabel:SetText(string.format("%d/%d", oData.info.memcnt, g_OrgCtrl:GetMaxMember(oData.info.level)))
	self.m_PresidentNameLabel:SetText(oData.info.leadername)
	self.m_IDLabel:SetText(oData.info.orgid)
	self.m_SpreadMark:SetActive(g_TimeCtrl:GetTimeS() < oData.info.spread_endtime)
	if oData.needallow == COrgCtrl.Need_Allow then
		self.m_ApplyBtn:SetText("申请")
		self.m_CantApplyBtn:SetText("申请")
	else
		self.m_ApplyBtn:SetText("加入")
		self.m_CantApplyBtn:SetText("加入")
	end
	if oData.hasapply ~= COrgCtrl.HAS_APPLY_ORG then
		if oData.powerlimit > g_AttrCtrl.power then
			self.m_ApplyBtn:SetActive(false)
			self.m_CantApplyBtn:SetActive(true)
		else
			self.m_ApplyBtn:SetActive(true)
			self.m_CantApplyBtn:SetActive(false)
		end
	else
		self.m_ApplyBtn:SetActive(false)
		self.m_CantApplyBtn:SetActive(true)
		self.m_CantApplyBtn:SetText("已申请")
	end
end

return CJoinOrgBox