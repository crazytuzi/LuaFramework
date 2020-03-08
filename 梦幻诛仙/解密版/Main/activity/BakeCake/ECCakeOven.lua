local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECPlayer = require("Model.ECPlayer")
local ECCakeOven = Lplus.Extend(ECPlayer, "ECCakeOven")
local def = ECCakeOven.define
def.final("number", "=>", ECCakeOven).new = function(cfgId)
  local obj = ECCakeOven()
  obj.m_IsTouchable = true
  obj.m_create_node2d = true
  obj.defaultParentNode = gmodule.moduleMgr:GetModule(ModuleId.MAP).mapPlayerNodeRoot
  obj.defaultLayer = ClientDef_Layer.NPC
  obj.m_Name = textRes.BakeCake[36]
  obj:Init(cfgId)
  return obj
end
def.override().OnClick = function(self)
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local heroPos = heroModule.myRole:GetPos()
  local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  local modelPos = self:GetPos()
  if heroPos == nil or modelPos == nil then
    return
  end
  local dx = (modelPos.x - heroPos.x) * (modelPos.x - heroPos.x)
  local dy = (modelPos.y - heroPos.y) * (modelPos.y - heroPos.y)
  local diff = math.sqrt(dx + dy)
  if diff < 160 then
    self:OpenCakeOven()
  else
    heroModule:MoveTo(0, modelPos.x, modelPos.y, 0, 5, MoveType.RUN, function()
      self:OpenCakeOven()
    end)
  end
end
def.method().OpenCakeOven = function(self)
  require("Main.activity.BakeCake.BakeCakeMgr").Instance():ShowMainUI()
end
return ECCakeOven.Commit()
