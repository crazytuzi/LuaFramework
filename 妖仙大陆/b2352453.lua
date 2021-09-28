local _M = {}

_M.BloodAllList = nil
_M.BloodSuitAllList = nil



function _M.GetAllBloodsAttrsRequest(cb)
  Pomelo.BloodHandler.getBloodAttrsRequest(function (ex,sjson)
    if not ex then
      local data = sjson:ToData()
      cb(data.bloodAttrs  or {})
    end
  end)
end


function _M.GetEquipedBloodsRequest(id, cb)
  Pomelo.BloodHandler.getEquipedBloodsRequest(id, function (ex,sjson)
    if not ex then
      local data = sjson:ToData().bloodIds or {}
      local bloodList = {}
      for i,v in ipairs(data) do
        local ret = _M.GetBloodInfoById(v)
        table.insert(bloodList, ret)
      end
      cb(bloodList)
    end
  end)
end


function _M.EquipBloodRequest(id, cb)
  Pomelo.BloodHandler.equipBloodRequest(id, function (ex,sjson)
    if not ex then
      cb()
    end
  end)
end


function _M.UnequipBloodRequest(pos, cb)
  Pomelo.BloodHandler.unequipBloodRequest(pos, function (ex,sjson)
    if not ex then
      cb()
    end
  end)
end

function _M.GetBloodInfoByCode(code)
  for i,v in ipairs(_M.BloodAllList) do
      if v.Code == code then
        return v
      end
  end
  return nil
end

function _M.GetBloodInfoById(id)
    if _M.BloodAllList == nil then
    _M.InitAllBloodList()
  end
  
  for i,v in ipairs(_M.BloodAllList) do
      if v.BloodID == tonumber(id) then
        return v
      end
  end
  return nil
end

function _M.GetAllBloodSuitList()
  if  _M.BloodSuitAllList == nil then
    _M.InitAllBloodSuitList()
  end
  return _M.BloodSuitAllList
end

function _M.GetAllBloodList()
  if _M.BloodAllList == nil then
    _M.InitAllBloodList()
  end
  return _M.BloodAllList
end

function _M.InitAllBloodSuitList()
  _M.BloodSuitAllList = GlobalHooks.DB.GetFullTable("BloodSuitList")
end

function _M.InitAllBloodList()
    _M.BloodAllList = GlobalHooks.DB.GetFullTable("BloodList")
end

function _M.fin(relogin)
  if relogin then
  end
end

function _M.InitNetWork()
  
end

return _M
