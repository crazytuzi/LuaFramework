local CExpandDailyTrainPage = class("CExpandDailyTrainPage", CPageBase)



function CExpandDailyTrainPage.ctor(self, obj)
	CPageBase.ctor(self, obj)

end

function CExpandDailyTrainPage.OnInitPage(self)
	self.m_TiTleLabel = self:NewUI(1, CLabel)
	self.m_DoubleCntLabel = self:NewUI(2, CLabel)
	self.m_GoldLabel = self:NewUI(3, CLabel)
	self.m_ExpLabel = self:NewUI(4, CLabel)
	self.m_RewardGrid = self:NewUI(5, CGrid)
	self.m_RewardBox = self:NewUI(6, CItemTipsBox)
	self.m_DlubleBtn = self:NewUI(7, CButton)
	self.m_LockBtn = self:NewUI(8, CButton)
	self.m_ShowBox = self:NewUI(9, CBox)
	self.m_HideBox = self:NewUI(10, CBox)
	self.m_CloseBtn = self:NewUI(11, CButton)
	self.m_OpenBtn = self:NewUI(12, CButton)
	self.m_NaviLabelMain = self:NewUI(13, CLabel)
	self.m_NaviBtn = self:NewUI(14, CButton)
	self.m_NaviLabelSub = self:NewUI(15, CLabel)
	self.m_DlubleSpr = self:NewUI(16, CSprite)
	self.m_QuitBtn = self:NewUI(17, CButton)

	self.m_ToggleDoubleTime = nil
	self.m_RewardBoxList = {}
	self:InitContent()
end

function CExpandDailyTrainPage.InitContent(self)
	self.m_RewardBox:SetActive(false)
	self.m_DlubleBtn:AddUIEvent("click", callback(self, "OnDluble"))
	self.m_LockBtn:AddUIEvent("click", callback(self, "OnLock"))
	self.m_QuitBtn:AddUIEvent("click", callback(self, "OnQuit"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnSetActive", false, true))
	self.m_OpenBtn:AddUIEvent("click", callback(self, "OnSetActive", true, true))
	self.m_NaviBtn:AddUIEvent("click", callback(self, "OnContinueTrain"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))
	g_ChatCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnChatCtrlEvent"))
	g_ActivityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlActivityEvent"))

	self:RefreshAll(true)
end

function CExpandDailyTrainPage.OnDluble(self)
	if g_ActivityCtrl.m_DTRewardTime == 0 then
		g_NotifyCtrl:FloatMsg(string.format("高级奖励次数已经使用完"))
		return
	end
	local currentTime = g_TimeCtrl:GetTimeS()
	if not self.m_ToggleDoubleTime or currentTime - self.m_ToggleDoubleTime >= 3 then
		self.m_ToggleDoubleTime = currentTime
		g_ActivityCtrl:CtrlC2GSSetTrainReward()
	else
		g_NotifyCtrl:FloatMsg(string.format("操作频繁，请%s秒后再试", 3 - currentTime + self.m_ToggleDoubleTime ))
	end
end

function CExpandDailyTrainPage.OnLock(self)
	g_ActivityCtrl.m_DTAutoConfig = not g_ActivityCtrl.m_DTAutoConfig		
	g_WarCtrl:SetLockPreparePartner(define.War.Type.DailyTrain, g_ActivityCtrl.m_DTAutoConfig)
end

function CExpandDailyTrainPage.OnQuit(self)
	g_ActivityCtrl:CtrlC2GSQuitTrain()
end

function CExpandDailyTrainPage.RefreshAll(self, isStart)
	local isHide = g_ChatCtrl.m_MainMenuChatBoxExpan == nil and true or g_ChatCtrl.m_MainMenuChatBoxExpan
	if isStart then
		self:OnSetActive(true, true)
	else
		--self:OnSetActive(not isHide, false)
	end

	local list = g_ActivityCtrl.m_DTClientNpc
	if list and list[1] then
		self.m_NaviLabelMain:SetText(string.format("[u][00ff00]击败%s", list[1].name))
		self.m_NaviLabelSub:SetText(string.format("(%s/10)", g_ActivityCtrl.m_DTRing))
		local pos = self.m_NaviLabelMain:GetLocalPos()
		local w = self.m_NaviLabelMain:GetWidth()
		self.m_NaviLabelSub:SetLocalPos(Vector3.New(pos.x + w + 2, pos.y, 0))
	end
	local gold = 0			
	local rt = g_ActivityCtrl.m_DTRewardList or {}			
	local list = rt.item or {}
	local exp = rt.exp or 0
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
	self.m_ExpLabel:SetText(string.format("%d", exp))
	self.m_RewardGrid:Reposition()
	self.m_GoldLabel:SetText(string.format("%d", gold))	
	self.m_DoubleCntLabel:SetText(string.format("多倍奖励次数:%d", g_ActivityCtrl:GetDailyTrainTimes()))
	self.m_LockBtn:SetSelected(g_ActivityCtrl.m_DTAutoConfig)
	self.m_DlubleSpr:SetActive(g_ActivityCtrl.m_DTDoubleFlag == 0 and g_ActivityCtrl.m_DTRewardTime ~= 0)
	g_WarCtrl:SetLockPreparePartner(define.War.Type.DailyTrain, g_ActivityCtrl.m_DTAutoConfig)	
end

function CExpandDailyTrainPage.OnCtrlAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:DelayCall(0, "RefreshAll", false)
	end
end

function CExpandDailyTrainPage.OnSetActive(self, b, isClick)	
	self.m_ShowBox:SetActive(b)
	self.m_HideBox:SetActive(not b)
	if isClick == true and b == true then
		local oView = CMainMenuView:GetView()
		if oView and oView.m_LB and oView.m_LB.m_ChatBox then
			oView.m_LB.m_ChatBox:OnPull()
		end
	end
end

function CExpandDailyTrainPage.OnChatCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Chat.Event.ChatBoxExpan then
		local isHide = g_ChatCtrl.m_MainMenuChatBoxExpan == nil and true or g_ChatCtrl.m_MainMenuChatBoxExpan
		if isHide then
			self:OnSetActive(false)
		end
	end
end


function CExpandDailyTrainPage.OnCtrlActivityEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Activity.Event.DTUpdate then
		self:RefreshAll()
	elseif oCtrl.m_EventID == define.Activity.Event.DTUpdateDouble then
		self:UpdateDouble()
	end
end

function CExpandDailyTrainPage.OnContinueTrain(self)
g_ActivityCtrl:StartDailyTrain()
	g_ActivityCtrl:CtrlC2GSContinueTraining()
		
end

function CExpandDailyTrainPage.UpdateDouble(self)
	self.m_DlubleSpr:SetActive(g_ActivityCtrl.m_DTDoubleFlag == 0 and g_ActivityCtrl.m_DTRewardTime ~= 0)
end


return CExpandDailyTrainPage