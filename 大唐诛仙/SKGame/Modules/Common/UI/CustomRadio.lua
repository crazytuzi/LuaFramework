CustomRadio = BaseClass(LuaUI)

function CustomRadio:__init(...)
	self.URL = "ui://0tyncec15v99nkh";
	self:__property(...)
	self:Config()
end
function CustomRadio:SetProperty(...)
end
function CustomRadio:Config()
end
function CustomRadio:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Common","CustomRadio")
	self.state = self.ui:GetController("state")
	self.selectCallBack = nil
	self.unSelectCallBack = nil
	self.curState = 1
	self.state.selectedIndex = self.curState
	self:AddEvent()
end
function CustomRadio.Create(ui, ...)
	return CustomRadio.New(ui, "#", {...})
end
function CustomRadio:AddEvent()
	self.ui.onClick:Add(self.OnClickHandler, self)
end
function CustomRadio:RemoveEvent()
	self.ui.onClick:Remove(self.OnClickHandler, self)
end
function CustomRadio:SetCallBack(select, unSelect)
	self.selectCallBack = select
	self.unSelectCallBack = unSelect
end
function CustomRadio:OnClickHandler()
	if self.curState == 1 then
		self.curState = 0
		if self.selectCallBack then
			self.selectCallBack()
		end
	else
		self.curState = 1
		if self.unSelectCallBack then
			self.unSelectCallBack()
		end
	end
	self.state.selectedIndex = self.curState
end
function CustomRadio:IsSelect()
	return self.curState == 0
end
function CustomRadio:Reset()
	self.curState = 1
	self.state.selectedIndex = self.curState
end

function CustomRadio:__delete()
	self:RemoveEvent()

	self.selectCallBack = nil
	self.unSelectCallBack = nil
end