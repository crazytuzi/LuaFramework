------------------------------------------------------------
-- 天天返利视图 config：EveryDayBackCfg 天天充值豪礼配置:EveryDayPayGiftCfg
------------------------------------------------------------

local InvestmentRebateView = BaseClass(SubView)

function InvestmentRebateView:__init()
	self.texture_path_list[1] = 'res/xui/investment.png'
	self.config_tab = {
		{"investment_ui_cfg", 3, {0}},
	}
end

function InvestmentRebateView:__delete()
end

function InvestmentRebateView:ReleaseCallBack()
	if self.reward_scroll_list then
		self.reward_scroll_list:DeleteMe()
		self.reward_scroll_list = nil
	end

	if self.day_award_list then
		self.day_award_list:DeleteMe()
		self.day_award_list = nil
	end

end

function InvestmentRebateView:LoadCallBack(index, loaded_times)
	self:CreateRewardListView()
	
	XUI.AddClickEventListener(self.node_t_list.btn_cz_money.node, BindTool.Bind(self.OnClickPayBtn, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_ques_fl.node, BindTool.Bind(self.OnClickTips, self))
	self.node_t_list.btn_ques_fl.node:setVisible(false)

	EventProxy.New(InvestmentData.Instance, self):AddEventListener(InvestmentData.Everyrebate, BindTool.Bind(self.Flush, self))
end

--显示索引回调
function InvestmentRebateView:ShowIndexCallBack(index)
	self:Flush()
end

----------视图函数----------

function InvestmentRebateView:OnFlush()
	self:RefreshView()
end

function InvestmentRebateView:RefreshView()
	if self.view_def == ViewDef.Investment.Everyrebate then
		self.reward_scroll_list:SetDataList(InvestmentData.Instance:GetRebateEveryDayDataList())
		self.day_award_list:SetDataList(InvestmentData.Instance:GetGourmetShow())
		if not InvestmentData.Instance:GetRebateEveryDayIsOpen() then
			ViewManager.Instance:CloseViewByDef(ViewDef.Investment)
		end
	else
		local path = ResPath.GetBigPainting("investment_bg_3")
		self.node_t_list["img_top"].node:loadTexture(path)

		local cfg = EveryDayPayGiftCfg or {}
		local award_list = cfg.AwardList or {}
		local show_item = cfg.ShowItem or {}
		local day_charge_gold_num = OtherData.Instance:GetDayChargeGoldNum()
		local luxury_gifts_pay_day = InvestmentData.Instance:GetLuxuryGiftsPayDay()
		local luxury_gifts_cur_index = InvestmentData.Instance:GetLuxuryGiftsCurIndex()
		local list = {}
		for i, v in ipairs(award_list) do
			local data = {award_list = {},}
			data.index = i
			data.btn_state = i <= luxury_gifts_cur_index and 2 or 1 -- 1-未领取 2-已领取 

			if i >= (luxury_gifts_cur_index + 1) and i <= luxury_gifts_pay_day then
				data.btn_state = 0 -- 可领取
			end

			for i,v in ipairs(v.awards) do
				table.insert(data.award_list, ItemData.InitItemDataByCfg(v))
			end

			table.insert(list, data)
		end
		table.sort(list, function(a, b)
				if a.btn_state ~= b.btn_state then
					return a.btn_state < b.btn_state
				else
					return a.index < b.index
				end
			end)
		self.reward_scroll_list:SetDataList(list)

		local list = {}
		local show_item = cfg.ShowItem or {}

		local item_1 = {}
		local item_2 = {}
		for k1, v1 in pairs(show_item) do
			if k1 % 2 == 0 then
				table.insert(item_2, ItemData.InitItemDataByCfg(v1))
			else
				table.insert(item_1, ItemData.InitItemDataByCfg(v1))
			end
		end

		for i = 1, math.ceil(#show_item/2) do
			list[i] = {}
			list[i].item_1 = item_1[i]
			list[i].item_2 = item_2[i]
		end

		self.day_award_list:SetDataList(list)
	end
end

function InvestmentRebateView:CreateRewardListView()
	if nil == self.reward_scroll_list then
		local ph = self.ph_list.ph_everyday_list
		self.reward_scroll_list = ListView.New()
		self.reward_scroll_list:Create( ph.x, ph.y, ph.w, ph.h, nil, self.EveryRebateRender, nil, nil, self.ph_list.ph_everyday_item)
		self.node_t_list.layout_every_rebate.node:addChild(self.reward_scroll_list:GetView(), 100)
		self.reward_scroll_list:SetJumpDirection(ListView.Top)
		self.reward_scroll_list:SetMargin(2) --首尾留空
	end

	if nil == self.day_award_list then
		local ph = self.ph_list.ph_day_award_list
		self.day_award_list = ListView.New()
		self.day_award_list:Create( ph.x, ph.y, ph.w, ph.h, nil, self.DayAwardItem, nil, nil, self.ph_list.ph_day_award_item)
		self.node_t_list.layout_every_rebate.node:addChild(self.day_award_list:GetView(), 100)
		self.day_award_list:SetJumpDirection(ListView.Top)
		self.day_award_list:SetMargin(2) --首尾留空
	end
end

function InvestmentRebateView:OnClickTips()
	if self.view_def == ViewDef.Investment.Everyrebate then
		DescTip.Instance:SetContent(Language.Investment.DayTipContent,Language.Investment.DayTipTitle)
	else
		DescTip.Instance:SetContent(Language.Investment.DayTipContent,Language.Investment.DayTipTitle)
	end
end

function InvestmentRebateView:OnClickPayBtn()
	if IS_ON_CROSSSERVER then return end
	ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
end

--------------------

-------------------------------------------------------------------------------------------------------------------
InvestmentRebateView.EveryRebateRender = InvestmentRebateView.EveryRebateRender or BaseClass(BaseRender)
local EveryRebateRender = InvestmentRebateView.EveryRebateRender
function EveryRebateRender:__init()
end

function EveryRebateRender:__delete()
	self.awards_list:DeleteMe()
end

function EveryRebateRender:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.btn_award_lingqu.node, BindTool.Bind(self.OnClickBuyBtn, self))
	local ph = self.ph_list.ph_award_list_view
	
	self.awards_list = ListView.New()
	self.awards_list:Create(ph.x, ph.y, ph.w, ph.h,  ScrollDir.Horizontal, ActBaseCell, nil, nil,self.ph_list.ph_awrad)
	self.view:addChild(self.awards_list:GetView(), 100)
	self.awards_list:SetJumpDirection(ListView.Left)
	self.awards_list:SetItemsInterval(15)
	self.awards_list:SetMargin(5) --首尾留空
end

function EveryRebateRender:OnClickBuyBtn()
	if self.data == nil then return end
	if ViewManager.Instance:IsOpen(ViewDef.Investment.Everyrebate) then
		InvestmentCtrl.Instance:SendGetRebateEveryDayReward(self.data.index)
	else
		InvestmentCtrl.SendLuxuryGifts(2, self.data.index)
	end
end

function EveryRebateRender:OnFlush()
	if nil == self.data then
		return
	end
	self.node_tree.lbl_reward_day.node:setString(string.format(Language.Investment.DayText,self.data.index))

	if self.data.award_list then
		 self.awards_list:SetDataList(self.data.award_list)
	end

	local text = self.data.btn_state == 2 and Language.Common.YiLingQu or Language.Common.LingQu
	self.node_tree.btn_award_lingqu.node:setTitleText(text)

	self.node_tree.btn_award_lingqu.node:setEnabled(self.data.btn_state == 0)
end

function EveryRebateRender:CreateSelectEffect()
	return
end

----------------------------------------
-- 额外奖励item
----------------------------------------
InvestmentRebateView.DayAwardItem = BaseClass(BaseRender)
local DayAwardItem = InvestmentRebateView.DayAwardItem
function DayAwardItem:__init()
	self.cell_list = {}
end

function DayAwardItem:__delete()
	if self.cell_list then
		for i,v in ipairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = nil
	end
end

function DayAwardItem:CreateChild()
	BaseRender.CreateChild(self)
	for i = 1, 2 do
		local ph = self.ph_list["ph_cell_" .. i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:GetView():setAnchorPoint(0.5, 0.5)
		self.view:addChild(cell:GetView(), 20)
		self.cell_list[i] = cell
	end

end

function DayAwardItem:OnFlush()
	if nil == self.data then return end

	local award = {}
	award[1] = self.data.item_1 or {}
	award[2] = self.data.item_2 or {}

	for i,v in pairs(self.cell_list) do
		if award[i] then
			v:SetData(award[i])
			v:SetVisible(true)
		else
			v:SetVisible(false)
		end
	end

end

function DayAwardItem:CreateSelectEffect()
	return
end

return InvestmentRebateView