local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local FlipCardAwardData = Lplus.Class(CUR_CLASS_NAME)
local def = FlipCardAwardData.define
def.field("userdata").awardUUID = nil
def.field("table").roles = nil
def.field("table").awarded = nil
def.field("table").notAwardRoles = nil
def.static("=>", FlipCardAwardData).new = function()
  local instance = FlipCardAwardData()
  instance:ctor()
  return instance
end
def.method().ctor = function(self)
  self.awarded = {}
  self.notAwardRoles = {}
end
return FlipCardAwardData.Commit()
