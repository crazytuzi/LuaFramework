ActQMCLView = ActQMCLView or BaseClass(ActBaseView)

function ActQMCLView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function ActQMCLView:__delete()
end

function ActQMCLView:InitView()
	self.node_t_list.btn_go_58.node:addClickEventListener(BindTool.Bind(self.OnClickGoCLHandler, self))
end

function ActQMCLView:RefreshView(param_list)
end

function ActQMCLView:OnClickGoCLHandler()
	Scene.SendQuicklyTransportReq(48)
	ActivityBrilliantCtrl.Instance:CloseView(self.act_id)
end
