-- 限时优惠界面
OperateActLimitGoodsPage = OperateActLimitGoodsPage or BaseClass()

function OperateActLimitGoodsPage:__init()
	self.view = nil

end

function OperateActLimitGoodsPage:__delete()
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



function OperateActLimitGoodsPage:InitPage(view)
	self.view = view
	self:CreateNumBar()
	self:CreateShowItemsList()
	self:InitEvent()
	self:OnTimeLimitedGoodsEvt()
	-- LimitedActivityCtrl.Instance:TimeLimitedGoodsDataReq()
end



function OperateActLimitGoodsPage:InitEvent()
	self.time_limited_goods_evt = GlobalEventSystem:Bind(OperateActivityEventType.TIME_LIMITED_GOODS_DATA_CHANGE, BindTool.Bind(self.OnTimeLimitedGoodsEvt, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
end

function OperateActLimitGoodsPage:RemoveEvent()
	if self.time_limited_goods_evt then
		GlobalEventSystem:UnBind(self.time_limited_goods_evt)
		self.time_limited_goods_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end


function OperateActLimitGoodsPage:UpdateData()
	
end

function OperateActLimitGoodsPage:CreateShowItemsList()
	if not self.show_items_list then
		local ph = self.view.ph_list.ph_shop_list
		self.show_items_list = ListView.New()
		self.show_items_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, OperateActLimitGoodsRender, gravity, is_bounce, self.view.ph_list.ph_shop_item)
		local margin = 1
		local gap = (ph.w - 2 * margin - 3 * self.view.ph_list.ph_shop_item.w) / 3
		self.show_items_list:SetItemsInterval(gap)
		self.show_items_list:SetMargin(margin)
		self.show_items_list:SetJumpDirection(ListView.Left)
		self.view.node_t_list.layout_discount.node:addChild(self.show_items_list:GetView(), 90)
	end
end

function OperateActLimitGoodsPage:CreateNumBar()
	if not self.rest_count_numBar then
		local ph = self.view.ph_list.ph_num
		self.rest_count_numBar = NumberBar.New()
		self.rest_count_numBar:SetRootPath(ResPath.GetMainui("num_"))
		self.rest_count_numBar:SetPosition(ph.x, ph.y)
		self.rest_count_numBar:SetGravity(NumberBarGravity.Center)
		self.rest_count_numBar:SetSpace(-5)
		self.view.node_t_list.layout_discount.node:addChild(self.rest_count_numBar:GetView(), 90)
		self.rest_count_numBar:SetNumber(0)
	end
end

function OperateActLimitGoodsPage:OnTimeLimitedGoodsEvt()
	local rest_count = OperateActivityData.Instance:GetLimitGoodsRestCount()
	local data_list = OperateActivityData.Instance:GetLimitGoodsInfo()
	if self.rest_count_numBar then
		self.rest_count_numBar:SetNumber(rest_count)
	end
	self:FlushRemainTime()
	self.show_items_list:SetDataList(data_list)
end

function OperateActLimitGoodsPage:FlushRemainTime()
	local time = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.TIME_LIMIT_GOODS)
	if time == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end

	if self.view.node_t_list.text_time_1 then
		self.view.node_t_list.text_time_1.node:setString(time)
	end
end