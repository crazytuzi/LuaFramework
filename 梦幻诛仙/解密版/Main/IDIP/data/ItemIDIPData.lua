local Lplus = require("Lplus")
local ItemIDIPData = Lplus.Class("ItemIDIPData")
local def = ItemIDIPData.define
local _instance
def.static("=>", ItemIDIPData).Instance = function()
  if _instance == nil then
    _instance = ItemIDIPData()
  end
  return _instance
end
def.field("table")._idipMap = nil
def.method().Init = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._idipMap = nil
end
def.method("table").SyncItemIDIPs = function(self, idipList)
  if idipList then
    for _, idipInfo in pairs(idipList) do
      self:DoSetItemIDIP(idipInfo, false)
    end
  end
  Event.DispatchEvent(ModuleId.IDIP, gmodule.notifyId.IDIP.ITEM_IDIP_LIST_UPDATE, nil)
end
def.method("table").SetItemIDIP = function(self, idipInfo)
  if idipInfo then
    self:DoSetItemIDIP(idipInfo, true)
  end
end
def.method("table", "boolean").DoSetItemIDIP = function(self, idipInfo, bEvent)
  if nil == idipInfo then
    warn("[ERROR][ItemIDIPData:DoSetItemIDIP] idipInfo nil!")
    return
  end
  local type = idipInfo.item_type
  local cfgId = idipInfo.cfgid
  local bOpen = nil == idipInfo.isopen or idipInfo.isopen ~= 0
  warn("[ItemIDIPData:DoSetItemIDIP] type, cfgId, bOpen:", type, cfgId, bOpen)
  if self._idipMap == nil then
    self._idipMap = {}
  end
  local cfgMap = self._idipMap[type]
  if nil == cfgMap then
    cfgMap = {}
    self._idipMap[type] = cfgMap
  end
  local oldState = cfgMap[cfgId]
  cfgMap[cfgId] = bOpen
  if bEvent and (nil == oldState or oldState ~= bOpen) then
    Event.DispatchEvent(ModuleId.IDIP, gmodule.notifyId.IDIP.ITEM_IDIP_INFO_CHANGE, {
      type = type,
      cfgId = cfgId,
      bOpen = bOpen
    })
  end
end
def.method("number", "number", "=>", "boolean").GetItemIDIP = function(self, type, cfgId)
  local result = true
  local cfgMap = self._idipMap and self._idipMap[type]
  if cfgMap and nil ~= cfgMap[cfgId] then
    result = cfgMap[cfgId]
  end
  return result
end
def.method("=>", "table").GetItemIDIPMap = function(self)
  return self._idipMap
end
def.method("table", "table").OnLeaveWorld = function(self, p1, p2)
  self:_Reset()
end
ItemIDIPData.Commit()
return ItemIDIPData
