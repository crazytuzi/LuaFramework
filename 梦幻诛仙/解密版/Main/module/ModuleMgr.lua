local Lplus = require("Lplus")
local ModuleMgr = Lplus.Class("ModuleMgr")
local ModuleBase = require("Main.module.ModuleBase")
local def = ModuleMgr.define
local instance
def.field("table").modules = nil
def.static("=>", ModuleMgr).Instance = function()
  if instance == nil then
    instance = ModuleMgr()
    instance.modules = {}
  end
  return instance
end
def.method("number", "string").RegisterModule = function(self, moduleId, moduleName)
  self.modules[moduleId] = {id = moduleId, name = moduleName}
end
def.method("number", "=>", ModuleBase).GetModule = function(self, moduleId)
  local moduleData = self.modules[moduleId]
  if moduleData == nil then
    warn("unregistered module for id: ", moduleId)
    return nil
  end
  if moduleData.obj == nil then
    moduleData.obj = require(moduleData.name).Instance()
    moduleData.obj.m_moduleId = moduleId
    moduleData.obj:Init()
  end
  return moduleData.obj
end
def.method().InitAllModules = function(self)
  for k, m in pairs(self.modules) do
    self:GetModule(k)
  end
end
def.method().LateInitAllModules = function(self)
  for _, m in pairs(self.modules) do
    if m.obj then
      m.obj:LateInit()
    end
  end
end
ModuleMgr.Commit()
return ModuleMgr
