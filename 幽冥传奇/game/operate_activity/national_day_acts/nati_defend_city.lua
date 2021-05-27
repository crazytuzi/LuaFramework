-- 守卫主城
NatiDefendCityPage = NatiDefendCityPage or BaseClass()

function NatiDefendCityPage:__init()
	self.view = nil

end

function NatiDefendCityPage:__delete()
	self:RemoveEvent()
	if self.sports_rank_list then
		self.sports_rank_list:DeleteMe()
		self.sports_rank_list = nil
	end

	self.view = nil
end



function NatiDefendCityPage:InitPage(view)
	self.view = view
	self:CreateShowItemsList()
	self:InitEvent()
	self.rich_desc = self.view.node_tree.layout_defend_city.rich_boss_desc.node
	self.rich_desc_1 = self.view.node_tree.layout_defend_city.rich_boss_desc1.node
	self.view.node_tree.layout_defend_city.txt_defend_rest_time.node:setHorizontalAlignment(RichHAlignment.HA_RIGHT)
	XUI.SetRichTextVerticalSpace(self.rich_desc,2)
end



function NatiDefendCityPage:InitEvent()
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)

end

function NatiDefendCityPage:RemoveEvent()
	if self.time_limited_goods_evt then
		GlobalEventSystem:UnBind(self.time_limited_goods_evt)
		self.time_limited_goods_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end


function NatiDefendCityPage:UpdateData()
	self:FlushRemainTime()
	local act_cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.DEFEND_CITY)
	local content = act_cfg and act_cfg.act_desc or ""
	RichTextUtil.ParseRichText(self.rich_desc, content, 24, COLOR3B.YELLOW)
	content = act_cfg and act_cfg.config.desc or ""
	content = content .. "\n"
	content = content .. (act_cfg and act_cfg.config.sceneDesc or "")
	RichTextUtil.ParseRichText(self.rich_desc_1, content, 18)
	-- RichTextUtil.ParseRichText(self.view.node_tree.layout_defend_city.rich_boss_atk_desc_2.node, content, 18)
	local data = OperateActivityData.Instance:GetDefendCityData()
	if data then
		self.sports_rank_list:SetData(data)
	end
end

function NatiDefendCityPage:CreateShowItemsList()
	if not self.sports_rank_list then
		local ph = self.view.ph_list.ph_defend_city_list
		self.sports_rank_list = ListView.New()
		self.sports_rank_list:Create(ph.x, ph.y, ph.w, ph.h, direction, OperateDefendCityItem, nil, false, self.view.ph_list.ph_defend_city_item)
		self.sports_rank_list:SetItemsInterval(2)
		self.sports_rank_list:SetJumpDirection(ListView.Top)
		self.view.node_tree.layout_defend_city.node:addChild(self.sports_rank_list:GetView(), 100)
	end
end

function NatiDefendCityPage:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.DEFEND_CITY)
	if time == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end

	if self.view.node_tree.layout_defend_city.txt_defend_rest_time then
		RichTextUtil.ParseRichText(self.view.node_tree.layout_defend_city.txt_defend_rest_time.node, string.format(Language.OperateActivity.RemianTime, time))
	end
end
