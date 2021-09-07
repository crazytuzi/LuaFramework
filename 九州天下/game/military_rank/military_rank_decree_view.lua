DecreeView = DecreeView or BaseClass(BaseView)
function DecreeView:__init()	
	self.ui_config = {"uis/views/militaryrankview", "DecreeView"}
	self:SetMaskBg(true)
	self.is_close = false
end

function DecreeView:ReleaseCallBack()
	self.title = nil
	self.content = nil
	self.show_btn = nil
	self.show_type = nil
	self.gather_show_data = nil
	self.receive_btn = nil
	self.type = DECREE_SHOW_TYPE.ACCEPT_TASK
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.DecreeView)
	end
end

function DecreeView:LoadCallBack()
	self:ListenEvent("CloseWindow", BindTool.Bind(self.Close, self))
	self:ListenEvent("DoJunXianTask", BindTool.Bind(self.DoJunXianTask, self))
	self.title = self:FindVariable("Title")
	self.content = self:FindVariable("Decree")
	self.show_btn = self:FindVariable("ShowBtn")
	self.show_type = self:FindVariable("Type")
	self.receive_btn = self:FindObj("ReceiveBtn")
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.DecreeView, BindTool.Bind(self.GetUiCallBack, self))
end

function DecreeView:OpenCallBack()
	self.is_close = false
	local cur_level = MilitaryRankData.Instance:GetCurLevel()
	local cur_cfg = MilitaryRankData.Instance:GetLevelSingleCfg(cur_level)
	local next_cfg = MilitaryRankData.Instance:GetLevelSingleCfg(cur_level + 1)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local content_str = ""
	local title_str = ""
	if self.type == DECREE_SHOW_TYPE.ACCEPT_TASK then
		if not next_cfg or not next(next_cfg) then return end
		content_str = string.format(Language.MilitaryRank.AcceptShowStr, main_role_vo.name, next_cfg.name)
		title_str = Language.MilitaryRank.AcceptTitle
		self.show_btn:SetValue(true)
	elseif self.type == DECREE_SHOW_TYPE.UPLEVEL then
		if not cur_cfg or not next(cur_cfg) then return end
		content_str = string.format(Language.MilitaryRank.ShowStr, main_role_vo.name, cur_cfg.name)
		title_str = Language.MilitaryRank.DecreeTitle
		self.show_btn:SetValue(false)
	elseif self.type == DECREE_SHOW_TYPE.GATHER_TASK then
		content_str = self.gather_show_data
		title_str = ""
		self.show_btn:SetValue(false)
	end
	self.show_type:SetValue(self.type ~= DECREE_SHOW_TYPE.GATHER_TASK)
	
	self.content:SetValue(content_str)
	self.title:SetValue(title_str)
end

function DecreeView:CloseCallBack()
	if not self.is_close and self.type == DECREE_SHOW_TYPE.UPLEVEL then
		self.is_close = true
		local cur_level = MilitaryRankData.Instance:GetCurLevel()
		MainUICtrl.Instance:OnOpenTrigger(6, cur_level)
	end
end

function DecreeView:SetOpenType(open_type, show_data)
	if show_data then
		self.gather_show_data = show_data
	end
	self.type = open_type
end

function DecreeView:DoJunXianTask()
	local can_accept_id_list = TaskData.Instance:GetTaskCapAcceptedIdList()
	for k,v in pairs(can_accept_id_list) do
		local task_cfg = TaskData.Instance:GetTaskConfig(k)
		if task_cfg and TASK_TYPE.JUN == task_cfg.task_type then
			ViewManager.Instance:Close(ViewName.DecreeView)
			ViewManager.Instance:Close(ViewName.MilitaryRank)
			TaskCtrl.Instance:DoTask(k)
			return
		end
	end
	local accepted_info_list = TaskData.Instance:GetTaskAcceptedInfoList()
	for k,v in pairs(accepted_info_list) do
		local task_cfg = TaskData.Instance:GetTaskConfig(k)
		if task_cfg and TASK_TYPE.JUN == task_cfg.task_type then
			ViewManager.Instance:Close(ViewName.DecreeView)
			ViewManager.Instance:Close(ViewName.MilitaryRank)
			TaskCtrl.Instance:DoTask(k)
			return
		end
	end
	SysMsgCtrl.Instance:ErrorRemind(Language.MilitaryRank.NoTask)
end

function DecreeView:GetUiCallBack(ui_name, ui_param)
	if index == TabIndex.ReceiveBtn then
		if self.receive_btn then
			return self.receive_btn, BindTool.Bind(self.DoJunXianTask, self)
		end
	elseif self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end