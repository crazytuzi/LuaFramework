local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local GiveModule = Lplus.Extend(ModuleBase, "GiveModule")
local GiveDlg = require("Main.Give.ui.GiveDlg")
require("Main.module.ModuleId")
local def = GiveModule.define
local instance
def.field(GiveDlg)._dlg = nil
def.field("boolean").bIsGive = false
def.static("=>", GiveModule).Instance = function()
  if nil == instance then
    instance = GiveModule()
    instance._dlg = GiveDlg.Instance()
    instance.m_moduleId = ModuleId.GIVE
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_GiveItem, GiveModule.ShowGiveItem)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_GivePet, GiveModule.ShowGivePet)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SSiftItemRes", GiveModule.SSiftItemRes)
  ModuleBase.Init(self)
end
def.static("table").SSiftItemRes = function(p)
  if false == instance.bIsGive then
    return
  end
  if nil ~= p.itemList then
    instance._dlg:PrepareItems(p.itemList)
    instance._dlg:SetModal(true)
    instance._dlg:CreatePanel(RESPATH.PREFAB_GIVE_ITEM, 1)
  else
    Toast(textRes.Give[5])
  end
  instance.bIsGive = false
end
def.static("table", "table").ShowGiveItem = function(tbl, p2)
  local siftId = tbl[1]
  GiveDlg.ShowGiveItemDlg(siftId)
  instance.bIsGive = true
end
def.static("table", "table").ShowGivePet = function(tbl, p2)
  local petId = tbl[1]
  instance._dlg:PreparePets(petId)
  instance._dlg:SetModal(true)
  instance._dlg:CreatePanel(RESPATH.PREFAB_GIVE_PET, 1)
end
GiveModule.Commit()
return GiveModule
