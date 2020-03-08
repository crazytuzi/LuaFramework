local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local MultiOccupationModule = Lplus.Extend(ModuleBase, "MultiOccupationModule")
local NPCServiceConst = require("Main.npc.NPCServiceConst")
local MultiOccupationData = require("Main.MultiOccupation.data.MultiOccupationData")
local def = MultiOccupationModule.define
local instance
def.field("table").data = nil
def.field("boolean").npcShow = false
def.static("=>", MultiOccupationModule).Instance = function()
  if nil == instance then
    instance = MultiOccupationModule()
    instance.data = MultiOccupationData.Instance()
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, MultiOccupationModule.OnNPCService)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, MultiOccupationModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, MultiOccupationModule.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, MultiOccupationModule.OnFeatureOpenChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.multioccupation.SMultiOccupationRes", MultiOccupationModule.OnSMultiOccupationRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.multioccupation.SActiveNewOccupationRes", MultiOccupationModule.OnSActiveNewOccupationRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.multioccupation.SSwitchOccupationRes", MultiOccupationModule.OnSSwitchOccupationRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.multioccupation.SMultiOccupationNormalResult", MultiOccupationModule.OnSMultiOccupationNormalResult)
  ModuleBase.Init(self)
end
def.override().OnReset = function(self)
end
def.method("=>", "table").getOwnOccupations = function(self)
  return self.data:getOwnOccupations()
end
def.method("=>", "boolean").IsFeatureOpen = function(self)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  local isOpen = feature:CheckFeatureOpen(Feature.TYPE_MULTI_OCCUPATION)
  return isOpen
end
def.method("=>", "boolean").IsLevelUnlock = function(self)
  local heroLevel = require("Main.Hero.Interface").GetBasicHeroProp().level
  return heroLevel >= constant.CMultiOccupConsts.LevelLimit
end
def.method("=>", "boolean").IsFunctionOpen = function(self)
  return self:IsFeatureOpen() and self:IsLevelUnlock()
end
def.method("number", "number", "=>", "string").GetOccupationLoadingImage = function(self, occupation, gender)
  return string.format("Arts/Image/Icons/Loading/menpai_%d_%d.png.u3dext", occupation, gender)
end
def.static("table", "table").OnNPCService = function(tbl, p2)
  local self = instance
  if not self:IsFeatureOpen() then
    warn("MultiOccupationModule . OnNPCService  IsFeatureOpen is false")
    return
  end
  local serviceId = tbl[1]
  local npcId = tbl[2]
  if serviceId == constant.CMultiOccupConsts.ActiveService then
    if self.data:isOwnAllOccupation() then
      Toast(textRes.MultiOccupation[20])
    else
      require("Main.MultiOccupation.ui.ChangeCharacterPanel").Instance():Reset()
      require("Main.MultiOccupation.ui.ChooseCharacterPanel").Instance():ShowPanel(npcId)
    end
  elseif serviceId == constant.CMultiOccupConsts.SwitchService then
    if 1 >= self.data:getOwnOccupationCount() then
      Toast(textRes.MultiOccupation[12])
    else
      require("Main.MultiOccupation.ui.ChooseCharacterPanel").Instance():Reset()
      require("Main.MultiOccupation.ui.ChangeCharacterPanel").Instance():ShowPanel(npcId)
    end
  end
end
def.static("table", "table").OnEnterWorld = function(params, context)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.multioccupation.CMultiOccupationReq").new())
end
def.static("table", "table").OnFeatureOpenInit = function(tbl, p2)
  local self = instance
  local npcShow = self:IsFeatureOpen()
  local npcId = constant.CMultiOccupConsts.npc
  self.npcShow = npcShow
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {npcid = npcId, show = npcShow})
end
def.static("table", "table").OnFeatureOpenChange = function(tbl, p2)
  local self = instance
  local npcShow = self:IsFeatureOpen()
  local npcId = constant.CMultiOccupConsts.npc
  if npcShow ~= self.npcShow then
    self.npcShow = npcShow
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {npcid = npcId, show = npcShow})
  end
end
def.static("table").OnSMultiOccupationRes = function(p)
  local self = instance
  self.data:sysOccupationInfo(p.activated_occpations)
  self.data:setSwitchTime(p.switch_time:ToNumber() / 1000)
  self.data:setActivateTime(p.activate_time:ToNumber() / 1000)
  Event.DispatchEvent(ModuleId.MULTIOCCUPATION, gmodule.notifyId.MultiOccupation.MultiOccupationInfo, nil)
end
def.static("table").OnSActiveNewOccupationRes = function(p)
  local self = instance
  self.data:addOwnOccupation(p.new_occupation)
  self.data:setActivateTime(GetServerTime())
  Event.DispatchEvent(ModuleId.MULTIOCCUPATION, gmodule.notifyId.MultiOccupation.OccupationChange, {
    add = true,
    newid = p.new_occupation
  })
end
def.static("table").OnSSwitchOccupationRes = function(p)
  local self = instance
  self.data:setSwitchTime(GetServerTime())
  Event.DispatchEvent(ModuleId.MULTIOCCUPATION, gmodule.notifyId.MultiOccupation.OccupationChange, {
    add = false,
    newid = p.new_occupation
  })
end
def.static("table").OnSMultiOccupationNormalResult = function(p)
  local resultMsg = textRes.MultiOccupation.ErrorCode[p.result]
  if resultMsg then
    Toast(resultMsg)
  else
    warn("OnSMultiOccupationNormalResult:", p.result)
  end
end
def.method().StartLoadingScene = function(self)
  local prefab = GameUtil.SyncLoad(RESPATH.PREFAB_LODING_PANEL_RES)
  local LoadingMgr = require("Main.Common.LoadingMgr")
  if LoadingMgr.Instance().loadingType == 0 then
    LoadingMgr.Instance():StartLoading(LoadingMgr.LoadingType.Other, {
      [1] = 1
    }, nil, nil)
    do
      local loadingTimer = 0
      local curTimeCount = 0
      local maxTimeCount = 30
      loadingTimer = GameUtil.AddGlobalTimer(0.1, false, function(...)
        curTimeCount = curTimeCount + 1
        if curTimeCount >= maxTimeCount then
          GameUtil.RemoveGlobalTimer(loadingTimer)
          loadingTimer = 0
          if LoadingMgr.Instance().loadingType == LoadingMgr.LoadingType.Other then
            LoadingMgr.Instance():UpdateTaskProgress(1, 1)
          end
        elseif LoadingMgr.Instance().loadingType == LoadingMgr.LoadingType.Other then
          LoadingMgr.Instance():UpdateTaskProgress(1, curTimeCount / maxTimeCount)
        end
      end)
    end
  end
end
MultiOccupationModule.Commit()
return MultiOccupationModule
