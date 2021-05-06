local CExpandYwBossPage = class("CExpandYwBossPage", CPageBase)

function CExpandYwBossPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CExpandYwBossPage.OnInitPage(self)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_TipLabel = self:NewUI(3, CLabel)
	self.m_HidePlayerBtn = self:NewUI(4, CButton)
	self.m_AutoWalk = self:NewUI(5, CButton)
	self.m_QuitBtn = self:NewUI(6, CButton)
	self.m_BossNameLabel = self:NewUI(7, CLabel)
	self.m_ShowBox = self:NewUI(8, CBox)
	self.m_HideBox = self:NewUI(9, CBox)
	self.m_CloseBtn = self:NewUI(10, CButton)
	self.m_OpenBtn = self:NewUI(11, CButton)
	self.m_TimeBox = self:NewUI(13, CBox)
	self.m_IconSpr = self:NewUI(14, CSprite)
	self.m_TopIconSpr = self:NewUI(15, CSprite)
	self.m_Slider = self:NewUI(16, CSlider)
	self.m_HPObj = self:NewUI(17, CObject)
	self.m_TimeLabel = self.m_TimeBox:NewUI(1, CLabel)
	self.m_Timer = nil
	self.m_ConditionLabelList = {}
	self:InitContent()
end

function CExpandYwBossPage.InitContent(self)
	self.m_TimeBox:SetActive(false)
	self.m_IconSpr:AddUIEvent("click", callback(self, "OnAuto"))
	self.m_TopIconSpr:AddUIEvent("click", callback(self, "OnAuto"))
	self.m_QuitBtn:AddUIEvent("click", callback(self, "OnQuitFb"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnSetActive", false, true))
	self.m_OpenBtn:AddUIEvent("click", callback(self, "OnSetActive", true, true))
	self.m_HidePlayerBtn:AddUIEvent("click", callback(self, "OnHidePlayer"))
	g_FieldBossCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFieldBossCtrl"))
	g_ChatCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnChatCtrlEvent"))
	self:RefreshAll(true)
end

function CExpandYwBossPage.OnFieldBossCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.FieldBoss.Event.RefreshHP then
		self:RefreshUI()
	end
end

function CExpandYwBossPage.RefreshGrid(self)
	
end

function CExpandYwBossPage.OnHidePlayer(self)
	if self.m_HidePlayerBtn:GetSelected() then
		g_FieldBossCtrl:SetHidePlayer(true)
	else
		g_FieldBossCtrl:SetHidePlayer(false)
	end
end

function CExpandYwBossPage.OnAuto(self)
	local bid = g_FieldBossCtrl:GetBossID()
	local bd, nd = g_FieldBossCtrl:GetBossData(bid)
	if not nd then
		return
	end
	local pos = {
		x = nd.x,
		y = nd.y,
		z = nd.z,
	}
	if g_TeamCtrl:IsInTeam() and not g_TeamCtrl:IsLeader() then
		return
	end
	g_MapTouchCtrl:WalkToPos(pos, nd.id, define.Walker.Npc_Talk_Distance + g_DialogueCtrl:GetTalkDistanceOffset(), function ()
		local npcid = g_MapCtrl:GetNpcIdByNpcType(nd.id)
		local oNpc = g_MapCtrl:GetNpc(npcid)
		if oNpc and oNpc.Trigger then
			oNpc:Trigger()
		end
	end)
end

function CExpandYwBossPage.OnQuitFb(self)
	local args = 
	{
		msg = "确定要离开场景吗？",
		okCallback= function ( )
			nethuodong.C2GSLeaveBattle()
		end,
		cancelCallback = function ()
		end,
		okStr = "是",
		cancelStr = "否",
		countdown = 10,
		forceConfirm = true,
	}
	if g_TeamCtrl:IsInTeam() then
		args = 
		{
			msg = "组队状态下，是否离开场景\n（离开后将暂离队伍）",
			okCallback= function ( )
				nethuodong.C2GSLeaveBattle()
			end,
			cancelCallback = function ()
			end,
			okStr = "是",
			cancelStr = "否",
			countdown = 10,
			forceConfirm = true,
		}
	end
	g_WindowTipCtrl:SetWindowConfirm(args)

end

function CExpandYwBossPage.OnShowPage(self)
	self:RefreshUI()
	self:RefreshAll(true)
end

function CExpandYwBossPage.RefreshUI(self)
	local d = g_FieldBossCtrl:GetUIData()
	if not d then
		return
	end
	self.m_AmountText = string.getstringdark("公会人数：#G"..tostring(d.orgamount))..string.getstringdark("\n#n场景人数：#G"..tostring(d.playercnt))
	self.m_TipLabel:SetText(self.m_AmountText)
	self:UpdateHP()
	self.m_BossNameLabel:SetText(d["bossname"])
	local bid = g_FieldBossCtrl:GetBossID()
	local bd, nd = g_FieldBossCtrl:GetBossData(bid)
	self.m_IconSpr:SpriteAvatar(nd["modelId"])
	self.m_TopIconSpr:SetSpriteName(tostring(nd["modelId"]))
end

function CExpandYwBossPage.UpdateHP(self)
	self.m_TipLabel:SetText(self.m_AmountText)
	local hp, maxhp = g_FieldBossCtrl:GetBossHP()
	if hp and hp > 0 then
		self.m_HPObj:SetActive(true)
		self.m_Slider:SetValue(hp/maxhp)
		local percent = hp/maxhp * 100
		self.m_Slider:SetSliderText(string.format("%d%%", percent))
		self:CloseTimeBox()
	else
		self.m_HPObj:SetActive(false)
		local d = g_FieldBossCtrl:GetUIData()
		if d.reward_endtime > 0 then
			self.m_AmountText = self.m_AmountText or ""
			self.m_TipLabel:SetText(self.m_AmountText.."\n#n神秘宝箱数量："..tostring(d.reward_amount))
			self:ShowTimeBox("结界关闭\n", d.reward_endtime)
		else
			if self.m_TimeTimer then
				return
			end
			self.m_TipLabel:SetText(self.m_AmountText.."\n#n神秘宝即将出现")
			self:ShowTimeBox("宝箱刷新\n", g_TimeCtrl:GetTimeS() + 30)
		end
	end
end

function CExpandYwBossPage.ShowTimeBox(self, str, iTime)
	self.m_EndTime = iTime
	self.m_TimeStr = str
	if not self.m_TimeTimer then
		self.m_TimeTimer = Utils.AddTimer(callback(self, "OnTimeUpdate"), 0.1, 0)
	end
	self.m_TimeBox:SetActive(true)
end

function CExpandYwBossPage.OnTimeUpdate(self)
	local seconds = self.m_EndTime - g_TimeCtrl:GetTimeS()
	self.m_TimeLabel:SetText(self.m_TimeStr..g_TimeCtrl:GetLeftTime(seconds))
	if seconds >= 0 then
		return true
	else
		self:CloseTimeBox()
		return false
	end
end

function CExpandYwBossPage.CloseTimeBox(self)
	self.m_TimeBox:SetActive(false)
	if self.m_TimeTimer ~= nil then
		Utils.DelTimer(self.m_TimeTimer)
		self.m_TimeTimer = nil
	end
end

function CExpandYwBossPage.RefreshAll(self, isStart)
	local isHide = g_ChatCtrl.m_MainMenuChatBoxExpan == nil and true or g_ChatCtrl.m_MainMenuChatBoxExpan
	if isStart then
		self:OnSetActive(true, true)
	else
		self:OnSetActive(not isHide, false)
	end
end

function CExpandYwBossPage.Destroy(self)
	if self.m_Timer ~= nil then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	CPageBase.Destroy(self)
end

function CExpandYwBossPage.OnSetActive(self, b, isClick)	
	self.m_ShowBox:SetActive(b)
	self.m_HideBox:SetActive(not b)
	if isClick == true and b == true then
		local oView = CMainMenuView:GetView()
		if oView and oView.m_LB and oView.m_LB.m_ChatBox then
			oView.m_LB.m_ChatBox:OnPull()
		end
	end	
end

function CExpandYwBossPage.OnChatCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Chat.Event.ChatBoxExpan then
		local isHide = g_ChatCtrl.m_MainMenuChatBoxExpan == nil and true or g_ChatCtrl.m_MainMenuChatBoxExpan
		if isHide then
			self:OnSetActive(false)
		end
	end
end

return CExpandYwBossPage