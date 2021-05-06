local CExpandEquipFbPage = class("CExpandEquipFbPage", CPageBase)



function CExpandEquipFbPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CExpandEquipFbPage.OnInitPage(self)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_TimeLabel = self:NewUI(2, CLabel)
	self.m_ConditionGrid = self:NewUI(3, CGrid)
	self.m_TipsLabel = self:NewUI(4, CLabel)
	self.m_AutoFightBtn = self:NewUI(5, CBox)
	self.m_AutoFightLabel = self:NewUI(6, CLabel)
	self.m_QuitBtn = self:NewUI(7, CButton)
	self.m_QuitLabel = self:NewUI(8, CLabel)
	self.m_ShowBox = self:NewUI(9, CBox)
	self.m_HideBox = self:NewUI(10, CBox)
	self.m_CloseBtn = self:NewUI(11, CButton)
	self.m_OpenBtn = self:NewUI(12, CButton)
	self.m_AutoFightLockSpr = self:NewUI(13, CSprite)
	self.m_QuitLockSpr = self:NewUI(14, CSprite)

	self.m_DoingTimer = nil
	self.m_ConditionLabelList = {}

	self:InitContent()
end

function CExpandEquipFbPage.InitContent(self)
	self.m_AutoFightBtn:AddUIEvent("click", callback(self, "OnAuto"))
	self.m_QuitBtn:AddUIEvent("click", callback(self, "OnQuitFb"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnSetActive", false, true))
	self.m_OpenBtn:AddUIEvent("click", callback(self, "OnSetActive", true, true))	
	g_EquipFubenCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEquipFubenEvent"))
	g_ChatCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnChatCtrlEvent"))
	self.m_ConditionLabelList = {}
	self.m_ConditionGrid:InitChild(function(obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_Index = idx
		oBox.m_Label = oBox:NewUI(1, CLabel)
		oBox.m_StarSprite = oBox:NewUI(2, CSprite)
		self.m_ConditionLabelList[idx] = oBox
		return oBox
	end)
	self:RefreshAll()
	--g_GuideCtrl:AddGuideUI("equipfuben_auto_btn", self.m_AutoFightBtn)
end

function CExpandEquipFbPage.OnAuto(self)
	--if g_EquipFubenCtrl:CanAutoFuben() or not g_GuideCtrl:IsCompleteEquipTipsGuide() then
	if g_EquipFubenCtrl:CanAutoFuben() then
		g_EquipFubenCtrl:CtrlC2GSSetAutoEquipFuBen()
	else	
		
		g_NotifyCtrl:FloatMsg("未通关此层无法自动副本")
	end
end

function CExpandEquipFbPage.OnQuitFb(self)
	local args = 
	{
		msg = "要退出装备副本么？（未通关不会获得装备）",
		okCallback= function ( )	
			g_EquipFubenCtrl:CtrlC2GSGooutEquipFB()			
			-- if g_GuideCtrl:IsCompleteEquipTipsGuide() then
			-- 	g_EquipFubenCtrl:CtrlC2GSGooutEquipFB()	
			-- 	g_EquipFubenCtrl:CtrlC2GSOpenEquipFBMain()
			-- else
			-- 	g_EquipFubenCtrl:CtrlC2GSGooutEquipFB()	
			-- 	g_GuideCtrl:SetEquipFbQuitGuide()	
			-- end			
		end,
		cancelCallback = function ()
		end,
		okStr = "是",
		cancelStr = "否",
		countdown = 10,
		forceConfirm = true,
	}
	g_WindowTipCtrl:SetWindowConfirm(args)

end

function CExpandEquipFbPage.OnCtrlEquipFubenEvent(self, oCtrl)
	if oCtrl.m_EventID == define.EquipFb.Event.BeginFb then		
		self:RefreshAll(true)

	elseif oCtrl.m_EventID == define.EquipFb.Event.EndFb then
		if self.m_DoingTimer ~= nil then
			Utils.DelTimer(self.m_DoingTimer)
			self.m_DoingTimer = nil
		end

	elseif oCtrl.m_EventID == define.EquipFb.Event.UpdateInfo then
		self:RefreshAll()

	end
end

function CExpandEquipFbPage.OnShowPage(self)

end

function CExpandEquipFbPage.RefreshAll(self, isStart)
	if g_EquipFubenCtrl:IsInEquipFB() then
		local isHide = g_ChatCtrl.m_MainMenuChatBoxExpan == nil and true or g_ChatCtrl.m_MainMenuChatBoxExpan
		if isStart == true then
			self:OnSetActive(true, true)
		else
			self:OnSetActive(not isHide, false)
		end
		local d = g_EquipFubenCtrl:GetCurFubenInfo()
		local condition = g_EquipFubenCtrl:GetPassCondition()

		self.m_TitleLabel:SetText(string.format("%s·%s层", d.fubenInfo.type, g_EquipFubenCtrl:CountConvert(d.floorInfo.id % 1000)))
		local passTimeStr, passTime = g_EquipFubenCtrl:GetDoingTimeStr()
		local fbTime = g_EquipFubenCtrl:GetFubenTime()
		if passTime > fbTime then
			self.m_TimeLabel:SetText(string.format("[FAE7B9]副本时间:#R%s", passTimeStr))
		else
			self.m_TimeLabel:SetText(string.format("[FAE7B9]副本时间:%s", passTimeStr))
		end	
		if g_EquipFubenCtrl:GetDoingTime() ~= "" then
			if self.m_DoingTimer ~= nil then
				Utils.DelTimer(self.m_DoingTimer)
				self.m_DoingTimer = nil
			end
			local function timetUpdate()
				local passTimeStr, passTime = g_EquipFubenCtrl:GetDoingTimeStr()
				if passTimeStr ~= "" then
					if not Utils.IsNil(self.m_TimeLabel) then
						if passTime > fbTime then
							self.m_TimeLabel:SetText(string.format("[FAE7B9]副本时间:#R%s", passTimeStr))
						else
							self.m_TimeLabel:SetText(string.format("[FAE7B9]副本时间:%s", passTimeStr))
						end						
					end					
					return true				
				end				
			end  

			self.m_DoingTimer = Utils.AddTimer(timetUpdate, 1, 0)
		end
		self.m_AutoFightBtn:SetGrey(not g_EquipFubenCtrl:CanAutoFuben() )
		self.m_AutoFightLockSpr:SetActive(not g_EquipFubenCtrl:CanAutoFuben())
		-- self.m_AutoFightBtn:SetGrey(not g_EquipFubenCtrl:CanAutoFuben() and g_GuideCtrl:IsCompleteEquipTipsGuide())
		-- self.m_AutoFightLockSpr:SetActive(not g_EquipFubenCtrl:CanAutoFuben() and g_GuideCtrl:IsCompleteEquipTipsGuide())
		self.m_QuitLockSpr:SetActive(false)
		self:RefreshState()
	end
end

function CExpandEquipFbPage.Destroy(self)
	if self.m_DoingTimer ~= nil then
		Utils.DelTimer(self.m_DoingTimer)
		self.m_DoingTimer = nil
	end
	CPageBase.Destroy(self)
end

function CExpandEquipFbPage.RefreshState(self)

	local d = g_EquipFubenCtrl:GetCurFubenInfo()
	local condition = g_EquipFubenCtrl:GetPassCondition()

	for i = 1, #self.m_ConditionLabelList do
		local str = ""
		if i == 3 then
			str = string.format("%s%s", g_EquipFubenCtrl:GetFubenTimeStr(), CEquipFubenCtrl.ConditionText[i])
		else
			str = CEquipFubenCtrl.ConditionText[i]
		end
		if condition[i] then
			self.m_ConditionLabelList[i].m_Label:SetText(string.format("[FAE7B9]%s", str))
			self.m_ConditionLabelList[i].m_StarSprite:SetActive(true)
		else
			if i ~= 1 then
				self.m_ConditionLabelList[i].m_Label:SetText(string.format("#R%s (失败)",str))				
				self.m_ConditionLabelList[i].m_StarSprite:SetActive(false)
			else
				--击败Boss不会显示失败
				self.m_ConditionLabelList[i].m_StarSprite:SetActive(true)
				self.m_ConditionLabelList[i].m_Label:SetText(string.format("[FAE7B9]%s",str))			
			end			
		end
	end

	if d.data.auto == true then
		self.m_AutoFightLabel:SetText(string.format("取消自动"))
	else
		self.m_AutoFightLabel:SetText(string.format("自动战斗"))
	end
end

function CExpandEquipFbPage.OnSetActive(self, b, isClick)	
	self.m_ShowBox:SetActive(b)
	self.m_HideBox:SetActive(not b)	
	if isClick == true and b == true then
		local oView = CMainMenuView:GetView()
		if oView and oView.m_LB and oView.m_LB.m_ChatBox then
			oView.m_LB.m_ChatBox:OnPull()
		end
	end
end

function CExpandEquipFbPage.OnChatCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Chat.Event.ChatBoxExpan then
		local isHide = g_ChatCtrl.m_MainMenuChatBoxExpan == nil and true or g_ChatCtrl.m_MainMenuChatBoxExpan
		if isHide then
			self:OnSetActive(false)
		end
	end
end

return CExpandEquipFbPage