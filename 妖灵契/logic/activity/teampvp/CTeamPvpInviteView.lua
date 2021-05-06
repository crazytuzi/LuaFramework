local CTeamPvpInviteView = class("CTeamPvpInviteView", CViewBase)

function CTeamPvpInviteView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/TeamPvp/TeamPvpInviteView.prefab", cb)

	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CTeamPvpInviteView.OnCreateView(self)
	self.m_InviteBtn = self:NewUI(1, CButton)
	self.m_InviteGrid = self:NewUI(2, CGrid)
	self.m_InviteBox = self:NewUI(3, CBox)
	self.m_RefreshBtn = self:NewUI(4, CButton)
	self.m_CancelBtn = self:NewUI(5, CButton)
	self:InitContent()
end

function CTeamPvpInviteView.InitContent(self)
	self.m_InviteBoxArr = {}
	self.m_InviteBtn:AddUIEvent("click", callback(self, "OnClickInvite"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_RefreshBtn:AddUIEvent("click", callback(self, "OnRefreshBtn"))
	self:Refresh()
end

function CTeamPvpInviteView.Refresh(self)
	self.m_SelectedDic = {}
	self.m_InviteBox:SetActive(false)
	local inviteData = g_TeamPvpCtrl:GetInviteData()

	for i,v in ipairs(inviteData) do
		if self.m_InviteBoxArr[i] == nil then
			self.m_InviteBoxArr[i] = self:CreateInviteBox()
			self.m_InviteGrid:AddChild(self.m_InviteBoxArr[i])
		end
		self.m_InviteBoxArr[i]:SetData(v)
		self.m_InviteBoxArr[i]:SetActive(true)
	end
	for i = #inviteData + 1, #self.m_InviteBoxArr do
		self.m_InviteBoxArr[i]:SetActive(false)
	end
end

function CTeamPvpInviteView.CreateInviteBox(self)
	local oInviteBox = self.m_InviteBox:Clone()
	oInviteBox.m_AvatarSprite = oInviteBox:NewUI(1, CSprite)
	oInviteBox.m_NameLabel = oInviteBox:NewUI(2, CLabel)
	oInviteBox.m_GradeLabel = oInviteBox:NewUI(3, CLabel)
	oInviteBox.m_InviteMark = oInviteBox:NewUI(4, CSprite)
	oInviteBox.m_PointLabel = oInviteBox:NewUI(5, CLabel)
	oInviteBox.m_IdentityMark = oInviteBox:NewUI(6, CSprite)

	oInviteBox:AddUIEvent("click", callback(self, "OnSelect", oInviteBox))

	function oInviteBox.SetData(self, oData)
		oInviteBox.m_Data = oData
		oInviteBox.m_AvatarSprite:SpriteAvatar(oData.info.shape)
		oInviteBox.m_GradeLabel:SetText(oData.info.grade)
		oInviteBox.m_NameLabel:SetText(oData.info.name)
		oInviteBox.m_PointLabel:SetText(string.format("积分：%s", oData.info.score))
		oInviteBox.m_InviteMark:SetActive(false)
		oInviteBox.m_IdentityMark:SetActive(true)
		if g_FriendCtrl:IsMyFriend(oData.info.pid) then
			oInviteBox.m_IdentityMark:SetSpriteName("text_wodehaoyou")
		elseif g_OrgCtrl:HasOrg() and oData.org == g_AttrCtrl.org_id then
			oInviteBox.m_IdentityMark:SetSpriteName("text_gonghuichengyuan")
		elseif oData.fight == 1 then
			oInviteBox.m_IdentityMark:SetSpriteName("text_jinqizhanyou")
		else
			oInviteBox.m_IdentityMark:SetActive(false)
			-- oInviteBox.m_IdentityMark:SetSpriteName("")
		end
		oInviteBox.m_IdentityMark:MakePixelPerfect()
	end

	return oInviteBox
end

function CTeamPvpInviteView.OnSelect(self, oInviteBox)
	if self.m_SelectedDic[oInviteBox.m_Data.info.pid] then
		oInviteBox.m_InviteMark:SetActive(false)
		self.m_SelectedDic[oInviteBox.m_Data.info.pid] = nil
	else
		oInviteBox.m_InviteMark:SetActive(true)
		self.m_SelectedDic[oInviteBox.m_Data.info.pid] = true
	end
end

function CTeamPvpInviteView.OnClickInvite(self)
	local inviteList = {}
	for k,v in pairs(self.m_SelectedDic) do
		table.insert(inviteList, k)
	end
	if #inviteList > 0 then
		g_TeamPvpCtrl:SendInvite(inviteList)
		self:OnClose()
	else
		g_NotifyCtrl:FloatMsg("请选择想要邀请的玩家")
	end
end

function CTeamPvpInviteView.OnRefreshBtn(self)
	g_TeamPvpCtrl:GetInviteList()
end

return CTeamPvpInviteView