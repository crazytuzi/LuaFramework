

local _M = {}
_M.__index = _M
local DepotInfo = nil
local BagInfo = {}
local DepotDynamic = {}

local Item = require "Zeus.Model.Item"
local guild = require 'Zeus.Model.Guild'

local function AddItems(msg)
  if msg.s2c_bagGrid then
    if BagInfo then
      table.insert(BagInfo,msg.s2c_bagGrid)
    end
  end
end

local function removeItems(index)
  if index and BagInfo then
    for k,v in pairs(BagInfo) do
      if v.gridIndex == index then
        table.remove(BagInfo,k)
        break
      end
    end
  end
end

function _M.getDepotInfoRequest(cb)
  Pomelo.GuildManagerHandler.getDepotInfoRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      
      DepotInfo = msg.s2c_depotInfo
      BagInfo = msg.s2c_depotBag.bagGrids
      if BagInfo==nil then BagInfo = {} end
      Item.RequestGuildWereHouseEquipmentDetail(msg.s2c_depotBag.bagDetails or {})
      cb()
    end
  end)
end

function _M.getDepotRecordRequest(page,cb)
  Pomelo.GuildManagerHandler.getDepotRecordRequest(page,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      if page==1 then DepotDynamic = {} end
      DepotDynamic[msg.s2c_page] = msg.s2c_recordList
      cb(msg.s2c_page)
    end
  end)
end

function _M.getDepotOneGridInfoRequest(bagIndex,cb)
  Pomelo.GuildManagerHandler.getDepotOneGridInfoRequest(bagIndex,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      local tab={}
      tab[1] = msg.s2c_bagDetail
      Item.RequestGuildWereHouseEquipmentDetail(tab)
      AddItems(msg)
      cb(msg.s2c_bagGrid)
    end
  end)
end

function _M.upgradeDepotRequest(cb)
  Pomelo.GuildDepotHandler.upgradeDepotRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      if DepotInfo then
        DepotInfo.level = msg.s2c_level
      end
      guild.setFouns(msg.s2c_fund)
      cb()
      EventManager.Fire('Guild.DepotUpLevel',{level = DepotInfo.level})
      EventManager.Fire("Event.UI.ChangeHallUI",{fund = msg.s2c_fund})
    end
  end)
end

function _M.depositItemRequest(c2s_fromIndex,cb)
  Pomelo.GuildDepotHandler.depositItemRequest(c2s_fromIndex,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      AddItems(msg)
      cb(msg.s2c_bagGrid,msg.depositCount)
    end
  end)
end

function _M.takeOutItemRequest(c2s_fromIndex,cb)
  Pomelo.GuildDepotHandler.takeOutItemRequest(c2s_fromIndex,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      removeItems(c2s_fromIndex)
      cb()
    end
  end)
end

function _M.setConditionRequest(useLevel,useUpLevel,useJob,minLevel,minUpLevel,minqColor,maxLevel,maxUpLevel,maxqColor,cb)
  Pomelo.GuildDepotHandler.setConditionRequest(useLevel,useUpLevel,useJob,minLevel,minUpLevel,minqColor,maxLevel,maxUpLevel,maxqColor,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      DepotInfo.depotCond = msg.s2c_condition
      cb()
    end
  end)
end

function _M.deleteItemRequest(c2s_fromIndex,cb)
  Pomelo.GuildDepotHandler.deleteItemRequest(c2s_fromIndex,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      removeItems(c2s_fromIndex)
      cb(msg.deleteCount)
    end
  end)
end

function _M.GetDepotInfo()
  return DepotInfo
end

function _M.GetDepotBagInfo()
  
  return BagInfo
end

function _M.GetDepotDynamic()
  return DepotDynamic
end

function GlobalHooks.DynamicPushs.GuildDepotPush(ex, sjson)
  if ex == nil then
    local msg = sjson:ToData()
    if msg.type==1 then 
      _M.getDepotOneGridInfoRequest(msg.bagIndex,function (msg_Grid)
        EventManager.Fire('Guild.DepotOneGridChange',{type = 1,msg = msg_Grid})
      end)
    elseif msg.type==2 then 
      removeItems(msg.bagIndex)
      EventManager.Fire('Guild.DepotOneGridChange',{type = 2,bagIndex = msg.bagIndex})
    elseif msg.type==3 then 
      EventManager.Fire('Guild.DepotOneGridChange',{type = 3,dopotlevel = msg.levelInfo.level})
    elseif msg.type==4 then 
      EventManager.Fire('Guild.DepotOneGridChange',{type = 4,condition = msg.condition})
    end
  end
end

function _M.InitNetWork()
  Pomelo.GuildDepotHandler.depotRefreshPush(GlobalHooks.DynamicPushs.GuildDepotPush)
end

return _M
