MountFuBenView = MountFuBenView or BaseClass(BaseView)

function MountFuBenView:__init()
	self.ui_config = {"uis/views/funfubenview", "MountFuBenView"}
	self.active_close = false
	self.fight_info_view = true

	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.OnChangeScene, self))
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.Flush, self))

	self.fail_data = {}
	self.view_layer = UiLayer.MainUILow
end

function MountFuBenView:__delete()
	self.fail_data = nil
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.scene_load_enter ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end

	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
end

function MountFuBenView:LoadCallBack()
	self.fb_name = self:FindVariable("FBName")
	self.have_num = self:FindVariable("HaveNum1")
	self.need_num = self:FindVariable("NeedNum1")
	self.gather_name = self:FindVariable("Require1")

	self.task_animator = self:FindObj("TaskAnimator").animator
	self.show_panel = self:FindVariable("ShowPanel")
	-- self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, BindTool.Bind(self.OnMainUIModeListChange, self))
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self:Flush()
end

function MountFuBenView:ReleaseCallBack()
	if self.scene_load_enter ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end
	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
	-- if self.show_mode_list_event ~= nil then
	-- 	GlobalEventSystem:UnBind(self.show_mode_list_event)
	-- 	self.show_mode_list_event = nil
	-- end
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
end

-- function MountFuBenView:OnMainUIModeListChange(is_show)
-- 	self.show_panel:SetValue(not is_show)
-- end

function MountFuBenView:OnChangeScene()
	-- if Scene.Instance:GetSceneType() == SceneType.FunFunBenMount then
	-- 	print("执行了 MountFuBenView:OnChangeScene  ####", Scene.Instance:GetSceneType())
	-- end
end

function MountFuBenView:OpenCallBack()
	local gather_id = ExpresionFuBenData.Instance:GetMountFuBenCfg()[1].gather_id
	local gather_name = ExpresionFuBenData.Instance:GetGatherInfoById(gather_id).show_name
	self.gather_name:SetValue(gather_name)
	self:Flush()
end

function MountFuBenView:CloseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function MountFuBenView:SetStoryFBSceneData()
	MainUICtrl.Instance:SetViewState(false)
	local mount_fb_info = ExpresionFuBenData.Instance:GetMountFuBenInfo()
	self.fb_name:SetValue(Scene.Instance:GetSceneName())
	self.have_num:SetValue(mount_fb_info.is_finish)
end

function MountFuBenView:SwitchButtonState(enable)
	if self.task_animator and self:IsOpen() then
		self.task_animator:SetBool("fold", not enable)
	end
end

function MountFuBenView:OnFlush(param_t)
	-- if Scene.Instance:GetSceneType() == SceneType.FunFunBenMount then
	-- 	self:SetStoryFBSceneData()
	-- end
end