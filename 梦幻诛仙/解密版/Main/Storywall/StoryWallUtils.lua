local Lplus = require("Lplus")
local StoryWallUtils = Lplus.Class("StoryWallUtils")
local instance
local def = StoryWallUtils.define
def.static("=>", StoryWallUtils).Instance = function()
  if nil == instance then
    instance = StoryWallUtils()
  end
  return instance
end
def.static("number", "=>", "table").GetStoryCfg = function(id)
  local cfg = {}
  local record = DynamicData.GetRecord(CFG_PATH.DATA_STORYWALL_CFG, id)
  if nil == record then
    warn("StoryWallUtils.GetStoryCfg(" .. id .. ") return nil")
    return cfg
  end
  cfg.id = id
  cfg.name = DynamicRecord.GetStringValue(record, "storyname")
  cfg.content = DynamicRecord.GetStringValue(record, "storycontent")
  return cfg
end
StoryWallUtils.Commit()
return StoryWallUtils
