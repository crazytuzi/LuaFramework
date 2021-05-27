
CallBossView = CallBossView or BaseClass(XuiBaseView)


function CallBossView:__init()

	if	CallBossView.Instance then
		ErrorLog("[CallBossView]:Attempt to create singleton twice!")
	end
	self:SetIsAnyClickClose(true)
	self:SetModal(true)
	self.config_tab = {
		{"call_boss_ui_cfg", 1, {0}},
	}
	self.series = 0
end

function CallBossView:__delete()
end

function CallBossView:ReleaseCallBack()
end

function CallBossView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.current_index = 1
end

function CallBossView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
	local content_size = self.root_node:getContentSize()
	self:CreateTopTitle(nil, content_size.width / 2 - 30, content_size.height - 30)
	XUI.AddClickEventListener(self.node_t_list.btn_go.node, BindTool.Bind(self.OnClickBtnGo, self), false)
	end
end

function CallBossView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function CallBossView:OnFlush(param_t, index)
	for k, v in pairs(param_t) do
		if k == "flush_data" then
			self.series = v.series
		end
	end
end

function CallBossView:OnClickBtnGo()
	BagCtrl.Instance:SendUseItem(self.series, 0, 1)
end






