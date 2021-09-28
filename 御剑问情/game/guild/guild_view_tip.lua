GuildViewTips = GuildViewTips or BaseClass(BaseView)
GuildViewTips.AUTO_VIEW_STR_T = {}
function GuildViewTips:__init()
	self.ui_config = {"uis/views/guildview_prefab", "GuildViewTip"}
	self.view_layer = UiLayer.Pop
	self.is_auto = true
	self.can_show_auto = false
	self.auto_view_str = ""
	self.ok_str = ""
	self.canel_str = ""
	self.play_audio = true
	self.auto_view_str_t = {}
	self.is_special = false
	self.toggle_isOn = true
	self.is_show_box_pay_text = false
	self.box_pay_text = ""
end

function GuildViewTips:LoadCallBack()
	self:ListenEvent("CloseWindow",
		BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("ClickOk",
		BindTool.Bind(self.ClickOk, self))
	self:ListenEvent("ClickCanel",
		BindTool.Bind(self.ClickCanel, self))

	self.des = self:FindVariable("des")
	self.show_auto = self:FindVariable("ShowAutoBuy")
	self.show_red_tip = self:FindVariable("ShowTips")
	self.ok_des = self:FindVariable("OkDes")
	self.canel_des = self:FindVariable("CanelDes")
	self.red_text = self:FindVariable("RedText")
	self.uplevelpay_text = self:FindVariable("uplevelpay_text")
	self.show_pay_text = self:FindVariable("show_pay_text")
	self.check = self:FindObj("Check")

	self.check.toggle:AddValueChangedListener(BindTool.Bind(self.ChangeAuto, self))
end

function GuildViewTips:ReleaseCallBack()
	-- 清理变量和对象
	self.des = nil
	self.show_auto = nil
	self.show_red_tip = nil
	self.ok_des = nil
	self.canel_des = nil
	self.red_text = nil
	self.check = nil
end

function GuildViewTips:OpenCallBack()
	self:Flush()
end

function GuildViewTips:ChangeAuto(isOn)
	self.is_auto = isOn
end

function GuildViewTips:CloseCallBack()
	self.ok_callback = nil
	self.canel_callback = nil
	self.is_show_box_pay_text = false
end

function GuildViewTips:SetRedText(the_red_text)
	self.the_red_text = the_red_text or Language.Common.AutoBuyDes
end

function GuildViewTips:CloseWindow()
	self.is_auto = false
	
	self:Close()
end

--是否展示自动购买
function GuildViewTips:SetShowAutoBuy(value)
	self.can_show_auto = value
end

--是否展示红字提示
function GuildViewTips:SetShowRedTip(value)
	self.is_show_red_tip = value
end

function GuildViewTips:SetAutoStr(str)
	self.auto_view_str = str
end

function GuildViewTips:SetIsSpecial(is_special)
	self.is_special = is_special
end

function GuildViewTips:SetDes(des)
	self.des_str = des
end

function GuildViewTips:SetOkCallBack(callback)
	self.ok_callback = callback
end

function GuildViewTips:SetToggleIsOn(value)
	self.toggle_isOn = value
end

function GuildViewTips:SetCanelCallBack(callback)
	self.canel_callback = callback
end

function GuildViewTips:SetBtnDes(ok_des, canel_des)
	self.ok_str = ok_des or "确定"
	self.canel_str = canel_des or "取消"
end

function GuildViewTips:SetUplevelPayText(text)
	self.box_pay_text = text
end

function GuildViewTips:SetIsShowPayText(is_show)
	self.is_show_box_pay_text = is_show
end

function GuildViewTips:ClickOk()
	if self.ok_callback then
		if self.is_special and self.is_auto then
			GuildViewTips.AUTO_VIEW_STR_T[self.auto_view_str] = {is_auto_buy = true}
		end
		self.ok_callback(self.is_auto)
	end
	self:Close()
end

function GuildViewTips:ClickCanel()
	if self.canel_callback then
		self.canel_callback()
	end
	
	self:Close()
end

function GuildViewTips:OnFlush()
	self.check.toggle.isOn = self.toggle_isOn
	self.is_auto = self.toggle_isOn
	self.show_auto:SetValue(self.can_show_auto)
	self.des:SetValue(self.des_str)
	self.show_red_tip:SetValue(self.is_show_red_tip)
	self.ok_des:SetValue(self.ok_str)
	self.canel_des:SetValue(self.canel_str)
	self.red_text:SetValue(self.the_red_text)
	self.show_pay_text:SetValue(self.is_show_box_pay_text)
	self.uplevelpay_text:SetValue(self.box_pay_text)
end