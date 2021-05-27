FubenRewardView = FubenRewardView or BaseClass(XuiBaseView)

function FubenRewardView:__init()
	self.texture_path_list[1] = 'res/xui/fuben.png'
	self.texture_path_list[2] = 'res/xui/mainui.png'
	self.texture_path_list[3] = 'res/xui/charge.png'
	
	self.config_tab = {
		{"fuben_child_view_ui_cfg", 1, {0}},
		{"fuben_child_view_ui_cfg", 2, {0}},
	}
	self.grid_list = nil
end

function FubenRewardView:__delete()
end

function FubenRewardView:ReleaseCallBack()
	if self.grid_list ~= nil then
		self.grid_list:DeleteMe()
		self.grid_list = nil 
	end

	ClientCommonButtonDic[CommonButtonType.SMSZ_REWARD_GRID] = nil
end

function FubenRewardView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateGrid()
	end
end

function FubenRewardView:OpenCallBack()
	
end

function FubenRewardView:CloseCallBack()
	
end

function FubenRewardView:ShowIndexCallBack(index)
	
end

function FubenRewardView:OnFlush(param_t, index)
	local data = FubenData.Instance:GetReward()
	local cur_data = {}
	for i, v in ipairs(data) do
		cur_data[i-1] = v
	end
	self.grid_list:SetDataList(cur_data)
	local monster_num, had_exp, drop_monster, drop_exp  = FubenData.Instance:GetRewardData()
	self.node_t_list.lbl_kill_mons.node:setString(monster_num)
	self.node_t_list.lbl_get_exp.node:setString(had_exp)
	self.node_t_list.lbl_miss_mons.node:setString(drop_monster)
	self.node_t_list.lbl_lost_exp.node:setString(drop_exp)
end

function FubenRewardView:CreateGrid()
	if self.grid_list == nil then
		self.grid_list = BaseGrid.New()
		self.grid_list:SetPageChangeCallBack(BindTool.Bind1(self.OnPageChangeCallBack, self))
		local ph_baggrid = self.ph_list.ph_reward_list
		local grid_node = self.grid_list:CreateCells({w=ph_baggrid.w, h=ph_baggrid.h, itemRender = RewardItemRender, direction = ScrollDir.Horizontal,cell_count= 6, col = 6, row = 1,ui_config = self.ph_list.ph_reward_info})
		grid_node:setAnchorPoint(0.5, 0.5)
		grid_node:setPosition(ph_baggrid.x, ph_baggrid.y)
		self.node_t_list.layout_strength_award.node:addChild(grid_node, 100)
		ClientCommonButtonDic[CommonButtonType.SMSZ_REWARD_GRID] = self.grid_list
	end
end

function FubenRewardView:OnPageChangeCallBack(grid, page_index, prve_page_index)
	-- body
end

RewardItemRender = RewardItemRender or BaseClass(BaseRender)

function RewardItemRender:__init()
	self.exp_cell = nil 
end

function RewardItemRender:__delete()
	if self.exp_cell then
		self.exp_cell:DeleteMe()
		self.exp_cell = nil 
	end
	self.effec = nil
end

function RewardItemRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.exp_cell == nil then
		local ph = self.ph_list.ph_cell
		self.exp_cell = BaseCell.New()
		self.exp_cell:SetPosition(ph.x, ph.y)
		self.exp_cell:GetView():setAnchorPoint(0.5, 0.5)
		self.exp_cell:SetIsShowTips(false)
		self.view:addChild(self.exp_cell:GetView(), 100)
	end
	XUI.SetButtonEnabled(self.node_tree.layout_btn.node, true)
	XUI.AddClickEventListener(self.node_tree.layout_btn.node, BindTool.Bind1(self.GetReward, self))
	XUI.SetButtonEnabled(self.exp_cell:GetView(), true)
	XUI.AddClickEventListener(self.exp_cell:GetView(), BindTool.Bind1(self.GetReward, self))
	if not self.effec then
		self.effec = RenderUnit.CreateEffect(10, self.node_tree.layout_btn.lbl_cost.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
		self.effec:setPosition(78, 126)
		self.effec:setScaleY(3)
		self.effec:setScaleX(0.6)
	end
end

function RewardItemRender:OnFlush()
	if self.data == nil then return end
	local  monster_num, had_exp, drop_monster, drop_exp  = FubenData.Instance:GetRewardData()
	local virtual_item_id = ItemData.Instance:GetVirtualItemId(11)
	self.exp_cell:SetData({["item_id"] = virtual_item_id, ["num"] = 1, is_bind = 0})
	local txt = ""
	local color = ""
	if self.data.count == 0 then
		txt = Language.Fuben.Free
		color = COLOR3B.WHITE
		self.effec:setVisible(false)
	else
		color = COLOR3B.YELLOW
		if self.data.re_type == 10 then
			txt = string.format(Language.Fuben.YuanBao, self.data.count)
		elseif self.data.re_type == 5 then
			txt = string.format(Language.Fuben.Bangyuan, self.data.count)
		end
		if had_exp == 0 then
			XUI.SetButtonEnabled(self.node_tree.layout_btn.node, false)
		elseif had_exp > 0 then
			XUI.SetButtonEnabled(self.node_tree.layout_btn.node, true)
		end
	end
	local num = nil 
	if self.data.pos < 5 then
		num = math.floor((had_exp/10000) * self.data.exp_rate)
	else
		num = math.floor(((had_exp+ drop_exp)/10000) * self.data.exp_rate)
	end
	local txt_1 = string.format(Language.Fuben.Exp_Count, num)
	self.node_tree.layout_btn.lbl_exp_val.node:setString(txt_1)
	self.node_tree.layout_btn.lbl_cost.node:setString(txt or 0)
	self.node_tree.layout_btn.lbl_cost.node:setColor(color)
	local txt = string.format(Language.Fuben.JinYan, self.data.exp_rate)
	self.node_tree.layout_btn.lbl_exp_time.node:setString(txt)
	local desc = ""
	if self.data.vip_1 == nil and self.data.lost_1 == false then
		desc = ""
	elseif self.data.vip_1 ~= nil and self.data.lost_1 == true then
		desc = string.format(Language.Fuben.Desc_1, self.data.vip_1)
	elseif  self.data.vip_1 ~= nil and self.data.lost_1 == false then
		desc = string.format(Language.Fuben.Desc_2, self.data.vip_1)
	end
	self.node_tree.layout_btn.txt_vip_level.node:setString(desc)
end

function RewardItemRender:GetReward()
	FubenCtrl.GetFubenReward(self.data.pos)
	-- XUI.SetButtonEnabled(self.node_tree.layout_btn.node, false)
	-- if self.exp_cell and self.exp_cell:GetView() then
	-- 	XUI.SetButtonEnabled(self.exp_cell:GetView(), false)
	-- end
end

function RewardItemRender:CompareGuideData(data)
	return self.data and self.data.pos == data
end

function RewardItemRender:GetGuideView()
	return self.node_tree.layout_btn.node
end