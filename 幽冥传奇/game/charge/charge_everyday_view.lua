-- 每日充值

local ChargeEveryDayView = ChargeEveryDayView or BaseClass(SubView)

function ChargeEveryDayView:__init()
	self.is_any_click_close = true
	self.is_modal = true
	self.texture_path_list[1] = 'res/xui/charge.png'
	self.config_tab = {
		{"charge_day_cfg", 1, {0}},
	}
end

function ChargeEveryDayView:__delete()
end

function ChargeEveryDayView:ReleaseCallBack()
	
end

function ChargeEveryDayView:LoadCallBack(index, loaded_times)
	
	self:ChangeListInfo()

	-- 顶部特效
	EventProxy.New(ChargeRewardData.Instance, self):AddEventListener(ChargeRewardData.EverydayDataChangeEvent, BindTool.Bind(self.OnFlushPanel, self))
end

function ChargeEveryDayView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	ChargeRewardCtrl.SendChargeEveryDayInfoReq()
	ChargeRewardCtrl.SendGetChargeEveryDayTreasureReq(0)
end

function ChargeEveryDayView:ShowIndexCallBack(index)
	self:Flush(index)
end

function ChargeEveryDayView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ChargeEveryDayView:ChangeListInfo()
	if nil == self.change_day_list then
		local ph = self.ph_list.ph_change_day_list
		self.change_day_list = ListView.New()
		self:AddObj("change_day_list")
		self.change_day_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ChargeEveryDayView.EveryChangeRender, nil, nil, self.ph_list.ph_change_day_item)
		-- self.change_day_list:GetView():setAnchorPoint(0, 0)
		self.change_day_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_everyday_charge_bg.node:addChild(self.change_day_list:GetView(), 100)
	end
end

-- 刷新
function ChargeEveryDayView:OnFlush(param_t, index)
	self:OnFlushPanel()

end

function ChargeEveryDayView:OnFlushPanel()
	self.change_day_list:SetDataList(ChargeRewardData.Instance:GetEveryDayChargeGiftIdentificationData())
end

ChargeEveryDayView.EveryChangeRender = BaseClass(BaseRender)
local EveryChangeRender = ChargeEveryDayView.EveryChangeRender
function EveryChangeRender:__init()	

end

function EveryChangeRender:__delete()	
	if self.charge_num then
   		self.charge_num:DeleteMe()
   		self.charge_num=nil
   	end
end

function EveryChangeRender:CreateChild()
	BaseRender.CreateChild(self)

	XUI.AddClickEventListener(self.node_tree.btn_rew.node, BindTool.Bind(self.OnClickGetGift, self), true)
	XUI.AddClickEventListener(self.node_tree.btn_charge.node, BindTool.Bind(self.OnClickCharge, self), true)

	self:CreateChargeNumberBar()

	self.cell_list = {}
	self.cell_view = self.node_tree.scroll_gift_cell.node
	self.cell_view:setScorllDirection(ScrollDir.Horizontal)
end

function EveryChangeRender:CreateChargeNumberBar()
	local ph = self.ph_list.ph_money_num
	-- 需要充值金额
	self.charge_num = NumberBar.New()
	self.charge_num:SetRootPath(ResPath.GetCharge("charge_num"))
	self.charge_num:SetPosition(ph.x, ph.y-14)
	self.charge_num:GetView():setScale(0.8)
	self.charge_num:SetGravity(NumberBarGravity.Center)
	self.view:addChild(self.charge_num:GetView(), 300, 300)
end

function EveryChangeRender:OnFlush()
	if self.data == nil then return end

	self.charge_num:SetNumber(self.data.need_money)
	XUI.RichTextSetCenter(self.node_tree.rich_need_money.node)
	RichTextUtil.ParseRichText(self.node_tree.rich_need_money.node, string.format(Language.Change.NeedMoney, self.data.money), 18, COLOR3B.OLIVE)


	self.node_tree.rich_need_money.node:setVisible(self.data.money > 0)
	self.node_tree.btn_charge.node:setVisible(self.data.money > 0)
	self.node_tree.img_stamp.node:setVisible(self.data.gift_state == 1)
	self.node_tree.btn_rew.node:setVisible(self.data.gift_state ~= 1)
	self.node_tree.img_lq_remind.node:setVisible(self.data.lq_state == 1)
	self:OnFlushCell()
end

function EveryChangeRender:OnClickGetGift()
	ChargeRewardCtrl.SendGetChargeEveryDayAwardReq(self.data.index)
end

function EveryChangeRender:OnClickCharge()
	ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
end

function EveryChangeRender:OnFlushCell()
	local data = ChargeRewardData.Instance:GetEveryDayChargeRewardData()[self.data.index]
	if nil == data then return end	
	for k,v in pairs(self.cell_list) do
		v:SetVisible(false)
	end

	local num = #data
	local ph = self.ph_list["ph_everyday_charge_cell"]
	local total_width
	if num <= 6 then
		total_width = 502
	else
		total_width = num * ph.w + (num - 1) * 8
	end
	local x, y = 0, 0
	for i, v in ipairs(data) do
		local cell = self.cell_list[i]
		if cell then
			cell:SetVisible(true)
		else
			local reward_cell = BaseCell.New()
			reward_cell:SetAnchorPoint(0.5, 0)
			reward_cell:SetCellBg(ResPath.GetCommon("cell_110"))
			self.cell_view:addChild(reward_cell:GetView(), 99)
			self.cell_list[i] = reward_cell
			cell = self.cell_list[i]
		end
		x = total_width / 2 - ((num / 2) * (ph.w + 8)) + ((ph.w + 8) * (i - 1) + ph.w / 2)
		cell:SetPosition(x, y)
		cell:SetData(v)
	end

	self.cell_view:setInnerContainerSize(cc.size(total_width, 90))
end

function EveryChangeRender:CreateSelectEffect()
end

return ChargeEveryDayView