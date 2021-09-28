require "Core.Module.Common.Panel"
require "Core.Module.Common.BasePropertyItem"

RoleAttrPanel = class("TitleAttrPanel", Panel);
function RoleAttrPanel:New()
	self = {};
	setmetatable(self, {__index = RoleAttrPanel});
	return self
end


function RoleAttrPanel:_Init()
	self:_InitReference();
	self:_InitListener();
	self:UpdatePanel()
end

function RoleAttrPanel:_InitReference()
	self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "phalanx")
	self._phalanx = Phalanx:New()
	self._phalanx:Init(self._phalanxInfo, BasePropertyItem)
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
end

function RoleAttrPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function RoleAttrPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(MainUINotes.CLOSE_ROLEATTRPANEL)
end

function RoleAttrPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	self._phalanx:Dispose()
	self._phalanx = nil
end

function RoleAttrPanel:UpdatePanel()
	local data = BaseAdvanceAttrInfo:New()
	data:Init(HeroController.GetInstance():GetInfo())
	if(data) then
		local attr = data:GetAllPropertyAndDes()
      
		self._phalanx:Build(math.ceil((table.getCount(attr) - 1) / 2 + 1), 2, attr)
	end
end


function RoleAttrPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
end

function RoleAttrPanel:_DisposeReference()
	self._btn_close = nil;
	
end
