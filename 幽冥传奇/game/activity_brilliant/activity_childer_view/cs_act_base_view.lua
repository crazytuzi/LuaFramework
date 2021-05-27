---------------
--跨服活动基类
---------------
CSActBaseView = CSActBaseView or BaseClass()

function CSActBaseView:__init(view, parent, act_model)
    GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
	self.view = view
	self.act_model = act_model
	self.ui_cfg = nil
	self.act_id = act_model.act_id
	self.ph_list = {}
	self.config_t = {}
	self.node_t_list = {}
end

function CSActBaseView:__delete()
	self.view = nil
	self.ui_cfg = nil
	self.act_id = nil
	self.act_model = nil
	self.ph_list = {}
	self.config_t = {}
	self.node_t_list = {}
    self:DispatchEvent(ViewEvent.RELEASE_EVENT)
end

function CSActBaseView:LoadView(parent)
	local ui_config = ConfigManager.Instance:GetUiConfig(self.act_model.client_cfg.ui_cfg_file_name)
	for k, v in pairs(ui_config) do
		if v.n == self.act_model.client_cfg.ui_layout_name then
			self.ui_cfg = v
			break
		end
	end

	self.ui_cfg.x = 0
	self.ui_cfg.y = 0
	self.tree = XUI.GeneratorUI(self.ui_cfg, nil, nil, self.node_t_list, nil, self.ph_list)
	parent:addChild(self.tree.node, 999, 999)

	self:InitView()
end

function CSActBaseView:SetVisible(visible)
	if nil ~= self.tree then
		self.tree.node:setVisible(visible)
	end
end

-- 初始化视图
function CSActBaseView:InitView()
end

-- 视图关闭回调
function CSActBaseView:CloseCallback() 
end

-- 选中当前视图回调
function CSActBaseView:ShowIndexView()
end

-- 切换当前视图回调
function CSActBaseView:SwitchIndexView()
end

-- 刷新当前视图
function CSActBaseView:RefreshView(param_list)
end
