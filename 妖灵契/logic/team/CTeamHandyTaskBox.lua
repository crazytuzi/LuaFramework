local CTeamHandyTaskBox = class("CTeamHandyTaskBox", CBox)

function CTeamHandyTaskBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ButtonBg = self:NewUI(1, CSprite)
	self.m_TaskBtn = self:NewUI(2, CButton, true ,false)
	self.m_BtnGrid = self:NewUI(3, CGrid)
	self.m_CloneBtn = self:NewUI(4, CBox)
	self.m_ArrowSpr = self:NewUI(5, CSprite)
	self.m_SelectedSpr = self:NewUI(6, CSprite)
	self.m_TaskNameLabel = self:NewUI(7, CLabel)
	self.m_StatusSpr = self:NewUI(8, CSprite)
	self.m_SubNameLabel = self:NewUI(9, CLabel)

	self.m_IsInit = true
	self.m_SelectedId = -1
	self.m_Callback = nil
	self.m_AutoteamData = nil
	self.m_IsExpand = false
	self.m_SubStatusSpr = nil
	self.m_SubMenus = {}
	self:BindButtonEvent()
	self.m_SubAutoteamData = {}
	self.m_TweenHeight = self.m_ButtonBg:GetComponent(classtype.TweenHeight)
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CTeamHandyTaskBox.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.NotifyCountAutoMatch or
		oCtrl.m_EventID == define.Team.Event.NotifyAutoMatch then
		if self.m_IsInit then
			return
		end
		self:RefreshAutoStatus()
		self:RefreshTaskName()
	end
end

function CTeamHandyTaskBox.BindButtonEvent(self)
	self.m_TaskBtn:AddUIEvent("click", callback(self, "OnClickTask"))
end

-- 初始化数据
function CTeamHandyTaskBox.SetAutoTeamData(self, data)
	self.m_AutoteamData = data
	if data.is_parent == 1 then
		self.m_SubAutoteamData = g_TeamCtrl:GetSubAutoteamData(data.id,  g_AttrCtrl.grade)
	end
	self:RefreshUI()
	self.m_IsInit = false
end

-- 设置监听器
function CTeamHandyTaskBox.SetListener(self, cb)
	self.m_Callback = cb
end

-- 初始化选定状态
function CTeamHandyTaskBox.InitSelected(self, taskId)
	local isSelected = false
	local selectedId = -1
	if self.m_AutoteamData.id == taskId then
		isSelected = true
		selectedId = taskId
	else
		local btn = self:InitSubSelected(taskId)
		if btn then
			isSelected = true
			selectedId = taskId

			-- self:ExpandSubMenu()
			-- self:InitSubSelectedDelay()
		end
	end
	self:SetSelected(isSelected)
	if selectedId ~= -1 then
		self:SetSelectedId(selectedId)
	end
	self:RefreshTaskName()
end

function CTeamHandyTaskBox.InitSubSelected(self, taskId)
	local btn = self.m_SubMenus[taskId]
	if btn then
		self:SetSelected(false)
		btn:SetSelected(true)
	end
	return btn
end

function CTeamHandyTaskBox.InitSubSelectedDelay(self)
	local function func()
		self:InitSubSelected(self.m_SelectedId)
		Utils.DelTimer(self.m_Timer)
	end
	self.m_Timer = Utils.AddTimer(func, 0, 0.1)
end

-- 执行UI刷新
function CTeamHandyTaskBox.RefreshUI(self)
	-- self:SetSelected(false)
	self:RefreshTaskButton()
	self:RefreshAutoStatus()
end

function CTeamHandyTaskBox.RefreshTaskName(self)
	self.m_TaskNameLabel:SetText(self.m_AutoteamData.name)
	self.m_SubNameLabel:SetActive(false)
	local pos = nil
	local iTaskId = g_TeamCtrl:GetPlayerAutoTarget()
	local bIsAutoMatch = self.m_AutoteamData.id == iTaskId or self.m_SubMenus[iTaskId]

	if self.m_SelectedId ~= -1 and self.m_AutoteamData.id ~= self.m_SelectedId and
	   not self.m_IsExpand and bIsAutoMatch then
		local taskData = data.teamdata.AUTO_TEAM[self.m_SelectedId]
		self.m_SubNameLabel:SetText(taskData.name)
		self.m_SubNameLabel:SetActive(true)
		pos = self.m_SubNameLabel:GetLocalPos()
		pos.y = -15
		self.m_SubNameLabel:SetLocalPos(pos)
		pos = self.m_TaskNameLabel:GetLocalPos()
		pos.y = 15
		self.m_TaskNameLabel:SetLocalPos(pos)
	else
		pos = self.m_TaskNameLabel:GetLocalPos()
		pos.y = 0
		if self.m_AutoteamData.is_parent == 0 then
			pos.x = 0 
		end
		self.m_TaskNameLabel:SetLocalPos(pos)
	end
end

function CTeamHandyTaskBox.RefreshTaskButton(self)
	if self.m_AutoteamData.is_parent == 0 or next(self.m_SubAutoteamData) == nil then
		self.m_ArrowSpr:SetActive(false)
		self.m_ButtonBg:SetParent(nil)
		self.m_ButtonBg:Destroy()
	else
		self:CreateSubTaskButton()
		self.m_ArrowSpr:SetActive(true)
	end
	self.m_TaskNameLabel:SetText(self.m_AutoteamData.name)
end


function CTeamHandyTaskBox.RefreshAutoStatus(self)
	self.m_StatusSpr:SetActive(false)
	if self.m_SubStatusSpr then
		self.m_SubStatusSpr:SetActive(false)
	end

	local iTaskId = g_TeamCtrl:GetPlayerAutoTarget()

	if (self.m_AutoteamData.id == iTaskId or self.m_SubMenus[iTaskId])
		 and g_TeamCtrl:IsPlayerAutoMatch() then
		if self.m_IsExpand then
			local btn = self.m_SubMenus[iTaskId]
			btn.m_StatusSpr:SetActive(true)
			self.m_SubStatusSpr = btn.m_StatusSpr
		else
			self.m_StatusSpr:SetActive(true)
		end
	end
end

function CTeamHandyTaskBox.CreateSubTaskButton(self)
	local count = 0

	for k,data in pairs(self.m_SubAutoteamData) do
		local button = self.m_CloneBtn:Clone(false)
		button.m_StatusSpr = button:NewUI(1, CSprite)
		button.m_BtnLabel = button:NewUI(2, CLabel)
		button:SetName(tostring(data.id))
		button.m_BtnLabel:SetText(data.name)
		local callback = function()
			self:SetSelectedId(data.id)
		end
		button:AddUIEvent("click", callback)
		self.m_BtnGrid:AddChild(button)
		self.m_SubMenus[data.id] = button
		count = count + 1
	end

	local _, h = self.m_CloneBtn:GetSize()
	self.m_TweenHeight.to = (count + 0.5) * h + 15

	self.m_BtnGrid:RemoveChild(self.m_CloneBtn)
end

function CTeamHandyTaskBox.SetSelected(self, isSelected)
	self.m_TaskBtn:SetSelected(isSelected)
	local iTaskId = g_TeamCtrl:GetPlayerAutoTarget()
	local bIsAutoMatch = self.m_AutoteamData.id == iTaskId or self.m_SubMenus[iTaskId]

	if not isSelected and not bIsAutoMatch then
		local oSubMenu = self.m_SubMenus[self.m_SelectedId]
		if oSubMenu then
			oSubMenu:SetSelected(false)
		end
		self.m_SelectedId = self.m_AutoteamData.id
	end
end

function CTeamHandyTaskBox.SetSelectedId(self, taskId)
	self.m_SelectedId = taskId
	if self.m_Callback then
		self.m_Callback(self)
	end
end

function CTeamHandyTaskBox.GetSelectedId(self)
	return self.m_SelectedId
end

function CTeamHandyTaskBox.OnClickTask(self)
	if self.m_AutoteamData.is_parent == 0 then
		self:SetSelected(true)
		self:SetSelectedId(self.m_AutoteamData.id)
	else
		self.m_IsExpand = not self.m_IsExpand
		self:RefreshTaskName()
		if self.m_IsExpand then
			self:InitSubSelectedDelay()
			if self.m_SelectedId ~= -1 then
				self:SetSelectedId(self.m_SelectedId)
			end
		end
		self:RefreshAutoStatus()
		local btn = self.m_SubMenus[self.m_SelectedId]
		if not btn then
			self:SetSelectedId(self.m_AutoteamData.id)
		end
	end
end

function CTeamHandyTaskBox.ExpandSubMenu(self)
	self.m_IsExpand = not self.m_IsExpand
	self.m_ButtonBg:SetActive(self.m_IsExpand)
	self.m_TweenHeight:Toggle()
end
return CTeamHandyTaskBox