require("game/rebate/rebate_content_view")
RebateView = RebateView or BaseClass(BaseView)
function RebateView:__init()
	self.ui_config = {"uis/views/rebateview_prefab","RebateView"}
	self.full_screen = false
	self.play_audio = true
end

function RebateView:__delete()

end

function RebateView:LoadCallBack()
	self:ListenEvent("close_click", BindTool.Bind(self.OnCloseClick, self))
	self.rebate_content_view = RebateContentView.New(self:FindObj("rebate_content_view"))
end

function RebateView:ReleaseCallBack()
	if self.rebate_content_view then
		self.rebate_content_view:DeleteMe()
	end
	self.rebate_content_view = nil
end

function RebateView:OpenCallBack()
	self.rebate_content_view:SetModelState()
end

function RebateView:OnCloseClick()
	self:Close()
end