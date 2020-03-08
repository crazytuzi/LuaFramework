local Lplus = require("Lplus")
local TitleMgr = Lplus.Class("TitleMgr")
local TitleInterface = require("Main.title.TitleInterface")
local def = TitleMgr.define
def.static("number", "string").ShowChengweiTips = function(chengweiId, name)
  if not TitleMgr.ValidateChengwei(chengweiId, name) then
    warn(string.format("error title cfg:%d, %s", chengweiId, name))
    return
  end
  require("Main.title.ui.ChengweiTips").Instance():ShowTip(chengweiId, name)
end
def.static("number", "string", "=>", "boolean").ValidateChengwei = function(chengweiId, name)
  local chengweiCfg = TitleInterface.GetAppellationCfg(chengweiId)
  if chengweiCfg == nil then
    return false
  end
  local BigAppellation = require("consts.mzm.gsp.title.confbean.BigAppellation")
  if chengweiCfg.bigAppellation == BigAppellation.RELATIONSHIP_APP then
    local emptyName = string.format(chengweiCfg.appellationName, "", "", "", "", "")
    if string.find(name, emptyName) then
      return true
    else
      return false
    end
  else
    return chengweiCfg.appellationName == name
  end
  return true
end
def.static("number", "string").ShowTouxianTips = function(touxianId, name)
  if not TitleMgr.ValidateTouxian(touxianId, name) then
    warn(string.format("error touxian cfg:%d, %s", touxianId, name))
    return
  end
  require("Main.title.ui.TouxianTips").Instance():ShowTip(touxianId, name)
end
def.static("number", "string", "=>", "boolean").ValidateTouxian = function(touxianId, name)
  local touxianCfg = TitleInterface.GetTitleCfg(touxianId)
  if touxianCfg == nil then
    return false
  end
  warn(touxianCfg.titleName, name)
  if touxianCfg.titleName ~= name then
    return false
  end
  return true
end
TitleMgr.Commit()
return TitleMgr
