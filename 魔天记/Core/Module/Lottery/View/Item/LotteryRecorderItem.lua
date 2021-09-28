require "Core.Module.Common.UIItem"

local LotteryRecorderItem = class("LotteryRecorderItem", UIItem);

function LotteryRecorderItem:New()
	self = {};
	setmetatable(self, {__index = LotteryRecorderItem});
	return self
end

function LotteryRecorderItem:_Init()	
	self._txtRecorder = UIUtil.GetComponent(self.transform, "UILabel")
	self:UpdateItem(self.data)
end

function LotteryRecorderItem:_Dispose()
	UIUtil.GetComponent(self._txtRecorder, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._txtRecorder = nil
end

function LotteryRecorderItem:UpdateItem(data)
	self.data = data
	if(self.data) then
		self._txtRecorder.text = self.data
		UIUtil.GetComponent(self._txtRecorder, "LuaUIEventListener"):RemoveDelegate("OnClick");
		TextCode.Handler(self._txtRecorder)
	end
end

return LotteryRecorderItem 