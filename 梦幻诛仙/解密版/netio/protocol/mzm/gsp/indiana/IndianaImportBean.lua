local OctetsStream = require("netio.OctetsStream")
local IndianaErrorCode = require("netio.protocol.mzm.gsp.indiana.IndianaErrorCode")
local AwardState = require("netio.protocol.mzm.gsp.indiana.AwardState")
local IndianaImportBean = class("IndianaImportBean")
function IndianaImportBean:ctor(_IndianaErrorCode, _AwardState)
  self._IndianaErrorCode = _IndianaErrorCode or IndianaErrorCode.new()
  self._AwardState = _AwardState or AwardState.new()
end
function IndianaImportBean:marshal(os)
  self._IndianaErrorCode:marshal(os)
  self._AwardState:marshal(os)
end
function IndianaImportBean:unmarshal(os)
  self._IndianaErrorCode = IndianaErrorCode.new()
  self._IndianaErrorCode:unmarshal(os)
  self._AwardState = AwardState.new()
  self._AwardState:unmarshal(os)
end
return IndianaImportBean
