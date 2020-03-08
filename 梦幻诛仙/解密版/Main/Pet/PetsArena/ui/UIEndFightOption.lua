local FILE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIEndFightOption = Lplus.Extend(ECPanelBase, FILE_NAME)
local Cls = UIEndFightOption
local def = Cls.define
local instance
def.field("table")._uiGOs = nil
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = Cls()
  end
  return instance
end
def.method().initUI = function(self)
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.PET, gmodule.notifyId.Pet.GET_PET_STASTIC_OK, Cls.OnGetStasticOK, self)
  Event.RegisterEventWithContext(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_PET_BATTLE, Cls.OnEnterPetFight, self)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.GET_PET_STASTIC_OK, Cls.OnGetStasticOK)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_PET_BATTLE, Cls.OnEnterPetFight)
end
def.override("boolean").OnShow = function(self, bShow)
end
def.method("userdata").ShowPanel = function(self, recordId)
  if self:IsShow() then
    return
  end
  if recordId == nil then
    return
  end
  self._uiGOs = {}
  self._uiGOs.recordId = recordId
  self:CreatePanel(RESPATH.PREFAB_ENDFIGHT_OPTION, 1)
  self:SetModal(true)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if "Img_Bg01" == id then
    self:onClickWatchAgain()
  elseif "Img_Bg02" == id then
    self:onClickFightStastic()
  elseif "Img_Bg03" == id then
    self:onClickQuitReplay()
  elseif "Img_Close" == id then
    self:onClickQuitReplay()
  end
end
local PetsArenaMgr = require("Main.Pet.PetsArena.PetsArenaMgr")
def.method().onClickWatchAgain = function(self)
  PetsArenaMgr.GetProtocol().CSendWatchVideoReq(self._uiGOs.recordId)
end
def.method().onClickFightStastic = function(self)
  PetsArenaMgr.GetProtocol().CGetFightDataReq(self._uiGOs.recordId)
end
def.method().onClickQuitReplay = function(self)
  self:DestroyPanel()
end
def.method("table").OnGetStasticOK = function(self, p)
  require("Main.Pet.PetsArena.ui.UIPetsFightStastic").Instance():ShowPanel({
    p.passive_infos,
    p.passive_name
  }, {
    p.active_infos,
    p.active_name
  })
end
def.method("table").OnEnterPetFight = function(self, p)
  self:DestroyPanel()
end
return Cls.Commit()
