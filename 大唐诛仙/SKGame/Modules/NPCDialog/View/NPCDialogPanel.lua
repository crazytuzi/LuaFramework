NPCDialogPanel =BaseClass(BaseView)

-- (Constructor) use NPCDialogPanel.New(...)
function NPCDialogPanel:__init( ... )
	self.URL = "ui://y1al0f5qtjjea";

	self.ui = UIPackage.CreateObject("NPCDialog","NPCDialogPanel");

	self.id = "NPCDialogPanel"

	
	self.img_bg = self.ui:GetChild("img_bg")
	self.img_npc_name_bg = self.ui:GetChild("img_npc_name_bg")
	self.model_npc = self.ui:GetChild("model_npc")
	self.label_npc_name = self.ui:GetChild("label_npc_name")
	self.label_npc_dialog = self.ui:GetChild("label_npc_dialog")
	self.button_next = self.ui:GetChild("button_next")
	self.button_skip = self.ui:GetChild("button_skip")
	self.task_state_select = self.ui:GetChild("task_state_select")
	self.button_mask = self.ui:GetChild("button_mask")



	self:InitData()
	self:InitUI()
	self:SetDefaultUI()
	self:InitEvent()
end
function NPCDialogPanel:InitEvent()

	self.closeCallback = function () 
		if self.task_state_select then
			self.task_state_select:CleanData()
		end

		self.button_mask.onClick:Clear()
	end
	self.openCallback  = function ()
		self.isEndDialog = false
	end

	self.button_skip.onClick:Add(self.OnSkipBtnClick, self)
	self.button_next.onClick:Add(self.OnNextBtnClick, self)

end


function NPCDialogPanel:InitData()
	self.curDialogContent = {}
	self.lastDialogNPCDressStyle = -1
	self.curDialogType = TaskConst.NPCTaskDialogType.None
	self.curTaskId = -1
	self.model = NPCDialogModel:GetInstance()
	self.controller = NPCDialogController:GetInstance()
	self.npcCfg = GetCfgData("npc")
	self.isEndDialog = false
	self.curModelType = NPCDialogConst.ModelType.None
	self.curModelObj = nil
	
end

function NPCDialogPanel:InitUI()
	
	self.task_state_select = TaskStateSelect.Create(self.task_state_select)
	

	self.label_npc_name.text = ""
	self.label_npc_dialog.text = ""

end

function NPCDialogPanel:SetDefaultUI()
	
	self.model:ResetDialogProcess()
	self.model:AddDialogProcess()
	self:SetData()
	self:SetUI()
end

function NPCDialogPanel:OnSkipBtnClick()
	if self.isEndDialog == false then
		self.isEndDialog = true

		self:CleanData()
		self:Close()
		self.controller:CompleteDialogTask()
		
		self:DispatchSumbitDramaEnd()
		self.model:EndDialogTask()
	end
end

function NPCDialogPanel:DispatchSumbitDramaEnd()
	if self.model:GetInstance():GetDialogType() ==  TaskConst.NPCTaskDialogType.SubmitTaskDramaType then
		
		GlobalDispatcher:DispatchEvent(EventName.FinishSubmitDramaDialog, self.curTaskId)
	end
end

function NPCDialogPanel:OnNextBtnClick()
	
	if not self.model:DialogIsEnd() then
		self.model:AddDialogProcess()
		self:SetData()
		self:SetUI()
	else
		if self.isEndDialog == false then
			self.isEndDialog = true
			self:CleanData()
			self:Close()
			self.controller:CompleteDialogTask()
			
			self:DispatchSumbitDramaEnd()
			self.model:EndDialogTask()
		end
	end
end


function NPCDialogPanel:CleanData()
	self.curDialogContent = {}
	self.curDialogType = TaskConst.NPCTaskDialogType.None
end

function NPCDialogPanel:SetData()
	self.curDialogContent = self.model:GetDialogContentByProcess()
	self.curDialogType = self.model:GetDialogType()
	local taskData = self.model:GetTaskData()
	if not TableIsEmpty(taskData) then
		self.curTaskId = taskData:GetTaskId()
	end
end

function NPCDialogPanel:SetUI()
	if self.task_state_select then
		self.task_state_select:SetVisible(false)
	end
	if self.button_next then
		self.button_next.visible = true
	end

	if self.button_skip then
		self.button_skip.visible = true
	end
	--self.button_mask.enabled = true
	--self.button_mask.onClick:Clear()
	if self.button_mask then
		self.button_mask.onClick:Add(self.OnNextBtnClick, self)
	end

	if self.curDialogType == TaskConst.NPCTaskDialogType.DramaType then
		--设置领取任务剧情对白UI
		local curNpcId = tonumber(self.curDialogContent.npcID) or -1 --如果是0的话就是玩家自己
		if curNpcId ~= -1  then
			if curNpcId ~= 0 and curNpcId ~= 1 then
				local curNpcCfg = self.npcCfg:Get(curNpcId)
				
				if curNpcCfg ~= nil then
					self.curModelType = NPCDialogConst.ModelType.NPC

					if self.label_npc_name ~= nil then
						self.label_npc_name.text = curNpcCfg.name or ""
						self.label_npc_name.visible = true
					end

					if ToLuaIsNull(self.model_npc) == false then
						self.model_npc.visible = true
					end

					self.img_npc_name_bg.visible = true
				end

			end

			if curNpcId == 0 then
				self.curModelType = NPCDialogConst.ModelType.Player

				local mainPlayer = SceneModel:GetInstance():GetMainPlayer()
				if mainPlayer then
					self.label_npc_name.text = mainPlayer.name or ""
				end
				
				
				self.label_npc_name.visible = true
				self.model_npc.visible = true
				self.img_npc_name_bg.visible = true
			end

			if curNpcId == 1 then
				self.curModelType = NPCDialogConst.ModelType.None

				local mainPlayer = SceneModel:GetInstance():GetMainPlayer()
				self.model_npc.visible = false
				self.label_npc_name.visible = false
				self.img_npc_name_bg.visible = false
				--self.label_npc_name.text = "旁白"
			end
		end
		
		self.label_npc_dialog.text = self.curDialogContent.dramaContent or ""

		local curNpcCfg = self.npcCfg:Get(curNpcId)
		if curNpcCfg then
			if self.lastDialogNPCDressStyle ~= curNpcCfg.dressStyle  then
				if curNpcCfg.dressStyle ~= "" then
					self:LoadModel(curNpcCfg.dressStyle)
					self.lastDialogNPCDressStyle = curNpcCfg.dressStyle
					self.model_npc.visible = true
				else
					self.model_npc.visible = false
				end
			end
		end

	elseif self.curDialogType == TaskConst.NPCTaskDialogType.SubmitTaskDramaType then
		--设置完成任务剧情对白UI
		local curNpcId = self.curDialogContent.submitNpc or -1
		
		if curNpcId ~= -1 then
			local curNpcCfg = self.npcCfg:Get(curNpcId)
			if curNpcCfg ~= nil then
				self.label_npc_name.text = curNpcCfg.name or ""
				self.curModelType = NPCDialogConst.ModelType.NPC

				if self.lastDialogNPCDressStyle ~= curNpcCfg.dressStyle then
					if curNpcCfg.dressStyle ~= "" then
						self:LoadModel(curNpcCfg.dressStyle)
						self.lastDialogNPCDressStyle = curNpcCfg.dressStyle
						self.model_npc.visible = true
					else
						self.model_npc.visible = false
					end
				end
			end

			self.label_npc_dialog.text = self.curDialogContent.submitWord or ""
			
			--self.model_npc.visible = true
			
		end
	end
end

--点击某个NPC，弹出对应的NPC对话UI
function NPCDialogPanel:SetNPCUI(npcId, taskDataList, funId)
	self.model_npc.visible = true
	self.button_next.visible = false
	self.button_skip.visible = false
	--self.button_mask.enabled = false
	self.button_mask.onClick:Clear()
	self.button_mask.onClick:Add(function ()
		self:Close()
	end)

	if npcId then
		local curNpcCfg = self.npcCfg:Get(npcId)
		if not TableIsEmpty(curNpcCfg) then
			self.curModelType = NPCDialogConst.ModelType.NPC
			if self.lastDialogNPCDressStyle ~= curNpcCfg.dressStyle then
				if curNpcCfg.dressStyle ~= "" then
					self:LoadModel(curNpcCfg.dressStyle)
					self.lastDialogNPCDressStyle = curNpcCfg.dressStyle
					self.model_npc.visible = true
				else
					self.model_npc.visible = false
				end
			end
			self.label_npc_name.text = curNpcCfg.name
			self.label_npc_dialog.text = curNpcCfg.dialog

		end
	end
	
	if taskDataList and funId then
		if self.task_state_select then
			self.task_state_select:SetUI(taskDataList, funId)
		end
	end

end


function NPCDialogPanel:LoadModel(modelId)
	
	if self.curModelType == NPCDialogConst.ModelType.Player then
		self:LockBtn(false)
		LoadPlayer(modelId, function(model)
			if ToLuaIsNull(model) then self:LockBtn(true) return end
			if ToLuaIsNull(self.model_npc) then return end

			local modelObj = GameObject.Instantiate(model)
			modelObj.transform.localPosition = Vector3.New(0, 0, 0)
			modelObj.transform.localScale = Vector3.New(0.5, 0.5, 0.5)
			modelObj.transform.localRotation = Quaternion.Euler(0, 0, 0)
			self.curModelObj = modelObj

			self.model_npc:SetNativeObject(GoWrapper.New(modelObj))
			
			self:LockBtn(true)
		end)
	elseif self.curModelType == NPCDialogConst.ModelType.NPC then
		
		self:LockBtn(false)
		LoadNPC(modelId, function (model)
			if ToLuaIsNull(model) then self:LockBtn(true) return end
			if ToLuaIsNull(self.model_npc) then return end
			
			local modelObj = GameObject.Instantiate(model)
			modelObj.transform.localPosition = Vector3.New(43, -267, 0)
			modelObj.transform.localScale = modelObj.transform.localScale*260
			modelObj.transform.localRotation = Quaternion.Euler(0, 160, 0)
			self.curModelObj = modelObj
			
			self.model_npc:SetNativeObject(GoWrapper.New(modelObj))
			self:LockBtn(true)
		end)
	else

	end
end

function NPCDialogPanel:LockBtn(isLook)
	self.button_next.enabled = isLook
end

-- Dispose use NPCDialogPanel obj:Destroy()
function NPCDialogPanel:__delete()
	self:CleanData()
	self.isEndDialog = false
	
	if self.curModelObj ~= nil then
		destroyImmediate(self.curModelObj) 
		self.curModelObj = nil
	end

	if self.task_state_select ~= nil then
		self.task_state_select:Destroy()
		self.task_state_select = nil
	end

	self.img_bg = nil
	self.img_npc_name_bg = nil
	self.model_npc = nil
	self.label_npc_name = nil
	self.label_npc_dialog = nil
	self.button_next = nil
	self.button_skip = nil
	self.button_mask = nil
	
end