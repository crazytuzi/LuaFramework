require "Core.Module.Common.UIComponent"


local SubNewestNoticePanel1 = class("SubNewestNoticePanel1", UIComponent);
function SubNewestNoticePanel1:New(parent)
	self = {};
	setmetatable(self, {__index = SubNewestNoticePanel1});
	log(parent)
	if(parent) then
		self._gameObject = UIUtil.GetUIGameObject(ResID.UI_SUBNEWESTNOTICEPANEL1, parent)
		self:Init(self._gameObject.transform)
	end
	self._isInit = false
	return self
end

function SubNewestNoticePanel1:_Init()
	self._txtContent = UIUtil.GetChildByName(self._transform, "UILabel", "content")	
	self._txtMsg1Smylog = UIUtil.GetChildByName(self._transform, "SymbolLabel", "content");
end

function SubNewestNoticePanel1:_Dispose()
	UIUtil.GetComponent(self._txtContent, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._txtContent = nil
	if(self._gameObject) then
		Resourcer.Recycle(self._gameObject, false);	
	end
end

function SubNewestNoticePanel1:UpdatePanel(data)
	self.data = data
	if(self.data) then
		if(not self._isInit) then
			self._isInit = true
			self._txtContent.text = self.data.content
            self._txtMsg1Smylog:UpdateLabel()
			TextCode.Handler(self._txtContent)
		end
	end
end

return SubNewestNoticePanel1 