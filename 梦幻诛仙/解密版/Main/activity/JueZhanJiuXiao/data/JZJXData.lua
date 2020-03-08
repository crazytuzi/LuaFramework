local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local JZJXData = Lplus.Class(CUR_CLASS_NAME)
local def = JZJXData.define
local JZJXMapData = import(".JZJXMapData")
def.field("table").mapDatas = nil
def.field("number").curLayerCfgId = 0
def.static("=>", JZJXData).New = function()
  local instance = JZJXData()
  instance:Ctor()
  return instance
end
def.method().Ctor = function(self)
  self.mapDatas = {}
end
def.method("table").RawSet = function(self, p)
  self.mapDatas = self.mapDatas or {}
  for i, mapDataBean in ipairs(p.mapDataBeans) do
    self.mapDatas[i] = self.mapDatas[i] or JZJXMapData()
    self.mapDatas[i]:RawSet(mapDataBean)
  end
end
def.method("table").UpdateLayerMapData = function(self, mapDataBean)
  local JZJXMgr = import("..JZJXMgr", CUR_CLASS_NAME)
  local cfgid = mapDataBean.cfgid or 0
  local layer = JZJXMgr.Instance():GetMapLayer(cfgid)
  self.mapDatas[cfgid] = self.mapDatas[cfgid] or JZJXMapData()
  self.mapDatas[cfgid]:RawSet(mapDataBean)
  self.curLayerCfgId = cfgid
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_JZJX_SyncLayerMapData, {cfgid})
end
def.method("=>", JZJXMapData).GetCurLayerMapData = function(self)
  if self.mapDatas == nil then
    return nil
  end
  return self.mapDatas[self.curLayerCfgId]
end
def.method("number", "boolean").SetDefeatBossState = function(self, cfgid, isDefeat)
  if self.mapDatas[cfgid] == nil then
    self.mapDatas[cfgid] = JZJXMapData()
  end
  self.mapDatas[cfgid].isDefeatBoss = isDefeat
  if cfgid == self.curLayerCfgId then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_JZJX_SyncLayerMapData, {cfgid})
  end
end
return JZJXData.Commit()
