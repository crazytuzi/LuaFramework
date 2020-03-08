local OctetsStream = require("netio.OctetsStream")
local AllLottoErrorCode = require("netio.protocol.mzm.gsp.alllotto.AllLottoErrorCode")
local AwardState = require("netio.protocol.mzm.gsp.alllotto.AwardState")
local AllLottoImportBean = class("AllLottoImportBean")
function AllLottoImportBean:ctor(_IndianaErrorCode, _AwardState)
  self._IndianaErrorCode = _IndianaErrorCode or AllLottoErrorCode.new()
  self._AwardState = _AwardState or AwardState.new()
end
function AllLottoImportBean:marshal(os)
  self._IndianaErrorCode:marshal(os)
  self._AwardState:marshal(os)
end
function AllLottoImportBean:unmarshal(os)
  self._IndianaErrorCode = AllLottoErrorCode.new()
  self._IndianaErrorCode:unmarshal(os)
  self._AwardState = AwardState.new()
  self._AwardState:unmarshal(os)
end
return AllLottoImportBean
