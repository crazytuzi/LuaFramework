CombineServerRewardTips = CombineServerRewardTips or BaseClass(XuiBaseView)
CombineServerRewardTips.Width = 395
function CombineServerRewardTips:__init()
	self.is_modal = true
	self.is_any_click_close = true
	self.config_tab  = {
							{"combineserver_ui_cfg", 14, {0},}
						}
	self.activedegree = nil
end

function CombineServerRewardTips:__delete()
	
end

function CombineServerRewardTips:ReleaseCallBack()
	if nil ~= self.reward_cell then
		for k,v in pairs(self.reward_cell) do
			v:DeleteMe()
		end
		self.reward_cell = nil
	end
end

function CombineServerRewardTips:SetData(activedegree)
	self.activedegree = activedegree
	self:Flush()
end

function CombineServerRewardTips:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateCells()
		-- self.node_t_list.rich_text_desc.node:setAnchorPoint(0.5, 0.5)
	end
end

function CombineServerRewardTips:OnFlush(paramt, index)
	self.node_t_list.text_desc.node:setString(Language.CombineServerActivity.RewardTips[self.activedegree])
	local data = CombineServerData.Instance:GetArenaRewards(self.activedegree) or {}
	for k, v in pairs(self.reward_cell) do
		if k <= #data then
			v:GetView():setVisible(true)
			v:SetData(data[k])
		else
			v:GetView():setVisible(false)
		end
	end
end

function CombineServerRewardTips:OpenCallBack()
end

function CombineServerRewardTips:CloseCallBack()
end

function CombineServerRewardTips:CreateCells()
	self.reward_cell = {}
	for i = 1, 4 do
		local ph = self.ph_list["ph_cell_"..i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:GetView():setAnchorPoint(0, 0)
		self.node_t_list.layout_reward_tips.node:addChild(cell:GetView(), 103)
		self.node_t_list.layout_reward_tips.node:setPosition(750,10)
		table.insert(self.reward_cell, cell)
	end
end