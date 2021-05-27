------------------------------------------------
--充值对话框的fla在dialog.fla文件里面
------------------------------------------------
AlertRecharge = AlertRecharge or BaseClass(XuiBaseView)

function AlertRecharge:__init(str, ok_func, cancel_func, close_func, is_show_action, is_str2, is_double)
	self.zorder = COMMON_CONSTS.PANEL_MAX_ZORDER

	self.config_tab = {
		{"dialog_ui_cfg", 1, {0},},
	}
	self.is_any_click_close = true
	self.is_modal = true
	self.content_str = nil ~= str and str or ""
	self.ok_func = ok_func
	self.cancel_func = cancel_func
	self.close_func = close_func

	self.ok_btn_text = Language.Common.Confirm
	self.cancel_btn_text = Language.Common.Cancel
	self.data = nil

	self.one_pos_x = 244
	self.one_pos_y = 62.5
	self.pos_x, self.pos_y = 150, 62.5

	self.close_type = -1 --0 确定关闭， 1 取消关闭， 2 其他地方面板关闭

	self.is_use_one = false
	self.is_no_closeBtn = false

	if nil ~= is_str2 and is_str2 then
		self.content_str2 = nil ~= is_str2 and is_str2 or ""
	end

	if nil ~= is_double and "" ~= is_double and is_double then
		self.content_str3 = nil ~= is_double and is_double or ""
	end

end

function AlertRecharge:__delete()

end

function AlertRecharge:OpenCallBack()
	
end

function Alert:ShowIndexCallBack()
	self.node_t_list.btn_OK.node:setPosition(self.pos_x, self.pos_y)
	self.node_t_list.btn_cancel.node:setVisible(true)
	-- self.node_t_list.btn_close_window.node:setVisible(true)

	if self.is_use_one then
		self:UseOne()
	end
	if self.is_no_closeBtn then
		self:NoCloseButton()
	end
end

function AlertRecharge:LoadCallBack()
	self.is_modal = true
	self.rich_dialog = self.node_t_list.rich_dialog.node

	self.rich_dialog_param = {}
	self.rich_dialog_param.x, self.rich_dialog_param.y = self.node_t_list.rich_dialog.node:getPosition()
	local size = self.node_t_list.rich_dialog.node:getContentSize()
	self.rich_dialog_param.w, self.rich_dialog_param.h = size.width, size.height

	self.rich_dialog2 = self.node_t_list.rich_dialog2.node

	self.rich_double = self.node_t_list.rich_double.node

	self:SetLableString(self.content_str)

	self:SetLableString2(self.content_str2)

	self:SetLableString3(self.content_str3)

	self.node_t_list.btn_OK.node:setTitleText(self.ok_btn_text)
	self.node_t_list.btn_cancel.node:setTitleText(self.cancel_btn_text)

	self.node_t_list.btn_OK.node:addClickEventListener(BindTool.Bind1(self.OnClickOK, self))
	self.node_t_list.btn_cancel.node:addClickEventListener(BindTool.Bind1(self.OnClickCancel, self))
end

function AlertRecharge:OnClickOK()
	self.close_type = 0
	local can_close = true
	if nil ~= self.ok_func then
		can_close = self.ok_func(self.data)
		if nil == can_close then can_close = true end
	end

	if can_close then
		self:Close()
	end

end

function AlertRecharge:OnClickCancel()
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

function AlertRecharge:CloseCallBack()
	if self.close_type == 2 then
		if nil ~= self.close_func then
			self.close_func()
		end
	end

	self.close_type = -1
end

-- 设置内容
function AlertRecharge:SetLableString(str)
	if nil ~= str and "" ~= str then
		self.content_str = str

		if nil ~= self.rich_dialog then

			HtmlTextUtil.SetString(self.rich_dialog, HtmlTool.GetHtml(self.content_str, COLOR3B.WHITE , 26))
			self.rich_dialog:refreshView()

			local text_renderer_size = self.rich_dialog:getInnerContainerSize()
			local text_x = self.rich_dialog_param.x + (self.rich_dialog_param.w - text_renderer_size.width) / 2
			local text_y = self.rich_dialog_param.y  - (self.rich_dialog_param.h - text_renderer_size.height) / 2
			self.rich_dialog:setPosition(text_x, text_y)
		end
	end
end

function AlertRecharge:ReleaseCallBack()
	if self.rich_dialog then
		self.rich_dialog = nil
	end
	if self.rich_dialog2 then
		self.rich_dialog2 = nil
	end
	if self.rich_double then
		self.rich_double = nil
	end
end

-- 设置内容2
function AlertRecharge:SetLableString2(str)
	if nil ~= str and "" ~= str then
		self.content_str2 = str

		if nil ~= self.rich_dialog2 then
			HtmlTextUtil.SetString(self.rich_dialog2, HtmlTool.GetHtml(self.content_str2, COLOR3B.WHITE , 26))
			self.rich_dialog2:refreshView()
		end
	end
end

-- 设置内容3
function AlertRecharge:SetLableString3(str)
	if nil ~= str and "" ~= str then
		self.content_str3 = str

		if nil ~= self.rich_double then

			HtmlTextUtil.SetString(self.rich_double, HtmlTool.GetHtml(self.content_str3, COLOR3B.WHITE, 22))
			self.rich_double:refreshView()
			self.rich_double:setIgnoreSize(true)
		end
	else
		if nil ~= self.rich_double then
			HtmlTextUtil.SetString(self.rich_double, HtmlTool.GetHtml("", COLOR3B.WHITE, 22))
		end
	end
end

-- 设置确定按钮文字
function AlertRecharge:SetOkString(str)
	if nil ~= str and "" ~= str then
		self.ok_btn_text = str

		if nil ~= self.node_t_list.btn_OK.node then
			self.node_t_list.btn_OK.node:setTitleText(self.ok_btn_text)
		end
	end
end

-- 设置取消按钮文字
function AlertRecharge:SetCancelString(str)
	if nil ~= str and "" ~= str then
		self.cancel_btn_text = str

		if nil ~= self.node_t_list.btn_cancel.node then
			self.node_t_list.btn_cancel.node:setTitleText(self.cancel_btn_text)
		end
	end
end

-- 设置确定回调
function AlertRecharge:SetOkFunc(ok_func)
	self.ok_func = ok_func
end

-- 设置取消回调
function AlertRecharge:SetCancelFunc(cancel_func)
	self.cancel_func = cancel_func
end

-- 设置关闭回调
function AlertRecharge:SetCloseFunc(close_func)
	self.close_func = close_func
end

function AlertRecharge:SetData(value)
	self.data = value
end

function AlertRecharge:Open()
	XuiBaseView.Open(self)
end

function AlertRecharge:Close()
	if self.close_type == -1 then
		self.close_type = 2
	end
	XuiBaseView.Close(self)
end

--设置让取消按钮消失
function AlertRecharge:UseOne()
	self.is_use_one = true
	if nil ~= self.node_t_list and nil ~= self.node_t_list.btn_cancel.node and nil ~= self.node_t_list.btn_OK.node then
		self.node_t_list.btn_cancel.node:setVisible(false)
		self.node_t_list.btn_OK.node:setPosition(self.one_pos_x, self.one_pos_y )
	end
end

function AlertRecharge:NoCloseButton()
	-- self.is_no_closeBtn = true
	-- if nil ~= self.node_t_list and nil ~= self.node_t_list.btn_close_window.node then
	-- 	self.node_t_list.btn_close_window.node:setVisible(false)
	-- end
end
