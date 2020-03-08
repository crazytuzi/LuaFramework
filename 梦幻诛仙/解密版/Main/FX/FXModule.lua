local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local FXModule = Lplus.Extend(ModuleBase, "FXModule")
local SystemSettingModule = Lplus.ForwardDeclare("SystemSettingModule")
local ECFxMan = Lplus.ForwardDeclare("ECFxMan")
local def = FXModule.define
def.field("table").ManagedFx = nil
local instance
def.static("=>", FXModule).Instance = function()
  if instance == nil then
    instance = FXModule()
    instance.m_moduleId = ModuleId.FX
    instance.ManagedFx = {}
    setmetatable(instance.ManagedFx, {__mode = "v"})
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.SYSTEM_SETTING, gmodule.notifyId.SystemSetting.SETTING_CHANGED, FXModule.OnSettingChanged)
end
def.override().LateInit = function(self)
  self:UpdateFXSetting()
end
def.method("=>", "boolean").IsHide = function(self)
  local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.LowFXNumbers)
  return setting.isEnabled
end
def.method("userdata").AddManagedFx = function(self, fx)
  local isHide = self:IsHide()
  local remove = {}
  for i = 1, #self.ManagedFx do
    local fx = self.ManagedFx[i]
    if fx == nil or fx.isnil or fx.name == "fx_del" then
      remove[i] = true
    else
    end
  end
  for i = #self.ManagedFx, 1, -1 do
    if remove[i] then
      table.remove(self.ManagedFx, i)
    end
  end
  if isHide then
    local fxone = fx:GetComponent("FxOne")
    fx:SetActive(false)
    fxone:Stop()
  end
  table.insert(self.ManagedFx, fx)
end
def.method().UpdateFXSetting = function(self)
  local isHide = self:IsHide()
  local remove = {}
  for i = 1, #self.ManagedFx do
    local fx = self.ManagedFx[i]
    if fx ~= nil and not fx.isnil and fx.name ~= "fx_del" then
      local fxone = fx:GetComponent("FxOne")
      if isHide then
        fx:SetActive(false)
        fxone:Stop()
      else
        fx:SetActive(true)
        fxone:PlayDo()
      end
    else
      remove[i] = true
    end
  end
  for i = #self.ManagedFx, 1, -1 do
    if remove[i] then
      table.remove(self.ManagedFx, i)
    end
  end
end
def.static("table", "table").OnSettingChanged = function(params)
  local id = params[1]
  if id == SystemSettingModule.SystemSetting.LowFXNumbers then
    FXModule.Instance():UpdateFXSetting()
  end
end
return FXModule.Commit()
