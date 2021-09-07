FunOpenVictoryView = FunOpenVictoryView or BaseClass(BaseView)

function FunOpenVictoryView:__init()
	self.ui_config = {"uis/views/funfubenview", "FunOpenVictoryView"}
	self.active_close = false
end

function FunOpenVictoryView:LoadCallBack()
	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickClose, self))

	self:Flush()
end

function FunOpenVictoryView:OpenCallBack()

end

function FunOpenVictoryView:ReleaseCallBack()

end

function FunOpenVictoryView:OnClickClose()
	ExpresionFuBenCtrl.Instance:CloseFuBenView()
	GlobalEventSystem:Fire(SceneEventType.SHOW_MAINUI_RIGHT_UP_VIEW)
	self:Close()
end

function FunOpenVictoryView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "finish" then
		end
	end
end