local MODULE_NAME = (...)
local Lplus = require("Lplus")
local TeamPlatformDataFactory = Lplus.Class(MODULE_NAME)
local TeamPlatformData = import(".TeamPlatformData")
local MatchTypeEnum = require("consts.mzm.gsp.team.confbean.MatchTypeEnum")
local def = TeamPlatformDataFactory.define
local CreateAndInit = function(class)
  local obj = class()
  return obj
end
def.static("number", "=>", "table").Create = function(matchType)
  local Class = TeamPlatformData
  if matchType == MatchTypeEnum.ACTIVITY then
    Class = import(".TeamPlatformActivityData", MODULE_NAME)
  elseif matchType == MatchTypeEnum.OPERA then
  end
  return CreateAndInit(Class)
end
return TeamPlatformDataFactory.Commit()
