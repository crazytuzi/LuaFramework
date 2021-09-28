

local equipmentItem = require("app.scenes.equipment.cell.EquipmentListCell")

--local TreasureItem = require("app.scenes.treasureCulture.TreasureItem")
local TreasureListFragmentLayer = class("TreasureListFragmentLayer",UFCCSNormalLayer)
local EquipmentConst = require("app.const.EquipmentConst")

function TreasureListFragmentLayer.create(...)
    return TreasureListFragmentLayer.new("ui_layout/equipment_EquipmentListLayer.json", ...)
end

function TreasureListFragmentLayer:ctor(...)
    
    self._listView = nil
    self.super.ctor(self, ...)
end


--addNode上去的,貌似不会自动调用这个方法
function TreasureListFragmentLayer:onLayerEnter()

end

function TreasureListFragmentLayer:updateView()
    

end



function TreasureListFragmentLayer:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
    self.super:onLayerExit()
end


return TreasureListFragmentLayer
