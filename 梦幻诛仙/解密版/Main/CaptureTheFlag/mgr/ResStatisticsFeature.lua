local Lplus = require("Lplus")
local BattleFeature = require("Main.CaptureTheFlag.mgr.BattleFeature")
local ResStatisticsFeature = Lplus.Extend(BattleFeature, "ResStatisticsFeature")
local RobResPointFeature = require("Main.CaptureTheFlag.mgr.RobResPointFeature")
local RobGroundResFeature = require("Main.CaptureTheFlag.mgr.RobGroundResFeature")
local PlayType = require("consts.mzm.gsp.singlebattle.confbean.PlayType")
local def = ResStatisticsFeature.define
local instance
def.final("=>", "table").Instance = function()
  if instance == nil then
    instance = ResStatisticsFeature()
    instance.playType = PlayType.RESOURCE_POINT
  end
  return instance
end
def.field("function").m_statisticReq = nil
def.field("table").readyRecord = nil
def.override().Init = function(self)
end
def.override().OnEnterBattle = function(self, data)
  self.readyRecord = {RobResPointFeature = false, RobGroundResFeature = false}
end
def.override("number").OnEnterStage = function(self, stage)
end
def.override().OnQuitBattle = function(self)
  self:Reset()
end
def.override().Reset = function(self)
  self.m_statisticReq = nil
  self.readyRecord = nil
end
def.override("=>", "string").GetExtraName = function(self)
  return textRes.CaptureTheFlag[101]
end
def.override("userdata", "=>", "string").GetFinalData = function(self, roleId)
  local finalData1 = RobResPointFeature.Instance():GetFinalData(roleId)
  local finalData2 = RobResPointFeature.Instance():GetFinalData(roleId)
  local finalData = tostring((tonumber(finalData1) or 0) + (tonumber(finalData2) or 0))
  return finalData
end
def.override("function").IsStatisticsReady = function(self, func)
  self.m_statisticReq = func
  RobResPointFeature.Instance():IsStatisticsReady(function()
    ResStatisticsFeature.FeatureReady("RobResPointFeature")
  end)
  RobGroundResFeature.Instance():IsStatisticsReady(function()
    ResStatisticsFeature.FeatureReady("RobGroundResFeature")
  end)
end
def.static("string").FeatureReady = function(feature)
  local self = ResStatisticsFeature.Instance()
  self.readyRecord[feature] = true
  local ready = true
  for k, v in pairs(self.readyRecord) do
    if v == false then
      ready = false
      break
    end
  end
  if ready and self.m_statisticReq then
    self.m_statisticReq()
    self.m_statisticReq = nil
  end
end
return ResStatisticsFeature.Commit()
