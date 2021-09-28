

local _M = {}
_M.__index = _M

_M.StateCanNotGet = 0
_M.StateCanGet    = 1
_M.StateAlreadyGot= 2
_M.NoticeList = nil

function _M.interestActivityAdRequest(cb, timeoutcb)
  
  Pomelo.ActivityHandler.interestActivityAdRequest(function (ex,sjson)
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

function _M.activityInviteCodeRequest(c2s_inviteCode, cb)
  Pomelo.ActivityHandler.activityInviteCodeRequest(c2s_inviteCode, function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end

function _M.cdkNotify(c2s_cdk,c2s_channel)
   Pomelo.PlayerHandler.cdkRequest(c2s_cdk,c2s_channel,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
      end
  end)
end

function _M.activityLuckyAwardViewRequest(cb)
  Pomelo.ActivityHandler.activityLuckyAwardViewRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end

function _M.luckyAwardViewRequest(cb, timeoutcb)
  Pomelo.ActivityHandler.luckyAwardViewRequest(function (ex,sjson)
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

function _M.reSetluckyAwardRequest(cb)
  Pomelo.ActivityHandler.reSetluckyAwardRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end










function _M.activityNoticeRequest(cb)
  if _M.NoticeList  == nil then
    Pomelo.ActivityHandler.activityNoticeRequest(function (ex,sjson)
        if not ex then
          local param = sjson:ToData()
          _M.NoticeList = cjson.decode(param.s2c_context)
          cb(_M.NoticeList)

          _M.NoticeList = nil 
        end
    end)
  else
    cb(_M.NoticeList)
  end
end

function _M.activityLevelOrSwordRequest(c2s_activityId, cb)
  Pomelo.ActivityHandler.activityLevelOrSwordRequest(c2s_activityId, function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end

function _M.requestAward(activityId, awardId, cb)
  Pomelo.ActivityHandler.activityAwardRequest(awardId, activityId, function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb()
      end
  end)
end

function _M.requestFirstRecharge(cb)
  Pomelo.ActivityHandler.payFirstRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb(param.s2c_awardItems, param.s2c_state, param.s2c_awardId)
      end
  end)
end
function _M.requestNextRecharge(cb)
  Pomelo.ActivityHandler.paySecondRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb(param.s2c_awardItems, param.s2c_state, param.s2c_awardId)
      end
  end)
end

function _M.requestCumulativeRecharge(cb)
  Pomelo.ActivityHandler.payTotalRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb(param.s2c_data)
      end
  end)
end


function _M.DailyRechargeGetInfoRequest(cb)
  Pomelo.ActivityFavorHandler.dailyRechargeGetInfoRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb(param)
      end
  end)
end

function _M.DailyRechargeGetAwardRequest(awardId, cb)
  Pomelo.ActivityFavorHandler.dailyRechargeGetAwardRequest(awardId, function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb()
      end
  end)
end


function _M.SuperPackageGetInfoRequest(cb)
  Pomelo.ActivityFavorHandler.superPackageGetInfoRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb(param.superPackageInfo)
      end
  end)
end


function _M.SuperPackageBuyRequest(id,cb)
  local channelId = SDKWrapper.Instance:GetChannel()
  local deviceId = SDKWrapper.Instance.udid
  local osType = PublicConst.OSType
  Pomelo.ActivityFavorHandler.superPackageBuyRequest(id,channelId,deviceId,osType,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb(param)
      end
  end)
end


function _M.LimitTimeGiftInfoRequest(cb)
  Pomelo.ActivityFavorHandler.limitTimeGiftInfoRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end


function _M.LimitTimeGiftBuyRequest(id,cb)
  Pomelo.ActivityFavorHandler.limitTimeGiftBuyRequest(id,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end


function _M.SevenDayPackageGetInfoRequest(cb)
  Pomelo.ActivityFavorHandler.sevenDayPackageGetInfoRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb(param.sevenDayPackageInfo)
      end
  end)
end


function _M.SevenDayPackageAwardRequest(id,cb)
  Pomelo.ActivityFavorHandler.sevenDayPackageAwardRequest(id,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb()
      end
  end)
end


function _M.RecoveredInfoRequest(cb)
  Pomelo.ActivityFavorHandler.recoveredInfoRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb(param.recoveredInfo)
      end
  end)
end


function _M.RecoveredRequest(id,type,cb)
  Pomelo.ActivityFavorHandler.recoveredRequest(id,type,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb()
      end
  end)
end


function _M.DailyDrawInfoRequest(id, cb)
  
  Pomelo.ActivityFavorHandler.dailyDrawInfoRequest(id, function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        param.freeCountUpdateTimeStamp = param.freeCountUpdateTimeStamp/1000
        
        cb(param)
      end
  end)
end


function _M.DailyDrawRequest(times,type,id,cb)
  
  Pomelo.ActivityFavorHandler.dailyDrawRequest(times,type,id,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb(param)
      end
  end)
end

function _M.requestCumulativeConsume(cb)
  Pomelo.ActivityHandler.consumeTotalRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb(param.s2c_data)
      end
  end)
end
function _M.requestFund(cb)
  Pomelo.ActivityHandler.activityOpenFundsRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb(param.s2c_data, param.s2c_hasBuyNum, param.s2c_needDiamond, param.s2c_needVipLevel, param.s2c_buyState)
      end
  end)
end
function _M.requestBuyFund(cb)
  Pomelo.ActivityHandler.activityBuyFundsRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb()
      end
  end)
end











function _M.openChangeRequest(cb)
  Pomelo.ActivityHandler.openChangeRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb(param)
      end
  end)
end

function _M.ActivityLsRequest(cb)
  Pomelo.ActivityHandler.activityLsRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb(param)
      end
  end)
end


function _M.SingleRechargeGetInfoRequest(cb)
  Pomelo.ActivityFavorHandler.singleRechargeGetInfoRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param.singleRechargeInfo)
      end
  end)
end


function _M.SingleRechargeAwardRequest(id,cb)
  Pomelo.ActivityFavorHandler.singleRechargeAwardRequest(id,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb()
      end
  end)
end


function _M.ContinuousRechargeGetInfoRequest(cb)
  Pomelo.ActivityFavorHandler.continuousRechargeGetInfoRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param.continuousRechargeInfo)
      end
  end)
end


function _M.ContinuousRechargeAwardRequest(id,cb)
  Pomelo.ActivityFavorHandler.continuousRechargeAwardRequest(id,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb()
      end
  end)
end


function _M.GetRichInfoRequest(cb)
  Pomelo.RichHandler.getRichInfoRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb(param)
      end
  end)
end


function _M.DiceRequest(cb)
  Pomelo.RichHandler.diceRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb(param)
      end
  end)
end


function _M.FetchTurnAwardRequest(id,cb)
  Pomelo.RichHandler.fetchTurnAwardRequest(id,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb(param)
      end
  end)
end


function _M.RevelryRechargeGetColumnRequest(cb)
  Pomelo.ActivityRevelryHandler.revelryRechargeGetColumnRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb(param)
      end
  end)
end


function _M.RevelryRechargeGetInfoRequest(day, cb)
  Pomelo.ActivityRevelryHandler.revelryRechargeGetInfoRequest(day, function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb(param.info or {})
      end
  end)
end


function _M.RevelryRechargeAwardRequest(id,cb)
  Pomelo.ActivityRevelryHandler.revelryRechargeAwardRequest(id,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        
        cb()
      end
  end)
end


function _M.GetSevenGoalRequest(cb)
  Pomelo.SevenGoalHandler.getSevenGoalRequest(function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end


function _M.FetchAwardRequest(id,cb)
  Pomelo.SevenGoalHandler.fetchAwardRequest(id,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end

local function UpdateRedPointPush(ex, sjson)
  if ex then return end
  local data = sjson:ToData()
  EventManager.Fire("Event.Activity.UpdateRedPoint", data.redPoint)
end

local function SuperPackageBuyPush(ex, sjson)
  if ex then return end
  local data = sjson:ToData()
  EventManager.Fire("Event.Activity.UpdateCZLB", data.packageId)
end

function _M.InitNetWork()
  
  
  Pomelo.ActivityFavorHandler.superPackageBuyPush(SuperPackageBuyPush)
end

return _M
