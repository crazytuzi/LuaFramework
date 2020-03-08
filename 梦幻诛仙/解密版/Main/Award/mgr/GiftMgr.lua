local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local AwardMgrBase = require("Main.Award.mgr.AwardMgrBase")
local GiftMgr = Lplus.Extend(AwardMgrBase, CUR_CLASS_NAME)
local def = GiftMgr.define
local CResult = {SUCCESS = 0, GIFT_CODE_FORMAT_ERROR = 1}
def.const("table").CResult = CResult
local instance
def.static("=>", GiftMgr).Instance = function()
  if instance == nil then
    instance = GiftMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.csprovider.SUseGiftCardFailed", GiftMgr.OnSUseGiftCardFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.csprovider.SUseGiftCardSuccess", GiftMgr.OnSUseGiftCardSuccess)
end
def.method("string", "=>", "number").ExchangeGift = function(self, giftCode)
  local GIFT_KEY_PATTERN = "^[a-hj-np-zA-HJ-NP-Z]*$"
  local GIFT_KEY_LEN_MIN = 7
  local GIFT_KEY_LEN_MAX = 15
  local matchstr = string.match(giftCode, GIFT_KEY_PATTERN)
  if matchstr == nil or not (GIFT_KEY_LEN_MIN <= #matchstr) or not (GIFT_KEY_LEN_MAX >= #matchstr) then
    return GiftMgr.CResult.GIFT_CODE_FORMAT_ERROR
  end
  self:C2S_UseGiftCardReq(giftCode)
  return GiftMgr.CResult.SUCCESS
end
def.method("string").C2S_UseGiftCardReq = function(self, giftCode)
  local p = require("netio.protocol.mzm.gsp.csprovider.CUseGiftCardReq").new(giftCode)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSUseGiftCardFailed = function(p)
  local text = textRes.Award.SUseGiftCardFailed[p.reason]
  if text == nil or p.reason == 0 then
    text = string.format(textRes.Award.SUseGiftCardFailed[0], p.reason)
  end
  Toast(text)
end
def.static("table").OnSUseGiftCardSuccess = function(p)
  Toast(textRes.Award[7])
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.USE_GIFT_CARD_SUCCESS, nil)
end
return GiftMgr.Commit()
