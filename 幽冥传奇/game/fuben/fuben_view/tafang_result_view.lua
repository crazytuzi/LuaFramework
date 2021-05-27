-- 封魔塔防 结算
TafangResultView = TafangResultView or BaseClass(XuiBaseView)

function TafangResultView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/fuben.png'
	self.config_tab = {
		{"fuben_child_view_ui_cfg", 2, {0}},
		{"fuben_child_view_ui_cfg", 3, {0}},
	}
	self.view_data = {}
end

function TafangResultView:__delete()
end

function TafangResultView:OpenCallBack()
end

function TafangResultView:CloseCallBack()
	self.view_data = {}
end

function TafangResultView:ReleaseCallBack()
end

function TafangResultView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		XUI.AddClickEventListener(self.node_t_list.layout_btn_ok.node, BindTool.Bind(self.OnClickOK, self), true)

		self.num_1 = NumberBar.New()
		self.num_1:Create(145, 190, 0, 0, ResPath.GetFightResPath("g_"))
		self.node_t_list.layout_tf_result.node:addChild(self.num_1:GetView())

		self.num_2 = NumberBar.New()
		self.num_2:Create(145, 126, 0, 0, ResPath.GetFightResPath("r_"))
		self.node_t_list.layout_tf_result.node:addChild(self.num_2:GetView())
	end
end

function TafangResultView:ShowIndexCallBack(index)
	self:Flush()
end

function TafangResultView:OnFlush(param_t, index)
	self.num_1:SetNumber(self.view_data[1] or 0)
	self.num_2:SetNumber(self.view_data[2] or 0)
end

function TafangResultView:SetViewData(data)
	self.view_data = data or {}
end

function TafangResultView:OnClickOK()
	FubenCtrl.OutFubenReq(FubenData.Instance:GetFubenId())	
	self:Close()
end
