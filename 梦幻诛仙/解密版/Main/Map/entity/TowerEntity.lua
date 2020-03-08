local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local EntityBase = import(".EntityBase")
local TowerEntity = Lplus.Extend(EntityBase, CUR_CLASS_NAME)
local CaptureTheFlagUtils = require("Main.CaptureTheFlag.CaptureTheFlagUtils")
local BattleFieldMgr = require("Main.CaptureTheFlag.mgr.BattleFieldMgr")
local ECTower = require("Main.CaptureTheFlag.model.ECTower")
local MapModule = require("Main.Map.MapModule")
local EC = require("Types.Vector3")
local def = TowerEntity.define
def.field("number").campId = 0
def.field("table").towerCfg = nil
def.field(ECTower).model = nil
def.field("userdata").tile = nil
def.override().OnCreate = function(self)
  self.towerCfg = CaptureTheFlagUtils.GetTowerCfg(self.cfgid)
end
def.override("table").UnmarshalExtraInfo = function(self, extra_info)
  local ExtraInfoType = EntityBase.MapEntityExtraInfoType
  self.campId = extra_info.int_extra_infos[ExtraInfoType.MET_SINGLE_BATTLE_POSITION_CAMPID]
end
def.override().OnDestroy = function(self)
  self:OnLeaveView()
end
def.override().OnEnterView = function(self)
  self:DestroyModel()
  local function onTowerLoad(ret)
    if ret then
      self.model:CreateHUD()
      self:SetTowerState()
    end
  end
  self.model = ECTower.new(self.cfgid)
  local modelId = self.towerCfg.defaultPositionMapCfg.modelId
  local tileId = self.towerCfg.defaultPositionMapCfg.mapModelId
  local tileX, tileY = self.towerCfg.defaultPositionMapCfg.positionX, self.towerCfg.defaultPositionMapCfg.positionY
  if self.campId ~= 0 and self.towerCfg.camps[self.campId] then
    modelId = self.towerCfg.camps[self.campId].modelId
    tileId = self.towerCfg.camps[self.campId].mapModelId
    tileX, tileY = self.towerCfg.camps[self.campId].positionX, self.towerCfg.camps[self.campId].positionY
  end
  local modelPath = GetModelPath(modelId)
  self.model:SetName(self.towerCfg.positionName, Color.white)
  self.model:Load2(modelPath, onTowerLoad, false)
  if tileId > 0 then
    local tilePath = GetModelPath(tileId)
    GameUtil.AsyncLoad(tilePath, function(obj)
      if self.towerCfg then
        self.tile = Object.Instantiate(obj)
        self.tile.parent = MapModule.Instance().mapNodeRoot
        self.tile.localScale = EC.Vector3.one
        self.tile.localPosition = EC.Vector3.new(tileX, world_height - tileY, 100)
        self.tile.layer = ClientDef_Layer.Default
      end
    end)
  end
end
def.method().SetTowerState = function(self)
  if self.model then
    if self.campId == 0 then
      self.model:SetTitleIcon(self.towerCfg.defaultPositionMapCfg.iconId)
      self.model:SetName("", Color.white)
    else
      local cfg = self.towerCfg.camps[self.campId]
      if cfg then
        self.model:SetTitleIcon(cfg.iconId)
      else
        self.model:SetTitleIcon(self.towerCfg.defaultPositionMapCfg.iconId)
      end
      local my = BattleFieldMgr.Instance():IsMyTeam(self.campId)
      if my then
        self.model:SetName("", Color.green)
      else
        self.model:SetName("", Color.red)
      end
    end
    self.model:SetPos(self.loc.x, self.loc.y)
  end
end
def.override().OnLeaveView = function(self)
  self:DestroyModel()
  self.campId = 0
  self.towerCfg = nil
end
def.method().DestroyModel = function(self)
  if self.model then
    self.model:Destroy()
    self.model = nil
  end
  if self.tile then
    if not self.tile.isnil then
      Object.Destroy(self.tile)
    end
    self.tile = nil
  end
end
def.override("number", "table", "table").OnInfoChange = function(self, cfgid, loc, extra_info)
  self.cfgid = cfgid
  self.loc = loc
  self:UnmarshalExtraInfo(extra_info)
  self:OnEnterView()
end
def.override("table", "table").OnExtraInfoChange = function(self, extra_info, remove_extra_info_keys)
  local ExtraInfoType = EntityBase.MapEntityExtraInfoType
  if extra_info.int_extra_infos[ExtraInfoType.MET_SINGLE_BATTLE_POSITION_CAMPID] then
    self.campId = extra_info.int_extra_infos[ExtraInfoType.MET_SINGLE_BATTLE_POSITION_CAMPID]
  end
  if remove_extra_info_keys[ExtraInfoType.MET_CAMP_ID] then
    self.campId = 0
  end
  self:OnEnterView()
end
def.override("table").OnSyncMove = function(self, locs)
  if self.model then
    self.model:SetPos(self.loc.x, self.loc.y)
  end
end
return TowerEntity.Commit()
