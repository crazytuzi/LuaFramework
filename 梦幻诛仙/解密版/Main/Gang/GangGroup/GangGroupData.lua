local Lplus = require("Lplus")
local GangGroupData = Lplus.Class("GangGroupData")
local ECMSDK = require("ProxySDK.ECMSDK")
local def = GangGroupData.define
def.field("boolean").isGroupBound = false
def.field("boolean").isInGroup = false
def.field("table").QQGroupInfo = nil
def.field("string").gangAnno = ""
local instance
def.static("=>", GangGroupData).Instance = function()
  if instance == nil then
    instance = GangGroupData()
  end
  return instance
end
def.method().Reset = function(self)
  self.isGroupBound = false
  self.isInGroup = false
  self.gangAnno = ""
  self.QQGroupInfo = nil
end
def.method("boolean").SetGroupBoundState = function(self, state)
  self.isGroupBound = state
end
def.method("boolean").SetInGroupState = function(self, state)
  self.isInGroup = state
end
def.method("=>", "boolean").IsGroupBound = function(self)
  return self.isGroupBound
end
def.method("=>", "boolean").IsInGroup = function(self)
  if not self:IsGroupBound() then
    return false
  end
  return self.isInGroup
end
def.method("string").SetGangAnno = function(self, anno)
  self.gangAnno = anno
end
def.method("=>", "string").GetGangAnno = function(self)
  return self.gangAnno
end
def.method("table").SyncQQGroupInfo = function(self, groupInfo)
  if not self.QQGroupInfo then
    self.QQGroupInfo = {}
  end
  self.QQGroupInfo.groupOpenId = groupInfo.groupOpenId
end
def.method("table").UpdateQQGroupInfo = function(self, groupInfo)
  if not self:IsQQGroupInfoChanged(groupInfo) then
    return
  end
  self:SetQQGroupInfo(groupInfo)
  local p = require("netio.protocol.mzm.gsp.gang.CSetGangQQGroupReq").new(groupInfo.groupOpenid)
  gmodule.network.sendProtocol(p)
end
def.method().NofityQQGroupUnbind = function(self)
  local p = require("netio.protocol.mzm.gsp.gang.CClearQQGroupReq").new()
  gmodule.network.sendProtocol(p)
end
def.method("table", "=>", "boolean").IsQQGroupInfoChanged = function(self, newInfo)
  if not newInfo then
    return false
  end
  if not self.QQGroupInfo then
    return true
  end
  if not self.QQGroupInfo.groupOpenId or self.QQGroupInfo.groupOpenId ~= newInfo.groupOpenid then
    return true
  end
  return false
end
def.method("table").SetQQGroupInfo = function(self, qqGroupInfo)
  if not qqGroupInfo then
    return
  end
  if not self.QQGroupInfo then
    self.QQGroupInfo = {}
  end
  self.QQGroupInfo.groupOpenId = qqGroupInfo.groupOpenid
end
def.method("=>", "table").GetQQGroupInfo = function(self)
  return self.QQGroupInfo
end
def.method("=>", "string").GetQQGroupOpenID = function(self)
  if not self.QQGroupInfo or not self.QQGroupInfo.groupOpenId then
    return ""
  end
  return self.QQGroupInfo.groupOpenId
end
GangGroupData.Commit()
return GangGroupData
