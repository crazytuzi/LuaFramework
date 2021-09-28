

local _M = {}
_M.__index = _M

function _M.rewardDeskRequest(cb)
  Pomelo.RewardHandler.rewardDeskRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      cb(msg.s2c_itemInfo)
    end
  end)
end

function _M.rewardRequest(c2s_playerName,cb)
  Pomelo.RewardHandler.rewardRequest(c2s_playerName,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      cb()
    end
  end)
end

function _M.checkBountyRequest(c2s_index,cb)
  Pomelo.RewardHandler.checkBountyRequest(c2s_index,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      cb(msg)
    end
  end)
end

function _M.getAwardBountyRequest(c2s_preyId,c2s_hunterId,c2s_bounty,cb)
  Pomelo.RewardHandler.getAwardBountyRequest(c2s_preyId,c2s_hunterId,c2s_bounty,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      cb()
    end
  end)
end

function _M.getHasFinishRequest(cb)
  Pomelo.RewardHandler.getHasFinishRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      cb(msg)
    end
  end)
end

return _M
