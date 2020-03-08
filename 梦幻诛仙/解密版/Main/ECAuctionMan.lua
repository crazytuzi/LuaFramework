local Lplus = require("Lplus")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECAuctionMan = Lplus.Class("ECAuctionMan")
local def = ECAuctionMan.define
def.field("table").mAuctionList = function()
  return {}
end
def.field("table").mAuctionItemList = function()
  return {}
end
local m_Instance
def.static("=>", ECAuctionMan).Instance = function()
  if m_Instance == nil then
    m_Instance = ECAuctionMan()
  end
  return m_Instance
end
local function BroadCastAuctionNotify(name, prtc)
  local AuctionChange = require("Event.AuctionChange")
  ECGame.EventManager:raiseEvent(nil, AuctionChange.new(name, prtc))
end
def.method("table").OnPrtc_NewAuctionOpenRe = function(self, prtc)
  BroadCastAuctionNotify("auction_open", prtc)
  if prtc.retcode == 859 then
    FlashTipMan.FlashTip(StringTable.Get(1620))
  elseif prtc.retcode == 283 then
    FlashTipMan.FlashTip(StringTable.Get(1623))
  elseif prtc.retcode == 285 then
    FlashTipMan.FlashTip(StringTable.Get(1624))
  elseif prtc.retcode ~= 0 then
    FlashTipMan.FlashTip(StringTable.Get(1601))
  else
    FlashTipMan.FlashTip(StringTable.Get(1600))
  end
end
def.method("table").OnPrtc_NewAuctionListRe = function(self, prtc)
  BroadCastAuctionNotify("auction_search", prtc)
  if prtc.retcode ~= 0 then
    FlashTipMan.FlashTip(StringTable.Get(1610))
  end
end
def.method("table").OnPrtc_NewAuctionGetRe = function(self, prtc)
  BroadCastAuctionNotify("auction_get", prtc)
  if prtc.retcode ~= 0 then
    FlashTipMan.FlashTip(StringTable.Get(1606))
  end
end
def.method("table").OnPrtc_NewAuctionAttendListRe = function(self, prtc)
  BroadCastAuctionNotify("auction_attendlist", prtc)
  if prtc.retcode ~= 0 then
    FlashTipMan.FlashTip(StringTable.Get(1612))
  end
end
def.method("table").OnPrtc_NewAuctionBuyRe = function(self, prtc)
  BroadCastAuctionNotify("auction_buy", prtc)
  if prtc.retcode == 859 then
    FlashTipMan.FlashTip(StringTable.Get(1620))
  elseif prtc.retcode ~= 0 then
    FlashTipMan.FlashTip(StringTable.Get(1607))
  elseif prtc.retcode == 0 then
    FlashTipMan.FlashTip(StringTable.Get(1617))
  end
end
def.method("table").OnPrtc_NewAuctionCloseRe = function(self, prtc)
  BroadCastAuctionNotify("auction_close", prtc)
  if prtc.retcode ~= 0 then
    FlashTipMan.FlashTip(StringTable.Get(1611))
  end
end
local function HostID()
  if ECGame.Instance().m_HostInfo then
    return ECGame.Instance().m_HostInfo.id
  end
  return ZeroUInt64
end
local function SendGameData(cmd)
  ECGame.Instance().m_Network:SendGameData(cmd)
end
local function SendProtocol(p)
  ECGame.Instance().m_Network:SendProtocol(p)
end
local function SendRequest(p)
  local os = OctetsStream.OctetsStream()
  p:Marshal(os)
  local player_request = require("C2S.player_request")
  local buf = player_request.new(p:GetType(), os)
  local NPCServiceCmdBuilder = require("C2S.NPCServiceCmdBuilder")
  local cmd = NPCServiceCmdBuilder.new(GP_NPCSEV_TYPE.GP_NPCSEV_NEW_AUCTION)
  cmd:SERVICE_SELF_SERVE()
  local writer = cmd.writer
  buf:Marshal(writer)
  SendGameData(cmd)
end
def.static("number", "number", "number", "number", "number", "number", "number", "number", "number").Send_NewAuctionOpen = function(item_id, item_location, item_pos, item_num, item_level, item_quality, category, price, elapse_time_type)
  local NewAuctionOpen = require("Protocol.NewAuctionOpen")
  local p = NewAuctionOpen()
  p.item_id = item_id
  p.item_location = item_location
  p.item_pos = item_pos
  p.item_num = item_num
  p.item_level = item_level
  p.item_quality = item_quality
  p.category = category
  p.price = price
  p.elapse_time_type = elapse_time_type
  SendRequest(p)
  print("Send_NewAuctionOpen")
end
def.static("number", "number", "number", "number", "string", "number", "number").Send_NewAuctionList = function(category, min_level, max_level, pageid, itemname, quality_type, search_type)
  local os = Octets.Octets()
  os:setStringUnicode(itemname)
  local NewAuctionList = require("Protocol.NewAuctionList")
  local p = NewAuctionList()
  p.category = category
  p.min_level = min_level
  p.max_level = max_level
  p.pageid = pageid
  p.itemname = os
  p.quality_type = quality_type
  p.search_type = search_type
  SendRequest(p)
end
def.static("table").Search = function(p)
  SendRequest(p)
end
def.static("number").Send_NewAuctionGet = function(auctionid)
  local NewAuctionGet = require("Protocol.NewAuctionGet")
  local p = NewAuctionGet()
  p.auctionid = auctionid
  SendRequest(p)
end
def.static("number", "number", "string").Send_NewAuctionAttendList = function(gettype, pageid, targetroleid)
  local NewAuctionAttendList = require("Protocol.NewAuctionAttendList")
  local p = NewAuctionAttendList()
  p.gettype = gettype
  p.pageid = pageid
  p.targetroleid = targetroleid
  SendRequest(p)
end
def.static("number", "number", "number").Send_AuctionBuy = function(auctionid, price, count)
  local ECMSDK = require("ProxySDK.ECMSDK")
  local sdkInfo = ECMSDK.GetMSDKInfo()
  local NewAuctionBuy = require("Protocol.NewAuctionBuy")
  local p = NewAuctionBuy()
  p.auctionid = auctionid
  p.price = price
  p.count = count
  local openKey = Octets.Octets()
  if platform ~= 0 then
    openKey:replace(sdkInfo.accessToken)
  end
  p.midas_openkey = openKey
  local osPayToken = Octets.Octets()
  if platform ~= 0 then
    osPayToken:replace(sdkInfo.payToken)
  end
  p.midas_paytoken = osPayToken
  local pf = Octets.Octets()
  if platform ~= 0 then
    pf:replace(sdkInfo.pf)
  end
  p.midas_pf = pf
  local pfKey = Octets.Octets()
  if platform ~= 0 then
    pfKey:replace(sdkInfo.pfKey)
  end
  p.midas_pfkey = pfKey
  SendRequest(p)
end
def.static("number").Send_AuctionClose = function(auctionid)
  local NewAuctionClose = require("Protocol.NewAuctionClose")
  local p = NewAuctionClose()
  p.auctionid = auctionid
  SendRequest(p)
end
ECAuctionMan.Commit()
return ECAuctionMan
