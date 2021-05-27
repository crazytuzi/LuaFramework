ActBossView = ActBossView or BaseClass(ActBaseView)

function ActBossView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function ActBossView:__delete()
	if self.boss_progressbar then
		self.boss_progressbar:DeleteMe()
		self.boss_progressbar = nil
	end

	if self.boss_reward_t then 
		for k,v in pairs(self.boss_reward_t) do
			v:DeleteMe()
		end
		self.boss_reward_t = {}
	end
	self.select_boss_effect = nil
end

function ActBossView:InitView()
	self:CreateBossProgressbar()
	self:CreateBossEffect()
	self:CreateBossRewards()
	self.boss_bar_pos = {9, 30, 50, 70, 100}
	self:FlushBossReward(1)
	self:BossAddClickEventListener()
	self:LoadBossTxtShow()
end

function ActBossView:RefreshView(param_list)
	local act_cfg = ActivityBrilliantData.Instance:GetOperActCfg(ACT_ID.BOSS)
	if nil == act_cfg then return end
	local mine_num = ActivityBrilliantData.Instance.mine_num[ACT_ID.BOSS]
	self.node_t_list.lbl_boss_tip.node:setString(mine_num)
	local per = 100
	for i,v in ipairs(act_cfg.config) do
		if mine_num <= v.numbers then
			local max_per = self.boss_bar_pos[i] or 0
			local min_per = self.boss_bar_pos[i - 1] or 0
			per = min_per + (max_per - min_per) * (mine_num / v.numbers) 
			break
		end
	end

	self.boss_progressbar:SetPercent(per)

	local sing_list = ActivityBrilliantData.Instance:GetDegreeBossSignList(ACT_ID.BOSS)
	for k1,v1 in pairs(sing_list) do
		self:FlushBossReward(v1.index)
	end
	
	-- for k,v in pairs(param_list) do
	-- 	if k == "flush_view" and v.result then
	-- 		self.node_t_list.layout_boss.btn_boss_lingqu.node:setEnabled(v.result ~= 0)
	-- 	end
	-- end
	--刷新状态
	local path = nil
	for i = 1, 5 do
		local pos_x, pos_y = self.node_t_list["img_boss_cell_" .. i].node:getPosition()
		if act_cfg.config[i].numbers and act_cfg.config[i].numbers <= mine_num then
			path = ResPath.GetActivityBrilliant("text_5")
		else
			path = ResPath.GetActivityBrilliant("text_4")
		end
		local img = XUI.CreateImageView(pos_x, pos_y - 70, path)
		self.node_t_list.layout_boss.node:addChild(img, 999)
	end
end

local reward_index = 0

function ActBossView:BossAddClickEventListener()
	for i = 1, 5 do
		XUI.AddClickEventListener(self.node_t_list["img_boss_cell_" .. i].node, BindTool.Bind(self.OnClickBossBox, self, i))
	end
	XUI.AddClickEventListener(self.node_t_list.btn_boss_lingqu.node, BindTool.Bind(self.OnClickLingquBoss, self))
end

function ActBossView:LoadBossTxtShow()
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.BOSS)
	for i = 1, 5 do
		local pos_x, pos_y = self.node_t_list["img_boss_cell_" .. i].node:getPosition()
		local text = XUI.CreateText(pos_x, pos_y + 50, 100, 50, nil, act_cfg.config[i].numbers)
		text:setColor(COLOR3B.GREEN)
		self.node_t_list.layout_boss.node:addChild(text,999)
	end
end

function ActBossView:CreateBossText()

end

function ActBossView:CreateBossProgressbar()
	self.boss_progressbar = ProgressBar.New()
	self.boss_progressbar:SetView(self.node_t_list.prog9_qh.node)
	self.boss_progressbar:SetTailEffect(991, nil, true)
	self.boss_progressbar:SetEffectOffsetX(-20)
	self.boss_progressbar:SetPercent(0)
end

function ActBossView:CreateBossRewards()
	self.boss_reward_t = {}
	for i = 1, 5 do
		local cell = ActBaseCell.New()
		local ph = self.ph_list["ph_degree_cell_" .. i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_boss.node:addChild(cell:GetView(), 300)
		table.insert(self.boss_reward_t, cell)
	end
end

function ActBossView:OnClickLingquBoss()
	local act_id = ACT_ID.BOSS
   	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, reward_index)
end

function ActBossView:OnClickBossBox(tag)
	self:FlushBossReward(tag)
end

function ActBossView:FlushBossReward(tag)
	reward_index = tag
	local mine_num = ActivityBrilliantData.Instance.mine_num[ACT_ID.BOSS]
	local list = ActivityBrilliantData.Instance:GetDegreeBossSignList(ACT_ID.BOSS)
	self.node_t_list.layout_boss.btn_boss_lingqu.node:setEnabled(list[tag].sign == 0 and mine_num >= list[tag].numbers)
	local ph = self.node_t_list["img_boss_cell_" .. tag].node:getPositionX()
	self.node_t_list.img_boss_arrow.node:setPositionX(ph)
	self.select_boss_effect:setPositionX(ph)
	local act_cfg = ActivityBrilliantData.Instance:GetOperActCfg(ACT_ID.BOSS)
	if act_cfg then
		for i,v in ipairs(self.boss_reward_t) do
			if  act_cfg.config[tag].award[i] then
				local data =  act_cfg.config[tag].award[i]
				if data.type == tagAwardType.qatEquipment then
					v:SetData({["item_id"] = data.id, ["num"] = data.count, is_bind = data.bind, effectId = data.effectId})
				else
					local virtual_item_id = ItemData.GetVirtualItemId(data.type)
					if virtual_item_id then
						v:SetData({["item_id"] = virtual_item_id, ["num"] = data.count, is_bind = 0, effectId = data.effectId})
					end
				end
			end
			v:SetVisible( act_cfg.config[tag].award[i] ~= nil)
		end
	end

end

function ActBossView:CreateBossEffect()
	local size = self.node_t_list.img_boss_cell_1.node:getContentSize()
	self.select_boss_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("cell_112_select"), true)
	self.select_boss_effect:setPosition(self.node_t_list.img_boss_cell_1.node:getPosition())
	if nil == self.select_boss_effect then
		ErrorLog("ActBossView:CreateSelectEffect fail")
		return
	end
	self.node_t_list.layout_boss.node:addChild(self.select_boss_effect,999)
end
