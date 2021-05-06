local CTravelInviteFriendView = class("CTravelInviteFriendView", CViewBase)

function CTravelInviteFriendView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Travel/TravelInviteFriendView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_BehindStrike = true
	self.m_ExtendClose = "Shelter"
end

function CTravelInviteFriendView.OnCreateView(self)
	self.m_PIDS = {}

	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_CancelBtn = self:NewUI(2, CButton)
	self.m_ConfirmBtn = self:NewUI(3, CButton)
	self.m_FriendGrid = self:NewUI(4, CGrid)
	self.m_FriendBox = self:NewUI(5, CBox)

	self:InitContent()
	self:RefreshFriendGrid()
end

function CTravelInviteFriendView.InitContent(self)
	self.m_FriendBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnCancelBtn"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirmBtn"))
end

function CTravelInviteFriendView.OnCancelBtn(self, oBtn)
	self:CloseView()
end

function CTravelInviteFriendView.OnConfirmBtn(self, oBtn)
	if #self.m_PIDS > 0 then
		nettravel.C2GSInviteTravel(self.m_PIDS)
		self:CloseView()
	else
		g_NotifyCtrl:FloatMsg("当前未选择好友")
	end
end

function CTravelInviteFriendView.RefreshFriendGrid(self)
	self.m_FriendGrid:Clear()
	local frdList = self:GetSortFriend()
	for i,frd in ipairs(frdList) do
		local bLately = frd.invite_time and i < 4 
		local oFriendBox = self:CreateFriendBox(frd.pid, bLately, i)
		self.m_FriendGrid:AddChild(oFriendBox)
	end
	self.m_FriendGrid:Reposition()
end

function CTravelInviteFriendView.CreateFriendBox(self, pid, bLately, i)
	local frdobj = g_FriendCtrl:GetFriend(pid)
	if not frdobj then
		return
	end
	local oFriendBox = self.m_FriendBox:Clone()
	oFriendBox:SetActive(true)
	oFriendBox.m_NameLabel = oFriendBox:NewUI(1, CLabel)
	oFriendBox.m_HeadSprite = oFriendBox:NewUI(2, CSprite)
	oFriendBox.m_SchoolSpr = oFriendBox:NewUI(3, CSprite)
	oFriendBox.m_GradeLabel = oFriendBox:NewUI(4, CLabel)
	oFriendBox.m_CheckSprite = oFriendBox:NewUI(5, CSprite)
	oFriendBox.m_LatelySprite = oFriendBox:NewUI(6, CSprite)
	oFriendBox.m_CheckSprite:SetActive(false)
	oFriendBox.m_LatelySprite:SetActive(bLately)
	oFriendBox:AddUIEvent("click", callback(self, "OnFriendBox"))
	
	oFriendBox.m_PID = pid
	oFriendBox.m_NameLabel:SetText(frdobj.name)
	oFriendBox.m_HeadSprite:SpriteAvatar(frdobj.shape)
	oFriendBox.m_GradeLabel:SetText(frdobj.grade)
	oFriendBox.m_SchoolSpr:SpriteSchool(frdobj.school)
	if bLately then
		self:OnFriendBox(oFriendBox)
	end
	return oFriendBox
end

function CTravelInviteFriendView.OnFriendBox(self, oFriendBox)
	local idx = table.index(self.m_PIDS, oFriendBox.m_PID)
	if idx then
		table.remove(self.m_PIDS, idx)
		oFriendBox.m_CheckSprite:SetActive(false)
	else
		table.insert(self.m_PIDS, oFriendBox.m_PID)
		oFriendBox.m_CheckSprite:SetActive(true)
	end
end

function CTravelInviteFriendView.GetMyFriend(self)
	local frdList = {}
	for _, pid in ipairs(g_FriendCtrl:GetMyFriend()) do
		local frdobj = g_FriendCtrl:GetFriend(pid)
		if frdobj.grade >= data.globalcontroldata.GLOBAL_CONTROL.travel.open_grade then
			table.insert(frdList, frdobj)
		end
	end
	return frdList
end

function CTravelInviteFriendView.GetSortFriend(self)
	local frdList = self:GetMyFriend()
	local inviteFrds = g_TravelCtrl:GetMine2FrdInviteInfo()
	if inviteFrds then
		for i,v in ipairs(inviteFrds) do
			for j,l in ipairs(frdList) do
				if v.frd_pid == l.pid then
					l.invite_time = v.invite_time
				end
			end
		end
	end

	local function sort(A, B)
		local timeA = A.invite_time or 0
		local timeB = B.invite_time or 0
		if timeA ~= timeB then
			return timeA > timeB
		end
		local friend_degreeA = A.friend_degree
		local friend_degreeB = B.friend_degree
		if friend_degreeA ~= friend_degreeB then
			return friend_degreeA > friend_degreeB
		end
		return A.pid > B.pid
	end
	table.sort(frdList, sort)
	return frdList
end

return CTravelInviteFriendView