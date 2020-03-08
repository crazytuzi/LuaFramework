local MODULE_NAME = (...)
local Lplus = require("Lplus")
local QingYunZhiProtocol = Lplus.Class(MODULE_NAME)
local QingYunZhiModule = Lplus.ForwardDeclare("QingYunZhiModule")
local QingYunZhiData = require("Main.QingYunZhi.data.QingYunZhiData")
local def = QingYunZhiProtocol.define
local __Debug = false
local gmodule = gmodule
local GameUtil = GameUtil
if __Debug then
  gmodule = {
    network = {}
  }
  function gmodule.network.sendProtocol(p)
    warn("fake sendProtocol " .. p.__cname, debug.traceback())
  end
else
  GameUtil = {
    AddGlobalTimer = function()
    end
  }
end
def.static().Init = function()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingyunzhi.SSynQingProgress", QingYunZhiProtocol.OnSynQingProgress)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingyunzhi.SSynQingSingleProgress", QingYunZhiProtocol.OnSynQingSingleProgress)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingyunzhi.SQingNormalResult", QingYunZhiProtocol.OnQingNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingyunzhi.SSynHelpAwardInfo", QingYunZhiProtocol.OnSSynHelpAwardInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingyunzhi.SNoMoreAwardNotice", QingYunZhiProtocol.OnSNoMoreAwardNotice)
end
def.static("table").OnSynQingProgress = function(p)
  local moduleInstance = QingYunZhiModule.Instance()
  for k, v in pairs(p.type2Progress) do
    moduleInstance:synQingSingleProgress(k, v.chapter, v.section)
  end
end
def.static("table").OnSynQingSingleProgress = function(p)
  local moduleInstance = QingYunZhiModule.Instance()
  moduleInstance:synQingSingleProgress(p.outPostType, p.chapter, p.section)
end
def.static("table").OnQingNormalResult = function(p)
  local args = p.args
  local errorDes = textRes.QingYunZhi.ErrorCode[p.result]
  if errorDes then
    if args and #args > 0 then
      Toast(string.format(errorDes, unpack(args)))
    else
      Toast(errorDes)
    end
  else
    Toast(textRes.QingYunZhi[4] .. p.result)
  end
end
def.static("table").OnSSynHelpAwardInfo = function(p)
  local name = textRes.QingYunZhi.Name[p.outPostType]
  if name then
    Toast(string.format(textRes.QingYunZhi[8], name, p.leftHelpCount))
  end
end
def.static("table").OnSNoMoreAwardNotice = function(p)
  local name = textRes.QingYunZhi.Name[p.outPostType]
  if name then
    Toast(string.format(textRes.QingYunZhi[9], name))
  end
end
def.static("number", "number", "number").sendChallengeQing = function(outPostType, chapter, section)
  warn("sendChallengeQing", string.format("%d %d", chapter, section))
  local p = require("netio.protocol.mzm.gsp.qingyunzhi.CChallengeQing").new(outPostType, chapter, section)
  gmodule.network.sendProtocol(p)
end
return QingYunZhiProtocol.Commit()
