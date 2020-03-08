local charsize = function(ch)
  if not ch then
    return 0
  elseif ch > 240 then
    return 4
  elseif ch > 225 then
    return 3
  elseif ch > 192 then
    return 2
  else
    return 1
  end
end
local function strlen(str)
  local len = 0
  local aNum = 0
  local hNum = 0
  local currentIndex = 1
  while currentIndex <= #str do
    local char = string.byte(str, currentIndex)
    local cs = charsize(char)
    currentIndex = currentIndex + cs
    len = len + 1
    if cs == 1 then
      aNum = aNum + 1
    elseif cs >= 2 then
      hNum = hNum + 1
    end
  end
  return len, aNum, hNum
end
local makepos = function(len, from, to)
  if not from and not to then
    return 1, len
  elseif not to then
    if from > 0 then
      if len < from then
        return len, len + 1
      else
        return from, len
      end
    elseif from < 0 then
      if from + len >= 0 and len > from + len then
        return from + len + 1, len
      elseif from + len < 0 then
        return 1, len
      end
    else
      return 1, len
    end
  elseif not from then
    if to > 0 then
      if to <= len then
        return 1, to
      elseif len < to then
        return 1, len
      end
    elseif to < 0 then
      if to + len >= 0 and len > to + len then
        return 1, len + to + 1
      elseif to + len < 0 then
        return 1, len
      end
    else
      error("bad argument #d to 'from' (number expected,got nil)")
    end
  elseif from > 0 and to > 0 then
    if from <= len and to <= len and from <= to then
      return from, to
    elseif from <= len and len < to then
      return from, len
    else
      error(("invalid pos for list range(expected range(%d-%d),but got (%d-%d)) "):format(1, len, from, to))
    end
  elseif from < 0 and to < 0 then
    if from + len >= 0 and len > from + len and to + len >= 0 and len > to + len and from <= to then
      return from + len + 1, to + len + 1
    end
    error(("invalid pos for list range(expected range(%d-%d),but got (%d-%d)) "):format(-len, -1, from, to))
  elseif from > 0 and to < 0 then
    return from, to + len + 1
  elseif from < 0 and to > 0 then
    if to <= len then
      return from + len + 1, to
    else
      return from + len + 1, len
    end
    error(("invalid pos for list range got (%d-%d) "):format(from, to))
  else
    error(("invalid pos for list range got (%d-%d) "):format(from, to))
  end
end
local function strsub(str, ...)
  local len = strlen(str)
  local from, to = makepos(len, ...)
  if len < from or to < from then
    return ""
  end
  local frombyte = 1
  local index = 1
  while true do
    if from <= index then
      break
    end
    local char = string.byte(str, frombyte)
    frombyte = frombyte + charsize(char)
    index = index + 1
  end
  index = from
  local byteIndex = frombyte
  while true do
    if to < index then
      break
    end
    local char = string.byte(str, byteIndex)
    byteIndex = byteIndex + charsize(char)
    index = index + 1
  end
  local tobyte = byteIndex
  return string.sub(str, frombyte, tobyte - 1)
end
local function tochar(str, pos)
  return strsub(str, pos, pos)
end
local Lplus = require("Lplus")
local ECLuaString = Lplus.Class("ECLuaString")
do
  local def = ECLuaString.define
  def.static("string", "varlist", "=>", "string").SubStr = function(str, ...)
    return strsub(str, ...)
  end
  def.static("string", "number", "=>", "string").CharAt = function(str, pos)
    return tochar(str, pos)
  end
  def.static("string", "=>", "number", "number", "number").Len = function(str)
    return strlen(str)
  end
end
ECLuaString.Commit()
return ECLuaString
