require "Core.Module.Common.Panel"

ZongMenLiLianDecPanel = class("ZongMenLiLianDecPanel",Panel);
function ZongMenLiLianDecPanel:New()
	self = { };
	setmetatable(self, { __index =ZongMenLiLianDecPanel });
	return self
end


function ZongMenLiLianDecPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function ZongMenLiLianDecPanel:_InitReference()
	self._txt_title = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_title");
	self._txt_label = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_label");
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
end

function ZongMenLiLianDecPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function ZongMenLiLianDecPanel:_OnClickBtn_close()
	 ModuleManager.SendNotification(ZongMenLiLianNotes.CLOSE_ZONGMENLILIANDECPANEL);
end

function ZongMenLiLianDecPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function ZongMenLiLianDecPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
end

function ZongMenLiLianDecPanel:_DisposeReference()
	self._btn_close = nil;
	self._txt_title = nil;
	self._txt_label = nil;
end
