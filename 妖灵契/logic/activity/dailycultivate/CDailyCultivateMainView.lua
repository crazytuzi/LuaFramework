local CDailyCultivateMainView = class("CDailyCultivateMainView", CViewBase)

function CDailyCultivateMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/dailycultivate/DailyCultivateMainView.prefab", cb)	
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
	self.m_IsAnswer = false
end

function CDailyCultivateMainView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CBox)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_MainTipsLabel = self:NewUI(3, CLabel)
	self.m_CountLabel = self:NewUI(4, CLabel)
	self.m_SubTipsLabel = self:NewUI(5, CLabel)
	self.m_AwardGrid = self:NewUI(6, CGrid)
	self.m_AwardCloneBox = self:NewUI(7, CItemTipsBox)
	self.m_GoBtn = self:NewUI(8, CButton)
	self:InitContent()
end

function CDailyCultivateMainView.InitContent(self)
	self.m_AwardCloneBox:SetActive(false)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnCustomClose"))
	self.m_GoBtn:AddUIEvent("click", callback(self, "OnGo"))
	g_ActivityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlActivityEvent"))
	g_GuideCtrl:AddGuideUI("linlianview_go_btn", self.m_GoBtn)
end

function CDailyCultivateMainView.SetContent(self, sessionidx)
	self.m_Sessionidx = sessionidx
	self:RefreshAll()
end

function CDailyCultivateMainView.RefreshAll(self)
	local d = data.liliandata.DATA[10001]
	if d then
		local str = ""
		if d.main_tips and #d.main_tips > 0 then
			for i, v in ipairs(d.main_tips) do
				str = str..v.."\n"
			end
		end
		self.m_MainTipsLabel:SetText(str)
		self.m_SubTipsLabel:SetText(d.sub_tips)

		local oTask = g_TaskCtrl:GetDailyCultivateTask()
		if oTask then
			local info = oTask:GetValue("lilianinfo")
			if info and info.left_time > 0 then
				self.m_CountLabel:SetText(string.format("%d/50", info.left_time))				
			else
				self.m_CountLabel:SetText(string.format("%d/50", 0))
			end			
		end			

		self.m_AwardGrid:Clear()
		local list = d.reward_list_ui
		for i = 1, #list do
			local sid = nil
			local parId	= nil
			local value = nil
			local str = list[i]
			if string.find(str, "value") then
				sid, value = g_ItemCtrl:SplitSidAndValue(str)
			elseif string.find(str, "partner") then
				sid, parId = g_ItemCtrl:SplitSidAndValue(str)
			else
				sid = tonumber(str)
			end
			local oBox = self.m_AwardCloneBox:Clone()
			oBox:SetActive(true)
			local config = {isLocal = true,}
			oBox:SetItemData(sid, 1, parId, config)
			self.m_AwardGrid:AddChild(oBox)
		end
	end
end

function CDailyCultivateMainView.OnCustomClose(self)
	netother.C2GSCallback(0, 0)
	self.m_IsAnswer = true
	self:CloseView()
end

function CDailyCultivateMainView.OnGo(self)
	if self.m_Sessionidx then
		netother.C2GSCallback(self.m_Sessionidx, 1)
		self.m_IsAnswer = true		
	end
	self:CloseView()
end

function CDailyCultivateMainView.OnCtrlActivityEvent(self, oCtrl)
	-- if oCtrl.m_EventID == define.Activity.Event.DCAddTeam then
	-- 	self:RefreshAll()

	-- elseif oCtrl.m_EventID == define.Activity.Event.DCLeaveTeam then
	-- 	self:CloseView()
	-- 	g_ActivityCtrl:OnEvent(define.Activity.Event.DCUpdateTeam)

	-- elseif oCtrl.m_EventID == define.Activity.Event.DCUpdateTeam then
	-- 	self:RefreshAll()

	-- elseif oCtrl.m_EventID == define.Activity.Event.DCRefreshTask then
	-- 	self:RefeshTask()
	-- end
end

function CDailyCultivateMainView.Destory(self)
	if self.m_IsAnswer ~= true then
		netother.C2GSCallback(0, 0)
	end
	CViewBase.Destory(self)
end

return CDailyCultivateMainView