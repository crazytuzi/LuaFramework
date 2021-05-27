DegreeView = DegreeView or BaseClass(ActBaseView)

function DegreeView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function DegreeView:__delete()
	if self.degree_progressbar then
		self.degree_progressbar:DeleteMe()
		self.degree_progressbar = nil
	end

	if self.degree_reward_list then 
		self.degree_reward_list:DeleteMe()
		self.degree_reward_list = nil
	end

	self.select_degree_effect = nil
	self.reward_index = nil
end

function DegreeView:InitView()
	self.reward_index = nil
	self:CreateDegreeProgressbar()
	self:CreateDegreeEffect()
	self:CreateDegreeRewards()
	self.degree_bar_pos = {9, 30, 50, 70, 100}
	self:FlushDegreeReward(1)
	self:LoadShow()
end

function DegreeView:AddActCommonClickEventListener()
	for i=1,5 do
		XUI.AddClickEventListener(self.node_t_list["img_degree_cell_"..i].node, BindTool.Bind2(self.OnClickDegreeBox, self, i))
	end
	XUI.AddClickEventListener(self.node_t_list.btn_degree_lingqu.node, BindTool.Bind(self.OnClickLingqu, self))
end

function DegreeView:RefreshView(param_list)
	local act_cfg = ActivityBrilliantData.Instance:GetOperActCfg(self.act_id)
	if nil == act_cfg then return end
	local mine_num = ActivityBrilliantData.Instance.mine_num[self.act_id]
	self.node_t_list.lbl_degree_tip.node:setString(mine_num)
	local per = 100
	for i,v in ipairs(act_cfg.config) do
		if mine_num <= v.numbers then
			local max_per = self.degree_bar_pos[i] or 0
			local min_per = self.degree_bar_pos[i - 1] or 0
			per = min_per + (max_per - min_per) * (mine_num / v.numbers) 
			break
		end
	end
	self.degree_progressbar:SetPercent(per)
	
	--刷新状态
	local path = nil
	for i=1,5 do
		local pos_x, pos_y = self.node_t_list["img_degree_cell_"..i].node:getPosition()
		if act_cfg.config[i].numbers and act_cfg.config[i].numbers <= mine_num then
			path = ResPath.GetActivityBrilliant("act_35_5")
		else
			path = ResPath.GetActivityBrilliant("act_35_4")
		end
		local img = XUI.CreateImageView(pos_x + 10, pos_y - 70, path)
		self.node_t_list.layout_degree.node:addChild(img, 999)
	end

	local list = ActivityBrilliantData.Instance:GetDegreeBossSignList(self.act_id)
	for i,v in ipairs(list) do
		-- 全部领取完时,固定选中最后一档
		if v.sign == 0 or i == #list then
			self:FlushDegreeReward(i)
			break
		end
	end
end

function DegreeView:LoadShow()
	local act_cfg = ActivityBrilliantData.Instance:GetOperActCfg(self.act_id)
	for i=1,5 do
		local cfg = act_cfg.config or {}
		local cur_cfg = cfg[i] or {}
		local pos_x, pos_y = self.node_t_list["img_degree_cell_"..i].node:getPosition()
		local text = XUI.CreateText(pos_x, pos_y + 52, 100, 50, nil, cur_cfg.numbers or 0)
		text:setColor(COLOR3B.GREEN)
		self.node_t_list.layout_degree.node:addChild(text,999)

		local cur_award = cur_cfg.award and cur_cfg.award[1] or {} 
		local item_id = cur_award.id or 0
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		local path = ResPath.GetItem(item_cfg.icon)
		local icon = XUI.CreateImageView(pos_x, pos_y, path, true)
		self.node_t_list.layout_degree.node:addChild(icon, 99)
	end
end

function DegreeView:CreateDegreeProgressbar()
	self.degree_progressbar = ProgressBar.New()
	self.degree_progressbar:SetView(self.node_t_list.prog9_qh.node)
	self.degree_progressbar:SetTailEffect(991, nil, true)
	self.degree_progressbar:SetEffectOffsetX(-20)
	self.degree_progressbar:SetPercent(0)
end

function DegreeView:CreateDegreeEffect()
	local size = self.node_t_list.img_degree_cell_1.node:getContentSize()
	local x, y = self.node_t_list.img_degree_cell_1.node:getPosition()
	self.select_degree_effect = XUI.CreateImageView(x + 1, y - 1, ResPath.GetCommon("cell_118_select"), true)
	if nil == self.select_degree_effect then
		ErrorLog("DegreeView:CreateSelectEffect fail")
		return
	end
	self.node_t_list.layout_degree.node:addChild(self.select_degree_effect, 999)
end

function DegreeView:CreateDegreeRewards()
	local ph = self.ph_list["ph_award_list"] or {x = 0, y = 0, w = 10, h = 10}
	local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE}
	self.degree_reward_list = ListView.New()
	self.degree_reward_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ActBaseCell, ListViewGravity.CenterVertical, false, ph_item)
	self.degree_reward_list:SetItemsInterval(5)
	self.degree_reward_list:SetMargin(8)
	self.node_t_list.layout_degree.node:addChild(self.degree_reward_list:GetView(), 100)
end

function DegreeView:FlushDegreeReward(tag)
	local mine_num = ActivityBrilliantData.Instance.mine_num[self.act_id]
	self.reward_index = tag
	local x = self.node_t_list["img_degree_cell_"..tag].node:getPositionX()
	local list = ActivityBrilliantData.Instance:GetDegreeBossSignList(self.act_id)
	self.node_t_list.layout_degree.btn_degree_lingqu.node:setEnabled(list[tag].sign == 0 and mine_num >= list[tag].numbers)
	self.node_t_list.img_degree_arrow.node:setPositionX(x)
	self.select_degree_effect:setPositionX(x + 1)
	local act_cfg = ActivityBrilliantData.Instance:GetOperActCfg(self.act_id)
	local mine_num = ActivityBrilliantData.Instance.mine_num[self.act_id]

	local data_list = {}
	if act_cfg then
		for _, v in pairs(act_cfg.config[tag].award) do
			table.insert(data_list, ItemData.FormatItemData(v))
		end
	end
	self.degree_reward_list:SetDataList(data_list)
end

function DegreeView:OnClickLingqu()
	local act_id = self.act_id or 0
	local reward_index = self.reward_index or 0
	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, reward_index)
end

function DegreeView:OnClickDegreeBox(tag)
	self:FlushDegreeReward(tag)
end