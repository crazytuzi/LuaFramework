local netgift = {}
function netgift.dataUpdated_(param)
  local cur_time_giftid = param.cur_time_giftid
  local lefttime = param.lefttime
  if cur_time_giftid ~= nil or lefttime ~= nil then
    gift.online:dataUpdate(cur_time_giftid, lefttime)
  end
  local cur_lv_giftid = param.cur_lv_giftid
  if cur_lv_giftid ~= nil then
    gift.levelup:dataUpdate(cur_lv_giftid)
  end
  local cur_login_giftid = param.cur_login_giftid
  if cur_login_giftid ~= nil then
    gift.levelup:dataLogindate(cur_login_giftid)
  end
  local lv_gift_op = param.lv_gift_op
  if lv_gift_op == 0 then
    gift.levelup:dataShowUpdate(false)
  elseif lv_gift_op == 1 then
    gift.levelup:dataShowUpdate(true)
  end
  local login_gift_op = param.login_gift_op
  if login_gift_op == 0 then
    gift.levelup:dataShowLogindate(false)
  elseif login_gift_op == 1 then
    gift.levelup:dataShowLogindate(true)
  end
  local cur_sig_giftid = param.cur_sig_giftid
  local month_sig_cnt = param.month_sig_cnt
  local month_paysig_cnt = param.month_paysig_cnt
  local sig = param.sig
  if cur_sig_giftid ~= nil or month_sig_cnt ~= nil or month_paysig_cnt ~= nil or sig ~= nil then
    gift.checkin:dataUpdate(month_sig_cnt, month_paysig_cnt, sig, cur_sig_giftid)
  end
end
function netgift.udpateAll(param, ptc_main, ptc_sub)
  print("netgift.udpateAll:", param, ptc_main, ptc_sub)
  netgift.dataUpdated_(param)
end
function netgift.acceptResult(param, ptc_main, ptc_sub)
  print("netgift.acceptResult:", param, ptc_main, ptc_sub)
  gift.acceptGiftResult(param.giftid, param.result)
end
function netgift.udpateData(param, ptc_main, ptc_sub)
  print("netgift.udpateData:", param, ptc_main, ptc_sub)
  netgift.dataUpdated_(param)
end
function netgift.setAcceptGiftOfIdentify(param, ptc_main, ptc_sub)
  print("netgift.setAcceptGiftOfIdentify:", param, ptc_main, ptc_sub)
  gift.identify:setAcceptIdentify(param.t_g)
end
function netgift.setAddExIdentifyGift(param, ptc_main, ptc_sub)
  print("netgift.setAddExIdentifyGift:", param, ptc_main, ptc_sub)
  gift.identify:setAddIdentifyGift(param.t_g)
end
function netgift.setShowGiftOfIdentify(param, ptc_main, ptc_sub)
  print("netgift.setShowGiftOfIdentify:", param, ptc_main, ptc_sub)
  gift.identify:setShowIdentify(param.t_s)
end
function netgift.setGetGiftOfFestival(param, ptc_main, ptc_sub)
  print("netgift.setGetGiftOfFestival:", param, ptc_main, ptc_sub)
  gift.festival:setHasGetFestival(param.t_g)
end
function netgift.setGetGiftOfFresh(param, ptc_main, ptc_sub)
  print("netgift.setGetGiftOfFresh:", param, ptc_main, ptc_sub)
  local t = param.t or 0
  gift.special:setFreshGiftTime(t)
end
function netgift.setNewTermCheckInData(param, ptc_main, ptc_sub)
  gift.newTermCheckIn:setNewTermCheckInData(param)
end
function netgift.setGuoQingCheckInData(param, ptc_main, ptc_sub)
  gift.guoQingCheckIn:setGuoQingCheckInData(param)
end
return netgift
