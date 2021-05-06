local CDailyCultivateView = class("CDailyCultivateView", CViewBase)

function CDailyCultivateView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/dailycultivate/DailyCultivateView.prefab", cb)	
end


function CDailyCultivateView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CBox)
	self.m_Content = self:NewUI(2, CBox)
	self.m_BottomGroup = self:NewUI(3, CBox)
	self.m_MemberGrid = self:NewUI(4, CGrid)
	self.m_MemberCloneBox = self:NewUI(5, CBox)
	self.m_ProgressLabel = self:NewUI(6, CLabel)
	self.m_LockBtn = self:NewUI(7, CButton)
	self.m_LockSprite = self:NewUI(8, CSprite)
	self.m_LeaveBtn = self:NewUI(9, CButton)
	self.m_ToggleBtn = self:NewUI(10, CButton)
	self.m_ToggleFlag = self:NewUI(11, CSprite)
	self.m_ToggleLabel = self:NewUI(12, CLabel)

	self.m_IsToggle = true
	self.m_OpenTimer = nil
	self.m_MemberList = nil
	self.m_MemberBoxList = {}

	self:InitContent()
end

function CDailyCultivateView.InitContent(self)
	self.m_MemberCloneBox:SetActive(false)
	self.m_Container:SetActive(false)
	self.m_LockBtn:AddUIEvent("click", callback(self, "OnLock"))
	self.m_LeaveBtn:AddUIEvent("click", callback(self, "OnLeave"))
	self.m_ToggleBtn:AddUIEvent("click", callback(self, "OnToggle"))

	g_ActivityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlActivityEvent"))

	self.m_LockBtn:SetSelected(g_ActivityCtrl.m_AutoConfig)
	g_ActivityCtrl.m_IsOpenDCView = true
	self:RefreshAll()
end

function CDailyCultivateView.OnLock(self)
	g_ActivityCtrl.m_AutoConfig = not g_ActivityCtrl.m_AutoConfig		
	g_WarCtrl:SetLockPreparePartner(define.War.Type.Lilian, g_ActivityCtrl.m_AutoConfig)
end

function CDailyCultivateView.OnLeave(self)
	g_ActivityCtrl:DailyCultivateLeavelTeam()
end

function CDailyCultivateView.OnToggle(self)
	g_ActivityCtrl.m_IsOpenDCView = false
	self:CloseView()
	-- self.m_IsToggle = not self.m_IsToggle
	-- self:RefreshUIMode(self.m_IsToggle)

end

function CDailyCultivateView.OnCtrlActivityEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Activity.Event.DCAddTeam then
		self:RefreshAll()

	elseif oCtrl.m_EventID == define.Activity.Event.DCLeaveTeam then
		self:CloseView()
		g_ActivityCtrl:OnEvent(define.Activity.Event.DCUpdateTeam)

	elseif oCtrl.m_EventID == define.Activity.Event.DCUpdateTeam then
		self:RefreshAll()

	elseif oCtrl.m_EventID == define.Activity.Event.DCRefreshTask then
		self:RefeshTask()
	end
end

function CDailyCultivateView.RefreshAll(self)
	if not g_ActivityCtrl:IsDailyCultivating() or g_WarCtrl:IsWar() then
		return
	end
	self.m_Container:SetActive(true)
	self:RefeshTask()

	self.m_MemberList = g_ActivityCtrl:GetDailyCultivateMemberList()
	if self.m_MemberList and next(self.m_MemberList) then
		for i = 1, 4 do
			local oBox = self.m_MemberBoxList[i]
			if not oBox then
				oBox = self.m_MemberCloneBox:Clone()
				oBox.m_IconSprite = oBox:NewUI(1, CSprite)
				oBox.m_NameLabel = oBox:NewUI(2, CLabel)
				oBox.m_GradeLabel = oBox:NewUI(3, CLabel)
				self.m_MemberGrid:AddChild(oBox)
				table.insert(self.m_MemberBoxList, oBox)
			end
			if i > #self.m_MemberList then
				oBox:SetActive(false)			
			else
				local d = self.m_MemberList[i]
				oBox:SetActive(true)
				oBox.m_IconSprite:SpriteAvatar(d.status_info.model_info.shape)
				oBox.m_NameLabel:SetText(d.status_info.name)
				oBox.m_GradeLabel:SetText(string.format("%d", d.status_info.grade))
			end
		end
		self.m_MemberGrid:Reposition()
	else
		for i = 1, 4 do
			local oBox = self.m_MemberBoxList[i]
			if oBox then
				oBox:SetActive(false)
			end
		end
	end
	--self:RefreshUIMode(self.m_IsToggle)
	
end

function CDailyCultivateView.RefreshUIMode(self, isOpen)
	if self.m_OpenTimer ~= nil then
		Utils.DelTimer(self.m_OpenTimer)
		self.m_OpenTimer = nil
	end
	if isOpen then
		self.m_ToggleLabel:SetText("收起")
		self.m_Container:SetHeight(310)
		local function wrap() 
			self.m_Content:SetActive(true)
			self.m_BottomGroup:SetActive(true)
		end 
		self.m_OpenTimer = Utils.AddTimer(wrap, 0, 0.1)
	else
		self.m_Content:SetActive(isOpen)
		self.m_BottomGroup:SetActive(isOpen)
		self.m_ToggleLabel:SetText("打开")
		self.m_Container:SetHeight(80)
	end

end

function CDailyCultivateView.RefeshTask(self)
	local oTask = g_TaskCtrl:GetDailyCultivateTask()
	if oTask and oTask:GetValue("lilianinfo") then
		local info = oTask:GetValue("lilianinfo")
		self.m_ProgressLabel:SetText(string.format("还可以完成%d次", info.left_time))
	end
end

function CDailyCultivateView.LoadDone(self)
	if not g_ActivityCtrl:IsDailyCultivating() or g_WarCtrl:IsWar() then
		self:CloseView()
	end
end

function CDailyCultivateView.Destroy(self)
	if self.m_OpenTimer ~= nil then
		Utils.DelTimer(self.m_OpenTimer)
		self.m_OpenTimer = nil
	end	
	CViewBase.Destroy(self)
end

return CDailyCultivateView