
local _M = {}
_M.__index = _M

local cjson = require "cjson"
local helper = require "Zeus.Logic.Helper"

_M.LBType = {
  FIGHTPOWER_ALL         =    101, 
  FIGHTPOWER_1           =    102, 
  FIGHTPOWER_2           =    103, 
  FIGHTPOWER_3           =    104, 
  FIGHTPOWER_4           =    105, 
  FIGHTPOWER_5           =    106, 
  LEVEL                  =    200, 
  GUILD_LEVEL            =    300, 
  GUILD_WAR              =    400, 
  GUILD_BOSS_PERSONAL_T  =    2200, 
  GUILD_BOSS_PERSONAL_Y  =    2201, 
  GUILD_BOSS_GUILD_T    =    2300, 
  GUILD_BOSS_GUILD_Y    =    2301, 
  RIDE                   =    500, 
  PET                    =    600, 
  XIANYUAN               =    700, 
  DEMONTOWER             =    2100, 
  HP                     =    800, 
  Phy                    =    801, 
  Mag                    =    802, 
  GEM                    =    1100, 
  ARENA                  =    2006, 
  ARENA_5V5              =    1003, 
  MELEE                  =    2009, 
  MELEE_LAST_SEASON      =    2010, 
}

function _M.RequestGuildInfo(id, cb)
  
  Pomelo.LeaderBoardHandler.guildInfoRequest(id, function( ex, sjson )
    
    
    if ex == nil then
      local param = sjson:ToData()
      if cb ~= nil then
        cb(param.s2c_data)
      end
    end
  end, nil)
end

function _M.RequestLeaderBoard(lbtype, season, cb)
  Pomelo.LeaderBoardHandler.leaderBoardRequest(lbtype, season, function( ex, sjson )
    
    
    if ex == nil then
      local param = sjson:ToData()
      if cb ~= nil then
        cb(param)
      end
    end
  end, nil)
end

function _M.RequestWorldLv(cb)
  Pomelo.LeaderBoardHandler.worldLevelInfoRequest(function( ex, sjson )
    
    
    if ex == nil then
      local param = sjson:ToData()
      if cb ~= nil then
        cb(param.s2c_data)
      end
    end
  end, nil)
end

function _M.RequestWorship(type, cb)
  Pomelo.LeaderBoardHandler.worShipRequest(type, function( ex, sjson )
    
    
    if ex == nil then
      local param = sjson:ToData()
      if cb ~= nil then
        cb(param.s2c_awards)
      end
    end
  end, nil)
end

function _M.initial()

end

function _M.fin()

end

function _M.InitNetWork()
  
end

return _M
