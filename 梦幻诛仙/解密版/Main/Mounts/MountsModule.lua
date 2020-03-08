local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local MountsModule = Lplus.Extend(ModuleBase, "MountsModule")
local MountsPanel = require("Main.Mounts.ui.MountsPanel")
local MountsMgr = require("Main.Mounts.mgr.MountsMgr")
local MountsConst = require("netio.protocol.mzm.gsp.mounts.MountsConst")
local MountsUtils = require("Main.Mounts.MountsUtils")
local MountsTypeEnum = require("consts.mzm.gsp.mounts.confbean.MountsTypeEnum")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local def = MountsModule.define
local instance
def.field("userdata").QingYuanSession = nil
def.static("=>", MountsModule).Instance = function()
  if instance == nil then
    instance = MountsModule()
    instance.m_moduleId = ModuleId.MOUNTS
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mounts.SSyncMountsInfo", MountsModule.OnSSyncMountsInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mounts.SRideMountsSuccess", MountsModule.OnSRideMountsSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mounts.SUnRideMountsSuccess", MountsModule.OnSUnRideMountsSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mounts.SUnlockMountsSuccess", MountsModule.OnSUnlockMountsSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mounts.SMountsBattleSuccess", MountsModule.OnSMountsBattleSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mounts.SMountsUnBattleSuccess", MountsModule.OnSMountsUnBattleSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mounts.SMountsSetBattleStateSuccess", MountsModule.OnSMountsSetBattleStateSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mounts.SMountsProtectPetSuccess", MountsModule.OnSMountsProtectPetSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mounts.SMountsUnProtectPetSuccess", MountsModule.OnSMountsUnProtectPetSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mounts.SMountsRefreshPassiveSkillSuccess", MountsModule.OnSMountsRefreshPassiveSkillSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mounts.SMountsReplacePassiveSkillSuccess", MountsModule.OnSMountsReplacePassiveSkillSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mounts.SMountsDyeSuccess", MountsModule.OnSMountsDyeSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mounts.SMountsActiveStarLifeSuccess", MountsModule.OnSMountsActiveStarLifeSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mounts.SAppearenceMountsExpired", MountsModule.OnSAppearenceMountsExpired)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mounts.SExtendMountsTimeSuccess", MountsModule.OnSExtendMountsTimeSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mounts.SCostMountsAddScoreSuccess", MountsModule.OnSCostMountsAddScoreSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mounts.SCostItemAddScoreSuccess", MountsModule.OnSCostItemAddScoreSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mounts.SMountsCostItemRankUpSuccess", MountsModule.OnSMountsCostItemRankUpSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mounts.SMountsReplaceProtectPetSuccess", MountsModule.OnSMountsReplaceProtectPetSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mounts.SMountsSelectOrnamentSuccess", MountsModule.OnSMountsSelectOrnamentSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mounts.SExpandProtectPetSizeSuccess", MountsModule.OnSExpandProtectPetSizeSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mounts.SMountsNormalFail", MountsModule.OnSMountsNormalFail)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_MOUNTS_CLICK, MountsModule.OnClickMountsButton)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, MountsModule.OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, MountsModule.OnFeatureOpenChange)
  ModuleBase.Init(self)
end
def.static("number", "function").RigisterRideMountsCondition = function(moduleId, fn)
  MountsMgr.Instance():RigisterRideMountsCondition(moduleId, fn)
end
def.static().OpenMountsMainPanel = function()
  local result = MountsModule.CheckMountsOperation()
  if result then
    MountsPanel.Instance():ShowPanel()
  end
end
def.static("table").OnSSyncMountsInfo = function(p)
  MountsMgr.Instance():SyncMountsInfo(p)
  Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsListChange, nil)
end
def.static("table").OnSRideMountsSuccess = function(p)
  local mounts = MountsMgr.Instance():GetMountsById(p.mounts_id)
  if mounts ~= nil then
    local mountsCfg = MountsUtils.GetMountsCfgById(mounts.mounts_cfg_id)
    if mountsCfg ~= nil then
      if mountsCfg.mountsType == MountsTypeEnum.APPEARANCE_TYPE then
        Toast(string.format(textRes.Mounts[120], mountsCfg.mountsName))
      else
        Toast(string.format(textRes.Mounts[72], mountsCfg.mountsName, mounts.mounts_rank))
      end
    end
  end
  MountsMgr.Instance():SetCurRideMountsId(p.mounts_id)
  Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.RideMountsChange, nil)
end
def.static("table").OnSUnRideMountsSuccess = function(p)
  local mounts = MountsMgr.Instance():GetMountsById(p.mounts_id)
  if mounts ~= nil then
    local mountsCfg = MountsUtils.GetMountsCfgById(mounts.mounts_cfg_id)
    if mountsCfg ~= nil then
      if mountsCfg.mountsType == MountsTypeEnum.APPEARANCE_TYPE then
        Toast(string.format(textRes.Mounts[121], mountsCfg.mountsName))
      else
        Toast(string.format(textRes.Mounts[73], mountsCfg.mountsName, mounts.mounts_rank))
      end
    end
  end
  MountsMgr.Instance():SetCurRideMountsId(Int64.new(MountsConst.NO_RIDE))
  Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.RideMountsChange, nil)
end
def.static("table").OnSUnlockMountsSuccess = function(p)
  MountsMgr.Instance():AddMounts(p.mounts_id, p.unlock_mounts_info)
  local mountsCfg = MountsUtils.GetMountsCfgById(p.unlock_mounts_info.mounts_cfg_id)
  if mountsCfg ~= nil then
    if mountsCfg.mountsType == MountsTypeEnum.APPEARANCE_TYPE then
      Toast(string.format(textRes.Mounts[119], mountsCfg.mountsName))
    else
      Toast(string.format(textRes.Mounts[3], mountsCfg.mountsName, p.unlock_mounts_info.mounts_rank))
    end
  end
  Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsListChange, nil)
end
def.static("table").OnSMountsBattleSuccess = function(p)
  Toast(textRes.Mounts[16])
  MountsMgr.Instance():AddBattleMounts(p.cell_id, p.mounts_id)
  MountsMgr.Instance():SetBattleMountsStatus(p.cell_id, p.battle_mounts_state)
  Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsBattleStatusChange, nil)
end
def.static("table").OnSMountsUnBattleSuccess = function(p)
  Toast(textRes.Mounts[18])
  MountsMgr.Instance():RemoveBattleMounts(p.cell_id)
  Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsBattleStatusChange, nil)
end
def.static("table").OnSMountsSetBattleStateSuccess = function(p)
  MountsMgr.Instance():SetBattleMountsMap(p.battle_mounts_info_map)
  Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsBattleStatusChange, nil)
end
def.static("table").OnSMountsProtectPetSuccess = function(p)
  MountsMgr.Instance():BattleMountsProtectPet(p.cell_id, p.protect_index, p.pet_id)
  Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsProtectPet, nil)
end
def.static("table").OnSMountsUnProtectPetSuccess = function(p)
  MountsMgr.Instance():BattleMountsUnProtectPet(p.cell_id, p.protect_index, p.pet_id)
  Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsUnProtectPet, nil)
end
def.static("table").OnSMountsRefreshPassiveSkillSuccess = function(p)
  MountsMgr.Instance():SetMountsPassiveSkill(p.mounts_id, p.refresh_passive_skill_result.current_passive_skill_cfg_id, p.refresh_passive_skill_result)
  Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsResetSkillSuccess, nil)
end
def.static("table").OnSMountsReplacePassiveSkillSuccess = function(p)
  MountsMgr.Instance():SetMountsPassiveSkill(p.mounts_id, p.old_passive_skill_cfg_id, p.refresh_passive_skill_result)
  Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsReplaceSkillSuccess, {
    p.refresh_passive_skill_result.current_passive_skill_cfg_id
  })
end
def.static("table").OnSMountsDyeSuccess = function(p)
  Toast(textRes.Mounts[45])
  MountsMgr.Instance():SetMountsDyeColor(p.mounts_id, p.color_id)
  Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsDyeSuccess, nil)
end
def.static("table").OnSMountsActiveStarLifeSuccess = function(p)
  Toast(textRes.Mounts[53])
  MountsMgr.Instance():SetMountsStarNumAndLevel(p.mounts_id, p.star_num, p.star_level)
  Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsActiveStartListSuccess, nil)
end
def.static("table").OnSAppearenceMountsExpired = function(p)
  local mounts = MountsMgr.Instance():GetMountsById(p.mounts_id)
  if mounts ~= nil then
    local mountsCfg = MountsUtils.GetMountsCfgById(mounts.mounts_cfg_id)
    if mountsCfg ~= nil then
      Toast(string.format(textRes.Mounts[58], mountsCfg.mountsName))
      MountsMgr.Instance():SetMountsExpired(p.mounts_id)
      Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsListChange, nil)
    end
  end
end
def.static("table").OnSExtendMountsTimeSuccess = function(p)
  local mounts = MountsMgr.Instance():GetMountsById(p.mounts_id)
  if mounts ~= nil then
    local mountsCfg = MountsUtils.GetMountsCfgById(mounts.mounts_cfg_id)
    if mountsCfg ~= nil then
      Toast(string.format(textRes.Mounts[74], mountsCfg.mountsName))
      MountsMgr.Instance():SetMountsRemainTime(p.mounts_id, p.remain_time)
      Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsExtendTimeSuccess, nil)
    end
  end
end
def.static("table").OnSCostMountsAddScoreSuccess = function(p)
  MountsMgr.Instance():SetMountsScore(p.add_score_mounts_id, p.now_score)
  MountsMgr.Instance():RemoveMounts(p.cost_mounts_id)
  Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsAddScoreSuccess, nil)
  Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsListChange, nil)
end
def.static("table").OnSCostItemAddScoreSuccess = function(p)
  MountsMgr.Instance():SetMountsScore(p.add_score_mounts_id, p.now_score)
  Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsAddScoreSuccess, nil)
end
def.static("table").OnSMountsCostItemRankUpSuccess = function(p)
  Toast(textRes.Mounts[34])
  MountsMgr.Instance():SetMountsRankUp(p.mounts_id, p.rank_up_mounts_info)
  Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsRankUpSuccess, nil)
  require("Main.Mounts.ui.MountsUpgradePanel").ShowPanel(p.mounts_id)
end
def.static("table").OnSMountsReplaceProtectPetSuccess = function(p)
  MountsMgr.Instance():SetBattleMountsInfo(p.cell_id, p.protect_index, p.battle_mounts_info)
  Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsProtectPetChange, nil)
end
def.static("table").OnSMountsSelectOrnamentSuccess = function(p)
  MountsMgr.Instance():SetMountsOrnament(p.mounts_id, p.select_rank)
  Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsOrnamentChange, {
    p.mounts_id,
    p.select_rank
  })
end
def.static("table").OnSExpandProtectPetSizeSuccess = function(p)
  MountsMgr.Instance():SetMountsProtectPetSize(p.mounts_id, p.protect_pet_expand_size)
  Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsUnlockProtectPos, nil)
end
def.static("table").OnSMountsNormalFail = function(p)
  if textRes.Mounts.SMountsNormalFail[p.result] ~= nil then
    Toast(textRes.Mounts.SMountsNormalFail[p.result])
  else
    Toast(string.format(textRes.Mounts.SMountsNormalFail[-1], p.result))
  end
end
def.static("table", "table").OnClickMountsButton = function(params, context)
  MountsModule.OpenMountsMainPanel()
end
def.static("table", "table").OnHeroLevelUp = function(params, context)
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
  local heroProp = HeroPropMgr.heroProp
  local lastHeroProp = HeroPropMgr.lastHeroProp
  if heroProp ~= nil and lastHeroProp ~= nil then
    warn(heroProp.level, lastHeroProp.level)
    if heroProp.level >= constant.CMountsConsts.mountsOpenLevel and lastHeroProp.level < constant.CMountsConsts.mountsOpenLevel then
      Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsFunctionOpenChange, nil)
    end
  end
end
def.static("table", "table").OnFeatureOpenChange = function(params, context)
  if params.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MOUNTS then
    Event.DispatchEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsFunctionOpenChange, nil)
  end
end
def.static("=>", "boolean").IsFunctionOpen = function()
  if not MountsModule.IsReachFunctionLevel() then
    return false
  end
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MOUNTS) then
    return false
  end
  return true
end
def.static("=>", "boolean").IsReachFunctionLevel = function()
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
  local heroProp = HeroPropMgr.heroProp
  if heroProp == nil then
    return false
  end
  if heroProp.level < constant.CMountsConsts.mountsOpenLevel then
    return false
  end
  return true
end
def.static("=>", "boolean").CheckMountsOperation = function()
  if not MountsModule.IsReachFunctionLevel() then
    Toast(string.format(textRes.Mounts[59], constant.CMountsConsts.mountsOpenLevel))
    return false
  end
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MOUNTS) then
    Toast(textRes.Mounts[57])
    return false
  end
  if _G.IsCrossingServer() then
    return true
  end
  local taskId = MountsModule.GetMountsTaskId()
  if taskId == 0 then
    return true
  else
    Toast(textRes.Mounts[89])
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TASK_TRACE_ITEM_CLICK, {
      taskId,
      constant.CMountsConsts.mounts_task_map_id
    })
    return false
  end
end
def.static("=>", "number").GetMountsTaskId = function()
  local TaskInterface = require("Main.task.TaskInterface")
  local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
  local taskGraphId = constant.CMountsConsts.mounts_task_map_id
  local taskInfos = TaskInterface.Instance():GetTaskInfos()
  for taskId, graphIdValue in pairs(taskInfos) do
    for graphId, info in pairs(graphIdValue) do
      if graphId == taskGraphId and (info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT or info.state == TaskConsts.TASK_STATE_CAN_ACCEPT or info.state == TaskConsts.TASK_STATE_FINISH) then
        return taskId
      end
    end
  end
  return 0
end
def.static("number", "userdata").UnlockMounts = function(itemId, uuid)
  local checkResult = MountsModule.CheckMountsOperation()
  if not checkResult then
    return
  end
  local unlockCfg = MountsUtils.GetUnlockMountsByItemId(itemId)
  if unlockCfg ~= nil then
    if not MountsModule.Instance():IsMountsIDIPOpen(unlockCfg.mountsCfgId) then
      Toast(textRes.Mounts[137])
      return
    end
    local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
    local heroProp = HeroPropMgr.heroProp
    if heroProp.level >= unlockCfg.needRoleLevel then
      if MountsMgr.Instance():CanExtendMountsTime(itemId) then
        CommonConfirmDlg.ShowConfirm("", textRes.Mounts[75], function(result)
          if result == 1 then
            MountsMgr.Instance():ExtendMountsTime(itemId)
          end
        end, nil)
      else
        MountsMgr.Instance():UnlockMounts(uuid)
      end
    else
      Toast(string.format(textRes.Mounts[70], unlockCfg.needRoleLevel))
    end
  else
    Toast(textRes.Mounts[69])
  end
end
def.static("userdata").ShowSelfMountsInfoById = function(mountsId)
  local mounts = MountsMgr.Instance():GetMountsById(mountsId)
  if mounts == nil then
    Toast(textRes.Mounts[118])
    return
  end
  MountsModule.ShowMountsInfo(mounts)
end
def.static("table").ShowMountsInfo = function(mountsData)
  if mountsData == nil then
    Toast(textRes.Mounts[118])
    return
  end
  require("Main.Mounts.ui.MountsInfoPanel").Instance():ShowPanel(mountsData)
end
def.method("number", "=>", "boolean").IsMountsIDIPOpen = function(self, mountsCfgId)
  local IDIPInterface = require("Main.IDIP.IDIPInterface")
  local ItemSwitchInfo = require("netio.protocol.mzm.gsp.idip.ItemSwitchInfo")
  local isOpen = IDIPInterface.IsItemIDIPOpen(ItemSwitchInfo.MOUNTS, mountsCfgId)
  return isOpen
end
MountsModule.Commit()
return MountsModule
