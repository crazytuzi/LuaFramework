local _M = {}
_M.__index = _M


function _M.worldBossListRequest(cb, timeoutcb)
  Pomelo.FightLevelHandler.worldBossListRequest(function (ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    else
      if timeoutcb ~= nil then
        timeoutcb()
      end
    end
  end, XmdsNetManage.PackExtData.New(true, true, timeoutcb))
end

function _M.enterWorldBossRequest(s2c_areaId, cb)
  Pomelo.FightLevelHandler.enterWorldBossRequest(s2c_areaId, function (ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.palaceListRequest(s2c_type, cb)
  Pomelo.FightLevelHandler.palaceListRequest(s2c_type, function (ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.getMonsterLeaderRequest(s2c_monsterId, s2c_areaId, cb)
  
  Pomelo.FightLevelHandler.getMonsterLeaderRequest(s2c_monsterId,s2c_areaId, function (ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.getBossInfoListRequest(cb)
  Pomelo.FightLevelHandler.getBossInfoRequest(function (ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.getDamageRankRequest(cb)
  
  Pomelo.FightLevelHandler.getBossDamageRankRequest(function (ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.getLllsionInfoRequest(cb)
  Pomelo.FightLevelHandler.getLllsionInfoRequest(function (ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.enterLllsionRequest(c2s_id,cb)
  Pomelo.FightLevelHandler.enterLllsionRequest(c2s_id,function (ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.GetLllsionBossInfoRequest(cb)
  Pomelo.FightLevelHandler.getLllsionBossInfoRequest(function (ex,sjson)
    if not ex then
      local param = sjson:ToData()
      _M.getBossInfoTime = os.time()
      cb(param)
    end
  end)
end

function _M.EnterLllsionBossRequest(c2s_id,cb)
  Pomelo.FightLevelHandler.enterLllsionBossRequest(c2s_id,function (ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

return _M
