------------------------------------------------------------
-- 查看返利券界面
------------------------------------------------------------
SpendscoreExchCheckView = SpendscoreExchCheckView or BaseClass(XuiBaseView)

function SpendscoreExchCheckView:__init()
	self.is_any_click_close = true
	-- self.texture_path_list[1] = 'res/xui/limit_activity.png'
	
	self.config_tab = { --类dom模式,数组顺序决定渲染顺序
		{"operate_activity_ui_cfg", 47, {0}},
	}
	
end

function SpendscoreExchCheckView:__delete()

end

function SpendscoreExchCheckView:ReleaseCallBack()
	if self.show_list then
		self.show_list:DeleteMe()
		self.show_list = nil
	end
end

function SpendscoreExchCheckView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateList()
		XUI.AddClickEventListener(self.node_t_list.btn_close_window.node, BindTool.Bind(self.OnCloseHandler, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_go_charge.node, BindTool.Bind(self.OnGoCharge, self), true)
	end
	
end

function SpendscoreExchCheckView:OpenCallBack()
	
end

function SpendscoreExchCheckView:CloseCallBack()
	
end

function SpendscoreExchCheckView:ShowIndexCallBack(index)
	self:Flush(index)
end

function SpendscoreExchCheckView:OnFlush(param_t, index)
	for k, v in pairs(param_t) do
		if k == "all" then
			self.show_list:SetDataList(v.data)
		end
	end
end

function SpendscoreExchCheckView:CreateList()
	if nil == self.show_list then
		local ph = self.ph_list.ph_payback_ticket_list
		self.show_list = ListView.New()
		self.show_list:Create(ph.x, ph.y, ph.w, ph.h, nil, SpendscoreExchCheckRender, nil, nil, self.ph_list.ph_payback_ticket_item)
		self.show_list:SetItemsInterval(5)
		self.show_list:SetJumpDirection(ListView.Top)
		self.show_list:SetIsUseStepCalc(false)
		-- self.show_list:SetSelectCallBack(BindTool.Bind(self.SelectItemCallback, self))
		self.node_t_list.layout_payback_ticket_check.node:addChild(self.show_list:GetView(), 20)
	end
end

function SpendscoreExchCheckView:OnGoCharge()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)	
		return 
	end
	self:Close()
	ViewManager.Instance:Open(ViewName.ChargePlatForm)
end

