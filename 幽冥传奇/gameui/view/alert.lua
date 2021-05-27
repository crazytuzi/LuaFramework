Alert = Alert or BaseClass(BaseView)

function Alert:__init(str, ok_func, cancel_func, close_func, has_checkbox, is_show_action, is_any_click_close)
	self.zorder = COMMON_CONSTS.ALERT_TIPS
  
	self.config_tab = {
		{"dialog_ui_cfg", 2, {0},},
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

function Alert:__delete()

end

function Alert:OpenCallBack()
	self:SetAutoCloseTime()
end

function Alert:ShowIndexCallBack()
	self.node_t_list.btn_OK.node:setPosition(self.pos_x, self.pos_y )
	self.node_t_list.btn_cancel.node:setVisible(true)
	-- self.node_t_list.btn_close_window.node:setVisible(true)

	if self.is_use_one then
		self:UseOne()
	end
	-- if self.is_no_closeBtn then
	-- 	self:NoCloseButton()
	-- end
end

function Alert:LoadCallBack()
	self.is_modal = true
	
	self.rich_dialog_param = {}
	self.rich_dialog_param.x, self.rich_dialog_param.y = self.node_t_list.rich_dialog.node:getPosition()
	local size = self.node_t_list.rich_dialog.node:getContentSize()
	self.rich_dialog_param.w, self.rich_dialog_param.h = size.width, size.height
	self.node_t_list.rich_dialog.node:setVerticalAlignment(RichVAlignment.VA_CENTER)
	
	local str = self.title_str or Language.Common.WXTS
	self:SetTitleString(str)

	self:SetLableString(self.content_str)
	self:SetLableString2(self.content_str2, self.rich2_alignment)
	self:SetLableString4(self.content_str4, RichVAlignment.VA_CENTER)
	self:SetLableString5(self.content_str5, RichVAlignment.VA_CENTER)

	self:SetLableString6(self.content_str6, RichVAlignment.VA_CENTER)

	self.node_t_list.btn_OK.node:setTitleText(self.ok_btn_text)
	self.node_t_list.btn_cancel.node:setTitleText(self.cancel_btn_text)
	self.node_t_list.layout_nolonger_tips.node:setVisible(self.has_checkbox)
	self.node_t_list.label_no_longer.node:setString(self.checkbox_tip_text)

	self.node_t_list.btn_OK.node:addClickEventListener(BindTool.Bind1(self.OnClickOK, self))

	self.node_t_list.btn_cancel.node:addClickEventListener(BindTool.Bind1(self.OnClickCancel, self))

	self.node_t_list.img_nohint_hook.node:setVisible(self.check_box_default_select)
	self.node_t_list.btn_nohint_checkbox.node:addClickEventListener(BindTool.Bind1(self.OnClickCheckBox, self))

end

function Alert:OnClickCheckBox()
	local is_visible = self.node_t_list.img_nohint_hook.node:isVisible()
	self.node_t_list.img_nohint_hook.node:setVisible(not is_visible)
	self.is_nolonger_tips = not is_visible
end

function Alert:SetCheckBoxDefaultSelect(visible)
	self.check_box_default_select = visible
	self.is_nolonger_tips = visible
	if self.node_t_list.img_nohint_hook then
		self.node_t_list.img_nohint_hook.node:setVisible(visible)
	end
end

function Alert:SetIsAnyClickClose(is_any_click_close)
	self.is_any_click_close = is_any_click_close
end

function Alert:OnClickOK()
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

function Alert:OnClickCancel()
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

function Alert:CloseCallBack()
	if self.close_type == 2 then
		if nil ~= self.close_func then
			self.close_func()
		end
	end

	self.close_type = -1
	GlobalTimerQuest:CancelQuest(self.close_timer)
end

function Alert:SetTitleString(str)
	if nil ~= str and "" ~= str then
		self.title_str = str
		if self.node_t_list["lbl_title"] then
			self.node_t_list["lbl_title"].node:setString(self.title_str)
		end
	end
end


-- 设置内容
function Alert:SetLableString(str)
	if self.node_t_list.layout_rich then
		self.node_t_list.layout_rich.node:setVisible(false)
	end
	if nil ~= str and "" ~= str then
		self.content_str = str

		if nil ~= self.node_t_list.rich_dialog then
			RichTextUtil.ParseRichText(self.node_t_list.rich_dialog.node, self.content_str, 24, COLOR3B.OLIVE)
			self.node_t_list.rich_dialog.node:refreshView()

			local text_renderer_size = self.node_t_list.rich_dialog.node:getInnerContainerSize()
			local text_x = self.rich_dialog_param.x + (self.rich_dialog_param.w - text_renderer_size.width) / 2
			local text_y = self.rich_dialog_param.y
			self.node_t_list.rich_dialog.node:setPosition(text_x, text_y)
		end
	end
end

-- 设置内容2
function Alert:SetLableString2(str, alignment, color)
	if nil ~= str and "" ~= str then
		self.content_str2 = str
		self.rich2_alignment = alignment
		self.rich2_color = color or self.rich2_color
		if nil ~= self.node_t_list.rich_dialog2 then
			if nil ~= alignment then
				self.node_t_list.rich_dialog2.node:setHorizontalAlignment(self.rich2_alignment)
			end

			RichTextUtil.ParseRichText(self.node_t_list.rich_dialog2.node, self.content_str2, 24, self.rich2_color or COLOR3B.OLIVE)
			--self.node_t_list.rich_dialog2.node:refreshView()
		end
	end
end


function Alert:SetLableString4(str,alignment )
	if nil ~= str and "" ~= str then
		self.content_str4 = str
		--self.rich3_alignment = alignment
		if nil ~= self.node_t_list.rich_dialog3 then
			if nil ~= alignment then
				self.node_t_list.rich_dialog3.node:setHorizontalAlignment(alignment)
			end
			RichTextUtil.ParseRichText(self.node_t_list.rich_dialog3.node, str, 24, COLOR3B.OLIVE)
			--self.node_t_list.rich_dialog2.node:refreshView()
		end
	end
end

function Alert:SetLableString5(str, alignment)
	if nil ~= str and "" ~= str then
		if self.node_t_list.layout_rich then
			self.node_t_list.layout_rich.node:setVisible(true)
		end
		self.content_str5 = str

		local str_data = Split(str, "\n")
		--self.rich3_alignment = alignment
		if nil ~= self.node_t_list.rich_text1 then
			if nil ~= alignment then
				self.node_t_list.rich_text1.node:setHorizontalAlignment(alignment)
			end
			RichTextUtil.ParseRichText(self.node_t_list.rich_text1.node, str_data[1], 24, COLOR3B.OLIVE)
			--self.node_t_list.rich_dialog2.node:refreshView()
		end

		if nil ~= self.node_t_list.rich_text2 then
			if nil ~= alignment then
				self.node_t_list.rich_text2.node:setHorizontalAlignment(alignment)
			end
			RichTextUtil.ParseRichText(self.node_t_list.rich_text2.node, str_data[2] or "", 24, COLOR3B.OLIVE)
			--self.node_t_list.rich_dialog2.node:refreshView()
		end
	end
end


function Alert:SetLableString6(str,alignment)
	if nil ~= str and "" ~= str then
		self.content_str6 = str
		--self.rich3_alignment = alignment
		if nil ~= self.node_t_list.rich_dialog6 then
			if nil ~= alignment then
				self.node_t_list.rich_dialog6.node:setHorizontalAlignment(alignment)
			end
			RichTextUtil.ParseRichText(self.node_t_list.rich_dialog6.node, str, 18, COLOR3B.OLIVE)
			--self.node_t_list.rich_dialog2.node:refreshView()
		end
	end
end

-- 设置确定按钮文字
function Alert:SetOkString(str)
	if nil ~= str and "" ~= str then
		self.ok_btn_text = str

		if nil ~= self.node_t_list.btn_OK then
			self.node_t_list.btn_OK.node:setTitleText(self.ok_btn_text)
		end
	end
end

-- 设置取消按钮文字
function Alert:SetCancelString(str)
	if nil ~= str and "" ~= str then
		self.cancel_btn_text = str

		if nil ~= self.node_t_list.btn_cancel then
			self.node_t_list.btn_cancel.node:setTitleText(self.cancel_btn_text)
		end
	end
end

-- 设置复选框的显示文本
function Alert:SetCheckBoxText(str)
	if nil ~= str and "" ~= str then
		self.checkbox_tip_text = str

		if nil ~= self.node_t_list.label_no_longer then
			self.node_t_list.label_no_longer.node:setString(self.checkbox_tip_text)
		end
	end
end

-- 设置确定回调
function Alert:SetOkFunc(ok_func)
	self.ok_func = ok_func
end

-- 设置取消回调
function Alert:SetCancelFunc(cancel_func)
	self.cancel_func = cancel_func
end

-- 设置关闭回调
function Alert:SetCloseFunc(close_func)
	self.close_func = close_func
end

function Alert:SetData(value)
	self.data = value
end

-- 是否显示复选框
function Alert:SetShowCheckBox(is_show)
	if self.has_checkbox ~= is_show then
		self.has_checkbox = is_show

		if nil ~= self.node_t_list.layout_nolonger_tips then
			self.node_t_list.layout_nolonger_tips.node:setVisible(is_show)
		end
	end
end

function Alert:GetIsNolongerTips()
	return self.is_nolonger_tips
end

function Alert:Open()
	if self.record_not_tip and self.has_checkbox then
		if self.auto_do_func then
			self.ok_func(self.is_nolonger_tips, self.data)
		end
	else
		Alert.super.Open(self)
	end
end

function Alert:SetAutoDoFunc(value)
	self.auto_do_func = value
end

function Alert:Close()
	if self.close_type == -1 then
		self.close_type = 2
	end
	Alert.super.Close(self)
end

--设置让取消按钮消失
function Alert:UseOne()
	self.is_use_one = true
	if nil ~= self.node_t_list and nil ~= self.node_t_list.btn_cancel and nil ~= self.node_t_list.btn_OK then
		self.node_t_list.btn_cancel.node:setVisible(false)
		self.node_t_list.btn_OK.node:setPosition(self.one_pos_x, self.one_pos_y )
	end
end

function Alert:NoCloseButton()
	-- self.is_no_closeBtn = true
	-- if nil ~= self.node_t_list and nil ~= self.node_t_list.btn_close_window then
	-- 	self.node_t_list.btn_close_window.node:setVisible(false)
	-- end
end

function Alert:ClearCheckHook()
	self.record_not_tip = false
end

function Alert:OnCloseHandler()
	if self.close_before_func then
		self.close_before_func()
	else
		self:Close()
	end
end

function Alert:SetCloseBeforeFunc(func)
	self.close_before_func = func
end

function Alert:GetOkBtn()
	return self.node_t_list.btn_OK.node
end

function Alert:SetAutoCloseTime(time)
	if nil ~= time then
		self.auto_close_time = time
		if not self:IsOpen() then
			return
		end
	end

	GlobalTimerQuest:CancelQuest(self.close_timer)
	if self.auto_close_time > 0 then
		self.close_timer = GlobalTimerQuest:AddDelayTimer(function()
			self.close_timer = nil
			self:Close()
		end, self.auto_close_time)
	end
end
