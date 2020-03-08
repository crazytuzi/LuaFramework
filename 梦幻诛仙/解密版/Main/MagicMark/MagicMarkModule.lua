local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local MagicMarkModule = Lplus.Extend(ModuleBase, "MagicMarkModule")
require("Main.module.ModuleId")
local def = MagicMarkModule.define
local instance
def.field("table").owned = nil
def.field("number").currentMagicMarkId = 0
def.field("number").enabledMagicMarkId = 0
def.field("boolean").enabled = false
def.static("=>", MagicMarkModule).Instance = function()
  if instance == nil then
    instance = MagicMarkModule()
    instance.m_moduleId = ModuleId.MAGIC_MARK
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.magicmark.SSyncMagicMarkInfo", MagicMarkModule.OnSSyncMagicMarkInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.magicmark.SUnLockMagicMarkRes", MagicMarkModule.OnSUnLockMagicMarkRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.magicmark.SEquipMagicMarkRes", MagicMarkModule.OnSEquipMagicMarkRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.magicmark.SUnEuquipMagicMarkRes", MagicMarkModule.OnSUnEuquipMagicMarkRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.magicmark.SMagicMarkExpired", MagicMarkModule.OnSMagicMarkExpired)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.magicmark.SMagicMarkSelectPropRes", MagicMarkModule.OnSMagicMarkSelectPropRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.magicmark.SMagicMarkUnSelectPropRes", MagicMarkModule.OnSMagicMarkUnSelectPropRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.magicmark.SExtendMagicMarkTimeRes", MagicMarkModule.OnSExtendMagicMarkTimeRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.magicmark.SExtendMagicMarkTimeErrorRes", MagicMarkModule.OnSExtendMagicMarkTimeErrorRes)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, MagicMarkModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, MagicMarkModule.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, MagicMarkModule.OnFeatureOpenInit)
end
def.static("table", "table").OnLeaveWorld = function()
  instance.owned = nil
  instance.currentMagicMarkId = 0
  instance.enabledMagicMarkId = 0
end
def.static("table").OnSSyncMagicMarkInfo = function(p)
  local curTime = _G.GetServerTime()
  instance.currentMagicMarkId = p.dressedMagicMarkType
  instance.owned = {}
  instance.enabledMagicMarkId = p.effectPropMagicType
  for k, v in pairs(p.magicMarkInfoMap) do
    instance.owned[k] = v / 1000 - curTime
  end
end
def.static("table").OnSUnLockMagicMarkRes = function(p)
  if p.ret == p.SUCCESS then
    Toast(textRes.MagicMark[23])
    if instance.owned == nil then
      instance.owned = {}
    end
    instance.owned[p.magicMarkType] = p.expiredTime / 1000 - _G.GetServerTime()
    Event.DispatchEvent(ModuleId.MAGIC_MARK, gmodule.notifyId.MagicMark.MAGIC_MARK_UNLOCKED, nil)
  elseif p.ret == p.ERROR_ITEM_NOT_ENOUGH then
    Toast(textRes.MagicMark[1])
  elseif p.ret == p.ERROR_ITEM_MAGIC_MARK_TYPE_NOT_SAME then
    Toast(textRes.MagicMark[2])
  elseif p.ret == p.ERROR_DO_NOT_NEED_UNLOCK then
    Toast(textRes.MagicMark[3])
  elseif p.ret == p.ERROR_ROLE_LEVEL_NOT_ENOUGH then
    Toast(textRes.MagicMark[4])
  end
end
def.static("table").OnSEquipMagicMarkRes = function(p)
  if p.ret == p.SUCCESS then
    instance.currentMagicMarkId = p.magicMarkType
    Toast(textRes.MagicMark[16])
    Event.DispatchEvent(ModuleId.MAGIC_MARK, gmodule.notifyId.MagicMark.MAGIC_MARK_CHANGED, nil)
  elseif p.ret == p.ERROR_MAGIC_MARK_LOCKED then
    Toast(textRes.MagicMark[5])
  elseif p.ret == p.ERROR_ROLE_LEVEL_NOT_ENOUGH then
    Toast(textRes.MagicMark[4])
  end
end
def.static("table").OnSUnEuquipMagicMarkRes = function(p)
  if p.ret == p.SUCCESS then
    instance.currentMagicMarkId = 0
    Toast(textRes.MagicMark[17])
    Event.DispatchEvent(ModuleId.MAGIC_MARK, gmodule.notifyId.MagicMark.MAGIC_MARK_CHANGED, nil)
  elseif p.ret == p.ERROR_NOT_EQUIP then
    Toast(textRes.MagicMark[6])
  elseif p.ret == p.ERROR_ROLE_LEVEL_NOT_ENOUGH then
    Toast(textRes.MagicMark[4])
  end
end
def.static("table").OnSMagicMarkSelectPropRes = function(p)
  if p.ret == p.SUCCESS then
    instance.enabledMagicMarkId = p.magicMarkType
  elseif p.ret == p.ERROR_LOCKED then
    Toast(textRes.MagicMark[5])
  elseif p.ret == p.ERROR_ROLE_LEVEL_NOT_ENOUGH then
    Toast(textRes.MagicMark[4])
  end
end
def.static("table").OnSMagicMarkUnSelectPropRes = function(p)
  if p.ret == p.SUCCESS then
    instance.enabledMagicMarkId = 0
  elseif p.ret == p.ERROR_NOT_SELECT then
    Toast(textRes.MagicMark[7])
  elseif p.ret == p.ERROR_ROLE_LEVEL_NOT_ENOUGH then
    Toast(textRes.MagicMark[4])
  end
end
def.static("table").OnSMagicMarkExpired = function(p)
  if instance.owned then
    instance.owned[p.magicMarkType] = nil
  end
  if instance.currentMagicMarkId == p.magicMarkType then
    instance.currentMagicMarkId = 0
  end
  if instance.enabledMagicMarkId == p.magicMarkType then
    instance.enabledMagicMarkId = 0
  end
  Event.DispatchEvent(ModuleId.MAGIC_MARK, gmodule.notifyId.MagicMark.MAGIC_MARK_EXPIRED, {
    magicMarkType = p.magicMarkType
  })
end
def.static("table").OnSExtendMagicMarkTimeRes = function(p)
  if instance.owned == nil then
    return
  end
  if p.expiredTime:lt(0) then
    instance.owned[p.magicMarkType] = p.expiredTime
  else
    instance.owned[p.magicMarkType] = p.expiredTime / 1000 - _G.GetServerTime()
  end
  Toast(textRes.MagicMark[19])
  Event.DispatchEvent(ModuleId.MAGIC_MARK, gmodule.notifyId.MagicMark.MAGIC_MARK_CHANGED, nil)
end
def.static("table").OnSExtendMagicMarkTimeErrorRes = function(p)
  local str
  if p.ret == p.ERROR_ITEM_MAGIC_MARK_TYPE_NOT_SAME then
    str = textRes.MagicMark[11]
  elseif p.ret == p.ERROR_ITEM_NOT_ENOUGH then
    str = textRes.MagicMark[12]
  elseif p.ret == p.ERROR_ROLE_LEVEL_NOT_ENOUGH then
    str = textRes.MagicMark[4]
  elseif p.ret == p.ERROR_DO_NOT_NEED_EXTEND then
    str = textRes.MagicMark[13]
  end
  if str then
    Toast(str)
  end
end
def.method("number", "=>", "boolean").hasMagicMark = function(self, markType)
  return self.owned ~= nil and self.owned[markType] ~= nil and not self.owned[markType]:eq(0)
end
def.method("=>", "table").GetAllMagicMarkItemCfg = function(self)
  local items = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_MAGIC_MARK_TYPE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local IDIPInterface = require("Main.IDIP.IDIPInterface")
  local ItemSwitchInfo = require("netio.protocol.mzm.gsp.idip.ItemSwitchInfo")
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    local magicMarkTypeId = DynamicRecord.GetIntValue(entry, "magicMarkType")
    local bOpen = IDIPInterface.IsItemIDIPOpen(ItemSwitchInfo.MAGIC_MARK, magicMarkTypeId)
    if bOpen then
      local item = {}
      item.magicMarkType = magicMarkTypeId
      item.name = DynamicRecord.GetStringValue(entry, "name")
      item.desc = DynamicRecord.GetStringValue(entry, "desc")
      item.modelId = DynamicRecord.GetIntValue(entry, "modelId")
      item.iconId = DynamicRecord.GetIntValue(entry, "iconId")
      item.howToGet = DynamicRecord.GetStringValue(entry, "howToGet")
      item.properties = {}
      local propertyStruct = entry:GetStructValue("propertyStruct")
      local size = propertyStruct:GetVectorSize("propertyList")
      for j = 0, size - 1 do
        local pro_record = propertyStruct:GetVectorValueByIdx("propertyList", j)
        local skill = pro_record:GetIntValue("skill")
        table.insert(item.properties, skill)
      end
      item.effectSkills = {}
      local effectStruct = entry:GetStructValue("effectStruct")
      size = effectStruct:GetVectorSize("effectList")
      for j = 0, size - 1 do
        local pro_record = effectStruct:GetVectorValueByIdx("effectList", j)
        local effectskill = pro_record:GetIntValue("effectskill")
        table.insert(item.effectSkills, effectskill)
      end
      table.insert(items, item)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return items
end
def.method("number", "=>", "table").GetMagicMarkTypeCfg = function(self, markType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MAGIC_MARK_TYPE_CFG, markType)
  if record == nil then
    warn("[GetMagicMarkItemCfg]record is nil for id: ", markType)
    return
  end
  local item = {}
  item.magicMarkType = DynamicRecord.GetIntValue(record, "magicMarkType")
  item.name = DynamicRecord.GetStringValue(record, "name")
  item.desc = DynamicRecord.GetStringValue(record, "desc")
  item.modelId = DynamicRecord.GetIntValue(record, "modelId")
  item.iconId = DynamicRecord.GetIntValue(record, "iconId")
  item.howToGet = DynamicRecord.GetStringValue(record, "howToGet")
  item.properties = {}
  local propertyStruct = record:GetStructValue("propertyStruct")
  local size = propertyStruct:GetVectorSize("propertyList")
  for i = 0, size - 1 do
    local pro_record = propertyStruct:GetVectorValueByIdx("propertyList", i)
    local skill = pro_record:GetIntValue("skill")
    table.insert(item.properties, skill)
  end
  item.effectSkills = {}
  local effectStruct = record:GetStructValue("effectStruct")
  size = effectStruct:GetVectorSize("effectList")
  for i = 0, size - 1 do
    local pro_record = effectStruct:GetVectorValueByIdx("effectList", i)
    local effectskill = pro_record:GetIntValue("effectskill")
    table.insert(item.effectSkills, effectskill)
  end
  return item
end
def.method("number", "=>", "table").GetMagicMarkItemCfg = function(self, itemCfgId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MAGIC_MARK_ITEM_CFG, itemCfgId)
  if record == nil then
    warn("[GetMagicMarkItemCfg]record is nil for id: ", itemCfgId)
    return nil
  end
  local item = {}
  item.id = DynamicRecord.GetIntValue(record, "id")
  item.magicType = DynamicRecord.GetIntValue(record, "magicType")
  item.lastHour = DynamicRecord.GetIntValue(record, "lastHour")
  return item
end
def.method("number").SetMagicMark = function(self, markId)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.magicmark.CEquipMagicMarkReq").new(markId))
end
def.method("number").RemoveMagicMark = function(self, markId)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.magicmark.CUnEuquipMagicMarkReq").new(markId))
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if p1 and p1.feature == Feature.TYPE_MAGIC_MARK then
    instance.enabled = p1.open
    require("Main.MagicMark.ui.DlgMagicMarkUnlock").Instance():DestroyPanel()
    require("Main.MagicMark.ui.MagicMarkPropPanel").Instance():DestroyPanel()
    Event.DispatchEvent(ModuleId.MAGIC_MARK, gmodule.notifyId.MagicMark.MAGIC_MARK_ENABLE_CHANGE, nil)
  end
end
def.static("table", "table").OnFeatureOpenInit = function(p1, p2)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local isOpen = _G.IsFeatureOpen(Feature.TYPE_MAGIC_MARK)
  if isOpen then
    instance.enabled = isOpen
    Event.DispatchEvent(ModuleId.MAGIC_MARK, gmodule.notifyId.MagicMark.MAGIC_MARK_ENABLE_CHANGE, nil)
  end
end
MagicMarkModule.Commit()
return MagicMarkModule
