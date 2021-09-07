JingLingFuBenView = JingLingFuBenView or BaseClass(BaseView)

function JingLingFuBenView:__init()
	self.ui_config = {"uis/views/funfubenview", "JingLingFuBenView"}
	self.active_close = false
	self.fight_info_view = true

	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.Flush, self))
	self.view_layer = UiLayer.MainUILow
end

function JingLingFuBenView:LoadCallBack()
	self.fb_name = self:FindVariable("FBName")

	self.task_animator = self:FindObj("TaskAnimator").animator
	self.show_panel = self:FindVariable("ShowPanel")
	-- self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, BindTool.Bind(self.OnMainUIModeListChange, self))
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self:Flush()
end

function JingLingFuBenView:__delete()
	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
end

function JingLingFuBenView:ReleaseCallBack()
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

-- function JingLingFuBenView:OnMainUIModeListChange(is_show)
-- 	self.show_panel:SetValue(not is_show)
-- end

function JingLingFuBenView:OpenCallBack()
	self:Flush()
end

function JingLingFuBenView:CloseCallBack()

end

function JingLingFuBenView:SetStoryFBSceneData()
	MainUICtrl.Instance:SetViewState(false)
	self.fb_name:SetValue(Scene.Instance:GetSceneName())
end

function JingLingFuBenView:SwitchButtonState(enable)
	if self.task_animator and self:IsOpen() then
		self.task_animator:SetBool("fold", not enable)
	end
end

function JingLingFuBenView:OnFlush(param_t)
	-- if Scene.Instance:GetSceneType() == SceneType.FunFunBenMount then
	-- 	self:SetStoryFBSceneData()
	-- end
end