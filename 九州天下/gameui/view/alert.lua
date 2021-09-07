Alert = Alert or BaseClass(BaseView)

function Alert:__init(title, content, ok_func, cancel_func, close_func, has_checkbox)
	self.view_layer = UiLayer.Pop
	self.ui_config = {"uis/views/tips/packuptips", "PackUpTips"}

	self.title_txt = nil
	self.content_txt = nil
	self.ok_btn = nil
	self.cancel_btn = nil

	self.close_func = close_func
	self.ok_func = ok_func
	self.cancel_func = cancel_func
	self.data = nil
	self.content_str = content or ""
	self.title_str = title or Language.AlertTitle.Default
	self.close_type = -1								-- 0 确定关闭， 1 取消关闭， 2 其他地方面板关闭
	self.is_nolonger_tips = true						-- 是否勾选不再提示
end


function Alert:__delete()
end

function Alert:OpenCallBack()
	self:Refresh()
end

function Alert:ReleaseCallBack()
	self.title_txt = nil
	self.content_txt = nil
	self.ok_btn = nil
	self.cancel_btn = nil

	self.close_func = nil
	self.ok_func = nil
	self.cancel_func = nil
	self.data = nil
	self.content_str = nil
	self.title_str = nil
	self.close_type = -1								-- 0 确定关闭， 1 取消关闭， 2 其他地方面板关闭
	self.is_nolonger_tips = true

	self.ok_btn_text = nil
	self.cancel_btn_text = nil
end

function Alert:LoadCallBack()

	self.title_txt = self:FindObj("PackUpTips/Text_Title")
	self.content_txt = self:FindObj("PackUpTips/TipsText")

	local ok_btn = self:FindObj("PackUpTips/YesButton")
	ok_btn.button:AddClickListener(BindTool.Bind(self.OnClickOkBtn, self))
	self.ok_btn_text = self:FindObj("PackUpTips/YesButton/YesText")

	local cancel_btn = self:FindObj("PackUpTips/NoButton")
	cancel_btn.button:AddClickListener(BindTool.Bind(self.OnClickCancelBtn, self))
	self.cancel_btn_text = self:FindObj("PackUpTips/NoButton/NoText")

	self.close_btn = self:FindObj("PackUpTips/CloseButton")
	self.close_btn.button:AddClickListener(BindTool.Bind(self.OnClickCloseBtn, self))

	local bg_btn = self:FindObj("BGButton")
	bg_btn.button:AddClickListener(BindTool.Bind(self.OnClickCloseBtn, self))
end


function Alert:OnClickOkBtn()
	self.close_type = 0
	local can_close = true
	if nil ~= self.ok_func then
		-- self.record_not_tip = self.is_nolonger_tips
		can_close = self.ok_func(self.is_nolonger_tips, self.data)
		if nil == can_close then can_close = true end
	end

	if can_close then
		self:Close()
	end

end

function Alert:OnClickCancelBtn()
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

function Alert:OnClickCloseBtn()
	if self.close_type == -1 then
		self.close_type = 2
	end
	if self.close_func then
		self.close_func()
	end
	self:Close()
end

function Alert:NoCloseButton()
	if self.close_btn then
		 self.close_btn:SetActive(false)
	end
end

-- 设置关闭回调
function Alert:SetCloseFunc(close_func)
	self.close_func = close_func
end

function Alert:SetData(value)
	self.data = value
end

function Alert:Refresh()
	if nil ~= self.content_txt then
		self.content_txt.text.text = self.content_str
	end
	if nil ~= self.title_txt then
		self.title_txt.text.text = self.title_str
	end

	if nil ~= self.ok_btn_text and nil ~= self.ok_btn_str then
		self.ok_btn_text.text.text = self.ok_btn_str
	end

	if nil ~= self.cancel_btn_text and nil ~= self.cancel_btn_str then
		self.cancel_btn_text.text.text = self.cancel_btn_str
	end
end

-- 设置内容
function Alert:SetContent(str)
	if nil ~= str and "" ~= str then
		self.content_str = str
		if nil ~= self.content_txt then
			self.content_txt.text.text = self.content_str
		end
	end
end

-- 设置标题
function Alert:SetTitle(str)
	if nil ~= str and "" ~= str then
		self.title_str = str
		if nil ~= self.title_txt then
			self.title_txt.text.text = self.title_str
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

-- 设置确定按钮文字
function Alert:SetOkString(str)
	if nil ~= str and "" ~= str then
		self.ok_btn_str = str
	end
end

-- 设置取消按钮文字
function Alert:SetCancelString(str)
	if nil ~= str and "" ~= str then
		self.cancel_btn_str = str
	end
end



