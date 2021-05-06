local CDialogueMainView = class("CDialogueMainView", CViewBase)

CDialogueMainView.UIType = 
{
	Normal = 1,
	StoryStart = 2,
}

CDialogueMainView.DelayCloseTime = 180

function CDialogueMainView.ctor(self, cb, pPageIndex)
	CViewBase.ctor(self, "UI/Dialogue/DialogueMainView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_SwitchSceneClose = false
	-- self.m_ExtendClose = "Black"
end

function CDialogueMainView.OnCreateView(self)
	self.m_CurPage = nil
	self.m_NormalPage = self:NewPage(2, CDialogueNormalPage)
	self.m_Container = self:NewUI(4, CWidget)
	UITools.ResizeToRootSize(self.m_Container)

	self.m_DialogData = nil
	self.m_StoryData = nil
	self.m_HideView = nil
	self.m_SubTalkerList = nil
	self.m_UIType = nil
	self.m_DelayCloseTimer = nil
	self.m_DialogueVoice = nil

	self:InitContent()

	local oView = CMainMenuOperateView:GetView()
	if oView then
		oView:OnClose()
	end

	--显示对话界面时，隐藏其他所有界面	
	g_DialogueCtrl:HideAllViews()
end
function CDialogueMainView.InitContent(self)
	g_DialogueCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self.m_DelayCloseTimer = Utils.AddTimer(function ()
		if not Utils.IsNil(self) then
			self:CloseView()
		end		
	end, 0 , CDialogueMainView.DelayCloseTime)
end

function CDialogueMainView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Dialogue.Event.Dialogue then
		if self.m_CurPage and self.m_CurPage.SetContent then
			self:AddSubTalker()
			self.m_CurPage:SetContent(oCtrl.m_EventData, function ()
				self:CloseView()
			end)
		end
	end
end

function CDialogueMainView.SetShowBtn(self, bShowSkip, bShowBack, bCan)
	self.m_NormalPage.m_ShowSkip = bShowSkip
	self.m_NormalPage.m_ShowBack = bShowBack
	if self.m_NormalPage.m_BackBtn then
		self.m_NormalPage.m_BackBtn:SetActive(bShowBack)
	end
	if self.m_NormalPage.m_JumpBtn then
		self.m_NormalPage.m_JumpBtn:SetActive(bShowSkip)
	end
	self.m_NormalPage.m_CanSkipOption = bCan
end

function CDialogueMainView.SetContent(self, data)
	self.m_DialogData = data
	if self.m_DialogData and self.m_DialogData.npcid then
		g_MapCtrl:FaceToHeroById(self.m_DialogData.npcid)

		local function wrap ()			
			--添加辅助对话者处理
			self:AddSubTalker()
			self:AssociatedTraceNpcFaceToHero(self.m_DialogData.npcid)
		end

		g_MapCtrl:HeroDialoguePosReset(self.m_DialogData.npcid, wrap)
	end	
	self.m_UIType = CDialogueMainView.UIType.Normal
	self:ShowSubPage(self.m_NormalPage)
end

function CDialogueMainView.Destroy(self)	
	if self.m_DialogData and self.m_DialogData.npcid then
		g_MapCtrl:ResetNPCRotionById(self.m_DialogData.npcid)
	end

	if self.m_DelayCloseTimer then
		Utils.DelTimer(self.m_DelayCloseTimer)
		self.m_DelayCloseTimer = nil
	end

	--关闭对话界面时，显示开始隐藏的所有界面
	g_DialogueCtrl:ShowAllViews()

	--删除辅助对话者处理
	self:DelSubTalker()

	--关闭对话界面，刷新护送的npc
	g_TaskCtrl:EscortNpcFollowHero()

	--关闭对话界面，继续接取师门任务
	g_TaskCtrl:ContinuShimen()

	--昨晚社交动作之后，归位
	g_DialogueCtrl:ResetSocialDialogue()

	g_MapCtrl:ClearTouchNpcTips()

	g_GuideCtrl:TriggerCheck("grade")

	if self.m_DialogueVoice then
		g_AudioCtrl:OnStopPlay()
	end

	g_DialogueCtrl:ResetData()

	if self.m_CloseCallBack then
		self.m_CloseCallBack()
	end

	CViewBase.Destroy(self)
end

function CDialogueMainView.AddSubTalker(self)
	if not self.m_DialogData.dialog or #self.m_DialogData.dialog <= 0 
		or self.m_DialogData.dialog[1].ui_mode ~= define.Dialogue.Mode.Dialogue 
		or self.m_DialogData.dialog[1].sub_talker_list == "" 
		or (self.m_SubTalkerList and next(self.m_SubTalkerList)) then
		return
	end

	local npclist = self.m_DialogData.dialog[1].sub_talker_list
	local taskNpc = {}
	if not npclist then
		return
	end
	local list = string.split(npclist, ",")
	if list and #list > 0 then
		for i = 1, #list do
			local npcType = tonumber(list[i]) 
			local t = {}
			if npcType ~= 0 then
				local npc = g_TaskCtrl:GetTaskNpc(npcType)
				if npc then
					t = table.copy(npc)
					t.npctype = npcType
					table.insert(taskNpc, t)		
				end				
			end						
		end		
	end

	if #taskNpc < 1 or #taskNpc > 2 then
		return
	end	
	self.m_SubTalkerList = {}
	if self.m_DialogData.npcid  then
		local count = #taskNpc   
		local dir = nil
		for i = 1, count do 
			local pos = {}
			local subNpc = {}
			local hero = g_MapCtrl:GetHero()
			local npc = g_MapCtrl:GetNpc(self.m_DialogData.npcid)
			if not npc then
				npc = g_MapCtrl:GetDynamicNpc(self.m_DialogData.npcid)
			end
			local d = taskNpc[i]
			local npctype
			if hero then				
				local heroPos = hero:GetPos()
				heroPos.z = 0
				local npcPos 
				if npc then
					npcPos = npc:GetPos()
				else
					npcPos = g_DialogueCtrl.m_CacheDialogueNpcPos		
					if not npcPos then
						npcPos = heroPos + Vector3.New(1, 1, 0)
					end
				end
				npcPos.z = 0				
				if not dir then
					local v1 = npcPos - heroPos 
					dir = v1:GetOrthoNormalVector()					
				end

				if i == 1 then
					pos = heroPos + dir									
				else
					pos = heroPos + (dir * -1)
				end

				subNpc = 
				{
					map_id = g_MapCtrl:GetMapID(),
					npctype = d.npctype,
					name = d.name,
					model_info = d.model_info,
					pos_info = npcPos,
					end_pos = pos,
				}

				subNpc.pos_info.z = 0 			
				if subNpc.pos_info.x < 1000 then
					subNpc.pos_info.x = subNpc.pos_info.x * 1000
					subNpc.pos_info.y = subNpc.pos_info.y * 1000
				end

				table.insert(self.m_SubTalkerList, subNpc)	
				g_DialogueCtrl:AddSubTalker(subNpc)				
			end

		end
	end
end

function CDialogueMainView.DelSubTalker(self)
	if self.m_SubTalkerList and next(self.m_SubTalkerList) then
		for k, v in pairs(self.m_SubTalkerList) do
			g_DialogueCtrl:DelSubTalker(v.npctype)
		end
	end
	self.m_SubTalkerList = nil
end

--对话时，跟踪Npc朝向主角 
function CDialogueMainView.AssociatedTraceNpcFaceToHero(self, npcId)
	local taskList = g_TaskCtrl:GetNpcAssociatedTaskList(npcId)	
	if taskList and next(taskList) then
		for i, v in ipairs(taskList) do			
			if v:GetValue("tasktype") == define.Task.TaskType.TASK_TRACE then
				local traceNpcList = g_MapCtrl.m_TraceNpcs				
				if traceNpcList and next(traceNpcList) then
					for _i, _v in pairs(traceNpcList) do						
						if _v.m_ClientNpc.taskId == v:GetValue("taskid") then							
							_v:FaceToHero()
						end
					end
				end					
			end
		end
	end
end

function CDialogueMainView.SetCloseCallBack(self, cb)
	self.m_CloseCallBack = cb 
end

return CDialogueMainView