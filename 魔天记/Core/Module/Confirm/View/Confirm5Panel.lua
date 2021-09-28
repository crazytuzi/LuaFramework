require "Core.Module.Confirm.View.BaseConfirmPanel"
Confirm5Panel = class("Confirm5Panel", BaseConfirmPanel);

function Confirm5Panel:New()
	self = {};
	setmetatable(self, {__index = Confirm5Panel});
	return self
end


function Confirm5Panel:_Init()
	self._luaBehaviour.canPool = true
	self:_InitReference();
	self:_InitListener();
end

function Confirm5Panel:_InitReference()
	self._txt_title = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_title");
	self._txt_label = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_label");
	self._btn_ok = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_ok");
	self._btn_cancel = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_cancel");
	
	local g = GuildDataManager.GetMyGuildData()
	--[[     消耗的“仙盟资金”=基础消耗+帮会等级*系数a
     基础消耗为100，等级系数为100，这两个系数都是暂时的
     ]]
	local needNum = 100 + 100 * g.level;
	
	self._txt_label.text = LanguageMgr.Get("Confirm5Panel/label1", {n = needNum});
end

function Confirm5Panel:_InitListener()
	self._onClickBtn_ok = function(go) self:_OnClickBtn_ok(self) end
	UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_ok);
	self._onClickBtn_cancel = function(go) self:_OnClickBtn_cancel(self) end
	UIUtil.GetComponent(self._btn_cancel, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_cancel);
end

function Confirm5Panel:_OnClickBtn_ok()
	XMBossProxy.TryMXBossZaoHuang();
	self:ClosePanel(ConfirmNotes.CLOSE_CONFIRM5PANEL);
	
end

function Confirm5Panel:_OnClickBtn_cancel()
	self:ClosePanel(ConfirmNotes.CLOSE_CONFIRM5PANEL);
	
end

function Confirm5Panel:SetData(data)
	
end

function Confirm5Panel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	
end

function Confirm5Panel:_DisposeListener()
	UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_ok = nil;
	UIUtil.GetComponent(self._btn_cancel, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_cancel = nil;
end

function Confirm5Panel:_DisposeReference()
	self._btn_ok = nil;
	self._btn_cancel = nil;
	self._txt_title = nil;
	self._txt_label = nil;
end

