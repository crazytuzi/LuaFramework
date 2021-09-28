
require "Core.Module.Confirm.View.BaseConfirmPanel"
Confirm7Panel = class("Confirm7Panel", BaseConfirmPanel);


local notice = LanguageMgr.Get("common/notice")
local ok = LanguageMgr.Get("common/ok")
local cancle = LanguageMgr.Get("common/cancle")

function Confirm7Panel:New()
	self = {};
	setmetatable(self, {__index = Confirm7Panel});
	return self
end


function Confirm7Panel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function Confirm7Panel:_InitReference()	
	self._txt_title = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_title");
	self._txt_label = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_label");
	self._btn_ok = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_ok");
	self._txtOk = UIUtil.GetChildByName(self._btn_ok, "UILabel", "Label");
	self._btn_cancel = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_cancel");
	self._txtCancle = UIUtil.GetChildByName(self._btn_cancel, "UILabel", "Label");
	self._toggle = UIUtil.GetChildByName(self._trsContent, "UIToggle", "checkBox")
end

function Confirm7Panel:_InitListener()
	self._onClickBtn_ok = function(go) self:_OnClickBtn_ok(self) end
	UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_ok);
	self._onClickBtn_cancel = function(go) self:_OnClickBtn_cancel(self) end
	UIUtil.GetComponent(self._btn_cancel, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_cancel);
	
	self._onClickToggle = function(go) self:_OnClickToggle(self) end
	UIUtil.GetComponent(self._toggle, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickToggle);
end

function Confirm7Panel:_OnClickToggle()
	if(self._toggleHandler) then
		self._toggleHandler(self._toggle.value)
	end
end

function Confirm7Panel:_OnClickBtn_ok() 
	if self._handlerTarget then
		if self._okHandler then
			self._okHandler(self._handlerTarget, self.data);
		end
	else
		if self._okHandler then
			
			self._okHandler(self.data);
		end
		
	end
	self:ClosePanel(ConfirmNotes.CLOSE_CONFIRM7PANEL);
end

function Confirm7Panel:_OnClickBtn_cancel()
	if self._handlerTarget ~= nil then
		if self._cancelHandler ~= nil then
			self._cancelHandler(self._handlerTarget, self.data);
		end
	else
		if self._cancelHandler ~= nil then
			self._cancelHandler(self.data);
		end
		
	end
	self:ClosePanel(ConfirmNotes.CLOSE_CONFIRM7PANEL);
end

--[title:标题 msg:文本内容 ok_Label:确认按钮文本 cance_lLabel:取消按钮文本 
--toggleValue:toggle的值 handle:确认回调 cancelHandler:取消回调 toggleHandler:toggle值变化回调
--target:函数调用的实例]
function Confirm7Panel:SetData(data)
	self._txt_title.text = data.title or notice;
	self._txt_label.text = data.msg;
	
	self._txtOk.text = data.ok_Label or ok;
	self._txtCancle.text = data.cance_lLabel or cancle;
	
	self._toggle.value = data.toggleValue or false
	self.data = data.data;
	self._okHandler = data.hander;
	self._cancelHandler = data.cancelHandler;
	self._toggleHandler = data.toggleHandler
	self._handlerTarget = data.target;
end

function Confirm7Panel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function Confirm7Panel:_DisposeListener()
	UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_ok = nil;
	UIUtil.GetComponent(self._btn_cancel, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_cancel = nil;
	UIUtil.GetComponent(self._toggle, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickToggle = nil;
	
	self._okHandler = nil
	self._cancelHandler = nil
	self._toggleHandler = nil
	self._handlerTarget = nil
end

function Confirm7Panel:_DisposeReference()
	self._txt_title = nil
	self._txt_label = nil
	self._btn_ok = nil
	self._txtOk = nil
	self._btn_cancel = nil
	self._txtCancle = nil
end
return Confirm7Panel 