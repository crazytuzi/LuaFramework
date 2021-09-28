require "Core.Module.Common.Panel"
require "Core.Module.Common.BasePropertyItem"


local RideRenewShowPanel = class("RideRenewShowPanel", Panel);
function RideRenewShowPanel:New()
	self = {};
	setmetatable(self, {__index = RideRenewShowPanel});
	return self
end

function RideRenewShowPanel:IsPopup()
	return false;
end


function RideRenewShowPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function RideRenewShowPanel:_InitReference()
	
	self._txtDes = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtDes");
	self._txtName = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtName");
	self._txtSpeedAdd = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtSpeedAdd");	
	self._btnRenew = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnRenew");
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");	
	self._trsRoleParent = UIUtil.GetChildByName(self._trsContent, "TexturePanel/imgRole/heroCamera/trsRoleParent");
	self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "allpropertyPhalanx")
	self._phalanx = Phalanx:New()
	self._phalanx:Init(self._phalanxInfo, BasePropertyItem)
end

function RideRenewShowPanel:_InitListener()
	self._onClickBtnRenew = function(go) self:_OnClickBtnRenew(self) end
	UIUtil.GetComponent(self._btnRenew, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRenew);
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function RideRenewShowPanel:_OnClickBtnRenew()
	ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, self.data)	
end

function RideRenewShowPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(RideNotes.CLOSE_RIDERENEWSHOWPANEL)
end

function RideRenewShowPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function RideRenewShowPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnRenew, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnRenew = nil;
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
end

function RideRenewShowPanel:_DisposeReference()
	self._btnRenew = nil;
	self._btn_close = nil;
	self._txtDes = nil;
	self._txtName = nil;
	self._txtSpeedAdd = nil;
	self._txtDes = nil;
	self._trsRoleParent = nil;
end

function RideRenewShowPanel:UpdatePanel(data)
	self.data = data
	
	if(self.data) then
		local rideInfo = self.data.rideInfo		
		self._txtDes.text = rideInfo.desc
		self._txtName.text = rideInfo.name
		local attr = rideInfo:GetPropertyAndDes()
		local count = table.getCount(attr)
		self._phalanx:Build(math.ceil((count - 1)) / 2 + 1, 2, attr)
		self._txtSpeedAdd.text = rideInfo.speed_per / 10 .. ""
		if(self._uiRideAnimationModel == nil) then
			self._uiRideAnimationModel = UIAnimationModel:New(rideInfo, self._trsRoleParent, RideModelCreater)
		else
			self._uiRideAnimationModel:ChangeModel(rideInfo, self._trsRoleParent)
		end
	end
end
return RideRenewShowPanel 