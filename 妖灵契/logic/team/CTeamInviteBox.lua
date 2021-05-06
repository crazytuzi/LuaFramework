local CTeamInviteBox = class("CTeamInviteBox", CBox)

function CTeamInviteBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_TargetLabel = self:NewUI(1, CLabel)
	self.m_MemberGrid = self:NewUI(2, CGrid)
	self.m_AgreeBtn = self:NewUI(3, CButton)
	self.m_TeamID = nil
	self:InitContent()
end

function CTeamInviteBox.InitContent(self)
	self.m_AgreeBtn:AddUIEvent("click", callback(self, "OnAgree"))
	local function initbox(obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_SchoolSpr = oBox:NewUI(1, CSprite)
		oBox.m_AvatarSpr = oBox:NewUI(2, CSprite)
		oBox.m_GradeLabel = oBox:NewUI(3, CLabel)
		oBox.m_NameLabel = oBox:NewUI(4, CLabel)
		return oBox
	end
	self.m_MemberGrid:InitChild(initbox)
end

function CTeamInviteBox.SetInvite(self, dInvite)
	self.m_TeamID = dInvite.teamid
	for i, oBox in ipairs(self.m_MemberGrid:GetChildList()) do
		local dMember = dInvite.member[i]
		if dMember then
			oBox.m_AvatarSpr:AddUIEvent("click", callback(self, "ShowPlayerTip", dMember.pid))
			local tStatusInfo = dMember.status_info
			oBox.m_AvatarSpr:SpriteAvatar(tStatusInfo.model_info.shape)
			oBox.m_SchoolSpr:SpriteSchool(tStatusInfo.school)
			oBox.m_GradeLabel:SetText(tostring(tStatusInfo.grade))
			oBox.m_NameLabel:SetText(tStatusInfo.name)
		end
		oBox.m_AvatarSpr:SetActive(dMember~=nil)
		oBox.m_SchoolSpr:SetActive(dMember~=nil)
		oBox.m_GradeLabel:SetActive(dMember~=nil)
		oBox.m_NameLabel:SetActive(dMember~=nil)
	end
	-- self.m_TargetLabel:SetText(tostring(self.m_TeamID))
	local sDesc = ""
	local tTargetInfo = dInvite.target_info
	if tTargetInfo then
		local tData = data.teamdata.AUTO_TEAM[tTargetInfo.auto_target]
		if tData then
			sDesc = string.format("目标：%s[%d-%d级]",tData.name, tTargetInfo.min_grade, tTargetInfo.max_grade)
		end
	end
	self.m_TargetLabel:SetText(sDesc)
end

function CTeamInviteBox.OnAgree(self)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSInvitePass"]) then
		netteam.C2GSInvitePass(self.m_TeamID)
	end
end

function CTeamInviteBox.ShowPlayerTip(self, iPid)
	-- print("select pid = "..iPid)
	g_AttrCtrl:GetPlayerInfo(iPid, define.PlayerInfo.Style.Default)
end

return CTeamInviteBox