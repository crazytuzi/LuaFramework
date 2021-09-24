acDayRechargeForEquipVo=activityVo:new()

function acDayRechargeForEquipVo:updateSpecialData(data)
    -- t --上一次充值当天凌晨的时间戳
    -- c -- 当日领奖次数
    -- v -- 当日充值总额
    if G_isToday(self.t) == true then
       self.refreshTs = G_getWeeTs(self.t)+86400  -- 刷新时间（比如排行结束时间，可能与st 或 et 有关系 ，所以有可能写到updateData里)
    else
       self.t = G_getWeeTs(base.serverTime)
       self.c = 0
       self.v = 0
       self.refreshTs = G_getWeeTs(base.serverTime)+86400  -- 刷新时间（比如排行结束时间，可能与st 或 et 有关系 ，所以有可能写到updateData里)
    end
    self.refresh = false --排行榜结束排名后是否已刷新过数据

    if data then
      self.datas = data
    end
end


function acDayRechargeForEquipVo:initRefresh()
    self.needRefresh = true -- 排行榜结束排名后是否需要刷新数据（比如排行结束后）   这里是从前一天到第二天时需要刷新数据
end