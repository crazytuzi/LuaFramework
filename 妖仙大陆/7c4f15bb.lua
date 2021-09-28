local _M = {}
_M.__index = _M

local Player = require"Zeus.Model.Player"

_M.AllMastery = nil
_M.countItems = nil
_M.CallFuc = nil

function _M.GetMasteryInfoRequest(cb)
	Pomelo.MasteryHandler.getMasteryInfoRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      _M.AllMastery = msg.s2c_mastery
      cb()
    end
  end)
end

function _M.ActiveMasteryRequest(c2s_pos,cb)
  Pomelo.MasteryHandler.activeMasteryRequest(c2s_pos,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      local msgg = msg.s2c_data.masterys[1]
      _M.AllMastery.masterys[msgg.pos] = msgg
      _M.AllMastery.curMagicNum = msg.s2c_data.curMagicNum
      cb(msg)
    end
  end)
end

function _M.MasteryRingRequest(cb)
  Pomelo.MasteryHandler.masteryRingRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      cb(msg.s2c_ring)
    end
  end)
end

function _M.GetRingRequest(c2s_ringId,cb)
  Pomelo.MasteryHandler.getRingRequest(c2s_ringId,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      _M.AllMastery = msg.s2c_data
      cb(msg)
      if _M.CallFuc then
        _M.CallFuc()
      end
    end
  end)
end

function _M.masteryDeliverRequest(c2s_pos,cb)
  Pomelo.MasteryHandler.masteryDeliverRequest(c2s_pos,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      cb()
    end
  end)
end

function _M.GetAllMastery()
  return _M.AllMastery
end

function _M.SetCallBack(fuc)
  _M.CallFuc = fuc
end

function _M.GetItemNum(code)
  local num = 0
  
  for k,v in pairs(_M.countItems) do
    if v.code == code then
      num = v.num
      break 
    end
  end
  return num
end

local function changItemNum(data)
  local bl = true
  for k,v in pairs(_M.countItems) do
    if v.code == data.code then
      _M.countItems[k].num = data.num
      bl = false
    end
  end
  if bl then
    table.insert(_M.countItems,data)
  end
end

function GlobalHooks.DynamicPushs.CountItemChangePush(ex, sjson)
  if ex == nil then
    local msg = sjson:ToData()
    if msg.s2c_data~= nil then
      for i=1,#msg.s2c_data do
        changItemNum(msg.s2c_data[i])
      end
      if _M.CallFuc then
        _M.CallFuc()
      end
    end
  end
end

function _M.InitNetWork()
   if _M.countItems == nil then
    local item = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.MASTERYS)
    item_pb = require("item_pb")
    _M.countItems = {}
    if type(item) == "string" then
      local stream = ZZBase64.decode(item)
      local msg = item_pb.CountItems()
      msg:ParseFromString(stream)
      msg = msg:ToData()
      if msg~=nil and msg.items~=nil then
        
        _M.countItems = msg.items
      end
    end
  end
  Pomelo.ItemHandler.countItemChangePush(GlobalHooks.DynamicPushs.CountItemChangePush)
end

return _M
