--
-- @Author: LaoY
-- @Date:   2018-09-19 19:57:36
--
TaskTalkNovicePanel = TaskTalkNovicePanel or class("TaskTalkNovicePanel",BasePanel)

function TaskTalkNovicePanel:ctor()
	self.abName = "main"
	self.assetName = "TaskTalkNovicePanel"
	self.layer = LayerManager.LayerNameList.UI

	self.use_background = false
	self.change_scene_close = true
	self.click_bg_close = true
	self.is_hide_other_panel = true
	self.is_exist_always = true
	self.is_hide_model_effect = false

	self.item_list = {}
	self.model = TaskModel:GetInstance()
	self.roleInfoModel = RoleInfoModel:GetInstance():GetMainRoleData()

end

function TaskTalkNovicePanel:dctor()
	if self.global_event_list then
		GlobalEvent:RemoveTabListener(self.global_event_list)
		self.global_event_list = {}
	end

	if self.npc_model then
		self.npc_model:destroy()
		self.npc_model = nil
	end

	self:ClearRT()

	if self.ui_effect then
		self.ui_effect:destroy()
	end
	--self.model.isOpenNpcPanel = false
end

function TaskTalkNovicePanel:Open(task_id,prog,content_str,call_back,npc_id)
	self.model.isOpenNpcPanel = true
	self.task_id = task_id
	self.prog = prog or self.model:GetTaskProg(task_id)


	self.call_back = call_back

	if npc_id then
		self.npc_id = npc_id
	end


	local vo = TaskModel:GetInstance():GetTask(self.task_id)
	if self.task_id then
		if vo.task_type == enum.TASK_TYPE.TASK_TYPE_DAILY or vo.task_type == enum.TASK_TYPE.TASK_TYPE_GUILD then
			self.config = vo
		else
			self.config = Config.db_task[self.task_id]
		end
		if not self.config then
			return
		end
		local goals = vo.goals or {}
		self.goal = goals[self.prog] or {}
		if vo.task_type == enum.TASK_TYPE.TASK_TYPE_DAILY or vo.task_type == enum.TASK_TYPE.TASK_TYPE_GUILD then
			self.goal = goals[1] or {}
			local next_goal = goals[2]
			if next_goal then
				local goal_type = next_goal[1]
				local target_id = next_goal[2]
				if goal_type == enum.EVENT.EVENT_DUNGE or 
				goal_type == enum.EVENT.EVENT_DUNGE_FLOOR or 
				goal_type == enum.EVENT.EVENT_DUNGE_ENTER then
					if DungeonModel:GetInstance():CheckIsDailyOrNoviceDungeon(target_id) then
						local cf = Config.db_dunge[target_id]
						if cf and not string.isempty(cf.text) then
							self.content_str = cf.text
						end
					end
				end
			end
		end
		self.npc_id = self.goal[2]
		if prog >= #goals then
			self.award = String2Table(self.config.gain)
		elseif prog == 0 then
			self.award = String2Table(self.config.quest)
		end
	end

	if type(content_str) == "table" then  --多段任务
		self.multTab = content_str
		self.multIndex = 1
		self.content_str = self.multTab[self.multIndex][2]
		self.npc_id = self.multTab[self.multIndex][1]
	else
		self.content_str = content_str
	end
	-- Yzprint('--LaoY TaskTalkNovicePanel.lua,line 58--',self.task_id,self.npc_id)
	-- traceback()
	TaskTalkNovicePanel.super.Open(self)
end

local last_time = -7
function TaskTalkNovicePanel:LoadCallBack()
	self.nodes = {
		"time","name","content","button","button/text",
		"UIModelCamera","UIModelCamera/Camera","Image/img_task_bg","Image",
		"mask",
	}
	self:GetChildren(self.nodes)

	SetAlignType(self,bit.bor(AlignType.Null,AlignType.Bottom))

	if self.background_transform then
		local x,y = self:GetPosition()
		SetLocalPosition(self.background_transform,0,-y,0)
	end

	self.rawImage = self.UIModelCamera:GetComponent("RawImage")
	self.camera_component = self.Camera:GetComponent("Camera")

	self.name_text = self.name:GetComponent('Text')
	self.content_text = self.content:GetComponent('Text')
	self.time_text = self.time:GetComponent('Text')

	self.btn_text_component = self.text:GetComponent('Text')

	SetSizeDeltaX(self.Image,ScreenWidth - 8)
	SetLocalPositionX(self.name, (-ScreenWidth / 2) + 405)
	SetLocalPositionX(self.UIModelCamera, (-ScreenWidth / 2) + 315)
	-- GoodsIconSettor()
	-- local npc_id = 3010100
	-- self.npc_model = UINpcModel(self.transform,npc_id,handler(self,self.LoadModelCallBack))

	if  self.ui_effect then
		self.ui_effect:destroy()
	end
	self.ui_effect = UIEffect(self.button, 10121, false, self.layer)
	self.ui_effect:SetConfig({ scale = 1.2 })

	self:AddEvent()
end

function TaskTalkNovicePanel:LoadModelCallBack()
	local config = Config.db_npc[self.npc_id] or {}
	if not config then
		SetLocalPosition(self.npc_model.transform , -2039 ,42, 194);--172.2
	else
		local pos = String2Table(config.pos)
		SetLocalPosition(self.npc_model.transform , pos[1]+59 ,pos[2]+107, 194)
	end
    SetLocalRotation(self.npc_model.transform, 0, 172, 0);
    self.npc_model:SetCameraLayer();

    local npc_object = SceneManager:GetInstance():GetObject(self.npc_id)
    local show_action_name = SceneConstant.ActionName.show
    if npc_object then
    	show_action_name = npc_object:GetShowActionName()
    	npc_object:ChangeMachineState(show_action_name)
    end
    self.npc_model:AddAnimation({show_action_name ,"idle"},true,"idle",0)--,"casual"
end

function TaskTalkNovicePanel:AddEvent()
	local function call_back(target,x,y)
		if self.multTab then
			self:UpdateMult()
			return
		end
		self:Close()
	end
	AddClickEvent(self.button.gameObject,call_back)
	AddClickEvent(self.Image.gameObject,call_back)
	AddClickEvent(self.mask.gameObject,call_back)
	self.global_event_list = {}
	local function call_back()
		self.call_back = nil
		self:Close()
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EventName.ChangeSceneStart, call_back)
end

function TaskTalkNovicePanel:OpenCallBack()
	self:ClearRT()

	if not self.npc_model then
		if self.npc_id == 1 then
			self:InitMineRole()
		else
			if self.npc_model then
				self.npc_model:destroy()
				self.npc_model = nil
			end
			local config = Config.db_npc[self.npc_id]
			if not config or not config.figure then
				if AppConfig.Debug then
					local vo = TaskModel:GetInstance():GetTask(self.task_id)
					print('--LaoY TaskTalkNovicePanel.lua,line 97--')
					dump(vo,"vo")
				end
				logError(string.format("配置了一个不存在的NPC，ID是：%s,任务ID是：%s",tostring(self.npc_id),self.task_id))
			end
			self.npc_model = UINpcModel(self.UIModelCamera,config.figure,handler(self,self.LoadModelCallBack))
			local scale = (config.chat or 1)*0.5
			self.npc_model:SetScale(scale * 100)

			if config.sound ~= 0 and Time.time - last_time >= 7 then
				SoundManager:GetInstance():PlayById(config.sound)
				last_time = Time.time
			end
		end
	end

	local texture = CreateRenderTexture()
	self.camera_component.targetTexture = texture
	self.rawImage.texture = texture
	self.render_texture = texture

	self:UpdateView()
	self:StartTime()
end

function TaskTalkNovicePanel:ClearRT()
	if self.npc_model then
		self.npc_model:destroy()
		self.npc_model = nil
	end

	if self.camera_component then
		self.camera_component.targetTexture = nil
	end
	if self.rawImage then
		self.rawImage.texture = nil
	end
	if self.render_texture then
		ReleseRenderTexture(self.render_texture)
		self.render_texture = nil
	end
end

function TaskTalkNovicePanel:UpdateView( )
	local config = Config.db_npc[self.npc_id] or {}
	self.name_text.text = config.name or ""
	if self.npc_id == 1 then
		self.name_text.text = self.roleInfoModel.name
	end
	self.content_text.text = self.content_str
	--local taskCfg = config.db_task[] or {}

	for k,item in pairs(self.item_list) do
		item:destroy()
	end
	self.item_list = {}


	if self.config then
		self.btn_text_component.text = "Continue"
		local goal = String2Table(self.config.goals)
		if #goal> 1 and goal[2][1] == enum.EVENT.EVENT_DUNGE  then --副本任务
			self.btn_text_component.text = "Enter Stage"
		end
	else
		self.btn_text_component.text = "Confirm"
	end

	--if self.task_id then
	--	local taskCfg = config.db_task[self.task_id] or {}
	--	if not taskCfg then
	--		return
	--	end
	--	if #self.config.goals > 1 and self.config.goals[2][1] == enum.EVENT.EVENT_DUNGE  then --副本任务
	--		self.btn_text_component.text = "进入副本"
	--	end
	--end

	if not self.award then
		return
	end
	for i=1,#self.award do
		local vo = self.award[i]
		local item = self.item_list[i]
		if not item then
			item = GoodsIconSettorTwo(self.transform)
			self.item_list[i] = item
		end
		local x = -300 + (i-1) * 85
		local y = -310
		-- if AppConfig.Debug then
		-- 	if type(vo[1]) == "table" then
		-- 		logError("任务奖励配置格式不对，任务ID是:",self.task_id)
		-- 	end
		-- end
		item:SetConfig(vo)
		item:SetPosition(x,y)
	end
end

function TaskTalkNovicePanel:StartTime()
	self:StopTime()
	local time = 11
	local function step()
		time = time - 1
		local str = string.format("(Auto continue in %s sec)",time)
		if not self.config then
			str = string.format("(Auto closing in %s sec)",time)
		end
		self.time_text.text = str
		if time <= 0 then
			if self.multTab then
				self:UpdateMult()
				return
			end
			self:Close()
			self:StopTime()
		end
	end
	self.time_id = GlobalSchedule:Start(step,1.0)
	step()
end
function TaskTalkNovicePanel:StopTime()
	if self.time_id then
		GlobalSchedule:Stop(self.time_id)
	end
end

function TaskTalkNovicePanel:Close()
    if self.is_dctored then
        return
    end
    if not self.isShow then
    	if AppConfig.Debug then
    		--logError("npc对话界面已经关闭，尝试关闭")
    		-- Dialog.ShowOne("错误","npc对话界面已经关闭，尝试关闭","确定",nil,nil)
    	end
    	return
    end
    lua_panelMgr:ToClosePanel(self)
    if not self.is_exist_always then
        self.isShow = false
        self:CloseCallBack()
        -- lua_panelMgr:ToClosePanel(self)
        self:destroy()
    else
        self.isShow = false
        self:SetVisibleInside(false)
        self:CloseCallBack()
    end
end

function TaskTalkNovicePanel:CloseCallBack(  )
	self:ClearRT()
	self:StopTime()
	self.model.isOpenNpcPanel = false
	for k,item in pairs(self.item_list) do
		item:destroy()
	end
	self.item_list = {}
	
	if self.call_back then
		self.call_back()
	end
	self.call_back = nil
end

function TaskTalkNovicePanel:UpdateMult()
	self.multIndex = self.multIndex + 1
	if self.multIndex > #self.multTab then
		self:StopTime()
		self:Close()
		return
	end
	self:StartTime()
	local str = self.multTab[self.multIndex][2]
	self.npc_id = self.multTab[self.multIndex][1]
	local config = Config.db_npc[self.npc_id]
	--if not config then
	--	logError("npc表没有npc id:"..self.npc_id)
	--	return
	--end

	if self.npc_id == 1 then
		self.name_text.text = self.roleInfoModel.name
	else
		if not config then
			logError("npc表没有npc id:"..self.npc_id)
			return
		end
		self.name_text.text = config.name
	end
	if self.npc_model then
		self.npc_model:destroy()
		self.npc_model = nil
	end
	if not self.npc_model then

		if self.npc_id == 1 then
			self:InitMineRole()
		else
			if self.npc_model then
				self.npc_model:destroy()
				self.npc_model = nil
			end
			if not config or not config.figure then
				--if AppConfig.Debug then
				--	local vo = TaskModel:GetInstance():GetTask(self.task_id)
				--	print('--LaoY TaskTalkNovicePanel.lua,line 97--')
				--	dump(vo,"vo")
				--end
				logError(string.format("配置了一个不存在的NPC，ID是：",self.npc_id))
			end
			self.npc_model = UINpcModel(self.UIModelCamera,config.figure,handler(self,self.LoadModelCallBack))
			local scale = (config.chat or 1)*0.5
			self.npc_model:SetScale(scale * 100)

			if config.sound ~= 0 and Time.time - last_time >= 7 then
				SoundManager:GetInstance():PlayById(config.sound)
				last_time = Time.time
			end
		end

	end
	self.content_text.text = str
end

function TaskTalkNovicePanel:InitMineRole()
	if self.npc_model then
		self.npc_model:destroy()
		self.npc_model = nil
	end
	local config = {}
	config.trans_x = 630
	config.trans_y = 630
	config.trans_offset = {x = -125 ,y=-141}
	self.npc_model = UIRoleCamera(self.UIModelCamera, nil, self.roleInfoModel,nil,nil,nil,config)
end

