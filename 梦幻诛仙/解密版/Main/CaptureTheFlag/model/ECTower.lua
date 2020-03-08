local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECPlayer = require("Model.ECPlayer")
local ECTower = Lplus.Extend(ECPlayer, "ECTower")
local def = ECTower.define
def.final("number", "=>", ECTower).new = function(cfgId)
  local obj = ECTower()
  obj.m_IsTouchable = true
  obj.m_create_node2d = true
  obj.defaultParentNode = gmodule.moduleMgr:GetModule(ModuleId.MAP).mapPlayerNodeRoot
  obj.defaultLayer = ClientDef_Layer.NPC
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
    self:CaptureTower()
  else
    heroModule:MoveTo(0, towerPos.x, towerPos.y, 0, 5, MoveType.RUN, function()
      self:CaptureTower()
    end)
  end
end
def.method().CaptureTower = function(self)
  require("Main.CaptureTheFlag.mgr.CTFFeature").Instance():RobTower(self.mModelId)
end
return ECTower.Commit()
