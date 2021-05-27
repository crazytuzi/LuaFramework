-------------------------------------------------------------------
-- 信息条
-------------------------------------------------------------------
CommonBar = CommonBar or BaseClass()

function CommonBar:__init()
	self.info_cfg = { 			-- 图片默认与类型名一样
		gold = {img = "glod"}
	}
	self.default_show_type_list = {"gold", "bind_gold", "coin", "bind_coin"}
	self.cur_show_type_list = nil

	self.layout_width = 210
	self.layout_height = 60
	self.layout_interval = 20

	self.view = XLayout:create()
	self.node_tree = {}

	self.change_callback = BindTool.Bind1(self.RoleDataAttrChangeCallBack, self)
	RoleData.Instance:NotifyAttrChange(self.change_callback)
end

function CommonBar:__delete()
	if nil ~= RoleData.Instance then
		RoleData.Instance:UnNotifyAttrChange(self.change_callback)
	end

	self.get_data_callback = nil
end

function CommonBar:GetView()
	return self.view
end

function CommonBar:UpdateView()
	local cur_show_type_list = self.cur_show_type_list or self.default_show_type_list
	local cur_show_list = {}

	local show_num = #cur_show_type_list
	local start_x = -(show_num * (self.layout_width + self.layout_interval) - self.layout_interval) / 2
	for i,v in ipairs(cur_show_type_list) do
		if nil == self.node_tree[v] then
			self.node_tree[v] = {}
			self:CreateNewLayout(self.view, self.node_tree[v])
		end

		local layout = self.node_tree[v].layout_money_bar
		self:CheckSpecialNode(v, layout)
		layout.node:setPosition(start_x + (i - 1) * (self.layout_width + self.layout_interval), 0)
		layout.node:setAnchorPoint(0, 1)
	end

	self:UpdateData()
end

function CommonBar:CreateNewLayout(parent, node_tree, ph_list)
	local ui_cfg = ConfigManager.Instance:GetUiConfig("money_bar_ui_cfg")
	XUI.Parse(ui_cfg, parent, nil, node_tree, ph_list)
end

function CommonBar:CheckSpecialNode(name, layout)
	if "gold" ~= name then
		layout.btn_add.node:setVisible(false)
	else
		layout.btn_add.node:addClickEventListener(function()
			FunOpen.Instance:OpenViewByName("recharge")
		end)
	end
end

function CommonBar:RoleDataAttrChangeCallBack()
	self:UpdateData()
end

-- 刷新数据
function CommonBar:UpdateData()
	local cur_show_type_list = self.cur_show_type_list or self.default_show_type_list
	for i,v in ipairs(cur_show_type_list) do
		if self.node_tree[v] then
			local layout = self.node_tree[v].layout_money_bar
			local icon_name = self.info_cfg[v] and self.info_cfg[v].img or v
			local num = 0
			local role_info = RoleData.Instance:GetRoleInfo()
			local role_vo = GameVoManager.Instance:GetMainRoleVo()
			if nil ~= role_info[v] then
				num = role_info[v]
			elseif nil ~= role_vo[v] then
				num = role_vo[v]
			elseif nil ~= self.get_data_callback then
				num = self.get_data_callback(v)
			end

			layout.img_icon.node:loadTexture(ResPath.GetCommon(icon_name))
			layout.label_num.node:setString(num)
		end
	end
end

-- type_list：需要显示的类型， info_cfg:特殊处理配置， 获取数值函数
function CommonBar:SetCommonBarInfo(type_list, info_cfg, func)
	if "table" == type(type_list) then
		self.cur_show_type_list = type_list
	end
	
	if "table" == type(info_cfg) then
		for k,v in pairs(info_cfg) do
			self.info_cfg[k] = v
		end
	end

	self.get_data_callback = func
end