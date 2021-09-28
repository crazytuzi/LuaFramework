require "Core.Module.Common.Panel"

ResultPanel = class("ResultPanel",Panel);



function ResultPanel:_OnNew()
    local luaPanel = Resourcer.Get("GUI/FBResult","UI_FBResultPanel");
end

function ResultPanel:_DisposeBase()
    if self._baseUI then
        Resourcer.Recycle(self._baseUI,false);
    end
end

function ResultPanel:GetUIOpenSoundName()
    return ""
end
