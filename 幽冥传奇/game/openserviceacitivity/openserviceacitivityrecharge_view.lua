------------------------------------------------------------
-- 充值排行 配置 OpenSvrPayRankingCfg
------------------------------------------------------------

local OpenServiceAcitivityRechargeView = OpenServiceAcitivityRechargeView or BaseClass(SubView)

function OpenServiceAcitivityRechargeView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/openserviceacitivity.png'
	self.config_tab = {
		{"openserviceacitivity_ui_cfg", 3, {0}},
		{"openserviceacitivity_ui_cfg", 15, {0}},
	}

	self.cfg = FinancingCfg
end

function OpenServiceAcitivityRechargeView:LoadCallBack()
	WelfareCtrl.Instance.RechargeRankReq(2)

	self.info = WelfareData.Instance:GetRechargeRankInfo()

	self:CreateRechargeRankingList()

	RichTextUtil.ParseRichText(self.node_t_list["rich_tips"].node, OpenSvrPayRankingCfg.tips, 21, COLOR3B.OLIVE)
	XUI.AddClickEventListener(self.node_t_list["btn_tip"].node, BindTool.Bind(self.OnTipHanddler, self))
	EventProxy.New(WelfareData.Instance, self):AddEventListener(WelfareData.RECHARGE_RANK_INFO_CHANGE, BindTool.Bind(self.OnRechargeRankInfoChange, self))
end

function OpenServiceAcitivityRechargeView:ReleaseCallBack()
	if self.grid_scroll then
		self.grid_scroll:DeleteMe()
		self.grid_scroll = nil
	end

	if nil ~= self.update_spare_timer then
		GlobalTimerQuest:CancelQuest(self.update_spare_timer)
		self.update_spare_timer = nil
	end
end

function OpenServiceAcitivityRechargeView:ShowIndexCallBack()

	self:Flush()
end

function OpenServiceAcitivityRechargeView:OnFlush()
	local my_rank = self.info.my_rank == 0 and Language.RankingList.MyRanking or self.info.my_rank
	self:FlushLeftTime()

	local yb = self.info.yb_num or 0
	self.node_t_list["lbl_recharge"].node:setString(Language.OpenServiceAcitivity.RechargeYB .. yb)
	self.node_t_list["lbl_level"].node:setString(my_rank)

	local list = WelfareData.Instance.GetRechargeRankCfg()
	self.grid_scroll:SetDataList(list)
	self.grid_scroll:JumpToTop()
end

-- 创建"充值排行"视图
function OpenServiceAcitivityRechargeView:CreateRechargeRankingList()
	local ph_item = self.ph_list["ph_sports_item"]
	local ph = self.ph_list["ph_sports_list"]
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.h + 5, self.ItemsShow, ScrollDir.Vertical, false, ph_item)
	grid_scroll:GetView():setAnchorPoint(0, 0)
	self.node_t_list["layout_recharge"].node:addChild(grid_scroll:GetView(), 20)
	self.grid_scroll = grid_scroll
end

-- 刷新剩余时间
function OpenServiceAcitivityRechargeView:FlushLeftTime()
	local left_time = WelfareData.Instance.GetRechargeRankLeftTime()
	local _, gear = WelfareData.Instance.GetRechargeRankOpen()
	self.node_t_list["lbl_left_time"].node:setString(TimeUtil.FormatSecond2Str(left_time))
	if nil ~= self.update_spare_timer then
		GlobalTimerQuest:CancelQuest(self.update_spare_timer)
		self.update_spare_timer = nil
	end
	self.update_spare_timer = GlobalTimerQuest:AddRunQuest(function ()
		local left_time = WelfareData.Instance.GetRechargeRankLeftTime()
		self.node_t_list["lbl_left_time"].node:setString(TimeUtil.FormatSecond2Str(left_time))
		-- 改变期数时,刷新
		local _, gear2 = WelfareData.Instance.GetRechargeRankOpen()
		if (gear ~= gear2) then
			GlobalTimerQuest:CancelQuest(self.update_spare_timer)
			self.update_spare_timer = nil
			self:Flush()
		end
	end, 1)
end

----------------------------------------

function OpenServiceAcitivityRechargeView:OnRechargeRankInfoChange()
	self:Flush()
end

function OpenServiceAcitivityRechargeView:OnTipHanddler()
	local _, gear = WelfareData.Instance.GetRechargeRankOpen()
	gear = gear or 1
	local tip_bar = OpenSvrPayRankingCfg.GiftLevels[gear].tip_bar
	local tips = OpenSvrPayRankingCfg.GiftLevels[gear].tips
	DescTip.Instance:SetContent(tips, tip_bar)
end

----------------------------------------
-- 充值排行项目
----------------------------------------

OpenServiceAcitivityRechargeView.ItemsShow = BaseClass(BaseRender)
local ItemsShow = OpenServiceAcitivityRechargeView.ItemsShow
function ItemsShow:__init()
	self.award_cell_list = nil
end

function ItemsShow:__delete()
	if self.award_cell_list then 
		for k, v in pairs(self.award_cell_list) do
			v:GetView():removeFromParent()
			v:DeleteMe()
			v = nil
		end
		self.award_cell_list = nil
	end
end

function ItemsShow:CreateChild()
	BaseRender.CreateChild(self)
	if nil == self.data then return end
	self.reward_list_view = self.node_tree.scroll_award_view.node
	self.reward_list_view:setScorllDirection(ScrollDir.Horizontal)

	ph = self.ph_list["ph_rank_num"]
	self.rank_num = NumberBar.New()
	self.rank_num:Create(ph.x, ph.y, 0, 0, ResPath.GetCommon("num_150_"))
	self.rank_num:SetGravity(NumberBarGravity.Left)
	self.view:addChild(self.rank_num:GetView(), 101)
	
	self.info = WelfareData.Instance:GetRechargeRankInfo()
	self.node_tree["btn_receive"].remind_eff = RenderUnit.CreateEffect(23, self.node_tree["btn_receive"].node, 1)

	XUI.AddClickEventListener(self.node_tree["btn_receive"].node, BindTool.Bind(self.OnReceive, self))
end

function ItemsShow:OnFlush()
	if nil == self.data then return end
	local is_join_award = self.data.index == "join_award" -- 是参与奖
	local yb = self.info.yb_num or 0
	local is_join = yb >= OpenSvrConsumRankingCfg.minRankingConsum -- 已参与
	local unreceived = self.info.tag == 0 -- 未领取

	local role_name
	if (not is_join_award) then
		local rank_list = WelfareData.Instance:GetRechargeRankList()[self.data.index]
		if rank_list then
			role_name = rank_list.role_name
		end
		role_name = role_name or Language.OpenServiceAcitivity.NobodyOnList
		self.rank_num:SetNumber(self.data.index)
	end
	self.rank_num:GetView():setVisible(not is_join_award)

	self.node_tree["img_rank_1"].node:setVisible(not is_join_award)
	self.node_tree["img_rank_2"].node:setVisible(not is_join_award)
	self.node_tree["img_rank_3"].node:setVisible(is_join_award)

	self.node_tree["lbl_role_name"].node:setString(role_name)
	self.node_tree["lbl_role_name"].node:setVisible(role_name ~= nil)

	self.node_tree["btn_receive"].node:setVisible(is_join_award and unreceived)
	self.node_tree["btn_receive"].node:setEnabled(is_join)
	self.node_tree["btn_receive"].remind_eff:setVisible(is_join_award and is_join and unreceived)
	self.node_tree["img_stamp"].node:setVisible(is_join_award and is_join and (not unreceived))
	
	self:CreateAwardList()
end

function ItemsShow:OnReceive()
	-- 领取参与奖
	WelfareCtrl.Instance.RechargeRankReq(1)
end

function ItemsShow:CreateAwardList()
	if self.award_cell_list then 
		for k, v in pairs(self.award_cell_list) do
			v:GetView():removeFromParent()
			v:DeleteMe()
			v = nil
		end
		self.award_cell_list = nil
	end
	
	self.award_cell_list = {}
	local x, y = 0, 0
	local x_interval = 85
	for k, v in pairs(self.data.award) do
		local award_cell = BaseCell.New()
		award_cell:SetAnchorPoint(0, 0)
		self.reward_list_view:addChild(award_cell:GetView(), 99)
		award_cell:SetPosition(x, y)
		award_cell:SetData(v)
		x = x + x_interval
		table.insert(self.award_cell_list, award_cell)
	end
	local w = x
	self.reward_list_view:setInnerContainerSize(cc.size(w, 80))
end

function ItemsShow:CreateSelectEffect()
	return
end

function ItemsShow:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end
--------------------

return OpenServiceAcitivityRechargeView