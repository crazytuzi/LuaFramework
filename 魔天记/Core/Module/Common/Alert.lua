require "Core.Module.Common.Panel"

Alert = Panel:New();

function Alert:SetAutoCloseFlag(v)
	self._autoCloseFlag = v;
end

function Alert:RegistListener(onClickBtnOKHandler, onClickBtnCancelHandler)
    self._onClickBtnOKHandler = onClickBtnOKHandler;
    self._onClickBtnCancelHandler = onClickBtnCancelHandler;
end

function Alert:_InitReference()
	self._btnOK = UIUtil.GetChildByName(self._trsContent, "Button", "btnOK");
	self._btnCancel = UIUtil.GetChildByName(self._trsContent, "Button", "btnCancel");
	self._btnClose = UIUtil.GetChildByName(self._trsContent, "Button", "btnClose");
	self._txtTitle = UIUtil.GetChildByName(self._trsContent, "Text", "txtTitle");
	self._txtContent = UIUtil.GetChildByName(self._trsContent, "Text", "txtContent");
	self._txtContent2 = UIUtil.GetChildByName(self._trsContent, "Text", "txtContent2");
	self._txtContent3 = UIUtil.GetChildByName(self._trsContent, "Text", "txtContent3");
	self._imgContent = UIUtil.GetChildByName(self._trsContent, "Image", "imgContent");
end

function Alert:_OnClickBtnOK(evt)
	if self._onClickBtnOKHandler ~= nil then
		self._onClickBtnOKHandler();
	end
	if self._autoCloseFlag then
		PanelManager.RecyclePanel(self);
	end
end

function Alert:_OnClickBtnCancel(evt)
	if self._onClickBtnCancelHandler ~= nil then
		self._onClickBtnCancelHandler();
	end
	if self._autoCloseFlag then
		PanelManager.RecyclePanel(self);
	end
end
    
function Alert:_InitListener()
	if self._btnOK ~= nil then
		self._onClickBtnOK = function(evt) self:_OnClickBtnOK(evt) end
		UIUtil.GetComponent(self._btnOK, "LuaUIEventListener"):RegisterDelegate("OnPointerClick", self._onClickBtnOK);
	end
	if self._btnCancel ~= nil then
		self._onClickBtnCanel = function(evt) self:_OnClickBtnCancel(evt) end
		UIUtil.GetComponent(self._btnCancel, "LuaUIEventListener"):RegisterDelegate("OnPointerClick", self._onClickBtnCanel);
	end
	if self._btnClose ~= nil then
		self._onClickBtnClose = function(evt) self:_OnClickBtnCancel(evt) end
		UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnPointerClick", self._onClickBtnClose);
	end	
end

function Alert:_Init()
	self._autoCloseFlag = true;
	self:_InitReference();
	self:_InitListener();
end

function Alert:_DisposeListener()
	if self._btnOK ~= nil then
		UIUtil.GetComponent(self._btnOK, "LuaUIEventListener"):RemoveDelegate("OnPointerClick");
		self._onClickBtnOK = nil;
	end 
	if self._btnCancel ~= nil then
		UIUtil.GetComponent(self._btnCancel, "LuaUIEventListener"):RemoveDelegate("OnPointerClick");
		self._onClickBtnCanel = nil;
	end
	if self._btnClose ~= nil then
		UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnPointerClick");
		self._onClickBtnClose = nil;
	end
end

function Alert:_DisposeReference()
	self._btnOK = nil;
	self._btnCancel = nil;
	self._btnClose = nil;
	self._txtTitle = nil;
	self._txtContent = nil;
	self._txtContent2 = nil;
	self._txtContent3 = nil;
	self._imgContent = nil;
	self._onClickBtnOKHandler = nil;
	self._onClickBtnCancelHandler = nil;
end

function Alert:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function Alert:SetTitle(v)
	self._txtTitle.text = v;
end

function Alert:SetContent(v)
	self._txtContent.text = v;
end

function Alert:SetContent2(v)
	self._txtContent2.text = v;
end

function Alert:SetContent3(v)
	self._txtContent3.text = v;
end

function Alert:SetImageContent(v)
	--self._imgContent.spriteName = v;--NGUI
	self._imgContent.sprite = sprite;
end

function Alert:GetImageContent()
	--return self._imgContent.spriteName;--NGUI
	return self._imgContent.sprite;
end
