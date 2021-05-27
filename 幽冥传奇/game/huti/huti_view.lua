
HutiView = HutiView or BaseClass(XuiBaseView)


function HutiView:__init()
	if	HutiView.Instance then
		ErrorLog("[HutiView]:Attempt to create singleton twice!")
	end
	self:SetModal(true)

	self.def_index = 1
	self.texture_path_list[1] = "res/xui/huti.png"
	self.config_tab = {
		{"huti_ui_cfg", 1, {0}},
		{"huti_ui_cfg", 2, {0}},
		{"huti_ui_cfg", 3, {0}},
	}
end

function HutiView:__delete()


end

function HutiView:ReleaseCallBack()

end

function HutiView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.current_index = 1
end

function HutiView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		local cs = self.root_node:getContentSize()
		self:CreateTopTitle(nil, cs.width / 2 - 18, cs.height - 40)
		XUI.AddClickEventListener(self.node_t_list.btn_open.node, BindTool.Bind(self.OnClickBtnOpen, self), false)
		XUI.AddClickEventListener(self.node_t_list.btn_close.node, BindTool.Bind(self.OnClickBtnClose, self), false)	
	end
end

function HutiView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.current_index = 1
end

function HutiView:OnClickBtnOpen()
	HutiCtrl.Instance:ShendunReq(1)
end

function HutiView:OnClickBtnClose()
	HutiCtrl.Instance:ShendunReq(0)
end






