local EC = require("Types.Vector3")
_G.ZeroUInt64 = LuaUInt64.Make(0, 0)
_G.ZeroInt64 = LuaInt64.Make(0, 0)
_G.NegativeOneInt64 = LuaInt64.Make(4294967295, 4294967295)
local fInvInter = 2 * math.pi / 65536
local fInvInter2 = 32768 / math.pi
local atan2 = math.atan2
local newvec = EC.Vector3.new
local cos = math.cos
local sin = math.sin
function _G.DecompressDirH2(nDir)
  local fRad = nDir * fInvInter
  return newvec(cos(fRad), 0, sin(fRad))
end
function _G.CompressDirH2(x, z)
  return atan2(z, x) * fInvInter2
end
function _G.DecompressDir(dir0, dir1)
  local fRad = dir0 * fInvInter
  local fHei = dir0 * dir1 * fInvInter
  local v = EC.Vector3.new()
  local p = sin(fHei)
  v.x = p * cos(fRad)
  v.z = p * sin(fRad)
  v.y = cos(fHei)
  return v
end
local _Old2NewIDMap = {}
local _New2OldIDMap = {}
function _G.GetOldID(ID32)
  local old = _New2OldIDMap[ID32]
  if old == nil then
    return ZeroUInt64
  end
  return old
end
function _G.GetNewID(ID64)
  local new = _Old2NewIDMap[ID64]
  if new == nil then
    return 0
  end
  return new
end
function _G.AddIDMap(ID32, ID64)
  _New2OldIDMap[ID32] = ID64
  _Old2NewIDMap[ID64] = ID32
end
function _G.ClearIDMap()
  _New2OldIDMap = {}
  _Old2NewIDMap = {}
end
function _G.DistH(vFrom, vTo)
  return newvec(vTo.x - vFrom.x, 0, vTo.z - vFrom.z)
end
function _G.DirH(vFrom, vTo)
  local x = vTo.x - vFrom.x
  local z = vTo.z - vFrom.z
  local len = math.sqrt(x * x + z * z)
  if len > 0 then
    return newvec(x / len, 0, z / len)
  else
    return newvec(0, 0, 0)
  end
end
function _G.AsyncLoadArray(arr, onfinish, ...)
  local ret = {}
  if #arr == 0 then
    onfinish(ret)
  end
  local count = 0
  local function _onload(i, obj)
    ret[i] = obj
    count = count + 1
    if count == #arr then
      onfinish(ret)
    end
  end
  for i = 1, #arr do
    GameUtil.AsyncLoad(arr[i], function(obj)
      _onload(i, obj)
    end, ...)
  end
end
local _res_path = {}
function _G.GetEquipResPath(path)
  local respath = _res_path[path]
  if respath == nil then
    respath = dofile(path)
    if respath then
      _res_path[path] = respath
    end
  end
  return respath
end
function _G.set_skinrender_bones(render, model, bonename)
  GameUtil.SetSkinRenderBones(render, model, "Root", bonename)
end
function _G.print_r(sth)
  if type(sth) ~= "table" then
    print(sth)
    return
  end
  local space, deep = string.rep(" ", 4), 0
  local function _dump(t)
    local temp = {}
    for k, v in pairs(t) do
      local key = tostring(k)
      if type(v) == "table" then
        deep = deep + 2
        print(string.format([[
%s[%s] => Table
%s(]], string.rep(space, deep - 1), key, string.rep(space, deep)))
        _dump(v)
        print(string.format("%s)", string.rep(space, deep)))
        deep = deep - 2
      else
        print(string.format("%s[%s] => %s", string.rep(space, deep + 1), key, v))
      end
    end
  end
  print(string.format([[
Table
(]]))
  _dump(sth)
  print(string.format(")"))
end
function _G.Color32RGBA(r, g, b, a)
  return bit.lshift(r, 24) + bit.lshift(g, 16) + bit.lshift(b, 8) + a
end
local r_mask = 4278190080
local g_mask = 16711680
local b_mask = 65280
local a_mask = 255
function _G.AssignColor(color, color32_value)
  local r = bit.rshift(bit.band(color32_value, r_mask), 24)
  local g = bit.rshift(bit.band(color32_value, g_mask), 16)
  local b = bit.rshift(bit.band(color32_value, b_mask), 8)
  local a = bit.band(color32_value, a_mask)
  color:set_r(r / 255)
  color:set_g(g / 255)
  color:set_b(b / 255)
  color:set_a(a / 255)
end
if ZLUtil then
  local DeviceUtility = require("Utility.DeviceUtility")
  local ECQQEC = require("ProxySDK.ECQQEC")
  local t = {
    onBattery = DeviceUtility.onBattery,
    onQQECStatusChangedNotify = ECQQEC.SetStatusNotify,
    onQQECCommentReceiveNotify = ECQQEC.SetCommentNotify,
    onQQECShareNotify = ECQQEC.SetShareNotify,
    onQQECWebViewNotify = ECQQEC.WebViewNotify,
    onTakePhoto = DeviceUtility.onTakePhoto,
    onPickPhoto = DeviceUtility.onPickPhoto
  }
  ZLUtil.init(t)
end
