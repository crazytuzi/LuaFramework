require "Core.Module.Common.Panel"

local RideRenewPanel = class("RideRenewPanel", Panel);
function RideRenewPanel:New()
	self = {};
	setmetatable(self, {__index = RideRenewPanel});
	return self
end

function RideRenewPanel:IsFixDepth()
	return true
end

function RideRenewPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end
local time = 10
function RideRenewPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
	self._txtTime = UIUtil.GetChildInComponents(txts, "txtTime");
	self._txtName = UIUtil.GetChildInComponents(txts, "txtName");
	self._imgIcon = UIUtil.GetChildByName(self._trsContent, "UISprite", "imgIcon");
	self._imgQuality = UIUtil.GetChildByName(self._trsContent, "UISprite", "imgQuality");
	self._btnAction = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnAction");
	self._timer = Timer.New(function()
		self:_OnUpdate()		
	end, 1, 10, false);
	self._timer:Start()	
	self._timer:Pause(true)
end

function RideRenewPanel:_InitListener()
	self._onClickBtnAction = function(go) self:_OnClickBtnAction(self) end
	UIUtil.GetComponent(self._btnAction, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAction);
end

function RideRenewPanel:_OnClickBtnAction()
	if(self._timer) then
		self._timer:Pause(true)		
	end
	
	if(self._func) then
		self._func()
	end
	
	ModuleManager.SendNotification(RideNotes.CLOSE_RIDEREUSEPANEL)
end

function RideRenewPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function RideRenewPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnAction, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnAction = nil;
end

function RideRenewPanel:_DisposeReference()
	self._btnAction = nil;
	self._txtTime = nil;
	self._txtName = nil;
	self._imgIcon = nil;
	self._imgQuality = nil;
	
	if(self._timer) then
		self._timer:Stop()
		self._timer = nil
	end
	self._func = nil
end

function RideRenewPanel:UpdatePanel(data, func)
	self._func = func
	self.data = data
	if(self.data) then
		self._time = time
		self._txtName.text = self.data.name
		ProductManager.SetIconSprite(self._imgIcon, self.data.icon)
		self._imgQuality.color = ColorDataManager.GetColorByQuality(self.data.quality)	
		self._timer:Pause(false)	
		self:_OnUpdate()		
		
	end
end

function RideRenewPanel:_OnUpdate()
	
	self._txtTime.text = self._time .. ""
	self._time = self._time - 1
	if self._time < 0 then
		self._timer:Pause(true);
		ModuleManager.SendNotification(RideNotes.CLOSE_RIDEREUSEPANEL)
		-- if(self._func) then
		-- 	self._func()
		-- end
	end
end

return RideRenewPanel 