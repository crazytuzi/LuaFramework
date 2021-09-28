require "Core.Module.Trump.View.Item.SubFusionEquipItem"
SubRefineEquipItem = class("SubRefineEquipItem", SubFusionEquipItem);

function SubRefineEquipItem:New()
    self = { };
    setmetatable(self, { __index = SubRefineEquipItem });
    return self
end

function SubRefineEquipItem:_OnClickItem()
    if (self.data and self.data.info) then
        TrumpProxy.SetSelectRefineTrumpData(self.data)
    end
end

function SubRefineEquipItem:_UpdateOther(data)
    if (data) then
        self._trsLvBg:SetActive(data.info.refineLev > 0)
        if (data.info.refineLev > 0) then
            self._txtLevel.text = data.info.refineLev
        else
            self._txtLevel.text = ""
        end
    end
end