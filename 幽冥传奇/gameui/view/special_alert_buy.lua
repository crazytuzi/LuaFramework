SpecialAlertBuy = SpecialAlertBuy or BaseClass(BaseView)

function SpecialAlertBuy:__init(str, ok_func, cancel_func, close_func, has_checkbox, is_show_action, is_any_click_close)
	self.zorder = 90003
  
	self.config_tab = {
		{"dialog_ui_cfg", 4, {0},},
	}
	self.is_async_load = false
	self.is_any_click_close = nil == is_any_click_close and true or is_any_click_close
	self.is_modal = true
	self.content_str = nil ~= str and str or ""
	self.content_str2 = nil ~= str and str or ""
	self.rich2_alignment = nil
	self.ok_func = ok_func
	self.cancel_func = cancel_func
	self.close_func = close_func
	self.buy_func = nil
	self.has_checkbox = has_checkbox
	self.is_nolonger_tips = false					-- 是否勾选不再提示
	self.checkbox_tip_text = Language.Common.DontTip
	self.ok_btn_text = Language.Common.Confirm
	self.cancel_btn_text = Language.Common.Cancel
	self.data = nil
	self.record_not_tip = false
	self.auto_do_func = true
	self.check_box_default_select = false 

	-- 单个按钮时的"确定"按钮坐标
	self.one_pos_x, self.one_pos_y = 213, 42

	-- 两个按钮时的"确定"按钮坐标
	self.pos_x ,self.pos_y = 101, 42

	self.close_type = -1 --0 确定关闭， 1 取消关闭， 2 其他地方面板关闭

	self.is_use_one = false
	-- self.is_no_closeBtn = false
	self.auto_close_time = 0	-- 多少秒后自动关闭, 0 不自动关闭
	self.close_timer = nil
end

function SpecialAlertBuy:__delete()

end

function SpecialAlertBuy:OpenCallBack()
	--self:SetAutoCloseTime()
end

function SpecialAlertBuy:ReleaseCallBack( ... )
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function SpecialAlertBuy:ShowIndexCallBack()
	-- self.node_t_list.btn_OK.node:setPosition(self.pos_x, self.pos_y )
	-- self.node_t_list.btn_cancel.node:setVisible(true)
	-- -- self.node_t_list.btn_close_window.node:setVisible(true)

	-- if self.is_use_one then
	-- 	self:UseOne()
	-- end
	-- if self.is_no_closeBtn then
	-- 	self:NoCloseButton()
	-- end
	self:Flush(index)
end

function SpecialAlertBuy:LoadCallBack()
	self.is_modal = true
	
	-- self.rich_dialog_param = {}
	-- self.rich_dialog_param.x, self.rich_dialog_param.y = self.node_t_list.rich_dialog.node:getPosition()
	-- local size = self.node_t_list.rich_dialog.node:getContentSize()
	-- self.rich_dialog_param.w, self.rich_dialog_param.h = size.width, size.height
	-- self.node_t_list.rich_dialog.node:setVerticalAlignment(RichVAlignment.VA_CENTER)
	
	-- self:SetLableString(self.content_str)
	-- self:SetLableString2(self.content_str2, self.rich2_alignment)
	-- self:SetLableString4(self.content_str4, RichVAlignment.VA_CENTER)
	-- self:SetLableString5(self.content_str5, RichVAlignment.VA_CENTER)

	-- self.node_t_list.btn_OK.node:setTitleText(self.ok_btn_text)
	-- self.node_t_list.btn_cancel.node:setTitleText(self.cancel_btn_text)
	-- self.node_t_list.layout_nolonger_tips.node:setVisible(self.has_checkbox)
	-- self.node_t_list.label_no_longer.node:setString(self.checkbox_tip_text)

	self.node_t_list.btn_OK.node:addClickEventListener(BindTool.Bind1(self.OnClickOK, self))

	self.node_t_list.btn_cancel.node:addClickEventListener(BindTool.Bind1(self.OnClickCancel, self))

	self.node_t_list.btn_Buy.node:addClickEventListener(BindTool.Bind1(self.BuyItem,self))

	-- self.node_t_list.img_nohint_hook.node:setVisible(self.check_box_default_select)
	-- self.node_t_list.btn_nohint_checkbox.node:addClickEventListener(BindTool.Bind1(self.OnClickCheckBox, self))

	if self.cell == nil then

		local ph = self.ph_list.ph_item_cell
		self.cell = BaseCell.New()

		self.cell:GetView():setPosition(ph.x -1.5, ph.y-3.5)
		self.node_t_list.layout_confirm_dialog2.node:addChild(self.cell:GetView(), 99)
	end
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
end

-- function Alert:OnClickCheckBox()
-- 	local is_visible = self.node_t_list.img_nohint_hook.node:isVisible()
-- 	self.node_t_list.img_nohint_hook.node:setVisible(not is_visible)
-- 	self.is_nolonger_tips = not is_visible
-- end

-- function Alert:SetCheckBoxDefaultSelect(visible)
-- 	self.check_box_default_select = visible
-- 	self.is_nolonger_tips = visible
-- 	if self.node_t_list.img_nohint_hook then
-- 		self.node_t_list.img_nohint_hook.node:setVisible(visible)
-- 	end
-- end

function SpecialAlertBuy:SetIsAnyClickClose(is_any_click_close)
	self.is_any_click_close = is_any_click_close
end

function SpecialAlertBuy:OnClickOK()
	self.close_type = 0
	local can_close = true
	if nil ~= self.ok_func then
		self.record_not_tip = self.is_nolonger_tips
		can_close = self.ok_func(self.is_nolonger_tips, self.data)
		if nil == can_close then can_close = true end
	end

	if can_close then
		self:Close()
	end
end

function SpecialAlertBuy:OnClickCancel()
	self.close_type = 1
	local can_close = true
	if nil ~= self.cancel_func then
		can_close = self.cancel_func()
		if nil == can_close then can_close = true end
	end

	if can_close then
		self:Close()
	end
end

function SpecialAlertBuy:CloseCallBack()
	if self.close_type == 2 then
		if nil ~= self.close_func then
			self.close_func()
		end
	end

	self.close_type = -1
	GlobalTimerQuest:CancelQuest(self.close_timer)
end

-- 设置确定按钮文字
function SpecialAlertBuy:SetOkString(str)
	if nil ~= str and "" ~= str then
		self.ok_btn_text = str

		if nil ~= self.node_t_list.btn_OK then
			self.node_t_list.btn_OK.node:setTitleText(self.ok_btn_text)
		end
	end
end


function SpecialAlertBuy:SetShowConetent(item_id, desc)
	self.item_id = item_id 
	self:Flush(index)
end

function SpecialAlertBuy:FlushShow( ... )
	if self.item_id then
		self.cell:SetData({item_id = self.item_id, num = 1, is_bind = 0})

		self.item_price_cfg = ShopData.GetItemPriceCfg(self.item_id, 3)
		if self.item_price_cfg == nil then
			return
		end

		local item_config = ItemData.Instance:GetItemConfig(self.item_id)
		if nil == item_config then
			return
		end

	local price_type = self.item_price_cfg.price[1].type
		self.node_t_list.img_pt.node:loadTexture(ShopData.GetMoneyTypeIcon(price_type))

		local num = self.item_price_cfg.price[1].price
		self.node_t_list.text_num.node:setString(num)
		-- local item_data = {item_id = self.item_id, num = self.item_price_cfg.buyOnceCount, is_bind = self.item_price_cfg.price[1].bind and 1 or 0}
		-- self.item_cell:SetData(item_data)

		self.node_t_list.text_equip_name.node:setString(item_config.name)
		self.node_t_list.text_equip_name.node:setColor(Str2C3b(string.sub(string.format("%06x", item_config.color), 1, 6)))

	end
end

function SpecialAlertBuy:FlushShowDesc( ... )
	if self.item_id then
		local color = BagData.Instance:GetItemNumInBagById(self.item_id, nil) > 0 and "00ff00" or "ff0000"
		local text = string.format("消耗1个 (拥有{wordcolor;%s;%d}个)",color, BagData.Instance:GetItemNumInBagById(self.item_id, nil))
		RichTextUtil.ParseRichText(self.node_t_list.text_had.node, text)
		XUI.RichTextSetCenter(self.node_t_list.text_had.node)
	end
end

-- 设置取消按钮文字
function SpecialAlertBuy:SetCancelString(str)
	if nil ~= str and "" ~= str then
		self.cancel_btn_text = str

		if nil ~= self.node_t_list.btn_cancel then
			self.node_t_list.btn_cancel.node:setTitleText(self.cancel_btn_text)
		end
	end
end


-- 设置确定回调
function SpecialAlertBuy:SetOkFunc(ok_func)
	self.ok_func = ok_func
end

-- 设置取消回调
function SpecialAlertBuy:SetCancelFunc(cancel_func)
	self.cancel_func = cancel_func
end

-- 设置关闭回调
function SpecialAlertBuy:SetCloseFunc(close_func)
	self.close_func = close_func
end

function SpecialAlertBuy:SetBuyFunc( buy_func)
	self.buy_func = buy_func
end

function SpecialAlertBuy:SetData(value)
	self.data = value
end

function SpecialAlertBuy:BuyItem( ... )
	self.close_type = 3
	local can_close = true
	if nil ~= self.buy_func then
		can_close = self.buy_func()
		if nil == can_close then can_close = true end
	end

	-- if can_close then
	-- 	self:Close()
	-- end
end



function SpecialAlertBuy:GetIsNolongerTips()
	return self.is_nolonger_tips
end

function SpecialAlertBuy:Open()
	if self.record_not_tip and self.has_checkbox then
		if self.auto_do_func then
			self.ok_func(self.is_nolonger_tips, self.data)
		end
	else
		SpecialAlertBuy.super.Open(self)
	end
end



function SpecialAlertBuy:Close()
	if self.close_type == -1 then
		self.close_type = 2
	end
	Alert.super.Close(self)
end



function SpecialAlertBuy:OnCloseHandler()
	if self.close_before_func then
		self.close_before_func()
	else
		self:Close()
	end
end

function SpecialAlertBuy:SetCloseBeforeFunc(func)
	self.close_before_func = func
end

function SpecialAlertBuy:GetOkBtn()
	return self.node_t_list.btn_OK.node
end


function SpecialAlertBuy:ItemDataListChangeCallback( ... )
	self:Flush(index)
end

function SpecialAlertBuy:OnFlush()
	self:FlushShow()
	self:FlushShowDesc()
end



