require "Core.Module.Common.Panel"

XLTInstanceDecPanel = class("XLTInstanceDecPanel",Panel);
function XLTInstanceDecPanel:New()
	self = { };
	setmetatable(self, { __index =XLTInstanceDecPanel });
	return self
end


function XLTInstanceDecPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function XLTInstanceDecPanel:_InitReference()
	self._txtTipTitle = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTipTitle");

    self.lb_num = 1;
    self.lbs={};

    for i=1, self.lb_num do 
       self.lbs[i] = UIUtil.GetChildByName(self._trsContent, "UILabel", "decPanel/txtlb"..i);  
       self.lbs[i].text=LanguageMgr.Get("XLTInstance/XLTInstanceDecPanel/lb"..i)
    end 

	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

    self._txtTipTitle.text=LanguageMgr.Get("XLTInstance/XLTInstanceDecPanel/title")

end

function XLTInstanceDecPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function XLTInstanceDecPanel:_OnClickBtn_close()
	 ModuleManager.SendNotification(XLTInstanceNotes.CLOSE_XLTINSTANCEDECPANEL);
end

function XLTInstanceDecPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function XLTInstanceDecPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
end

function XLTInstanceDecPanel:_DisposeReference()
	self._btn_close = nil;
	self._txtTipTitle = nil;
end
