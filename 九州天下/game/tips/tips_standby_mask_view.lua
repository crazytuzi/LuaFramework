TipsStandbyMaskView = TipsStandbyMaskView or BaseClass(BaseView)

function TipsStandbyMaskView:__init()
	self.ui_config = {"uis/views/tips/standbymasktips", "StandbyMaskView"}
	self.close_mode = CloseMode.CloseVisible
	self.view_layer = UiLayer.Standby
	self.play_audio = true
end

function TipsStandbyMaskView:LoadCallBack()
	self:ListenEvent("OnClickHide", BindTool.Bind(self.OnClickHide, self))
end

function TipsStandbyMaskView:SetCallback(call_back)
	self.click_call_back = call_back
end

function TipsStandbyMaskView:OnClickHide()
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		scene_logic:OnTouchScreen()
	end

	if self.click_call_back then
		self.click_call_back()
		self.click_call_back = nil
	end

	self:Close()
end