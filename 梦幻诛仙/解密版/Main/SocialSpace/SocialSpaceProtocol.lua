local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SocialSpaceProtocol = Lplus.Class(MODULE_NAME)
local SocialSpaceModule = Lplus.ForwardDeclare("Main.SocialSpace.SocialSpaceModule")
local def = SocialSpaceProtocol.define
local Octets = require("netio.Octets")
local ItemModule = require("Main.Item.ItemModule")
local ECSocialSpaceMan = Lplus.ForwardDeclare("ECSocialSpaceMan")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local GET_SIGN_TIMEOUT_SECONDS = 20
local _getSignCallback, _getSignTimerId
def.static().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friendscircle.SSyncFriendsCircleInfo", SocialSpaceProtocol.OnSSyncFriendsCircleInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friendscircle.SUseFriendsCircleOrnamentItemSuccess", SocialSpaceProtocol.OnSUseFriendsCircleOrnamentItemSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friendscircle.SReplaceFriendsCircleOrnamentItemSuccess", SocialSpaceProtocol.OnSReplaceFriendsCircleOrnamentItemSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friendscircle.SBuyFriendsCircleTreasureBoxSuccess", SocialSpaceProtocol.OnSBuyFriendsCircleTreasureBoxSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friendscircle.STreadFriendsCircleSuccess", SocialSpaceProtocol.OnSTreadFriendsCircleSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friendscircle.SNotifyFriendsCircleBeTrod", SocialSpaceProtocol.OnSNotifyFriendsCircleBeTrod)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friendscircle.SGiveFriendsCircleGiftSuccess", SocialSpaceProtocol.OnSGiveFriendsCircleGiftSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friendscircle.SReceiveFriendsCircleGiftSuccess", SocialSpaceProtocol.OnSReceiveFriendsCircleGiftSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friendscircle.SFriendsCircleNormalRes", SocialSpaceProtocol.OnSFriendsCircleNormalRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friendscircle.SGetFriendsCircleSignRes", SocialSpaceProtocol.OnSGetFriendsCircleSignRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friendscircle.SAddFriendsCircleBlacklistSuccess", SocialSpaceProtocol.OnSAddFriendsCircleBlacklistSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friendscircle.SDeleteFriendsCircleBlacklistSuccess", SocialSpaceProtocol.OnSDeleteFriendsCircleBlacklistSuccess)
end
def.static().Clear = function()
  if _getSignCallback then
    _getSignCallback(nil)
    _getSignCallback = nil
  end
  SocialSpaceProtocol.RemoveGetSignTimer()
end
local debug = false
local function sendProtocol(p)
  if debug then
    printInfo("[DEBUG] sendProtocol " .. p.class.__cname)
  else
    gmodule.network.sendProtocol(p)
  end
end
def.static("userdata", "number").CTreadFriendsCircle = function(roleId, zoneId)
  local p = require("netio.protocol.mzm.gsp.friendscircle.CTreadFriendsCircle").new(roleId, zoneId)
  sendProtocol(p)
end
def.static("userdata").CFriendsCircleTryTread = function(roleId)
  local p = require("netio.protocol.mzm.gsp.friendscircle.CFriendsCircleTryTread").new(roleId)
  sendProtocol(p)
end
def.static("userdata", "number", "number", "number", "string", "boolean", "number").CGiveFriendsCircleGift = function(roleId, zoneId, itemId, giftGrade, messageStr, useYuanbao, costYuanbao)
  local client_currency_value = Int64.new(ItemModule.Instance():GetAllYuanBao())
  local is_use_yuan_bao = useYuanbao and 1 or 0
  local message = Octets.rawFromString(messageStr)
  local p = require("netio.protocol.mzm.gsp.friendscircle.CGiveFriendsCircleGift").new(roleId, zoneId, itemId, giftGrade, client_currency_value, is_use_yuan_bao, message, costYuanbao)
  sendProtocol(p)
end
def.static("number").CBuyFriendsCircleTreasureBox = function(buyNum)
  local client_currency_value = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
  local p = require("netio.protocol.mzm.gsp.friendscircle.CBuyFriendsCircleTreasureBox").new(buyNum, client_currency_value)
  sendProtocol(p)
end
def.static("function").CGetFriendsCircleSign = function(callback)
  if _getSignCallback then
    return
  end
  _getSignCallback = callback
  _getSignTimerId = AbsoluteTimer.AddListener(GET_SIGN_TIMEOUT_SECONDS, 0, function()
    if _getSignCallback then
      _getSignCallback(nil)
      _getSignCallback = nil
    end
    _getSignTimerId = nil
  end, nil, 0)
  local p = require("netio.protocol.mzm.gsp.friendscircle.CGetFriendsCircleSign").new(buyNum, client_currency_value)
  sendProtocol(p)
end
def.static("table").OnSGetFriendsCircleSignRes = function(p)
  if _getSignCallback then
    _getSignCallback(p)
    _getSignCallback = nil
  end
  SocialSpaceProtocol.RemoveGetSignTimer()
end
def.static().RemoveGetSignTimer = function()
  if _getSignTimerId then
    AbsoluteTimer.RemoveListener(_getSignTimerId)
    _getSignTimerId = nil
  end
end
def.static("userdata").CUseFriendsCircleOrnamentItem = function(item_uuid)
  local p = require("netio.protocol.mzm.gsp.friendscircle.CUseFriendsCircleOrnamentItem").new(item_uuid)
  sendProtocol(p)
end
def.static("table").CReplaceFriendsCircleOrnamentItem = function(replace_ornament_map)
  local p = require("netio.protocol.mzm.gsp.friendscircle.CReplaceFriendsCircleOrnamentItem").new(replace_ornament_map)
  sendProtocol(p)
end
def.static("number", "number").CWeekPopularityChartReq = function(start_pos, end_pos)
  local p = require("netio.protocol.mzm.gsp.friendscircle.CWeekPopularityChartReq").new(start_pos, end_pos)
  sendProtocol(p)
end
def.static("userdata", "number").CAddFriendsCircleBlacklist = function(black_role_id, black_role_server_id)
  local p = require("netio.protocol.mzm.gsp.friendscircle.CAddFriendsCircleBlacklist").new(black_role_id, black_role_server_id)
  sendProtocol(p)
end
def.static("userdata").CDeleteFriendsCircleBlacklist = function(black_role_id)
  local p = require("netio.protocol.mzm.gsp.friendscircle.CDeleteFriendsCircleBlacklist").new(black_role_id)
  sendProtocol(p)
end
def.static("table").OnSDeleteFriendsCircleBlacklistSuccess = function(p)
  ECSocialSpaceMan.Instance():onRemoveFromBlacklistSuccess(p)
end
def.static("table").OnSAddFriendsCircleBlacklistSuccess = function(p)
  ECSocialSpaceMan.Instance():onAddToBlacklistSuccess(p)
end
def.static("table").OnSFriendsCircleNormalRes = function(p)
  local RetEnum = p.class
  if p.ret == RetEnum.CURRENCY_NOT_EQUAL_WITH_SERVER or p.ret == RetEnum.ALEARDY_DEAL then
    return
  end
  local text = textRes.SocialSpace.SFriendsCircleNormalRes[p.ret]
  if text == nil then
    text = textRes.SocialSpace.SFriendsCircleNormalRes.COMMON:format(p.ret)
  end
  Toast(text)
end
def.static("table").OnSReceiveFriendsCircleGiftSuccess = function(p)
  ECSocialSpaceMan.Instance():onHostReceiveGift(p)
end
def.static("table").OnSGiveFriendsCircleGiftSuccess = function(p)
  ECSocialSpaceMan.Instance():onSendGiftSuccess(p)
end
def.static("table").OnSNotifyFriendsCircleBeTrod = function(p)
end
def.static("table").OnSTreadFriendsCircleSuccess = function(p)
  ECSocialSpaceMan.Instance():onAddSpacePopularSuccess(p)
end
def.static("table").OnSBuyFriendsCircleTreasureBoxSuccess = function(p)
  ECSocialSpaceMan.Instance():onBuyTreauseChestSuccess(p)
  Toast(textRes.SocialSpace[50])
end
def.static("table").OnSReplaceFriendsCircleOrnamentItemSuccess = function(p)
  ECSocialSpaceMan.Instance():onSaveSpaceDecorateSuccess(p)
end
def.static("table").OnSUseFriendsCircleOrnamentItemSuccess = function(p)
  ECSocialSpaceMan.Instance():onUseDecorateItemSuccess(p)
end
def.static("table").OnSSyncFriendsCircleInfo = function(p)
  ECSocialSpaceMan.Instance():onGetSocialSpaceData(p)
end
return SocialSpaceProtocol.Commit()
