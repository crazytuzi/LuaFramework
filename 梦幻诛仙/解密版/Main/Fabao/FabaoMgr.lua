local Lplus = require("Lplus")
local ToastTip = require("GUI.ToastTip")
local FabaoData = require("Main.Fabao.data.FabaoData")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local TaskInterface = require("Main.task.TaskInterface")
local FabaoMgr = Lplus.Class("FabaoMgr")
local def = FabaoMgr.define
local instance
def.static("=>", FabaoMgr).Instance = function()
  if not instance then
    instance = FabaoMgr()
  end
  return instance
end
def.const("number").MINRANK = 1
def.const("number").MAXRANK = 5
def.const("number").MAXLEVEL = 20
def.field("number").m_FabaoId = 0
def.static("table").onSSynRoleFabao = function(p)
  print("onSSynRoleFabao", p.fabaoId)
  self.m_FabaoId = p.fabaoId
end
def.static("table").OnFabaoComplexRes = function(p)
  warn("OnFabaoComplexRes", p.resultcode)
  local SFabaoComplexRe = require("netio.protocol.mzm.gsp.fabao.SFabaoComplexRes")
  local errCode = p.resultcode
  if errCode == SFabaoComplexRe.ERROR_BAG_FULL then
    Toast(textRes.Fabao[15])
  end
end
def.static("table").OnSFabaoComplexSuccessRes = function(p)
  warn("OnSFabaoComplexSuccessRes", p.key)
  Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.COMBINE_SUCCESS, p)
end
local function ShowSkillTip(str, id, index)
  if id and id > 0 then
    local skillCfg = FabaoMgr.GetFabaoEffectSkillCfg(id, index)
    Toast(str:format(skillCfg.name))
  end
end
def.static("table").OnFabaoWashRes = function(p)
  warn("OnFabaoWashRes", p.resultcode, p.skillid1, " ", p.skillid2, " ", p.skillid3, " ", p.skilllv1, " ", p.skilllv2, " ", p.skilllv3)
  local SFabaoWashRes = require("netio.protocol.mzm.gsp.fabao.SFabaoWashRes")
  local errCode = p.resultcode
  if errCode == SFabaoWashRes.SUCCESS then
    Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.WASH_SUCCESS, {})
    local ids = {
      p.skillid1,
      p.skillid2,
      p.skillid3
    }
    local indexs = {
      p.skilllv1,
      p.skilllv2,
      p.skilllv3
    }
    for i = 1, 3 do
      ShowSkillTip(textRes.Fabao[37], ids[i], indexs[i])
    end
  elseif errCode == SFabaoWashRes.ERROR_SILVER_NOT_ENOUGH then
    Toast(textRes.Fabao[16])
  end
end
def.static("table").OnFabaoUpRankRes = function(p)
  warn("OnFabaoUpRankRes", p.resultcode, p.skillid)
  local SFabaoUpRankRes = require("netio.protocol.mzm.gsp.fabao.SFabaoUpRankRes")
  if p.resultcode == SFabaoUpRankRes.SUCCESS then
    Toast(textRes.Fabao[33])
    Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.RANKUP_SUCCESS, {})
    ShowSkillTip(textRes.Fabao[36], p.skillid, 0)
  elseif p.resultcode == SFabaoUpRankRes.ERROR_LV_NOT_ENOUGH then
    Toast(textRes.Fabao[19])
  elseif p.resultcode == SFabaoUpRankRes.ERROR_UPRANK_ITEM then
    Toast(textRes.Fabao[21])
  end
end
def.static("table").OnFabaoAddExpRes = function(p)
  warn("OnFabaoAddExpRes", p.resultcode)
  local SFabaoAddExpRes = require("netio.protocol.mzm.gsp.fabao.SFabaoAddExpRes")
  if p.resultcode == SFabaoAddExpRes.SUCCESS then
    Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.EXP_SUCCESS, {})
  elseif p.resultcode == SFabaoAddExpRes.ERROR_EXP_MAX_LV_RANK then
    Toast(textRes.Fabao[20])
  elseif p.resultcode == SFabaoAddExpRes.ERROR_EXP_MAX_LV_ROLE then
    Toast(textRes.Fabao[61])
  end
end
def.static("table").OnSLongjingComplexRes = function(p)
  warn("OnSLongjingComplexRes", p.resultcode)
  local SLongjingComplexRes = require("netio.protocol.mzm.gsp.fabao.SLongjingComplexRes")
  if p.resultcode == SLongjingComplexRes.SUCCESS then
    Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.LJ_COMBINE_SUCCESS, {})
  end
end
def.static("table").OnSLongjingMountRes = function(p)
  warn("OnSLongjingMountRes", p.resultcode)
  local SLongjingMountRes = require("netio.protocol.mzm.gsp.fabao.SLongjingMountRes")
  if p.resultcode == SLongjingMountRes.SUCCESS then
    Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.MOUNT_SUCCESS, {
      groupid = p.groupid
    })
  elseif p.resultcode == SLongjingMountRes.ERROR_LONGJING_REPEAT then
    Toast(textRes.Fabao[13])
  elseif p.resultcode == SLongjingMountRes.ERROR_REPEAT_MOUNT then
    Toast(textRes.Fabao[14])
  end
end
def.static("table").OnSLongjingUnMountRes = function(p)
  warn("OnSLongjingUnMountRes", p.resultcode)
  local SLongjingUnMountRes = require("netio.protocol.mzm.gsp.fabao.SLongjingUnMountRes")
  if p.resultcode == SLongjingUnMountRes.SUCCESS then
    Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.UNMOUNT_SUCCESS, {
      groupid = p.groupid
    })
  end
end
def.static("table").OnSFabaoDecomposeRes = function(p)
  warn("OnSFabaoDecomposeRes", p.resultcode)
  local SFabaoDecomposeRes = require("netio.protocol.mzm.gsp.fabao.SFabaoDecomposeRes")
  if p.resultcode == SFabaoDecomposeRes.SUCCESS then
  elseif p.resultcode == SFabaoDecomposeRes.ERROR_BAG_FULL then
    Toast(textRes.Fabao[15])
  end
end
def.static("table").OnSFabaoDecomposeSuccessRes = function(p)
  warn("SFabaoDecomposeSuccessRes", p.longjing, #p.items)
  if p.longjing == 1 then
    Toast(textRes.Fabao[29])
  end
  for k, v in pairs(p.items) do
    local name = ItemUtils.GetItemBase(k).name
    Toast(textRes.Fabao[30]:format(name, v))
  end
end
def.static("table").OnFabaoLevelUp = function(p)
  warn("OnFabaoLevelUp", p.fabaoid, p.fabaolv)
  local name = ItemUtils.GetItemBase(p.fabaoid).name
  Toast(textRes.Fabao[39]:format(name, p.fabaolv))
  if _G.PlayerIsInFight() then
    Toast(textRes.Fabao[56])
  end
end
def.static("table").OnFabaoSkillLevelUp = function(p)
  warn("OnFabaoSkillLevelUp", p.fabaoid, #p.skills)
  for id, lv in pairs(p.skills) do
    if id and lv and id > 0 and lv > 0 and lv < 3 then
      local skillName = FabaoMgr.GetFabaoEffectSkillCfg(id, lv - 1).name
      local skillName1 = FabaoMgr.GetFabaoEffectSkillCfg(id, lv).name
      local tip = lv == 1 and textRes.Fabao[40] or textRes.Fabao[41]
      Toast(tip:format(skillName, skillName1))
    end
  end
end
def.static("number").CombineItem = function(fabaoid)
  local p = require("netio.protocol.mzm.gsp.fabao.CFabaoComplexReq").new(fabaoid)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number", "number").RefreshItem = function(bagType, fabaoid, needYuanBaoNum)
  warn("RefreshItem.........", bagType, fabaoid)
  local p = require("netio.protocol.mzm.gsp.fabao.CFabaoWashReq").new(bagType, fabaoid, needYuanBaoNum)
  gmodule.network.sendProtocol(p)
end
def.static("table").AddExp = function(params)
  warn("AddExp........")
  local p = require("netio.protocol.mzm.gsp.fabao.CFabaoAddExpReq").new(params.bagid, params.fabaoid, params.expUuidList)
  gmodule.network.sendProtocol(p)
end
def.static("table").Advance = function(params)
  warn("Advance........", params.bagid, params.fabaoid)
  local p = require("netio.protocol.mzm.gsp.fabao.CFabaoUpRankReq").new(params.bagid, params.fabaoid, params.needYuanBaoNum)
  gmodule.network.sendProtocol(p)
end
def.static("table").Mount = function(params)
  warn("Mount........", params.longjingid, params.fabaobagid, params.fabaoitemid, params.pos)
  local p = require("netio.protocol.mzm.gsp.fabao.CLongjingMountReq").new(params.longjingid, params.fabaobagid, params.fabaoitemid, params.pos)
  gmodule.network.sendProtocol(p)
end
def.static("table").UnMount = function(params)
  warn("UnMount........", params.bagid, params.fabaoid, params.pos)
  local p = require("netio.protocol.mzm.gsp.fabao.CLongjingUnMountReq").new(params.bagid, params.fabaoid, params.pos)
  gmodule.network.sendProtocol(p)
end
def.static("table").LongJingCombine = function(params)
  warn("Mount........", params.id)
  local p = require("netio.protocol.mzm.gsp.fabao.CLongjingComplexReq").new(params.id)
  gmodule.network.sendProtocol(p)
end
def.static("table").FabaoDecompose = function(params)
  warn("FabaoDecompose........", params.bagid, " ", params.fabaoid)
  local p = require("netio.protocol.mzm.gsp.fabao.CFabaoDecomposeReq").new(params.bagid, params.fabaoid)
  gmodule.network.sendProtocol(p)
end
def.static("table", "table").OnFabaoPanelIconClick = function(p1, p2)
  local hasFabaoTask, taskId = FabaoMgr.HasFabaoTask()
  if false == hasFabaoTask and 0 == taskId then
    local fabaoPanel = require("Main.Fabao.ui.FabaoPanel")
    fabaoPanel.Instance():ShowPanel(not p1 and fabaoPanel.SUBNODEINFO[1].ID or p1.id)
  else
    Toast(textRes.Fabao[59])
    if 0 ~= taskId then
      local FabaoTaskGraphID = FabaoData.GetFabaoConstant("FABAO_TASK_MAP_ID")
      Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TASK_TRACE_ITEM_CLICK, {taskId, FabaoTaskGraphID})
    end
  end
end
def.static("table", "table").OnPreviewPanelClick = function(p1, p2)
  local preview = require("Main.Fabao.ui.PreviewPanel")
  local instance = preview.Instance()
  instance:UpdateData()
  if p1.id then
    instance:UpdateCurIndex(p1.id)
  end
  instance:ShowPanel()
end
def.static("table", "table").OnFabaoExpPanelClick = function(p1, p2)
  local _, count = FabaoMgr.GetFabaoExpItem()
  if count == 0 then
    local fabaoExpGetPanel = require("Main.Fabao.ui.FabaoExpGetPanel")
    fabaoExpGetPanel.Instance():ShowPanel()
  else
    local fabaoExpPanel = require("Main.Fabao.ui.FabaoExpPanel")
    fabaoExpPanel.Instance():SetItem(p1[1])
    fabaoExpPanel.Instance():ShowPanel()
  end
end
def.static("table", "table").OnLJGetPanelClick = function(p1, p2)
  local ljGetPanel = require("Main.Fabao.ui.LongJingGetPanel")
  ljGetPanel.Instance():ShowPanel()
end
def.static("table", "table").OnFabaoWikiPanelClick = function(p1, p2)
  local fabaoWikiPanel = require("Main.Fabao.ui.FabaoWikiPanel")
  fabaoWikiPanel.Instance():ShowPanel()
end
local ClosePanelAction = function()
  local fabaoPanel = require("Main.Fabao.ui.FabaoPanel")
  fabaoPanel.Instance():UpdateLeftView()
  fabaoPanel.Instance():UpdateMainView()
end
def.static("table", "table").OnFabaoExpPanelClose = function(p1, p2)
  ClosePanelAction()
end
def.static("table", "table").OnLJCombinePanelClose = function(p1, p2)
  ClosePanelAction()
end
def.static("table", "table").OnLongJingCombineClick = function(p1, p2)
  local ljPanel = require("Main.Fabao.ui.LongJingCombinePanel")
  ljPanel.Instance():ShowPanel()
end
def.static("=>", "table").GetFabaoSkillDesc = function()
  return {
    textRes.Fabao[4],
    textRes.Fabao[5],
    textRes.Fabao[6]
  }
end
def.static("=>", "number", "table").GetFabaoItems = function()
  return FabaoData.GetFabaoItems()
end
def.static("number", "=>", "table").GetFabaoTemplateData = function(id)
  return FabaoData.GetFabaoTemplateData(id)
end
def.static("number", "=>", "number").GetItemFromBag = function(id)
  return ItemModule.Instance():GetNumberByItemId(ItemModule.FABAOBAG, id)
end
def.static("string", "=>", "number").GetFabaoConstant = function(name)
  return FabaoData.GetFabaoConstant(name)
end
def.static("number", "number", "=>", "table").GetFabaoLevelCfg = function(levelId, level)
  return FabaoData.GetFabaoLevelCfg(levelId, level)
end
def.static("number", "number", "=>", "table").GetFabaoEffectSkillCfg = function(id, skillIndex)
  return FabaoData.GetFabaoEffectSkillCfg(id, skillIndex + 1)
end
def.static("number", "=>", "table").GetFabaoEffectCfg = function(id)
  return FabaoData.GetFabaoEffectCfg(id)
end
def.static("number", "=>", "table").GetFabaoAttributeCfg = function(id)
  return FabaoData.GetFabaoAttributeCfg(id)
end
def.static("number", "number", "=>", "table").GetFabaoRankCfg = function(rankId, rankLevel)
  return FabaoData.GetFabaoRankCfg(rankId, rankLevel)
end
def.static("=>", "table").GetFabaoAllAttribute = function()
  return FabaoData.GetFabaoAllAttribute()
end
def.static("=>", "table").GetAllLongJingItems = function()
  return FabaoData.GetAllLongJingItems()
end
def.static("=>", "table").GetFabaoAllRankLevel = function()
  return FabaoData.GetFabaoAllRankLevel()
end
def.static("=>", "table").GetAllCombineData = function()
  return FabaoData.GetAllCombineData()
end
def.static("number", "=>", "table").GetCombineData = function(id)
  return FabaoData.GetCombineData(id)
end
def.static("=>", "table").GetFabaoExpIDs = function()
  local ids = {}
  local fragItems = FabaoData.GetAllFabaoFragmentItemIDs()
  local expItems = FabaoData.GetAllFabaoExpItemIDs()
  for _, v in pairs(expItems) do
    if v.isShowUpDlg then
      table.insert(ids, v.id)
    end
  end
  for _, v in pairs(fragItems) do
    table.insert(ids, v)
  end
  return ids
end
def.static("=>", "boolean", "number").HasFabaoTask = function()
  local fabaoGraphId = FabaoData.GetFabaoConstant("FABAO_TASK_MAP_ID")
  local taskNum = 6
  for i = 1, taskNum do
    local taskId = FabaoData.GetFabaoConstant("FABAO_TASK_ID" .. tostring(i))
    local taskInfo = TaskInterface.Instance():GetTaskInfo(taskId, fabaoGraphId)
    if taskInfo then
      return true, taskId
    end
  end
  return false, 0
end
def.static("number", "=>", "boolean").IsFabaoNeedUpgrade = function(level)
  local rankLevels = FabaoMgr.GetFabaoAllRankLevel()
  for _, v in pairs(rankLevels) do
    if level + 1 == v then
      return true
    end
  end
  return false
end
def.static("=>", "table", "number").GetFabaoExpItem = function()
  local typeEnum = {
    ItemType.FABAO_EXP_ITEM,
    ItemType.FABAO_FRAG_ITEM
  }
  local count = 0
  local expItems = {}
  for _, v in pairs(typeEnum) do
    local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, v)
    for i, j in pairs(items) do
      if not expItems[j.id] then
        expItems[j.id] = {}
        expItems[j.id].type = v
        expItems[j.id].totalNum = j.number
        expItems[j.id].UID = {}
        expItems[j.id].itemKey = i
        count = count + 1
      else
        expItems[j.id].totalNum = expItems[j.id].totalNum + j.number
      end
      expItems[j.id].UID[j.uuid[1]] = j.number
    end
  end
  return expItems, count
end
def.static().OpenMoneyPanel = function()
  GoToBuySilver(false)
end
def.static("=>", "number", "table").GetAllFabaoItems = function()
  local bagTypes = {
    ItemModule.FABAOBAG,
    ItemModule.EQUIPBAG
  }
  local itemDatas = {}
  for _, bagType in pairs(bagTypes) do
    local count, data = FabaoMgr.GetFabaoItemsByBagType(bagType)
    for i = 1, count do
      local index = #itemDatas + 1
      itemDatas[index] = {}
      itemDatas[index].bagType = bagType
      itemDatas[index].data = data[i]
    end
  end
  return #itemDatas, itemDatas
end
def.static("number", "=>", "number", "table").GetFabaoItemsByBagType = function(bagType)
  local itemDatas = {}
  local items = ItemModule.Instance():GetItemsByItemType(bagType, ItemType.FABAO_ITEM)
  for _, item in pairs(items) do
    local index = #itemDatas + 1
    itemDatas[index] = {}
    itemDatas[index].dynamicData = item
    itemDatas[index].templateData = FabaoData.GetFabaoTemplateData(item.id)
  end
  return #itemDatas, itemDatas
end
def.method("number").SetFabaoID = function(self, id)
  self.m_FabaoId = id
end
def.method("=>", "number").GetMyFabao = function(self)
  return self.m_FabaoId
end
def.method().ToggleFabao = function(self)
  print("self.m_fabaoId", self.m_FabaoId)
  if self.m_FabaoId <= 0 then
    self:EquipFabao(390000000)
  else
    self:EquipFabao(0)
  end
end
def.method("number").EquipFabao = function(self, fabaoId)
  local heroMgr = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  if heroMgr.isFly then
    return
  end
  if fabaoId <= 0 then
    local takeOffFabao = require("netio.protocol.mzm.gsp.wingfabao.CTakeOffFabaoReq").new()
    gmodule.network.sendProtocol(takeOffFabao)
  else
    local putOnfabao = require("netio.protocol.mzm.gsp.wingfabao.CWearOnFabaoReq").new(fabaoId)
    gmodule.network.sendProtocol(putOnfabao)
  end
end
def.method().Init = function(self)
  FabaoData.Instance()
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_FABAO_CLICK, FabaoMgr.OnFabaoPanelIconClick)
  Event.RegisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.BTN_PREVIEW_CLICK, FabaoMgr.OnPreviewPanelClick)
  Event.RegisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.BTN_ENHANCE_CLICK, FabaoMgr.OnFabaoExpPanelClick)
  Event.RegisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.BTN_WIKI_CLICK, FabaoMgr.OnFabaoWikiPanelClick)
  Event.RegisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.LJINFO_GET_BTN, FabaoMgr.OnLJGetPanelClick)
  Event.RegisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.FABAOEXP_PANEL_CLOSE, FabaoMgr.OnFabaoExpPanelClose)
  Event.RegisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.BTN_COMBINE_CLICK, FabaoMgr.OnLongJingCombineClick)
  Event.RegisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.LJCOMBINE_PANEL_CLOSE, FabaoMgr.OnLJCombinePanelClose)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFabaoComplexRes", FabaoMgr.OnFabaoComplexRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFabaoComplexSuccessRes", FabaoMgr.OnSFabaoComplexSuccessRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFabaoWashRes", FabaoMgr.OnFabaoWashRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFabaoAddExpRes", FabaoMgr.OnFabaoAddExpRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFabaoUpRankRes", FabaoMgr.OnFabaoUpRankRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SLongjingComplexRes", FabaoMgr.OnSLongjingComplexRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SLongjingMountRes", FabaoMgr.OnSLongjingMountRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SLongjingUnMountRes", FabaoMgr.OnSLongjingUnMountRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFabaoDecomposeRes", FabaoMgr.OnSFabaoDecomposeRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFabaoDecomposeSuccessRes", FabaoMgr.OnSFabaoDecomposeSuccessRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFabaoLevelUp", FabaoMgr.OnFabaoLevelUp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabao.SFabaoSkillLevelUp", FabaoMgr.OnFabaoSkillLevelUp)
end
def.method().Reset = function(self)
  FabaoData.ClearFabaoData()
end
return FabaoMgr.Commit()
