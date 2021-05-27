ActivityActiveDegreeRewardTips = ActivityActiveDegreeRewardTips or BaseClass(XuiBaseView)
ActivityActiveDegreeRewardTips.Width = 395
function ActivityActiveDegreeRewardTips:__init()
	self.is_modal = true
	self.is_any_click_close = true
	self.config_tab  = {
							{"activity_ui_cfg", 5, {0},}
						}
	self.activedegree = nil
end

function ActivityActiveDegreeRewardTips:__delete()
	
end

function ActivityActiveDegreeRewardTips:ReleaseCallBack()
	-- if nil ~= self.reward_cell then
	-- 	for k,v in pairs(self.reward_cell) do
	-- 		v:DeleteMe()
	-- 	end
	-- 	self.reward_cell = nil
	-- end
end

function ActivityActiveDegreeRewardTips:SetData(activedegree)
	self.activedegree = activedegree
	self:Flush()
end

function ActivityActiveDegreeRewardTips:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		-- self:CreateCells()
		self.node_t_list.rich_text_desc.node:setAnchorPoint(0.5, 0.5)
	end
end

function ActivityActiveDegreeRewardTips:OnFlush(paramt, index)
	local data, num = ActivityData.Instance:GetActiveDegreeNum(self.activedegree or 1)
	-- local  = ActiveDegreeData.Instance:GetRewardByStar(self.activedegree or 1) or {}
	local config = ItemData.Instance:GetItemConfig(data[1] and data[1].item_id)
	if config == nil then return end
	local txt = string.format(Language.Activity.Desc, num, config.desc)
	RichTextUtil.ParseRichText(self.node_t_list.rich_text_desc.node, txt, 20, COLOR3B.GREEN)
	self.node_t_list.rich_text_desc.node:refreshView()
	local bg_h = self.node_t_list.rich_text_desc.node:getInnerContainerSize().height +30
	self.root_node:setContentWH(ActivityActiveDegreeRewardTips.Width, bg_h)
	self.node_t_list.rich_text_desc.node:setPosition(ActivityActiveDegreeRewardTips.Width / 2 , bg_h / 2 + 46)
	self.node_t_list.reward_bg.node:setContentWH(ActivityActiveDegreeRewardTips.Width, bg_h)
	self.node_t_list.reward_bg1.node:setContentWH(ActivityActiveDegreeRewardTips.Width-10, bg_h-5)
	-- for k,v in pairs(self.reward_cell) do
	-- 	if k <= #data then
	-- 		v:GetView():setVisible(true)
	-- 		v:SetData(data[k])
	-- 	else
	-- 		v:GetView():setVisible(false)
	-- 	end
	-- end
end

function ActivityActiveDegreeRewardTips:OpenCallBack()
end

function ActivityActiveDegreeRewardTips:CloseCallBack()
end

function ActivityActiveDegreeRewardTips:CreateCells()
	-- self.reward_cell = {}
	-- for i = 1, 3 do
	-- 	local ph = self.ph_list["ph_cell_"..i]
	-- 	local cell = BaseCell.New()
	-- 	cell:SetPosition(ph.x, ph.y)
	-- 	cell:GetView():setAnchorPoint(0, 0)
	-- 	self.node_t_list.layout_reward_tips.node:addChild(cell:GetView(), 103)
	-- 	self.node_t_list.layout_reward_tips.node:setPosition(750,10)
	-- 	table.insert(self.reward_cell, cell)
	-- end
end