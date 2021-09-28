

local _M = {}
_M.__index = _M

local AllGift
local InBoxIcons = {}
local LVGiftState = 0

local function SetLVGiftState()
  LVGiftState = 0
  if AllGift and #AllGift > 0 then
    for k,v in pairs(AllGift) do
    for ke,vl in pairs(v.giftSimpleStructs) do
        if vl.giftState == 1 then
          LVGiftState = LVGiftState+1
        end
      end
    end
  end
end

function _M.GetAllEventDatasRequest(cb)
	Pomelo.ActivityHandler.getAllEventDatasRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      AllGift = msg.s2c_eventDatas
      SetLVGiftState()
      cb()
    end
  end)
end

local function SetGetGift(evtid,giftid)
  for k,v in pairs(AllGift) do
    if v.eventId == evtid+0 then
      for ke,vl in pairs(v.giftSimpleStructs) do
        if vl.giftId == giftid+0 then
          vl.giftState = 2
          break
        end
      end
    end
  end
end

function _M.GetEventGiftRequest(c2s_eventId,c2s_giftId,cb)
  Pomelo.ActivityHandler.getEventGiftRequest(c2s_eventId,c2s_giftId,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      print (sjson)
      SetGetGift(c2s_eventId,c2s_giftId)
      LVGiftState = LVGiftState - 1
      if LVGiftState == 0 then
        EventManager.Fire("Event.Menu.SetLVGiftFlag", {param = 0})
      end
      cb()
    end
  end)
end

function _M.CheckEventGiftItemsRequest(c2s_eventId,c2s_giftId,cb)
  Pomelo.ActivityHandler.checkEventGiftItemsRequest(c2s_eventId,c2s_giftId,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      InBoxIcons = msg.giftItemStructs
      
      cb()
    end
  end)
end

function _M.GetAllGift()
  return AllGift
end

function _M.GetInBoxIcons()
  return InBoxIcons
end

function _M.GetGiftNum()
  return LVGiftState
end

local function setGiftPush(msg)
  for k,v in pairs(AllGift) do
    if v.eventId == msg.s2c_eventId then
      for ke,vl in pairs(v.giftSimpleStructs) do
        if vl.giftId == msg.s2c_giftId then
          vl.giftState = 1
          break
        end
      end
    end
  end
end

function _M.InitNetWork()
  print ("LVGiftInitWork")
end


return _M
