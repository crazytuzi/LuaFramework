require "Core.Module.Common.UIItem"

SubMallTypeItem = UIItem:New();
function SubMallTypeItem:_Init()
	self._txtDes = UIUtil.GetChildByName(self.gameObject, "UILabel", "tltle")
	self._onClick = function(go) self:_OnClick() end
	self._toggle = UIUtil.GetComponent(self.gameObject, "UIToggle")
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);
	self:UpdateItem(self.data);
end

function SubMallTypeItem:_OnClick()
	ModuleManager.SendNotification(MallNotes.RESETSCROLLVIEW)
	MallProxy.SendGetMallItem(1, self.data.id)
end

function SubMallTypeItem:_Dispose()
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClick = nil;
end

function SubMallTypeItem:SetToggleActive(enable)
	self._toggle.value = enable
end

function SubMallTypeItem:UpdateItem(data)
	self.data = data
	if(self.data) then
		self._txtDes.text = self.data.name
	end
end




