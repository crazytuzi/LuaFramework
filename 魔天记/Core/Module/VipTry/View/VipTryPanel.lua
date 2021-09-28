require "Core.Module.Common.Panel"

local VipTryPanel = class("VipTryPanel",Panel);
function VipTryPanel:New()
	self = { };
	setmetatable(self, { __index =VipTryPanel });
	return self
end


function VipTryPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function VipTryPanel:_InitReference()
	local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
	self._btnmore = UIUtil.GetChildInComponents(btns, "btnmore");
	self._btntry = UIUtil.GetChildInComponents(btns, "btntry");
	self._btnGo = UIUtil.GetChildInComponents(btns, "btnGo");
	self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
	self._trsUse = UIUtil.GetChildByName(self._trsContent, "Transform", "trsUse");
	self._trsRecharge = UIUtil.GetChildByName(self._trsContent, "Transform", "trsRecharge");
end

function VipTryPanel:_InitListener()
	self._onClickBtnmore = function(go) self:_OnClickBtnmore(self) end
	UIUtil.GetComponent(self._btnmore, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnmore);
	self._onClickBtntry = function(go) self:_OnClickBtntry(self) end
	UIUtil.GetComponent(self._btntry, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtntry);
	self._onClickBtnGo = function(go) self:_OnClickBtnGo(self) end
	UIUtil.GetComponent(self._btnGo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGo);
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function VipTryPanel:_OnClickBtnmore()
	ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, {val = 4})
end

function VipTryPanel:_OnClickBtntry()
    VipTryProxy.StartTryVip(self.id)
	self:_OnClickBtn_close()
end

function VipTryPanel:_OnClickBtnGo()
    ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, {val = 4})
	self:_OnClickBtn_close()
end

function VipTryPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(VipTryNotes.CLOSE_VIP_TRY_PANEL)
end

function VipTryPanel:SetData(d)
    local flg = d.s == 1
    self.id = d.id
	self._trsUse.gameObject:SetActive(flg)
	self._trsRecharge.gameObject:SetActive(not flg)
end

function VipTryPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function VipTryPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnmore, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnmore = nil;
	UIUtil.GetComponent(self._btntry, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtntry = nil;
	UIUtil.GetComponent(self._btnGo, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnGo = nil;
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
end

function VipTryPanel:_DisposeReference()
	self._btnmore = nil;
	self._btntry = nil;
	self._btnGo = nil;
	self._btn_close = nil;
	self._trsUse = nil;
	self._trsRecharge = nil;
end
return VipTryPanel