local CTeamApplyBox = class("CTeamApplyBox", CBox)

function CTeamApplyBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ActorTexture = self:NewUI(1, CActorTexture)
	self.m_NameLabel = self:NewUI(2, CLabel)
	self.m_SchoolSpr = self:NewUI(3, CSprite)
	self.m_GradeLabel = self:NewUI(4, CLabel)
	self.m_AgreeBtn = self:NewUI(5, CButton)
	self.m_SchoolLabel = self:NewUI(6, CLabel)
	self.m_Apply = nil

	self.m_AgreeBtn:SetActive(g_TeamCtrl:IsLeader())
	self.m_AgreeBtn:AddUIEvent("click", callback(self, "OnAgree"))

	self:AddUIEvent("click", callback(self, "ShowPlayerTip"))
end

function CTeamApplyBox.SetApply(self, dApply)
	self.m_Apply = dApply
	self.m_ActorTexture:ChangeShape(dApply.model_info.shape, dApply.model_info)
	self.m_NameLabel:SetText(dApply.name)
	self.m_GradeLabel:SetText("Lv "..tostring(dApply.grade))
	self.m_GradeLabel:SimulateOnEnable()
	self.m_SchoolSpr:SpriteSchool(dApply.school)
	self.m_SchoolLabel:SetText(g_AttrCtrl:GetSchoolBranchStr(dApply.school, dApply.school_branch))	
end

function CTeamApplyBox.OnAgree(self)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSApplyTeamPass"]) then
		netteam.C2GSApplyTeamPass(self.m_Apply.pid)
	end
end

function CTeamApplyBox.ShowPlayerTip(self)
	g_AttrCtrl:GetPlayerInfo(self.m_Apply.pid, define.PlayerInfo.Style.Default)
end

return CTeamApplyBox