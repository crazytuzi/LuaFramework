acSlotMachineCommonVo=activityVo:new()

function acSlotMachineCommonVo:updateSpecialData(data)
    if self.lastResult == nil then
      self.lastResult = {1,1,1}
    end

    if data.ls ~= nil then
      self.lastResult = data.ls
    end
    
    if self.free == nil then
      self.free = 0 -- 每日免费抽奖次数
    end

    if data.free ~= nil then
      self.free = data.free
    end

    if self.cost == nil then
      self.cost = 99999 -- 非免费抽奖每次需要的金币
    end

    if data.cost ~= nil then
      self.cost = data.cost
    end
    
    if self.mul == nil then
      self.mul = 0 -- 模式倍数
    end
    
    if data.mul ~= nil then
      self.mul = data.mul
    end

    if self.mulCost == nil then
      self.mulCost = 99999 -- 模式倍数下花费的金币是self.mulCost * self.cost
    end
    
    if data.mulc ~= nil then
      self.mulCost = data.mulc
    end

    if self.conversionTable == nil then
      self.conversionTable = {}

      -- todo 测试数据
      -- self.conversionTable = {
      --     -- 同种道具抽到3次的奖励
      --     {id=1,num=3,reward={o={{a10073=5,index=1}}}}, -- id为 1 的道具抽到了 3 次
      --     {id=2,num=3,reward={o={{a10053=5,index=1}}}},
      --     {id=3,num=3,reward={o={{a10043=5,index=1}}}},
      --     {id=4,num=3,reward={o={{a10082=5,index=1}}}},
          
      --     -- 同种道具抽到2次的奖励
      --     {id=1,num=2,reward={o={{a10005=3,index=1}}}},
      --     {id=2,num=2,reward={o={{a10015=3,index=1}}}},
      --     {id=3,num=2,reward={o={{a10025=3,index=1}}}},
      --     {id=4,num=2,reward={o={{a10035=3,index=1}}}},
          
      --     -- 同种道具抽到1次的奖励
      --     {id=1,num=1,reward={o={{a10004=2,index=1}}}},
      --     {id=2,num=1,reward={o={{a10014=2,index=1}}}},
      --     {id=3,num=1,reward={o={{a10024=2,index=1}}}},
      --     {id=4,num=1,reward={o={{a10034=2,index=1}}}},
      -- }
    end
    
    if data.version then
        self.version = data.version
    end


    if data.r ~= nil then
      self.conversionTable = data.r
    end
    
    -- t --上一次免费抽奖当天凌晨的时间戳
    -- v -- 当日已免费抽奖次数
    if G_isToday(self.t) == true then
       self.refreshTs = G_getWeeTs(self.t)+86400  -- 刷新时间（比如排行结束时间，可能与st 或 et 有关系 ，所以有可能写到updateData里)
    else
       self.t = G_getWeeTs(base.serverTime)
       self.v = 0
       self.refreshTs = G_getWeeTs(base.serverTime)+86400  -- 刷新时间（比如排行结束时间，可能与st 或 et 有关系 ，所以有可能写到updateData里)
    end
    self.refresh = false --排行榜结束排名后是否已刷新过数据
end


function acSlotMachineCommonVo:initRefresh()
    self.needRefresh = true -- 排行榜结束排名后是否需要刷新数据（比如排行结束后）   这里是从前一天到第二天时需要刷新数据
end