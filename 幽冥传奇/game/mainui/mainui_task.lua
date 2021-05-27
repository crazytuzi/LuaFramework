
---------------------------------------------------
-- 主线任务
---------------------------------------------------
MainuiTask = MainuiTask or BaseClass()
MainuiTask.task_size = cc.size(300, 64)
MainuiTaskIndex = 0
function MainuiTask:__init()
	self.mt_layout_task = nil
	self.task_data = nil
end

function MainuiTask:__delete()
	if nil ~= self.task_event_proxy then
		self.task_event_proxy:DeleteMe()
		self.task_event_proxy = nil
	end
	self.task_data = nil
	self.mt_layout_task = nil
end

function MainuiTask:GetMtLayoutVis()
	return self.mt_layout_task and self.mt_layout_task:isVisible()
end

function MainuiTask:GetMtLayout()
	return self.mt_layout_task
end

function MainuiTask:Init(mt_layout_root)
	local bottom_center = mt_layout_root
	local bottom_size = bottom_center:getContentSize()
	self.mt_layout_task = MainuiMultiLayout.CreateMultiLayout(bottom_size.width / 2, 142, XUI.ANCHOR_POINTS[XUI.CENTER], MainuiTask.task_size, bottom_center, 1)
	self.mt_layout_task:AddClickEventListener(BindTool.Bind(self.OnClickMainTask, self))
	self.mt_layout_task:setVisible(false)

	self.task_bg = XUI.CreateImageView(MainuiTask.task_size.width / 2, 0, ResPath.GetMainui("task_bg"))
	self.task_bg:setAnchorPoint(XUI.ANCHOR_POINTS[XUI.BOTTOM_CENTER])
	self.mt_layout_task:TextureLayout():addChild(self.task_bg)
	
	local title_w = XUI.CreateImageView(MainuiTask.task_size.width / 2 - 5, 74, ResPath.GetMainui("task_w"))
	title_w:setAnchorPoint(XUI.ANCHOR_POINTS[XUI.BOTTOM_CENTER])
	self.mt_layout_task:TextureLayout():addChild(title_w)

	self.task_title = XUI.CreateRichText(MainuiTask.task_size.width / 2, 40, 200, 30)
	self.task_title:setVerticalAlignment(RichVAlignment.VA_CENTER)
	self.task_title:setAnchorPoint(0.5, 0)
	XUI.RichTextSetCenter(self.task_title)
	self.mt_layout_task:TextLayout():addChild(self.task_title)

	self.task_desc = XUI.CreateRichText(MainuiTask.task_size.width / 2, 10, 200, 30)
	self.task_desc:setVerticalAlignment(RichVAlignment.VA_CENTER)
	self.task_desc:setAnchorPoint(0.5, 0)
	XUI.RichTextSetCenter(self.task_desc)
	self.mt_layout_task:TextLayout():addChild(self.task_desc)

	self.task_effect = RenderUnit.CreateEffect(TASK_EFFECT_ID.COMPLETE, self.mt_layout_task:TextLayout(), 300, nil, nil, 145, 45)
	self.task_effect:setVisible(false)

	self.task_instance = TaskData.Instance
	self.task_event_proxy = EventProxy.New(self.task_instance)
	self.task_event_proxy:AddEventListener(TaskData.ON_TASK_LIST, BindTool.Bind(self.OnTaskList, self))
	self.task_event_proxy:AddEventListener(TaskData.ADD_ONE_TASK, BindTool.Bind(self.OnAddOneTask, self))
	self.task_event_proxy:AddEventListener(TaskData.FINISH_ONE_TASK, BindTool.Bind(self.OnFinishOneTask, self))
	self.task_event_proxy:AddEventListener(TaskData.GIVEUP_ONE_TASK, BindTool.Bind(self.OnGiveupOneTask, self))
	self.task_event_proxy:AddEventListener(TaskData.TASK_VALUE_CHANGE, BindTool.Bind(self.OnTaskValueChange, self))
	GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.OnSceneChangeComplete, self))
	-- self.special_num = 0
end

function MainuiTask:FLushTask()
	self.task_data = self.task_instance:GetMainTaskInfo()
	local can_show = Scene.Instance:GetSceneLogic():CanShowMainuiTask()
	local vis = nil ~= self.task_data and can_show
	self.mt_layout_task:setVisible(vis)
	if vis then
		self:FlushTaskContent()
	end

	GlobalEventSystem:FireNextFrame(MainUIEventType.TASK_BAR_VIS, vis)
end

function MainuiTask:SetTaskDesc(rich_node, desc, total_color)
	if nil == self.task_data then
		return
	end

	local task_state = self.task_instance:GetTaskState(self.task_data)
	local color = task_state == TaskState.Complete and COLORSTR.GREEN or COLORSTR.RED
	desc = string.gsub(desc, "<target_color>", color)
	desc = string.gsub(desc, "<task_title>", self.task_data.title)

	if nil ~= self.task_data.target then
		desc = string.gsub(desc, "<cur_value>", self.task_data.target.cur_value)
		desc = string.gsub(desc, "<target_value>", self.task_data.target.target_value)
		desc = string.gsub(desc, "<name>", self.task_data.target.name)
		desc = string.gsub(desc, "<id>", self.task_data.target.id)
	end
	if nil ~= self.task_data.npc then
		desc = string.gsub(desc, "<npc_name>", self.task_data.npc.name)
	end

	RichTextUtil.ParseRichText(rich_node, desc, 22, total_color)
end

function MainuiTask:FlushTaskContent()
	if nil == self.task_data then
		return
	end

	local task_config = TaskConfig[self.task_data.task_id]
	if nil == task_config then
		self:SetTaskDesc(self.task_title, string.format("无配置任务id:%d", self.task_data.task_id))
		self:SetTaskDesc(self.task_desc, string.format("无配置任务id:%d", self.task_data.task_id))
		return
	end

	local task_state = self.task_instance:GetTaskState(self.task_data)

	local txt_content = task_config.txt_content[task_state] or task_config.txt_content[-1] or string.format("无配置任务id:%d", self.task_data.task_id)
	self:SetTaskDesc(self.task_title, txt_content, COLOR3B.ORANGE)

	local txt_content2 = task_config.txt_content2[task_state] or task_config.txt_content2[-1] or string.format("无配置任务id:%d", self.task_data.task_id)
	self:SetTaskDesc(self.task_desc, txt_content2, COLOR3B.WHITE)

	--特效
	self.task_effect:setVisible(task_state == TaskState.Complete)
end

-- 做任务
--优先场景打怪
local sp_scene = SetBag{107, 292, 291}
function MainuiTask.HandleTask(task_data, param)
	-- Log("--->>>HandleTask:" .. task_data.title)
	if nil == task_data then
		return
	end

	local task_config = TaskConfig[task_data.task_id]
	if nil == task_config then
		Log(string.format("[MainuiTask]:无配置点击命令 任务id:%d", task_data.task_id))
		return
	end

	local task_state = TaskData.Instance:GetTaskState(task_data)
	local command = task_config.touch_command[task_state] or task_config.touch_command[-1]
	if nil == command then
		Log(string.format("[MainuiTask]:无配置点击命令 任务id:%d", task_data.task_id))
		return
	end

	local ignore_view_link = param and param.ignore_view_link -- 忽略界面链接
	local ignore_submit_task = param and param.ignore_submit_task -- 忽略提交任务
	if command.view_link and not ignore_view_link then
		ViewManager.Instance:OpenViewByStr(command.view_link)
		if command.view_index then
			ViewManager.Instance:FlushViewByStr(command.view_link, 0, "param1",command)
		end
	elseif command.monster then
		MainuiTask.OnTaskMonster(task_data)
	elseif command.npc then
		if not sp_scene[Scene.Instance:GetSceneId()] then
			MainuiTask.OnTaskTalkToNpc(task_data, command.npc)
		end
	
		if MainuiTaskIndex == 0 then
			if command.view_pos then
				ViewManager.Instance:OpenViewByStr(command.view_pos)
				MainuiTaskIndex = 1
			end
		end
	elseif command.submit_task and not ignore_submit_task then
		TaskCtrl.SendCompleteTaskReq(task_data.task_id)
	elseif command.transfer then
		Scene.SendQuicklyTransportReqByNpcId(command.transfer)
	elseif command.fuben_id then
		if Scene.Instance.fuben_id ~= command.fuben_id then		
			-- local protocol = ProtocolPool.Instance:GetProtocol(CSGEnterFubenReq)
			-- protocol.fuben_id = command.fuben_id or 0
			-- protocol:EncodeAndSend()
			if command.view_link then
				ViewManager.Instance:OpenViewByStr(command.view_link)
				--if command.view_index then
				ViewManager.Instance:FlushViewByStr(command.view_link, 0, "param1",command)
				--end
			else
				TaskCtrl.SendEnterFubenReq(command.fuben_id or 0)
			end
		end
	end
	GuajiCtrl.Instance:NewSetOptState(false)    -- 做任务时玩家操作为false
end

function MainuiTask.OnTaskTalkToNpc(task_data, command_npc)
	if nil == task_data or nil == task_data.npc then
		return
	end

	local npc = task_data.npc
	if type(command_npc) == "table" then
		npc = command_npc
	end

	-- 检查重复
	-- if MoveCache.is_valid and MoveCache.param1 == task_data.npc.id and MoveCache.end_type == MoveEndType.NpcTask and MoveCache.task_id == task_data.task_id then
	-- 	return
	-- end

	Scene.Instance:GetMainRole():StopMove()
	MoveCache.param1 = npc.id
	MoveCache.task_id = task_data.task_id
	MoveCache.end_type = MoveEndType.NpcTask
	GuajiCtrl.Instance:MoveToPos(npc.scene_id, npc.x, npc.y, 1)
end

-- 移动到指定坐标 进行打怪
function MainuiTask.OnTaskMonster(data)
	if nil == data or nil == data.target then
		return
	end

	-- 检查重复
	if GuajiCache.monster_id == data.target.id and GuajiCache.guaji_type == GuajiType.Auto then
		return
	end
	
	Scene.Instance:GetMainRole():StopMove()
	
	local x, y = data.target.x, data.target.y
	MoveCache.task_id = data.task_id
	MoveCache.end_type = MoveEndType.FightByMonsterId
	MoveCache.be_clear_callback = function(reason, clear_end_type)	-- 传送后会被清除掉任务信息，在这里重新执行一下
		MoveCache.be_clear_callback = nil
		if clear_end_type ~= MoveEndType.FightByMonsterId or reason ~= ClearGuajiCacheReason.SceneChange then
			return
		end
		MainuiTask.OnTaskMonster(data)
	end

	GuajiCache.monster_id = data.target.id
	GuajiCtrl.Instance:MoveToPos(data.target.scene_id, x, y, 1)
end
---------------------------------------------------------------------------------
function MainuiTask:OnClickMainTask()
	MainuiTask.HandleTask(self.task_data)
end

function MainuiTask:OnTaskList()
	self:FLushTask()
end

function MainuiTask:OnGiveupOneTask()
	self:FLushTask()
end

function MainuiTask:OnTaskValueChange()
	self:FLushTask()
end

function MainuiTask:OnAddOneTask(task_info)
	self:FLushTask()
end

function MainuiTask:OnFinishOneTask(task_info)
	self:FLushTask()
end

function MainuiTask:OnSceneChangeComplete()
	self:FLushTask()
end
