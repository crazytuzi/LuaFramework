CombinedServerActView = CombinedServerActView or BaseClass(BaseView)

function CombinedServerActView:LoadDoubleView()
	self.node_t_list.btn_d_guaji.node:addClickEventListener(BindTool.Bind(self.OnClickGuajiHandler, self))
end

function CombinedServerActView:DeleteDoubleView()
end

function CombinedServerActView:FlushDoubleView(param_t)
end

function CombinedServerActView:OnClickGuajiHandler()
	Scene.SendQuicklyTransportReq(11)
end