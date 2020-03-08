local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local EntityBase = import(".EntityBase")
local GoldStatueEntity = Lplus.Extend(EntityBase, CUR_CLASS_NAME)
local ECModel = require("Model.ECModel")
local def = GoldStatueEntity.define
local MapUtility = require("Main.Map.MapUtility")
def.field("table").m_model = nil
def.field("string").m_roleName = ""
def.field("string").m_teamName = ""
def.field("number").m_teamZoneId = 0
def.field("number").m_teamBadgeId = 0
def.field("number").m_number = 0
def.override().OnCreate = function(self)
end
def.override("table").UnmarshalExtraInfo = function(self, extraInfo)
  local EntityExtraInfoType = EntityBase.MapEntityExtraInfoType
  self.m_roleName = _G.GetStringFromOcts(extraInfo.string_extra_infos[EntityExtraInfoType.MET_GOLD_STATUE_ROLE_NAME])
  self.m_teamName = _G.GetStringFromOcts(extraInfo.string_extra_infos[EntityExtraInfoType.MET_GOLD_STATUE_CORPS_NAME])
  self.m_teamZoneId = extraInfo.int_extra_infos[EntityExtraInfoType.MET_GOLD_STATUE_CORPS_ZONEID] or 0
  self.m_teamBadgeId = extraInfo.int_extra_infos[EntityExtraInfoType.MET_GOLD_STATUE_CORPS_BADGEID] or 0
  self.m_number = extraInfo.int_extra_infos[EntityExtraInfoType.MET_GOLD_STATUE_CROSS_BATTLE_NO] or 0
end
def.override().OnDestroy = function(self)
  self:OnLeaveView()
end
def.override().OnEnterView = function(self)
  self:UpdateModel()
end
def.override().OnLeaveView = function(self)
  self:DestroyModel()
end
def.method().DestroyModel = function(self)
  if self.m_model == nil then
    return
  end
  self.m_model:Destroy()
  self.m_model = nil
end
def.override("number", "table", "table").OnInfoChange = function(self, cfgid, loc, extra_info)
end
def.override("table", "table").OnExtraInfoChange = function(self, extra_info, remove_extra_info_keys)
end
def.method().UpdateModel = function(self)
  self:DestroyModel()
  local cfg = MapUtility.GetMapStatueCfg(self.cfgid)
  if cfg == nil then
    return
  end
  self.m_model = require("Model.ECPlayer").new(nil, cfg.modelId, self.m_roleName, GetColorData(701300007), RoleType.NPC)
  self.m_model.m_create_node2d = false
  self.m_model:SetDefaultParentNode(gmodule.moduleMgr:GetModule(ModuleId.MAP).mapPlayerNodeRoot)
  local function OnModelLoaded()
    local TitleInterface = require("Main.title.TitleInterface")
    local app_cfg = TitleInterface.GetAppellationCfg(cfg.appellation)
    if app_cfg then
      local color = GetColorData(app_cfg.appellationColor)
      local number_str = MapUtility.GetChineseNumber(self.m_number)
      if number_str == nil or number_str == "" then
        number_str = tostring(self.m_number)
      end
      local app_name = string.format(app_cfg.appellationName, number_str)
      self.m_model:SetTitleWithColor(app_name, color)
    end
    local cfg = TitleInterface.GetTitleCfg(cfg.title)
    if cfg then
      self.m_model:SetTitleIcon(cfg.picId)
    else
      self.m_model:SetTitleIcon(0)
    end
    local badgeCfg = require("Main.Corps.CorpsUtils").GetCorpsBadgeCfg(self.m_teamBadgeId)
    if badgeCfg then
      self.m_model:SetOrganizationIcon(badgeCfg.iconId)
    end
  end
  local modelPath = GetModelPath(cfg.modelId)
  if modelPath ~= "" then
    self.m_model:AddOnLoadCallback("onload", OnModelLoaded)
    self.m_model:LoadModel(modelPath, self.loc.x, self.loc.y, 0)
  end
end
return GoldStatueEntity.Commit()
