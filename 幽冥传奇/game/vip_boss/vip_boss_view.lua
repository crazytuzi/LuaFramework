VipBossView = VipBossView or BaseClass(XuiBaseView)

function VipBossView:__init()
	self:SetModal(true)
	self.def_index = 1

	self.texture_path_list[1] = "res/xui/vip.png"
	self.title_img_path = ResPath.GetVipResPath("txt_login_2")
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"vip_boss_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}

	self.select_index = 1

end

function VipBossView:__delete()
	self.select_index = 1
end

function VipBossView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:VipFubenInfoList()
		self.node_t_list.btn_boss_left.node:setVisible(false)
		self.node_t_list.btn_boss_right.node:setVisible(false)
		-- XUI.AddClickEventListener(self.node_t_list.btn_boss_left.node, BindTool.Bind(self.OnMoveLeftHandler, self), true)
		-- XUI.AddClickEventListener(self.node_t_list.btn_boss_right.node, BindTool.Bind(self.OnMoveRightHandler, self), true)
		self.node_t_list.btn_boss_left.node:setVisible(false)
	end
end

function VipBossView:OpenCallBack()
	
end

function VipBossView:ShowIndexCallBack(index)
	self:Flush(index)
end

function VipBossView:CloseCallBack()
	
end

function VipBossView:ReleaseCallBack()
	if self.grid_list then
		self.grid_list:DeleteMe()
		self.grid_list = nil 
	end
end

function VipBossView:OnFlush(param_list, index)
	local data = VipBossData.Instance:GetVipBossData()
	self.grid_list:SetDataList(data)
end

function VipBossView:VipFubenInfoList()
	local ph_grid = self.ph_list.ph_list_boss

	local grid_list_view = ListView.New()	
	grid_list_view:Create(ph_grid.x + 510, ph_grid.y + 300, ph_grid.w, ph_grid.h, 2, VipBossFubenItem, nil, false, self.ph_list.ph_boss_item)
	grid_list_view:SetItemsInterval(10)
	-- grid_list_view:setAnchorPoint(0.5, 0.5)
	grid_list_view:SetMargin(3)

	self.node_t_list.layout_vip_boss.node:addChild(grid_list_view:GetView(), 999)
	self.grid_list = grid_list_view
	self.grid_list:SetSelectCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
end

function VipBossView:OnPageChangeCallBack(item, index)
	if nil == item or nil == item:GetData() then return end
	self.select_index = index
	if index ~= self.select_index then 
		self.escort_list_view:SelectIndex(self.select_index)
	end
	-- self:FlushBtns()
end

function VipBossView:OnMoveLeftHandler()
	if self.select_index > 1 then
		self.select_index = self.select_index - 1
		self.grid_list:SetSelectItemToLeft(self.select_index)
		self.grid_list:SelectIndex(self.select_index)
	end
end

function VipBossView:OnMoveRightHandler()
	local max_num = self.grid_list:GetCount()
	if self.select_index < max_num  then
		self.select_index = self.select_index + 1
		self.grid_list:SetSelectItemToLeft(self.select_index)
		self.grid_list:SelectIndex(self.select_index)
	end
end

function VipBossView:FlushBtns()
	local max_num = self.grid_list:GetCount()
	self.node_t_list.layout_vip_boss.btn_boss_left.node:setVisible(self.select_index ~= 1)
	self.node_t_list.layout_vip_boss.btn_boss_right.node:setVisible(self.select_index ~= max_num)
end


-- vip boss rend
VipBossFubenItem = VipBossFubenItem or BaseClass(BaseRender)
function VipBossFubenItem:__init()

end

function VipBossFubenItem:__delete()
	if self.chosen_item_cell then
		self.chosen_item_cell:DeleteMe()
		self.chosen_item_cell = nil
	end

	if nil ~= self.cell_gift_list then
		for k, v in pairs(self.cell_gift_list) do
			v:DeleteMe()
		end
		self.cell_gift_list = nil
	end
end

function VipBossFubenItem:CreateChild()
	BaseRender.CreateChild(self)
	self:CreateRewardCell()
	XUI.AddClickEventListener(self.node_tree.btn_enter.node, BindTool.Bind(self.EnterFuben, self), true)
	
end

function VipBossFubenItem:OnFlush()
	if nil == self.data then return end
	self.node_tree.img_boss.node:loadTexture(ResPath.GetBigPainting("vip_boss_" .. self.index))
	self.node_tree.img_boss_name.node:loadTexture(ResPath.GetVipResPath("vip_boss_txt_" .. self.index))


	local level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
	local txt = string.format(Language.Vip.BossLimitText, self.data.vip_lev)
	self.node_tree.txt_limit_lev.node:setString(txt)

	if level >= self.data.vip_lev then
		if self.data.inter_time == 0 then
			self.node_tree.btn_enter.node:setEnabled(true)
			self.node_tree.txt_remaind_time.node:setString(string.format(Language.Vip.FubenTime, 1))
		else
			self.node_tree.btn_enter.node:setEnabled(false)
			self.node_tree.txt_remaind_time.node:setString(string.format(Language.Vip.FubenTime, 0))
		end
	else
		self.node_tree.btn_enter.node:setEnabled(false)
		self.node_tree.txt_remaind_time.node:setString(txt)
	end
		
	self:BossShowReward()
end

function VipBossFubenItem:CreateSelectEffect()

end

function VipBossFubenItem:CreateRewardCell()
	self.cell_gift_list = {}
	for i = 1, 4 do
		local cell = BaseCell.New()
		local ph = self.ph_list["ph_gift_cell_" .. i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:GetView():setScale(0.8)
		self.node_tree.layout_gift_cells.node:addChild(cell:GetView(), 300)

		-- local cell_effect = AnimateSprite:create()
		-- cell_effect:setPosition(ph.x, ph.y)
		-- self.node_t_list.layout_gift_cells.node:addChild(cell_effect, 300)
		-- cell_effect:setVisible(false)
		-- cell.cell_effect = cell_effect

		table.insert(self.cell_gift_list, cell)
	end
	for k,v in pairs(self.cell_gift_list) do
		v:GetView():setVisible(false)
	end
end

function VipBossFubenItem:BossShowReward()
	if nil == self.cell_gift_list then return end

	local data = VipData.Instance:GetBossReward(self.data.vip_lev)
	-- local vis = false
	-- for i1 = 1, 8 do
	-- 	vis = data[i1] and true or false
	-- 	self.cell_gift_list[i1]:GetView():setVisible(vis)
	-- end
	for i1, v1 in ipairs(data) do
		self.cell_gift_list[i1]:GetView():setVisible(true)
		self.cell_gift_list[i1]:SetData(v1)
	end

end

function VipBossFubenItem:EnterFuben()
	VipBossCtrl:SendOnVipBossFubenReq(self.data.vip_lev)
end
