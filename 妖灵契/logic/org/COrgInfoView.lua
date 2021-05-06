local COrgInfoView = class("COrgInfoView", CViewBase)

function COrgInfoView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Org/OrgInfoView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function COrgInfoView.OnCreateView(self)
	--tzq弃用
	self:SetActive(false)
	-- self.m_CloseBtn = self:NewUI(1, CButton)
	-- self.m_InfoGrid = self:NewUI(2, CGrid)
	-- self.m_InfoBox = self:NewUI(3, COrgInfoBox)
	-- self.m_ApplyBtn = self:NewUI(4, CButton)
	-- self.m_OrgInfoPart = self:NewUI(5, COrgInfoPart)
	-- self:InitContent()
end

function COrgInfoView.InitContent(self)
	self.m_InfoBoxArr = {}
	self.m_InfoBoxArr[1] = self.m_InfoBox
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ApplyBtn:AddUIEvent("click", callback(self, "OnClickApply"))
end

function COrgInfoView.SetData(self, oData, meminfo)
	self.m_Data = oData
	self.m_OrgInfoPart:SetData(oData.info)
	if oData.hasapply == COrgCtrl.HAS_APPLY_ORG or oData.info.memcnt >= g_OrgCtrl:GetMaxMember(oData.info.level) or oData.powerlimit > g_AttrCtrl.power then
		self.m_ApplyBtn:SetActive(false)
	end
	local count = 0
	for k,v in pairs(meminfo) do
		count = count + 1
		if self.m_InfoBoxArr[count] == nil then
			self.m_InfoBoxArr[count] = self.m_InfoBox:Clone()
			self.m_InfoGrid:AddChild(self.m_InfoBoxArr[count])
		end
		self.m_InfoBoxArr[count]:SetData(v)
		self.m_InfoBoxArr[count]:SetActive(true)
	end
	count = count + 1
	for i = count, #self.m_InfoBoxArr do
		self.m_InfoBoxArr[i]:SetActive(false)
	end
end

function COrgInfoView.OnClickApply(self)
	g_OrgCtrl:ApplyJoinOrg(self.m_Data.info.orgid)
end

return COrgInfoView