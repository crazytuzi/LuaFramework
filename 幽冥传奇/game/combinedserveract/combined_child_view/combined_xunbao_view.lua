CombinedServerActView = CombinedServerActView or BaseClass(BaseView)

function CombinedServerActView:LoadXunbaoView()
	self.node_t_list.btn_xunbao.node:addClickEventListener(BindTool.Bind(self.OnClickXunbaoHandler, self))
end

function CombinedServerActView:DeleteXunbaoView()
	-- body
end

function CombinedServerActView:FlushXunbaoView(param_t)
	-- body
end

function CombinedServerActView:OnClickXunbaoHandler()
	ViewManager.Instance:OpenViewByDef(ViewDef.Explore)
end