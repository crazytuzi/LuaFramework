local CTeamHandyApplyBox = class("CTeamHandyApplyBox", CBox)

CTeamHandyApplyBox.Enum = 
{
	Join = 1,
	Apply = 2,
	Go = 3,
	Leave = 4,
}

function CTeamHandyApplyBox.ctor(self, obj, parentView)
	CBox.ctor(self, obj)
	self.m_TargetLabel = self:NewUI(1, CLabel)
	self.m_MemberGrid = self:NewUI(2, CGrid)
	self.m_HandyApplyBtn = self:NewUI(3, CButton)
	self.m_TeamID = -1
	self.m_LeaderID = -1
	self.m_IsApply = false
	self.m_ApplyState = nil
	self.m_Callback = nil
	self.m_IsAutoMatch = false
	self.m_ParentView = parentView
	self:InitContent()
end

function CTeamHandyApplyBox.SetCallback(self, cb)
	self.m_Callback = cb
end

function CTeamHandyApplyBox.InitContent(self)
	self.m_HandyApplyBtn:AddUIEvent("click", callback(self, "OnHandyApply"))
	local function initbox(obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_SchoolSpr = oBox:NewUI(1, CSprite)
		oBox.m_AvatarSpr = oBox:NewUI(2, CSprite)
		oBox.m_GradeLabel = oBox:NewUI(3, CLabel)
		oBox.m_NameLabel = oBox:NewUI(4, CLabel)
		oBox.m_SchoolBranch = oBox:NewUI(5, CLabel)
		return oBox
	end
	self.m_MemberGrid:InitChild(initbox)
end

function CTeamHandyApplyBox.SetHandyApply(self, dTargetTeam, igonreVisible)
	self.m_TeamID = dTargetTeam.teamid
	self.m_LeaderID = dTargetTeam.leader
	self.m_IsAutoMatch = false
	local tTargetInfo = dTargetTeam.target_info
	local tAutoTeamdata = nil
	if tTargetInfo then
		tAutoTeamdata = data.teamdata.AUTO_TEAM[tTargetInfo.auto_target]
		self.m_IsAutoMatch = tTargetInfo.team_match == 1
	end

	for i, oBox in ipairs(self.m_MemberGrid:GetChildList()) do
		local dMember = dTargetTeam.member[i]
		if dMember then
			local tStatusInfo = dMember.status_info
			oBox.m_AvatarSpr:SpriteAvatar(tStatusInfo.model_info.shape)
			--oBox.m_AvatarSpr:AddUIEvent("click", callback(self, "ShowPlayerTip", dMember.pid))
			oBox.m_SchoolSpr:SpriteSchool(tStatusInfo.school)	
			oBox.m_SchoolSpr:SetActive(true)		
			oBox.m_GradeLabel:SetText(tostring(tStatusInfo.grade))				
			oBox.m_GradeLabel:SetActive(true)
			oBox.m_NameLabel:SetText(tStatusInfo.name)
			oBox.m_SchoolBranch:SetText(g_AttrCtrl:GetSchoolBranchStr(tStatusInfo.school, tStatusInfo.school_branch))
		else
			oBox.m_AvatarSpr:SetSpriteName("")
			oBox.m_GradeLabel:SetActive(false)
			oBox.m_SchoolSpr:SetActive(false)		
			oBox.m_SchoolBranch:SetActive(false)
		end		
		if igonreVisible ~= true then
			oBox.m_AvatarSpr:SetActive(dMember~=nil)
			oBox.m_SchoolSpr:SetActive(dMember~=nil and i == 1)
			oBox.m_GradeLabel:SetActive(dMember~=nil and i == 1)
			oBox.m_NameLabel:SetActive(dMember~=nil and i == 1)
			oBox.m_SchoolBranch:SetActive(dMember~=nil and i == 1)
		else
			oBox.m_SchoolBranch:SetActive(false)
		end		
		oBox:SetActive(true)
		if tAutoTeamdata and tAutoTeamdata.id ~= CTeamCtrl.TARGET_NONE and
			i > tAutoTeamdata.match_count then
			oBox:SetActive(false)
		end
	end

	local use_sub_name_table = {1161, 1162, 1163, 1101, 1111}
	local sDesc = ""	
	if tAutoTeamdata then
		if table.key(use_sub_name_table, tAutoTeamdata.id) then
			sDesc = string.format("%s", tAutoTeamdata.sub_name)	
		elseif tAutoTeamdata.parentId and tAutoTeamdata.parentId ~= 0 then
			sDesc = string.format("%s", tAutoTeamdata.sub_name)			
		else
			sDesc = string.format("%s", tAutoTeamdata.name)	
		end		
	end
	self.m_TargetLabel:SetText(sDesc)

	local minGarde = dTargetTeam.target_info.min_grade or 0
	local maxGarde = dTargetTeam.target_info.max_grade or g_AttrCtrl.server_grade
	local isLeader = g_TeamCtrl:IsLeader()
	local isJoinTeam = g_TeamCtrl:IsJoinTeam()
	local fixLevel = (g_AttrCtrl.grade >= minGarde and g_AttrCtrl.grade <= maxGarde) and true or false
	local isMyTeam = (isJoinTeam == true and g_TeamCtrl.m_TeamID == self.m_TeamID) and true or false
	self.m_HandyApplyBtn:SetActive(false)

	if isMyTeam then
		self.m_HandyApplyBtn:SetActive(true)
		if isLeader then
			self.m_ApplyState = CTeamHandyApplyBox.Enum.Go
			self.m_HandyApplyBtn:SetText("出发")
		else
			self.m_ApplyState = CTeamHandyApplyBox.Enum.Leave
			self.m_HandyApplyBtn:SetText("离开")
		end
	else
		if not isJoinTeam then
			self.m_HandyApplyBtn:SetActive(true)
			if fixLevel and self.m_IsAutoMatch then
				self.m_ApplyState = CTeamHandyApplyBox.Enum.Join
				self.m_HandyApplyBtn:SetText("加入")
			else
				self.m_ApplyState = CTeamHandyApplyBox.Enum.Apply
				self.m_HandyApplyBtn:SetText("申请")
			end
		end		
	end
end

function CTeamHandyApplyBox.OnHandyApply(self)
	-- TODO:根据状态发起申请or取消请求，按钮文本在请求返回后处理
	if self.m_ApplyState == CTeamHandyApplyBox.Enum.Go then
		if g_TeamCtrl:TeamReadGo() then
			if self.m_ParentView then
				self.m_ParentView:CloseView()
			end
		end
	elseif self.m_ApplyState == CTeamHandyApplyBox.Enum.Leave then
		if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSLeaveTeam"]) then
			netteam.C2GSLeaveTeam()
		end

	elseif self.m_ApplyState == CTeamHandyApplyBox.Enum.Join then
		if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSApplyTeam"]) then
			nettask.C2GSEnterShow(0, 0)
			netteam.C2GSApplyTeam(self.m_LeaderID)
		end

	elseif self.m_ApplyState == CTeamHandyApplyBox.Enum.Apply then
		if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSApplyTeam"]) then
			nettask.C2GSEnterShow(0, 0)
			netteam.C2GSApplyTeam(self.m_LeaderID)
		end
	end
	
	if self.m_Callback then
		self.m_Callback()
	end	

	-- if self.m_IsApply then
	--	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSCancelApply"]) then
	-- 	netteam.C2GSCancelApply(self.m_TeamID)
	--	end
	-- 	self.m_HandyApplyBtn:SetText("申请")
	-- 	self.m_IsApply = false
	-- else
	-- 	if g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.TeamApply, self.m_LeaderID) then
	-- 		g_NotifyCtrl:FloatMsg("申请太频繁，请稍后再试")
	-- 		return
	-- 	end
	--  if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSApplyTeam"]) then
	--	nettask.C2GSEnterShow(0, 0)
	-- 	netteam.C2GSApplyTeam(self.m_LeaderID)
	--	end
	-- 	g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.TeamApply, self.m_LeaderID, 10)
	-- 	self.m_HandyApplyBtn:SetText("取消申请")
	-- 	self.m_IsApply = true
	-- 	if self.m_Callback then
	-- 		self.m_Callback()
	-- 	end
	-- end

end

function CTeamHandyApplyBox.ShowPlayerTip(self, iPid)
	g_AttrCtrl:GetPlayerInfo(iPid, define.PlayerInfo.Style.Default)
end

return CTeamHandyApplyBox