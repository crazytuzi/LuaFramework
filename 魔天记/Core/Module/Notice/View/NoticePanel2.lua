require "Core.Module.Common.Panel"

NoticePanel2 = class("NoticePanel2",Panel);
function NoticePanel2:New()
	self = { };
	setmetatable(self, { __index =NoticePanel2 });
	return self
end
function NoticePanel2:IsPopup()
    return false
end

function NoticePanel2:_Init()
	self:_InitReference();
	self:_InitListener();
end

function NoticePanel2:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
	self._txtCon = UIUtil.GetChildInComponents(txts, "txtCon");
	self._txtBug = UIUtil.GetChildInComponents(txts, "txtBug");

	self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
	self._btnOk = UIUtil.GetChildByName(self._trsContent, "UIButton", "con/btnOk");

	self._uiTable = UIUtil.GetChildByName(self._trsContent, "UITable", "trsScroll/Table");
end

function NoticePanel2:_InitListener()
	self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
	self._onClickBtnOk = function(go) self:_OnClickBtnOk(self) end
	UIUtil.GetComponent(self._btnOk, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnOk);
end

function NoticePanel2:_OnClickBtnClose()
	ModuleManager.SendNotification(NoticeNotes.CLOSE_NOTICE_PANEL2)
end

function NoticePanel2:_OnClickBtnOk()
	ModuleManager.SendNotification(NoticeNotes.CLOSE_NOTICE_PANEL2)
end

function NoticePanel2:UpdatePanel(data)

	if data.notice and data.notice ~= "" then
		self._txtCon.gameObject:SetActive(true);
    	self._txtCon.text = data.notice;
   	else
		self._txtCon.gameObject:SetActive(false);
   	end

    if data.bug_notice and data.bug_notice ~= "" then
    	self._txtBug.gameObject:SetActive(true);
    	self._txtBug.text = data.bug_notice;
    else
    	self._txtBug.gameObject:SetActive(false);
  	end

  	self._uiTable:Reposition();
end

function NoticePanel2:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function NoticePanel2:_DisposeListener()
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;
	UIUtil.GetComponent(self._btnOk, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnOk = nil;
end

function NoticePanel2:_DisposeReference()
	self._btnClose = nil;
	self._btnOk = nil;
	self._txtCon = nil;

end
