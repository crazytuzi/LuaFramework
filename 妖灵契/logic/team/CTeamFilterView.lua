local CTeamFilterView = class("CTeamFilterView", CViewBase)

function CTeamFilterView.ctor(self, cb)
	CViewBase.ctor(self, "UI/team/TeamFilterView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CTeamFilterView.OnCreateView(self)
	self.m_TaskBtnClone = self:NewUI(1, CTeamFilterBox, true, "IsSelectText")
	self.m_TaskScrollView = self:NewUI(2, CScrollView)
	self.m_TaskTable = self:NewUI(3, CTable)
	self.m_OkBtn = self:NewUI(4, CButton)
	self.m_CloseBtn = self:NewUI(5, CButton)
	self.m_DesLabel = self:NewUI(6, CLabel)
	self.m_AwardGrid = self:NewUI(7, CGrid)
	self.m_AwardBox = self:NewUI(8, CItemTipsBox)
	self.m_AwardLabel = self:NewUI(9, CLabel)
	self.m_LevelBtn = self:NewUI(10, CButton)
	self.m_LevelLabel = self:NewUI(11, CLabel)
	self.m_NoneTargetWidget = self:NewUI(12, CBox)
	self.m_TitleLabel = self:NewUI(13, CLabel)

	self.m_MinGrade = 0
	self.m_MaxGrade = g_AttrCtrl.server_grade + 8
	self.m_SelectedTaskId = 0
	self.m_Callback = nil
	self.m_Targets = {}

	self:InitContent()
	self:SetAutoTeamData()
	self:LoadTeamFilterInfo()
	self:RefreshUI()
end

function CTeamFilterView.InitContent(self)
	self.m_AwardBox:SetActive(false)
	self.m_OkBtn:AddUIEvent("click", callback(self,"RequestTeamFilter"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_LevelBtn:AddUIEvent("click", callback(self, "OnTargetLevel"))
end

function CTeamFilterView.SetListener(self, cb)
	self.m_Callback = cb
end

function CTeamFilterView.SetAutoTeamData(self, data)
	self.m_AutoTeamData = DataTools.GetAutoteamData(g_AttrCtrl.grade)
end

function CTeamFilterView.GetTeamFilterInfo(self)
	return self.m_SelectedTaskId, self.m_MinGrade, self.m_MaxGrade
end

function CTeamFilterView.RefreshUI(self)
	if not self.m_AutoTeamData then
		return
	end
	self:RefreshTaskTable()
	self:RefreshTarget()
	self:RefreshAward()
end

function CTeamFilterView.RefreshTaskTable(self)
	for k,v in pairs(self.m_AutoTeamData) do
		if v.parentId == 0 then 
			local taskBtn = self.m_TaskBtnClone:Clone("IsSelectText")
			taskBtn:SetActive(true)
			taskBtn:SetAutoTeamData(v)
			taskBtn:SetListener(callback(self, "OnStatusChange"))
			taskBtn:InitSelected(self.m_SelectedTaskId)
			self.m_TaskTable:AddChild(taskBtn)
		end
	end
	self.m_TaskBtnClone:SetActive(false)
end

function CTeamFilterView.RefreshTaskDesc(self, sDec)
	if sDec == nil then
		local tData = data.teamdata.AUTO_TEAM[CTeamCtrl.TARGET_NONE]
		sDec = tData.desc
	end
	local str = ""
	local t = string.split(sDec, '|')
	if t[1] == nil or t[1] == "" then
		str = string.format("限制: 无")
	else
		str = string.format("限制: %s", t[1])
	end
	if t[2] == nil or t[2] == "" then
		str = string.format("%s \n时间: 全天", str)
	else
		str = string.format("%s \n时间: %s", str, t[2])
	end
	if t[3] == nil or t[3] == "" then
		str = string.format("%s \n事件描述:\n      暂时无描述", str)
	else
		str = string.format("%s \n事件描述:\n      %s", str, t[3])
	end
	self.m_DesLabel:SetText(str)
end

function CTeamFilterView.RefreshTarget(self)
	local sDesc = ""
	local sTitle = "无"
	local iMinLv = 0
	local iMaxLv = g_AttrCtrl.server_grade + 8
	local tData = data.teamdata.AUTO_TEAM[self.m_SelectedTaskId]
	local tTargetInfo = self.m_Targets[self.m_SelectedTaskId]

	if tData then
		sDesc = tData.desc
		sTitle = tData.name
		iMinLv = tData.unlock_level

		if tTargetInfo.min_grade == -1 then
			if tData.target_type == 0 then
				tTargetInfo.min_grade = math.max(tData.unlock_level, g_AttrCtrl.grade - 5)
				tTargetInfo.max_grade = math.min(g_AttrCtrl.grade + 5, g_AttrCtrl.server_grade + 8)
			else
				tTargetInfo.min_grade = tData.unlock_level
				tTargetInfo.max_grade = iMaxLv
			end
			self.m_Targets[self.m_SelectedTaskId] = tTargetInfo
		else
			if tTargetInfo.min_grade ~= nil then
				iMinLv = tTargetInfo.min_grade
			end

			if tTargetInfo.max_grade ~= nil then
				iMaxLv = tTargetInfo.max_grade
			end
		end
	end
	self.m_TitleLabel:SetText(sTitle)
	self.m_MinGrade = iMinLv
	self.m_MaxGrade = iMaxLv
	self:RefreshLevelButtonText(iMinLv, iMaxLv)
	self:RefreshTaskDesc(sDesc)
end

function CTeamFilterView.RefreshAward(self)
	local tData = data.teamdata.AUTO_TEAM[self.m_SelectedTaskId]

	self.m_AwardLabel:SetActive(true)
	if tData then
		local t = string.split(tData.award_list, ';') 
		if #t == 1 and t[1] == "0" then
			self.m_AwardLabel:SetActive(false)
		else
			for i = 1, #t do				
				local pairId = nil
				local sid = nil
				local str = t[i]
				if string.find(str, "partner") then
					sid, parId = g_ItemCtrl:SplitSidAndValue(str)
				else
					sid = tonumber(str)
				end
				if sid then
					local oBox = self.m_AwardGrid:GetChild(i)
					if oBox == nil then
						oBox = self.m_AwardBox:Clone()			
						self.m_AwardGrid:AddChild(oBox)
					end	
					oBox:SetActive(true)					
					local config = {isLocal = true}

					oBox:SetItemData(sid, 1, pairId, config)
				end				
			end

			if #t < self.m_AwardGrid:GetCount() then
				for i = (#t + 1), self.m_AwardGrid:GetCount() do
					local oBox = self.m_AwardGrid:GetChild(i)
					oBox:SetActive(false)
				end
			end	
		end
	else
		self.m_AwardLabel:SetActive(false)
	end
end

function CTeamFilterView.OnStatusChange(self, box)
	if self.m_SelectedTaskBtn and self.m_SelectedTaskBtn ~= box then
		self.m_SelectedTaskBtn:SetSelected(false)
	end

	self.m_SelectedTaskBtn = box
	self.m_SelectedTaskId = box:GetSelectedId()

	-- if self.m_SelectedTaskId == CTeamCtrl.TARGET_NONE then
	-- 	self.m_NoneTargetWidget:SetActive(true)
	-- else
		self.m_NoneTargetWidget:SetActive(false)
		self:RefreshTarget()
		self:RefreshAward()
	--end
end

function CTeamFilterView.RequestTeamFilter(self)
	local tTargetInfo = self.m_Targets[self.m_SelectedTaskId]
	if not g_TeamCtrl:CanAutoMatchTeam(self.m_SelectedTaskId, tTargetInfo.min_grade, tTargetInfo.max_grade) then
		return 
	end

	if not self:CanManualCreareTarget(self.m_SelectedTaskId) then		
		return
	end

	if self.m_Callback then
		self.m_Callback(self)
	end
	self:SaveTeamFilterInfo()
	self:CloseView()
end

function CTeamFilterView.LoadTeamFilterInfo(self)
	for k,v in pairs(self.m_AutoTeamData) do
		local sKey = string.format("team_min_lv_%d_%d", v.id, g_AttrCtrl.pid)
		local sKey1 = string.format("team_max_lv_%d_%d", v.id, g_AttrCtrl.pid)
		local sKey2 = string.format("team_auto_%d_%d", v.id, g_AttrCtrl.pid)

		self.m_Targets[v.id] = {
			min_grade = IOTools.GetClientData(sKey) or -1,
			max_grade = IOTools.GetClientData(sKey1) or -1,
			team_match = IOTools.GetClientData(sKey2) or 1
		}
	end

	local targetInfo = g_TeamCtrl:GetTeamTargetInfo()
	if targetInfo and next(targetInfo) and self.m_Targets then
		self.m_SelectedTaskId = targetInfo.auto_target
		self.m_Targets[self.m_SelectedTaskId] = self.m_Targets[self.m_SelectedTaskId] or {}
		self.m_Targets[self.m_SelectedTaskId].min_grade = targetInfo.min_grade
		self.m_Targets[self.m_SelectedTaskId].max_grade = targetInfo.max_grade
	else
		self.m_SelectedTaskId = IOTools.GetClientData("team_task_"..g_AttrCtrl.pid)
	end

end

function CTeamFilterView.SaveTeamFilterInfo(self)
	IOTools.SetClientData("team_task_"..g_AttrCtrl.pid, self.m_SelectedTaskId)

	for targetId,targetInfo in pairs(self.m_Targets) do
		IOTools.SetClientData(string.format("team_min_lv_%d_%d",targetId, g_AttrCtrl.pid), targetInfo.min_grade)
		IOTools.SetClientData(string.format("team_max_lv_%d_%d",targetId, g_AttrCtrl.pid), targetInfo.max_grade)
		IOTools.SetClientData(string.format("team_auto_%d_%d",targetId, g_AttrCtrl.pid), targetInfo.team_match)
	end
end

function CTeamFilterView.RefreshLevelButtonText(self, iMin, iMax)
	self.m_LevelLabel:SetText(string.format("等级:%d-%d", iMin, iMax))
end

function CTeamFilterView.OnTargetLevel(self)
	g_WindowTipCtrl:SetWindowTeamLevel(	
		{	
			iTaskId = self.m_SelectedTaskId,
			iMaxGrade = self.m_MaxGrade,
		    iMinGrade = self.m_MinGrade,
		    valueCallback = callback(self, "OnLevelChange"),
		    okCallback =  callback(self, "OnLeveOk")
		},
		{ widget = self.m_LevelBtn, side = enum.UIAnchor.Side.Top, offset = Vector2.New(0, -5)}
	)
end

function CTeamFilterView.OnLevelChange(self, iMin, iMax)
	self:RefreshLevelButtonText(iMin, iMax)
end

function CTeamFilterView.OnLeveOk(self, iMin, iMax)
	if iMax < iMin then
		iMax, iMin = iMin, iMax
	end
	self.m_Targets[self.m_SelectedTaskId].min_grade = iMin
	self.m_Targets[self.m_SelectedTaskId].max_grade = iMax
	self.m_MinGrade = iMin
	self.m_MaxGrade = iMax
	self:RefreshLevelButtonText(iMin, iMax)
end

function CTeamFilterView.CanManualCreareTarget(self, targetId)
	local b = true
	local d = data.autoteamdata.DATA
	if d then
		if d[targetId] and d[targetId].is_parent == 1 then
			if d[targetId].select_target_tips and d[targetId].select_target_tips ~= "" then
				g_NotifyCtrl:FloatMsg(d[targetId].select_target_tips)
			end			
			b = false
		end
	end
	return b
end

function CTeamFilterView.SetLocalTargetInfo(self, targetId, min, max)
	for k,v in pairs(self.m_AutoTeamData) do
		local sKey = string.format("team_min_lv_%d_%d", v.id, g_AttrCtrl.pid)
		local sKey1 = string.format("team_max_lv_%d_%d", v.id, g_AttrCtrl.pid)
		local sKey2 = string.format("team_auto_%d_%d", v.id, g_AttrCtrl.pid)

		self.m_Targets[v.id] = {
			min_grade = IOTools.GetClientData(sKey) or -1,
			max_grade = IOTools.GetClientData(sKey1) or -1,
			team_match = IOTools.GetClientData(sKey2) or 1
		}
	end

	self.m_SelectedTaskId = targetId
	self.m_Targets[self.m_SelectedTaskId] = self.m_Targets[self.m_SelectedTaskId] or {}
	self.m_Targets[self.m_SelectedTaskId].min_grade = min 
	self.m_Targets[self.m_SelectedTaskId].max_grade = max
	self:RefreshUI()
end

return CTeamFilterView