require "Core.Module.Common.UIItem"
require "Core.Module.Mall.View.Item.SubMallItem"

SubMallListItem = UIItem:New();
function SubMallListItem:_Init()
    self._phalanxInfo = UIUtil.GetComponent(self.transform, "LuaAsynPhalanx")
    self._phalanx = Phalanx:New()
    self._phalanx:Init(self._phalanxInfo, SubMallItem)
    self:UpdateItem(self.data)
end
   
function SubMallListItem:_Dispose()
    self._phalanx:Dispose()
    self._phalanx = nil
end 

function SubMallListItem:UpdateItem(data)
    self.data = data
    local count = 1
    if (self.data) then
        count = table.getCount(self.data)
    end

    self._phalanx:Build(math.ceil((count - 1)) / 2 + 1, math.min(2, count), self.data)
end

function SubMallListItem:SetItemToggle(index, enable)
    local item = self._phalanx:GetItem(index)
    if (item) then
        item.itemLogic:SetToggleActive(enable)
    end 
end

 

 
