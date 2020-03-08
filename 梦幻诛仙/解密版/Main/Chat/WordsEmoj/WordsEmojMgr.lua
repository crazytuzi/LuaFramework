local Lplus = require("Lplus")
local WordsEmojMgr = Lplus.Class("WordsEmojMgr")
local Cls = WordsEmojMgr
local def = Cls.define
local instance
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local WordsEmojUtil = require("Main.Chat.WordsEmoj.WordsEmojUtil")
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = Cls()
  end
  return instance
end
def.method().Init = function(self)
end
def.static("=>", "boolean").IsFeatureOpen = function()
  local bFeatureOpen = FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_CHAT_TEXT_FACE)
  return bFeatureOpen
end
local AtUtils = require("Main.Chat.At.AtUtils")
def.static("string", "=>", "string").MakeFakeInfoPack = function(str)
  if string.find(str, "@") then
    local str = string.trim(str)
    local s, _ = string.find(str, "@")
    local strLen = string.len(str)
    local s1 = strLen
    for i = 1, strLen do
      local char = string.sub(str, i, i)
      if char == " " or char == "#" then
        s1 = i
        break
      end
    end
    str = string.sub(str, s + 1, s1)
    return "{" .. AtUtils.AT_PREFIX .. ":2," .. str .. ",0, 0}"
  end
end
def.static("string", "number", "=>", "string").CheckReplace = function(str, atTxtId)
  if Cls.IsFeatureOpen() and string.find(str, AtUtils.AT_PREFIX) then
    local pattern = WordsEmojUtil.GetWordsEmojById(atTxtId)
    if pattern == "" then
      return ""
    end
    local prefixLen = string.len(AtUtils.AT_PREFIX)
    local strs = string.split(string.sub(str, prefixLen + 3, -2), ",")
    local atName = strs[2]
    return Cls.indexBaseFormat(pattern, {
      ("{color:%s,%s}"):format(_G.GetHeroProp().name, textRes.Chat[90]),
      ("{color:%s,%s}"):format(atName, textRes.Chat[91])
    })
  else
    return ""
  end
end
def.static("string", "table", "=>", "string").indexBaseFormat = function(pattern, paramlist)
  if paramlist == nil or #paramlist < 1 then
    return pattern
  end
  local str = pattern
  for i = 1, #paramlist do
    local val = paramlist[i]
    str = string.gsub(str, "%%" .. i .. "s", val)
  end
  return str
end
return Cls.Commit()
