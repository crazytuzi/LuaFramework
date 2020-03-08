local Lplus = require("Lplus")
local RankUnitInfoMgr = Lplus.Class("RankUnitInfoMgr")
local RankListModule = Lplus.ForwardDeclare("RankListModule")
local PubroleModule = require("Main.Pubrole.PubroleModule")
local RoleOperateHelper = require("Main.Common.RoleOperateHelper")
local PetInfoPanel = require("Main.Pet.ui.PetInfoPanel")
local def = RankUnitInfoMgr.define
local instance
def.static("=>", RankUnitInfoMgr).Instance = function()
  if instance == nil then
    instance = RankUnitInfoMgr()
  end
  return instance
end
def.method("userdata").ShowRoleInfo = function(self, roleId)
  local function onRecivedRoleInfo(roleInfo)
    RoleOperateHelper.ShowRoleOPPanel(roleInfo)
  end
  PubroleModule.Instance():ReqRoleInfo(roleId, onRecivedRoleInfo)
end
def.method("userdata", "userdata").ShowPetInfo = function(self, roleId, petId)
  local PetModule = require("Main.Pet.PetModule")
  local function onRecivedPetInfo(petInfo)
    PetInfoPanel.Instance():ShowPanelByPetInfo(petInfo)
  end
  PetModule.Instance():ReqPetInfo(roleId, petId, onRecivedPetInfo)
end
def.method("userdata").ShowChildInfo = function(self, childId)
  local ChildrenInterface = require("Main.Children.ChildrenInterface")
  ChildrenInterface.RequestChildInfo(childId)
end
return RankUnitInfoMgr.Commit()
