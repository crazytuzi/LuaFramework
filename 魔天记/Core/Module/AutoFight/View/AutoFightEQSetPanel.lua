require "Core.Module.Common.Panel"

require "Core.Module.AutoFight.ctr.GuajiSetEqCtr"

AutoFightEQSetPanel = class("AutoFightEQSetPanel", Panel);
function AutoFightEQSetPanel:New()
    self = { };
    setmetatable(self, { __index = AutoFightEQSetPanel });
    return self
end


function AutoFightEQSetPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function AutoFightEQSetPanel:_InitReference()
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
end

function AutoFightEQSetPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);


    self.epPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "epPanel");

    for i = 1, 8 do
        local gobj = UIUtil.GetChildByName(self.epPanel, "Transform", "eq_" .. i);
        self["eqCtr" .. i] = GuajiSetEqCtr:New();
        self["eqCtr" .. i]:Init(gobj, i);
    end

    
    
end



function AutoFightEQSetPanel:_OnClickBtn_close()
    SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, self._name);
    ModuleManager.SendNotification(AutoFightNotes.CLOSE_AUTOFIGHTEQSETPANEL);
end

function AutoFightEQSetPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function AutoFightEQSetPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
end

function AutoFightEQSetPanel:_DisposeReference()
    self._btn_close = nil;

    for i = 1, 8 do
        self["eqCtr" .. i]:Dispose();
         self["eqCtr" .. i] = nil;
    end
     self.epPanel = nil;
      self._onClickBtn_close = nil;

    GuajiSetEqCtr.currSelected = nil;

   

end
