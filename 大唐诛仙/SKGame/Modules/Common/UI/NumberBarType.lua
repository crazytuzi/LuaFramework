-- 数字键盘
-- 一般是在点击输入文本控件时，需要弹出数字键盘时使用， 从而输入文本内容
NumberBarType = BaseClass(LuaUI)
function NumberBarType:__init(...)
	self:RegistUI()
	self:InitEvent()
end
function NumberBarType:SetProperty(...)
	
end
function NumberBarType:InitEvent()
	for i=0,11 do
		if i < 11 then
			self["t"..i].onClick:Add(function ()
				if self.callback then
					self.callback(i)
				end
			end)
		else
			self["t"..i].onClick:Add(function ()
				UIMgr.HidePopup(self.ui)
			end)
		end
	end
end
-- 设置回调输入结果
function NumberBarType:SetTypeCallback( callback )
	self.callback = callback
end
function NumberBarType:RegistUI()
	self.ui = UIPackage.CreateObject("Common","NumberBar2")
	self.t7 = self.ui:GetChild("t7")
	self.t8 = self.ui:GetChild("t8")
	self.t6 = self.ui:GetChild("t6")
	self.t5 = self.ui:GetChild("t5")
	self.t4 = self.ui:GetChild("t4")
	self.t9 = self.ui:GetChild("t9")
	self.t2 = self.ui:GetChild("t2")
	self.t1 = self.ui:GetChild("t1")
	self.t3 = self.ui:GetChild("t3")
	self.t0 = self.ui:GetChild("t0")
	self.t10 = self.ui:GetChild("tDel")
	self.t11 = self.ui:GetChild("tDo")
end

function NumberBarType.Create(ui, ...)
	return NumberBarType.New(ui, "#", {...})
end
function NumberBarType:__delete()
end

-- callback操作返回
function NumberBarType.Show(callback)
	local bar = NumberBarType.New()
	bar:SetTypeCallback(callback)
	UIMgr.ShowCenterPopup(bar)
end
