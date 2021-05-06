local CTaskBox = class("CTaskBox", CBox)

function CTaskBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)

	self.m_TypeLabel = self:NewUI(1, CLabel)
	self.m_DesLabel = self:NewUI(2, CLabel)
	self.m_AcceptStatusBox = self:NewUI(3, CBox)
	-- self.m_BgSprite = self:NewUI(4, CObject)
	self.m_TaskBgBtn = self:NewUI(4, CButton, true, false)
	self.m_DivisionBox = self:NewUI(5, CBox)
	self.m_DoingStatusBox = self:NewUI(6, CBox)
	self.m_DefeatedStatusBox = self:NewUI(7, CBox)
	self.m_DonetatusBox = self:NewUI(8, CBox)
	self.m_StatusBox = self:NewUI(9, CBox)
	self.m_TitleLabel = self:NewUI(10, CLabel)
	self.m_TaskTypeSprite = self:NewUI(11, CSprite)

	self.m_Callback = cb
	self:ResetStatus()

	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTaskCtrlEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrlEvent"))
	-- self.m_BgSprite:AddUIEvent("repeatpress", callback(self, "OnPressTaskBox"))
	self.m_TaskBgBtn:AddUIEvent("click", callback(self, "OnTaskBox"))
	self.m_TaskTypeSprite:AddUIEvent("click", callback(self, "OnTaskView"))
	self.m_TaskBgBtn.m_BoxCollider = self.m_TaskBgBtn:GetComponent(classtype.BoxCollider)
	self.m_TaskTypeSprite.m_BoxCollider = self.m_TaskTypeSprite:GetComponent(classtype.BoxCollider)

end

function CTaskBox.ResetStatus(self)
	self.m_TaskData = nil

	self.m_TypeText = ""
	self.m_TitleText = ""
	self.m_TargetText = ""
	self.m_RemainTime = 0
	self.m_RemainTimer = nil

	self:RefreshTaskBox()
end

function CTaskBox.OnTaskCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.RefreshSpecificTaskBox then
		if self.m_TaskData and oCtrl.m_EventData then
			local localTaskID = self.m_TaskData:GetValue("taskid")
			if localTaskID == oCtrl.m_EventData then
				local oTask = g_TaskCtrl:GetTaskById(oCtrl.m_EventData)
				if oTask then
					self:SetTaskBox(oTask)
				end
			end
		end
	end
end

function CTaskBox.OnCtrlAttrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		if self:GetActive() == true and self.m_TaskData then
			self:SetTaskBox(self.m_TaskData)
		end
	end
end

function CTaskBox.SetTaskBox(self, oTask)
	self.m_TaskData = oTask
	if oTask then
		self.m_TypeText = g_TaskCtrl:GetTaskTitleDesc(oTask, true)
		self.m_TaskTypeSprite:SetSpriteName(oTask:GetTaskTypeSpriteteName())
		local acceptGrade = oTask:GetValue("acceptgrade")
		if g_AttrCtrl.grade >= acceptGrade then
			self.m_TargetText = g_TaskCtrl:GetTargetDesc(oTask, true)
		else
			self.m_TargetText = string.format("#R(角色%d级可接)", acceptGrade)
		end		
		--任务倒计时处理
		self.m_RemainTime = oTask:GetRemainTime()
		if self.m_RemainTime > 0 then
			local function update(dt)
				self.m_RemainTime = self.m_RemainTime - 1
				self:SetTargetText()
				if self.m_RemainTime <= 0 then
					return false
				else
					return true
				end
			end
			if self.m_RemainTimer ~= nil then
				Utils.DelTimer(self.m_RemainTimer)
				self.m_RemainTimer = nil
			end
			self.m_RemainTimer = Utils.AddTimer(update, 1, 0)
		else
			self.m_RemainTime = 0
			if self.m_RemainTimer ~= nil then
				Utils.DelTimer(self.m_RemainTimer)
				self.m_RemainTimer = nil
			end
		end
	end
	self:RefreshTaskBox()
end

function CTaskBox.RefreshTaskBox(self)
	self.m_TypeLabel:SetText(self.m_TypeText)
	self.m_TitleLabel:SetText(self.m_TitleText)
	self:SetTargetText()

	self:ShowTaskStatus()
end

function CTaskBox.SetTargetText(self)
	local targetText = self.m_TargetText
	if self.m_RemainTime and self.m_RemainTime > 0 then
		targetText = string.format("%s [ff0000](%dS)",  self.m_TargetText, self.m_RemainTime)
	end
	if self.m_TaskData then
		local acceptGrade = self.m_TaskData:GetValue("acceptgrade") or 0
		local chapterData = self.m_TaskData:GetChaptetFubenData()
		if g_AttrCtrl.grade >= acceptGrade and chapterData then
			if tonumber(chapterData[1]) <= g_ChapterFuBenCtrl:GetCurMaxChapter(define.ChapterFuBen.Type.Simple) then
				if not g_ChapterFuBenCtrl:CheckChapterLevelPass(define.ChapterFuBen.Type.Simple, chapterData[1], chapterData[2]) then
					local lastChapter, lastLevel = g_ChapterFuBenCtrl:GetFinalChapterLevel(define.ChapterFuBen.Type.Simple)		
					local des = g_ChapterFuBenCtrl:GetTaskPassDes(define.ChapterFuBen.Type.Simple, lastChapter, lastLevel)				
					if des ~= "" then
						targetText = string.format("[FAE7B9]%s", des)
					else
						targetText = string.format("[ff6868]通关战役%d-%d", lastChapter, lastLevel)
					end						
				end
			end
		end
	end
	self.m_DesLabel:SetText(targetText)
	if not self.m_TaskData or self.m_TaskData:GetValue("taskid") ~= CTaskCtrl.PartnerAccectTaskId then
		self.m_DesLabel:SetColor(Color.New( 250/255, 231/255, 185/255, 255/255))		
	else
		self.m_DesLabel:SetColor(Color.New( 255/255, 104/255, 104/255, 255/255))		
	end

	if self.m_DesLabel:GetHeight() > 40 then
		self.m_TaskBgBtn:SetSize(230, 100)
		self.m_TypeLabel:SetLocalPos(Vector3.New(-50, 15, 0))
		self.m_DesLabel:SetLocalPos(Vector3.New(-50, 9.5, 0))
	else
		self.m_TaskBgBtn:SetSize(230, 80)
		self.m_TypeLabel:SetLocalPos(Vector3.New(-50, 6, 0))
		self.m_DesLabel:SetLocalPos(Vector3.New(-50, -6, 0))
	end
end

function CTaskBox.OnTaskBox(self, oBtn)
	if g_TaskCtrl:CheckClickTaskInterval(self.m_TaskData:GetValue("taskid")) then
		if g_ActivityCtrl:ActivityBlockContrl("task") then		
			print(string.format("<color=#00FF00> >>> .%s | 表数据查看 | %s </color>", "OnTaskBox", "任务导航TaskBox数据输出", "self.m_TaskData"))
			table.print(self.m_TaskData)

			if self.m_TaskData:GetValue("type") == define.Task.TaskCategory.SHIMEN.ID then
				g_TaskCtrl:StartAutoDoingShiMen(true)
			else
				g_TaskCtrl:StartAutoDoingShiMen(false)
			end

			g_GuideCtrl:ReqTipsGuideFinish("mainmenu_xmqq_task_nv_btn")
			g_TaskCtrl:ClickTaskLogic(self.m_TaskData, nil, {clickTask = true})
			if self.m_Callback then
				self.m_Callback()
			end
			if self.m_TipsGuideEnum == "mainmenu_nv_task_31024_btn" then
				g_GuideCtrl:ReqTipsGuideFinish("mainmenu_nv_task_31024_btn")		

			elseif self.m_TipsGuideEnum == "mainmenu_nv_task_31515_btn" then
				g_GuideCtrl:ReqTipsGuideFinish("mainmenu_nv_task_31515_btn")	

			elseif self.m_TipsGuideEnum == "mainmenu_nv_task_31516_btn" then
				g_GuideCtrl:ReqTipsGuideFinish("mainmenu_nv_task_31516_btn")					

			end
		end
	end
end

function CTaskBox.ShowTaskStatus(self)
	if self.m_TaskData then
		local acceptGrade = self.m_TaskData:GetValue("acceptgrade")
		if g_AttrCtrl.grade >= acceptGrade then
			self.m_StatusBox:SetActive(true)
			self.m_AcceptStatusBox:SetActive(false)
			self.m_DoingStatusBox:SetActive(false)
			self.m_DefeatedStatusBox:SetActive(false)
			self.m_DonetatusBox:SetActive(false)
			if self.m_TaskData then
				local status = self.m_TaskData:GetValue("status")
				--主线一直显示进行中
				if status == define.Task.TaskStatus.Accept or status == define.Task.TaskStatus.HasCommmit then				
					--可接任务暂时显示为进行中,不显示任务状态					
				elseif status == define.Task.TaskStatus.Doing then
					--进行中任务,不显示任务状态	
				elseif status == define.Task.TaskStatus.Defeated then
					self.m_DefeatedStatusBox:SetActive(true)
				elseif status == define.Task.TaskStatus.Done then
					if self.m_TaskData:GetValue("type") == define.Task.TaskCategory.ACHIEVE.ID then
						self.m_DonetatusBox:SetActive(true)
					end
					
				end
			end
		else
			self.m_StatusBox:SetActive(false)
		end
	else
		self.m_StatusBox:SetActive(false)
	end
end

function CTaskBox.ShowDivisionBox(self, isVisible)
	self.m_DivisionBox:SetActive(isVisible)
end

function CTaskBox.Destroy(self)
	if self.m_RemainTimer ~= nil then
		Utils.DelTimer(self.m_RemainTimer)
		self.m_RemainTimer = nil
	end
	CObject.Destroy(self)
end

function CTaskBox.SetActive(self, bActive)
	if bActive == false then
		if self.m_RemainTimer ~= nil then
			Utils.DelTimer(self.m_RemainTimer)
			self.m_RemainTimer = nil
		end
	end
	CObject.SetActive(self, bActive)
end

function CTaskBox.OnTaskView(self )
	CTaskMainView:ShowView(function (oView)
 		oView:ShowDefaultTask()
	end)
end

function CTaskBox.SetTouchEnable(self, b)
	if self.m_TaskBgBtn then
		self.m_TaskBgBtn.m_BoxCollider.enabled = b
	end
	if self.m_TaskTypeSprite then
		self.m_TaskTypeSprite.m_BoxCollider.enabled = b	
	end	
end

return CTaskBox