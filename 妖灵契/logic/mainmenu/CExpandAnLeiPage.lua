local CExpandAnLeiPage = class("CExpandAnLeiPage", CPageBase)



function CExpandAnLeiPage.ctor(self, obj)
	CPageBase.ctor(self, obj)

end

function CExpandAnLeiPage.OnInitPage(self)
	self.m_TiTleLabel = self:NewUI(1, CLabel)
	self.m_AnLeiPointLabel = self:NewUI(2, CLabel)
	self.m_GoldLabel = self:NewUI(3, CLabel)
	self.m_ExpLabel = self:NewUI(4, CLabel)
	self.m_RewardGrid = self:NewUI(5, CGrid)
	self.m_RewardBox = self:NewUI(6, CItemTipsBox)
	self.m_QuitBtn = self:NewUI(7, CButton)
	self.m_LockBtn = self:NewUI(8, CButton)
	self.m_ShowBox = self:NewUI(9, CBox)
	self.m_HideBox = self:NewUI(10, CBox)
	self.m_CloseBtn = self:NewUI(11, CButton)
	self.m_OpenBtn = self:NewUI(12, CButton)

	self.m_RewardBoxList = {}
	self:InitContent()
end

function CExpandAnLeiPage.InitContent(self)
	self.m_RewardBox:SetActive(false)
	self.m_QuitBtn:AddUIEvent("click", callback(self, "OnQuit"))
	self.m_LockBtn:AddUIEvent("click", callback(self, "OnLock"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnSetActive", false, true))
	self.m_OpenBtn:AddUIEvent("click", callback(self, "OnSetActive", true, true))
	g_AnLeiCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAnLeilEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlMapEvent"))
	g_ChatCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnChatCtrlEvent"))

	local config = g_AnLeiCtrl:GetConfig()
	if config then
		self.m_TiTleLabel:SetText(config.name)
	end

	self:RefreshAll(true)
end

function CExpandAnLeiPage.OnQuit(self)
	g_AnLeiCtrl:CtrlC2GSCancelTrapmine()
end

function CExpandAnLeiPage.OnLock(self)
	if g_AnLeiCtrl.m_AutoLock == true then
		g_AnLeiCtrl.m_AutoLock = false
	else
		g_AnLeiCtrl.m_AutoLock = true
	end
	self.m_LockBtn:SetSelected(g_AnLeiCtrl.m_AutoLock)
	g_WarCtrl:SetLockPreparePartner(define.War.Type.AnLei, g_AnLeiCtrl.m_AutoLock)
end

function CExpandAnLeiPage.RefreshAll(self, isStart)
	local isHide = g_ChatCtrl.m_MainMenuChatBoxExpan == nil and true or g_ChatCtrl.m_MainMenuChatBoxExpan
	if isStart then
		self:OnSetActive(true, true)
	else
		self:OnSetActive(not isHide, false)
	end
	local gold = 0
	self.m_AnLeiPointLabel:SetText(string.format("探索点：%d/%d", g_AttrCtrl.trapmine_point, CAnLeiCtrl.AnLeiPointMax))
	local list = g_AnLeiCtrl.m_ItemList
	for i = 1, #self.m_RewardBoxList do
		local oBox = self.m_RewardBoxList[i]
		if oBox then
			oBox:SetActive(false)
		end
	end
	local boxIdx = 1
	for i = 1, #list do 
		if list[i].sid then
			--金币id
			if list[i].sid ~= tonumber(data.globaldata.GLOBAL.attr_coin_itemid.value) then
				local oBox = self.m_RewardBoxList[boxIdx]
				if not oBox then
					oBox = self.m_RewardBox:Clone()				
					self.m_RewardGrid:AddChild(oBox)
					table.insert(self.m_RewardBoxList, oBox)
				end
				oBox:SetActive(true)
				local config = {isLocal = true,}
				if list[i].virtual ~= 1010 then
					oBox:SetItemData(list[i].sid, list[i].amount, nil ,config)	
				else
					oBox:SetItemData(list[i].virtual, list[i].amount, list[i].sid ,config)						
				end
				oBox.m_CountLabel:SetActive(true)
				oBox.m_CountLabel:SetText(string.format("x%d", list[i].amount))
				boxIdx = boxIdx + 1
			else
				gold = list[i].amount
			end							
		end		
	end	
	self.m_RewardGrid:Reposition()
	self.m_GoldLabel:SetText(string.format("%d", gold))			
	self.m_LockBtn:SetSelected(g_AnLeiCtrl.m_AutoLock)
	if g_AnLeiCtrl:IsInAnLei() then
		g_WarCtrl:SetLockPreparePartner(define.War.Type.AnLei, g_AnLeiCtrl.m_AutoLock)
	else
		g_WarCtrl:SetLockPreparePartner(define.War.Type.AnLei, false)
	end		
end

function CExpandAnLeiPage.OnCtrlAnLeilEvent( self, oCtrl)
	if oCtrl.m_EventID == define.AnLei.Event.UpdateInfo then
		self:RefreshAll()
	elseif oCtrl.m_EventID == define.AnLei.Event.BeginPatrol then
		self:RefreshAll(true)
	end
end

function CExpandAnLeiPage.OnCtrlAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshAll()
	end
end

function CExpandAnLeiPage.OnCtrlMapEvent(self, oCtrl)	
	if oCtrl.m_EventID == define.Map.Event.HeroLoadDone then
		if g_AnLeiCtrl:IsInAnLei() then
			if not g_TeamCtrl:IsJoinTeam() or g_TeamCtrl:IsLeader() then
				g_AnLeiCtrl:CtrlC2GSStartTrapmine()
			end
			g_AnLeiCtrl:StartPatrol()
		end
	end		
end

function CExpandAnLeiPage.OnSetActive(self, b, isClick)	
	self.m_ShowBox:SetActive(b)
	self.m_HideBox:SetActive(not b)
	if isClick == true and b == true then
		local oView = CMainMenuView:GetView()
		if oView and oView.m_LB and oView.m_LB.m_ChatBox then
			oView.m_LB.m_ChatBox:OnPull()
		end
	end
end

function CExpandAnLeiPage.OnChatCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Chat.Event.ChatBoxExpan then
		local isHide = g_ChatCtrl.m_MainMenuChatBoxExpan == nil and true or g_ChatCtrl.m_MainMenuChatBoxExpan
		if isHide then
			self:OnSetActive(false)
		end
	end
end

return CExpandAnLeiPage