TipsCommonInputView = TipsCommonInputView or BaseClass(BaseView)

function TipsCommonInputView:__init()
	self.ui_config = {"uis/views/tips/commontips_prefab", "InputNumTip"}
	self.view_layer = UiLayer.Pop
	self.ok_callback = nil
	self.cancel_callback = nil

	self.max_num = 999
	self.play_audio = true
end

function TipsCommonInputView:LoadCallBack()
	self:ListenEvent("OnClickYes",
		BindTool.Bind(self.OnClickYes, self))
	self:ListenEvent("OnClickClose",
		BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickClean",
		BindTool.Bind(self.OnClickClean, self))
	self:ListenEvent("OnClickZero",
		BindTool.Bind(self.OnClickNum, self, 0))
	self:ListenEvent("OnClickOne",
		BindTool.Bind(self.OnClickNum, self, 1))
	self:ListenEvent("OnClickTwo",
		BindTool.Bind(self.OnClickNum, self, 2))
	self:ListenEvent("OnClickThree",
		BindTool.Bind(self.OnClickNum, self, 3))
	self:ListenEvent("OnClickFour",
		BindTool.Bind(self.OnClickNum, self, 4))
	self:ListenEvent("OnClickFive",
		BindTool.Bind(self.OnClickNum, self, 5))
	self:ListenEvent("OnClickSix",
		BindTool.Bind(self.OnClickNum, self, 6))
	self:ListenEvent("OnClickSeven",
		BindTool.Bind(self.OnClickNum, self, 7))
	self:ListenEvent("OnClickEight",
		BindTool.Bind(self.OnClickNum, self, 8))
	self:ListenEvent("OnClickNight",
		BindTool.Bind(self.OnClickNum, self, 9))

	self.input_flied = self:FindObj("InputField")
end

function TipsCommonInputView:ReleaseCallBack()
	-- 清理变量和对象
	self.input_flied = nil
end

function TipsCommonInputView:__delete()
	self.cur_str = nil
end

function TipsCommonInputView:CloseCallBack()
	self.max_num = 999
	self.max_len = nil
	self.cur_str = ""
	self.ok_callback = nil
	self.cancel_callback = nil
end

function TipsCommonInputView:SetCallback(ok_callback, cancel_callback)
	self.ok_callback = ok_callback
	self.cancel_callback = cancel_callback
end

function TipsCommonInputView:OnClickYes()
	if self.ok_callback ~= nil then
		if self.cur_str == "" then
			self.cur_str = 0
		end
		self.ok_callback(self.cur_str)
	end
	if self.cancel_callback ~= nil then
		self.cancel_callback()
	end
	self:Close()
end

function TipsCommonInputView:OnClickClose()
	if self.cancel_callback ~= nil then
		self.cancel_callback()
	end
	self:Close()
end

function TipsCommonInputView:OnClickClean()
	if self.cur_str == "" or self.cur_str == nil or self.cur_str == 0 then
		self.cur_str = 0
		return
	end
	local str = string.sub(self.cur_str, 1, -2)
	self.input_flied.input_field.text = str
	self.cur_str = str
end

function TipsCommonInputView:SetText(str, max_num)
	if str and str ~= "" then
		self.cur_str = tostring(str)
	elseif str == "" and max_num then
		self.cur_str = tostring(max_num)
	else
		self.cur_str = ""
	end

	self.max_num = max_num or self.max_num

	self:Open()
	self:Flush()
end

function TipsCommonInputView:SetMaxLen(max_len)
	self.max_len = max_len
end

function TipsCommonInputView:OnClickNum(index)
	local str = self.input_flied.input_field.text
	if tonumber(str) == 0 and index == 0 then
		self.input_flied.input_field.text = 0
		self.cur_str = 0
		return
	end

	if string.len(str) == 1 then
		local s = string.sub(str, 1, -1)
		if tonumber(s) == 0 then
			str = string.sub(str, -1, 0)
		end
	end

	str = str .. index
	if self.max_len then
		if string.len(str) > self.max_len then
			str = string.sub(str, 1, self.max_len)
		end
	end

	if tonumber(str) >= self.max_num and not self.max_len then
		self.input_flied.input_field.text = tostring(self.max_num)
		self.cur_str = tostring(self.max_num)
		return
	end

	self.input_flied.input_field.text = str
	self.cur_str = str
end

function TipsCommonInputView:OnFlush(param_t)
	self.input_flied.input_field.text = self.cur_str
	self.init_str = self.input_flied.input_field.text
end
