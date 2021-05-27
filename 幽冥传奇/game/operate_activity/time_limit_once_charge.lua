-- 限时单笔
OperateActTimeLimitOnceCharge = OperateActTimeLimitOnceCharge or BaseClass()

function OperateActTimeLimitOnceCharge:__init()
	self.view = nil

end

function OperateActTimeLimitOnceCharge:__delete()
	self:RemoveEvent()
	if self.rest_count_numBar then
		self.rest_count_numBar:DeleteMe()
		self.rest_count_numBar = nil
	end

	if self.show_items_list then
		self.show_items_list:DeleteMe()
		self.show_items_list = nil
	end

	self.view = nil
end



function OperateActTimeLimitOnceCharge:InitPage(view)
	self.view = view
	-- self:CreateNumBar()
	self:CreateShowItemsList()
	self:InitEvent()
	self:OnTimeLimitedGoodsEvt()
	-- LimitedActivityCtrl.Instance:TimeLimitedGoodsDataReq()
end

function OperateActTimeLimitOnceCharge:InitEvent()
	self.time_limited_goods_evt = GlobalEventSystem:Bind(OperateActivityEventType.TIME_LIMIT_ONCE_CHARGE, BindTool.Bind(self.OnTimeLimitedGoodsEvt, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
end

function OperateActTimeLimitOnceCharge:RemoveEvent()
	if self.time_limited_goods_evt then
		GlobalEventSystem:UnBind(self.time_limited_goods_evt)
		self.time_limited_goods_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function OperateActTimeLimitOnceCharge:UpdateData()
	-- local data_list = OperateActivityData.Instance:GetLimitGoodsInfoTwo()
	-- self.show_items_list:SetDataList(data_list)
	local cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.TIME_LIMIT_ONCE_CHARGE)
	local content = cfg and cfg.act_desc or ""
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_discount2_des_1.node, content, 22, COLOR3B.GREEN)
	self:OnTimeLimitedGoodsEvt()
end

function OperateActTimeLimitOnceCharge:CreateShowItemsList()
	if not self.show_items_list then
		local ph = self.view.ph_list.ph_discount2_list_1
		self.show_items_list = ListView.New()
		self.show_items_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, OperateActTimeLimitOnceRender, gravity, is_bounce, self.view.ph_list.ph_discount2_item_1)
		self.show_items_list:SetItemsInterval(10)
		self.show_items_list:SetJumpDirection(ListView.Top)
		self.view.node_t_list.layout_time_limit_once_charge.node:addChild(self.show_items_list:GetView(), 90)
	end
end

function OperateActTimeLimitOnceCharge:CreateNumBar()
	if not self.rest_count_numBar then
		local ph = self.view.ph_list.ph_discount2_num
		self.rest_count_numBar = NumberBar.New()
		self.rest_count_numBar:SetRootPath(ResPath.GetMainui("num_"))
		self.rest_count_numBar:SetPosition(ph.x, ph.y)
		self.rest_count_numBar:SetGravity(NumberBarGravity.Center)
		self.rest_count_numBar:SetSpace(-5)
		self.view.node_t_list.layout_time_limit_once_charge.node:addChild(self.rest_count_numBar:GetView(), 90)
		self.rest_count_numBar:SetNumber(0)
	end
end

function OperateActTimeLimitOnceCharge:OnTimeLimitedGoodsEvt()
	-- local rest_count = OperateActivityData.Instance:GetLimitGoodsRestCountTwo()
	-- if self.rest_count_numBar then
	-- 	self.rest_count_numBar:SetNumber(rest_count)
	-- end
	local data_list = OperateActivityData.Instance:GetTimeLimitOnceData()
	self.show_items_list:SetDataList(data_list)
	self:FlushRemainTime()
end

function OperateActTimeLimitOnceCharge:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.TIME_LIMIT_ONCE_CHARGE)
	if time == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end

	if self.view.node_t_list.text_discount2_time_1 then
		self.view.node_t_list.text_discount2_time_1.node:setString(time)
	end
end