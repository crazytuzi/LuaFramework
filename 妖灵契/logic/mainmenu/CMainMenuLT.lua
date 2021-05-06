local CMainMenuLT = class("CMainMenuLT", CBox)

function CMainMenuLT.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_HeroBox = self:NewUI(1, CBox)
	-- HeroBox
	self.m_HeroBox.m_Avatar = self.m_HeroBox:NewUI(1, CSprite)
	self.m_HeroBox.m_GradeLabel = self.m_HeroBox:NewUI(2, CLabel)
	self.m_HeroBox.m_MainMenuBuffBox = self.m_HeroBox:NewUI(3, CMainMenuBuffBox)
	self.m_HeroBox.m_HeroPowLabel = self.m_HeroBox:NewUI(4, CLabel)
	self.m_HeroBox.m_HeroVipSprite = self.m_HeroBox:NewUI(5, CSprite)
	self.m_HeroBox.m_HeroVipLevelLabel = self.m_HeroBox:NewUI(6, CLabel)

	self.m_ExpandBox = self:NewUI(2, CMainMenuExpandBox)
	self.m_TeamBox = self:NewUI(3, CMainMenuTeamBox)
	self.m_FriendBtn = self:NewUI(4, CSprite)
	self.m_MsgLabel = self:NewUI(5, CLabel)

	self.m_HeroBox.m_IgnoreCheckEffect = true
	self:InitContent()
end

function CMainMenuLT.InitContent(self)
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTaskEvent"))
	g_TalkCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTalkEvent"))
	g_MailCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMailEvent"))
	g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFriendEvent"))
	g_ActivityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlActivityEvent"))
	g_EquipFubenCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEquipFbEvent"))
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlMapEvent"))
	g_AnLeiCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAnLeilEvent"))		
	g_FieldBossCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFieldBossEvent"))
	g_ConvoyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnConvoyEvent"))
	self.m_FriendBtn:AddUIEvent("click", callback(self, "OpenFriendInfoView"))
	self.m_HeroBox:AddUIEvent("click", callback(self, "OnShowAttr"))
	self:UpdateMsgAmount()
	self:CheckOpenGrade()
	self:RefreshHero()
	self:RefreshButton()
	self:CheckHeroBoxRedDot()
end

function CMainMenuLT.Destroy(self)
	CViewBase.Destroy(self)
end

function CMainMenuLT.CheckOpenGrade(self)
	self.m_FriendBtn:SetActive(g_FriendCtrl:IsOpen())	
end

function CMainMenuLT.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:DelayCall(0, "CheckOpenGrade")
		self:DelayCall(0, "RefreshHero")
		self:DelayCall(0, "RefreshButton")
	elseif oCtrl.m_EventID == define.Attr.Event.UpdateSkin then
		self:CheckHeroBoxRedDot()
	end
end

function CMainMenuLT.OnTalkEvent(self, oCtrl)
	self:DelayCall(0, "UpdateMsgAmount", "talk")
end

function CMainMenuLT.OnFriendEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Friend.Event.UpdateApply then
		self:DelayCall(0, "UpdateMsgAmount", "apply")
	end 
end

function CMainMenuLT.OnTaskEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.RefreshAllTaskBox then
		self:DelayCall(0, "CheckOpenGrade")
		self:DelayCall(0, "RefreshButton")
	end
end

function CMainMenuLT.OnMailEvent(self, oCtrl)
	self:DelayCall(0, "UpdateMsgAmount", "mail")
end

function CMainMenuLT.UpdateMsgAmount(self, sType)
	local function getStr(str)
		if str == "talk" then
			return "你有新的消息"
		elseif str == "mail" then
			return "你有新的邮件"
		elseif str == "apply" then
			return "你有新的请求"
		end
		return ""
	end
	local dAmount = {}
	dAmount["talk"] = g_TalkCtrl:GetTotalNotify()
	dAmount["apply"] = g_FriendCtrl:GetApplyAmount()
	dAmount["mail"] = g_MailCtrl:GetUnOpenMailAmount()
	if dAmount["talk"] + dAmount["apply"] + dAmount["mail"] > 0 then
		self.m_MsgLabel:SetActive(true)
		if sType and dAmount[sType] > 0 then
			self.m_MsgLabel:SetText(getStr(sType))
		else
			for _, key in ipairs({"talk", "mail", "apply"}) do
				if dAmount[key] and dAmount[key] > 0 then
					self.m_MsgLabel:SetText(getStr(key))
					break
				end
			end
		end
	else
		self.m_MsgLabel:SetActive(false)
	end
end

function CMainMenuLT.OpenFriendInfoView(self)
	CFriendMainView:ShowView()
end

function CMainMenuLT.RefreshHero(self)
	self.m_HeroBox.m_Avatar:SpriteMainMenuAvatarBig(g_AttrCtrl.model_info.shape)
	self.m_HeroBox.m_GradeLabel:SetText(g_AttrCtrl.grade)
	self:RefreshHeroPower()
	if g_AttrCtrl.vip_level ~= 0 then
		self.m_HeroBox.m_HeroVipSprite:SetActive(true)
		self.m_HeroBox.m_HeroVipLevelLabel:SetText("V"..tostring(g_AttrCtrl.vip_level))
	else
		self.m_HeroBox.m_HeroVipSprite:SetActive(false)
	end
end

function CMainMenuLT.RefreshHeroPower(self)
	self.m_HeroBox.m_HeroPowLabel:SetText(g_AttrCtrl:GetTotalPower())
end

function CMainMenuLT.OnShowAttr(self)
	CAttrMainView:ShowView()
end

function CMainMenuLT.RefreshButton(self)
	self.m_TeamBox:SetActive(g_ActivityCtrl:IsActivityVisibleBlock("team"))
end

function CMainMenuLT.OnCtrlActivityEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Activity.Event.DCAddTeam then
		self:DelayCall(0, "RefreshButton")
	elseif oCtrl.m_EventID == define.Activity.Event.DCLeaveTeam then
		self:DelayCall(0, "RefreshButton")

	elseif oCtrl.m_EventID == define.Activity.Event.DCUpdateTeam then
		self:DelayCall(0, "RefreshButton")

	elseif oCtrl.m_EventID == define.Activity.Event.DCRefreshTask then
		self:DelayCall(0, "RefreshButton")
	end
end

function CMainMenuLT.OnCtrlEquipFbEvent(self, oCtrl)
	if oCtrl.m_EventID == define.EquipFb.Event.BeginFb then
		self:DelayCall(0, "RefreshButton")

	elseif oCtrl.m_EventID == define.EquipFb.Event.EndFb then
		self:DelayCall(0, "RefreshButton")

	elseif oCtrl.m_EventID == define.EquipFb.Event.CompleteFB then
		self:DelayCall(0, "RefreshButton")
	end
end

function CMainMenuLT.OnCtrlMapEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Map.Event.ShowScene then
		self:DelayCall(0, "RefreshButton")		
	elseif oCtrl.m_EventID == define.Map.Event.MapLoadDone then
		self:DelayCall(0, "RefreshButton")
	elseif oCtrl.m_EventID == define.Map.Event.EnterScene then
	 	self:DelayCall(0, "RefreshButton")
	end	
end

function CMainMenuLT.OnCtrlAnLeilEvent( self, oCtrl)
	if oCtrl.m_EventID == define.AnLei.Event.BeginPatrol then
		self:DelayCall(0, "RefreshButton")
	elseif oCtrl.m_EventID == define.AnLei.Event.EndPatrol then
		self:DelayCall(0, "RefreshButton")	
	end
end

function CMainMenuLT.OnFieldBossEvent(self, oCtrl)
	if oCtrl.m_EventID == define.FieldBoss.Event.UpadteBossList then
		self:DelayCall(0, "RefreshButton")
	end
end

function CMainMenuLT.OnConvoyEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Convoy.Event.UpdateConvoyInfo then
		self:DelayCall(0, "RefreshButton")
	end
end

function CMainMenuLT.CheckHeroBoxRedDot(self)
	local redDot = g_AttrCtrl:GetSkinRedDot()
	if redDot and #redDot > 0 then
		self.m_HeroBox:AddEffect("RedDot")
	else
		self.m_HeroBox:DelEffect("RedDot")
	end
end

return CMainMenuLT