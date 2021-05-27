ChongFuCZView = ChongFuCZView or BaseClass(ActBaseView)

function ChongFuCZView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function ChongFuCZView:__delete()
	if nil ~= self.cell_cf_reward_list then
		self.cell_cf_reward_list:DeleteMe()
		self.cell_cf_reward_list = nil
	end
end

function ChongFuCZView:InitView()
	self.node_t_list.btn_chagre.node:addClickEventListener(BindTool.Bind(self.OnClickActChargeHandler, self))
	self.node_t_list.btn_charge_lingqu.node:addClickEventListener(BindTool.Bind(self.OnClickActChargeRewardHandler, self))
	self:CreateActChargeRewards()
	XUI.RichTextSetCenter(self.node_t_list["rich_times"].node)
end

function ChongFuCZView:RefreshView(param_list)
	local num = ActivityBrilliantData.Instance:GetTodayRecharge() 
	self.node_t_list.layout_chagre_again.lbl_activity_tip.node:setString(num)

	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CFCZ)
	self.node_t_list.lbl_chagre_count.node:setString(act_cfg.config.params[1])
	if act_cfg then
		local data_list = {}
		for _, v in pairs(act_cfg.config.award) do
			table.insert(data_list, ItemData.FormatItemData(v))
		end
		self.cell_cf_reward_list:SetDataList(data_list)

		-- 居中处理
		self.cell_cf_reward_list:SetCenter()
	end

	local lingqu_num = ActivityBrilliantData.Instance.lingqu_num
	local max_times = act_cfg and act_cfg.config and act_cfg.config.params[2] or 0
	local text = string.format(Language.ActivityBrilliant.Text20, lingqu_num, max_times)
	local rich = self.node_t_list["rich_times"].node
	rich = RichTextUtil.ParseRichText(rich, text, 20, COLOR3B.GREEN)
	rich:setVisible(true)
	rich:refreshView()
end

function ChongFuCZView:CreateActChargeRewards()
	local ph = self.ph_list["ph_award_list"]
	self.cell_cf_reward_list = ListView.New()
	self.cell_cf_reward_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ActBaseCell, ListViewGravity.CenterHorizontal, false, {w = 80, h = 80})
	self.cell_cf_reward_list:SetItemsInterval(5)
	self.node_t_list.layout_chagre_again.node:addChild(self.cell_cf_reward_list:GetView(), 100)
end

function ChongFuCZView:OnClickActChargeHandler()
	ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
end

function ChongFuCZView:OnClickActChargeRewardHandler()
	local act_id = ACT_ID.CFCZ
   	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id)
end
