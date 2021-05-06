local CTeamInvitePlayersView = class("CTeamInvitePlayersView", CViewBase)

CTeamInvitePlayersView.TabEnum = 
{
	Friend = 1,
	Org = 2,
	Match = 3,
}

function CTeamInvitePlayersView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Team/TeamInvitePlayersView.prefab", cb)
	--界面设置
	--self.m_GroupName = "teamsub"
	self.m_ExtendClose = "Black"
	self.m_GirdMax = 50
	self.m_TabIndedx = nil
	self.m_MemberList = {}
end

function CTeamInvitePlayersView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_PlayerGrid = self:NewUI(2, CGrid)
	self.m_PlayerBoxClone = self:NewUI(3, CBox)
	self.m_RefreshBtn = self:NewUI(4, CButton)
	self.m_InviteAllBtn = self:NewUI(5, CButton)
	self.m_TabGrid = self:NewUI(6, CGrid)
	self.m_PlayerBoxClone:SetActive(false)

	self:InitContent()
end

function CTeamInvitePlayersView.InitContent( self )
	self.m_TabGrid:InitChild(function ( obj, index)
		local oBox = CBox.New(obj)
		oBox:AddUIEvent("click", callback(self, "OnClickBtn", "Switch", index))
		oBox:SetGroup(self.m_TabGrid:GetInstanceID())
		return oBox
	end)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_RefreshBtn:AddUIEvent("click", callback(self, "OnClickBtn", "RefreshAll"))
	self.m_InviteAllBtn:AddUIEvent("click", callback(self, "OnClickBtn", "InviteAll"))

	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlTeamEvent"))

	self:OnClickBtn("Switch", CTeamInvitePlayersView.TabEnum.Friend)
end

function CTeamInvitePlayersView.RefreshAll( self , isClearAll)
	self.m_PlayerGrid:Clear()
	if isClearAll == true then
		return
	end
	self.m_MemberList = g_TeamCtrl:GetInvitePlayerListByType(self.m_TabIndedx)

	local count = 1
	for k,tPlayer in ipairs(self.m_MemberList) do
		--if tPlayer.pid ~= g_AttrCtrl.pid and  count < self.m_GirdMax then
		if count < self.m_GirdMax then
			local oBox = self.m_PlayerBoxClone:Clone()
			oBox:SetActive(true)
			oBox.m_AvatarSpr = oBox:NewUI(1, CSprite):SpriteAvatar(tPlayer.shape)
			oBox.m_NameLab = oBox:NewUI(2, CLabel):SetText(tPlayer.name)
			oBox.m_GradeLab = oBox:NewUI(3, CLabel):SetText(tostring(tPlayer.grade))
			oBox.m_SchoolSpr = oBox:NewUI(4, CSprite):SpriteSchool(tPlayer.school)
			oBox.m_InviteBtn = oBox:NewUI(5, CButton)
			oBox.m_InviteBtn.m_InvitedSprite = oBox:NewUI(6, CSprite)
			oBox.m_BranchLabel = oBox:NewUI(8, CLabel):SetText(g_AttrCtrl:GetSchoolBranchStr(tPlayer.school, tPlayer.school_branch))
			oBox.m_InviteBtn.m_Pid = tPlayer.pid
			oBox.m_InviteBtn.m_Name = tPlayer.name
			oBox.m_InviteBtn.m_IsInvited = false
			oBox.m_InviteBtn:AddUIEvent("click", callback(self, "OnInvite"))
			self.m_PlayerGrid:AddChild(oBox)
			count = count + 1
		end
	end
	self.m_PlayerGrid:Reposition()
end

function CTeamInvitePlayersView.OnRefreshAll( self )
	self:RefreshAll()
end

function CTeamInvitePlayersView.OnInviteAll( self )
	if #g_TeamCtrl:GetMemberList() >= 4 then 
		g_NotifyCtrl:FloatMsg("你的队伍人数已满，无法邀请")	
	else
		if next(self.m_MemberList) == nil then
			g_NotifyCtrl:FloatMsg("没有玩家可以邀请")	
		else
			local t = {}
			for i = 1, #self.m_MemberList do 
				local oBox = self.m_PlayerGrid:GetChild(i)
				if oBox.m_InviteBtn.m_IsInvited == false then
					oBox.m_InviteBtn.m_IsInvited = true
					oBox.m_InviteBtn.m_InvitedSprite:SetActive(true)
					oBox.m_InviteBtn:SetActive(false)
					table.insert(t, oBox.m_InviteBtn.m_Pid)
				end
			end
			if #t == 0 then
				g_NotifyCtrl:FloatMsg("没有玩家可以邀请")	
			else
				g_TeamCtrl:C2GSInviteAll(t, g_TeamCtrl:GetTeamTargetInfo())
			end
		end
	end
end

function CTeamInvitePlayersView.OnInvite( self, oBtn)
	if #g_TeamCtrl:GetMemberList() >= 4 then 
		g_NotifyCtrl:FloatMsg("你的队伍人数已满，无法邀请")	
	else 
		oBtn.m_InvitedSprite:SetActive(true)
		oBtn.m_IsInvited = true	
		oBtn:SetActive(false)
		local d = g_TeamCtrl:GetTeamTargetInfo()
		g_TeamCtrl:C2GSInviteTeam(oBtn.m_Pid, d.auto_target, d.min_grade, d.max_grade) 
	end 
end

function CTeamInvitePlayersView.OnClickBtn(self, sKey, index)
	if sKey == "RefreshAll" then
		if g_TeamCtrl:CanInvitePlayer() then
			if self.m_TabIndedx == CTeamInvitePlayersView.TabEnum.Friend then
				g_TeamCtrl:CtrlC2GSInviteFriendList()

			elseif self.m_TabIndedx == CTeamInvitePlayersView.TabEnum.Org then
				if g_OrgCtrl:HasOrg() then
					--请求公会成员
					g_OrgCtrl:GetMemberList(define.Org.HandleType.OpenTeamInviteView)
				end
			end
			self:RefreshAll(true)
		end

	elseif sKey == "InviteAll" then
		self:OnInviteAll()

	elseif sKey == "Switch" then
		if self.m_TabIndedx ~= index then
			self.m_TabIndedx = index

			if index == CTeamInvitePlayersView.TabEnum.Friend then
				g_TeamCtrl:CtrlC2GSInviteFriendList()

			elseif index == CTeamInvitePlayersView.TabEnum.Org then
				if g_OrgCtrl:HasOrg() then
					--请求公会成员
					g_OrgCtrl:GetMemberList(define.Org.HandleType.OpenTeamInviteView)
				end
			elseif index == CTeamInvitePlayersView.TabEnum.Match then
				 g_TeamCtrl:CtrlC2GSGetTargetMemList()
			end
			self.m_TabGrid:GetChild(index):SetSelected(true)		
			self:RefreshAll(true)
		end
	end
end

function CTeamInvitePlayersView.OnCtrlTeamEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.TeamInvitePlayerList or 
		oCtrl.m_EventID == define.Team.Event.TeamInviteMatchList then
		self:RefreshAll()
	end
end

return CTeamInvitePlayersView