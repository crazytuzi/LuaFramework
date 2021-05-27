PengLaiFairylandView = PengLaiFairylandView or BaseClass(BaseView)

function PengLaiFairylandView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.texture_path_list = {
		"res/xui/penglai_fairyland.png",
	}
	self.config_tab = {
		{"penglai_fairyland_ui_cfg", 1, {0}},
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
	}
	self.tabbar_name = {ViewDef.PengLaiFairyland.PengLaiFairylandSub.name, ViewDef.PengLaiFairyland.LuckyFlopSub.name}
	self.view_table = {ViewDef.PengLaiFairyland.PengLaiFairylandSub, ViewDef.PengLaiFairyland.LuckyFlopSub}
end

function PengLaiFairylandView:__delete()
end

function PengLaiFairylandView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function PengLaiFairylandView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function PengLaiFairylandView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

function PengLaiFairylandView:LoadCallBack(index, loaded_times)
	PengLaiFairylandCtrl.Instance:SendInfoReq()
	self.node_t_list.btn_close_window.node:setLocalZOrder(999)
	self:InitTabbar()
end

function PengLaiFairylandView:ShowIndexCallBack(index)
	self:FlushTabbarSelect()
end

function PengLaiFairylandView:InitTabbar()
	if nil == self.tabbar then
		self.tabbar = Tabbar.New()
		local x = self.ph_list.ph_tabbar.x
		local y = self.ph_list.ph_tabbar.y
		self.tabbar:SetTabbtnTxtOffset(-10, 0)
		self.tabbar:CreateWithNameList(self.node_t_list.layout_tabbar.node, x, y,
			BindTool.Bind(self.SelectTabCallback, self), self.tabbar_name,
			true, ResPath.GetCommon("toggle_110"))
	end
end

function PengLaiFairylandView:SetRemind(num)
	self.tabbar:SetRemindByIndex(2, num > 0)
end

function PengLaiFairylandView:FlushTabbarSelect()
	for k, v in pairs(self.view_table) do
		if v.open then
			self.tabbar:ChangeToIndex(k, self.root_node)
			break
		end
	end
end

function PengLaiFairylandView:SelectTabCallback(index)
	ViewManager.Instance:OpenViewByDef(self.view_table[index])
	for k, v in pairs(self.view_table) do
		if ViewManager.Instance:IsOpen(v) then
			self.tabbar:ChangeToIndex(k)
		end
	end
end