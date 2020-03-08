local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECPlayer = require("Model.ECPlayer")
local ECGatherItem = Lplus.Extend(ECPlayer, "ECGatherItem")
local def = ECGatherItem.define
def.final("number", "userdata", "=>", ECGatherItem).new = function(cfgId, instanceId)
  local obj = ECGatherItem()
  obj.m_IsTouchable = true
  obj.m_create_node2d = true
  obj.defaultParentNode = gmodule.moduleMgr:GetModule(ModuleId.MAP).mapPlayerNodeRoot
  obj.defaultLayer = ClientDef_Layer.NPC
  obj.roleId = instanceId
  obj:Init(cfgId)
  return obj
end
def.override().OnClick = function(self)
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local heroPos = heroModule.myRole:GetPos()
  local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  local towerPos = self:GetPos()
  if heroPos == nil or towerPos == nil then
    return
  end
  local dx = (towerPos.x - heroPos.x) * (towerPos.x - heroPos.x)
  local dy = (towerPos.y - heroPos.y) * (towerPos.y - heroPos.y)
  local diff = math.sqrt(dx + dy)
  if diff < 160 then
    self:GatherItem()
  else
    heroModule:MoveTo(0, towerPos.x, towerPos.y, 0, 5, MoveType.RUN, function()
      self:GatherItem()
    end)
  end
end
def.method().GatherItem = function(self)
  require("Main.CaptureTheFlag.mgr.RobGroundResFeature").Instance():GatherItem(self.roleId)
end
return ECGatherItem.Commit()
