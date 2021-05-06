local CTeamMemberBox = class("CTeamMemberBox", CBox)

function CTeamMemberBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_SchoolLabel = self:NewUI(1, CLabel)
	self.m_NameLabel = self:NewUI(2, CLabel)
	self.m_SchoolSpr = self:NewUI(3, CSprite)
	self.m_GradeLabel = self:NewUI(4, CLabel)
	self.m_LevelWidget = self:NewUI(5, CBox)
	self.m_LeaderSpr = self:NewUI(6, CSprite)
	self.m_OperateLabel = self:NewUI(7, CLabel)
	self.m_LocWidget = self:NewUI(8, CWidget)
	self.m_SelfSpr = self:NewUI(9, CWidget)
	self.m_CenterActorTexture = self:NewUI(10, CActorTexture)
	self.m_LeftActorTexture = self:NewUI(11, CActorTexture)
	self.m_RightActorTexture = self:NewUI(12, CActorTexture)
	self.m_OffLineWidget = self:NewUI(15, CBox)
	self.m_TargetCountLabel = self:NewUI(16, CLabel)
	self.m_ZanBtn = self:NewUI(17, CBox)
	self.m_PartnerGradeLabel = self:NewUI(18, CLabel)
	self.m_CommomWidget = self:NewUI(20, CBox)
	self.m_Member = nil
	self.m_Partner = nil	
	self.m_CdTimer = nil
	self.m_CdTime = 0
	self:InitContent()
end

function CTeamMemberBox.InitContent(self)
	self.m_RightActorTexture:SetAlpha(0.6)
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlTeamEvent"))
end

function CTeamMemberBox.SetMember(self, dMember, dPartner)
	self.m_Member = dMember
	self.m_Partner = dPartner
	self.m_CenterActorTexture:SetActive(false)
	self.m_LeftActorTexture:SetActive(false)
	self.m_RightActorTexture:SetActive(false)	
	self.m_ZanBtn:SetActive(false)
	self.m_PartnerGradeLabel:SetActive(false)
	self.m_GradeLabel:SetActive(false)
	self.m_CommomWidget:SetActive(false)
	self:SetCountLabel()
	--如果显示的玩家信息
	if self:IsMember() then
		local pid = dMember.pid
		self.m_LeaderSpr:SetActive(g_TeamCtrl:IsLeader(pid))
		self.m_NameLabel:SetText(dMember.name)
		self.m_GradeLabel:SetText("Lv "..tostring(dMember.grade))
		self.m_GradeLabel:SimulateOnEnable()
		self.m_SelfSpr:SetActive(dMember.pid == g_AttrCtrl.pid)
		self.m_SchoolSpr:SetActive(true)
		self.m_SchoolSpr:SpriteSchool(dMember.school)
		self.m_SchoolLabel:SetText(g_AttrCtrl:GetSchoolBranchStr(dMember.school, dMember.school_branch))

		self.m_LevelWidget:SetActive(false)
		self.m_OffLineWidget:SetActive(false)
		if g_TeamCtrl:IsLeave(pid) then
			self.m_LevelWidget:SetActive(true)
			--self.m_GradeLabel:SetText("暂离")
		elseif g_TeamCtrl:IsOffline(pid) then
			self.m_OffLineWidget:SetActive(true)
			--self.m_GradeLabel:SetText("离线")
		end
		if g_TeamCtrl:IsJoinTeam(pid) and g_TeamCtrl:IsCommander(pid) and not g_TeamCtrl:IsLeader(pid) then
			self.m_CommomWidget:SetActive(true)
		end
		--该玩家的主伙伴未出战
		if dMember.partner_info == nil then
			self.m_CenterActorTexture:SetActive(true)
			self.m_CenterActorTexture:ChangeShape(dMember.model_info.shape, dMember.model_info)
		else
			self.m_LeftActorTexture:SetActive(true)
			self.m_RightActorTexture:SetActive(true)
			self.m_LeftActorTexture:ChangeShape(dMember.model_info.shape, dMember.model_info)	
			self.m_RightActorTexture:ChangeShape(dMember.partner_info.model_info.shape, dMember.partner_info.model_info)					
		end
		if pid ~= g_AttrCtrl.pid then
			self.m_ZanBtn:SetActive(true)
			self.m_ZanBtn:SetGrey(false)
			self.m_ZanBtn:AddUIEvent("click", callback(self, "OnDianZan", pid))
		end

	--如果显示的玩家的副伙伴
	else
		if dPartner ~= nil then
			printc("--如果显示的玩家的副伙伴 ")
			table.print(dPartner)

			self.m_PartnerGradeLabel:SetActive(true)
			self.m_LeaderSpr:SetActive(false) 
			self.m_LevelWidget:SetActive(false)
			self.m_OffLineWidget:SetActive(false)
			self.m_SchoolSpr:SetActive(false)	
			self.m_NameLabel:SetText(dPartner.name)
			self.m_PartnerGradeLabel:SetText("Lv "..tostring(dPartner.grade))
			self.m_CenterActorTexture:SetActive(true)
			self.m_CenterActorTexture:ChangeShape(dPartner.model_info.shape, dPartner.model_info)
		end
	end
end

function CTeamMemberBox.IsMember(self)
	return self.m_Member ~= nil
end

function CTeamMemberBox.OnDianZan(self, pid, oBox)
	oBox:SetGrey(true)
	netplayer.C2GSUpvotePlayer(pid)
end

function CTeamMemberBox.OnCtrlTeamEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.RefreshTargetCount 
		or oCtrl.m_EventID == define.Team.Event.NotifyAutoMatch then
		self:SetCountLabel()
	end
end

function CTeamMemberBox.SetCountLabel(self)
	if self.m_CdTimer ~= nil then
		Utils.DelTimer(self.m_CdTimer)
		self.m_CdTimer = nil
	end
	self.m_TargetCountLabel:SetActive(false)	
	local targetInfo = g_TeamCtrl:GetTeamTargetInfo()
	if self:IsMember() and targetInfo.auto_target == CTeamCtrl.TARGET_MING_LEI then		
		local t = g_TeamCtrl:GetargetCountTable(CTeamCtrl.TARGET_MING_LEI)
		local pid = self.m_Member.pid
		if t and t[pid] and t[pid].fight_time and t[pid].fight_time ~= "" then
			self.m_TargetCountLabel:SetActive(true)
			local list = string.split(t[pid].fight_time, "/")
			if list and #list > 1 and (tonumber(list[1]) - tonumber(list[2])) == 0 then
				self.m_TargetCountLabel:SetText("次数不足")
				self.m_TargetCountLabel:SetColor(Color.New( 255/255, 0/255, 0/255, 255/255))				
			else				
				self.m_TargetCountLabel:SetText(t[pid].fight_time)
				self.m_TargetCountLabel:SetColor(Color.New( 0/255, 0/255, 0/255, 255/255))
			end			
		end	
	elseif self:IsMember() and targetInfo.auto_target == CTeamCtrl.TARGET_AN_LEI_BOX then	
		local t = g_TeamCtrl:GetargetCountTable(CTeamCtrl.TARGET_AN_LEI_BOX)
		local pid = self.m_Member.pid
		if t and t[pid] then		
			if t[pid].cd and t[pid].cd > 0 then
				self.m_TargetCountLabel:SetColor(Color.New( 255/255, 0/255, 0/255, 255/255))
				self.m_CdTime = t[pid].cd		
				self.m_TargetCountLabel:SetText(string.format("冷却时间\n%s", g_TimeCtrl:GetLeftTime(self.m_CdTime)))		
				local function wrap()					
					self.m_CdTime = self.m_CdTime - 1
					self.m_TargetCountLabel:SetText(string.format("冷却时间\n%s", g_TimeCtrl:GetLeftTime(self.m_CdTime)))		
					if self.m_CdTime < 0 then
						self.m_TargetCountLabel:SetActive(false)
						return false
					else																
						return true
					end
				end
				self.m_TargetCountLabel:SetActive(true)		
				self.m_CdTimer = Utils.AddTimer(wrap, 1, 0)			
			end			
		end	
	end
end

function CTeamMemberBox.Destroy(self)
	if self.m_CdTimer ~= nil then
		Utils.DelTimer(self.m_CdTimer)
		self.m_CdTimer = nil
	end	
	CObject.Destroy(self)
end

return CTeamMemberBox