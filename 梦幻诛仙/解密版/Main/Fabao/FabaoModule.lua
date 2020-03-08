require("Main.module.ModuleId")
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local FabaoData = require("Main.Fabao.data.FabaoData")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local FabaoUtils = require("Main.Fabao.FabaoUtils")
local FabaoSocialPanel = require("Main.Fabao.ui.FabaoSocialPanel")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local FabaoModule = Lplus.Extend(ModuleBase, "FabaoModule")
local def = FabaoModule.define
def.field("table").m_NewFabaoMap = nil
local instance
def.static("=>", FabaoModule).Instance = function()
  if not instance then
    instance = FabaoModule()
    instance.m_moduleId = ModuleId.FABAO
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  require("Main.Fabao.LJTransformMgr").Instance():Init()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SSynFabaoInfo", FabaoModule.OnSSynFabaoInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SSynFaBaoChangeInfo", FabaoModule.OnSSynFabaoChangeInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SSynLongJingChangeInfo", FabaoModule.OnSSynLongJingChangeInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SEquipFabaoErrorRes", FabaoModule.OnSEquipFabaoErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SUnEquipFabaoErrorRes", FabaoModule.OnSUnEquipFabaoErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SChangeDisPlayFabaoRes", FabaoModule.OnSChangeDisPlayFabaoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SChangeDisPlayFabaoErrorRes", FabaoModule.OnSChangeDisPlayFabaoErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFabaoComposeSuccessRes", FabaoModule.OnSFabaoComposeSuccessRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFabaoComposeRes", FabaoModule.OnSFabaoComposeRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFabaoLevelUp", FabaoModule.OnSFabaoLevelUp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFabaoExpTipRes", FabaoModule.OnSFabaoExpTipRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFabaoAddExpRes", FabaoModule.OnSFabaoAddExpRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFabaoWashSucRes", FabaoModule.OnSFabaoWashSucRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFabaoWashErrorRes", FabaoModule.OnSFabaoWashErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFabaoReplaceWashSkillRes", FabaoModule.OnSFabaoReplaceWashSkillRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFabaReplaceWashSkillErrorRes", FabaoModule.OnSFabaReplaceWashSkillErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFabaoUpRankSucRes", FabaoModule.OnSFabaoUpRankSucRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFabaoUpRankErrorRes", FabaoModule.OnSFabaoUpRankErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFabaoAddRankScoreRes", FabaoModule.OnSFabaoAddRankScoreRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFabaoAddRankScoreErrorRes", FabaoModule.OnSFabaoAddRankScoreErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SChoiceRankSkillRes", FabaoModule.OnSChoiceRankSkillRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SChoiceRankSkillErrorRes", FabaoModule.OnSChoiceRankSkillErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SLongjingMountSucRes", FabaoModule.OnSLongjingMountSucRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SLongjingMountErrorRes", FabaoModule.OnSLongjingMountErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SLongjingUnMountSucRes", FabaoModule.OnSLongjingUnMountSucRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SLongjingUnMountErrorRes", FabaoModule.OnSLongjingUnMountErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SLongjingComposeSucRes", FabaoModule.OnSLongjingComposeSucRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SLongjingComposeErrorRes", FabaoModule.OnSLongjingComposeErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SLongjingUpLevelRes", FabaoModule.OnSLongjingUpLevelRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SLongjingUpLevelErrorRes", FabaoModule.OnSLongjingUpLevelErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SResItemYuanbaoPriceWithId", FabaoModule.OnYuanBaoPriceRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFaBaoAutoRankUpRes", FabaoModule.OnSFaBaoAutoRankUpRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFaBaoAutoRankUpErrorRes", FabaoModule.OnSFaBaoAutoRankUpErrorRes)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, function()
    self:InitNewMap()
  end)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_FABAO_CLICK, FabaoModule.OpenFabaoSocialPanel)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Get_NewOne, FabaoModule.OnGetNewItem)
end
def.override().OnReset = function(self)
  self:ClearNewMap()
  FabaoData.Instance():Clear()
end
def.method().InitNewMap = function(self)
  if nil == self.m_NewFabaoMap then
    self.m_NewFabaoMap = {}
  end
end
def.method().ClearNewMap = function(self)
  self.m_NewFabaoMap = nil
end
def.method("number", "boolean").SetFabaoNew = function(self, key, isNew)
  if nil == self.m_NewFabaoMap then
    self.m_NewFabaoMap = {}
  end
  self.m_NewFabaoMap[key] = isNew
end
def.method("number", "=>", "boolean").GetFabaoNew = function(self, key)
  if nil == self.m_NewFabaoMap then
    return false
  end
  if nil == self.m_NewFabaoMap[key] then
    return false
  end
  return self.m_NewFabaoMap[key]
end
def.method("number", "=>", "table").GetSpecialLongjingInBag = function(self, fabaoType)
  local allLongjing = self:GetAllLongjingInBag()
  local allLongjingOfType = allLongjing[fabaoType]
  if nil == allLongjingOfType then
    return nil
  end
  local specialLongjing = {}
  for k, v in pairs(allLongjingOfType) do
    local id = v.id
    local itemBase = ItemUtils.GetItemBase(id)
    local typeName = itemBase.itemTypeName
    if nil == specialLongjing[typeName] then
      specialLongjing[typeName] = {}
    end
    table.insert(specialLongjing[typeName], v)
  end
  return specialLongjing
end
def.method("=>", "table").GetAllLongjingInBag = function(self)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local allLongjing = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, ItemType.FABAO_LONGJING_ITEM)
  if nil == allLongjing then
    return nil
  end
  local longjing = {}
  for k, v in pairs(allLongjing) do
    local data = {}
    local longjingBase = ItemUtils.GetLongJingItem(v.id)
    local longjingItemBase = ItemUtils.GetItemBase(v.id)
    local longjingType = longjingBase.longjingType
    local longjingName = longjingItemBase.name
    local longjingIconId = longjingItemBase.icon
    local longjingProIds = longjingBase.attrIds
    local longjingProValues = longjingBase.attrValues
    data.id = v.id
    data.key = k
    data.number = v.number
    data.longjingType = longjingType
    data.longjingName = longjingName
    data.longjingIconId = longjingIconId
    data.longjingProIds = longjingProIds
    data.longjingProValues = longjingProValues
    data.longjingLevel = longjingBase.lv
    data.longjingNameColor = longjingItemBase.namecolor
    if nil == longjing[longjingType] then
      longjing[longjingType] = {}
    end
    table.insert(longjing[longjingType], data)
  end
  return longjing
end
def.method("number", "=>", "boolean").CanLevelUpOnLongjingType = function(self, longjingType)
  local allLongjing = FabaoData.Instance():GetAllLongJingData()
  if nil == allLongjing then
    return false
  end
  local longjingOnType = allLongjing[longjingType]
  if nil == longjingOnType then
    return false
  end
  for k, v in pairs(longjingOnType) do
    if v then
      local canLevelUp = self:CanLongJingLevelUp(v.id)
      if canLevelUp then
        return true
      end
    end
  end
  return false
end
def.method("number", "=>", "boolean").CanLongJingLevelUp = function(self, curLongjingId)
  local longjingId = curLongjingId
  local LongjingBase = ItemUtils.GetLongJingItem(curLongjingId)
  local needNextComposeNum = LongjingBase.complexNextCount
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  local longjingLv = LongjingBase.lv
  local levelLimit = math.floor(heroLevel / 10)
  if longjingLv >= levelLimit then
    return false
  end
  local nextLongjingId = LongjingBase.nextId
  if nil == nextLongjingId or 0 == nextLongjingId then
    return false
  end
  local preNum = 1
  local longjingNum = require("Main.Item.ItemModule").Instance():GetItemCountById(longjingId) + 1
  while true do
    if longjingNum >= preNum * needNextComposeNum then
      return true
    end
    preNum = preNum * needNextComposeNum - longjingNum
    local preLongjingId = FabaoUtils.GetPreLongJingItemId(longjingId)
    if 0 == preLongjingId then
      return false
    end
    longjingId = preLongjingId
    LongjingBase = ItemUtils.GetLongJingItem(longjingId)
    needNextComposeNum = LongjingBase.complexNextCount
    longjingNum = require("Main.Item.ItemModule").Instance():GetItemCountById(longjingId)
  end
end
def.method("=>", "table").GetAllFabao = function(self)
  local fabaoInWear = require("Main.Fabao.data.FabaoData").Instance():GetAllFabaoData()
  local all = {}
  if fabaoInWear then
    for k, v in pairs(fabaoInWear) do
      local fabao = {}
      local id = v.id
      local fabaoBase = ItemUtils.GetFabaoItem(id)
      local itemBase = ItemUtils.GetItemBase(id)
      fabao.id = id
      fabao.itemInfo = v
      fabao.key = -1
      fabao.equiped = true
      fabao.rank = fabaoBase.rank
      fabao.fabaoType = fabaoBase.fabaoType
      fabao.attrId = fabaoBase.attrId
      fabao.classId = fabaoBase.classId
      fabao.name = itemBase.name
      fabao.iconId = itemBase.icon
      fabao.namecolor = itemBase.namecolor
      fabao.useLevel = itemBase.useLevel
      table.insert(all, fabao)
    end
    table.sort(all, function(a, b)
      return a.rank > b.rank
    end)
  end
  local fabaoInBag = FabaoModule.Instance():GetAllFabaoInBagByType(0)
  if fabaoInBag then
    for k, v in pairs(fabaoInBag) do
      table.insert(all, v)
    end
  end
  return all
end
def.method("number", "number", "=>", "table").GetAllFabaoInBagByTypeAndRank = function(self, targetType, rank)
  local fabaoOnType = self:GetAllFabaoInBagByType(targetType)
  local allFabao = {}
  if fabaoOnType and #fabaoOnType > 0 then
    for k, v in pairs(fabaoOnType) do
      if v then
        if 0 == rank then
          table.insert(allFabao, v)
        elseif rank == v.rank then
          table.insert(allFabao, v)
        end
      end
    end
    return allFabao
  else
    return allFabao
  end
end
def.method("number", "=>", "table").GetAllFabaoInBagByType = function(self, targetType)
  warn("GetAllFabaoInBagByType  ~~~~ ", targetType)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local fabaosInBag = ItemModule.Instance():GetItemsByItemType(ItemModule.FABAOBAG, ItemType.FABAO_ITEM)
  local allFabao = {}
  local MathHelper = require("Common.MathHelper")
  local count = MathHelper.CountTable(fabaosInBag)
  warn("fabao count is ~~~ ", count)
  if 0 == count then
    return allFabao
  end
  for k, v in pairs(fabaosInBag) do
    local fabao = {}
    fabao.key = k
    fabao.itemInfo = v
    fabao.equiped = false
    local id = v.id
    local fabaoBase = ItemUtils.GetFabaoItem(id)
    local itemBase = ItemUtils.GetItemBase(id)
    fabao.id = id
    fabao.rank = fabaoBase.rank
    fabao.fabaoType = fabaoBase.fabaoType
    fabao.attrId = fabaoBase.attrId
    fabao.classId = fabaoBase.classId
    fabao.name = itemBase.name
    fabao.iconId = itemBase.icon
    fabao.namecolor = itemBase.namecolor
    fabao.useLevel = itemBase.useLevel
    if 0 == targetType then
      table.insert(allFabao, fabao)
    elseif fabao.fabaoType == targetType then
      table.insert(allFabao, fabao)
    end
  end
  table.sort(allFabao, function(a, b)
    return a.rank > b.rank
  end)
  return allFabao
end
def.method("number", "number", "=>", "table").GetAllThingInFabaoBagByTypeAndRank = function(self, targetType, rank)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local fabaosInBag = ItemModule.Instance():GetItemsByBagId(ItemModule.FABAOBAG)
  local allFabao = {}
  for k, v in pairs(fabaosInBag) do
    local id = v.id
    local itemBase = ItemUtils.GetItemBase(id)
    if itemBase.itemType == ItemType.FABAO_ITEM then
      local fabaoBase = ItemUtils.GetFabaoItem(id)
      local add = true
      if targetType ~= 0 and fabaoBase.fabaoType ~= targetType then
        add = false
      end
      if rank ~= 0 and fabaoBase.rank ~= rank then
        add = false
      end
      if add then
        local fabao = {}
        fabao.key = k
        fabao.id = id
        fabao.iconId = itemBase.icon
        fabao.namecolor = itemBase.namecolor
        fabao.sort = itemBase.sort
        fabao.type = ItemType.FABAO_ITEM
        fabao.rank = fabaoBase.rank
        fabao.fabaoType = fabaoBase.fabaoType
        fabao.num = v.number
        table.insert(allFabao, fabao)
      end
    elseif itemBase.itemType == ItemType.FABAO_FRAG_ITEM then
      local fabaoFragmentBase = ItemUtils.GetFabaoFragmentItem(id)
      local add = true
      if targetType ~= 0 and fabaoFragmentBase.fabaoType ~= targetType then
        add = false
      end
      if rank ~= 0 then
        add = false
      end
      if add then
        local fabao = {}
        fabao.key = k
        fabao.id = id
        fabao.iconId = itemBase.icon
        fabao.namecolor = itemBase.namecolor
        fabao.sort = itemBase.sort
        fabao.type = ItemType.FABAO_FRAG_ITEM
        fabao.rank = 0
        fabao.fabaoType = fabaoFragmentBase.fabaoType
        fabao.num = v.number
        table.insert(allFabao, fabao)
      end
    end
  end
  table.sort(allFabao, function(a, b)
    if a.type > b.type then
      return true
    elseif a.type < b.type then
      return false
    elseif a.sort < b.sort then
      return true
    elseif a.sort > b.sort then
      return false
    else
      return a.id < b.id
    end
  end)
  return allFabao
end
def.method("=>", "boolean").CheckMainUIRedNotice = function(self)
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  local fabaoOpenLevel = FabaoUtils.GetFabaoConstValue("FABAO_OPEN_LEVEL") or 60
  local isMatchLevel = heroLevel >= fabaoOpenLevel
  local hasRedNotice = self:CheckFabaoRedNotice()
  return hasRedNotice and isMatchLevel
end
def.method("=>", "boolean").CheckFabaoRedNotice = function(self)
  local czRedNotice = self:CheckCZRedNotice()
  local xqRedNotice = self:CheckXQRedNotice()
  return czRedNotice or xqRedNotice
end
def.method("number", "=>", "boolean").CheckBagFabaoCZRedNotice = function(self, key)
  local fabaoData = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.FABAOBAG, key)
  if fabaoData then
    local rankRandomSkillId = fabaoData.extraMap[ItemXStoreType.FABAO_RANK_RANDOM_SKILL_ID]
    if rankRandomSkillId and 0 ~= rankRandomSkillId then
      return true
    else
      return false
    end
  else
    return false
  end
end
def.method("number", "=>", "boolean").CheckEquipFabaoCZRedNotice = function(self, fabaoType)
  local fabaoData = FabaoData.Instance():GetFabaoByType(fabaoType)
  if fabaoData then
    local rankRandomSkillId = fabaoData.extraMap[ItemXStoreType.FABAO_RANK_RANDOM_SKILL_ID]
    if rankRandomSkillId and 0 ~= rankRandomSkillId then
      return true
    else
      return false
    end
  else
    return false
  end
end
def.method("table", "=>", "boolean").IsFabaoRed = function(self, fabaoData)
  if fabaoData then
    local rankRandomSkillId = fabaoData.extraMap[ItemXStoreType.FABAO_RANK_RANDOM_SKILL_ID]
    if rankRandomSkillId and 0 ~= rankRandomSkillId then
      return true
    else
      return false
    end
  else
    return false
  end
end
def.method("=>", "boolean").CheckCZRedNotice = function(self)
  local allFabaoInWear = FabaoData.Instance():GetAllFabaoData()
  local allFabaosInBag = ItemModule.Instance():GetItemsByItemType(ItemModule.FABAOBAG, ItemType.FABAO_ITEM)
  if nil == allFabaoInWear and nil == allFabaosInBag then
    return false
  end
  if allFabaoInWear then
    for k, v in pairs(allFabaoInWear) do
      if v then
        local rankRandomSkillId = v.extraMap[ItemXStoreType.FABAO_RANK_RANDOM_SKILL_ID]
        if rankRandomSkillId and 0 ~= rankRandomSkillId then
          return true
        end
      end
    end
  end
  if allFabaosInBag then
    for k, v in pairs(allFabaosInBag) do
      if v then
        local rankRandomSkillId = v.extraMap[ItemXStoreType.FABAO_RANK_RANDOM_SKILL_ID]
        if rankRandomSkillId and 0 ~= rankRandomSkillId then
          return true
        end
      end
    end
  end
  return false
end
def.method("=>", "boolean").CheckXQRedNotice = function(self)
  local longjingInWear = FabaoData.Instance():GetAllLongJingData()
  local longjingInBag = FabaoModule.Instance():GetAllLongjingInBag()
  for i = 1, 6 do
    local isFull, _ = FabaoData.Instance():IsLongjingFullOnType(i)
    if not isFull then
      local longjingOnType = longjingInBag[i]
      if longjingOnType and #longjingOnType > 0 then
        return true
      end
    end
  end
  if longjingInWear then
    for k, v in pairs(longjingInWear) do
      local canLevelUpOnType = self:CanLevelUpOnLongjingType(k)
      if canLevelUpOnType then
        return true
      end
    end
  end
  return false
end
def.static("number", "number", "=>", "table").GetFabaoItemInfo = function(fabaoKey, fabaoType)
  if -1 == fabaoKey then
    local fabaoData = FabaoData.Instance():GetFabaoByType(fabaoType)
    return fabaoData
  else
    local bagId = ItemModule.FABAOBAG
    return ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, fabaoKey)
  end
end
def.static("number", "userdata", "=>", "table").GetFabaoItemInfoEx = function(equiped, fabaouuid)
  local FabaoConst = require("netio.protocol.mzm.gsp.fabao.FaBaoConst")
  local fabaoItemInfo
  if equiped == FabaoConst.EQUIPED then
    local allEquipFabao = require("Main.Fabao.data.FabaoData").Instance():GetAllFabaoData()
    for k, v in pairs(allEquipFabao) do
      if v.uuid[1]:eq(fabaouuid) then
        fabaoItemInfo = v
        break
      end
    end
  else
    local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
    local fabaosInBag = ItemModule.Instance():GetItemsByItemType(ItemModule.FABAOBAG, ItemType.FABAO_ITEM)
    for k, v in pairs(fabaosInBag) do
      if v.uuid[1]:eq(fabaouuid) then
        fabaoItemInfo = v
        break
      end
    end
  end
  return fabaoItemInfo
end
def.static("=>", "boolean", "number").HasFabaoTask = function()
  local TaskInterface = require("Main.task.TaskInterface")
  local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
  local fabaoGraphId = FabaoUtils.GetFabaoConstValue("FABAO_TASK_MAP_ID")
  local taskInfos = TaskInterface.Instance():GetTaskInfos()
  for taskId, graphIdValue in pairs(taskInfos) do
    for graphId, info in pairs(graphIdValue) do
      if graphId == fabaoGraphId and (info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT or info.state == TaskConsts.TASK_STATE_CAN_ACCEPT or info.state == TaskConsts.TASK_STATE_FINISH) then
        return true, taskId
      end
    end
  end
  return false, 0
end
def.static("table", "table").OnGetNewItem = function(p1, p2)
  if p1.bagId == ItemModule.FABAOBAG then
    local itemId = p1.itemId
    if nil == itemId then
      return
    end
    local self = FabaoModule.Instance()
    local itemBase = ItemUtils.GetItemBase(itemId)
    local itemType = itemBase.itemType
    if itemType == ItemType.FABAO_ITEM or itemType == ItemType.FABAO_FRAG_ITEM then
      for k, v in pairs(p1.keyList) do
        self:SetFabaoNew(v, true)
      end
    end
  end
end
def.static().ShowAttrChangeTipInFight = function()
  if PlayerIsInFight() then
    Toast(textRes.Fabao[109])
  end
end
def.static("table").OnSSynFabaoInfo = function(p)
  local fabaoData = p.euqipFabao
  local longjingData = p.euqipLongjing
  local curDisFaoType = p.disFaBaotype
  warn("OnSSynFabaoInfo ~~~~ ", fabaoData, longjingData)
  if fabaoData then
    FabaoData.Instance():SetFabaoData(fabaoData)
  end
  if longjingData then
    FabaoData.Instance():SetLongJingData(longjingData)
  end
  FabaoData.Instance():SetDisplayFabaoType(curDisFaoType)
end
def.static("table").OnSSynFabaoChangeInfo = function(p)
  local fabaoChangeInfo = p.fabaoChangeInfo
  warn("OnSSynFabaoChangeInfo ~~~~ ", fabaoChangeInfo)
  FabaoData.Instance():ChangeFabaoData(fabaoChangeInfo)
  Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.FABAO_WEARINFO_CHANGE, {changeInfo = fabaoChangeInfo})
  Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.FABAO_REDNOTICE_CHANGE, nil)
  FabaoModule.ShowAttrChangeTipInFight()
end
def.static("table").OnSSynLongJingChangeInfo = function(p)
  warn("OnSSynLongJingChangeInfo ~~~~ ", p)
  FabaoData.Instance():ChangeLongJingData(p)
  Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.LONGJING_QX_INFO_CHANGE, {changeInfo = p})
  Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.FABAO_REDNOTICE_CHANGE, nil)
  FabaoModule.ShowAttrChangeTipInFight()
end
def.static("table").OnYuanBaoPriceRes = function(p)
  FabaoSocialPanel.Instance():OnYuanBaoPriceRes(p.uid, p.itemid2yuanbao)
end
def.static("table").OnSEquipFabaoErrorRes = function(p)
  warn("OnSEquipFabaoErrorRes ~~~~~ ", p.errorCode)
  if textRes.Fabao.FabaoEquipError[p.errorCode] then
    Toast(textRes.Fabao.FabaoEquipError[p.errorCode])
  end
end
def.static("table").OnSUnEquipFabaoErrorRes = function(p)
  warn("OnSUnEquipFabaoErrorRes ~~~ ", p.errorCode)
  if textRes.Fabao.FabaoUnEquipError[p.errorCode] then
    Toast(textRes.Fabao.FabaoUnEquipError[p.errorCode])
  end
end
def.static("table").OnSFabaoComposeRes = function(p)
  warn("OnSFabaoComposeRes ~~~~ ", p.resultcode)
  if textRes.Fabao.FabaoComposeError[p.resultcode] then
    Toast(textRes.Fabao.FabaoComposeError[p.resultcode])
  end
end
def.static("table").OnSFabaoComposeSuccessRes = function(p)
  warn("OnSFabaoComposeSuccessRes  ~~~~~~ ", p.key, p.eqpInfo)
  local FabaoCommonPanel = require("Main.Fabao.ui.FabaoCommonPanel")
  local params = {}
  params.ComposeInfo = {}
  params.ComposeInfo.fabaoId = p.eqpInfo.id
  params.ComposeInfo.fabaoLevel = p.eqpInfo.extraMap[ItemXStoreType.FABAO_CUR_LV] or 0
  params.ComposeInfo.fabaoSkillId = p.eqpInfo.extraMap[ItemXStoreType.FABAO_OWN_SKILL_ID]
  FabaoCommonPanel.Instance():ShowPanel(FabaoCommonPanel.TypeDefine.FabaoCompose, params)
end
def.static("table").OnSFabaoLevelUp = function(p)
  local fabaoId = p.fabaoid
  local oldLevel = p.fabaoOriginallv
  local curLevel = p.fabaolv
  warn("OnSFabaoLevelUp ~~~~~ ", fabaoId, oldLevel, curLevel)
  FabaoSocialPanel.OnSFabaoLevelUp(fabaoId, oldLevel, curLevel)
end
def.static("table").OnSFabaoExpTipRes = function(p)
  local fabaoId = p.fabaoid
  local addExp = p.exp
  warn("OnSFabaoExpTipRes ~~~~~~ ", fabaoId, addExp)
  FabaoSocialPanel.OnSFabaoAddExpSucc(fabaoId, addExp)
  Toast(string.format(textRes.Fabao[120], addExp))
end
def.static("table").OnSFabaoAddExpRes = function(p)
  local retCode = p.resultcode
  warn("OnSFabaoAddExpRes ~~~~~~ ", retCode)
  local SFabaoAddExpRes = require("netio.protocol.mzm.gsp.fabao.SFabaoAddExpRes")
  if retCode == SFabaoAddExpRes.ERROR_EXP_MAX_LV_ROLE then
    FabaoSocialPanel.OnLevelUpLimitByRoleLv()
  elseif textRes.Fabao.FabaoAddExpError[retCode] then
    Toast(textRes.Fabao.FabaoAddExpError[retCode])
  end
end
def.static("table").OnSFabaoWashSucRes = function(p)
  warn("~~~ OnSFabaoWashSucRes ~~~~")
  FabaoSocialPanel.OnSFabaoWashSucRes(p.equiped, p.fabaouuid, p.skillid)
end
def.static("table").OnSFabaoWashErrorRes = function(p)
  warn("~~~~~~~ OnSFabaoWashErrorRes ~~~~", p.resultcode)
  if textRes.Fabao.FabaoWashSkillError[p.resultcode] then
    Toast(textRes.Fabao.FabaoWashSkillError[p.resultcode])
  end
end
def.static("table").OnSFabaoReplaceWashSkillRes = function(p)
  warn("OnSFabaoReplaceWashSkillRes ~~~~~~")
  FabaoSocialPanel.OnSFabaoReplaceWashSkillRes(p.equiped, p.fabaouuid, p.skillid)
end
def.static("table").OnSFabaReplaceWashSkillErrorRes = function(p)
  warn("OnSFabaReplaceWashSkillErrorRes ~~~ ", p.retCode)
end
def.static("table").OnSFabaoUpRankSucRes = function(p)
  local ownSkillid = p.next_rank_skillid
  local rankSkillid = p.random_skillid
  local fabaouuid = p.fabaouuid
  local equiped = p.equiped
  FabaoSocialPanel.OnSFabaoUpRankSucRes(ownSkillid, rankSkillid, fabaouuid, equiped, 0)
end
def.static("table").OnSFaBaoAutoRankUpRes = function(p)
  local ownSkillid = p.next_rank_skillid
  local rankSkillid = p.random_skillid
  local fabaouuid = p.fabaouuid
  local equiped = p.equiped
  local targetFabaoId = p.upToFaBaoCfgid
  FabaoSocialPanel.OnSFabaoUpRankSucRes(ownSkillid, rankSkillid, fabaouuid, equiped, targetFabaoId)
end
def.static("table").OnSFabaoUpRankErrorRes = function(p)
  local retCode = p.resultcode
  warn("OnSFabaoUpRankErrorRes   ~~~~~~~~~ ", retCode)
  if textRes.Fabao.FabaoRankUpError[retCode] then
    Toast(textRes.Fabao.FabaoRankUpError[retCode])
  end
end
def.static("table").OnSFabaoAddRankScoreRes = function(p)
  warn("OnSFabaoAddRankScoreRes ~~~~ ", p.equiped, p.fabaouuid, p.addScore)
  Toast(string.format(textRes.Fabao[121], p.addScore))
end
def.static("table").OnSFabaoAddRankScoreErrorRes = function(p)
  warn("OnSFabaoAddRankScoreErrorRes ~~~~~ ", p.resultcode)
  if textRes.Fabao.FabaoAddRankScoreError[p.resultcode] then
    Toast(textRes.Fabao.FabaoAddRankScoreError[p.resultcode])
  end
end
def.static("table").OnSChoiceRankSkillRes = function(p)
  warn("OnSChoiceRankSkillRes ~~~~ ", p.skillid)
  if p.skillid then
    local skillCfg = require("Main.Skill.SkillUtility").GetSkillCfg(p.skillid)
    if skillCfg then
      Toast(string.format(textRes.Fabao[113], skillCfg.name))
    end
  end
end
def.static("table").OnSChoiceRankSkillErrorRes = function(p)
  warn("OnSChoiceRankSkillErrorRes ~~~~~~", p.resultcode)
end
def.static("table").OnSLongjingMountSucRes = function(p)
  warn("OnSLongjingMountSucRes ~~~~~ ", p.itemid, p.pos)
  local longjingBase = require("Main.Item.ItemUtils").GetItemBase(p.itemid)
  local color = require("Main.Chat.HtmlHelper").NameColor[longjingBase.namecolor] or "ffffff"
  if longjingBase then
    Toast(string.format(textRes.Fabao[107], color, longjingBase.name))
  end
  FabaoSocialPanel.OnLongjingMountSucc(p.itemid, p.pos)
end
def.static("table").OnSLongjingMountErrorRes = function(p)
  warn("OnSLongjingMountErrorRes  ~~~~~~~~  ", p.resultcode)
end
def.static("table").OnSLongjingUnMountSucRes = function(p)
  warn("OnSLongjingUnMountSucRes ~~~ ", p.itemids)
end
def.static("table").OnSLongjingUnMountErrorRes = function(p)
  warn("OnSLongjingMountErrorRes ~~~~ ", p.resultcode)
end
def.static("table").OnSLongjingComposeSucRes = function(p)
  warn("OnSLongjingComposeSucRes ~~~~~ ")
  Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.LJ_COMBINE_SUCCESS, {
    longjingInfo = p.itemid2Num
  })
end
def.static("table").OnSLongjingComposeErrorRes = function(p)
  warn("OnSLongjingComposeErrorRes ~~~ ", p.resultcode)
  if textRes.Fabao.LongjingComposeError[p.resultcode] then
    Toast(textRes.Fabao.LongjingComposeError[p.resultcode])
  end
end
def.static("table").OnSLongjingUpLevelRes = function(p)
  warn("OnSLongjingUpLevelRes ~~~~~ ", p.curItemid, p.nextItemid)
  local curLongjingBase = ItemUtils.GetItemBase(p.curItemid)
  local nextLongjingBase = ItemUtils.GetItemBase(p.nextItemid)
  if curLongjingBase and nextLongjingBase then
    local curName = curLongjingBase.name
    local nextName = nextLongjingBase.name
    local curColor = require("Main.Chat.HtmlHelper").NameColor[curLongjingBase.namecolor] or "ffffff"
    local nextColor = require("Main.Chat.HtmlHelper").NameColor[nextLongjingBase.namecolor] or "ffffff"
    Toast(string.format(textRes.Fabao[102], curColor, curName, nextColor, nextName))
  end
end
def.static("table").OnSLongjingUpLevelErrorRes = function(p)
  warn("OnSLongjingUpLevelErrorRes ~~~~~~~~ ", p.resultcode)
  if textRes.Fabao.LongjingLevelUpError[p.resultcode] then
    Toast(textRes.Fabao.LongjingLevelUpError[p.resultcode])
  end
end
def.static("table").OnSChangeDisPlayFabaoRes = function(p)
  warn("OnSChangeDisPlayFabaoRes ~~~~~ ", p.faobaotype)
  local fabaoType = p.faobaotype
  FabaoData.Instance():SetDisplayFabaoType(fabaoType)
  local displayFabao = FabaoData.Instance():GetCurDisplayFabao()
  if displayFabao then
    local fabaoData = displayFabao.fabaoData
    if fabaoData then
      local fabaoBase = ItemUtils.GetItemBase(fabaoData.id)
      local fabaoName = fabaoBase.name
      local color = require("Main.Chat.HtmlHelper").NameColor[fabaoBase.namecolor] or "ffffff"
      Toast(string.format(textRes.Fabao[101], color, fabaoName))
    end
  end
  Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.FABAO_DISPLAY_CHANGE, {fabaoType = fabaoType})
end
def.static("table").OnSChangeDisPlayFabaoErrorRes = function(p)
  warn("OnSChangeDisPlayFabaoErrorRes ~~~~~~ ", p.errorCode)
end
def.static("table", "table").OpenFabaoSocialPanel = function(p1, p2)
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  local FabaoOpenLevel = FabaoUtils.GetFabaoConstValue("FABAO_OPEN_LEVEL") or 60
  if heroLevel < FabaoOpenLevel then
    Toast(textRes.Fabao[54]:format(FabaoOpenLevel))
    return
  end
  local hasFabaoTask, taskId = FabaoModule.HasFabaoTask()
  warn("OpenFabaoSocialPanel ~~~~ ", hasFabaoTask, taskId)
  if false == hasFabaoTask and 0 == taskId then
    FabaoSocialPanel.Instance():ShowPanel(FabaoSocialPanel.NodeId.FabaoBasic)
  else
    Toast(textRes.Fabao[59])
    if 0 ~= taskId then
      local FabaoTaskGraphID = FabaoUtils.GetFabaoConstValue("FABAO_TASK_MAP_ID")
      Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TASK_TRACE_ITEM_CLICK, {taskId, FabaoTaskGraphID})
    end
  end
end
def.static("number", "number").RequestFabaoCompose = function(fabaoId, yuanbaoNum)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local p = require("netio.protocol.mzm.gsp.fabao.CFabaoComposeReq").new(fabaoId, yuanbaoNum)
  gmodule.network.sendProtocol(p)
end
def.static("number").RequestWearOnFabao = function(itemKey)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local p = require("netio.protocol.mzm.gsp.fabao.CEquipFabaoReq").new(itemKey)
  gmodule.network.sendProtocol(p)
end
def.static("number").RequestWearOffFabao = function(fabaoType)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local p = require("netio.protocol.mzm.gsp.fabao.CUnEquipFabaoReq").new(fabaoType)
  gmodule.network.sendProtocol(p)
  warn("wear off fabao ~~~~~~~~~~~~~~~~~ ", fabaoType)
end
def.static("number", "userdata", "number", "number").RequestAddFabaoExp = function(isEquiped, fabaouuid, itemKey, itemCount)
  local p = require("netio.protocol.mzm.gsp.fabao.CFabaoAddExpReq").new(isEquiped, fabaouuid, itemKey, itemCount)
  gmodule.network.sendProtocol(p)
end
def.static("number", "userdata", "number").RequestFabaoWashSkill = function(isEquiped, fabaouuid, yuanbaoNum)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local p = require("netio.protocol.mzm.gsp.fabao.CFabaoWashReq").new(isEquiped, fabaouuid, yuanbaoNum)
  gmodule.network.sendProtocol(p)
end
def.static("number", "userdata").RequestReplaceFabaoWashSkill = function(isEquiped, fabaouuid)
  local p = require("netio.protocol.mzm.gsp.fabao.CFabaoReplaceWashSkillReq").new(isEquiped, fabaouuid)
  gmodule.network.sendProtocol(p)
end
def.static("number", "userdata", "number").RequestFabaoRankUp = function(isEquiped, fabaouuid, yuanbaoNum)
  local p = require("netio.protocol.mzm.gsp.fabao.CFabaoUpRankReq").new(isEquiped, fabaouuid, yuanbaoNum)
  gmodule.network.sendProtocol(p)
end
def.static("number", "userdata", "number", "number").RequestAddRankExp = function(isEquiped, fabaouuid, itemKey, itemCount)
  local p = require("netio.protocol.mzm.gsp.fabao.CFabaoAddRankScoreReq").new(isEquiped, fabaouuid, itemKey, itemCount)
  gmodule.network.sendProtocol(p)
end
def.static("number", "userdata", "number").RequestChoiceRankSkill = function(isEquiped, fabaouuid, skillId)
  local p = require("netio.protocol.mzm.gsp.fabao.CChoiceRankSkillReq").new(isEquiped, fabaouuid, skillId)
  gmodule.network.sendProtocol(p)
  warn("RequestChoiceRankSkill ~~~~~~~~~~~~~~ ")
end
def.static("number", "number").RequestLongjingMount = function(key, pos)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local p = require("netio.protocol.mzm.gsp.fabao.CLongjingMountReq").new(key, pos)
  gmodule.network.sendProtocol(p)
  warn("RequestLongjingMount ~~~~ ", key, pos)
end
def.static("number", "number").RequestLongjingUnMount = function(fabaoType, pos)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local p = require("netio.protocol.mzm.gsp.fabao.CLongjingUnMountReq").new(fabaoType, pos)
  gmodule.network.sendProtocol(p)
end
def.static("number").RequestUnMountAllLongjing = function(fabaoType)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local p = require("netio.protocol.mzm.gsp.fabao.CLongjingUnMountAllReq").new(fabaoType)
  gmodule.network.sendProtocol(p)
  warn("send protocol ~~ RequestUnMountAllLongjing")
end
def.static("number").RequestLongjingCompose = function(itemId)
  local p = require("netio.protocol.mzm.gsp.fabao.CLongjingComposeReq").new(itemId)
  gmodule.network.sendProtocol(p)
end
def.static().ReqiestLongjingAllCompose = function()
  local p = require("netio.protocol.mzm.gsp.fabao.CLongjingAutoComposeReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("number", "number").RequestLongjingLevelUp = function(fabaoType, pos)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local p = require("netio.protocol.mzm.gsp.fabao.CLongjingUpLevelReq").new(fabaoType, pos)
  gmodule.network.sendProtocol(p)
end
def.static("number").RequestChangeDisplayFabao = function(fabaoType)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local p = require("netio.protocol.mzm.gsp.fabao.CChangeDisPlayFabaoReq").new(fabaoType)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSFaBaoAutoRankUpErrorRes = function(p)
  local ret = p.resultcode
  local tip = textRes.Fabao.FabaoAutoRankUpError[ret]
  if tip then
    Toast(tip)
  end
end
FabaoModule.Commit()
return FabaoModule
