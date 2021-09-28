-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_perfect_userdata = i3k_class("wnd_perfect_userdata", ui.wnd_base)

function wnd_perfect_userdata:ctor()
	self._initData = {}
end

function wnd_perfect_userdata:configure()
	local widgets = self._layout.vars
	self._inputBox = {
		qq = widgets.qqBox,
		phone = widgets.phoneBox,
	}
	widgets.giveupBtn:onClick(self, self.onGiveup)
	
	self._selectBtn = {
		[1] = {btn = widgets.yesBtn, img = widgets.yesImg},
		[2] = {btn = widgets.noBtn, img = widgets.noImg}
	}
	
	for i,v in ipairs(self._selectBtn) do
		v.btn:setTag(i)
		v.btn:onClick(self, self.onSelectOldUser)
	end
end

function wnd_perfect_userdata:onShow()
	
end

function wnd_perfect_userdata:refresh(qq, phone, isOld, reward)
	self._initData = {qq = qq, phone = phone, isOld = isOld}
	self._isOld = isOld
	self:setQQText(qq)
	self:setPhoneText(phone)
	self:setIsOldData(isOld)
	self._layout.vars.confirmBtn:onClick(self, self.onConfirm, reward)
end

function wnd_perfect_userdata:setQQText(text)
	if text=="" then
		self._inputBox.qq:setPlaceHolder(string.format("点击输入"))
	else
		self._inputBox.qq:setText(text)
	end
end

function wnd_perfect_userdata:setPhoneText(text)
	if text=="" then
		self._inputBox.phone:setPlaceHolder(string.format("点击输入"))
	else
		self._inputBox.phone:setText(text)
	end
end

function wnd_perfect_userdata:setIsOldData(isOld)
	for i,v in ipairs(self._selectBtn) do
		v.img:setVisible(isOld == i)
		v.btn:setTouchEnabled(isOld ~= i)
	end
end

function wnd_perfect_userdata:onSelectOldUser(sender)
	self._isOld = sender:getTag()
	self:setIsOldData(sender:getTag())
end

function wnd_perfect_userdata:onConfirm(sender, reward)
	local qqText = self._inputBox.qq:getText()
	local phoneText = self._inputBox.phone:getText()
	if qqText=="" or phoneText=="" or self._isOld==0 then
		g_i3k_ui_mgr:PopupTipMessage(string.format("请填写所有资料"))
		return
	end
	
	if string.len(qqText)<5 or string.len(qqText)>11 or not tonumber(qqText) then
		g_i3k_ui_mgr:PopupTipMessage(string.format("QQ号格式错误"))
		return
	end
	
	if string.len(phoneText)~=11 or not tonumber(phoneText) then
		g_i3k_ui_mgr:PopupTipMessage(string.format("手机号格式错误"))
		return
	end
	
	
	local callback = function ()
		if g_i3k_ui_mgr:GetUI(eUIID_PerfectUserdata) then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "setMaterialRightData", qqText, phoneText, self._isOld, reward)
			local desc = reward==1 and string.format("修改资料成功") or string.format("完善资料成功")
			g_i3k_ui_mgr:PopupTipMessage(desc)
			g_i3k_ui_mgr:CloseUI(eUIID_PerfectUserdata)
		end
	end
	i3k_sbean.reset_userdata(qqText, phoneText, self._isOld, callback)
end

function wnd_perfect_userdata:onGiveup(sender)
	local qq = self._inputBox.qq:getText()
	local phoneText = self._inputBox.phone:getText()
	if qq~=self._initData.qq or phoneText~=self._initData.phone or self._isOld~=self._initData.isOld then
		local desc = string.format("内容已经被修改，继续放弃将丢弃本次修改，是否放弃？")
		local callback = function (isOk)
			if isOk then
				g_i3k_ui_mgr:CloseUI(eUIID_PerfectUserdata)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
	else
		g_i3k_ui_mgr:CloseUI(eUIID_PerfectUserdata)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_perfect_userdata.new()
	wnd:create(layout, ...)
	return wnd;
end
