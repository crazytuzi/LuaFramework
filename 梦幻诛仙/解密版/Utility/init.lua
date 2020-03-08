_G.__NetIO_UnmarshalString = nil
local _cur_f, _arg_1, _arg_2, _arg_3, _arg_4
local function _wrapper_f_1()
  local f = _cur_f
  local p1 = _arg_1
  _cur_f = nil
  _arg_1 = nil
  f(p1)
end
local function _wrapper_f_2()
  local f = _cur_f
  local p1 = _arg_1
  local p2 = _arg_2
  _cur_f = nil
  _arg_1 = nil
  _arg_2 = nil
  f(p1, p2)
end
local function _wrapper_f_3()
  local f = _cur_f
  local p1 = _arg_1
  local p2 = _arg_2
  local p3 = _arg_3
  _cur_f = nil
  _arg_1 = nil
  _arg_2 = nil
  _arg_3 = nil
  f(p1, p2, p3)
end
local function _wrapper_f_4()
  local f = _cur_f
  local p1 = _arg_1
  local p2 = _arg_2
  local p3 = _arg_3
  local p4 = _arg_4
  _cur_f = nil
  _arg_1 = nil
  _arg_2 = nil
  _arg_3 = nil
  _arg_4 = nil
  f(p1, p2, p3, p4)
end
_G.isDebugBuild = GameUtil.isDebugBuild()
_G.enableLogError = false
local _realLogError = Debug.LogError
local function _logError(errstr)
  if enableLogError or Application.platform == RuntimePlatform.WindowsPlayer or Application.platform == RuntimePlatform.WindowsEditor then
    _realLogError(errstr)
  end
end
Debug.LogError = _logError
local _error_log = function(errlog)
  return debug.traceback(errlog)
end
function _G.IsNil(obj)
  if obj == nil then
    return true
  end
  local mt = getmetatable(obj)
  if mt == nil then
    return false
  end
  if mt.get_isnil then
    return obj:get_isnil()
  end
  return false
end
function _G.SafeCall(f, ...)
  local success, info
  local _paramCount = select("#", ...)
  if _paramCount == 0 then
    success, info = xpcall(f, _error_log)
  elseif _paramCount == 1 then
    _cur_f = f
    _arg_1 = (...)
    success, info = xpcall(_wrapper_f_1, _error_log)
  elseif _paramCount == 2 then
    _cur_f = f
    _arg_1, _arg_2 = ...
    success, info = xpcall(_wrapper_f_2, _error_log)
  elseif _paramCount == 3 then
    _cur_f = f
    _arg_1, _arg_2, _arg_3 = ...
    success, info = xpcall(_wrapper_f_3, _error_log)
  elseif _paramCount == 4 then
    _cur_f = f
    _arg_1, _arg_2, _arg_3, _arg_4 = ...
    success, info = xpcall(_wrapper_f_4, _error_log)
  else
    success, info = pcall(f, ...)
  end
  if not success then
    Debug.LogError(info)
  end
  return success
end
local GetTickCount = function()
  return math.floor(Time.realtimeSinceStartup * 1000)
end
GameUtil.GetTickCount = GetTickCount
local _replaceHtml = mtNGUIHTML.ForceHtmlText
local legalTag = {
  "a",
  "img",
  "p",
  "span",
  "spin",
  "br",
  "font",
  "code",
  "b",
  "i",
  "u",
  "s",
  "strike",
  "effect",
  "gameobj"
}
local ascii_A = string.byte("A", 1)
local ascii_Z = string.byte("Z", 1)
local ascii_a = string.byte("a", 1)
local ascii_z = string.byte("z", 1)
local ascii_space = string.byte(" ", 1)
local ascii_gt = string.byte(">", 1)
local ascii_slash = string.byte("/", 1)
local ascii_char_to_low = ascii_a - ascii_A
local function CompareStr(a, b)
  local len = math.min(#a, #b)
  for i = 1, len do
    local byte = string.byte(a, i)
    if byte >= ascii_A and byte <= ascii_Z then
      byte = byte + ascii_char_to_low
    end
    if byte ~= string.byte(b, i) then
      return false
    end
  end
  return true
end
local function FindNextWord(content, length, start)
  for i = start, length do
    local byte = string.byte(content, i)
    if byte >= ascii_a and byte <= ascii_z or byte >= ascii_A and byte <= ascii_Z then
    else
      if i == start then
        return nil
      end
      return string.sub(content, start, i - 1)
    end
  end
  return string.sub(content, start, length)
end
local function CheckHtml(content)
  local len = string.len(content)
  local index = 1
  while true do
    if len < index then
      return true
    end
    index = string.find(content, "<", index)
    if index then
      if len < index + 1 then
        return false
      end
      local next = string.byte(content, index + 1)
      if next == ascii_slash then
        index = index + 1
      end
      index = index + 1
      if len < index then
        return false
      end
      local tag = FindNextWord(content, len, index)
      if tag == nil then
        return false
      end
      index = index + #tag
      if len < index then
        return false
      end
      local tagEnd = string.byte(content, index)
      if tagEnd ~= ascii_space and tagEnd ~= ascii_gt and tagEnd ~= ascii_slash then
        return false
      end
      local find = false
      for _, v in ipairs(legalTag) do
        if CompareStr(tag, v) then
          find = true
          break
        end
      end
      if not find then
        return false
      end
    else
      return true
    end
  end
  return true
end
local function RepalceForceHtml(nguihtml, content)
  if CheckHtml(content) then
    _replaceHtml(nguihtml, content)
  else
    _replaceHtml(nguihtml, "***")
  end
end
mtNGUIHTML.ForceHtmlText = RepalceForceHtml
local TraceHelperLib = TraceHelper
local function TraceHelper_trace(logType, logContent)
  if TraceHelperLib and TraceHelperLib.trace then
    TraceHelperLib.trace(logType, logContent)
  else
    print("TraceHelper.trace not implement")
  end
end
_G.TraceHelper = {}
_G.TraceHelper.trace = TraceHelper_trace
if not UniSDK then
  UniSDK = ZLHappySDK
end
