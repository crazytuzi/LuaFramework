BoxShowRewardTips = BoxShowRewardTips or BaseClass(XuiBaseView)

function BoxShowRewardTips:__init()
	self.is_modal = true
	self.is_any_click_close = true
	self.config_tab  = {
							{"mafa_explore_ui_cfg", 5, {0},}
						}
	self.circle = nil 
end

function BoxShowRewardTips:__delete()
	
end

function BoxShowRewardTips:ReleaseCallBack()
	if nil ~= self.reward_cell then
		for k,v in pairs(self.reward_cell) do
			v:DeleteMe()
		end
		self.reward_cell = nil
	end
end

function BoxShowRewardTips:SetData(circle)
	self.circle = circle
	-- self.star = star
	self:Flush()
end

function BoxShowRewardTips:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateCells()
	end
end

function BoxShowRewardTips:OnFlush(paramt, index)
	local txt = string.format(Language.AllDayActivity.CanGetRewardDesc, self.circle)
	RichTextUtil.ParseRichText(self.node_t_list.rich_text_desc.node, txt, 20, COLOR3B.OLIVE)
	local data = ActivityData.Instance:GetCirlceReward(self.circle) or {}
	for k,v in pairs(self.reward_cell) do
		v:GetView():setVisible(false)
	end
	for k,v in pairs(data) do
		if self.reward_cell[k] ~= nil then
			self.reward_cell[k]:GetView():setVisible(true)
			self.reward_cell[k]:SetData({item_id = v.id, num = v.count, is_bind = v.bind})
		end
	end
end

function BoxShowRewardTips:OpenCallBack()
end

function BoxShowRewardTips:CloseCallBack()
end

function BoxShowRewardTips:CreateCells()
	self.reward_cell = {}
	for i = 1, 3 do
		local ph = self.ph_list["ph_cell_"..i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:GetView():setAnchorPoint(0, 0)
		self.node_t_list.layout_reward_tips.node:addChild(cell:GetView(), 103)
		self.node_t_list.layout_reward_tips.node:setPosition(200,10)
		table.insert(self.reward_cell, cell)
	end
end