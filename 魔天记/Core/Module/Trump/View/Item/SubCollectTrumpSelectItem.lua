-- require "Core.Module.Trump.View.Item.SubFusionSelectItem"
require "Core.Module.Common.BaseSelectItem"

SubCollectTrumpSelectItem = class("SubCollectTrumpSelectItem", BaseSelectItem);

function SubCollectTrumpSelectItem:New()
    self = { };
    setmetatable(self, { __index = SubCollectTrumpSelectItem });
    return self
end


function SubCollectTrumpSelectItem:_OnClickItem()
    if self._toggle.value then
        TrumpManager.SetCollectQc(self.data)
    else
        TrumpManager.SetCollectQc(-1)
    end
    ModuleManager.SendNotification(TrumpNotes.SET_TRUMPOBTAINPANELSELECTPANEL)
end