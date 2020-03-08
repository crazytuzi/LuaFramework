local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local EntityBase = import(".EntityBase")
local AnniversayParadeEntity = Lplus.Extend(EntityBase, CUR_CLASS_NAME)
local def = AnniversayParadeEntity.define
local NpcModel = require("Main.Pubrole.NpcModel")
local ECPlayer = Lplus.ForwardDeclare("ECPlayer")
local NPCInterface = require("Main.npc.NPCInterface")
local Vector = require("Types.Vector")
local ECGame = require("Main.ECGame")
def.const("number").DEFAULT_NAME_COLOR_ID = 701300008
def.field("table").vehicle = nil
def.field("table").host = nil
def.field("table").hostess = nil
def.field("userdata").host_roleid = nil
def.field("userdata").hostess_roleid = nil
def.field("number").vehicle_ocp = 0
def.field("number").velocity = 100
def.field("table").master = nil
def.field("table").masteress = nil
def.field("userdata").range_fx = nil
def.override().OnCreate = function(self)
end
def.override("table").UnmarshalExtraInfo = function(self, extra_info)
  local ExtraInfoType = EntityBase.MapEntityExtraInfoType
  self.host_roleid = extra_info.long_extra_infos[ExtraInfoType.MET_FLOAT_PARADE_MALE]
  self.hostess_roleid = extra_info.long_extra_infos[ExtraInfoType.MET_FLOAT_PARADE_FEMAIL]
  self.vehicle_ocp = extra_info.int_extra_infos[ExtraInfoType.MET_FLOAT_PARADE_OCP]
  self.velocity = extra_info.int_extra_infos[ExtraInfoType.MET_FLOAT_PARADE_VELOCITY]
end
def.override().OnDestroy = function(self)
  self:OnLeaveView()
end
def.override().OnEnterView = function(self)
  gmodule.moduleMgr:GetModule(ModuleId.ANNIVERSARY):PlayCountDown()
  self:LoadModel()
end
def.override().OnLeaveView = function(self)
  if self.host then
    self.host:Destroy()
  end
  self.host = nil
  if self.hostess then
    self.hostess:Destroy()
  end
  self.hostess = nil
  if self.master then
    self.master:Destroy()
  end
  self.master = nil
  if self.masteress then
    self.masteress:Destroy()
  end
  self.masteress = nil
  if self.range_fx then
    require("Fx.ECFxMan").Instance():Stop(self.range_fx)
    self.range_fx = nil
  end
  if self.vehicle then
    self.vehicle:Destroy()
  end
  self.vehicle = nil
end
def.override("number", "table", "table").OnInfoChange = function(self, cfgid, loc, extra_info)
end
def.override("table", "table").OnExtraInfoChange = function(self, extra_info, remove_extra_info_keys)
  local ExtraInfoType = EntityBase.MapEntityExtraInfoType
end
def.override("number").Update = function(self, dt)
  if self.vehicle == nil then
    return
  end
  local x, y, z = self.vehicle.m_node2d:GetPosXYZ()
  local map_scene = gmodule.moduleMgr:GetModule(ModuleId.MAP).scene
  if MapScene.IsTransparent(map_scene, x, y) then
    if self.vehicle.m_IsAlpha == false then
      self.vehicle:SetAlpha(0.55)
      if self.host then
        self.host:SetAlpha(0.55)
        if self.host.mECWingComponent then
          self.host.mECWingComponent:SetAlpha(0.55)
        end
        if self.host.mECFabaoComponent then
          self.host.mECFabaoComponent:SetAlpha(0.55)
        end
      end
      if self.hostess then
        self.hostess:SetAlpha(0.55)
        if self.hostess.mECWingComponent then
          self.hostess.mECWingComponent:SetAlpha(0.55)
        end
        if self.hostess.mECFabaoComponent then
          self.hostess.mECFabaoComponent:SetAlpha(0.55)
        end
      end
      if self.master then
        self.master:SetAlpha(0.55)
        if self.master.mECWingComponent then
          self.master.mECWingComponent:SetAlpha(0.55)
        end
        if self.master.mECFabaoComponent then
          self.master.mECFabaoComponent:SetAlpha(0.55)
        end
      end
      if self.masteress then
        self.masteress:SetAlpha(0.55)
        if self.masteress.mECWingComponent then
          self.masteress.mECWingComponent:SetAlpha(0.55)
        end
        if self.masteress.mECFabaoComponent then
          self.masteress.mECFabaoComponent:SetAlpha(0.55)
        end
      end
    end
  elseif self.vehicle.m_IsAlpha == true then
    self.vehicle:CloseAlpha()
    if self.host then
      self.host:CloseAlpha()
      if self.host.mECWingComponent then
        self.host.mECWingComponent:CloseAlpha()
      end
      if self.host.mECFabaoComponent then
        self.host.mECFabaoComponent:CloseAlpha()
      end
    end
    if self.hostess then
      self.hostess:CloseAlpha()
      if self.hostess.mECWingComponent then
        self.hostess.mECWingComponent:CloseAlpha()
      end
      if self.hostess.mECFabaoComponent then
        self.hostess.mECFabaoComponent:CloseAlpha()
      end
    end
    if self.master then
      self.master:CloseAlpha()
      if self.master.mECWingComponent then
        self.master.mECWingComponent:CloseAlpha()
      end
      if self.master.mECFabaoComponent then
        self.master.mECFabaoComponent:CloseAlpha()
      end
    end
    if self.masteress then
      self.masteress:CloseAlpha()
      if self.masteress.mECWingComponent then
        self.masteress.mECWingComponent:CloseAlpha()
      end
      if self.masteress.mECFabaoComponent then
        self.masteress.mECFabaoComponent:CloseAlpha()
      end
    end
  end
end
local function CreateNpc(npcId)
  local npccfg = NPCInterface.GetNPCCfg(npcId)
  local npcModelId = npccfg.monsterModelTableId
  local npc = NpcModel.new(npccfg.NpcID, npcModelId, npccfg.npcName, nameColor, RoleType.NPC)
  npc.runSpeed = 0
  if 0 < npccfg.outlookid then
    local appearanceCfg = GetAppearanceCfg(npccfg.outlookid)
    if 0 < appearanceCfg.weaponId then
      npc:SetWeapon(appearanceCfg.weaponId, 0)
    end
    if 0 < appearanceCfg.wingId then
      npc:SetWing(appearanceCfg.wingId, 0)
    end
    if 0 < appearanceCfg.flyMountId then
      npc:SetFeijianId(appearanceCfg.flyMountId)
    end
    npc:SetOrnament(appearanceCfg.isShowDecorateItem)
    if appearanceCfg.scaleRate and appearanceCfg.scaleRate ~= 1 then
      npc:SetModelScaleValue(appearanceCfg.scaleRate)
    end
  end
  return npc
end
def.method().LoadModel = function(self)
  self:OnLeaveView()
  local AnniversaryUtils = require("Main.activity.Anniversary.AnniversaryUtils")
  local ocp_info = AnniversaryUtils.GetParadeOccupationCfg(1, self.vehicle_ocp)
  local function OnLoadEnd()
    if self.vehicle and self.vehicle:IsLoaded() and self.host and self.host:IsLoaded() and self.hostess and self.hostess:IsLoaded() and self.master and self.master:IsLoaded() and self.masteress and self.masteress:IsLoaded() then
      local rot = Vector.Vector3.new(90, -90, 0)
      self.vehicle:AttachModelEx("host", self.host, "Bip01 ZuoQi", Vector.Vector3.zero, rot)
      self.vehicle:AttachModelEx("hostess", self.hostess, "Bip01 ZuoQi02", Vector.Vector3.zero, rot)
      self.vehicle:AttachModelEx("master", self.master, "Bip01 ZuoQi03", Vector.Vector3.zero, rot)
      self.vehicle:AttachModelEx("masteress", self.masteress, "Bip01 ZuoQi04", Vector.Vector3.zero, rot)
    end
  end
  local pubMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  local nameColor = GetColorData(701300300)
  self.vehicle = ECPlayer.new(nil, ocp_info.modelId, "", nameColor, RoleType.NPC)
  self.vehicle.defaultLayer = ClientDef_Layer.NPC
  self.vehicle.clickPriority = 0
  self.vehicle.runSpeed = self.velocity
  self.vehicle:AddOnLoadCallback("AnniversaryParade", function()
    local parade_cfg = AnniversaryUtils.GetAnniversaryParadeCfg(constant.FlowerParadeConstCfg.activityId)
    local effcfg = GetEffectRes(parade_cfg.flowerRadiusEffectId)
    if self.range_fx then
      require("Fx.ECFxMan").Instance():Stop(self.range_fx)
    end
    self.range_fx = require("Fx.ECFxMan").Instance():PlayAsChild(effcfg.path, self.vehicle.m_model, Vector.Vector3.zero, Quaternion.identity, -1, false, -1)
    if self.range_fx then
      self.range_fx.localScale = Vector.Vector3.one * (ocp_info.radius * 2 * cam_2d_to_3d_scale / 0.95)
    end
    OnLoadEnd()
  end)
  self.vehicle:LoadCurrentModel(self.loc.x, self.loc.y, 0)
  if self.host_roleid:eq(0) then
    self.host = CreateNpc(constant.FlowerParadeConstCfg.maleId)
    self.host:SetTouchable(false)
    self.host:AddOnLoadCallback("AnniversaryParade", OnLoadEnd)
    self.host:LoadCurrentModel(0, 0, 0)
  else
    local function load_host(modelInfo)
      self.host = ECPlayer.new(self.host_roleid, modelInfo.modelid, modelInfo.name, nameColor, RoleType.NPC)
      self.host.enableIdleAct = false
      self.host.checkAlpha = false
      self.host:SetTouchable(false)
      self.host:AddOnLoadCallback("AnniversaryParade", OnLoadEnd)
      _G.LoadModel(self.host, modelInfo, 0, 0, 0, false, false)
    end
    pubMgr:GetServerRoleModelInfo(self.host_roleid, load_host)
  end
  if self.hostess_roleid:eq(0) then
    self.hostess = CreateNpc(constant.FlowerParadeConstCfg.femaleId)
    self.hostess:SetTouchable(false)
    self.hostess:AddOnLoadCallback("AnniversaryParade", OnLoadEnd)
    self.hostess:LoadCurrentModel(0, 0, 0)
  else
    local function load_hostess(modelInfo)
      self.hostess = ECPlayer.new(self.hostess_roleid, modelInfo.modelid, modelInfo.name, nameColor, RoleType.NPC)
      self.hostess.enableIdleAct = false
      self.hostess.checkAlpha = false
      self.hostess:SetTouchable(false)
      self.hostess:AddOnLoadCallback("AnniversaryParade", OnLoadEnd)
      _G.LoadModel(self.hostess, modelInfo, 0, 0, 0, false, false)
    end
    pubMgr:GetServerRoleModelInfo(self.hostess_roleid, load_hostess)
  end
  self.master = CreateNpc(ocp_info.ocpRole1)
  self.master:SetTouchable(false)
  self.master:AddOnLoadCallback("AnniversaryParade", OnLoadEnd)
  self.master:LoadCurrentModel(0, 0, 0)
  self.masteress = CreateNpc(ocp_info.ocpRole2)
  self.masteress:SetTouchable(false)
  self.masteress:AddOnLoadCallback("AnniversaryParade", OnLoadEnd)
  self.masteress:LoadCurrentModel(0, 0, 0)
  self.vehicle:RunPath(self.locs, self.vehicle.runSpeed, nil)
end
def.method("number", "number", "number", "function").MoveTo = function(self, x, y, distance, cb)
  if self.vehicle == nil or self.vehicle:IsDestroyed() then
    return
  end
  local pos = self.vehicle.m_node2d.localPosition
  local findpath = gmodule.moduleMgr:GetModule(ModuleId.MAP):FindPath(pos.x, pos.y, x, y, distance)
  if findpath == nil or #findpath == 0 then
    return
  end
  self.vehicle:RunPath(findpath, self.vehicle.runSpeed, cb)
end
def.method().PlayRandomAnimation = function(self)
  local phase = self.period
  local animations = ChildrenInterface.GetChildAnimationByPhase(phase) or {}
  if #animations == 0 then
    warn("PlayRandomAnimation:No animations!")
    return
  end
  local animation = animations[math.random(#animations)]
  self:PlayAnimation(animation)
end
def.method("string").PlayAnimation = function(self, animation)
  local ecmodel = self.vehicle
  if ecmodel == nil or ecmodel:IsDestroyed() then
    return
  end
  if ecmodel.movePath ~= nil then
    print("can't play animation when move")
    return
  end
  ecmodel:SetIdleTime()
  ecmodel:PlayAnimationThenStand(animation)
end
def.override("table").OnSyncMove = function(self, locs)
  if self.vehicle == nil or self.vehicle:IsDestroyed() then
    return
  end
  self.vehicle:RunPath(locs, self.vehicle.runSpeed, cb)
end
def.override("=>", "table").GetPos = function(self)
  if self.vehicle == nil or self.vehicle:IsDestroyed() then
    return self.loc
  end
  return self.vehicle:GetPos()
end
return AnniversayParadeEntity.Commit()
