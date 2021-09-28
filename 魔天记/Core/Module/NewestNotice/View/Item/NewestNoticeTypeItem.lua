require "Core.Module.Common.UIItem"

local NewestNoticeTypeItem = class("NewestNoticeTypeItem", UIItem);

function NewestNoticeTypeItem:New()
	self = {};
	setmetatable(self, {__index = NewestNoticeTypeItem});
	return self
end


function NewestNoticeTypeItem:_Init()
 
	self._txtTitle = UIUtil.GetChildByName(self.transform, "UILabel", "title")
	self._goTip = UIUtil.GetChildByName(self.transform, "tip").gameObject
	self._onClickItem = function(go) self:_OnClickItem() end
	UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
	self:UpdateItem(self.data)
end

function NewestNoticeTypeItem:_OnClickItem()	 
	ModuleManager.SendNotification(NewestNoticeNotes.UPDATE_NEWESTNOTICENOTESPANEL, self.data)
end

function NewestNoticeTypeItem:_Dispose()
	UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickItem = nil;
end

function NewestNoticeTypeItem:UpdateItem(data)
	self.data = data
	if(self.data) then
		self._txtTitle.text = self.data.title		
	end
end

return NewestNoticeTypeItem