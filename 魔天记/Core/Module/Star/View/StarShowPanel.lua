require "Core.Module.Common.Panel"

local StarShowPanel = class("StarShowPanel",Panel);
function StarShowPanel:New()
	self = { };
	setmetatable(self, { __index =StarShowPanel });
	return self
end


function StarShowPanel:_Init()
	self:_InitReference();
	self:_InitListener();
    self:UpdatePanel()
end

function StarShowPanel:_InitReference()
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

    self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "scrollView/phalanx");
	self._phalanx = Phalanx:New();
    local Item = require "Core.Module.Star.View.StarShowItem"
	self._phalanx:Init(self._phalanxInfo, Item)
end

function StarShowPanel:_InitListener()
	self:_AddBtnListen(self._btn_close.gameObject)
end

function StarShowPanel:_OnBtnsClick(go)
	if go == self._btn_close.gameObject  then
		self:_OnClickBtn_close()
	end
end

function StarShowPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(StarNotes.CLOSE_STAR_SHOW_PANEL)
end

function StarShowPanel:UpdatePanel()
    local d = StarManager.GetConfigs()
	self._phalanx:Build(40, 1, d)
end

function StarShowPanel:_Dispose()
	self:_DisposeReference();
    self._phalanx:Dispose()
	self._phalanx = nil
end

function StarShowPanel:_DisposeReference()
	self._btn_close = nil;
	self._txtNuLock = nil;
end
return StarShowPanel