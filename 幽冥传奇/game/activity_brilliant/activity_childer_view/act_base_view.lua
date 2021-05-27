---------------
--活动基类
---------------
ActBaseView = ActBaseView or BaseClass()

function ActBaseView:__init(view, parent, act_id)
	GameObject.Extend(self)
	self:AddComponent(EventProtocol):ExportMethods()					-- 增加事件组件

	self.view = view
	self.ui_cfg = nil
	self.act_id = act_id
	self.ph_list = {}
	self.config_t = {}
	self.node_t_list = {}
	self.node_tree = {}
end

function ActBaseView:__delete()
	NeedDelObjs:clear(self)

	self.view = nil
	self.ui_cfg = nil
	self.act_id = nil
	self.ph_list = {}
	self.config_t = {}
	self.node_t_list = {}
	self.node_tree = {}

	self:DispatchEvent(GameObjEvent.REMOVE_ALL_LISTEN)
	self:RemoveAllEventlist()
end

function ActBaseView:LoadView(parent)
	local ui_config = ConfigManager.Instance:GetUiConfig("activity_brilliant_ui_cfg")
	if self.act_id >= 84 and self.act_id <= 99 then
		ui_config = ConfigManager.Instance:GetUiConfig("activity_brilliant84_99_ui_cfg")
	elseif self.act_id >= 73 and self.act_id <= 83 then
		ui_config = ConfigManager.Instance:GetUiConfig("act_73_83_ui_cfg")
	elseif self.act_id >=52 and self.act_id <= 72 then
		ui_config = ConfigManager.Instance:GetUiConfig("activity_brilliant54_72_ui_cfg")
	end
	for k, v in pairs(ui_config) do
		if v.n == OPER_ACT_CLIENT_CFG[self.act_id].ui_layout_name then
			self.ui_cfg = v
			break
		end
	end
	
	if nil == self.ui_cfg then
		ErrorLog(string.format("ActBaseView no ui_cfg !, act_id : %d", self.act_id))
	else
		self.ui_cfg.x = 0
		self.ui_cfg.y = 0
		self.tree = XUI.GeneratorUI(self.ui_cfg, nil, nil, self.node_t_list, nil, self.ph_list)
		parent:addChild(self.tree.node, 999, 999)
		self:InitView()
		self:AddActCommonClickEventListener()
	end
end

function ActBaseView:SetVisible(visible)
	if nil ~= self.tree then
		self.tree.node:setVisible(visible)
	end
end

-- 加入自动清理列表
function ActBaseView:AddObj(key)
	NeedDelObjs:add(self, key)
end

-- 初始化视图
function ActBaseView:InitView()
end

-- 注册通用点击事件
function ActBaseView:AddActCommonClickEventListener()
end

-- 视图关闭回调
function ActBaseView:CloseCallback() 
end

-- 选中当前视图回调
function ActBaseView:ShowIndexView()
end

-- 切换当前视图回调
function ActBaseView:SwitchIndexView()
end

-- 刷新当前视图
function ActBaseView:RefreshView(param_list)
end
