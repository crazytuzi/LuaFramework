StrengthfbRewardTips = StrengthfbRewardTips or BaseClass(XuiBaseView)

function StrengthfbRewardTips:__init()
	self.is_modal = true
	self.is_any_click_close = true
	self.config_tab  = {
							{"strengthfb_ui_cfg", 4, {0},}
						}
	self.page = nil 
	self.stage = nil
end

function StrengthfbRewardTips:__delete()
	
end

function StrengthfbRewardTips:ReleaseCallBack()
	if nil ~= self.reward_cell then
		for k,v in pairs(self.reward_cell) do
			v:DeleteMe()
		end
		self.reward_cell = nil
	end
end

function StrengthfbRewardTips:SetData(page, stage)
	self.page = page
	self.stage = stage
	self:Flush()
end

function StrengthfbRewardTips:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateCells()
	end
end

function StrengthfbRewardTips:OnFlush(paramt, index)
	local data, achieve_num = StrenfthFbData.Instance:GetRewardByStar(self.page, self.stage)
	local txt = string.format(Language.StrenfthFb.Desc, achieve_num)
	RichTextUtil.ParseRichText(self.node_t_list.rich_text_desc.node, txt, 20, COLOR3B.OLIVE)
	for k,v in pairs(self.reward_cell) do
		if k <= #data then
			v:GetView():setVisible(true)
			v:SetData(data[k])
		else
			v:GetView():setVisible(false)
		end
	end
end

function StrengthfbRewardTips:OpenCallBack()
end

function StrengthfbRewardTips:CloseCallBack()
end

function StrengthfbRewardTips:CreateCells()
	self.reward_cell = {}
	for i = 1, 3 do
		local ph = self.ph_list["ph_cell_"..i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:GetView():setAnchorPoint(0, 0)
		self.node_t_list.layout_reward_tips.node:addChild(cell:GetView(), 103)
		self.node_t_list.layout_reward_tips.node:setPosition(750,10)
		table.insert(self.reward_cell, cell)
	end
end