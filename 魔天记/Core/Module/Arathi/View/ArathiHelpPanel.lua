require "Core.Module.Common.Panel";
require "Core.Module.Arathi.View.ArathiHelpAwardPanel"
require "Core.Module.Arathi.View.ArathiHelpTimePanel"

ArathiHelpPanel = Panel:New();

function ArathiHelpPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function ArathiHelpPanel:_InitReference()
    self._panels = { }
    self._btnTog1 = UIUtil.GetChildByName(self._trsContent, "UIButton", "trsToggle/btnTog1");
    self._btnTog2 = UIUtil.GetChildByName(self._trsContent, "UIButton", "trsToggle/btnTog2");
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");


    local p1 = UIUtil.GetChildByName(self._trsContent, "Transform", "trsPanels/panel1");
    if (p1) then
        self._panels[1] = ArathiHelpAwardPanel:New(p1);
    end

    local p2 = UIUtil.GetChildByName(self._trsContent, "Transform", "trsPanels/panel2");
    if (p2) then
        self._panels[2] = ArathiHelpTimePanel:New(p2);
    end

    self:SelectSubPanel(1);
end

function ArathiHelpPanel:_InitListener()
    self._onClickTab1Handler = function(go) self:_OnClickTab1Handler(self) end
    UIUtil.GetComponent(self._btnTog1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickTab1Handler);

    self._onClickTab2Handler = function(go) self:_OnClickTab2Handler(self) end
    UIUtil.GetComponent(self._btnTog2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickTab2Handler);

    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
end

function ArathiHelpPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function ArathiHelpPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnTog1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickTab1Handler = nil;

    UIUtil.GetComponent(self._btnTog2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickTab2Handler = nil;

    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;
end

function ArathiHelpPanel:_DisposeReference()
    self._btnClose = nil;
end

function ArathiHelpPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(ArathiNotes.CLOSE_ARATHIHELPPANEL)
end

function ArathiHelpPanel:_OnClickTab1Handler()
    self:SelectSubPanel(1)
end

function ArathiHelpPanel:_OnClickTab2Handler()
    self:SelectSubPanel(2)
end

function ArathiHelpPanel:SelectSubPanel(index)
    if (self._index ~= index and index) then
        for i, v in pairs(self._panels) do
            if (i == index) then
                v:Enable()
            else
                v:Disable()
            end
        end
        self._index = index
    end
end