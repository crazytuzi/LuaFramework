local CEscortNpc = class("CEscortNpc", CMapWalker)

function CEscortNpc.ctor(self)
	CMapWalker.ctor(self)

	self.m_ClientNpc = nil
	self.m_Timer = nil
	self.m_IsFollowHero = false
	self.m_IsCanFollowHero = true
	self.m_FollowTargetPid = nil
end

function CEscortNpc.SetData(self, clientNpc)
	self.m_ClientNpc = clientNpc
	local taskNpc = g_TaskCtrl:GetTaskNpc(clientNpc.npctype)
	self.m_Actor:SetLocalRotation(Quaternion.Euler(0, taskNpc.rotateY or 150, 0))
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTeamCtrlEvent"))
	--self:FollowHero()

	self:DelayCall(0, "RefreshNpcVisible")
end

function CEscortNpc.OnTouch(self)
	-- TODO >>> 点到DynamicNpc
	CMapWalker.OnTouch(self, self.m_ClientNpc.npcid)
end

function CEscortNpc.Trigger(self)
	--self:FaceToHero()
	-- local npcid = self.m_ClientNpc.npcid
	-- local taskList = g_TaskCtrl:GetNpcAssociatedTaskList(npcid)
	-- if taskList and #taskList > 0 then
	-- 	-- 默认直接给他第一个任务的id
	-- 	local taskid = taskList[1]:GetValue("taskid")
	--if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSTaskEvent"]) then
	-- 	nettask.C2GSTaskEvent(taskid, npcid)
	--end
	-- end
end

function CEscortNpc.FollowHero(self, follower)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end	
	local oHero = g_MapCtrl:GetHero()
	if self.m_FollowTargetPid then
		if self.m_FollowTargetPid == g_AttrCtrl.pid	then
			if oHero then
				oHero:DelTaskNpcFollower(self)
			end
		else
			local walker = g_MapCtrl:GetPlayer(self.m_FollowTargetPid)
			if walker then
				walker:DelTaskNpcFollower(self)
			end
		end
	end
	
	if follower then
		follower:AddTaskNpcFollower(self)

	elseif oHero then
		oHero:AddTaskNpcFollower(self)
		self:DelayCall(0, "RefreshNpcVisible")
	else
		local function wrap( )
			local oHero = g_MapCtrl:GetHero()
			if oHero then
				self:SetPos(oHero:GetPos()) 
				oHero:AddTaskNpcFollower(self)
				--self:ChangeFollow(oHero)
				return false
			else
				return true
			end	
		end 
		self.m_Timer = Utils.AddTimer(wrap, 0.5, 0)
	end
	self.m_IsFollowHero = true
end

function CEscortNpc.Destroy(self)
	if self.m_FollowTargetPid then
		if self.m_FollowTargetPid == g_AttrCtrl.pid	then
			local oHero = g_MapCtrl:GetHero()
			if oHero then
				oHero:DelTaskNpcFollower(self)
			end
		else
			local walker = g_MapCtrl:GetPlayer(self.m_FollowTargetPid)
			if walker then
				walker:DelTaskNpcFollower(self)
			end
		end
	end

	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	CMapWalker.Destroy(self)
end

function CEscortNpc.SetVisible(self, b)
	if not self.m_Actor then
		return
	end
	self.m_Actor:SetActive(b)
	self.m_Actor:SetColliderEnbled(b)	
	self:SetNeedShadow(b)

	if b == false then
		self:SetIgnoreUpdateTransparent(true)
		self:SetTransparent(0)
		self:SetNameHud("")
	else
		self:SetIgnoreUpdateTransparent(false)
		self:SetTransparent(1)	
		self:SetNameHud(string.format("[FF00FF]%s", self.m_Name))
	end

end

function CEscortNpc.OnTeamCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.AddTeam or
		oCtrl.m_EventID == define.Team.Event.DelTeam or 
		oCtrl.m_EventID == define.Team.Event.NotifyAutoMatch or
		oCtrl.m_EventID == define.Team.Event.MemberUpdate then
		self:DelayCall(1, "RefreshNpcVisible")
	end
end

function CEscortNpc.RefreshNpcVisible(self)
	local visible = true
	local isInTeam = g_TeamCtrl:IsInTeam()
	local isLeader = g_TeamCtrl:IsLeader()
	if isInTeam and not isLeader then
		visible = false
	end
	if not isInTeam then
		local oHero = g_MapCtrl:GetHero()
		if oHero and self.m_IsCanFollowHero == true then
			self:FollowHero(oHero)
		end
		
	elseif isLeader then
		local pid = g_AttrCtrl.pid
		local pos = 0
		local lMemberList = g_TeamCtrl:GetMemberList()
		for i = 1, #lMemberList do
			local dMember = lMemberList[i]

			if dMember and not g_TeamCtrl:IsOffline(dMember.pid) and not g_TeamCtrl:IsLeave(dMember.pid) and dMember.pid ~= pid then
				local p = g_TeamCtrl:GetMemberPosById(dMember.pid)		
				--printy(" dMember ", dMember.name,dMember.pid, p, pos)	
				if p > pos then
					pid = dMember.pid
					pos = p
				end				
			end

		end
		--printy(" dMember end ", pid, pos)	
		if pid then
			if pid == g_AttrCtrl.pid then
				local oHero = g_MapCtrl:GetHero()
				if oHero then
					self:FollowHero(oHero)
				end
			else
				local walker = g_MapCtrl:GetPlayer(pid)
				if walker then
					self:FollowHero(walker)
				end
			end
		end
	end
	self:SetVisible(visible)
end

function CEscortNpc.SetTransparent(self, alpha)
	if not Utils.IsNil(self) then
		self.m_Walker:SetTransparent(alpha)
	end
end

function CEscortNpc.SetIgnoreUpdateTransparent(self, b)
	self.m_Walker:SetIgnoreUpdateTransparent(b)
end

function CEscortNpc.DelayCheckFollow(self)
	if not self.m_IsFollowHero then
		local cb = function ()
			if not Utils.IsNil(self) then
				if not self.m_IsFollowHero and CDialogueMainView:GetView() == nil then
					self.m_IsCanFollowHero = true
					self:RefreshNpcVisible()
				end
			end
		end
		Utils.AddTimer(cb, 0, 0.5)
	end	
end


return CEscortNpc