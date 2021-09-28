local _M = {}

function _M.ReqMyfarmInfo(cb)
	Pomelo.FarmHandler.myfarmInfoRequest(function (ex,sjson)
    if not ex then
      local data = sjson:ToData()
      
      cb(data)
    end
  end)
end

function _M.ReqFriendsfarmInfo(cb)
  Pomelo.FarmHandler.friendsfarmInfoRequest(function (ex,sjson)
    if not ex then
      local data = sjson:ToData()
      
      cb(data.friendFarmLs or {})
    end
  end)
end


function _M.OpenRequest(id,cb)
  Pomelo.FarmHandler.OpenRequest(id,function (ex,sjson)
    if not ex then
      local data = sjson:ToData()
      
      cb()
    end
  end)
end


function _M.OpenRequest(id,cb)
  Pomelo.FarmHandler.openRequest(id,function (ex,sjson)
    if not ex then
      local data = sjson:ToData()
      
      cb()
    end
  end)
end


function _M.SeedRequest(id,code,cb)
  Pomelo.FarmHandler.seedRequest(id,code,function (ex,sjson)
    if not ex then
      local data = sjson:ToData()
      
      cb()
    end
  end)
end


function _M.WaterRequest(id,code,friendId,cb)
  Pomelo.FarmHandler.waterRequest(id,code,friendId,function (ex,sjson)
    if not ex then
      local data = sjson:ToData()
      
      cb()
    end
  end)
end


function _M.StealRequest(id,code,friendId,cb)
  Pomelo.FarmHandler.stealRequest(id,code,friendId,function (ex,sjson)
    if not ex then
      local data = sjson:ToData()
      
      cb()
    end
  end)
end


function _M.HarvestRequest(id,code,cb)
  Pomelo.FarmHandler.harvestRequest(id,code,function (ex,sjson)
    if not ex then
      local data = sjson:ToData()
      
      cb()
    end
  end)
end


function _M.ReqEnterMyfarm(id)
  Pomelo.FarmHandler.enterFarmSceneRequest(id,function (ex,sjson)
    if not ex then
      local data = sjson:ToData()
      
    end
  end)
end

function _M.fin(relogin)
  if relogin then

  end
end

function _M.InitNetWork()

end

return _M
