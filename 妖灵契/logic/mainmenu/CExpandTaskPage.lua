local CExpandTaskPage = class("CExpandTaskPage", CPageBase)

function CExpandTaskPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CExpandTaskPage.OnInitPage(self)
	self.m_ItemScrollView = self:NewUI(1, CScrollView)
	self.m_ItemTable = self:NewUI(2, CTable)
	self.m_CloneTaskBox = self:NewUI(3, CTaskBox)
	self.m_CloneTaskBox:SetActive(false)
	self.m_NormalTaskBoxList = {}

	self.m_UpdateTimer = nil
	self:InitContent()
end

function CExpandTaskPage.InitContent(self)
	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_TeachCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTeachCtrlEvent"))
end

function CExpandTaskPage.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.RefreshAllTaskBox
	or oCtrl.m_EventID == define.Task.Event.RefreshSpecificTaskBox then
		-- 是否隐藏状态下
		-- 是否剧情中
		-- 是否特殊状态下
		-- return
		self:RefreshGrid()
	end
end

function CExpandTaskPage.OnTeachCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Teach.Event.OnUpdateProgressInfo then
		self:RefreshGrid()
	end
end

function CExpandTaskPage.OnShowPage(self)
	self:RefreshGrid()
end

function CExpandTaskPage.RefreshGrid(self)
	local taskDataList = g_TaskCtrl:GetTaskDataListWithSort() or {}
	local taskBoxList = self.m_NormalTaskBoxList or {}	

	local oTaskBox = nil
	for i = 1 , #taskBoxList do
		oTaskBox = taskBoxList[i]
		if oTaskBox then
			oTaskBox:SetActive(false)
			oTaskBox.IsActive = false
		end		
	end	

	--只有显示在任务主界面上的任务，才会假如判断
	local taskMask = {}
	local d = data.taskdata.TASKTYPE
	for i = 1, #d do
		if d[i].menu_show_index ~= 0 then
			taskMask[d[i].id ] = d[i].menu_show_index
		end
	end

	local isShowGradeTask = false --是否有需要提示等级的任务
	for k, v in pairs(taskDataList) do
		if v:GetValue("type") == define.Task.TaskCategory.STORY.ID and v:GetValue("acceptgrade") > g_AttrCtrl.grade then
			isShowGradeTask = true
		end
	end

	g_GuideCtrl:AddGuideUI("mainmenu_xmqq_task_nv_btn", nil)
	local isAddTeachTask = false		--是否已经显示了教学任务
	local index = 1
	for _,v in ipairs(taskDataList) do		
		if v:GetValue("taskid") ~= CTaskCtrl.DailyCultivateTaskID and taskMask[v:GetValue("type")] ~= nil then
			if v:GetValue("type") == define.Task.TaskCategory.TEACH.ID then
				-- if isAddTeachTask == false then
				-- 	isAddTeachTask = true
				-- 	if index > #taskBoxList then
				-- 		oTaskBox = self.m_CloneTaskBox:Clone()
				-- 		self.m_ItemTable:AddChild(oTaskBox)
				-- 		table.insert(self.m_NormalTaskBoxList, oTaskBox)
				-- 	else
				-- 		oTaskBox = taskBoxList[index]
				-- 	end
				-- 	oTaskBox.m_TaskBgBtn:ClearEffect()
				-- 	local oTask = g_TaskCtrl:LocalNewTeachTask()
				-- 	oTaskBox:SetTaskBox(oTask)
				-- 	oTaskBox:SetActive(true)
				-- 	index = index + 1
				-- end	
			else
				if index > #taskBoxList then
					oTaskBox = self.m_CloneTaskBox:Clone()
					self.m_ItemTable:AddChild(oTaskBox)
					table.insert(self.m_NormalTaskBoxList, oTaskBox)
				else
					oTaskBox = taskBoxList[index]
				end
				oTaskBox:SetTaskBox(v)
				oTaskBox:SetActive(true)	
				oTaskBox.IsActive = true
				index = index + 1	
				
				--任务导航引导
				local d 
				local delEffect = true
				if data.guidedata.TaskNv and data.guidedata.TaskNv.guide_list[1].effect_list[2] then 
					d = data.guidedata.TaskNv.guide_list[1].effect_list[2]
				end
				if d then		
					local ui_effect = "bordermove"		
					if  v:GetValue("taskid") >= 10001 and v:GetValue("taskid") <= 10036 or v:GetValue("taskid") == 10191 or	v:GetValue("taskid") == CTaskCtrl.ShiMenAccectTaskId then

						local pos = Vector2.New(0,0)
						if d.near_pos then
							pos.x = d.near_pos.x
							pos.y = d.near_pos.y
						end
						delEffect = false
						if v:GetValue("taskid") == 10001 or (v:GetValue("taskid") == 10003 and not g_ChapterFuBenCtrl:CheckChapterLevelPass(define.ChapterFuBen.Type.Simple, 1, 1)) then
							ui_effect = "Finger"		
							oTaskBox.m_TaskBgBtn:DelEffect("bordermove")				
						else
							oTaskBox.m_TaskBgBtn:DelEffect("Finger")	
						end						
						if not oTaskBox.m_TaskBgBtn:GetdEffect(ui_effect) then
							oTaskBox.m_TaskBgBtn:AddEffect(ui_effect, nil, pos)					
						end	
					end
				end

				oTaskBox.m_TaskBgBtn.m_IgnoreCheckEffect = false				
				--卡等级提示师门任务特效
				if isShowGradeTask and (v:GetValue("taskid") == CTaskCtrl.ShiMenAccectTaskId or v:GetValue("type") == define.Task.TaskCategory.SHIMEN.ID) then
					oTaskBox.m_TaskBgBtn.m_IgnoreCheckEffect = true
					delEffect = false
					oTaskBox.m_TaskBgBtn:DelEffect("Finger")
					oTaskBox.m_TaskBgBtn:AddEffect("bordermove")	
				end

				if delEffect then
					oTaskBox.m_TaskBgBtn:DelEffect("Finger")
					oTaskBox.m_TaskBgBtn:DelEffect("bordermove")
				end

				--小萌 请求				
				if v:IsMissMengTask() then
					g_GuideCtrl:AddGuideUI("mainmenu_xmqq_task_nv_btn", oTaskBox.m_TaskBgBtn)
					g_GuideCtrl:LoadTipsGuideEffect({"mainmenu_xmqq_task_nv_btn"})
				end						
				--任务导航引导		

				if v:GetValue("taskid") == CTaskCtrl.ShiMenAccectTaskId then
					g_GuideCtrl:AddGuideUI("mainmenu_shimen_accept_task_nv_btn", oTaskBox.m_TaskBgBtn)
				end	

				--31024  挑战图鉴  31513  完成重华传记任务     31516  宅邸抚摸    31517 宅邸娱乐
				oTaskBox.m_TipsGuideEnum = nil 

				if v:GetValue("taskid") == 10003 then
					g_GuideCtrl:AddGuideUI("mainmenu_nv_task_10003_btn", oTaskBox.m_TaskBgBtn)
				end	

				if v:GetValue("taskid") == 31024 then
					oTaskBox.m_TipsGuideEnum = "mainmenu_nv_task_31024_btn"
					g_GuideCtrl:AddGuideUI("mainmenu_nv_task_31024_btn", oTaskBox.m_TaskBgBtn)
				end	

				if v:GetValue("taskid") == 31515 then
					oTaskBox.m_TipsGuideEnum = "mainmenu_nv_task_31515_btn"
					g_GuideCtrl:AddGuideUI("mainmenu_nv_task_31515_btn", oTaskBox.m_TaskBgBtn)
				end					

				if v:GetValue("taskid") == 31516 then
					oTaskBox.m_TipsGuideEnum = "mainmenu_nv_task_31516_btn"
					g_GuideCtrl:AddGuideUI("mainmenu_nv_task_31516_btn", oTaskBox.m_TaskBgBtn)
				end	

			end
					
		end
	end

	local guide_ui = {"mainmenu_nv_task_31024_btn", "mainmenu_nv_task_31515_btn", "mainmenu_nv_task_31516_btn"}
	g_GuideCtrl:LoadTipsGuideEffect(guide_ui)

	-- if not isAddTeachTask and g_TeachCtrl:IsNeedToShow() then
	-- 	oTaskBox = self.m_CloneTaskBox:Clone()
	-- 	self.m_ItemTable:AddChild(oTaskBox)
	-- 	table.insert(self.m_NormalTaskBoxList, oTaskBox)
	-- 	oTaskBox.m_TaskBgBtn:ClearEffect()
	-- 	local oTask = g_TaskCtrl:LocalNewTeachTask()
	-- 	oTaskBox:SetTaskBox(oTask)
	-- 	oTaskBox:SetActive(true)
	-- end

	local function delay()
		if not Utils.IsNil(self.m_ItemTable) then
			self.m_ItemTable:RepositionLater()
		end		
		--自动接受一下个任务操作
		g_TaskCtrl:AutoDoNextTask()
		self.m_UpdateTimer = Utils.AddTimer(callback(self, "TaskCloneUpdate"), 0, 0)
		g_MainMenuCtrl:CheckTaskScrollViewUpdateTimer()
		return false
	end  
	Utils.AddTimer(delay, 0, 0.1)
	self:StopUpdateTimer()
end

function CExpandTaskPage.TaskCloneUpdate(self)
	for i = 1, #self.m_NormalTaskBoxList do
		local oTaskBox = self.m_NormalTaskBoxList[i]
		if oTaskBox and oTaskBox.IsActive == true and not Utils.IsNil(oTaskBox) then
			local bNeedShow = not self.m_ItemScrollView:IsFullOut(oTaskBox.m_TaskBgBtn)
			if oTaskBox.m_LastScrollCull ~= bNeedShow then
				oTaskBox.m_LastScrollCull = bNeedShow
				oTaskBox:SetTouchEnable(bNeedShow)
			end
		end
	end	
	return self.m_UpdateTimer ~= nil
end

function CExpandTaskPage.StopUpdateTimer(self)
	if self.m_UpdateTimer then
		Utils.DelTimer(self.m_UpdateTimer)
		self.m_UpdateTimer = nil
	end
end

return CExpandTaskPage