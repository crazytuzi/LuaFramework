local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECModel = require("Model.ECModel")
local ECAirCraft = Lplus.Extend(ECModel, "ECAirCraft")
local ECFxMan = require("Fx.ECFxMan")
local def = ECAirCraft.define
def.field("table").owner = nil
def.final("number", "table", "=>", ECAirCraft).new = function(id, owner)
  local obj = ECAirCraft()
  obj.m_IsTouchable = true
  obj.owner = owner
  obj.defaultParentNode = gmodule.moduleMgr:GetModule(ModuleId.MAP).mapPlayerNodeRoot
  obj:Init(id)
  return obj
end
def.override().OnClick = function(self)
  if self.owner then
    self.owner:OnClick()
  end
end
def.override("=>", "string").GetName = function(self)
  if self.owner then
    return self.owner:GetName()
  else
    return self.m_Name
  end
end
return ECAirCraft.Commit()
