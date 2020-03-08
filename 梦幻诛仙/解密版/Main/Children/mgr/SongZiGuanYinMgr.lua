local Lplus = require("Lplus")
local SongZiGuanYinMgr = Lplus.Class("SongZiGuanYinMgr")
local SongZiGuanYin = require("Main.Children.ui.SongZiGuanYin")
local GongOn = require("Main.Children.ui.GongOn")
local QiuQian = require("Main.Children.ui.BeenSwamped")
local def = SongZiGuanYinMgr.define
local instance
def.static("=>", SongZiGuanYinMgr).Instance = function()
  if instance == nil then
    instance = SongZiGuanYinMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SAttendGuanYinShangGongFail", SongZiGuanYin.OnAttenGongOnFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shanggong.SStartShangGong", GongOn.OnStartAttenGongOn)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SAttendGuanYinQiuQianFail", SongZiGuanYin.OnAttenQiuQianFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qiuqian.SStartQiuQian", QiuQian.OnStartToSign)
  GongOn.Instance():RegisterProtocols()
  QiuQian.Instance():RegisterProtocols()
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, SongZiGuanYin.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, GongOn.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, QiuQian.OnFeatureOpenChange)
end
return SongZiGuanYinMgr.Commit()
