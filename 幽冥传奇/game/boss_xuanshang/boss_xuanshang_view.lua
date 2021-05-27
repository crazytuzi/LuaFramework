BossXuanShangView = BossXuanShangView or BaseClass(XuiBaseView)

function BossXuanShangView:__init()
	self:SetModal(true)
	self.def_index = 1

	self.texture_path_list[1] = "res/xui/boss.png"
	self.title_img_path = ResPath.GetBoss("title_xuanshang")
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"boss_xuanshang_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}

end

function BossXuanShangView:__delete()

end

function BossXuanShangView:ReleaseCallBack()
	if self.xs_boss_list then
		self.xs_boss_list:DeleteMe()
		self.xs_boss_list = nil
	end
end

function BossXuanShangView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateBossList()

		XUI.AddClickEventListener(self.node_t_list.helpBtn.node, BindTool.Bind2(self.OnHelp, self))
	end
end

function BossXuanShangView:CreateBossList()
	local ph = self.ph_list.ph_xs_boss_list
	self.xs_boss_list = ListView.New()
	self.xs_boss_list:Create(ph.x, ph.y, ph.w, ph.h, direction, XsBossRender, nil, false, self.ph_list.ph_xs_boss_item)
	self.xs_boss_list:SetItemsInterval(3)
	self.xs_boss_list:SetMargin(3)
	self.xs_boss_list:GetView():setAnchorPoint(0, 0)
	self.xs_boss_list:SetJumpDirection(ListView.Top)
	-- self.xs_boss_list:SetSelectCallBack(BindTool.Bind(self.SelectTypeCallback, self))
	self.node_t_list.layout_suanshang_boss.node:addChild(self.xs_boss_list:GetView(), 100)
end

function BossXuanShangView:OpenCallBack()
	BossXuanShangCtrl.Instance:SendBossInfoReq()
end

function BossXuanShangView:ShowIndexCallBack(index)
	self:Flush(index)
end

function BossXuanShangView:OnFlush(param_t, index)
	local data = BossXuanShangData.Instance:GetBossData()
	self.xs_boss_list:SetData(data)
end

function BossXuanShangView:OnHelp()
	DescTip.Instance:SetContent(Language.Boss.BossXuanshangDesc, Language.Boss.BossXuanshangDescTitle)
end

XsBossRender = XsBossRender or BaseClass(BaseRender)
function XsBossRender:__init()
	
end

function XsBossRender:__delete()
	if nil ~= self.cell_gift_list then
		for k, v in pairs(self.cell_gift_list) do
			v:DeleteMe()
		end
		self.cell_gift_list = nil
	end
end

function XsBossRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_gift_list = {}
	for i = 1, 3 do
		local cell = BaseCell.New()
		local ph = self.ph_list["ph_xsboss_cell_" .. i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		self.view:addChild(cell:GetView(), 300)
		table.insert(self.cell_gift_list, cell)
	end
end

function XsBossRender:OnFlush()
	if not self.data then return end
	
	local boss_data = ConfigManager.Instance:GetMonsterConfig(self.data.boss_id)
	self.node_tree.img_icon.node:loadTexture(ResPath.GetBossHead("boss_icon_" .. boss_data.icon))
	self.node_tree.txt_boss_name.node:setString(boss_data.name)
	self.node_tree.txt_boss_level.node:setString(boss_data.level)

	local num, max_num = BossXuanShangData.Instance:GetBossKillNum(self.index)
	local itme_data = BossXuanShangData.Instance:GetBosskillReward(num, max_num, self.data.boss_id)
	self.node_tree.txt_kill_num.node:setString(num .. "/" .. max_num)
	if self.data.is_kill == 1 then
		self.node_tree.txt_is_kill.node:loadTexture(ResPath.GetCommon("stamp_36"))
	else
		self.node_tree.txt_is_kill.node:loadTexture(ResPath.GetCommon("stamp_37"))
	end

	local cur_data = {}
	for i, v in ipairs(itme_data) do
		if v.id == 0 then
			local virtual_item_id = ItemData.Instance:GetVirtualItemId(v.type)
			if virtual_item_id then
				cur_data[i] = {["item_id"] = virtual_item_id, ["num"] = v.count, is_bind = 0}
			end
		else
			cur_data[i] = {item_id = v.id, num = v.count, is_bind = 1}
		end
	end
	local vis = false
	for i1, v1 in ipairs(cur_data) do
		for i1 = 1, 3 do
			vis = cur_data[i1] and true or false
			self.cell_gift_list[i1]:GetView():setVisible(vis)
		end
		self.cell_gift_list[i1]:SetData(v1)
	end

	for i2, v2 in ipairs(self.cell_gift_list) do
		local ph = self.ph_list["ph_xsboss_cell_"..i2]
		if #cur_data == 1 then
			v2:GetView():setPositionX(ph.x + 105)
		elseif #cur_data == 2 then
			v2:GetView():setPositionX(ph.x + 45)
		end
	end
	
end



