ConfirmNum = BaseClass(LuaUI)
local confirm = nil
function ConfirmNum:__init()
	if not resMgr:AddUIAB("MainTip") then return nil end
	local ui = UIPackage.CreateObject("MainTip", "MW_ConfirmNum")
	self.ui = ui
	self.content = ui:GetChild("content")
	self.btnEnter = ui:GetChild("btnEnter")
	self.btnExit = ui:GetChild("btnExit")
	self.btnClose = ui:GetChild("btnClose")
	self.slider = ui:GetChild("slider")

	self.btnConfirmText = self.btnEnter:GetChild("title")
	self.btnCancelText = self.btnExit:GetChild("title")

	self.btnClose.onClick:Add(function ()
		if self.fun2 then self.fun2() end
		UIMgr.HidePopup(self.ui)
	end)
	self.btnExit.onClick:Add(function ()
		if self.fun2 then self.fun2() end
		UIMgr.HidePopup(self.ui)
	end)
	self.btnEnter.onClick:Add(function ()
		if self.fun1 then self.fun1(self.slider.value) end
		UIMgr.HidePopup(self.ui)
	end)
end
function ConfirmNum:SetInfo(content, title, l1, l2, f1, f2, max, value)
	self.ui.title = title or "提示"
	self.content.text = content
	self.btnConfirmText.text = l1 or "是"
	self.btnCancelText.text = l2 or "否"
	self.fun1 = f1
	self.fun2 = f2
	max = max or 0
	self.slider.max = max or 0
	self.slider.value = value or max
end

function ConfirmNum.Show(content, title, l1, l2, f1, f2, max, value)
	if confirm == nil then confirm = ConfirmNum.New() end
	confirm:SetInfo(content, title, l1, l2, f1, f2, max, value)
	UIMgr.ShowCenterPopup(confirm,function ()
		confirm=nil
	end, true)
end

function ConfirmNum:__delete()
	
end