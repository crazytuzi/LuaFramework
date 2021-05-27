-- 限时优惠界面
LimitedActivityYhPage = LimitedActivityYhPage or BaseClass()

function LimitedActivityYhPage:__init()
	self.view = nil

end

function LimitedActivityYhPage:__delete()
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



function LimitedActivityYhPage:InitPage(view)
	self.view = view
	self:CreateNumBar()
	self:CreateShowItemsList()
	self:InitEvent()
	self:OnTimeLimitedGoodsEvt()
	LimitedActivityCtrl.Instance:TimeLimitedGoodsDataReq()
end



function LimitedActivityYhPage:InitEvent()
	self.time_limited_goods_evt = GlobalEventSystem:Bind(OtherEventType.TIME_LIMITED_GOODS_DATA_CHANGE, BindTool.Bind(self.OnTimeLimitedGoodsEvt, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushRemainTime, self), 60)
end



function LimitedActivityYhPage:RemoveEvent()
	if self.time_limited_goods_evt then
		GlobalEventSystem:UnBind(self.time_limited_goods_evt)
		self.time_limited_goods_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end


function LimitedActivityYhPage:UpdateData()
	-- body
end

function LimitedActivityYhPage:CreateShowItemsList()
	if not self.show_items_list then
		local ph = self.view.ph_list.ph_shop_list
		self.show_items_list = ListView.New()
		self.show_items_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, LimitGoodsItemRender, gravity, is_bounce, self.view.ph_list.ph_shop_item)
		local margin = 1
		local gap = (ph.w - 2 * margin - 3 * self.view.ph_list.ph_shop_item.w) / 3
		self.show_items_list:SetItemsInterval(gap)
		self.show_items_list:SetMargin(margin)
		self.show_items_list:SetJumpDirection(ListView.Left)
		self.view.node_t_list.layout_discount.node:addChild(self.show_items_list:GetView(), 90)
	end
end

function LimitedActivityYhPage:CreateNumBar()
	local ph = self.view.ph_list.ph_num
	self.rest_count_numBar = NumberBar.New()
	self.rest_count_numBar:SetRootPath(ResPath.GetMainui("num_"))
	self.rest_count_numBar:SetPosition(ph.x, ph.y)
	self.rest_count_numBar:SetGravity(NumberBarGravity.Center)
	self.rest_count_numBar:SetSpace(-5)
	self.view.node_t_list.layout_discount.node:addChild(self.rest_count_numBar:GetView(), 90)
	self.rest_count_numBar:SetNumber(0)
end

function LimitedActivityYhPage:OnTimeLimitedGoodsEvt()
	local rest_count = LimitedActivityData.Instance:GetLimitGoodsRestCount()
	local data_list = LimitedActivityData.Instance:GetLimitGoodsInfo()
	if self.rest_count_numBar then
		self.rest_count_numBar:SetNumber(rest_count)
	end
	self:FlushRemainTime()
	self.show_items_list:SetDataList(data_list)
end

function LimitedActivityYhPage:FlushRemainTime()
	local time = LimitedActivityData.Instance:GetLimitGoodsRemainTime()
	if not time then 
		return
	end
	time = math.floor(time - Status.NowTime)
	if time < 1 then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end

	local day = math.floor(time / (24 * 3600))
	local hour = math.floor((time / (60 * 60)) % 24)
	local minute = math.floor((time / 60) % 60)
	if self.view.node_t_list.text_time_1 then
		self.view.node_t_list.text_time_1.node:setString(string.format(Language.Limited.Time, day, hour, minute))
	end
end





------LimitGoodsItemRender------
LimitGoodsItemRender = LimitGoodsItemRender or BaseClass(BaseRender)
function LimitGoodsItemRender:__init()

end

function LimitGoodsItemRender:__delete()	
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function LimitGoodsItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_list = {}
	for i = 1, 2 do
		local ph = self.ph_list["ph_cell_" .. i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		self.view:addChild(cell:GetView(), 100)
		table.insert(self.cell_list, cell)
	end
	self.node_tree.btn_buy.node:addClickEventListener(BindTool.Bind(self.OnBuyClick, self))
end

function LimitGoodsItemRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.text_ingot.node:setString(self.data.ingot)
	self.node_tree.img_box.node:loadTexture(ResPath.GetLimitedActivity("box_" .. self.data.idx))
	self.node_tree.btn_buy.node:setTitleText("¥ " .. self.data.money)
	for i = 1, 2 do
		self.cell_list[i]:SetData(self.data.awards[i]) 
	end
end

function LimitGoodsItemRender:OnBuyClick()

end

function LimitGoodsItemRender:CreateSelectEffect()

end

