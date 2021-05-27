OperateActivityView = OperateActivityView or BaseClass(XuiBaseView)

function OperateActivityView:InitOperSportsRank()
	self.last_id = nil
	if not self.sport_timer then
		self.node_t_list.rich_my_rank.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
		self.node_t_list.rich_rank_des.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
		self:CreateRankInfoList()
		self.sport_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushSportsRankRemainTime, self), 1)
		XUI.AddClickEventListener(self.node_t_list.btn_rank_tip.node,BindTool.Bind(self.OnHelp,self),true)
	end
end

function OperateActivityView:CreateRankInfoList()
	if not self.sports_rank_list then
		local ph = self.ph_list.ph_item_list_8
		self.sports_rank_list = ListView.New()
		self.sports_rank_list:Create(ph.x, ph.y, ph.w, ph.h, direction, OperateSportsRankItem, nil, false, self.ph_list.ph_list_item_8)
		self.sports_rank_list:SetItemsInterval(2)
		self.sports_rank_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_sports_rank.node:addChild(self.sports_rank_list:GetView(), 100)
	end
end

function OperateActivityView:DeleteOperSportsRank()
	self.last_id = nil
	if self.sports_rank_list then
		self.sports_rank_list:DeleteMe()
		self.sports_rank_list = nil
	end
	if self.sport_timer then
		GlobalTimerQuest:CancelQuest(self.sport_timer)
		self.sport_timer = nil
	end
	
end

function OperateActivityView:FlushRankView(act_id)
	if not self.node_t_list.layout_sports_rank or act_id ~= self.selec_act_id then return end
	local content = Language.OperateActivity.Content[self.selec_act_id]
	self.node_t_list.btn_rank_tip.node:setVisible(content ~= nil)
	local act_cfg = OperateActivityData.Instance:GetActCfgByActID(self.selec_act_id)
	local content = act_cfg and act_cfg.act_desc or ""
	RichTextUtil.ParseRichText(self.node_t_list.rich_rank_des.node, content, 24, COLOR3B.YELLOW)
	local my_rank = OperateActivityData.Instance:GetSportsRankMyRankByActID(self.selec_act_id)
	local limit_cnt = act_cfg and act_cfg.config.needMinValue or 0
	local limit_charge = act_cfg and act_cfg.config.needRechargeValue or 0
	if my_rank > 0 then
		if OperateActivityData.GetSportsRankType(self.selec_act_id) == 1 then
			content = string.format(Language.OperateActivity.SportsRankTexts[1], my_rank, string.format(Language.OperateActivity.SportsRankTexts[3], limit_cnt))
		elseif OperateActivityData.GetSportsRankType(self.selec_act_id) == 2 then
			content = string.format(Language.OperateActivity.SportsRankTexts[1], my_rank, string.format(Language.OperateActivity.SportsRankTexts[4],
						 OperateActivityData.GetChargeOrSpendStr(self.selec_act_id), limit_cnt))
		else
			content = string.format(Language.OperateActivity.SportsRankTexts[1], my_rank, string.format(Language.OperateActivity.SportsRankTexts[5],
						 limit_cnt, limit_charge))
		end
	else
		if OperateActivityData.GetSportsRankType(self.selec_act_id) == 1  then
			content = string.format(Language.OperateActivity.SportsRankTexts[2], string.format(Language.OperateActivity.SportsRankTexts[3], limit_cnt))
		elseif OperateActivityData.GetSportsRankType(self.selec_act_id) == 2 then
			content = string.format(Language.OperateActivity.SportsRankTexts[2], string.format(Language.OperateActivity.SportsRankTexts[4],
						 OperateActivityData.GetChargeOrSpendStr(self.selec_act_id), limit_cnt))
		else
			content = string.format(Language.OperateActivity.SportsRankTexts[2], string.format(Language.OperateActivity.SportsRankTexts[5],
						 limit_cnt, limit_charge))
		end
	end

	local val = OperateActivityData.Instance:GetSportsRankMyValuByActID(self.selec_act_id)
	if val then
		local attr_name = OperateActivityData.GetAttrNameByActID(self.selec_act_id)
		content = string.format(Language.OperateActivity.HasSome, val, attr_name) .. "  " .. content
	end
	RichTextUtil.ParseRichText(self.node_t_list.rich_my_rank.node, content)
	
	local cur_money = OperateActivityData.Instance:GetSportsRankMyMoneyByActID(self.selec_act_id)
	self.node_t_list.lbl_cur_money_title.node:setString("")
	self.node_t_list.lbl_cur_my_money.node:setString("")
	if cur_money and OperateActivityData.GetChargeOrSpendStr(self.selec_act_id) ~= "" then
		local title_str = OperateActivityData.GetChargeOrSpendStr(self.selec_act_id)
		self.node_t_list.lbl_cur_money_title.node:setString(string.format(Language.OperateActivity.CurRechargeSpendNum, title_str))
		self.node_t_list.lbl_cur_my_money.node:setString(cur_money)
	end

	if self.sports_rank_list then
		local data = OperateActivityData.Instance:GetSportsRankCfgByActID(self.selec_act_id) or {}
		self.sports_rank_list:SetDataList(data)
		if self.last_id ~= self.selec_act_id then
			self.last_id = self.selec_act_id
			self.sports_rank_list:JumpToTop(true)
		end
	end
	if self.node_t_list.lbl_rank_remain_time then
		self.node_t_list.lbl_rank_remain_time.node:setString("")
	end
	self:FlushSportsRankRemainTime()
end

function OperateActivityView:FlushSportsRankRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(self.selec_act_id)
	if self.node_t_list.lbl_rank_remain_time then
		self.node_t_list.lbl_rank_remain_time.node:setString(time)
	end
end

--帮助点击
function OperateActivityView:OnHelp()
	local content = Language.OperateActivity.Content[self.selec_act_id]
	if content then
		DescTip.Instance:SetContent(content, Language.OperateActivity.Title[1])
	end
end	