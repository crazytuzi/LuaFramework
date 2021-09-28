
local _M = {}
_M.__index = _M


local GiftMsg = {}
local refresh = false

function _M.FindWillGiftMsg()
    local msg = nil
    if GiftMsg.giftList then
        for k,v in pairs(GiftMsg.giftList) do
            if v.state==1 then
                msg = v
                return msg
            end
        end
        if msg==nil then
            for k,v in pairs(GiftMsg.giftList) do
                if v.state==0 then
                    msg = v
                    return msg
                end
            end
        end
        return msg
    end
    return nil
end

local function SrotMsg(msg)
    if msg.giftList~=nil then
        table.sort( msg.giftList, function (a,b)
            return a.time<b.time
        end )
    end
end

function _M.GetGiftInfoRequest(cb,failCb)
  Pomelo.OnlineGiftHandler.getGiftInfoRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      GiftMsg = msg.s2c_gift
      
      SrotMsg(GiftMsg)
      cb(GiftMsg)
    else
      failCb()
    end
  end,XmdsNetManage.PackExtData.New(true, true, failCb))
end

function _M.GetOnlineTimeRequest(cb)
    Pomelo.OnlineGiftHandler.getOnlineTimeRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      cb(msg.s2c_onlineTime)
    end
  end)
end

function _M.ReceiveGiftRequest(c2s_id,cb)
    Pomelo.OnlineGiftHandler.receiveGiftRequest(c2s_id,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      GiftMsg = msg.s2c_gift
      SrotMsg(GiftMsg)
      cb()
    end
  end)
end

function GlobalHooks.DynamicPushs.GiftOnlinePush(ex, sjson)
  if ex == nil then
    local msg = sjson:ToData()
    GiftMsg = msg.s2c_gift
    
    SrotMsg(GiftMsg)
    refresh = true
    EventManager.Fire("Event.Hud.OnlineGiftPush",{})
  end
end

function _M.InitNetWork()
  Pomelo.OnlineGiftHandler.giftInfoPush(GlobalHooks.DynamicPushs.GiftOnlinePush)
end

function _M.GetGiftMsg()
    return GiftMsg
end

function _M.GetRefresh()
    return refresh
end

function _M.SetRefresh(ref)
    refresh = ref
end

function _M.GetOnlineTime()
    return OnlineTime
end

return _M
