ActQMYBView = ActQMYBView or BaseClass(ActBaseView)

function ActQMYBView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function ActQMYBView:__delete()
end

function ActQMYBView:InitView()
	self.node_t_list.btn_hs_go.node:addClickEventListener(BindTool.Bind(self.OnClickGoYBHandler, self))
end

function ActQMYBView:RefreshView(param_list)
end

function ActQMYBView:OnClickGoYBHandler()
	Scene.SendQuicklyTransportReq(21)
	ActivityBrilliantCtrl.Instance:CloseView(self.act_id)
end

