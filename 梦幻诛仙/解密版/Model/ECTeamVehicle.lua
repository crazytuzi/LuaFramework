local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECPlayer = require("Model.ECPlayer")
local ECTeamVehicle = Lplus.Extend(ECPlayer, "ECTeamVehicle")
local def = ECTeamVehicle.define
def.virtual("number", "number", "number").Create = function(self, x, y, dir)
end
def.virtual(ECPlayer, "number").AttachMember = function(self, role, index)
end
def.virtual("number").RemoveMember = function(self, index)
end
def.virtual().RemoveAllMember = function(self)
end
def.virtual("number", "=>", "table").GetMember = function(self, index)
  return nil
end
def.virtual("=>", "number").GetMemberCount = function(self)
  return 0
end
def.virtual("table", "=>", "number").GetMemberIndex = function(self, role)
  return 0
end
return ECTeamVehicle.Commit()
