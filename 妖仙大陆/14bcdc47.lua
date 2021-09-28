

local _M = {}
_M.__index = _M

local PrayInfo = {}
local PrayDynamic = {}

local guild = require 'Zeus.Model.Guild'

local function SetBlessRequestMsg(msg)
  PrayInfo.myInfo.blessCount = msg.blessCount
  
  PrayInfo.guildInfo.finishState = msg.finishState
  PrayInfo.guildInfo.blessValue = msg.blessValue
  for k,v in pairs(PrayInfo.guildInfo.itemList) do
    if v.id == msg.id then
      v.finishNum = msg.finishNum
    end
  end
end

function _M.blessActionRequest(id,cb) 
  Pomelo.GuildBlessHandler.blessActionRequest(id,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      
      cb()
    end
  end)
end

function _M.getBlessRecordRequest(page,cb) 
  Pomelo.GuildManagerHandler.getBlessRecordRequest(page,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      if page==1 then PrayDynamic = {} end
      PrayDynamic[msg.s2c_page] = msg.s2c_recordList
      cb(msg.s2c_page)
    end
  end)
end

function _M.getMyBlessInfoRequest(cb)
  Pomelo.GuildBlessHandler.getMyBlessInfoRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      
      PrayInfo.myInfo = msg.s2c_blessInfo
      cb()
    end
  end)
end

function _M.getBlessInfoRequest(cb)
  Pomelo.GuildManagerHandler.getBlessInfoRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      
      PrayInfo.guildInfo = msg.s2c_blessInfo
      cb()
    end
  end)
end

function _M.upgradeBlessRequest(cb)
  Pomelo.GuildBlessHandler.upgradeBlessRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      PrayInfo.guildInfo.level = msg.s2c_level
      guild.setFouns(msg.s2c_fund)
      cb(msg.s2c_level)
      EventManager.Fire("Event.UI.ChangeHallUI",{fund = msg.s2c_fund})
    end
  end)
end

function _M.receiveBlessGiftRequest(index, cb)
  Pomelo.GuildBlessHandler.receiveBlessGiftRequest(index, function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      
      cb()
    end
  end)
end

function _M.GetMyPrayInfo()
  return PrayInfo
end

function _M.GetPrayDynamic()
  return PrayDynamic
end

function GlobalHooks.DynamicPushs.BlessPush(ex, sjson)
  if ex == nil then
    local msg = sjson:ToData()
    
    EventManager.Fire('Guild.PushChangPray',{})
  end
end

function _M.InitNetWork()
  Pomelo.GuildBlessHandler.blessRefreshPush(GlobalHooks.DynamicPushs.BlessPush)
end

function _M.initial()

end

return _M
