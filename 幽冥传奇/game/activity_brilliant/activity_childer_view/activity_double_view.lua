DoubleEXPView = DoubleEXPView or BaseClass(ActBaseView)

function DoubleEXPView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function DoubleEXPView:__delete()
end

function DoubleEXPView:InitView()
	self.node_t_list.btn_d_guaji.node:addClickEventListener(BindTool.Bind(self.OnClickActGuajiHandler, self))
end

function DoubleEXPView:RefreshView(param_list)
end

function DoubleEXPView:OnClickActGuajiHandler()
	Scene.SendQuicklyTransportReq(11)
	ActivityBrilliantCtrl.Instance:CloseView(self.act_id)
end