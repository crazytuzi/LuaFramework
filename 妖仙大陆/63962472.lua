

local _M = {}
_M.__index = _M

_M.StateCanNotGet = 0
_M.StateCanGet    = 1
_M.StateAlreadyGot= 2
_M.NoticeList = nil

function _M.firstPayGiftInfoRequest(cb, timeoutcb)
  
  Pomelo.PayGiftHandler.firstPayGiftInfoRequest(function (ex,sjson)
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

function _M.getFirstPayGiftRequest(cb)
  Pomelo.PayGiftHandler.getFirstPayGiftRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end

function _M.cdkNotify(c2s_cdk,c2s_channel)
  Pomelo.PlayerHandler.cdkNotify(c2s_cdk,c2s_channel)
end

function _M.dailyPayGiftInfoRequest(cb)
  Pomelo.PayGiftHandler.dailyPayGiftInfoRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end

function _M.getDailyPayGiftRequest(c2s_giftId,cb, timeoutcb)
  Pomelo.PayGiftHandler.getDailyPayGiftRequest(c2s_giftId,function (ex,sjson)
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

function _M.InitNetWork()
  print ("LVGiftInitWork")
end

return _M
