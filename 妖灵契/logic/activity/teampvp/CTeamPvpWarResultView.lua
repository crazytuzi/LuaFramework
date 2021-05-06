local CTeamPvpWarResultView = class("CTeamPvpWarResultView", CViewBase)

function CTeamPvpWarResultView.ctor(self, ob)
	CViewBase.ctor(self, "UI/Activity/TeamPvp/TeamPvpWarResultView.prefab", ob)
	self.m_ExtendClose = "Black"
end

function CTeamPvpWarResultView.OnCreateView(self)
	self.m_PointLabel = self:NewUI(1, CLabel)
	self.m_WinMark = self:NewUI(2, CTexture)
	self.m_LoseMark = self:NewUI(3, CTexture)
	self.m_RightInfoBox = self:NewUI(4, CBox)
	self.m_LeftInfoBox = self:NewUI(5, CBox)
	self.m_ScorePart = self:NewUI(6, CBox)
	self:InitContent()
end
function CTeamPvpWarResultView.InitContent(self)
	self:InitInfoBox(self.m_LeftInfoBox)
	self:InitInfoBox(self.m_RightInfoBox)
	g_TeamPvpCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
	self:SetData()
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWarEvnet"))
	netopenui.C2GSOpenInterface(define.OpenInterfaceType.WarResult)
end

function CTeamPvpWarResultView.InitInfoBox(self, oInfoBox)
	oInfoBox.m_WinBg = oInfoBox:NewUI(1, CTexture)
	oInfoBox.m_LeaderBox = oInfoBox:NewUI(2, CBox)
	oInfoBox.m_LoseBg = oInfoBox:NewUI(3, CTexture)
	oInfoBox.m_MemberBox = oInfoBox:NewUI(4, CBox)
	oInfoBox.m_MemberBoxArr = {self:CreateMemberBox(oInfoBox.m_LeaderBox), self:CreateMemberBox(oInfoBox.m_MemberBox)}

	function oInfoBox.SetData(self, oData, isWinner)
		for i,memberData in ipairs(oData) do
			oInfoBox.m_MemberBoxArr[i]:SetData(memberData, isWinner)
		end
		oInfoBox.m_WinBg:SetActive(isWinner)
		oInfoBox.m_LoseBg:SetActive(not isWinner)
	end
	return oInfoBox
end

function CTeamPvpWarResultView.CreateMemberBox(self, oMemberBox)
	oMemberBox.m_Texture = oMemberBox:NewUI(1, CTexture)
	oMemberBox.m_NameLabel = oMemberBox:NewUI(2, CLabel)
	oMemberBox.m_LoseNameLabel = oMemberBox:NewUI(3, CLabel)
	oMemberBox.m_ParnetView = self
	function oMemberBox.SetData(self, oData, isWinner)
		if oData then
			oMemberBox.m_Texture:SetGrey(not isWinner)
			oMemberBox:SetActive(true)
			oMemberBox.m_ParnetView:SetTexture(oMemberBox.m_Texture, oData.shape)
			oMemberBox.m_NameLabel:SetText(oData.name)
			oMemberBox.m_LoseNameLabel:SetText(oData.name)
		else
			oMemberBox:SetActive(false)
		end
	end
	return oMemberBox
end

function CTeamPvpWarResultView.OnShowView(self)
	if g_TeamPvpCtrl.m_Result == define.TeamPvp.WarResult.NotReceive then
		self:SetActive(false)
	end
end

function CTeamPvpWarResultView.SetData(self)
	self.m_IsPlayRecord = g_TeamPvpCtrl.m_ViewSide ~= 0
	self.m_ScorePart:SetActive(not self.m_IsPlayRecord)
	local isWinner = false
	-- local strTemp = "[FFFAAF]积分%d[ff311c](-%d)[-]"
	local strTemp = "[FFFAAF]积分%d[ff311c](-%d)[-]"
	if g_TeamPvpCtrl.m_Result == define.TeamPvp.WarResult.NotReceive then
		self:SetActive(false)
		return
	elseif g_TeamPvpCtrl.m_Result == define.TeamPvp.WarResult.Win then
		isWinner = true
		strTemp = "[FFFAAF]积分%d[00cc00](+%d)[-]"
	else
	end
	self.m_WinMark:SetActive(isWinner)
	self.m_LoseMark:SetActive(not isWinner)
	if g_TeamPvpCtrl.m_ResultPoint == 0 then
		self.m_PointLabel:SetText(string.format("[FFFAAF]积分%d[00cc00](+0)[-]", g_TeamPvpCtrl.m_ArenaPoint))
	else
		self.m_PointLabel:SetText(string.format(strTemp, g_TeamPvpCtrl.m_ArenaPoint, g_TeamPvpCtrl.m_ResultPoint))
	end
	self.m_LoadCount = 0
	self.m_LeftInfoBox:SetData(g_TeamPvpCtrl:GetOwnResultInfo(), isWinner)
	self.m_RightInfoBox:SetData(g_TeamPvpCtrl:GetOtherResultInfo(), false)
end

function CTeamPvpWarResultView.SetTexture(self, oTexture, shape)
	oTexture:LoadArenaPhoto(shape, callback(self, "AfterLoadPhoto"))
end

function CTeamPvpWarResultView.AfterLoadPhoto(self)
	self.m_LoadCount = self.m_LoadCount + 1
	if self.m_LoadCount >= 4 then
		self:SetActive(true)
	end
end

function CTeamPvpWarResultView.Destroy(self)
	g_ViewCtrl:CloseInterface(define.OpenInterfaceType.WarResult)
	CViewBase.Destroy(self)
end

function CTeamPvpWarResultView.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.TeamPvp.Event.OnWarEnd then
		self:SetData()
	end
end

function CTeamPvpWarResultView.CloseView(self)
	g_WarCtrl:SetInResult(false)
end

function CTeamPvpWarResultView.OnWarEvnet(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.EndWar then
		CViewBase.CloseView(self)
	end
end

return CTeamPvpWarResultView
