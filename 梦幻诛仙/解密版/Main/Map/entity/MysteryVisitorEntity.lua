local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local EntityBase = import(".EntityBase")
local MysteryVisitorEntity = Lplus.Extend(EntityBase, CUR_CLASS_NAME)
local def = MysteryVisitorEntity.define
def.field("table")._ecmodel = nil
def.field("table").m_Name2Part = nil
def.override().OnCreate = function(self)
end
def.override("table").UnmarshalExtraInfo = function(self, extra_info)
end
def.override().OnDestroy = function(self)
  self:OnLeaveView()
end
def.override().OnEnterView = function(self)
  self:UpdateHomelandNPCEntity()
end
def.override().OnLeaveView = function(self)
  warn(">>>>>OnLeaveView")
  if self._ecmodel and not self._ecmodel:IsDestroyed() then
    self._ecmodel:Destroy()
  end
  self._ecmodel = nil
  self.m_Name2Part = nil
end
def.override("number", "table", "table").OnInfoChange = function(self, cfgid, loc, extra_info)
  self.cfgid = cfgid
  self.loc = loc
  self:UpdateHomelandNPCEntity()
end
def.override("table", "table").OnExtraInfoChange = function(self, extra_info, remove_extra_info_keys)
end
def.override("number").Update = function(self, dt)
end
local HomeVisitorUtils = require("Main.Homeland.homeVisitor.HomeVisitorUtils")
local HomelandModule = require("Main.Homeland.HomelandModule")
def.method().UpdateHomelandNPCEntity = function(self)
  if self.instanceid ~= require("Main.Hero.HeroModule").Instance().roleId then
    return
  end
  local cfgInfo = HomeVisitorUtils.GetCfgInfoById(self.cfgid)
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.CfgIdChange, {
    self.cfgid
  })
  cfgInfo.map_cfg_id = require("Main.Map.MapModule").Instance():GetMapId()
  if cfgInfo == nil then
    return
  end
  if cfgInfo.npc_id ~= 0 then
    if self._ecmodel and self._ecmodel.m_cfgId ~= cfgInfo.npc_id then
      self._ecmodel:Destroy()
      self._ecmodel = nil
    end
    if self._ecmodel == nil then
      do
        local npcData = {
          instanceid = self.instanceid,
          x = self.loc.x,
          y = self.loc.y,
          dir = 180,
          npcId = cfgInfo.npc_id,
          mapId = cfgInfo.map_cfg_id,
          extraInfo = {
            entityInstanceId = self.instanceid
          }
        }
        local npc = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):CreateUserNpc(npcData)
        self._ecmodel = npc
        self._ecmodel.extraInfo.npc = npc
        self._ecmodel.extraInfo.cfgid = self.cfgid
        local function loadCallBack()
          if npc.m_model and not npc.m_model.isnil then
            self:UpdateModelName2Part(npc.m_model)
            self:UpdateEntityPart(self._ecmodel.m_model)
          end
        end
        if npc:IsInLoading() then
          npc:AddOnLoadCallback("update_npc_entity_part", loadCallBack)
        else
          loadCallBack()
        end
      end
    else
      self:UpdateEntityPart(self._ecmodel.m_model)
    end
  else
    self:UpdateCustomEntity()
  end
end
def.method("userdata").UpdateModelName2Part = function(self, model)
  if model and not model.isnil then
    local childCount = model:get_childCount()
    self.m_Name2Part = {}
    for i = 0, childCount - 1 do
      local child = model:GetChild(i)
      child:SetActive(false)
      self.m_Name2Part[child.name] = child
    end
  end
end
def.method("userdata").UpdateEntityPart = function(self, model)
  if model and not model.isnil and self.m_Name2Part then
    for k, v in pairs(self.m_Name2Part) do
      v:SetActive(true)
    end
  end
end
def.method().UpdateCustomEntity = function(self)
  warn("No Entity npc")
end
return MysteryVisitorEntity.Commit()
