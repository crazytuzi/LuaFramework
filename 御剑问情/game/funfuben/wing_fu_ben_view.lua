WingFuBenView = WingFuBenView or BaseClass(BaseView)

function WingFuBenView:__init()
	self.ui_config = {"uis/views/funfubenview_prefab", "WingFuBenView"}
	self.active_close = false
	self.fight_info_view = true

	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.Flush, self))
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
end

function WingFuBenView:LoadCallBack()
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

function WingFuBenView:__delete()
	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
end

function WingFuBenView:ReleaseCallBack()
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

-- function WingFuBenView:OnMainUIModeListChange(is_show)
-- 	self.show_panel:SetValue(not is_show)
-- end

function WingFuBenView:OpenCallBack()
	local gather_id = ExpresionFuBenData.Instance:GetWingFuBenCfg()[1].gather_id
	local gather_name = ExpresionFuBenData.Instance:GetGatherInfoById(gather_id).show_name
	self.gather_name:SetValue(gather_name)
	self:Flush()
end

function WingFuBenView:CloseCallBack()

end

function WingFuBenView:SetWingFBSceneData()
	MainUICtrl.Instance:SetViewState(false)
	local mount_fb_info = ExpresionFuBenData.Instance:GetMountFuBenInfo()
	self.fb_name:SetValue(Scene.Instance:GetSceneName())
	self.have_num:SetValue(mount_fb_info.is_finish)
end

function WingFuBenView:SwitchButtonState(enable)
	if self.task_animator and self:IsOpen() then
		self.task_animator:SetBool("fold", not enable)
	end
end

function WingFuBenView:OnFlush(param_t)
	if Scene.Instance:GetSceneType() == SceneType.WingFuBenView then
		self:SetWingFBSceneData()
	end
end