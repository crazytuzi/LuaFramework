
FindresTips = FindresTips or BaseClass(BaseView)

function FindresTips:__init()
	self.texture_path_list[1] = 'res/xui/bag.png'
	self.config_tab = {
		{"welfare_ui_cfg", 14, {0}}
	}

	self.awards_list = {}
	self.num_keyboard = nil
	self.item_count = 1

	self:SetIsAnyClickClose(true)
	self:SetModal(true)

	self.check_box_show = false
end

function FindresTips:__delete()
end

function FindresTips:ReleaseCallBack()
	self.item_count = 1

	self.item_price_cfg = nil
	self.auto_use = nil


	if nil ~= self.num_keyboard then
		self.num_keyboard:DeleteMe()
		self.num_keyboard = nil
	end

	if self.notzs_tip then
		self.notzs_tip:DeleteMe()
		self.notzs_tip = nil
	end

	if nil ~= self.task_award_list then
		self.task_award_list:DeleteMe()
		self.task_award_list = nil
	end
end

function FindresTips:OpenCallBack()
	
end

function FindresTips:CloseCallBack()
	-- self.item_count = 1
end

function FindresTips:LoadCallBack()
	self:CreateItemCell()
	self:CreateKeyBoard()

	XUI.AddClickEventListener(self.node_t_list.img9_buy_num_bg.node, BindTool.Bind1(self.OnOpenPopNum, self), false)
	XUI.AddClickEventListener(self.node_t_list.btn_minus.node, BindTool.Bind2(self.OnClickChangeNum, self, -1))
	XUI.AddClickEventListener(self.node_t_list.btn_plus.node, BindTool.Bind2(self.OnClickChangeNum, self, 1))
	XUI.AddClickEventListener(self.node_t_list.btn_OK.node, BindTool.Bind1(self.OnClickBuy, self))
	XUI.AddClickEventListener(self.node_t_list.btn_cancel.node, BindTool.Bind1(self.OnClickCancel, self))

end

function FindresTips:ShowIndexCallBack()
	self:Flush()
end

-- 是否显示复选框
function FindresTips:SetShowCheckBox(is_show)
	if self.has_checkbox ~= is_show then
		self.has_checkbox = is_show

		if nil ~= self.node_t_list.layout_nolonger_tips then
			self.node_t_list.layout_nolonger_tips.node:setVisible(is_show)
		end
	end
end

function FindresTips:OnFlush(param_t, index)
	if not param_t.param then return end
	self.tip_type = param_t.param[1]
	self.awards_list = param_t.param[2]
	self.item_count = param_t.param[3]

	self.item_price_cfg = param_t.param[4]
	self.task_id = param_t.param[5]
	self.max_num = param_t.param[3]

	local path = self.tip_type == 1 and ResPath.GetCommon("bind_gold") or ResPath.GetCommon("gold")
	self.node_t_list.img_cost_type.node:loadTexture(path)
	self.node_t_list.txt_title.node:setString(Language.Welfare.FindreTitle[self.tip_type])
	
	self:SetAwardShow()

	self:RefreshPurchaseView(self.item_count)
end

function FindresTips:SetAwardShow()
	local item_data = {}
	for k, v in pairs(self.awards_list) do
		local index = self.tip_type == 1 and 0.5 or 1
		local num = math.ceil(v.num * self.item_count * index)
		item_data[k] = {item_id = v.item_id, num = num, is_bind = v.is_bind}
	end
	self.task_award_list:SetDataList(item_data)
	self.task_award_list:SetCenter()
end

function FindresTips:SetItemCount(count)
	self.item_count = count
end

function FindresTips:SetItemId(item_id)
	-- self.item_id = item_id
	self:Flush()
end

--创建物品格子
function FindresTips:CreateItemCell()
	local ph = self.ph_list["ph_raskrew_list"]
	local ph_item = {w = BaseCell.SIZE, h = BaseCell.SIZE}
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w + 10, BaseCell, ScrollDir.Horizontal, false, ph_item)
	self.node_t_list.layout_finder_tip.node:addChild(grid_scroll:GetView(), 99)
	self.task_award_list = grid_scroll
end

--创建数字键盘
function FindresTips:CreateKeyBoard()
	if self.num_keyboard then return end

	self.num_keyboard = NumKeypad.New()
	self.num_keyboard:SetOkCallBack(BindTool.Bind1(self.OnClickEnterNumber, self))
end

function FindresTips:GetMaxBuyNum()
	if self.item_price_cfg == nil then
		return 1
	end

	-- local item_price = self.item_price_cfg.price[1].price
	-- local price_type = self.item_price_cfg.price[1].type
	-- local obj_attr_index = ShopData.GetMoneyObjAttrIndex(price_type)
	-- local role_money = RoleData.Instance:GetAttr(obj_attr_index)
	-- local enough_num = math.floor(role_money / item_price)

	return self.max_num--enough_num > 0 and enough_num or 1
end

function FindresTips:OnOpenPopNum()
	if nil ~= self.num_keyboard then
		self.num_keyboard:Open()
		self.num_keyboard:SetText(self.item_count)
		self.num_keyboard:SetMaxValue(self:GetMaxBuyNum())
	end
end

function FindresTips:OnClickChangeNum(change_num)
	local num = self.item_count + change_num
	
	if num < 1 then
		return
	end

	if num > self:GetMaxBuyNum() then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Common.MaxValue)
		return
	end

	self.item_count = num
	self:RefreshPurchaseView(self.item_count)
	self:SetAwardShow()
end

--刷新购买版界面
function FindresTips:RefreshPurchaseView(item_count)
	if self.item_price_cfg == nil then
		return
	end

	local item_price = self.item_price_cfg
	self.node_t_list.lbl_num.node:setString(item_count)
	self.node_t_list.label_cost.node:setString(item_count * item_price)
	self.item_count = item_count
	self:SetAwardShow()
end

--输入数字
function FindresTips:OnClickEnterNumber(num)
	self:RefreshPurchaseView(num)
end

--点击购买
function FindresTips:OnClickBuy()
	if self.item_price_cfg == nil then
		return
	end

	local need_noney = self.item_count * self.item_price_cfg
	if self.tip_type == 1 then
		local yb = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COIN)
		if yb >= need_noney then
			for i = 1, self.item_count do
				WelfareCtrl.Instance:FindResGetReq(self.tip_type, self.task_id)
			end
		else
			TipCtrl.Instance:OpenGetStuffTip(493)
		end
	elseif self.tip_type == 2 then
		local zs = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
		if zs >= need_noney then
			for i = 1, self.item_count do
				WelfareCtrl.Instance:FindResGetReq(self.tip_type, self.task_id)
			end
		else
			self.notzs_tip = self.notzs_tip or Alert.New()
			self.notzs_tip:SetShowCheckBox(false)
			self.notzs_tip:SetLableString(Language.Welfare.FindresNotZs)
			self.notzs_tip:SetOkFunc(function()
				ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
			end)
			self.notzs_tip:Open()
		end
	end

	self:Close()
end

function FindresTips:OnClickCancel()
	self:Close()
end

-- 设置一次购买并使用
function FindresTips:SetOnceAutoUse(auto_use)
	self.auto_use = auto_use and 1 or 0
end