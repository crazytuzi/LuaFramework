

local CDialogueNormalPage = class("CDialogueNormalPage", CPageBase)

CDialogueNormalPage.EnumContinu = 
{
	None = 0,
	Continue = 1,
	Switch = 2,
	DialogEnd =3,
	ScreenMask =4,
}

CDialogueNormalPage.SaySide = 
{
	Left = 1,
	Right = 2,
	Center = 3,
	LeftAndRight = 4,
	All = 5,
	None = 6,
}

function CDialogueNormalPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_ShowSkip = true
	self.m_ShowBack = true

	self.m_closeCB = nil
	self.m_DialogData = nil
	self.m_CurDialog = nil 
	self.m_TaskId = 0
	self.m_DialogIdx = 1
	self.m_LastShapeID = 0
	self.m_ToContinue = CDialogueNormalPage.EnumContinu.None
	self.m_ScreenMaskTimer = nil
	self.m_ScreenMaskAlphaTimer = nil
	self.m_IsTextAni = false
	self.m_RightBtnList = {}
	self.m_CenterBtnList = {}
	self.m_CanSkipOption = true
	self.m_AutoDoingTaskTimer = nil
	self.m_SocialTimer = nil
	self.m_SocialList = nil
	self.m_IsDoingSocial = false
end

function CDialogueNormalPage.OnInitPage(self)
	self.m_CheckNextBox = self:NewUI(1, CBox)
	self.m_RBContinue = self:NewUI(2, CBox)
	self.m_LeftNameWidget = self:NewUI(3, CBox)
	self.m_RightNameWidget = self:NewUI(4, CBox)
	self.m_BottomBtn = self:NewUI(5, CBox)
	self.m_LeftActorTextureWidget = self:NewUI(6, CBox)
	self.m_LeftActorTexture = self:NewUI(7, CTexture)
	self.m_RightActorTexture = self:NewUI(8, CTexture)
	self.m_MidDialogueLabel = self:NewUI(9, CLabelWriteEffect)
	self.m_RewardItemWidget = self:NewUI(10, CBox)
	self.m_RewardItemGird = self:NewUI(11, CGrid)
	self.m_RewardItemBox = self:NewUI(12, CItemTipsBox)
	self.m_CenterBtnWidget = self:NewUI(13, CBox)
	self.m_CenterGrid = self:NewUI(14, CGrid)
	self.m_CenterOptionBox = self:NewUI(15, CBox)
	self.m_RightBtnWidget = self:NewUI(16, CBox)
	self.m_RightGrid = self:NewUI(17, CGrid)
	self.m_RightOptionBox = self:NewUI(18, CBox)
	self.m_LeftNameLabel = self:NewUI(19, CLabel)
	self.m_RightNameLabel = self:NewUI(20, CLabel)
	self.m_LeftDialogueLabel = self:NewUI(21, CLabelWriteEffect)
	self.m_MidNameWidget = self:NewUI(22, CBox)
	self.m_MidNameLabel = self:NewUI(23, CLabel)
	self.m_TaskTitleWidget = self:NewUI(24, CBox)
	self.m_TaskTitleNameLabel = self:NewUI(25, CLabel)
	self.m_TaskStatusSprite = self:NewUI(26, CSprite)
	self.m_MTBox = self:NewUI(27, CBox)	--more talk
	self.m_LeftTimeLabel = self:NewUI(28, CLabel)
	self.m_BttomSprite = self:NewUI(29, CSprite)
	self.m_SCSMask = self:NewUI(30, CBox) -- screen mask
	self.m_RightDialogueLabel = self:NewUI(31, CLabelWriteEffect)
	self.m_BackBtn = self:NewUI(32, CBox)
	self.m_JumpBtn = self:NewUI(33, CBox)
	self.m_LBContinue = self:NewUI(34, CBox)
	self.m_BgTexture = self:NewUI(35, CTexture)
	self.m_TopMaskSprite = self:NewUI(36, CSprite)
	self.m_LeftSpineTexture = self:NewUI(37, CSpineTexture)
	self.m_RightSpineTexture = self:NewUI(38, CSpineTexture)
	self.m_LeftVoiceSprite = self:NewUI(39, CSprite)
	self.m_RightVoiceSprite = self:NewUI(40, CSprite)
	self.m_BaseWidget = self:NewUI(41, CBox)
	self.m_MaskWidget = self:NewUI(42, CBox)

	self.m_MTBox.m_TwoBox = self.m_MTBox:NewUI(1, CBox)
	self.m_MTBox.m_LeftTextrue2 = self.m_MTBox:NewUI(2, CTexture)
	self.m_MTBox.m_LeftName2 = self.m_MTBox:NewUI(3, CLabel)
	self.m_MTBox.m_RightTextrue2 = self.m_MTBox:NewUI(4, CTexture)
	self.m_MTBox.m_RightName2 = self.m_MTBox:NewUI(5, CLabel)
	self.m_MTBox.m_ThreeBox = self.m_MTBox:NewUI(6, CBox)
	self.m_MTBox.m_LeftTextrue3 = self.m_MTBox:NewUI(7, CTexture)
	self.m_MTBox.m_LeftName3 = self.m_MTBox:NewUI(8, CLabel)
	self.m_MTBox.m_MidTexture3 = self.m_MTBox:NewUI(9, CTexture)
	self.m_MTBox.m_MidName3 = self.m_MTBox:NewUI(10, CLabel)
	self.m_MTBox.m_RightTexture3 = self.m_MTBox:NewUI(11, CTexture)
	self.m_MTBox.m_RightName3 = self.m_MTBox:NewUI(12, CLabel)

	self.m_SCSMask.m_MaskBg = self.m_SCSMask:NewUI(1, CTexture)
	self.m_SCSMask.m_MaskBg.m_Tween = self.m_SCSMask.m_MaskBg:GetComponent(classtype.TweenAlpha)
	self.m_SCSMask.m_ContentLabel = self.m_SCSMask:NewUI(2, CLabel)
	self.m_SCSMask.m_ContentLabel.m_Tween = self.m_SCSMask.m_ContentLabel:GetComponent(classtype.TweenAlpha)
	self.m_SCSMask.m_ContinueLabel = self.m_SCSMask:NewUI(3, CLabel)
	
	self:InitContetn()
end

function CDialogueNormalPage.InitContetn(self)
	self.m_CenterOptionBox:SetActive(false)
	self.m_RightOptionBox:SetActive(false)
	self.m_RewardItemBox:SetActive(false)
	self.m_LeftTimeLabel:SetActive(false)
	self.m_BottomBtn:AddUIEvent("click", callback(self, "OnContinue"))
	self.m_CheckNextBox:AddUIEvent("click", callback(self, "OnNext"))
	self.m_BackBtn:AddUIEvent("click", callback(self, "OnBack"))
	self.m_JumpBtn:AddUIEvent("click", callback(self, "OnJump"))

	local config = 
	{
		FinishCallBack = callback(self, "TextEndCallBack"),
		StartCallBack = callback(self, "TextStartCallBack"),
	}
	--self.m_LeftDialogueLabel:InitLabel(config)
	--self.m_MidDialogueLabel:InitLabel(config)
	--self.m_RightDialogueLabel:InitLabel(config)
	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTaskCtrlEvent"))
end

function CDialogueNormalPage.OnTaskCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.RefreshAllTaskBox or 
	   oCtrl.m_EventID == define.Task.Event.RefreshSpecificTaskBoxthen then
	   if self.m_CurDialog.ui_mode == define.Dialogue.Mode.MainMenu then
	  	 	self:ResetGrid(self.m_RightGrid)
			self:AddDialogOptionsList(self.m_CurDialog.content)
			self:AddTaskList()
			self:AddFightNpcOpionsList()
	   end
	end
end

function CDialogueNormalPage.SetContent(self, dialogData, cb)
	self.m_DialogData = dialogData
	self.m_closeCB = cb
	self:SetNextContent()
end

function CDialogueNormalPage.SetCanSkipOption(self, bCan)
	self.m_CanSkipOption = bCan
end

function CDialogueNormalPage.SetNextContent(self, uiMode, taskId, delayShow)
	self.m_IsInOption = false
	self:ResetGrid(self.m_CenterGrid)
	self:ResetGrid(self.m_RightGrid)
	local curDialogueInfo = self:GetCurDialogueInfo()
	self.m_CurDialog = curDialogueInfo

	if curDialogueInfo then
		uiMode = uiMode or curDialogueInfo.ui_mode
		self:CheckHasEndTime(self.m_DialogData)

		--如果当前是在主界面模 并且当前NPC只有1个关联任务,直接执行任务
		if uiMode == define.Dialogue.Mode.MainMenu then
			local npcId = self.m_DialogData.npcid
			local taskList = g_TaskCtrl:GetNpcAssociatedTaskList(npcId)
			local isFightNpc = g_TaskCtrl:IsFightNpc(npcId) and data.globalcontroldata.GLOBAL_CONTROL.npcfight.is_open == "y" and 
							   g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.npcfight.open_grade

			--如果在自动师门状态，则自动做师门
			if #taskList > 0 and g_TaskCtrl:IsAutoDoingShiMen() then
				for i, v in ipairs(taskList) do
					if v:GetValue("type") == define.Task.TaskCategory.SHIMEN.ID then
						if self:MainmenuTaskClickCb(v:GetValue("taskid")) then
							return
						end
					end
				end
			end

			--该如果该NPC只有1个任务，或者是挑战NPc时
			if #taskList == 1 or isFightNpc == true then
				--只是挑战NPc时，则直接请求挑战npc
				if isFightNpc == true and #taskList == 0 then
					if g_DialogueCtrl:HasNpcFightTime(npcId) then
						g_TaskCtrl:DoFightNpc(npcId)
						return
					end					

				--该Npc只是挂着一个任务时
				elseif data.globalcontroldata.GLOBAL_CONTROL.task.is_open == "y" and isFightNpc ~= true and #taskList == 1
				 and taskList[1]:GetValue("acceptgrade") <= g_AttrCtrl.grade and taskList[1]:IsPassChaterFuben() and not string.find(curDialogueInfo.content, "%&Q") then									
					taskId = taskList[1]:GetValue("taskid")
					if self:MainmenuTaskClickCb(taskId) then
						--如果该类型的任务开关已经关闭，则协议还是要发送，但是界面继续用 npcsay的协议刷新
						if g_TaskCtrl:CheckTaskTypeOpenToggle(taskList[1]) then
							uiMode = define.Dialogue.Mode.TaskMenu							
							return
						end							
					end													
				end
			end
		end
		--如果当前是在主界面模 并且当前NPC只有1个关联任务,直接执行任务

		self.m_RewardItemWidget:SetActive(false)
		self.m_MaskWidget:SetActive(false)
		self:SetViewStyle(curDialogueInfo, uiMode)

		self.m_RBContinue:SetActive(self.m_ToContinue == CDialogueNormalPage.EnumContinu.Continue and self.m_LeftDialogueLabel:GetActive())
		self.m_LBContinue:SetActive(self.m_ToContinue == CDialogueNormalPage.EnumContinu.Continue and self.m_RightDialogueLabel:GetActive())
	
		if uiMode == define.Dialogue.Mode.MainMenu then
			if not delayShow then				
				self:AddDialogOptionsList(curDialogueInfo.content)
				self:AddTaskList()
				self:AddFightNpcOpionsList()
			end
			
		elseif uiMode == define.Dialogue.Mode.Dialogue then			
			if curDialogueInfo.type == 7 then
				self:SetScreenMaskModeUI(curDialogueInfo)
			else 
				if self.m_LeftDialogueLabel:GetActive() == true then
					self.m_LeftDialogueLabel:SetText(curDialogueInfo.content)
				else
					self.m_LeftDialogueLabel:SetText("")
				end

				if self.m_RightDialogueLabel:GetActive() == true then
					self.m_RightDialogueLabel:SetText(curDialogueInfo.content)
				else
					self.m_RightDialogueLabel:SetText("")
				end				
			end		
			self.m_SocialList = nil			
			self:AddDialogSwichtOptions(curDialogueInfo.last_action)
			self:AddRewardList(self.m_DialogData.rewards)

		elseif uiMode == define.Dialogue.Mode.TaskMenu then
			local oTask = g_TaskCtrl:GetTaskById(taskId)
			if oTask then
				local targetdesc = oTask:GetValue("targetdesc")
				local status = oTask:GetValue("status")
				self.m_MidDialogueLabel:SetText(targetdesc)	
				self:AddTaskOptions(oTask)
				--self:SetTaskStatusIcon(self.m_TaskStatusSprite, status)
				self.m_TaskTitleNameLabel:SetText( g_TaskCtrl:GetTaskTitleDesc(oTask))
			end
		end

	elseif uiMode == define.Dialogue.Mode.ScreenMask then
		

	elseif uiMode == define.Dialogue.Mode.Movie then

	elseif self.m_DialogData.sessionidx then
		netother.C2GSCallback(self.m_DialogData.sessionidx)
		if self.m_closeCB then
			self.m_closeCB()
		end
	end
	self:AutoDoShiMen()
end

function CDialogueNormalPage.GetCurDialogueInfo(self)
	self.m_ToContinue = CDialogueNormalPage.EnumContinu.None
	if self.m_DialogData and self.m_DialogData.dialog and #self.m_DialogData.dialog > 0  and self.m_DialogIdx ~= 0 then	
		if self.m_DialogIdx <= #self.m_DialogData.dialog then
			local tCurInfo = table.copy(self.m_DialogData.dialog[self.m_DialogIdx]) 
			if tCurInfo.ui_mode ~= define.Dialogue.Mode.MainMenu and tCurInfo.ui_mode ~= define.Dialogue.Mode.TaskMenu then
				local nextInfo = g_DialogueCtrl:GetSwithDialogueTable(tCurInfo.next)
				if #nextInfo > 1 then
					for i = 1, #nextInfo do
						local id = nextInfo[i].id
						local str = nextInfo[i].str
						--tzq 暂时修改------------
						-- self:AddCenterOption(str, function ()
						-- 	self.m_DialogIdx = tonumber(id) 
						-- 	self:SetNextContent()
						-- end)
						self:AddRightOption(string.format("%s", str) , function ()
							self.m_DialogIdx = tonumber(id)
							self:SetNextContent()
						end, nil, false)
						----tzq--------------------------------------
					end
					self.m_ToContinue = CDialogueNormalPage.EnumContinu.Switch

				elseif #nextInfo == 1 then	
					local nextId = 	tonumber(nextInfo[1].id) 						
					self.m_DialogIdx = nextId
					if nextId ~= 0 then
						self.m_ToContinue = CDialogueNormalPage.EnumContinu.Continue
					else
						self.m_ToContinue = CDialogueNormalPage.EnumContinu.DialogEnd
					end

				else
					self.m_DialogIdx = 0
				end
			end
			return tCurInfo
		end
	end
end

function CDialogueNormalPage.GetNpcNameByType(self, dialogueType , curDialogueInfo)
	local dialogueType = dialogueType or 1
	local npcName = ""
	local npcShape = 0
	local isHero = false
	if dialogueType == 1 then
		npcName = g_AttrCtrl.name or ""
		if npcName == "" then
			npcName = "我"
		end
		npcShape = g_AttrCtrl:GetMyShape()
		isHero = true

	elseif dialogueType == 2 then
		npcName = self.m_DialogData.npc_name or ""
		npcShape = self.m_DialogData.shape or 0

	elseif dialogueType == 3 then
		if curDialogueInfo.pre_id_list and curDialogueInfo.pre_id_list ~= "" then
			local list = string.split(curDialogueInfo.pre_id_list, ",")
			local npcType = tonumber(list[1]) 
			local taskNpc = g_TaskCtrl:GetTaskNpc(npcType)

			npcName = taskNpc.name or ""
			npcShape = taskNpc.modelId		
		else
			printerror("任务对话配置有错误，对话类型 3 没配置对 ")			
		end
	
	elseif dialogueType == 4 or dialogueType == 5 then
		if curDialogueInfo.pre_id_list and curDialogueInfo.pre_id_list ~= "" then	
			local list = string.split(curDialogueInfo.pre_id_list, ",")
			if list and #list == 2 then
				local taskNpc1 = {}
				local npcType1 = tonumber(list[1]) 
				if npcType1 == 0 then
					taskNpc1.npcName =  g_AttrCtrl.name or ""
					if taskNpc1.npcName == "" then
						taskNpc1.npcName = "我"
					end					
					taskNpc1.npcShape = g_AttrCtrl:GetMyShape()
					taskNpc1.isHero1 = true
				else
					local taskNpc = g_TaskCtrl:GetTaskNpc(npcType1)
					taskNpc1.npcName = taskNpc.name or ""
					taskNpc1.npcShape = taskNpc.modelId
					taskNpc1.isHero1 = false
				end

				local taskNpc2 = {}
				local npcType2 = tonumber(list[2]) 
				local isHero2 = false
				if npcType2 == 0 then
					taskNpc2.npcName =  g_AttrCtrl.name or ""
					if taskNpc2.npcName == "" then
						taskNpc2.npcName = "我"
					end					
					taskNpc2.npcShape = g_AttrCtrl:GetMyShape()
					taskNpc2.isHero = true
				else
					local taskNpc = g_TaskCtrl:GetTaskNpc(npcType2)
					taskNpc2.npcName = taskNpc.name or ""
					taskNpc2.npcShape = taskNpc.modelId
					taskNpc2.isHero = false
				end	
				return taskNpc1.npcName, taskNpc1.npcShape, taskNpc1.isHero, taskNpc2.npcName, taskNpc2.npcShape, taskNpc2.isHero
			end
		end
		printerror("任务对话配置有错误，对话类型 4, 5 没配置对 ", curDialogueInfo.content)
	elseif dialogueType == 6 then
		if curDialogueInfo.pre_id_list and curDialogueInfo.pre_id_list ~= "" then	
			local list = string.split(curDialogueInfo.pre_id_list, ",")
			if list and #list > 1 then
				local taskNpc = {}
				for i = 1, #list do
					local npcType = tonumber(list[i]) 
					local t = {}
					if npcType == 0 then
						t.npcName =  g_AttrCtrl.name or ""
						if t.npcName == "" then
							t.npcName = "我"
						end						
						t.npcShape = g_AttrCtrl:GetMyShape()
						t.isHero = true
					else
						local taskNpc = g_TaskCtrl:GetTaskNpc(npcType)
						t.npcName = taskNpc.name or ""
						t.npcShape = taskNpc.modelId
						t.isHero = false
					end			
					table.insert(taskNpc, t)		
				end
				if #taskNpc == 2 then
					return taskNpc[1].npcName, taskNpc[1].npcShape, taskNpc[1].isHero, taskNpc[2].npcName, taskNpc[2].npcShape, taskNpc[2].isHero
				elseif #taskNpc == 3 then
					return taskNpc[1].npcName, taskNpc[1].npcShape, taskNpc[1].isHero, taskNpc[2].npcName, taskNpc[2].npcShape, taskNpc[2].isHero, taskNpc[3].npcName, taskNpc[3].npcShape, taskNpc[3].isHero
				else
					printerror("任务对话配置有错误，对话类型 6 没配置对 ", curDialogueInfo.content)	
				end					
			end
		end
		printerror("任务对话配置有错误，对话类型 6 没配置对 ", curDialogueInfo.content)

	elseif dialogueType == 7 then

	else
		printerror("获取Npc名称错误,没有对应类型的Npc", dialogueType)
	end

	return npcName, npcShape, isHero
end

function CDialogueNormalPage.SetViewStyle(self, curDialogueInfo, uiMode)
	-- 说话类型 
	-- 1：主角(单人)
	-- 2：目标npc(单人)
	-- 3：第三方npc(单人)
	-- 4：2人对话(右侧说话)
	-- 5：2人对话(左侧说话)
	-- 6：2~3人同时说话
	-- 7: 全屏遮罩
	local dialogueType = curDialogueInfo.type or 1
	self.m_LeftActorTexture:SetActive(false)
	self.m_RightActorTexture:SetActive(false)
	self.m_LeftNameWidget:SetActive(false)
	self.m_RightNameWidget:SetActive(false)
	self.m_MidNameWidget:SetActive(false)
	self.m_LeftDialogueLabel:SetActive(false)
	self.m_RightDialogueLabel:SetActive(false)
	self.m_MidDialogueLabel:SetActive(false)
	self.m_TaskTitleWidget:SetActive(false)
	self.m_MTBox:SetActive(false)
	self.m_SCSMask:SetActive(false)	
	self.m_BttomSprite:SetActive(true)
	self.m_BackBtn:SetActive(false)
	self.m_JumpBtn:SetActive(false)
	self.m_TopMaskSprite:SetActive(false)
	self.m_LeftVoiceSprite:SetActive(false)
	self.m_RightVoiceSprite:SetActive(false)
	self.m_LeftSpineTexture:SetActive(false)
	self.m_RightSpineTexture:SetActive(false)

	local SaySide = CDialogueNormalPage.SaySide.None

	local list = {}

	local function addDialogFunction(t, name, isHero)
		if name then
			local d = {}
			d.name = name
			d.isHero = isHero
			table.insert(t, d)
		end
	end

	--显示对话信息
	local npcName, npcShape, isHero, npcName2, npcShape2, isHero2, npcName3, npcShape3, isHero3 = self:GetNpcNameByType(dialogueType, curDialogueInfo)		
	npcShape = g_DialogueCtrl:GetSpecialShape(npcShape)
	npcShape2 = g_DialogueCtrl:GetSpecialShape(npcShape2)
	npcShape3 = g_DialogueCtrl:GetSpecialShape(npcShape3)

	if dialogueType == 1 or dialogueType == 2 or dialogueType == 3 then
		SaySide = CDialogueNormalPage.SaySide.Left
		self.m_LeftActorTexture:SetActive(true)
		self.m_LeftSpineTexture:SetActive(true)
		self.m_RightActorTexture:SetActive(true)
		self.m_RightSpineTexture:SetActive(true)

		local config = g_DialogueCtrl:GetDialogueSpineConfig(npcShape)	
		if config and #config >= 4 then
			local spineAnis = g_DialogueCtrl:GetDialogueSpineAni(self.m_DialogData.dialog_id, curDialogueInfo.subid, 1)
			
			if self.m_LeftSpineTexture.npcShape ~= npcShape then
				self.m_LeftSpineTexture.npcShape = npcShape
				self.m_LeftSpineTexture:SetSize(config[1], config[2])
				self.m_LeftSpineTexture:SetLocalPos(Vector3.New(-200 + config[3] , -200 + config[4], 0))						
				self.m_LeftSpineTexture:ShapeCommon(tostring(npcShape), function ()
					 self.m_LeftSpineTexture:SetSequenceAnimation(spineAnis)
				end, 1.73)	
			else
				self.m_LeftSpineTexture:SetSequenceAnimation(spineAnis)				
			end		
			self:ClearTextrue(self.m_LeftActorTexture)
		else
			if self.m_LeftActorTexture.npcShape ~= npcShape then
				self.m_LeftActorTexture:LoadDialogPhoto(npcShape)
				self.m_LeftActorTexture.npcShape = npcShape
			end
			self:ClearTextrue(self.m_LeftSpineTexture)		
		end

		self:ClearTextrue(self.m_RightActorTexture)
		self:ClearTextrue(self.m_RightSpineTexture)
		
		if uiMode == define.Dialogue.Mode.Dialogue then
			self.m_LeftDialogueLabel:SetActive(true)
			self.m_LeftNameWidget:SetActive(true)
			self.m_LeftNameLabel:SetText(self:ConverName(npcName))			

		elseif uiMode == define.Dialogue.Mode.MainMenu then			
			self.m_MidDialogueLabel:SetActive(true)
			self.m_MidNameWidget:SetActive(true)
			self.m_MidNameLabel:SetText(self:ConverName(npcName))

		elseif uiMode == define.Dialogue.Mode.TaskMenu then
			self.m_MidDialogueLabel:SetActive(true)
			self.m_TaskTitleWidget:SetActive(true)
		end
		addDialogFunction(list, npcName, isHero)

	elseif dialogueType == 4 then
		SaySide = CDialogueNormalPage.SaySide.Right
		self.m_LeftActorTexture:SetActive(true)
		self.m_LeftSpineTexture:SetActive(true)
		self.m_RightActorTexture:SetActive(true)
		self.m_RightSpineTexture:SetActive(true)
		self.m_LeftNameWidget:SetActive(false)
		self.m_LeftNameLabel:SetText(self:ConverName(npcName))
		self.m_RightNameWidget:SetActive(true)
		self.m_RightNameLabel:SetText(self:ConverName(npcName2))


		local config = g_DialogueCtrl:GetDialogueSpineConfig(npcShape2)	
		if config and #config >= 4 then
			local spineAnis = g_DialogueCtrl:GetDialogueSpineAni(self.m_DialogData.dialog_id, curDialogueInfo.subid, 2)
			if self.m_RightSpineTexture.npcShape ~= npcShape2 then
				self.m_RightSpineTexture.npcShape = npcShape2
				self.m_RightSpineTexture:SetSize(config[1], config[2])
				self.m_RightSpineTexture:SetLocalPos(Vector3.New(200 - config[3] , -200 + config[4], 0))
				self.m_RightSpineTexture:ShapeCommon(tostring(npcShape2), function ()
					 self.m_RightSpineTexture:SetSequenceAnimation(spineAnis)
				end, 1.73)	
			else
				self.m_RightSpineTexture:SetSequenceAnimation(spineAnis)
			end		
			self:ClearTextrue(self.m_RightActorTexture)
		else
			if self.m_RightActorTexture.npcShape ~= npcShape2 then
				self.m_RightActorTexture:LoadDialogPhoto(npcShape2)
				self.m_RightActorTexture.npcShape = npcShape2
			end
			self:ClearTextrue(self.m_RightSpineTexture)		
		end
		self:ClearTextrue(self.m_LeftActorTexture)
		self:ClearTextrue(self.m_LeftSpineTexture)
		self.m_RightDialogueLabel:SetActive(true)
		addDialogFunction(list, npcName2, isHero2)

	elseif dialogueType == 5 then
		SaySide = CDialogueNormalPage.SaySide.Left
		self.m_LeftActorTexture:SetActive(true)
		self.m_LeftSpineTexture:SetActive(true)
		self.m_RightActorTexture:SetActive(true)
		self.m_RightSpineTexture:SetActive(true)
		self.m_LeftNameWidget:SetActive(false)
		self.m_LeftNameWidget:SetActive(true)
		self.m_LeftNameLabel:SetText(self:ConverName(npcName))
		self.m_RightNameWidget:SetActive(false)
		self.m_RightNameLabel:SetText(self:ConverName(npcName2))	

		local config = g_DialogueCtrl:GetDialogueSpineConfig(npcShape)	
		if config and #config >= 4 then
			local spineAnis = g_DialogueCtrl:GetDialogueSpineAni(self.m_DialogData.dialog_id, curDialogueInfo.subid, 1)
			if self.m_LeftSpineTexture.npcShape ~= npcShape then
				self.m_LeftSpineTexture.npcShape = npcShape
				self.m_LeftSpineTexture:SetSize(config[1], config[2])
				self.m_LeftSpineTexture:SetLocalPos(Vector3.New(-200 + config[3] , -200 + config[4], 0))						
				self.m_LeftSpineTexture:ShapeCommon(tostring(npcShape), function ()
					 self.m_LeftSpineTexture:SetSequenceAnimation(spineAnis)
				end, 1.73)	
			else
				self.m_LeftSpineTexture:SetSequenceAnimation(spineAnis)
			end		
			self:ClearTextrue(self.m_LeftActorTexture)
		else
			if self.m_LeftActorTexture.npcShape ~= npcShape then
				self.m_LeftActorTexture:LoadDialogPhoto(npcShape)
				self.m_LeftActorTexture.npcShape = npcShape
			end
			self:ClearTextrue(self.m_LeftSpineTexture)		
		end

		self:ClearTextrue(self.m_RightActorTexture)
		self:ClearTextrue(self.m_RightSpineTexture)

		self.m_LeftDialogueLabel:SetActive(true)
		addDialogFunction(list, npcName, isHero)

	elseif dialogueType == 6 then
		self.m_MTBox:SetActive(true)
		self.m_MTBox.m_TwoBox:SetActive(false)
		self.m_MTBox.m_ThreeBox:SetActive(false)
		self.m_LeftDialogueLabel:SetActive(true)
		if npcName3 and npcShape3 then
			SaySide = CDialogueNormalPage.SaySide.All
			self.m_MTBox.m_ThreeBox:SetActive(true)
			self.m_MTBox.m_LeftName3:SetText(npcName)
			self.m_MTBox.m_LeftTextrue3:LoadDialogPhoto(npcShape)
			self.m_MTBox.m_MidName3:SetText(npcName2)
			self.m_MTBox.m_MidTexture3:LoadDialogPhoto(npcShape2)			
			self.m_MTBox.m_RightName3:SetText(npcName3)
			self.m_MTBox.m_RightTexture3:LoadDialogPhoto(npcShape3)	
		else
			SaySide = CDialogueNormalPage.SaySide.LeftAndRight
			self.m_MTBox.m_TwoBox:SetActive(true)
			self.m_MTBox.m_LeftName2:SetText(npcName)
			self.m_MTBox.m_LeftTextrue2:LoadDialogPhoto(npcShape)
			self.m_MTBox.m_RightName2:SetText(npcName2)
			self.m_MTBox.m_RightTextrue2:LoadDialogPhoto(npcShape2)	
		end
		addDialogFunction(list, npcName, isHero)
		addDialogFunction(list, npcName2, isHero2)
		addDialogFunction(list, npcName3, isHero3)

	elseif dialogueType == 7 then
		SaySide = CDialogueNormalPage.SaySide.None
		self.m_SCSMask:SetActive(true)
		self.m_SCSMask.m_MaskBg.m_Tween:Toggle()
		self.m_BttomSprite:SetActive(false)

	else
		printerror("获取Npc名称错误,没有对应类型的Npc")
	end
	g_DialogueCtrl:CheckDialogTips(true ,list)

	--显示跳转和关闭按钮
	if uiMode == define.Dialogue.Mode.Dialogue then
		if curDialogueInfo.hide_back_jump == nil and (curDialogueInfo.last_action == nil or not next(curDialogueInfo.last_action)) then
			if self.m_ShowSkip and dialogueType ~= 7 then
				self.m_JumpBtn:SetActive(true)
			end
			--隐藏返回按钮
			-- if self.m_ShowBack and dialogueType ~= 7 then
			-- 	self.m_BackBtn:SetActive(true)
			-- end
			--暂时隐藏上面按钮的底图
			self.m_TopMaskSprite:SetActive(false)
			--self.m_TopMaskSprite:SetActive(self.m_ShowSkip or self.m_ShowBack)
		end
	end

	--显示对话背景
	local temp = table.copy(curDialogueInfo)
	if temp.bgPath and temp.bgPath ~= "" then
		if self.m_BgTexture.m_Path ~= temp.bgPath then
			self.m_BgTexture:LoadPath(temp.bgPath)
			self.m_BgTexture.m_Path = temp.bgPath
		end
	else
		self.m_BgTexture.m_Path = nil
		self.m_BgTexture:SetMainTextureNil()
	end

	--处理音乐
	self:ProcessMusic(curDialogueInfo.voice, SaySide)

	--处理动态任务npc隐藏,和动态表情
	if uiMode == define.Dialogue.Mode.Dialogue then
		g_DialogueCtrl:ProgressHideDynamicNpc(self.m_DialogData.dialog_id, curDialogueInfo.subid)
		g_DialogueCtrl:ProgressDynamicSocailEmoji(self.m_DialogData.dialog_id, curDialogueInfo.subid)
	end

	--任务npc出现效果
	g_DialogueCtrl:ProgressNpcAddEffect(curDialogueInfo.pre_id_list)
end

--解析对白中的战斗战斗
function CDialogueNormalPage.AddDialogOptionsList(self, str)
	self.m_MidDialogueLabel:SetText("")
	--&Q带战斗标记的选项
	--&T不带战斗标记的选项
	if str and type(str) == "string" and string.len(str) > 0 then
		local strList = string.split(str, "%&")
		local showContent = strList[1]
		
		if showContent then
			self.m_MidDialogueLabel:SetActive(true)
			self.m_MidDialogueLabel:SetText(showContent)
		else
			self.m_MidDialogueLabel:SetActive(false)
		end
		local dOptionList = self:PraseOption(strList)
		for i, dOption in ipairs(dOptionList) do
			if dOption[1] == "Q" then
				self:AddRightOption(string.format("%s", dOption[2]), function()
					netother.C2GSCallback(self.m_DialogData.sessionidx, i)
				end, nil, true)
			elseif dOption[1] == "T" then
				self:AddRightOption(string.format("%s", dOption[2]), function()
					netother.C2GSCallback(self.m_DialogData.sessionidx, i)
					if self.m_closeCB then
						self.m_closeCB()
					end
				end, nil, false)
			end
		end
	end
end

function CDialogueNormalPage.PraseOption(self, strList)
	local dOptionList = {}
	for i = 2, #strList do
		local str = strList[i]
		local c = string.sub(str, 1, 1)
		if c == "Q" then
			table.insert(dOptionList, {"Q", string.sub(str, 2)})
		elseif c == "T" then
			table.insert(dOptionList, {"T", string.sub(str, 2)})
		else
			local iEnd = #dOptionList
			if dOptionList[iEnd] then
				dOptionList[iEnd][2] = dOptionList[iEnd][2]..string.sub(str, 1)
			end
		end
	end
	return dOptionList
end

function CDialogueNormalPage.AddFightNpcOpionsList(self)
	if data.globalcontroldata.GLOBAL_CONTROL.npcfight.is_open == "y" then
		if g_TaskCtrl:IsFightNpc(self.m_DialogData.npcid) and g_DialogueCtrl:HasNpcFightTime(self.m_DialogData.npcid) and 
		   g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.npcfight.open_grade then
			local npc = g_MapCtrl:GetNpc(self.m_DialogData.npcid)
			if npc then			
				self:AddRightOption(string.format("挑战:%s", self.m_DialogData.npc_name), function()
					g_TaskCtrl:DoFightNpc(self.m_DialogData.npcid)
				end, define.Task.TaskStatus.Accept)
			end
		end
	end
end

--解析对白中的，操作指令（战斗，组队，放弃）
function CDialogueNormalPage.AddDialogSwichtOptions(self, action)
	if action and next(action) ~= nil then
		for i = 1 , #action do	
			local isFight = false				
			if action[i].event and action[i].event ~= "" and string.find(action[i].event, "F") then
				isFight = true
			end
			local isSocial = false
			local list = {}
			if action[i].event and action[i].event ~= "" and string.find(action[i].event, "social") then
				list = string.split(action[i].event , ";")
				if list and next(list) and list[1] == "social" and #list == 3 then
					isSocial = true
					if not self.m_SocialList then
						self.m_SocialList = list
					end
				end
			end
			if self.m_DialogData.sessionidx then
				if isSocial == false then
					self:AddRightOption(string.format("%s", action[i].content) , function ()
						netother.C2GSCallback(self.m_DialogData.sessionidx, i)
						if self.m_closeCB then
							self.m_closeCB()
						end
						if action[i].event and action[i].event == "CreateDailyTrainTeam" then
							g_ActivityCtrl:CreateDailyTrainTeam()
						elseif action[i].event and action[i].event == "JoinDailyTrainTeam" then
							g_ActivityCtrl:JoinDailyTrainTeam()
						end

					end, nil, isFight)
				else
					--社交任务处理
					self:AddRightOption(string.format("%s", action[i].content) , function ()
						self:ProcessSocialChoice(list)
					end, nil, false)
				end
			elseif self.m_DialogData.isMLGuide == true then
				self:AddRightOption(string.format("%s", list[1]) , function ()
					g_ActivityCtrl:MingLeiC2GSCallback(i)
					if self.m_closeCB then
						self.m_closeCB()
					end
				end, nil, isFight)
			else
				local d = table.copy(action[i])
				if d and d.callback then
					self:AddRightOption(string.format("%s", d.content) , function ()
						d.callback()
						if self.m_closeCB then
							self.m_closeCB()
						end
					end, nil, isFight)
				end
			end
		end
	end
end

function CDialogueNormalPage.AddTaskList(self)
	local taskList = {}
	local npcId = self.m_DialogData.npcid
	local npcType = g_MapCtrl:GetNpcTypeByNpcId(npcId)
	taskList = g_TaskCtrl:GetNpcAssociatedTaskList(npcId)

	if #taskList > 0 then
		for i = 1, #taskList do
			local oTask = taskList[i]
			if oTask then
				local status = oTask:GetValue("status", npcType)
				local name = g_TaskCtrl:GetTaskTitleDesc(oTask)
				local taskId = oTask:GetValue("taskid")
				local accpetGrade = oTask:GetValue("acceptgrade")
				if g_AttrCtrl.grade >= accpetGrade then	
					local function cb()
						--主界面点击任务时，直接执行2级界面的操作
						self:MainmenuTaskClickCb(taskId)

						--self:SetNextContent(define.Dialogue.Mode.TaskMenu, taskId)						
					end

					if status == define.Task.TaskStatus.Doing then
						--self:AddRightOption(string.format("%s进行中)",name), cb, status)
						self:AddRightOption(string.format("%s",name), cb, status)

					elseif status == define.Task.TaskStatus.Accept then 
						--可接任务也显示进行中
						--self:AddRightOption(string.format("%s(进行中)",name), cb, define.Task.TaskStatus.Doing)
						self:AddRightOption(string.format("%s",name), cb, define.Task.TaskStatus.Doing)						

					elseif status == define.Task.TaskStatus.Defeated then

					elseif status == define.Task.TaskStatus.Done then
						--self:AddRightOption(string.format("%s(可提交)",name), cb, status)
						self:AddRightOption(string.format("%s",name), cb, status)

					end
				end
			end
		end
	end
end


function CDialogueNormalPage.AddTaskOptions(self, oTask)
	local npcType = g_MapCtrl:GetNpcTypeByNpcId(self.m_DialogData.npcid)
	local status = oTask:GetValue("status", npcType)
	local name = g_TaskCtrl:GetTaskTitleDesc(oTask)
	local taskId = oTask:GetValue("taskid")
	local npcId = self.m_DialogData.npcid
	local accpetGrade = oTask:GetValue("acceptgrade")

	if status == define.Task.TaskStatus.Doing then
		self:AddRightOption("[714F22]继续任务", function ()	
			if g_TaskCtrl:CheckOpenChapterTask(oTask) then
				--跳转到剧情副本		
			elseif g_AttrCtrl.grade >= accpetGrade then	
				if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSTaskEvent"]) then
					nettask.C2GSTaskEvent(taskId, npcId)
				end
				self.m_ParentView:CloseView()
			else
				g_NotifyCtrl:FloatMsg("等级不足，看看冒险里有什么活动参加吧")
			end
		end)

		self:AddRightOption("[714F22]我再想想", function()
			self:SetNextContent()
		end)

	elseif status == define.Task.TaskStatus.Accept then
		self:AddRightOption(string.format("%s", name), function()	
			if g_TaskCtrl:CheckOpenChapterTask(oTask) then
				--跳转到剧情副本
			elseif g_AttrCtrl.grade >= accpetGrade then
				g_TaskCtrl:C2GSAcceptTask(taskId)		
				self.m_ParentView:CloseView()
			else
				g_NotifyCtrl:FloatMsg("等级不足，看看冒险里有什么活动参加吧")
			end			
		end)

		self:AddRightOption("[714F22]我再想想", function()
			self:SetNextContent()
		end)

	elseif status == define.Task.TaskStatus.Defeated then

	elseif status == define.Task.TaskStatus.Done then
		self:AddRightOption("[714F22]提交任务", function()
			if not g_TaskCtrl:CheckOpenChapterTask(oTask) then
				if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSTaskEvent"]) then
					nettask.C2GSTaskEvent(taskId, npcId)
				end
			end

			self.m_ParentView:CloseView()
		end)	
	end

end

function CDialogueNormalPage.MainmenuTaskClickCb(self, taskId)
	local oTask = g_TaskCtrl:GetTaskById(taskId)
	local npcType = g_MapCtrl:GetNpcTypeByNpcId(self.m_DialogData.npcid)
	local status = oTask:GetValue("status", npcType)
	local name = g_TaskCtrl:GetTaskTitleDesc(oTask)
	local taskId = oTask:GetValue("taskid")
	local npcId = self.m_DialogData.npcid
	local accpetGrade = oTask:GetValue("acceptgrade")
	local b = false

	if status == define.Task.TaskStatus.Doing then
		if g_TaskCtrl:CheckOpenChapterTask(oTask) then
			--跳转到剧情副本
			b = true		
		elseif g_AttrCtrl.grade >= accpetGrade then	
			if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSTaskEvent"]) then
				nettask.C2GSTaskEvent(taskId, npcId)
			end
			self.m_ParentView:CloseView()
			b = true			
		else
			g_NotifyCtrl:FloatMsg("等级不足，看看冒险里有什么活动参加吧")
		end

	elseif status == define.Task.TaskStatus.Accept then
		if g_TaskCtrl:CheckOpenChapterTask(oTask) then
			--跳转到剧情副本			
			b = true
		elseif g_AttrCtrl.grade >= accpetGrade then
			g_TaskCtrl:C2GSAcceptTask(taskId)		
			self.m_ParentView:CloseView()
			b = true			
		else
			g_NotifyCtrl:FloatMsg("等级不足，看看冒险里有什么活动参加吧")
		end			
	elseif status == define.Task.TaskStatus.Defeated then


	elseif status == define.Task.TaskStatus.Done then
		if not g_TaskCtrl:CheckOpenChapterTask(oTask) then
			if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSTaskEvent"]) then
				nettask.C2GSTaskEvent(taskId, npcId)
			end
		end

		self.m_ParentView:CloseView()
		b = true

	elseif status == define.Task.TaskStatus.HasCommmit then

	end
	return b
end

function CDialogueNormalPage.ResetGrid(self, grid)
	if grid then
		local childList = grid:GetChildList() or {}
		if childList and #childList > 0 then
			for i = 1, #childList do
				local oBox = childList[i]
				if oBox and oBox:GetActive() == true then
					oBox:SetActive(false)
				end
			end
		end
	end
end

function CDialogueNormalPage.AddCenterOption(self, text, cb)
	self:AddOption(text, cb, self.m_CenterGrid, self.m_CenterOptionBox, self.m_CenterBtnList)
end

function CDialogueNormalPage.AddRightOption(self, text, cb, status, isFight)
	self:AddOption(text, cb, self.m_RightGrid, self.m_RightOptionBox, status, self.m_RightBtnList, isFight)
end

function CDialogueNormalPage.AddOption(self, text, cb, grid, clone, status, btnPool, isFight)
	self.m_IsInOption = true
	if grid then
		local oBox = nil
		if btnPool and next(btnPool) ~= nil and #btnPool > 0 then
			for i = 1, #btnPool do
				if btnPool[i] and btnPool[i]:GetActive() == false then
					oBox = btnPool[i]
					break
				end
			end
		end  
		if oBox == nil then
			oBox = clone:Clone()
			oBox.m_TextLabel = oBox:NewUI(1, CLabel) 
			oBox.m_WenHaoWidget = oBox:NewUI(2, CBox)
			oBox.m_TanHaoWidget = oBox:NewUI(3, CBox)
			oBox.m_ZhandouWidget = oBox:NewUI(4, CBox)
			table.insert(btnPool, oBox)
			if #btnPool == 1 then				
				if self.m_DialogData and self.m_DialogData.dialog_id == 10003 then
					g_GuideCtrl:AddGuideUI("dialogue_right_10003_btn_1", oBox)
				elseif self.m_DialogData and self.m_DialogData.dialog_id == 10008 then
					g_GuideCtrl:AddGuideUI("dialogue_right_10008_btn_1", oBox)
				else
					g_GuideCtrl:AddGuideUI("dialogue_right_btn_1", oBox)
				end				
			end
			oBox.m_Idx = #btnPool
			grid:AddChild(oBox)
		end
		oBox:SetActive(true)
		oBox.m_TextLabel:SetText(text)
		self:SetTaskStatusIcon(oBox, status, isFight)
		oBox:AddUIEvent("click", cb)
		grid:Reposition()

		--引导
		if self.m_DialogData and self.m_DialogData.dialog_id == 10001 and self.m_CurDialog and self.m_CurDialog.ui_mode == define.Dialogue.Mode.Dialogue 
			and self.m_CurDialog.last_action and next(self.m_CurDialog.last_action) and isFight == true then
			local d 
			if data.guidedata.StoryDlg and data.guidedata.StoryDlg.guide_list[1].effect_list[2] then 
				d = data.guidedata.StoryDlg.guide_list[1].effect_list[2]
			end
			if d then
				oBox:DelEffect(d.ui_effect)
				local pos = Vector2.New(0,0)
				if d.near_pos then
					pos.x = d.near_pos.x
					pos.y = d.near_pos.y
				end
				oBox:AddEffect(d.ui_effect, nil, pos)				
			end			
		end

		--任务10004 提示手指
		if self.m_DialogData and self.m_DialogData.dialog_id == 10004 and self.m_CurDialog and self.m_CurDialog.ui_mode == define.Dialogue.Mode.Dialogue 
			and self.m_CurDialog.last_action and next(self.m_CurDialog.last_action) and oBox.m_Idx == 1 then			
			local pos = Vector2.New(-10,0)
			oBox:AddEffect("Finger", nil, pos)		
		elseif self.m_DialogData and self.m_DialogData.dialog_id == 10008 and self.m_CurDialog and self.m_CurDialog.ui_mode == define.Dialogue.Mode.Dialogue 
			and self.m_CurDialog.last_action and next(self.m_CurDialog.last_action) and oBox.m_Idx == 1 then	
			oBox:AddEffect("Finger", nil)				
		end		
		--引导	
	end
end

function CDialogueNormalPage.OnContinue(self, force)
	--当前正在播放播放字的动画，则停止播放
	if self.m_IsTextAni then
		self:SetTextAniFinsh()
		return
	end

	--当前正在选择是战斗，则不能关闭画面 
	if force ~= true and self:IsCurDialogueHasLastaction() and self:GetCurDialogueUiMode() == define.Dialogue.Mode.Dialogue then
		return
	end
	printc("OnContinue", self.m_ToContinue)
	if self.m_ToContinue == CDialogueNormalPage.EnumContinu.Continue then
		self:SetNextContent()

	elseif self.m_ToContinue == CDialogueNormalPage.EnumContinu.DialogEnd then
		if self.m_DialogData.sessionidx and self.m_DialogData.sessionidx ~= 0 then
			netother.C2GSCallback(self.m_DialogData.sessionidx)
		end		
		self.m_ParentView:CloseView()

 	elseif self.m_ToContinue == CDialogueNormalPage.EnumContinu.ScreenMask then

	end
end

function CDialogueNormalPage.OnNext(self)
	--当前正在播放播放字的动画，则停止播放
	if self.m_IsTextAni then
		self:SetTextAniFinsh()
		return
	end

	--当前正在选择是战斗，则不能关闭画面 
	if self:IsCurDialogueHasLastaction() and self:GetCurDialogueUiMode() == define.Dialogue.Mode.Dialogue then
		return
	end
	if self.m_IsInOption and not self.m_CanSkipOption then
		return
	end

	printc("OnNext", self.m_ToContinue)
	if self.m_ToContinue == CDialogueNormalPage.EnumContinu.Continue then
		self:SetNextContent()

	elseif self.m_ToContinue == CDialogueNormalPage.EnumContinu.DialogEnd or 
		self.m_ToContinue == CDialogueNormalPage.EnumContinu.None or 
		self.m_ToContinue == CDialogueNormalPage.EnumContinu.Switch then
		if self.m_DialogData.sessionidx and self.m_DialogData.sessionidx ~= 0 then
			netother.C2GSCallback(self.m_DialogData.sessionidx)
		end		
		self.m_ParentView:CloseView()

 	elseif self.m_ToContinue == CDialogueNormalPage.EnumContinu.ScreenMask then

	end
end

function CDialogueNormalPage.OnShowItemTips(self, sid, parId, oBox)
	g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(sid,
	{widget=  oBox, openView = self.m_ParentView}, parId)
end

function CDialogueNormalPage.SetTaskStatusIcon(self, oBox, status, isFight)
	if oBox and oBox.m_WenHaoWidget and oBox.m_TanHaoWidget and oBox.m_ZhandouWidget then
		oBox.m_WenHaoWidget:SetActive(false)
		oBox.m_TanHaoWidget:SetActive(false)
		oBox.m_ZhandouWidget:SetActive(false)
		if isFight == true then
			oBox.m_ZhandouWidget:SetActive(true)
		else
			if status then
				if status == define.Task.TaskStatus.Accept then
					oBox.m_TanHaoWidget:SetActive(true)
				else
					oBox.m_WenHaoWidget:SetActive(true)
				end
			end
		end		
	end
end

--检测是否有倒计时
function CDialogueNormalPage.CheckHasEndTime(self, dialogData)
	dialogData = dialogData or {}
	--判断贪玩童子
	if dialogData.playboyinfo and dialogData.playboyinfo.endtime then
		self:SetLeftTimeLabel(dialogData.playboyinfo.endtime)	
	end
end

function CDialogueNormalPage.SetLeftTimeLabel(self, lefttime)
	if self.m_LeftTimer then
		Utils.DelTimer(self.m_LeftTimer)
		self.m_LeftTimer = nil
	end
	self.m_LeftTimeLabel:SetActive(true)
	local itme = lefttime
	local function countdown()
		if Utils.IsNil(self) then
			return
		end
		itme = itme - 1
		if itme <= 0 then
			self.m_LeftTimeLabel:SetActive(false)
			return
		end
		self.m_LeftTimeLabel:SetText(os.date("%M:%S", itme))
		return true
	end
	self.m_LeftTimer = Utils.AddTimer(countdown, 1, 0)
end

function CDialogueNormalPage.SetScreenMaskModeUI(self, dialogData)
	local str = dialogData.content	
	if str and str ~= "" then
		local list = string.split(str, ",")
		if #list >= 2 then			
			local conetent = tostring(list[1])
			local time = tonumber(list[2])			
			self.m_SCSMask.m_ContentLabel:SetText(conetent)
			self.m_SCSMask.m_ContinueLabel:SetActive(false)
			self.m_RBContinue:SetActive(false)
			if self.m_ScreenMaskTimer ~= nil then
				Utils.DelTimer(self.m_ScreenMaskTimer)
				self.m_ScreenMaskTimer = nil
			end
			if self.m_ScreenMaskAlphaTimer ~= nil then
				Utils.DelTimer(self.m_ScreenMaskAlphaTimer)
				self.m_ScreenMaskAlphaTimer = nil
			end
			local tempToContineu = self.m_ToContinue
			self.m_ToContinue = CDialogueNormalPage.EnumContinu.ScreenMask
			local function wrap()
				self.m_SCSMask.m_ContinueLabel:SetActive(true)
				self.m_ToContinue = tempToContineu
			end
			self.m_ScreenMaskTimer = Utils.AddTimer(wrap, 0, time)		
			if list[3] then
				local timeAlpha = tonumber(list[3])
				self.m_SCSMask.m_ContentLabel:SetActive(false)
				local function wrap2()
					self.m_SCSMask.m_ContentLabel:SetActive(true)
					self.m_SCSMask.m_ContentLabel.m_Tween:Toggle()
				end				
				self.m_ScreenMaskAlphaTimer = Utils.AddTimer(wrap2, 0, timeAlpha)				
			else
				self.m_SCSMask.m_ContentLabel:SetActive(true)				
			end
		end
	end
end

function CDialogueNormalPage.Destroy(self)
	if self.m_ScreenMaskTimer then
		Utils.DelTimer(self.m_ScreenMaskTimer)
		self.m_ScreenMaskTimer = nil
	end
	if self.m_ScreenMaskAlphaTimer then
		Utils.DelTimer(self.m_ScreenMaskAlphaTimer)
		self.m_ScreenMaskAlphaTimer = nil
	end
	if self.m_SocialTimer then
		Utils.DelTimer(self.m_SocialTimer)
		self.m_SocialTimer = nil
	end
	self:StopAutoDoingTaskTimer()
	g_DialogueCtrl:CheckDialogTips(false)
	g_TaskCtrl:RefreshMark()
	CPageBase.Destroy(self)
end

function CDialogueNormalPage.TextStartCallBack(self)
	self.m_IsTextAni = true
end

function CDialogueNormalPage.TextEndCallBack(self)
	self.m_IsTextAni = false	
end

function CDialogueNormalPage.SetTextAniFinsh(self)
	if self.m_LeftDialogueLabel:GetActive() then
		self.m_LeftDialogueLabel:SetFinsh()
	end
	if self.m_MidDialogueLabel:GetActive() then
		self.m_MidDialogueLabel:SetFinsh()
	end
	if self.m_RightDialogueLabel:GetActive() then
		self.m_RightDialogueLabel:SetFinsh()
	end
end

function CDialogueNormalPage.OnBack(self)
	if self.m_ParentView then
		self.m_ParentView:CloseView()
	end
end

function CDialogueNormalPage.IsDialogueHasLastaction(self)
	local dialogueList = self.m_DialogData.dialog 
	local hasLastAction = false
	local dilaogueIndex = 1
	if dialogueList and next(dialogueList) then
		for i = 1, #dialogueList do
			if dialogueList[i].last_action and next(dialogueList[i].last_action) then
				hasLastAction = true
				dilaogueIndex = i
				break
			end
		end
	end
	return hasLastAction, dilaogueIndex
end

function CDialogueNormalPage.IsCurDialogueHasLastaction(self)
	local hasLastAction = false
	if self.m_CurDialog and self.m_CurDialog.last_action and next(self.m_CurDialog.last_action) then
		hasLastAction = true
	end
	return hasLastAction
end

function CDialogueNormalPage.GetCurDialogueUiMode(self)
	local mode = define.Dialogue.Mode.MainMenu 
	if self.m_CurDialog and self.m_CurDialog.ui_mode then
		mode = self.m_CurDialog.ui_mode
	end
	return mode 
end

function CDialogueNormalPage.OnJump(self)
	local hasLastAction , index = self:IsDialogueHasLastaction()
	if hasLastAction and not self:IsTargetTaskType(define.Task.TaskType.TASK_SOCIAL) and self.m_DialogIdx ~= 0 and index > self.m_DialogIdx then
		self.m_DialogIdx = index		
		self:SetNextContent()
	else
		if self.m_DialogData.sessionidx and self.m_DialogData.sessionidx ~= 0 then
			netother.C2GSCallback(self.m_DialogData.sessionidx)
		end		

		if self:GetCurDialogueUiMode() == define.Dialogue.Mode.Dialogue then
			g_DialogueCtrl:ProgressWhenJumpView(self.m_DialogData)
		end

		if self.m_ParentView then
			self.m_ParentView:CloseView()
		end
	end
end

function CDialogueNormalPage.ProcessMusic(self, voiceId, SaySide)
	if not voiceId or voiceId == 0 then 
		g_AudioCtrl:OnStopPlay()
		self.m_ParentView.m_DialogueVoice = nil
	else
		if SaySide == CDialogueNormalPage.SaySide.Left then
			self.m_LeftVoiceSprite:SetActive(true)
		elseif SaySide == CDialogueNormalPage.SaySide.Right then
			self.m_RightVoiceSprite:SetActive(true)
		end
		g_AudioCtrl:PlayVoice(voiceId)
		self.m_ParentView.m_DialogueVoice = voiceId
	end
end

function CDialogueNormalPage.ClearTextrue(self, oTextrue)
	if oTextrue then
		oTextrue:SetMainTextureNil()
		oTextrue.npcShape = nil
	end
end

function CDialogueNormalPage.AddRewardList(self, list)
	if not list or not next(list) then
		self.m_RewardItemWidget:SetActive(false)
	else
		
		local itemList = g_DialogueCtrl:GetNpcFightRewardItmeList(list)
		local partId = tonumber(data.globaldata.GLOBAL.partner_reward_itemid.value)
		if itemList and next(itemList) then
			self.m_RewardItemWidget:SetActive(true)
			self.m_RewardItemGird:Clear()
			for i, v in ipairs(itemList) do
				local oBox = self.m_RewardItemBox:Clone()
				oBox:SetActive(true)
				local config = {isLocal = true,}
				if v.sid == partId then
					oBox:SetItemData(v.sid, v.amount, v.partnerId, config)
				else
					oBox:SetItemData(v.sid, v.amount, nil, config)			
				end				
				self.m_RewardItemGird:AddChild(oBox)
			end
			self.m_RewardItemGird:Reposition()
		else
			self.m_RewardItemWidget:SetActive(false)
		end
	end
end

function CDialogueNormalPage.AutoDoShiMen(self)
	if g_TaskCtrl:IsAutoDoingShiMen() or self:IsTargetDialogue(define.Task.TaskCategory.STORY.ID) then
		if self:IsTargetDialogue(define.Task.TaskCategory.SHIMEN.ID) or self:IsTargetDialogue(define.Task.TaskCategory.STORY.ID) then
			self:StopAutoDoingTaskTimer()
			local cb = function ()
				if Utils.IsNil(self) then
					return
				end				
				self:SetTextAniFinsh()
				if self:IsTargetTaskType(define.Task.TaskType.TASK_SOCIAL) and self.m_SocialList then
					if self.m_IsDoingSocial ~= true then
						self:ProcessSocialChoice(self.m_SocialList)
					end					
					return true
				end
				local b, idx = self:IsDialogueHasLastaction()				
				if b then					
					if self.m_ToContinue == CDialogueNormalPage.EnumContinu.DialogEnd then
						netother.C2GSCallback(self.m_DialogData.sessionidx , 1)
						self.m_ParentView:CloseView()
						return false
					else						
						self:OnContinue()
						return true
					end								
				else														
					if self.m_ToContinue == CDialogueNormalPage.EnumContinu.DialogEnd then
						self:OnContinue()
						return false
					else
						self:OnContinue()
						return true
					end								
				end
			end
			local time = CTaskCtrl.AutoDoingSM.Time
			if self:IsTargetDialogue(define.Task.TaskCategory.STORY.ID) then
				time = 15
			end
			self.m_AutoDoingTaskTimer = Utils.AddTimer(cb, time, time)	
		end
	end
end

function CDialogueNormalPage.StopAutoDoingTaskTimer(self)
	if self.m_AutoDoingTaskTimer then
		Utils.DelTimer(self.m_AutoDoingTaskTimer)
		self.m_AutoDoingTaskTimer = nil
	end
end

function CDialogueNormalPage.IsTargetDialogue(self, iType )
	if self.m_DialogData.task_big_type == iType then
		return true
	end
end

function CDialogueNormalPage.IsTargetTaskType(self, iType )
	if self.m_DialogData.task_small_type == iType then
		return true
	end
end

--某些怪物名字带颜色，则把颜色替换为UI名字的颜色
function CDialogueNormalPage.ConverName(self, oName)
	local name = oName
	local i, j = string.find(oName, "]") 
	if i and j and i == j then
		name = string.gsub(name, string.sub(name, 2, i - 1), "FAAB27")
	else
		name = string.format("%s%s", "[FAAB27]", name)
	end
	return name
end

--处理社交任务选项
function CDialogueNormalPage.ProcessSocialChoice(self, list)
	self.m_SocialTimer = nil
	if self.m_SocialTimer then
		Utils.DelTimer(self.m_SocialTimer)
		self.m_SocialTimer = nil 
	end
	if list and next(list) then
		self.m_IsDoingSocial = true
		nethuodong.C2GSSocailDisplay(tonumber(list[2]), 0)
		self:SetBaseGroupVisible(false)
		if self.m_ToContinue ~= CDialogueNormalPage.EnumContinu.DialogEnd then
			self.m_SocialTimer = Utils.AddTimer(callback(self, "ProcessSocialChoiceCallback"), 0, tonumber(list[3]))
		else
			self.m_SocialTimer = Utils.AddTimer(callback(self, "ProcessSocialChoiceEndCallback"), 0, tonumber(list[3]))
		end		
	end
end

function CDialogueNormalPage.ProcessSocialChoiceCallback(self)
	self.m_IsDoingSocial = false
	self:OnContinue(true)
	self:SetBaseGroupVisible(true)
end

function CDialogueNormalPage.ProcessSocialChoiceEndCallback(self)
	self.m_IsDoingSocial = false
	if self.m_DialogData.sessionidx and self.m_DialogData.sessionidx ~= 0 then
		netother.C2GSCallback(self.m_DialogData.sessionidx)
	end		
	self.m_ParentView:CloseView()
end

function CDialogueNormalPage.SetBaseGroupVisible(self, b)
	self.m_BaseWidget:SetActive(b)
	self.m_MaskWidget:SetActive(not b)	
end

return CDialogueNormalPage