-- 数字键盘
-- max_value不为空时，max_length无效

NumKeypad = NumKeypad or BaseClass(XuiBaseView)
NumKeypad.MaxVaule = 99999999999999

function NumKeypad:__init(max_length, max_value)
	self.is_any_click_close = true
	self.is_modal = true
	self.config_tab = {
		{"itemtip_ui_cfg", 6, {0},}
	}

	self.ok_callback = nil							-- 确定回调
	self.max_value = 9999999999						-- 可输入的最大值
	self.input_num = 0								-- 输入的数字

	if nil ~= max_length then
		local temp_max = math.pow(10, max_length)
		if nil == max_value or max_value > temp_max then
			max_value = temp_max
		end
	end
	if nil ~= max_value then
		self:SetMaxValue(max_value)
	end
	self.zorder = 100
end

function NumKeypad:__delete()
	
end

-- 设置确定按钮回调事件
function NumKeypad:SetOkCallBack(func)
	if "function" == type(func) then
		self.ok_callback = func
	else
		ErrorLog("[NumKeypad] set ok callback is not func")
	end
end

-- 设置输入最大值
function NumKeypad:SetMaxValue(max_value)
	if nil ~= max_value and max_value >= 0 then
		self.max_value = max_value > 99999999999 and 99999999999 or max_value
	end
end

function NumKeypad:LoadCallBack()	
	self:RegisterAllEvents()
end

function NumKeypad:RegisterAllEvents()
	for i = 0, 9 do
		XUI.AddClickEventListener(self.node_t_list["layout_num_" .. i].node, BindTool.Bind2(self.OnClickBtn, self, i), true)
		self.node_t_list["layout_num_" .. i].node:setTouchEnabled(true)
		-- self.node_t_list["layout_num_" .. i].node:setTitleColor(COLOR3B.WHITE)
	end
	XUI.AddClickEventListener(self.node_t_list.btn_num_del.node, BindTool.Bind1(self.OnClickDel, self))
	XUI.AddClickEventListener(self.node_t_list.btn_num_ok.node, BindTool.Bind1(self.OnClickOK, self))
end

function NumKeypad:OpenCallBack()
	self:SetNum(0)
end

function NumKeypad:ShowIndexCallBack()
	
end

function NumKeypad:OnFlush()
	 self.node_t_list.lbl_pop_num.node:setString(tostring(self.input_num))
end

function NumKeypad:OnClickBtn(num)
	self.input_num = self.input_num * 10 + num
	if self.input_num > self.max_value then
		self.input_num = self.max_value
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Common.MaxValue)
	end
	self:SetNum(self.input_num)
end

function NumKeypad:OnClickDel()
	self:SetNum(math.floor(self.input_num / 10))
end

-- 点击确定按钮
function NumKeypad:OnClickOK()
	if nil ~= self.ok_callback then
		self.ok_callback(self:GetNum())
	end

	self:Close()
end

function NumKeypad:GetText()
	return tostring(self:GetNum())
end

function NumKeypad:SetText(text)
	self:SetNum(tonumber(text))
end

function NumKeypad:GetNum()
	return self.input_num > 0 and self.input_num or 1
end

function NumKeypad:SetNum(num)
	if num <= 0 then
		num = 0
	end
	self.input_num = num
	self:Flush()
end
