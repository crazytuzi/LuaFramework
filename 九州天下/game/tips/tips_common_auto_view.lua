TipsCommonAutoView = TipsCommonAutoView or BaseClass(BaseView)
TipsCommonAutoView.AUTO_VIEW_STR_T = {}
function TipsCommonAutoView:__init()
	self.ui_config = {"uis/views/tips/commontips", "CommonAutoTip"}
	-- self:SetMaskBg(true)
	self.view_layer = UiLayer.Pop
	self.is_auto = false
	self.mask_close = 0
	self.is_not_show = false
	self.can_show_auto = {}
	self.auto_view_str = ""
	self.ok_str = ""
	self.canel_str = ""
	self.play_audio = true
	self.auto_view_str_t = {}
	self.is_special = false
	self.auto_close = false
	self.des_str = ""
	self.toggle_isOn = false
end

function TipsCommonAutoView:LoadCallBack()
	self:ListenEvent("CloseWindow",	BindTool.Bind(self.ClickCancel, self))
	self:ListenEvent("ClickOk",	BindTool.Bind(self.ClickOk, self))
	self:ListenEvent("MaskClose",	BindTool.Bind(self.ClickMaskBg, self))

	self.des = self:FindVariable("des")
	self.show_auto = self:FindVariable("ShowAutoBuy")
	self.show_red_tip = self:FindVariable("ShowTips")
	self.ok_des = self:FindVariable("OkDes")
	self.canel_des = self:FindVariable("CanelDes")
	self.red_text = self:FindVariable("RedText")
	self.check = self:FindObj("Check")

	self.check.toggle:AddValueChangedListener(BindTool.Bind(self.ChangeShow, self))
end

function TipsCommonAutoView:ReleaseCallBack()
	-- 清理变量和对象
	self.des = nil
	self.show_auto = nil
	self.show_red_tip = nil
	self.ok_des = nil
	self.canel_des = nil
	self.red_text = nil
	self.check = nil
	self.toggle_isOn = false
end

function TipsCommonAutoView:OpenCallBack()
	self:Flush()
	self.is_not_show = self.check.toggle.isOn
end

function TipsCommonAutoView:ChangeAuto(isOn)
	self.is_auto = isOn
end

function TipsCommonAutoView:ChangeShow(isOn)
	self.is_not_show = isOn
	self.is_auto = isOn
end

function TipsCommonAutoView:CloseCallBack()	
	self.ok_callback = nil
	self.canel_callback = nil
end

function TipsCommonAutoView:ClickCancel()
	if self.canel_callback then
		self.canel_callback()
	end
	self.is_auto = false
	self:Close()
end

function TipsCommonAutoView:ClickMaskBg()
	if 0 == self.mask_close then
		self:ClickCancel()
	end
end

function TipsCommonAutoView:SetIsUseMaskClick(is_use)
	self.mask_close = is_use
end

function TipsCommonAutoView:SetRedText(the_red_text)
	self.the_red_text = the_red_text or Language.Common.AutoBuyDes
end

--是否展示自动购买
function TipsCommonAutoView:SetShowAutoBuy(value)
	if self.auto_view_str ~= "" then
		self.can_show_auto[self.auto_view_str] = value
	end
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
	if self.des_str ~= "" and self.des_str ~= des then
		self.auto_close = false
	end
	self.des_str = des
end

function TipsCommonAutoView:SetOkCallBack(callback)
	self.ok_callback = callback
end

function TipsCommonAutoView:SetCanelCallBack(callback)
	self.canel_callback = callback
end

function TipsCommonAutoView:SetBtnDes(ok_des, canel_des)
	self.ok_str = ok_des or "确定"
	self.canel_str = canel_des or "取消"
end

function  TipsCommonAutoView:GetAutoClose()	
	return self.auto_close
end

function TipsCommonAutoView:ClickOk()
	if self.ok_callback then
		if self.is_special and self.is_auto then
			TipsCommonAutoView.AUTO_VIEW_STR_T[self.auto_view_str] = {is_auto_buy = true}
		end
		self.ok_callback(self.is_auto)
		if self.is_not_show then
			self.auto_close = true
		else
			self.auto_close = false
		end
	end
	self:Close()
end

function TipsCommonAutoView:OnFlush()
	self.check.toggle.isOn = self.can_show_auto[self.auto_view_str] or self.toggle_isOn
	self.is_auto = self.check.toggle.isOn
	local show_flag = false
	if self.can_show_auto[self.auto_view_str] ~= nil then
		show_flag = self.can_show_auto[self.auto_view_str]
	end
	
	self.show_auto:SetValue(show_flag)
	self.des:SetValue(self.des_str)
	self.show_red_tip:SetValue(self.is_show_red_tip)
	self.ok_des:SetValue(self.ok_str)
	self.canel_des:SetValue(self.canel_str)
	self.red_text:SetValue(self.the_red_text)
end

function TipsCommonAutoView:HodeAutoBuy(str, value)
	TipsCommonAutoView.AUTO_VIEW_STR_T[str] = {is_auto_buy = value}
end

function TipsCommonAutoView:SetToggleIsOn(value)
	self.toggle_isOn = value
end