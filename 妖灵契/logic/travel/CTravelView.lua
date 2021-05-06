local CTravelView = class("CTravelView", CViewBase)

function CTravelView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Travel/TravelView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CTravelView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_TitleLabel = self:NewUI(3, CLabel)
	self.m_TravelHelpBtn = self:NewUI(4, CButton)
	self.m_TravelOtherBox = self:NewUI(5, CTravelOtherBox)
	self.m_TravelGameBox = self:NewUI(6, CTravelGameBox)
	self.m_TravelMoveBox = self:NewUI(7, CTravelMoveBox)
	self.m_TravelLineUpBox = self:NewUI(8, CTravelLineUpBox)
	self.m_BackBtn = self:NewUI(9, CButton)
	self.m_OperateBox = self:NewUI(10, CBox)
	self.m_OperateBox.m_ChuanDuoSpr = self.m_OperateBox:NewUI(1, CSprite)
	self.m_OperateBox.m_OperateSpr = self.m_OperateBox:NewUI(2, CSprite)
	self.m_OperateBox.m_ChuanMaoSpr = self.m_OperateBox:NewUI(3, CSprite)
	self.m_OperateBox.m_TweenRotation = self.m_OperateBox.m_ChuanDuoSpr:GetComponent(classtype.TweenRotation)
	self.m_OperateBox.m_TweenRotation.enabled = false
	self.m_GetRewardTipLabel = self:NewUI(13, CLabel)
	self.m_TravelTimeLabel = self:NewUI(14, CLabel)
	self.m_TravelMoveBox:SetParentView(self)
	self.m_TravelLineUpBox:SetParentView(self)

	self:InitContent()
end

function CTravelView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_TravelHelpBtn:AddHelpTipClick("travel_main")
	self.m_OperateBox:AddUIEvent("click", callback(self, "OnOperateBtn"))
	self.m_BackBtn:AddUIEvent("click", callback(self, "OnBackBtn"))
	g_TravelCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTravelCtrl"))
	
	self:RefreshAll(define.Travel.Type.Mine)
end

function CTravelView.OnBackBtn(self, oBtn)
	if self.m_Type == define.Travel.Type.Friend then
		self:RefreshAll(define.Travel.Type.Mine)
	else
		self:OnClose()
	end
end

function CTravelView.OnOperateBtn(self, oBtn)
	if g_TravelCtrl:IsMainTraveling() or g_TravelCtrl:HasTravelReward() then
		CTravelContentView:ShowView()
	else
		CTravelSelectTimeView:ShowView()
	end
end

function CTravelView.OnTravelCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Travel.Event.Base then
		self:RefreshViewInfo()
	elseif oCtrl.m_EventID == define.Travel.Event.MineItem then
		self.m_TravelOtherBox:Refresh(self.m_Type)
	elseif oCtrl.m_EventID == define.Travel.Event.MineInvite then
		if self.m_Type == define.Travel.Type.Mine then
			self.m_TravelOtherBox:Refresh(self.m_Type)
		end
	elseif oCtrl.m_EventID == define.Travel.Event.Mine2Frd then
		self.m_TravelOtherBox:Refresh(self.m_Type)
	elseif oCtrl.m_EventID == define.Travel.Event.TravelGame then
		self.m_TravelGameBox:Refresh(self.m_Type)
		self.m_TravelOtherBox:Refresh(self.m_Type)
	end
end

function CTravelView.RefreshAll(self, iType)
	self.m_Type = iType
	self:RefreshViewInfo()
	self.m_TravelOtherBox:Refresh(self.m_Type)
	self.m_TravelGameBox:Refresh(self.m_Type)
	self.m_TravelMoveBox:Refresh(self.m_Type)
	self.m_TravelLineUpBox:Refresh(self.m_Type)
end

function CTravelView.RefreshViewInfo(self, iType)
	if self.m_Type == define.Travel.Type.Mine then
		local traveling = g_TravelCtrl:IsMainTraveling()
		local hasreward = g_TravelCtrl:HasTravelReward()
		self.m_GetRewardTipLabel:SetActive(hasreward and not traveling)
		self.m_OperateBox:SetActive(true)
		if not traveling then
			self.m_OperateBox.m_ChuanMaoSpr:SetActive(true)
			self.m_OperateBox.m_TweenRotation.enabled = false
			self.m_OperateBox.m_OperateSpr:SetSpriteName("text_kaishi")
			if hasreward then
				self.m_OperateBox.m_OperateSpr:SetSpriteName("text_lingqujiangli")
			end
		else
			self.m_OperateBox.m_TweenRotation.enabled = true
			self.m_OperateBox.m_ChuanMaoSpr:SetActive(false)
			self.m_OperateBox.m_OperateSpr:SetSpriteName("text_youlizhong")
		end
		self.m_OperateBox.m_OperateSpr:MakePixelPerfect()
		self.m_TravelHelpBtn:SetActive(true)
		self.m_TitleLabel:SetText("我的游历队伍")
		self:RefreshTravelTimeLabel()
		local bHas = g_TravelCtrl:HasMainInvite()
		local frd = g_TravelCtrl:GetFrd2MineParInfo() and 1 or 0
		local color = "#R"
		if frd == 1 then
			color = "#G"
		end
	elseif self.m_Type == define.Travel.Type.Friend then
		self.m_OperateBox:SetActive(false)
		self.m_GetRewardTipLabel:SetActive(false)
		self.m_TravelHelpBtn:SetActive(false)
		self.m_TitleLabel:SetText(g_TravelCtrl:GetFrdName() .. "的游历队伍")
		self:RefreshTravelTimeLabel()
	end
end

function CTravelView.RefreshTravelTimeLabel(self)
	if self.m_Type == define.Travel.Type.Mine then
		local info = g_TravelCtrl:GetMineTravelInfo()
		if info and info.end_time and info.server_time then
			if self.m_TravelTimer then
				Utils.DelTimer(self.m_TravelTimer)
				self.m_TravelTimer = nil
			end
			local time = math.min(info.end_time - g_TimeCtrl:GetTimeS(), info.end_time - info.server_time)
			local sText = "游历剩余时间 %s" 
			local function countdown()
				if Utils.IsNil(self) then
					return 
				end
				if time >= 0 then
					self.m_TravelTimeLabel:SetText(string.format("游历剩余时间 %s", g_TimeCtrl:GetLeftTime(time, true)))
					time = time - 1
					return true
				end
				self.m_TravelTimeLabel:SetText("")
			end
			self.m_TravelTimer = Utils.AddTimer(countdown, 1, 0)
		else
			self.m_TravelTimeLabel:SetText("")
		end
	elseif self.m_Type == define.Travel.Type.Friend then
		local info = g_TravelCtrl:GetFrdTravelInfo().travel_partner
		if info and info.end_time and info.server_time then
			if self.m_TravelTimer then
				Utils.DelTimer(self.m_TravelTimer)
				self.m_TravelTimer = nil
			end
			local time = info.end_time - info.server_time
			local sText = "游历剩余时间 %s" 
			local function countdown()
				if Utils.IsNil(self) then
					return 
				end
				if time >= 0 then
					self.m_TravelTimeLabel:SetText(string.format("游历剩余时间 %s", g_TimeCtrl:GetLeftTime(time, true)))
					time = time - 1
					return true
				end
				self.m_TravelTimeLabel:SetText("")
			end
			self.m_TravelTimer = Utils.AddTimer(countdown, 1, 0)
		else
			self.m_TravelTimeLabel:SetText("")
		end		
	end 
end

function CTravelView.OnExchangeBtn(self, oBtn)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSOpenShop"]) then
		netstore.C2GSOpenShop(define.Store.Page.TravelShop)
	end
end

return CTravelView