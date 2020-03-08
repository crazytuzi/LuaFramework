local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationSweep = Lplus.Extend(OperationBase, "OperationSweep")
local def = OperationSweep.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.SWEEP_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local SoloNpc = require("Main.Dungeon.DungeonUtils").GetDungeonConst().SoloServiceNpc
  local ServiceType = require("consts.mzm.gsp.npc.confbean.ServiceType")
  Event.DispatchEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_GOTO_TARGET_SERVICE, {
    SoloNpc,
    ServiceType.Function,
    nil
  })
  return true
end
OperationSweep.Commit()
return OperationSweep
