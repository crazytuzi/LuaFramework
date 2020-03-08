local Lplus = require("Lplus")
local bit = require("bit")
function _G.TrimIllegalChar(str)
  local strBuffer
  local i = 1
  local iLastTrimEnd
  while i <= #str do
    local ch = str:byte(i)
    if ch >= 240 then
      strBuffer = strBuffer or {}
      strBuffer[#strBuffer + 1] = str:sub(iLastTrimEnd or 1, i - 1)
      local trimLen
      if ch >= 252 then
        trimLen = 6
      elseif ch >= 248 then
        trimLen = 5
      else
        trimLen = 4
      end
      i = i + trimLen
      iLastTrimEnd = i
    else
      i = i + 1
    end
  end
  if iLastTrimEnd then
    strBuffer[#strBuffer + 1] = str:sub(iLastTrimEnd)
  end
  return strBuffer and table.concat(strBuffer) or str
end
function _G.bytesToHex(bytes)
  local strBuilder = {}
  for i = 1, #bytes do
    local byte = bytes:byte(i)
    strBuilder[#strBuilder + 1] = ("%02x"):format(byte)
  end
  return table.concat(strBuilder)
end
local Utf8Helper = Lplus.Class()
do
  local def = Utf8Helper.define
  def.static("string", "number", "=>", "number").moveAhead = function(str, offset)
    local char = str:byte(offset)
    if bit.band(char, 128) ~= 0 then
      if bit.band(char, 64) ~= 0 then
        if bit.band(char, 32) ~= 0 then
          return offset + 3
        else
          return offset + 2
        end
      else
        return offset + 1
      end
    else
      return offset + 1
    end
  end
end
return Utf8Helper.Commit()
