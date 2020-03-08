local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local EntityBase = import(".EntityBase")
local ChristmasTreeEntity = Lplus.Extend(EntityBase, CUR_CLASS_NAME)
local ChristmasTreeModel = require("Main.activity.ChristmasTree.ui.ChristmasTreeModel")
local def = ChristmasTreeEntity.define
def.field("string").rolename = ""
def.field("userdata").ownerId = nil
def.field("table").stockStatus = nil
def.field("table").m_ecmodel = nil
def.override("table").UnmarshalExtraInfo = function(self, extra_info)
  local ExtraInfoType = EntityBase.MapEntityExtraInfoType
  local rolename = extra_info.string_extra_infos[ExtraInfoType.MET_CHRISTMAS_STOCKING_OWNER_NAME]
  self.rolename = rolename and _G.GetStringFromOcts(rolename) or self.rolename
  self.ownerId = extra_info.long_extra_infos[ExtraInfoType.MET_CHRISTMAS_STOCKING_OWNER] or self.ownerId
  self.stockStatus = self.stockStatus or {}
  for i = 1, constant.CChristmasStockingConsts.TREE_HANG_MAX_NUM do
    self.stockStatus[i] = extra_info.int_extra_infos[ExtraInfoType.MET_CHRISTMAS_STOCKING_POS_START + i - 1] or self.stockStatus[i]
  end
end
def.override().OnDestroy = function(self)
  self:OnLeaveView()
end
def.override().OnEnterView = function(self)
  self:CreateChristmasTree()
  Event.RegisterEventWithContext(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, ChristmasTreeEntity.OnNewDay, self)
end
def.override().OnLeaveView = function(self)
  self:DestroyChristmasTree()
  Event.UnregisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, ChristmasTreeEntity.OnNewDay)
end
def.override("number", "table", "table").OnInfoChange = function(self, cfgid, loc, extra_info)
  self.cfgid = cfgid
  self.loc = loc
  self:UnmarshalExtraInfo(extra_info)
  self:UpdateChristmasTreeInfo()
end
def.override("table", "table").OnExtraInfoChange = function(self, extra_info, remove_extra_info_keys)
  self:UnmarshalExtraInfo(extra_info)
  self:UpdateChristmasTreeInfo()
end
def.method().CreateChristmasTree = function(self)
  if self.m_ecmodel and not self.m_ecmodel:IsDestroyed() then
    self.m_ecmodel:Destroy()
  end
  local function onModelLoad()
    if not _G.IsNil(self.m_ecmodel) then
      self:UpdateChristmasTreeInfo()
    end
  end
  local modelId = constant.CChristmasStockingConsts.TREE_MODEL_CFG_ID
  self.m_ecmodel = ChristmasTreeModel.new(modelId)
  self.m_ecmodel:SetRoleInfo(self.ownerId, self.rolename)
  self.m_ecmodel:AddOnLoadCallback("ChristmasTreeEntity", onModelLoad)
  self.m_ecmodel:LoadCurrentModel(self.loc.x, self.loc.y, 180)
end
def.method().UpdateChristmasTreeInfo = function(self)
  if self.m_ecmodel or self.m_ecmodel:IsLoaded() then
    self.m_ecmodel:SetStockStatusOnTree(self.stockStatus)
  end
end
def.method().DestroyChristmasTree = function(self)
  if self.m_ecmodel and not self.m_ecmodel:IsDestroyed() then
    self.m_ecmodel:Destroy()
  end
  self.m_ecmodel = nil
end
def.method("table").OnNewDay = function(self, params)
  local SGetStockingInfoSuccess = require("netio.protocol.mzm.gsp.christmasstocking.SGetStockingInfoSuccess")
  for i = 1, constant.CChristmasStockingConsts.TREE_HANG_MAX_NUM do
    if self.stockStatus[i] == SGetStockingInfoSuccess.POSITION_HANGING then
      self.stockStatus[i] = SGetStockingInfoSuccess.POSITION_WITH_AWARD
    end
  end
  self:UpdateChristmasTreeInfo()
end
return ChristmasTreeEntity.Commit()
