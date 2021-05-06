local CExpandTeamPvpPage = class("CExpandTeamPvpPage", CPageBase)

function CExpandTeamPvpPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CExpandTeamPvpPage.OnInitPage(self)
	self.m_PlayerBoxGrid = self:NewUI(1, CGrid)
	self.m_InviteBtn = self:NewUI(2, CButton)
	self.m_OwnHandleGroup = self:NewUI(3, CBox)
	self.m_LeaderHandleGroup = self:NewUI(4, CBox)
	self:InitContent()
end

function CExpandTeamPvpPage.InitContent(self)
	self:InitOwnHandleGroup()
	self:InitLeaderHandleGroup()
	self.m_PlayerBoxArr = {}
	self.m_PlayerBoxGrid:InitChild(function (obj, idx)
		self.m_PlayerBoxArr[idx] = self:CreatePlayerBox(obj, idx)
		return self.m_PlayerBoxArr[idx]
	end)
	self.m_OwnHandleGroup:SetActive(false)
	self.m_LeaderHandleGroup:SetActive(false)
	self.m_InviteBtn:AddUIEvent("click", callback(self, "OnClickInvite"))
	g_TeamPvpCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTeamPvpEvent"))
	self:SetData()
end

function CExpandTeamPvpPage.OnShowPage(self)
	self:SetData()
end

function CExpandTeamPvpPage.InitOwnHandleGroup(self)
	self.m_OwnHandleGroup.m_LeaveBtn = self.m_OwnHandleGroup:NewUI(1, CButton)
	self.m_OwnHandleGroup.m_LeaveBtn:AddUIEvent("click", callback(self, "LeaveTeam"))
	g_UITouchCtrl:TouchOutDetect(self.m_OwnHandleGroup, function(obj)
		self.m_OwnHandleGroup:SetActive(false)
	end)
end

function CExpandTeamPvpPage.InitLeaderHandleGroup(self)
	self.m_LeaderHandleGroup.m_AppointBtn = self.m_LeaderHandleGroup:NewUI(1, CButton)
	self.m_LeaderHandleGroup.m_KickOutBtn = self.m_LeaderHandleGroup:NewUI(2, CButton)
	self.m_LeaderHandleGroup.m_AppointBtn:AddUIEvent("click", callback(self, "Appoint"))
	self.m_LeaderHandleGroup.m_KickOutBtn:AddUIEvent("click", callback(self, "KickOut"))
	g_UITouchCtrl:TouchOutDetect(self.m_LeaderHandleGroup, function(obj)
		self.m_LeaderHandleGroup:SetActive(false)
	end)
end

function CExpandTeamPvpPage.KickOut(self)
	if g_TeamPvpCtrl.m_IsMatching then
		g_NotifyCtrl:FloatMsg("请先停止匹配")
		return
	end
	-- printc("KickOut: " .. self.m_CurrentBox.m_Data.pid)
	netarena.C2GSTeamPVPKickout(self.m_CurrentBox.m_Data.pid)
	self.m_LeaderHandleGroup:SetActive(false)
end

function CExpandTeamPvpPage.LeaveTeam(self)
	if g_TeamPvpCtrl.m_IsMatching then
		g_NotifyCtrl:FloatMsg("请先停止匹配")
		return
	end
	-- printc("LeaveTeam")
	netarena.C2GSTeamPVPLeave()
	self.m_OwnHandleGroup:SetActive(false)
end

function CExpandTeamPvpPage.Appoint(self)
	if g_TeamPvpCtrl.m_IsMatching then
		g_NotifyCtrl:FloatMsg("请先停止匹配")
		return
	end
	-- printc("Appoint: " .. self.m_CurrentBox.m_Data.pid)
	netarena.C2GSTeamPVPLeader(self.m_CurrentBox.m_Data.pid)
	self.m_LeaderHandleGroup:SetActive(false)
end

function CExpandTeamPvpPage.SetData(self)
	local oData = g_TeamPvpCtrl:GetTeamData()
	for i,v in ipairs(self.m_PlayerBoxArr) do
		self:SetPlayerBoxData(v, oData[i])
	end
	self.m_InviteBtn:SetActive(#oData <= 1)
	-- self.m_LeaveBtn:SetActive(#oData <= 1)
end

function CExpandTeamPvpPage.OnClickInvite(self)
	g_TeamPvpCtrl:GetInviteList()
end

function CExpandTeamPvpPage.CreatePlayerBox(self, obj, idx)
	local oPlayerBox = CBox.New(obj)
	oPlayerBox.m_AvatarSprite = oPlayerBox:NewUI(1, CSprite)
	oPlayerBox.m_GradeLabel = oPlayerBox:NewUI(2, CLabel)
	oPlayerBox.m_NameLabel = oPlayerBox:NewUI(3, CLabel)
	oPlayerBox.m_PointLabel = oPlayerBox:NewUI(4, CLabel)
	oPlayerBox.m_PartnerGrid = oPlayerBox:NewUI(5, CGrid)
	oPlayerBox:AddUIEvent("click", callback(self, "OnClickPlayerBox", oPlayerBox))
	oPlayerBox.m_PartnerBoxArr = {}
	oPlayerBox.m_PartnerGrid:Clear()
	oPlayerBox.m_PartnerGrid:InitChild(function (obj, idx)
		oPlayerBox.m_PartnerBoxArr[idx] = self:CreatePartnerBox(obj)
		return oPlayerBox.m_PartnerBoxArr[idx]
	end)
	return oPlayerBox
end

function CExpandTeamPvpPage.OnClickPlayerBox(self, oPlayerBox)
	self.m_CurrentBox = oPlayerBox
	if self.m_InviteBtn:GetActive() then
		return
	end
	if oPlayerBox.m_Data.pid == g_AttrCtrl.pid then
		--点击自己
		self.m_OwnHandleGroup:SetActive(true)
		UITools.NearTarget(oPlayerBox, self.m_OwnHandleGroup, enum.UIAnchor.Side.Right)
	elseif oPlayerBox.m_Data.leader == 0 then
		--自己是队长，选择队员
		self.m_LeaderHandleGroup:SetActive(true)
		UITools.NearTarget(oPlayerBox, self.m_LeaderHandleGroup, enum.UIAnchor.Side.Right)
	end
end

function CExpandTeamPvpPage.SetPlayerBoxData(self, oPlayerBox, oData)
	if oData then
		oPlayerBox.m_Data = oData
		oPlayerBox:SetActive(true)
		oPlayerBox.m_AvatarSprite:SpriteAvatar(oData.shape)
		oPlayerBox.m_GradeLabel:SetText(oData.grade)
		oPlayerBox.m_NameLabel:SetText(oData.name)
		oPlayerBox.m_PointLabel:SetText(oData.score)
		for i,v in ipairs(oPlayerBox.m_PartnerBoxArr) do
			self:SetParterBoxData(v, oData.partner[i])
		end
	else
		oPlayerBox:SetActive(false)
	end
end

function CExpandTeamPvpPage.CreatePartnerBox(self, obj, idx)
	local oPartnerBox = CBox.New(obj)
	oPartnerBox.m_RareBg = oPartnerBox:NewUI(1, CSprite)
	oPartnerBox.m_ShapeSprite = oPartnerBox:NewUI(2, CSprite)
	oPartnerBox.m_StarGrid = oPartnerBox:NewUI(3, CGrid)
	oPartnerBox.m_GradeLabel = oPartnerBox:NewUI(4, CLabel)
	oPartnerBox.m_StarBoxArr = {}
	oPartnerBox.m_StarGrid:Clear()
	oPartnerBox.m_StarGrid:InitChild(function (starBox, idx)
		local oStarBox = CBox.New(starBox)
		oStarBox.m_BgSprite = oStarBox:NewUI(1, CSprite)
		oStarBox.m_StarSprite = oStarBox:NewUI(2, CSprite)
		oStarBox.m_StarSprite:SetActive(false)
		oPartnerBox.m_StarBoxArr[idx] = oStarBox
		return oStarBox
	end)
	return oPartnerBox
end

function CExpandTeamPvpPage.SetParterBoxData(self, oPartnerBox, oData)
	if oData then
		oPartnerBox:SetActive(true)
		local partnerData = data.partnerdata.DATA[oData.partner_type]
		g_PartnerCtrl:ChangeRareBorder(oPartnerBox.m_RareBg, partnerData.rare)
		oPartnerBox.m_ShapeSprite:SpriteAvatar(oData.model_info.shape)
		for i,v in ipairs(oPartnerBox.m_StarBoxArr) do
			v.m_StarSprite:SetActive(i <= oData.star)
		end
		oPartnerBox.m_GradeLabel:SetText(oData.grade)
	else
		oPartnerBox:SetActive(false)
	end
end

function CExpandTeamPvpPage.OnTeamPvpEvent(self, oCtrl)
	if oCtrl.m_EventID == define.TeamPvp.Event.UpdataTeamData then
		self:SetData()
	end
end

return CExpandTeamPvpPage