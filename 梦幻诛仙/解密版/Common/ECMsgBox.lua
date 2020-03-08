require("bit")
_G.MsgBoxType = {
  MBT_INFO = bit.lshift(1, 0),
  MBT_OK = bit.lshift(1, 1),
  MBT_WARN = bit.lshift(1, 2),
  MBT_AUTOCLOSE = bit.lshift(1, 3),
  MBBT_OK = bit.lshift(1, 4),
  MBBT_CANCEL = bit.lshift(1, 5),
  MBBT_CHECKBOX = bit.lshift(1, 6),
  MBBT_OKCANCEL = bit.bor(bit.lshift(1, 4), bit.lshift(1, 5)),
  MBT_OVERTIME = bit.lshift(1, 7),
  MBBT_YES = bit.lshift(1, 8),
  MBBT_NO = bit.lshift(1, 9),
  MBBT_YESNO = bit.bor(bit.lshift(1, 8), bit.lshift(1, 9))
}
_G.MsgBoxRetT = {
  MBRT_CANCEL = 0,
  MBRT_OK = 1,
  MBRT_OKCHECKED = 2,
  MBRT_OVERTIME = 3
}
local Enum = require("Utility.Enum")
_G.Priority = Enum.make({
  "normal",
  "guide",
  "disconnect"
})
local _MsgBox = function(hwnd, lpszText, lpszCaption, nType, callback, ttl, timercallback, priority, opencall)
  lpszText = lpszText or ""
  lpszCaption = lpszCaption or "MsgBox"
  nType = nType or MsgBoxType.MBBT_OKCANCEL
  ttl = ttl or 0
  priority = priority or Priority.normal
  local boxMan = require("GUI.ECMsgBoxMan")
  local box = boxMan.Instance():ShowMsgBox(hwnd, lpszText, lpszCaption, nType, callback, ttl, timercallback, priority, opencall)
  return box
end
local _MsgBoxEx = function(hwnd, lpszText, lpszCaption, nType, callback, ttl, timercallback, priority, opencall)
  lpszText = lpszText or ""
  lpszCaption = lpszCaption or "MsgBox"
  nType = nType or MsgBoxType.MBBT_OKCANCEL
  ttl = ttl or 0
  priority = priority or Priority.normal
  local boxMan = require("GUI.ECMsgBoxMan")
  local box = boxMan.Instance():ShowMsgBoxEx(hwnd, lpszText, lpszCaption, nType, callback, ttl, timercallback, priority, opencall)
  return box
end
local _CloseAll = function()
  local boxMan = require("GUI.ECMsgBoxMan")
  boxMan.Instance():RemoveAll()
end
local _IsShown = function()
  local boxMan = require("GUI.ECMsgBoxMan")
  return boxMan.Instance():IsMsgBoxShowed()
end
local MsgBox = {
  MsgBoxType = MsgBoxType,
  MsgBoxRetT = MsgBoxRetT,
  ShowMsgBox = _MsgBox,
  ShowMsgBoxEx = _MsgBoxEx,
  CloseAll = _CloseAll,
  IsShown = _IsShown
}
_G.MsgBox = MsgBox
return MsgBox
