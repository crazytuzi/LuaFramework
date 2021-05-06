local CDialogueOptionView = class("CDialogueOptionView", CViewBase)

function CDialogueOptionView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Dialogue/DialogueOptionView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "ClickOut"

	self.m_NpcSayData = nil
	self.m_TaskList = nil
end

function CDialogueOptionView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_OptionGroup = self:NewUI(2, CObject)
	self.m_OptionGrid = self:NewUI(3, CGrid)
	self.m_CloneOptionBtn = self:NewUI(4, CButton)
	self.m_NpcTexture = self:NewUI(5, CActorTexture)
	self.m_NpcNameLabel = self:NewUI(6, CLabel)
	self.m_NpcContentLabel = self:NewUI(7, CLabel)
	self:InitContent()
end

function CDialogueOptionView.InitContent(self)
	g_DialogueCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CDialogueOptionView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Dialogue.Event.InitOption then
		self.m_NpcSayData = oCtrl.m_EventData
		self:SetDialogueContent()
	end
end

function CDialogueOptionView.SetDialogueContent(self)
	self.m_CloneOptionBtn:SetActive(false)

	self.m_NpcTexture:ChangeShape(self.m_NpcSayData.shape, {})
	local name = self.m_NpcSayData.name
	if string.len(name) <= 0 then
		name = "这是默认Npc名称"
	end
	self.m_NpcNameLabel:SetText("[b][2DC6F8]" .. name)

	local tMsgStr = self.m_NpcSayData.text
	if tMsgStr and type(tMsgStr) == "string" and string.len(tMsgStr) > 0 then
		local strList = string.split(tMsgStr, "%&Q")
		local showContent = #strList > 0
		self.m_NpcContentLabel:SetActive(showContent)
		if showContent then
			self.m_NpcContentLabel:SetText("[502E10]" .. strList[1])
			table.remove(strList, 1)
		end

		local btnGridList = self.m_OptionGrid:GetChildList() or {}

		local taskList = {}
		local npcid = self.m_NpcSayData.npcid
		local isDynamicNpc = g_MapCtrl:GetDynamicNpc(npcid)
		if not isDynamicNpc then
			taskList = g_TaskCtrl:GetNpcAssociatedTaskList(npcid)
			-- 过滤不显示的任务
			for i=#taskList,1,-1 do
				local oTask = taskList[i]
				if oTask:AssociatedSubmit(npcid) and oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_FIND_ITEM) and not oTask.m_Finish then
					table.remove(taskList, i)
				end
			end
			self.m_TaskList = taskList
		end

		printc("  SetDialogueContent ， ", tMsgStr)
		table.print(taskList)
		table.print(tMsgStr)

		local optionCount = #taskList + #strList
		if optionCount > 0 then
			printc("  SetDialogueContent  optionCount " ,optionCount)
			for i=1,optionCount do
				local oOptionBtn = nil
				if i > #btnGridList then
					oOptionBtn = self.m_CloneOptionBtn:Clone(false)
					oOptionBtn:GetMissingComponent(classtype.UIDragScrollView)
					self.m_OptionGrid:AddChild(oOptionBtn)
				else
					oOptionBtn = btnGridList[i]
				end

				oOptionBtn:AddUIEvent("click", callback(self, "OnOptionBtn", i))
				local optionName = ""
				local idx = i - #taskList
				if idx > 0 then
					optionName = strList[idx]
				else
					local oTask = taskList[i]
					local taskName = oTask:GetValue("name")
					if oTask:GetValue("type") == 4 then
						local strList = string.split(taskName, '%（')
						optionName = oTask.m_TaskType.name .. "-" .. strList[1]
					else
						optionName = taskName
					end
				end
				oOptionBtn:SetText("[FFF9E3]" .. optionName)
				oOptionBtn:SetActive(true)
			end

			if #btnGridList > optionCount then
				for i=optionCount+1,#btnGridList do
					btnGridList[i]:SetActive(false)
				end
			end
		else
			if btnGridList and #btnGridList > 0 then
				for _,v in ipairs(btnGridList) do
					v:SetActive(false)
				end
			end
		end
	end
end

function CDialogueOptionView.OnOptionBtn(self, answer)
	if self.m_TaskList and #self.m_TaskList > 0 then
		if answer > #self.m_TaskList then
			answer = answer - #self.m_TaskList
			netother.C2GSCallback(self.m_NpcSayData.sessionidx, answer)
		else
			local task = self.m_TaskList[answer]
			if task then
				local taskid = task:GetValue("taskid")
				if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSTaskEvent"]) then
					nettask.C2GSTaskEvent(taskid, self.m_NpcSayData.npcid)
				end
			end
		end
	else
		netother.C2GSCallback(self.m_NpcSayData.sessionidx, answer)
	end
	self:CloseView()
end

return CDialogueOptionView