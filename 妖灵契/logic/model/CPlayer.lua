local CPlayer = class("CPlayer", CMapWalker)

function CPlayer.ctor(self)
	CMapWalker.ctor(self)
	
	self.m_Eid = nil --场景中唯一的ID
	self.m_Pid = nil --角色ID
	self.m_Followers ={} --跟随宠物列表
	self:SetCheckInScreen(true)
end

function CPlayer.OnTouch(self)
	local oView = CMainMenuView:GetView()
	if oView then
		if g_OrgWarCtrl:GetCurrentScene() == define.Org.OrgWarScene.War and self.m_Camp ~= g_AttrCtrl.camp then
			-- if g_TeamCtrl:IsInTeam() and g_TeamCtrl:GetMemberSize() > 1 then
			-- 	if g_TeamCtrl:IsLeader() then
					nethuodong.C2GSOrgWarPK(self.m_Pid)
			-- 	end
			-- else
			-- 	g_NotifyCtrl:FloatMsg("需要2人组队才能主动PK对方")
			-- end
		elseif oView.m_LB.m_SocialityPart:IsSelectingMotion() then
			oView.m_LB.m_SocialityPart:OnSelectPlayer(self)
		else
			oView.m_Center:ShowPlayerAvatar(self.m_Pid)
		end
	end
end

function CPlayer.DoOtherSet(self)
	if g_FieldBossCtrl:IsHidePlayer() then
		if self.m_IsFight then
			self:HidePlayer("hidefight")
		else
			self:ShowPlayer()
		end
	end
	self:SysCtrlCheckHidePlayer()
end

function CPlayer.HidePlayer(self, sReason)
	for hudname, v in pairs(self.m_Huds) do
		local oHud = v.obj
		if oHud then
			oHud:SetAutoUpdate(false)
			oHud:SetActive(false)
		else
			v.ishide = true
		end
	end
	self.m_HideKey = sReason
	self:SetActive(false)
	for k,v in pairs(self.m_Followers) do
		if v then
			if v.m_Huds then
				for _,d in pairs(v.m_Huds ) do
					local oHud = d.obj
					if oHud then
						oHud:SetAutoUpdate(false)
						oHud:SetActive(false)						
					end
				end
			end
			v:SetActive(false)
		end
	end
end

function CPlayer.ShowPlayer(self)
	for hudname, v in pairs(self.m_Huds) do
		local oHud = v.obj
		v.ishide = false
		if oHud then
			oHud:SetAutoUpdate(true)
			oHud:SetActive(true)
		end
	end
	self:SetActive(true)
	for k,v in pairs(self.m_Followers) do
		if v then
			if v.m_Huds then
				for _,d in pairs(v.m_Huds ) do
					local oHud = d.obj
					if oHud then
						oHud:SetAutoUpdate(true)
						oHud:SetActive(true)						
					end
				end
			end
			v:SetActive(true)
		end
	end
end

function CPlayer.SysCtrlCheckHidePlayer(self)
	local bHide = g_SysSettingCtrl:GetHidePlayerEnabled() == true
	if bHide then
		self:HidePlayer("sysctrlhide")
	end
end

return CPlayer