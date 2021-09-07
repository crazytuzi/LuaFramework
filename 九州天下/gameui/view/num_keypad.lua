NumKeypad = NumKeypad or BaseClass(BaseView)

function NumKeypad:__init()
	self.ui_config = {"uis/views/tips/computertips", "ComputerTips"}
	self.ok_callback = nil							-- 确定回调
	self.max_value = 999							-- 可输入的最大值
	self.input_num = 0								-- 输入的数字

end

function NumKeypad:__delete()

end

-----------------------------------
-- 回调逻辑
-----------------------------------
-- 创建完调用
function NumKeypad:LoadCallBack()
	local bg = self:FindObj("BGButton")
	bg.button:AddClickListener(BindTool.Bind(self.HandleClickClose, self))
	local close_btn = self:FindObj("ComputerTips/CloseBtn")
	close_btn.button:AddClickListener(BindTool.Bind(self.HandleClickClose, self))

	self.input_num_txt = self:FindObj("ComputerTips/ManyBG/Many")

	self.key0 = self:FindObj("ComputerTips/BtnObj/Btn8")
	self.key1 = self:FindObj("ComputerTips/BtnObj/Btn1")
	self.key2 = self:FindObj("ComputerTips/BtnObj/Btn2")
	self.key3 = self:FindObj("ComputerTips/BtnObj/Btn3")
	self.key4 = self:FindObj("ComputerTips/BtnObj/Btn5")
	self.key5 = self:FindObj("ComputerTips/BtnObj/Btn6")
	self.key6 = self:FindObj("ComputerTips/BtnObj/Btn7")
	self.key7 = self:FindObj("ComputerTips/BtnObj/Btn9")
	self.key8 = self:FindObj("ComputerTips/BtnObj/Btn10")
	self.key9 = self:FindObj("ComputerTips/BtnObj/Btn11")
	self.del_btn = self:FindObj("ComputerTips/BtnObj/Btn4")
	self.ok_btn = self:FindObj("ComputerTips/BtnObj/Btn12")

	for i = 0, 9 do
		self["key" .. i].button:AddClickListener(BindTool.Bind(self.HandleClickNum, self, i))
	end
	self.del_btn.button:AddClickListener(BindTool.Bind(self.HandleClickDel, self))
	self.ok_btn.button:AddClickListener(BindTool.Bind(self.HandleClickOK, self))
end

-- 打开后调用
function NumKeypad:OpenCallBack()
    self:SetNum(self.input_num)
end

-- 切换标签调用
function NumKeypad:ShowIndexCallBack(index)
    -- override
end

-- 关闭前调用
function NumKeypad:CloseCallBack()
    -- override
end

-- 销毁前调用
function NumKeypad:ReleaseCallBack()
    -- override
end

-- 刷新
function NumKeypad:OnFlush(param_list)
	self.input_num_txt.text.text = self.input_num
end

-----------------------------------
-- 功能逻辑
-----------------------------------
function NumKeypad:SetNum(num)
	if num <= 0 then
		num = 0
	end
	self.input_num = num
	self:Flush()
end

function NumKeypad:GetNum()
	return self.input_num
end

-- 设置输入最大值
function NumKeypad:SetMaxValue(max_value)
	if nil ~= max_value and max_value >= 0 then
		self.max_value = max_value > 99999999999 and 99999999999 or max_value
	end
end

-- 设置确定按钮回调事件
function NumKeypad:SetOkCallBack(func)
	if "function" == type(func) then
		self.ok_callback = func
	else
		print_error("[NumKeypad] set ok callback is not func")
	end
end

function NumKeypad:GetText()
	return tostring(self:GetNum())
end

function NumKeypad:SetText(text)
	self:SetNum(tonumber(text))
end

-----------------------------------
-- 事件逻辑
-----------------------------------
function NumKeypad:HandleClickClose()
	self:Close()
end

function NumKeypad:HandleClickOK()
	if nil ~= self.ok_callback then
		self.ok_callback(self:GetNum())
	end
	self:Close()
end

function NumKeypad:HandleClickDel()
	self:SetNum(math.floor(self.input_num / 10))
end

function NumKeypad:HandleClickNum(num)
	self.input_num = self.input_num * 10 + num
	if self.input_num > self.max_value then
		self.input_num = self.max_value
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.MaxValue)
	end
	self:SetNum(self.input_num)
end


