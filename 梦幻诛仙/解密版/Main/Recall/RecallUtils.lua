local Lplus = require("Lplus")
local ItemUtils = require("Main.Item.ItemUtils")
local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
local RecallUtils = Lplus.Class("RecallUtils")
local def = RecallUtils.define
def.static("string", "=>", "number").GetConst = function(key)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_RECALL_FRIENDS_CONSTS, key)
  if not record then
    warn("[ERROR][RecallUtils:GetConst] no record for key:", key)
    return 0
  else
    local value = DynamicRecord.GetIntValue(record, "value")
    return value
  end
end
def.static("number", "=>", "number").GetPastDayBy24 = function(time)
  local curTime = _G.GetServerTime()
  local duration = curTime - time
  local dayCount = math.floor(duration / 86400)
  return dayCount
end
def.static("number", "=>", "number").GetPastDayBy0 = function(time)
  local curTime = _G.GetServerTime()
  local nYear = tonumber(os.date("%Y", curTime))
  local nMonth = tonumber(os.date("%m", curTime))
  local nDay = tonumber(os.date("%d", curTime))
  local nHour = tonumber(os.date("%H", time))
  local nMin = tonumber(os.date("%M", time))
  local nSec = tonumber(os.date("%S", time))
  local tmpCurTime = TimeCfgUtils.GetTimeSec(nYear, nMonth, nDay, nHour, nMin, nSec)
  local duration = tmpCurTime - time
  local dayCount = math.floor(duration / 86400)
  return dayCount
end
def.static("userdata", "=>", "string").ProcessHeadImgURL = function(url)
  local urlStr = _G.GetStringFromOcts(url) or ""
  if _G.LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
    urlStr = urlStr .. "/46"
  elseif _G.LoginPlatform == MSDK_LOGIN_PLATFORM.QQ then
    urlStr = urlStr .. "40"
  end
  local ECMSDK = require("ProxySDK.ECMSDK")
  if ECMSDK.IsHttpsSupported() and platform == 1 then
    urlStr = string.gsub(urlStr, "^(http):", "%1s:")
  end
  return urlStr or ""
end
def.static("number", "number", "=>", "boolean").IsSameDay = function(time1, time2)
  local timeStr1 = os.date("%Y%m%d", time1)
  local timeStr2 = os.date("%Y%m%d", time2)
  if timeStr1 == timeStr2 then
    return true
  end
  return false
end
def.static("number", "userdata").ShowActiveAwardTip = function(awardId, obj)
  local itemList = RecallUtils.GetAwardItems(awardId)
  if obj and itemList and #itemList > 0 then
    local awardContent = ""
    local awardCount = #itemList
    for idx, awardItem in ipairs(itemList) do
      local itemBase = ItemUtils.GetItemBase(awardItem.itemId)
      if itemBase and 0 < awardItem.num then
        awardContent = awardContent .. itemBase.name .. "x" .. awardItem.num
        if idx ~= awardCount then
          awardContent = awardContent .. "\n"
        end
      else
        warn("[ERROR][RecallUtils:ShowActiveAwardTip] itemBase nil for itemid:", awardItem.itemId)
      end
    end
    local CommonUISmallTip = require("GUI.CommonUISmallTip")
    local position = obj:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local widget = obj:GetComponent("UIWidget")
    CommonUISmallTip.Instance():ShowTip(awardContent, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
  else
    warn("[ERROR][RecallUtils:ShowActiveAwardTip] ShowActiveAwardTip fail:", obj, itemList)
  end
end
def.static("number", "=>", "table").GetAwardItems = function(awardId)
  local key = string.format("%d_%d_%d", awardId, occupation.ALL, gender.ALL)
  local cfg = ItemUtils.GetGiftAwardCfg(key)
  local itemList = ItemUtils.GetAwardItemsFromAwardCfg(cfg)
  if itemList and itemList[1] then
    return itemList
  else
    return nil
  end
end
RecallUtils.Commit()
return RecallUtils
