TipsCommonAutoView = TipsCommonAutoView or BaseClass(BaseView)
TipsCommonAutoView.AUTO_VIEW_STR_T = {}
function TipsCommonAutoView:__init()
	self.ui_config = {"uis/views/tips/commontips_prefab", "CommonAutoTip"}
	self.view_layer = UiLayer.Pop
	self.is_auto = true
	self.can_show_auto = true
	self.auto_view_str = ""
	self.ok_str = ""
	self.canel_str = ""
	self.play_audio = true
	self.auto_view_str_t = {}
	self.is_special = false
	self.toggle_isOn = true
	self.index = 0
end

function TipsCommonAutoView:LoadCallBack()
	self:ListenEvent("CloseWindow",
		BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("ClickOk",
		BindTool.Bind(self.ClickOk, self))
	self:ListenEvent("ClickCanel",
		BindTool.Bind(self.ClickCanel, self))
	self:ListenEvent("ClickBlack",
		BindTool.Bind(self.ClickBlack, self))

	self.show_auto = self:FindVariable("ShowAutoBuy")
	self.show_red_tip = self:FindVariable("ShowTips")
	self.ok_des = self:FindVariable("OkDes")
	self.canel_des = self:FindVariable("CanelDes")
	self.red_text = self:FindVariable("RedText")
	self.check = self:FindObj("Check")
	self.content = self:FindObj("Content")
	self.bg_button = self:FindObj("BGButton")

	self.check.toggle:AddValueChangedListener(BindTool.Bind(self.ChangeAuto, self))
end

function TipsCommonAutoView:ReleaseCallBack()
	-- 清理变量和对象
	self.show_auto = nil
	self.show_red_tip = nil
	self.ok_des = nil
	self.canel_des = nil
	self.red_text = nil
	self.check = nil
	self.content = nil
	self.bg_button = nil
end

function TipsCommonAutoView:OpenCallBack()
	self:Flush()
end

function TipsCommonAutoView:ChangeAuto(isOn)
	self.is_auto = isOn
end

function TipsCommonAutoView:CloseCallBack()
	self.ok_callback = nil
	self.canel_callback = nil
	self.black_close = nil
end

function TipsCommonAutoView:SetRedText(the_red_text)
	self.the_red_text = the_red_text or Language.Common.AutoBuyDes
end

function TipsCommonAutoView:CloseWindow()
	self.is_auto = false
	self:Close()
end

function TipsCommonAutoView:ClickBlack()
	if self.black_close then
		self.is_auto = false
		self:Close()
	end
end

--是否展示自动购买
function TipsCommonAutoView:SetShowAutoBuy(value)
	self.can_show_auto = value
end

--是否展示红字提示
function TipsCommonAutoView:SetShowRedTip(value)
	self.is_show_red_tip = value
end

function TipsCommonAutoView:SetAutoStr(str)
	self.auto_view_str = str
end

function TipsCommonAutoView:SetIsSpecial(is_special)
	self.is_special = is_special
end

function TipsCommonAutoView:SetDes(des)
	self.des_str = des
end

function TipsCommonAutoView:SetOkCallBack(callback)
	self.ok_callback = callback
end

function TipsCommonAutoView:SetToggleIsOn(value)
	self.toggle_isOn = value
end

function TipsCommonAutoView:SetCanelCallBack(callback)
	self.canel_callback = callback
end

function TipsCommonAutoView:SetBtnDes(ok_des, canel_des)
	self.ok_str = ok_des or "确定"
	self.canel_str = canel_des or "取消"
end

function TipsCommonAutoView:SetIndex(index)
	self.index = index
end

function TipsCommonAutoView:SetBlackTagget(black_close)
	if black_close == nil or black_close == 0 then
		self.black_close = true
		return
	end
	if black_close == 1 then
		self.black_close = false
	end
end

function TipsCommonAutoView:ClickOk()
	if self.ok_callback then
		if self.is_special and self.is_auto then
			TipsCommonAutoView.AUTO_VIEW_STR_T[self.auto_view_str] = {is_auto_buy = true}
		end
		self.ok_callback(self.is_auto)
	end
	self:Close()
end

function TipsCommonAutoView:ClickCanel()
	self.is_auto = false
	if self.canel_callback then
		self.canel_callback()
	end
	self:Close()
end



function TipsCommonAutoView:OnFlush()
	self.check.toggle.isOn = self.toggle_isOn
	self.is_auto = self.toggle_isOn
	self.show_auto:SetValue(self.can_show_auto)
	-- self.des:SetValue(self.des_str)
	self.content.text.text = self.des_str
	self.show_red_tip:SetValue(self.is_show_red_tip)
	self.ok_des:SetValue(self.ok_str)
	self.canel_des:SetValue(self.canel_str)
	self.red_text:SetValue(self.the_red_text)
end