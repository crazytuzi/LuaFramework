local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local NPCShopModule = Lplus.Extend(ModuleBase, "NPCShopModule")
local NPCServiceConst = require("Main.npc.NPCServiceConst")
local NPCShopDlg = require("Main.Shop.NpcShop.ui.NPCShopDlg")
local NPCTradeData = require("Main.Shop.NpcShop.NPCTradeData")
local TaskInterface = require("Main.task.TaskInterface")
require("Main.module.ModuleId")
local def = NPCShopModule.define
local instance
def.field(NPCShopDlg)._dlg = nil
def.field("table")._taskRequirements = nil
def.field("boolean")._bHaveRequire = false
def.field("number")._serviceId = 0
def.field("number")._npcId = 0
def.field("table")._curRequirementByTask = nil
def.field("table").requirementsCondTbl = nil
def.field("boolean")._bWaitToShow = false
def.const("number").SERVICEID_CAOYAO = 150200001
def.static("=>", NPCShopModule).Instance = function()
  if nil == instance then
    instance = NPCShopModule()
    instance._dlg = NPCShopDlg.Instance()
    instance._taskRequirements = {}
    instance._curRequirementByTask = {}
    instance.requirementsCondTbl = {}
    instance.m_moduleId = ModuleId.NPC_STORE
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_TRADE, NPCShopModule.OnNPCService)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE_WITH_REQUIREMENT, NPCShopModule.OnNPCServiceByTask)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_InfoChanged, NPCShopModule.OnTaskInfoChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, NPCShopModule.OnBagInfoSyncronized)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, NPCShopModule.OnitemMoneySilverChanged)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.npc.STipRes", NPCShopModule.STipRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SSiftItemRes", NPCShopModule.SSiftItemRes)
  ModuleBase.Init(self)
end
def.method().RefeshShopItemRequirements = function(self)
  local taskInterfaceInstance = TaskInterface.Instance()
  local Requirements = taskInterfaceInstance:GetTaskRequirements()
  local itemCount = 0
  local conCount = 0
  for taskId, graphIdRequiremnt in pairs(Requirements) do
    for graphId, requiremnt in pairs(graphIdRequiremnt) do
      if nil ~= self._taskRequirements[requiremnt.requirementID] then
        self._taskRequirements[requiremnt.requirementID] = self._taskRequirements[requiremnt.requirementID] + requiremnt.needCount
      else
        itemCount = itemCount + 1
        self._taskRequirements[requiremnt.requirementID] = requiremnt.needCount
      end
    end
  end
  for k, v in pairs(self.requirementsCondTbl) do
    v.needNum = 0
  end
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  local activityAllRequirements = activityInterface:GetActivityAllRequirements()
  for requirementID, requiremnt in pairs(activityAllRequirements) do
    if false == require("Main.Shop.NpcShop.NPCShopUtils").IsItemId(requirementID) then
      if nil ~= self.requirementsCondTbl[requirementID] then
        self.requirementsCondTbl[requirementID].needNum = self.requirementsCondTbl[requirementID].needNum + requiremnt.needCount
      else
        conCount = conCount + 1
        self._bWaitToShow = true
        self.requirementsCondTbl[requirementID] = {}
        self.requirementsCondTbl[requirementID].needNum = requiremnt.needCount
        self.requirementsCondTbl[requirementID].itemList = {}
        self.requirementsCondTbl[requirementID].inited = false
      end
    elseif nil ~= self._taskRequirements[requirementID] then
      self._taskRequirements[requirementID] = self._taskRequirements[requirementID] + requiremnt.needCount
    else
      itemCount = itemCount + 1
      self._taskRequirements[requirementID] = requiremnt.needCount
    end
  end
  if itemCount > 0 or conCount > 0 then
    self._bHaveRequire = true
  else
    self._bHaveRequire = false
  end
  for k, v in pairs(self._curRequirementByTask) do
    if self._taskRequirements[k] then
      self._curRequirementByTask[k] = self._taskRequirements[k]
    end
  end
  if not self._bWaitToShow then
    self:FillConditionItemIdToTask()
  end
end
def.method("number", "number").SetCurRequirementByTask = function(self, RequirementID, NeedCount)
  self._curRequirementByTask[RequirementID] = NeedCount
end
def.method("=>", "table").GetTaskRequirements = function(self)
  return self._taskRequirements
end
def.method("=>", "boolean").GetIsHaveRequire = function(self)
  return self._bHaveRequire
end
def.method("=>", "table").GetCurRequirementByTask = function(self)
  return self._curRequirementByTask
end
def.method("=>", "number").GetServiceId = function(self)
  return self._serviceId
end
def.method("=>", "number").GetNpcId = function(self)
  return self._npcId
end
def.method("number").UpdateCurRequirementsByTask = function(self, requirementID)
  if nil ~= self._curRequirementByTask[requirementID] then
    table.remove(self._curRequirementByTask, requirementID)
    self._curRequirementByTask[requirementID] = nil
  end
end
def.method("=>", "boolean").IsCurRequirementsByTaskOver = function(self)
  for k, v in pairs(self._curRequirementByTask) do
    if nil ~= v then
      return false
    end
  end
  return true
end
def.method("number").RemoveRequirement = function(self, requirementID)
  if nil ~= self._taskRequirements[requirementID] then
    table.remove(self._taskRequirements, requirementID)
    self._taskRequirements[requirementID] = nil
  end
end
def.method().UpdateRequirement = function(self)
  local count = 0
  for k, v in pairs(self._taskRequirements) do
    if nil ~= v then
      count = count + 1
    end
  end
  if 0 == count then
    self._bHaveRequire = false
  else
    self._bHaveRequire = true
  end
end
def.method().RequireRequirements = function(self)
  for k, v in pairs(self.requirementsCondTbl) do
    local p = require("netio.protocol.mzm.gsp.item.CSiftItemBySiftCfgReq").new(k)
    gmodule.network.sendProtocol(p)
  end
end
def.method().FillConditionItemIdToTask = function(self)
  for k, v in pairs(self.requirementsCondTbl) do
    local needNum = v.needNum
    if needNum > 0 then
      for _, itemId in ipairs(v.itemList) do
        if nil ~= self._taskRequirements[itemId] then
          self._taskRequirements[itemId] = self._taskRequirements[itemId] + needNum
        else
          self._taskRequirements[itemId] = needNum
        end
      end
    end
  end
end
def.method("number", "table").FillConditionItemId = function(self, siftId, list)
  if self._bWaitToShow then
    if nil ~= self.requirementsCondTbl[siftId] then
      local needNum = self.requirementsCondTbl[siftId].needNum
      self.requirementsCondTbl[siftId].itemList = {}
      for k, v in pairs(list) do
        table.insert(self.requirementsCondTbl[siftId].itemList, v)
      end
      self.requirementsCondTbl[siftId].inited = true
      for k, v in pairs(self.requirementsCondTbl[siftId].itemList) do
        if nil ~= self._taskRequirements[v] then
          self._taskRequirements[v] = self._taskRequirements[v] + needNum
        else
          self._taskRequirements[v] = needNum
        end
      end
    end
    local bAllInited = true
    for k, v in pairs(self.requirementsCondTbl) do
      if not v.inited then
        bAllInited = false
        break
      end
    end
    if bAllInited then
      self._dlg:CreatePanel(RESPATH.PREFAB_NPC_SHOP_PANEL, 1)
      self._bWaitToShow = false
    end
  end
end
def.static("table", "table").OnNPCService = function(tbl, p2)
  local serviceID = tbl[1]
  local NPCID = tbl[2]
  if false == NPCTradeData.IsNPCShopId(serviceID) then
    return
  end
  instance._serviceId = serviceID
  instance._npcId = NPCID
  instance._taskRequirements = {}
  instance._curRequirementByTask = {}
  instance:RefeshShopItemRequirements()
  instance._dlg._bIsByTask = false
  if instance._dlg.m_panel == nil then
    if instance._bWaitToShow == false then
      instance._dlg:CreatePanel(RESPATH.PREFAB_NPC_SHOP_PANEL, 1)
    else
      instance:RequireRequirements()
    end
  end
end
def.static("table", "table").OnNPCServiceByTask = function(tbl, p2)
  local serviceID = tbl[1]
  local NPCID = tbl[2]
  if false == NPCTradeData.IsNPCShopId(serviceID) then
    return
  end
  local RequirementID = tbl[3]
  local NeedCount = tbl[4]
  instance._serviceId = serviceID
  instance._npcId = NPCID
  instance._taskRequirements = {}
  instance._curRequirementByTask = {}
  instance:SetCurRequirementByTask(RequirementID, NeedCount)
  instance:RefeshShopItemRequirements()
  instance._dlg._bIsByTask = true
  if instance._dlg.m_panel == nil then
    if instance._bWaitToShow == false then
      instance._dlg:CreatePanel(RESPATH.PREFAB_NPC_SHOP_PANEL, 1)
    else
      instance:RequireRequirements()
    end
  end
end
def.static("table", "table").OnTaskInfoChanged = function(p1, p2)
end
def.static("table").STipRes = function(p)
  local STipRes = require("netio.protocol.mzm.gsp.npc.STipRes")
  if p.ret == STipRes.SUCCESS then
    local itemBase = require("Main.Item.ItemUtils").GetItemBase(p.itemid)
    local itemMoney = require("Main.Shop.NpcShop.NPCShopUtils").GetItemSellNum(p.itemid)
    local namenum = string.format("%sx%d", itemBase.name, p.count)
    local money = itemMoney * p.count
    local PersonalHelper = require("Main.Chat.PersonalHelper")
    PersonalHelper.CommonMsg(PersonalHelper.Type.ColorText, textRes.Common[44], "ffffff", PersonalHelper.Type.ColorText, namenum, "ffff00", PersonalHelper.Type.ColorText, textRes.Common.comma .. textRes.Common[45], "ffffff", PersonalHelper.Type.Silver, money)
  elseif textRes.NPCStore.WrongResult[p.ret] ~= nil then
    Toast(textRes.NPCStore.WrongResult[p.ret])
  end
end
def.static("table").SSiftItemRes = function(p)
  if instance._dlg then
    instance:FillConditionItemId(p.siftCfgid, p.itemList)
  end
end
def.static("table", "table").OnBagInfoSyncronized = function(p1, p2)
  if instance._dlg and instance._dlg.m_panel then
    instance._dlg:SuccessedBuyItem()
  end
end
def.static("table", "table").OnitemMoneySilverChanged = function(p1, p2)
  if instance._dlg and instance._dlg.m_panel then
    instance._dlg:UpdateHaveAndNeedSilver()
  end
end
NPCShopModule.Commit()
return NPCShopModule
