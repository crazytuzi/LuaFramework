local CExpandLilianPage = class("CExpandLilianPage", CPageBase)



function CExpandLilianPage.ctor(self, obj)
	CPageBase.ctor(self, obj)

end

function CExpandLilianPage.OnInitPage(self)
	self.m_TiTleLabel = self:NewUI(1, CLabel)
	self.m_TimeLabel = self:NewUI(2, CLabel)
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

function CExpandLilianPage.InitContent(self)
	self.m_RewardBox:SetActive(false)
	self.m_QuitBtn:AddUIEvent("click", callback(self, "OnQuit"))
	self.m_LockBtn:AddUIEvent("click", callback(self, "OnLock"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnSetActive", false, true))
	self.m_OpenBtn:AddUIEvent("click", callback(self, "OnSetActive", true, true))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))
	g_ChatCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnChatCtrlEvent"))
	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlTaskEvent"))
	g_ActivityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlActivityEvent"))

	self:RefreshAll(true)
end

function CExpandLilianPage.OnQuit(self)
	g_ActivityCtrl:DailyCultivateLeavelTeam()
end

function CExpandLilianPage.OnLock(self)
	g_ActivityCtrl.m_AutoConfig = not g_ActivityCtrl.m_AutoConfig		
	g_WarCtrl:SetLockPreparePartner(define.War.Type.Lilian, g_ActivityCtrl.m_AutoConfig)
end

function CExpandLilianPage.RefreshAll(self, isStart)
	local isQuit = true
	local isHide = g_ChatCtrl.m_MainMenuChatBoxExpan == nil and true or g_ChatCtrl.m_MainMenuChatBoxExpan
	if isStart then
		self:OnSetActive(true, true)
	else
		self:OnSetActive(not isHide, false)
	end
	
	local oTask = g_TaskCtrl:GetDailyCultivateTask()
	if oTask and g_ActivityCtrl:IsActivityVisibleBlock("lilian") then
		local info = oTask:GetValue("lilianinfo")
		if info then
			isQuit = false
			local gold = 0			
			self.m_TimeLabel:SetText(string.format("修行次数：%d",info.left_time))
			local rt = info.reward_info or {}			
			local list = rt.item or {}
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
			self.m_LockBtn:SetSelected(g_ActivityCtrl.m_AutoConfig)
			g_WarCtrl:SetLockPreparePartner(define.War.Type.Lilian, g_ActivityCtrl.m_AutoConfig)	
		end			
	end	

	if isQuit and g_ActivityCtrl:IsDailyCultivating() then 
		g_ActivityCtrl:DailyCultivateLeavelTeam()
	end
end


function CExpandLilianPage.OnCtrlAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:DelayCall(0, "RefreshAll")
	end
end

function CExpandLilianPage.OnSetActive(self, b, isClick)	
	self.m_ShowBox:SetActive(b)
	self.m_HideBox:SetActive(not b)
	if isClick == true and b == true then
		local oView = CMainMenuView:GetView()
		if oView and oView.m_LB and oView.m_LB.m_ChatBox then
			oView.m_LB.m_ChatBox:OnPull()
		end
	end
end

function CExpandLilianPage.OnChatCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Chat.Event.ChatBoxExpan then
		local isHide = g_ChatCtrl.m_MainMenuChatBoxExpan == nil and true or g_ChatCtrl.m_MainMenuChatBoxExpan
		if isHide then
			self:OnSetActive(false)
		end
	end
end

function CExpandLilianPage.OnCtrlTaskEvent(self, oCtrl)
	if define.Task.Event.RefreshAllTaskBox or define.Task.Event.RefreshSpecificTaskBox then
		self:DelayCall(0, "RefreshAll")			
	end
end

function CExpandLilianPage.OnCtrlActivityEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Activity.Event.DCAddTeam then
		self:RefreshAll(true)
	end
end


return CExpandLilianPage