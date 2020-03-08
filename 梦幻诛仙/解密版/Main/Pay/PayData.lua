local Lplus = require("Lplus")
local Json = require("Utility.json")
local ProductServiceType = require("consts.mzm.gsp.qingfu.confbean.ProductServiceType")
local ChannelType = require("consts.mzm.gsp.qingfu.confbean.ChannelType")
local PayData = Lplus.Class("PayData")
local def = PayData.define
local instance
def.field("table").cfgData = nil
def.field("table").marketData = nil
def.field("table").data = nil
def.field("boolean").isValid = false
def.field("number").rate = 10
def.field("number").ver = 0
def.static("=>", PayData).Instance = function()
  if not instance then
    instance = PayData()
  end
  return instance
end
def.method().Init = function(self)
  warn("Pay Data Init")
  self.cfgData = PayData.GetQingFuCfgByType(ProductServiceType.NONE)
  self.marketData = {}
  self.data = self:MergeData(self.cfgData, self.marketData)
  self.isValid = false
  self.ver = 0
end
def.method().ClearData = function(self)
  self.cfgData = nil
  self.marketData = nil
  self.data = nil
  self.isValid = false
  self.ver = 0
end
def.method("string").SetPayData = function(self, json)
  if self.cfgData == nil then
    self.cfgData = PayData.GetQingFuCfgByType(ProductServiceType.NONE)
  end
  self.marketData = self:AnalysisMarketData(json)
  self.data = self:MergeData(self.cfgData, self.marketData)
  self.ver = self.ver + 1
end
def.method("=>", "table").GetPayData = function(self)
  return self.data
end
def.method("=>", "number").GetPayDataVer = function(self)
  return self.ver
end
def.method("string", "=>", "table").AnalysisMarketData = function(self, json)
  local mpdata = Json.decode(json)
  local retTbl = {}
  if mpdata then
    if mpdata.ret == 0 then
      self.rate = mpdata.rate
      if mpdata.mp_info and mpdata.mp_info.utp_mpinfo then
        for k, v in ipairs(mpdata.mp_info.utp_mpinfo) do
          local data
          if v.single_ex then
            data = v.single_ex[1]
          else
            data = v
          end
          local info = {}
          info.num = tonumber(data.num)
          info.sendnum = tonumber(data.send_num)
          local send_ext = data.send_ext
          info.isfirst = 0 < string.len(send_ext)
          info.type = tonumber(v.send_type)
          if retTbl[info.num] then
            warn("Repeat num in market data, num = " .. info.num)
            retTbl[info.num] = info
          else
            retTbl[info.num] = info
          end
        end
      end
    else
      warn("Midas Data ret err errcode = " .. mpdata.ret)
    end
  else
    warn("Analysis Json String fail!")
  end
  return retTbl
end
def.method("table", "table", "=>", "table").MergeData = function(self, cfgData, midasData)
  local mergeData = {}
  for k, v in ipairs(cfgData) do
    local payItem = {}
    payItem.cfg = v
    local midasInfo = midasData[v.yuanbao]
    if midasInfo then
      payItem.isfirst = midasInfo.isfirst
      payItem.sendnum = midasInfo.sendnum
      payItem.type = midasInfo.type
    else
      payItem.isfirst = false
      payItem.sendnum = 0
      payItem.type = 0
    end
    table.insert(mergeData, payItem)
  end
  return mergeData
end
def.static("number", "=>", "table").GetQingFuCfgByType = function(type)
  local qingfuCfg = PayData.LoadQingFuCfg()
  local resTbl = {}
  for k, v in ipairs(qingfuCfg) do
    if v.productServiceType == type then
      table.insert(resTbl, v)
    end
  end
  table.sort(resTbl, function(a, b)
    return a.rmb < b.rmb
  end)
  return resTbl
end
def.static("number", "=>", "table").GetQingFuCfgByServerId = function(id)
  local qingfuCfg = PayData.LoadQingFuCfg()
  local resTbl = {}
  for k, v in ipairs(qingfuCfg) do
    if v.productServiceId == id then
      table.insert(resTbl, v)
    end
  end
  table.sort(resTbl, function(a, b)
    return a.rmb < b.rmb
  end)
  return resTbl
end
def.static("=>", "table").LoadQingFuCfg = function()
  local tbl = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_QINGFU_CFG)
  if entries == nil then
    warn("Load Pay Config failed!")
    return tbl
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  warn("Pay Count", count)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = record:GetIntValue("id")
    cfg.channelId = record:GetIntValue("channelId")
    cfg.platId = record:GetIntValue("platId")
    cfg.productName = record:GetStringValue("productName")
    cfg.productId = record:GetStringValue("productId")
    cfg.rmb = record:GetIntValue("rmb")
    cfg.yuanbao = record:GetIntValue("yuanbao")
    cfg.commonYuanbaoPresent = record:GetIntValue("commonYuanbaoPresent")
    cfg.activityYuanbaoPresent = record:GetIntValue("activityYuanbaoPresent")
    cfg.vip = record:GetIntValue("vip")
    cfg.icon = record:GetIntValue("icon")
    cfg.commonIcon = record:GetIntValue("commonIcon")
    cfg.activityIcon = record:GetIntValue("activityIcon")
    cfg.productServiceType = record:GetIntValue("productServiceType")
    cfg.productServiceId = record:GetIntValue("productServiceId")
    cfg.productServiceDurationDays = record:GetIntValue("productServiceDurationDays")
    if cfg.productId ~= "threepay" then
      local myPlat = platform
      local sdktype = ClientCfg.GetSDKType()
      if sdktype == ClientCfg.SDKTYPE.MSDK then
        local logingPlatform = require("ProxySDK.ECMSDK").PayPlatform()
        local myChannel = ChannelType.SHADOW
        if logingPlatform == MSDK_LOGIN_PLATFORM.WX then
          myChannel = ChannelType.WECHAT
        elseif logingPlatform == MSDK_LOGIN_PLATFORM.QQ then
          myChannel = ChannelType.QQ
        end
        if cfg.platId == myPlat and cfg.channelId == myChannel then
          table.insert(tbl, cfg)
        end
      elseif sdktype == ClientCfg.SDKTYPE.UNISDK then
        local UniSDK = require("ProxySDK.ECUniSDK")
        local logingPlatform = UniSDK.Instance():GetChannelType()
        local myChannel = ChannelType.SHADOW
        if logingPlatform == UniSDK.CHANNELTYPE.EFUNTW then
          myChannel = ChannelType.EFUN_TW
        elseif logingPlatform == UniSDK.CHANNELTYPE.EFUNHK then
          myChannel = ChannelType.EFUN_HK
        elseif logingPlatform == UniSDK.CHANNELTYPE.LOONG then
          myChannel = ChannelType.ZULONG_XINMA
        end
        if cfg.platId == myPlat and cfg.channelId == myChannel then
          table.insert(tbl, cfg)
        end
      elseif sdktype == ClientCfg.SDKTYPE.NON and cfg.platId == myPlat then
        table.insert(tbl, cfg)
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return tbl
end
PayData.Commit()
return PayData
