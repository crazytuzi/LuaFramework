RoleFashionBtnCaoZuoView = RoleFashionBtnCaoZuoView or BaseClass(XuiBaseView)

function RoleFashionBtnCaoZuoView:__init()
	--self:SetModal(true)
	self.is_any_click_close = true	
	self.can_penetrate = true
	self.config_tab = {
		{"role_ui_cfg", 15, {0}},
	}
	self.data = nil 
	self.selec_view = nil
	self.state = {}
end

function RoleFashionBtnCaoZuoView:__delete()
	
end

function RoleFashionBtnCaoZuoView:ReleaseCallBack()
	if self.alert_window then
		self.alert_window:DeleteMe()
		self.alert_window = nil 
	end
end

function RoleFashionBtnCaoZuoView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		XUI.AddClickEventListener(self.node_t_list.btn_shichuan.node, BindTool.Bind(self.OnSuiChuang, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_jihuo.node, BindTool.Bind(self.OnActivie, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_tuoxia.node, BindTool.Bind(self.OnTuoxia, self), true)
		for i = 1, 4 do
			self.state[i] = {}
		end
	end
end

function RoleFashionBtnCaoZuoView:SetData(data, selec_view)
	self.data = data
	self.selec_view = selec_view
	self:Flush()
end

function RoleFashionBtnCaoZuoView:OnFlush(param_t, index)
	if self.selec_view then
		local pos = self.selec_view:convertToWorldSpace(cc.p(0, 0))
		self.node_t_list.layout_btn_list.node:setPosition(pos.x - 26, pos.y - 72)
	end
 	if self.state[self.data.fashion_type] == nil then
 		self.node_t_list.btn_tuoxia.node:setVisible(false)
		self.node_t_list.btn_shichuan.node:setVisible(true)
	else
		if self.state[self.data.fashion_type].name == self.data.name then
			self.node_t_list.btn_tuoxia.node:setVisible(true)
			self.node_t_list.btn_shichuan.node:setVisible(false)
		else
			self.node_t_list.btn_tuoxia.node:setVisible(false)
			self.node_t_list.btn_shichuan.node:setVisible(true)
		end
 	end
end

function RoleFashionBtnCaoZuoView:OnSuiChuang()
	if self.data ~= nil then
		RoleCtrl.Instance:FlushFashion(self.data.fashion_type, self.data.model)
	end
	self.node_t_list.btn_tuoxia.node:setVisible(true)
	self.node_t_list.btn_shichuan.node:setVisible(false)
	self.state[self.data.fashion_type] = self.data
end

function RoleFashionBtnCaoZuoView:OnActivie()
	if nil == self.alert_window then
		self.alert_window = Alert.New()
	end
	self.alert_window:SetLableString(Language.Role.FashionDesc[self.data.fashion_type] or "")
	self.alert_window:SetOkFunc(BindTool.Bind2(self.SendAgreeHandler, self))
	self.alert_window:Open()
end

function RoleFashionBtnCaoZuoView:SendAgreeHandler()
	if self.data ~= nil then
		RoleCtrl.SendActivitiveFashion(self.data.fashion_type, self.data.id)
		RoleCtrl.Instance:FlushTuoxiaFashion(self.data.fashion_type)
		self.state[self.data.fashion_type] = {}
	end
	self:Close()
end

function RoleFashionBtnCaoZuoView:OnTuoxia()
	if self.data ~= nil then
		RoleCtrl.Instance:FlushTuoxiaFashion(self.data.fashion_type)
	end
	self.node_t_list.btn_tuoxia.node:setVisible(false)
	self.node_t_list.btn_shichuan.node:setVisible(true)
	self.state[self.data.fashion_type] = {}
end