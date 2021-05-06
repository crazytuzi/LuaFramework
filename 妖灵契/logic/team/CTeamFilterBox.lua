local CTeamFilterBox = class("CTeamFilterBox", CBox)

function CTeamFilterBox.ctor(self, obj, isSelectText)
	CBox.ctor(self, obj)
	self.m_ButtonBg = self:NewUI(1, CSprite)
	self.m_TaskBtn = self:NewUI(2, CButton, true ,false)
	self.m_BtnGrid = self:NewUI(3, CGrid)
	self.m_CloneBtn = self:NewUI(4, CBox)
	self.m_ArrowSpr = self:NewUI(5, CSprite)
	self.m_TaskNameLabel = self:NewUI(6, CLabel)
	self.m_SubNameLabel = self:NewUI(7, CLabel)
	self.m_MainWaitBox = self:NewUI(8, CBox)
	self.m_MainSelectLabel = nil
	self.m_SelectTextMode = false 
	if isSelectText == "IsSelectText" then
		self.m_SelectTextMode = true
		self.m_MainSelectLabel = self:NewUI(9, CLabel)
	end
	self.m_SelectedId = -1
	self.m_Callback = nil
	self.m_AutoteamData = nil
	self.m_IsExpand = false
	self.m_SubMenus = {}
	self.m_SubAutoteamData = {}
	self.m_TweenHeight = self.m_ButtonBg:GetComponent(classtype.TweenHeight)
	self:InitContent()
end

function CTeamFilterBox.InitContent(self)
	self.m_TaskBtn:AddUIEvent("click", callback(self, "OnClickTask"))
end

function CTeamFilterBox.SetAutoTeamData(self, data)
	self.m_AutoteamData = data
	if data.is_parent == 1 then
		self.m_SubAutoteamData = g_TeamCtrl:GetSubAutoteamData(data.id, g_AttrCtrl.grade)
	end
	self:RefreshUI()
end

function CTeamFilterBox.SetListener(self, cb)
	self.m_Callback = cb
end

function CTeamFilterBox.InitSelected(self, taskId)
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

			--展开子菜单
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

function CTeamFilterBox.SetAutoMatchWait(self, taskId)
	self.m_MainWaitBox:SetActive(false)
	if self.m_AutoteamData.is_parent == 0 then
		if self.m_AutoteamData.id == taskId and taskId ~= CTeamCtrl.TARGET_NONE then
			self.m_MainWaitBox:SetActive(true)
		end
	elseif self.m_AutoteamData.is_parent == 1 then
		for k, v in pairs(self.m_SubMenus) do
			if k == taskId and taskId ~= CTeamCtrl.TARGET_NONE then
				v.m_SubWaitBox:SetActive(true)
			else
				v.m_SubWaitBox:SetActive(false)
			end	
		end	
	end
end

function CTeamFilterBox.InitSubSelected(self, taskId)
	local btn = self.m_SubMenus[taskId]
	if btn then
		self:SetSelected(false)
		btn:SetSelected(true)
	end
	return btn
end

function CTeamFilterBox.InitSubSelectedDelay(self)
	local function func()
		self:InitSubSelected(self.m_SelectedId)
		Utils.DelTimer(self.m_Timer)
	end
	self.m_Timer = Utils.AddTimer(func, 0, 0.1)
end

function CTeamFilterBox.RefreshUI(self)
	-- self:SetSelected(false)
	self:RefreshTaskButton()
end

function CTeamFilterBox.RefreshTaskName(self)
	self.m_TaskNameLabel:SetText(self.m_AutoteamData.name)
	if self.m_SelectTextMode and self.m_MainSelectLabel then
		self.m_MainSelectLabel:SetText(self.m_AutoteamData.name)
	end
	self.m_SubNameLabel:SetActive(false)
	local pos = nil

	local iTaskId = g_TeamCtrl:GetTeamTargetInfo().auto_target
	local bIsAutoMatch = self.m_AutoteamData.id == iTaskId or self.m_SubMenus[iTaskId]

	if self.m_SelectedId ~= -1 and self.m_AutoteamData.id ~= self.m_SelectedId and
	   not self.m_IsExpand and bIsAutoMatch then
		local taskData = data.teamdata.AUTO_TEAM[self.m_SelectedId]
		self.m_SubNameLabel:SetText(taskData.name)
		--self.m_SubNameLabel:SetActive(true)
		pos = self.m_SubNameLabel:GetLocalPos()
		pos.y = -10
		self.m_SubNameLabel:SetLocalPos(pos)
		pos = self.m_TaskNameLabel:GetLocalPos()
		pos.y = 10
		--self.m_TaskNameLabel:SetLocalPos(pos)
	else
		pos = self.m_TaskNameLabel:GetLocalPos()
		pos.y = 0
		--self.m_TaskNameLabel:SetLocalPos(pos)
	end
end

function CTeamFilterBox.RefreshTaskButton(self)
	--子项不会展开
	-- if self.m_AutoteamData.is_parent == 0 or next(self.m_SubAutoteamData) == nil then
	-- 	self.m_ArrowSpr:SetActive(false)
	-- 	self.m_ButtonBg:SetParent(nil)
	-- 	self.m_ButtonBg:Destroy()
	-- else
		-- self:CreateSubTaskButton()
		-- self.m_ArrowSpr:SetActive(true)
	--end
	self.m_ArrowSpr:SetActive(false)
	self.m_ButtonBg:SetParent(nil)
	self.m_ButtonBg:Destroy()	
	self.m_TaskNameLabel:SetText(self.m_AutoteamData.name)
end

function CTeamFilterBox.CreateSubTaskButton(self)
	local count = 0

	for k,data in pairs(self.m_SubAutoteamData) do
		local button = self.m_CloneBtn:Clone(false)
		button.m_BtnLabel = button:NewUI(1, CLabel)
		button.m_SubWaitBox = button:NewUI(2, CBox)
		button.m_SubWaitBox:SetActive(false)
		button:SetName(tostring(data.id))
		button.m_BtnLabel:SetText(data.name)
		button.m_SubSelectLabel = nil
		if self.m_SelectTextMode then
			button.m_SubSelectLabel = button:NewUI(3, CLabel)
			button.m_SubSelectLabel:SetText(data.name)
		end
		local callback = function()
			self:SetSelectedId(data.id)
		end
		button:AddUIEvent("click", callback)
		self.m_BtnGrid:AddChild(button)
		self.m_SubMenus[data.id] = button
		count = count + 1
	end

	local _, h = self.m_BtnGrid:GetCellSize()
	self.m_TweenHeight.to = (count ) * h
	self.m_BtnGrid:RemoveChild(self.m_CloneBtn)
end

function CTeamFilterBox.SetSelected(self, isSelected)
	self.m_TaskBtn:SetSelected(isSelected)
	local iTaskId = g_TeamCtrl:GetTeamTargetInfo().auto_target
	local bIsAutoMatch = self.m_AutoteamData.id == iTaskId or self.m_SubMenus[iTaskId]

	if not isSelected and not bIsAutoMatch then
		local oSubMenu = self.m_SubMenus[self.m_SelectedId]
		if oSubMenu then
			oSubMenu:SetSelected(false)
		end
		self.m_SelectedId = self.m_AutoteamData.id
	end
end

function CTeamFilterBox.SetSelectedId(self, taskId, isClick)
	self.m_SelectedId = taskId
	if self.m_Callback then
		self.m_Callback(self, isClick)
	end
end

function CTeamFilterBox.GetSelectedId(self)
	return self.m_SelectedId
end

function CTeamFilterBox.OnClickTask(self)
	if self.m_AutoteamData.is_parent == 0 then
		self:SetSelected(true)
		-- self.m_SelectedId = self:GetName()
		self:SetSelectedId(self.m_AutoteamData.id, true)
	else
		self.m_IsExpand = not self.m_IsExpand
		self:RefreshTaskName()
		if self.m_IsExpand then
			self:InitSubSelectedDelay()
		end
		local btn = self.m_SubMenus[self.m_SelectedId]
		if not btn then
			self:SetSelectedId(self.m_AutoteamData.id, true)
		end
	end
end

function CTeamFilterBox.ExpandSubMenu(self)
	self.m_IsExpand = not self.m_IsExpand
	self.m_ButtonBg:SetActive(self.m_IsExpand)
	self.m_TweenHeight:Toggle()
end
return CTeamFilterBox