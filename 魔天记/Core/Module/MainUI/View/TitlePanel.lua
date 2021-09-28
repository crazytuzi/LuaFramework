require "Core.Module.Common.Panel"
require "Core.Module.Common.TitleItem"

TitlePanel = class("TitlePanel", Panel);

local autoCloseTime = 5
function TitlePanel:New()
    self = { };
    setmetatable(self, { __index = TitlePanel });
    return self
end

function TitlePanel:GetUIOpenSoundName( )
    return ""
end

function TitlePanel:IsPopup()
    return false;
end 

function TitlePanel:IsFixDepth()
    return true;
end 

function TitlePanel:_Init()
    self:_InitReference();
    self:_InitListener();
    self._time = autoCloseTime
end

function TitlePanel:_InitReference()
    self._txtNotice = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtNotice");
    self._btnCheckTitle = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnCheckTitle");
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
    self._trsTitleItem = UIUtil.GetChildByName(self._trsContent, "Transform", "trsTitleItem");
    self._titleItem = TitleItem:New()
    self._titleItem:Init(self._trsTitleItem)
    self._timer = Timer.New( function() TitlePanel._OnTimerHandler(self) end, 1, -1, false);

end

function TitlePanel:_InitListener()
    self._onClickBtnCheckTitle = function(go) self:_OnClickBtnCheckTitle(self) end
    UIUtil.GetComponent(self._btnCheckTitle, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnCheckTitle);
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
end

function TitlePanel:_OnClickBtnCheckTitle()
    local type = self.data["type"]
    ModuleManager.SendNotification(MainUINotes.CLOSE_TITLENOTICE)
    ModuleManager.SendNotification(MainUINotes.OPEN_MYROLEPANEL, { 3,type })
end

function TitlePanel:_OnClickBtnClose()
    self._timer:Stop()
    ModuleManager.SendNotification(MainUINotes.CLOSE_TITLENOTICE)
end

function TitlePanel:_Dispose()
    if (self._timer) then
        self._timer:Stop()
        self._timer = nil
    end

    self._titleItem:Dispose()
    self._titleItem = nil  

    self:_DisposeListener();
    self:_DisposeReference();
    
end

function TitlePanel:_DisposeListener()
    UIUtil.GetComponent(self._btnCheckTitle, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnCheckTitle = nil;
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;
end

function TitlePanel:_DisposeReference()
    self._btnCheckTitle = nil;
    self._btnClose = nil;
    self._txtNotice = nil;
    self._trsTitleItem = nil;
end

local get = LanguageMgr.Get("TitlePanel/get")
local lost = LanguageMgr.Get("TitlePanel/lost")

function TitlePanel:UpdatePanel(data, isGet)
    if (data == nil) then
        return
    end
   
    self.data = data
    self._timer:Stop()
    self._time = autoCloseTime
    self._timer:Start()

    self._titleItem:UpdateItem(data)
    if (isGet) then
        self._txtNotice.text = get
        self._txtNotice.color = ColorDataManager.Get_green()
    else
        self._txtNotice.text = lost
        self._txtNotice.color = ColorDataManager.Get_red()
    end
end


function TitlePanel:_OnTimerHandler()
    self._time = self._time - 1

    if (self._time == 0) then
        self._timer:Stop()
        ModuleManager.SendNotification(MainUINotes.CLOSE_TITLENOTICE)
    end
end