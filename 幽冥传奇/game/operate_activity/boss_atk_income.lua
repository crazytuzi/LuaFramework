-- 新充值排行
OperateActBossAtkIncomePage = OperateActBossAtkIncomePage or BaseClass()

function OperateActBossAtkIncomePage:__init()
	self.view = nil

end

function OperateActBossAtkIncomePage:__delete()
	self:RemoveEvent()
	if self.sports_rank_list then
		self.sports_rank_list:DeleteMe()
		self.sports_rank_list = nil
	end

	self.view = nil
end



function OperateActBossAtkIncomePage:InitPage(view)
	self.view = view
	self:CreateShowItemsList()
	self:InitEvent()
	XUI.SetRichTextVerticalSpace(self.view.node_t_list.rich_boss_atk_desc_1.node,2)
end



function OperateActBossAtkIncomePage:InitEvent()
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)

end

function OperateActBossAtkIncomePage:RemoveEvent()
	if self.time_limited_goods_evt then
		GlobalEventSystem:UnBind(self.time_limited_goods_evt)
		self.time_limited_goods_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end


function OperateActBossAtkIncomePage:UpdateData()
	self:FlushRemainTime()
	local act_cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.BOSS_ATK_INCOME)
	local content = act_cfg and act_cfg.act_desc or ""
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_boss_atk_des.node, content, 24, COLOR3B.YELLOW)
	content = act_cfg and act_cfg.config.desc or ""
	content = content .. "\n"
	content = content .. (act_cfg and act_cfg.config.sceneDesc or "")
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_boss_atk_desc_1.node, content, 18)
	-- RichTextUtil.ParseRichText(self.view.node_t_list.rich_boss_atk_desc_2.node, content, 18)
	local data = OperateActivityData.Instance:GetBossAtkIncomeData()
	if data then
		self.sports_rank_list:SetData(data)
	end
end

function OperateActBossAtkIncomePage:CreateShowItemsList()
	if not self.sports_rank_list then
		local ph = self.view.ph_list.ph_boss_atk_list
		self.sports_rank_list = ListView.New()
		self.sports_rank_list:Create(ph.x, ph.y, ph.w, ph.h, direction, OperateBossAtkItem, nil, false, self.view.ph_list.ph_boss_atk_award_item)
		self.sports_rank_list:SetItemsInterval(2)
		self.sports_rank_list:SetJumpDirection(ListView.Top)
		self.view.node_t_list.layout_boss_atk.node:addChild(self.sports_rank_list:GetView(), 100)
	end
end

function OperateActBossAtkIncomePage:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.BOSS_ATK_INCOME)
	if time == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end

	if self.view.node_t_list.text_boss_atk_rest_time then
		RichTextUtil.ParseRichText(self.view.node_t_list.text_boss_atk_rest_time.node, string.format(Language.OperateActivity.RemianTime, time))
	end
end
