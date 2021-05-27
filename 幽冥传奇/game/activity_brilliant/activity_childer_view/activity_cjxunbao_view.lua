CJXunBaoView = CJXunBaoView or BaseClass(ActBaseView)

function CJXunBaoView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function CJXunBaoView:__delete()
	if nil ~= self.cell_xb_reward_list then
		self.cell_xb_reward_list:DeleteMe()
		self.cell_xb_reward_list = nil
	end
end

function CJXunBaoView:InitView()
	self.node_t_list.btn_xb_go.node:addClickEventListener(BindTool.Bind(self.OnClickCJXunbaoHandler, self))
	self.node_t_list.btn_xb_lb.node:addClickEventListener(BindTool.Bind(self.OnClickSuperDrawHandler, self))

	-- if nil ~= self.update_spare_timer then
	-- 	GlobalTimerQuest:CancelQuest(self.update_spare_timer)
	-- end
	-- self.update_spare_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateSpareTime, self), 1)

	XUI.AddRemingTip(self.node_t_list["btn_xb_lb"].node)
end

function CJXunBaoView:UpdateSpareTime(end_time)
	local now_time = TimeCtrl.Instance:GetServerTime()
	local str = TimeUtil.FormatSecond2Str(end_time - now_time)
	self.node_t_list["lbl_activity_spare_time"].node:setString(str)
end

function CJXunBaoView:OnFlushTopView(beg_time, end_time, act_desc)
	self.node_t_list["lbl_activity_about"].node:setString(act_desc[1])
end

function CJXunBaoView:RefreshView(param_list)
	self:FlushXBView()
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CJXB)
	local lq_limit =  act_cfg and act_cfg.config.params[1] or 0
	local num  = ActivityBrilliantData.Instance.spare_xb_num
	local xb_count = lq_limit - num  % 5
	local reward_count = math.floor(num / lq_limit)
	self.node_t_list.layout_cjxunbao.lbl_draw.node:setString(Language.ActivityBrilliant.Text33 .. reward_count)

	self.node_t_list["btn_xb_lb"].node:UpdateReimd(reward_count > 0)
end

function CJXunBaoView:OnClickCJXunbaoHandler()
	ViewManager.Instance:OpenViewByDef(ViewDef.Explore)
	ActivityBrilliantCtrl.Instance:CloseView(self.act_id)
end

function CJXunBaoView:OnClickSuperDrawHandler()
	local act_id = ACT_ID.CJXB
   	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id)
end

function CJXunBaoView:FlushXBView()
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CJXB)

	local award_list = {}
	local index = 0
	for i,v in ipairs(act_cfg.config.award) do
		if v.display == 1 then
			award_list[index] = ItemData.InitItemDataByCfg(v)
			index = index + 1
		end
	end

	if nil == self.cell_xb_reward_list then
		local cell_count = #award_list + 1
		local ph = self.ph_list["ph_cell_list"]
		self.cell_xb_reward_list = BaseGrid.New()
		self.cell_xb_reward_list:Create(ph.x, ph.y, ph.w, ph.h, cell_count, 3, 2, ActBaseCell, ScrollDir.Horizontal, {w = BaseCell.SIZE, h = BaseCell.SIZE})
		self.node_t_list.layout_cjxunbao.node:addChild(self.cell_xb_reward_list:GetView(), 100)
	end

	self.cell_xb_reward_list:SetDataList(award_list)
end
