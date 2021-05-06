local CTeamTargetSetView = class("CTeamTargetSetView", CViewBase)

CTeamTargetSetView.UIMode = 
{
	Target = 1,
	Level = 2,
}

function CTeamTargetSetView.ctor(self, cb)
	CViewBase.ctor(self, "UI/team/TeamTargetSetView.prefab", cb)
	self.m_ExtendClose = "ClickOut"
	self.m_UIMode = nil
end

function CTeamTargetSetView.OnCreateView(self)
	self.m_TaskBtnClone = self:NewUI(1, CTeamFilterBox, true)
	self.m_TaskScrollView = self:NewUI(2, CScrollView)
	self.m_TaskTable = self:NewUI(3, CTable)
	self.m_LvLimitScrollView = {}
	self.m_LvLimitScrollView["min"] = self:NewUI(4, CScrollView)
	self.m_LvLimitScrollView["max"] = self:NewUI(5, CScrollView)
	self.m_LvLimitScrollView["min"]["grid"] = self:NewUI(6, CGrid)
	self.m_LvLimitScrollView["max"]["grid"] = self:NewUI(7, CGrid)
	self.m_LvLimitScrollView["min"]["gradeLabel"] = self:NewUI(8, CLabel)
	self.m_LvLimitScrollView["max"]["gradeLabel"] = self:NewUI(9, CLabel)
	self.m_DesLabel = self:NewUI(10, CLabel)
	self.m_TargetBox = self:NewUI(11, CBox)
	self.m_LevelBox = self:NewUI(12, CBox)
	self.m_LevelOkBtn = self:NewUI(13, CBox)
	self.m_SubTargetBox = self:NewUI(14, CBox)
	self.m_SubTargetTable = self:NewUI(15, CTable)
	self.m_SubTargetCloneBox = self:NewUI(16, CBox)

	self.m_SelectedTaskId = nil
	self.m_TargetCallback = nil
	self.m_CloseCallback = nil
	self.m_LevelCallback = nil	
	self.m_OkCallback = nil
	self.m_AgreeStatuses = {}
	self.m_Targets = {}
	self.m_GradeLabels = {}
	self.m_SubTargetBoxList = {}

	self:InitContent()
	self:SetAutoTeamData()
end

function CTeamTargetSetView.InitContent(self)
	self.m_LevelOkBtn:AddUIEvent("click", callback(self, "OnLevelOk"))
	self.m_TaskBtnClone:SetActive(false)
	self.m_LevelOkBtn:SetActive(false)
	self.m_SubTargetBox:SetActive(false)
	self.m_SubTargetCloneBox:SetActive(false)
end

function CTeamTargetSetView.ShowTargetBox(self, targetId)
	self.m_UIMode = CTeamTargetSetView.UIMode.Target
	self.m_SelectedTaskId = targetId or g_TeamCtrl.TARGET_NONE	
	self.m_TargetBox:SetActive(true)
	self.m_LevelBox:SetActive(false)
	self:RefreshTargetTable()
	self:RefreshSubTargetTable()
end

function CTeamTargetSetView.ShowLevelBox(self, targetId, iMin, iMax)
	self.m_UIMode = CTeamTargetSetView.UIMode.Level
	self.m_SelectedTaskId = targetId or g_TeamCtrl.TARGET_NONE	
	self.m_TargetBox:SetActive(false)
	self.m_LevelBox:SetActive(true)	
	self.m_LevelOkBtn:SetActive(true)
	iMin = iMin or 0 
	iMax = iMax or g_AttrCtrl.server_grade
	self:LoadTeamFilterInfo(iMin, iMax)
	self:RereshLevelBox()
end

function CTeamTargetSetView.SetTargetListener(self, cb)
	self.m_TargetCallback = cb
end

function CTeamTargetSetView.SetLevelListener(self, cb)
	self.m_LevelCallback = cb
end

function CTeamTargetSetView.SetCloseListener(self, cb)
	self.m_CloseCallback = cb
end

function CTeamTargetSetView.SetOkListener(self, cb)
	self.m_OkCallback = cb
end

function CTeamTargetSetView.InitLvScrollView(self, scrollview, iMinGrade, iMaxGrade, cb)
	scrollview:ResetPosition()
	local grid = scrollview["grid"]	
	for _, label in pairs(grid:GetChildList()) do
		label:SetActive(false)
	end
	-- grid:Clear()
	local gradeLabelClone = scrollview["gradeLabel"]
	for iGrade = iMinGrade, iMaxGrade do
		local gradeLabel = grid:GetChild(iGrade - (iMinGrade - 1))
		if not gradeLabel then
			gradeLabel = gradeLabelClone:Clone(false)
			grid:AddChild(gradeLabel)
		end
		gradeLabel:SetName(tostring(iGrade))
		gradeLabel:SetText(iGrade)
		gradeLabel:SetActive(true)
	end
	scrollview:InitCenterOnCompnent(grid, cb)
end

function CTeamTargetSetView.ScrollToTargetLevel(self, scrollview, iMinGrade, iTargetGrade)
	local grid = scrollview["grid"]
	local _,h = grid:GetCellSize()
	local scrollPos = Vector3.New(0, h*(iTargetGrade - iMinGrade - 2), 0)

	printc(string.format("%d:%d:%d",iMinGrade, iTargetGrade,grid:GetCount()))

	scrollview:MoveRelative(scrollPos)
	local timer = nil
	local function update()
		if timer then
			Utils.DelTimer(timer)
		end
		if not Utils.IsNil(grid) and not Utils.IsNil(grid:GetChild(iTargetGrade - iMinGrade + 1)) then
			local obj = grid:GetChild(iTargetGrade - iMinGrade + 1).m_Transform
			scrollview:CenterOn(obj)
		end		
		return false
	end
	timer = Utils.AddTimer(update, 0.1, 0.2)
end

function CTeamTargetSetView.SetAutoTeamData(self, data)
	self.m_AutoTeamData = DataTools.GetAutoteamData(g_AttrCtrl.grade)
end

function CTeamTargetSetView.GetTeamFilterInfo(self)
	local tTargetInfo = self.m_Targets[self.m_SelectedTaskId]
	return self.m_SelectedTaskId, tTargetInfo.min_grade, tTargetInfo.max_grade
end

function CTeamTargetSetView.RefreshTargetTable(self)
	local autoTaskId = CTeamCtrl.TARGET_NONE
	if not g_TeamCtrl:IsJoinTeam() and g_TeamCtrl:IsPlayerAutoMatch() then
		autoTaskId = g_TeamCtrl:GetPlayerAutoTarget()
	end
	if g_TeamCtrl:IsJoinTeam() and g_TeamCtrl:IsTeamAutoMatch() then
		autoTaskId = g_TeamCtrl:GetTeamTargetInfo().auto_target

	end	
	local selectIdTaskId = self.m_SelectedTaskId
	local d = data.teamdata.AUTO_TEAM[selectIdTaskId]		
	if d and d.parentId ~= 0 then			
		selectIdTaskId = d.parentId
	end
	local tMoveIdx = 1
	local oMoveIdx = 1
	local MainPool = {}
	for k,v in ipairs(self.m_AutoTeamData) do
		if v.parentId == 0 then
			table.insert(MainPool, v)
		end
	end

	for k,v in ipairs(MainPool) do
		local taskBtn = self.m_TaskBtnClone:Clone()
		taskBtn:SetActive(true)
		--喵萌茶会
		if v.id == 1101 then
			local oView = CTeamMainView:GetView()
			if oView and oView.m_HandyBuildPage == oView.m_CurPage then
				g_GuideCtrl:AddGuideUI("teamtarget_minglei_btn", taskBtn.m_TaskBtn)
			end				
		end
		taskBtn.m_Id = v.id
		taskBtn:SetAutoTeamData(v)
		taskBtn:SetListener(callback(self, "OnStatusChange"))
		taskBtn:InitSelected(selectIdTaskId)
		taskBtn:SetAutoMatchWait(autoTaskId)	
		taskBtn.m_SubTargetTipsSpr = taskBtn:NewUI(9, CSprite)		
		taskBtn.m_MainTarget = v.id
		self.m_TaskTable:AddChild(taskBtn)
		if selectIdTaskId == v.id and #MainPool > 6 then
			tMoveIdx = k
			oMoveIdx = k
			if #MainPool - 6 <= tMoveIdx then
				tMoveIdx = #MainPool - 6
			end	
		end
		taskBtn.m_SubTargetTipsSpr:SetActive(#g_TeamCtrl:GetAutoTeamSubTargetTableByPartId(v.id, g_TeamCtrl:IsJoinTeam()) > 0) 
	end	
	if tMoveIdx ~= 1 then
		local oBox = self.m_TaskTable:GetChild(tMoveIdx)
		if oBox then
			local cb = function ( )
				if #MainPool > 6 and oMoveIdx == #MainPool then
					UITools.MoveToTarget(self.m_TaskScrollView, oBox, 5)
				else
					UITools.MoveToTarget(self.m_TaskScrollView, oBox, 20)
				end
			end
			Utils.AddTimer(cb, 0, 0)
		end
	end
	local guide_ui = {"teamtarget_minglei_btn"}
	g_GuideCtrl:LoadTipsGuideEffect(guide_ui)	
end

function CTeamTargetSetView.RefreshSubTargetTable(self, isClick)
	local selectIdTaskId = self.m_SelectedTaskId
	local d = data.teamdata.AUTO_TEAM[selectIdTaskId]		
	if d and d.parentId ~= 0 then			
		selectIdTaskId = d.parentId
	end
	local subTargetTable = g_TeamCtrl:GetAutoTeamSubTargetTableByPartId(selectIdTaskId, g_TeamCtrl:IsJoinTeam())
	if subTargetTable and next(subTargetTable) then
		self.m_SubTargetBox:SetActive(true)
		for i, v in ipairs(subTargetTable) do
			local oBox = self.m_SubTargetBoxList[i]
			if not oBox then
				oBox = self.m_SubTargetCloneBox:Clone()
				oBox.m_MenuBox = oBox:NewUI(1, CBox)
				oBox.m_Label = oBox:NewUI(2, CLabel)
				oBox.m_SelectSpr = oBox:NewUI(3, CSprite)
				oBox.m_MenuBox:SetGroup(self.m_SubTargetTable:GetInstanceID())				
				self.m_SubTargetTable:AddChild(oBox)
				table.insert(self.m_SubTargetBoxList, oBox)
			end			
			if g_TeamCtrl:ConverTargetId(self.m_SelectedTaskId) == g_TeamCtrl:ConverTargetId(v.id) then
				oBox.m_SelectSpr:SetActive(true)
				oBox.m_MenuBox:SetSelected(true)
			else
				oBox.m_SelectSpr:SetActive(false)
			end
			oBox:SetActive(true)
			oBox.m_Label:SetText(v.sub_title_name)
			oBox.m_MenuBox:AddUIEvent("click", callback(self, "ClickSubTargetItemBox", v.id, oBox))
		end

		if #subTargetTable < #self.m_SubTargetBoxList then
			for i = #subTargetTable + 1, #self.m_SubTargetBoxList do
				local oBox = self.m_SubTargetBoxList[i]
				if oBox then
					oBox:SetActive(false)
				end
			end
		end
	else
		if isClick then
			self:CloseView()
			return
		end
		self.m_SubTargetBox:SetActive(false)
	end

	for i = 1, self.m_TaskTable:GetCount() do
		local oBox = self.m_TaskTable:GetChild(i)
		if oBox then
			local isVisible = oBox.m_MainTarget == selectIdTaskId
			oBox.m_SubTargetTipsSpr:SetLocalRotation(Quaternion.Euler(0, 0, isVisible == true and 90 or 0))
		end
	end	
end

function CTeamTargetSetView.RereshLevelBox(self)
	local sDesc = "限制：无"
	local iMinLv = 0
	local iMaxLv = g_AttrCtrl.server_grade > self.m_Targets[self.m_SelectedTaskId].max_grade and g_AttrCtrl.server_grade or self.m_Targets[self.m_SelectedTaskId].max_grade
	local tData = data.teamdata.AUTO_TEAM[self.m_SelectedTaskId]
	if tData then
		sDesc = tData.desc
		iMinLv = tonumber(tData.unlock_level)
	end
	self:RefreshLvLimitPanel(iMinLv, iMaxLv)
	self.m_DesLabel:SetText(sDesc)
end

function CTeamTargetSetView.RefreshLvLimitPanel(self, iMinGrade, iMaxGrade)
	self:InitLvScrollView(self.m_LvLimitScrollView["min"], iMinGrade, iMaxGrade, callback(self, "OnMinGradeCenter"))
	self:InitLvScrollView(self.m_LvLimitScrollView["max"], iMinGrade, iMaxGrade, callback(self, "OnMaxGradeCenter"))
	local targetInfo = self.m_Targets[self.m_SelectedTaskId]
	self:ScrollToTargetLevel(self.m_LvLimitScrollView["min"], iMinGrade, targetInfo.min_grade)
	self:ScrollToTargetLevel(self.m_LvLimitScrollView["max"], iMinGrade, targetInfo.max_grade)
end

function CTeamTargetSetView.OnMinGradeCenter(self, scrollview, gameObject)
	local grid = self.m_LvLimitScrollView["min"]["grid"]
	local idx = grid:GetChildIdx(gameObject.transform)
	local label = grid:GetChild(idx)
	local lastLabel = self.m_GradeLabels.min
	if label then
		self.m_Targets[self.m_SelectedTaskId].min_grade =  tonumber(label:GetText())
		if lastLabel then
			--lastLabel:SetColor(Color.New(0x89/0xff, 0x60/0xff, 0x55/0xff, 1))
		end
		--label:SetColor(Color.New(1, 0x76/0xff, 0x33/0xff, 1))
		self.m_GradeLabels.min = label
		if self.m_LevelCallback	 ~= nil then
			self.m_LevelCallback(self.m_Targets[self.m_SelectedTaskId].min_grade, self.m_Targets[self.m_SelectedTaskId].max_grade)
		end		
	end
end

function CTeamTargetSetView.OnMaxGradeCenter(self, scrollview, gameObject)
	local grid = self.m_LvLimitScrollView["max"]["grid"]
	local idx = grid:GetChildIdx(gameObject.transform)
	local label = grid:GetChild(idx)
	local lastLabel = self.m_GradeLabels.max
	if label then
		self.m_Targets[self.m_SelectedTaskId].max_grade = tonumber(label:GetText())
		if lastLabel then
			--lastLabel:SetColor(Color.New(0x89/0xff, 0x60/0xff, 0x55/0xff, 1))
		end
		--label:SetColor(Color.New(1, 0x76/0xff, 0x33/0xff, 1))
		self.m_GradeLabels.max = label
		if self.m_LevelCallback	 ~= nil then
			self.m_LevelCallback(self.m_Targets[self.m_SelectedTaskId].min_grade, self.m_Targets[self.m_SelectedTaskId].max_grade)
		end
	end
end

function CTeamTargetSetView.OnStatusChange(self, box, isClick)
	if box and box.m_Id == 1101 and isClick then
		g_GuideCtrl:ReqTipsGuideFinish("teamtarget_minglei_btn")
	end
	if self.m_SelectedTaskBtn and self.m_SelectedTaskBtn ~= box then
		self.m_SelectedTaskBtn:SetSelected(false)
	end
	self.m_SelectedTaskBtn = box
	if isClick then
		self.m_SelectedTaskId = box:GetSelectedId()
		local d = data.teamdata.AUTO_TEAM[self.m_SelectedTaskId]
		if d and d.parentId == 0 then 		
			if self.m_TargetCallback ~= nil then				
				self.m_TargetCallback(self.m_SelectedTaskId)
			end
		end
		self:RefreshSubTargetTable(isClick)
	end
end

function CTeamTargetSetView.LoadTeamFilterInfo(self, iMin, iMax)
	self.m_Targets[self.m_SelectedTaskId] = self.m_Targets[self.m_SelectedTaskId] or {}	
	self.m_Targets[self.m_SelectedTaskId].min_grade = iMin
	self.m_Targets[self.m_SelectedTaskId].max_grade = iMax
end

function CTeamTargetSetView.SaveTeamFilterInfo(self)
	IOTools.SetClientData("team_task_"..g_AttrCtrl.pid, self.m_SelectedTaskId)
	for targetId,targetInfo in pairs(self.m_Targets) do
		IOTools.SetClientData(string.format("team_min_lv_%d_%d",targetId, g_AttrCtrl.pid), targetInfo.min_grade)
		IOTools.SetClientData(string.format("team_max_lv_%d_%d",targetId, g_AttrCtrl.pid), targetInfo.max_grade)
		IOTools.SetClientData(string.format("team_auto_%d_%d",targetId, g_AttrCtrl.pid), targetInfo.team_match)
	end
end

function CTeamTargetSetView.OnLevelOk(self)
	local tTargetInfo = self.m_Targets[self.m_SelectedTaskId]
	local tData = data.teamdata.AUTO_TEAM[self.m_SelectedTaskId]
	if self.m_OkCallback ~= nil then
		self.m_OkCallback(tTargetInfo.min_grade, tTargetInfo.max_grade)
	end
	self:CloseView()
end

function CTeamTargetSetView.CloseView(self)
	if self.m_CloseCallback ~= nil then
		self.m_CloseCallback()
	end
	CViewBase.CloseView(self)
end

function CTeamTargetSetView.ClickSubTargetItemBox(self, id, oBox)
	if oBox and oBox.m_SelectSpr then
		oBox.m_SelectSpr:SetActive(true)
	end
	if id ~= self.m_SelectedTaskId then
		self.m_SelectedTaskId = id
		if self.m_TargetCallback ~= nil then
			self.m_TargetCallback(self.m_SelectedTaskId)
		end		
	end
	self:CloseView()
end

return CTeamTargetSetView