acCustomLotteryVo=activityVo:new()

function acCustomLotteryVo:updateSpecialData(data)
    
    if self.cost == nil then
      self.cost = 99999 -- 非免费抽奖每次需要的金币
    end

    if data.cost ~= nil then
      self.cost = data.cost
    end

    if data.v ~=nil then
      self.lotteryNum = data.v
    end


    if self.time == nil and data.time ==nil then
      self.time = -1
    end
   
    if data.time ~=nil then --总抽奖次数 
      self.time = data.time
    end

    if self.good ==nil then
      self.good = {}
    end
    if data.good ~=nil then
      self.good = data.good 
    end
    -- self.good={{p="p427"}, {p="p428"}}

    if self.list ==nil then
      self.list = {}
    end
    if data.list ~=nil then
      self.list = data.list 
    end
    -- self.list={{p="p427",num=2},{p="p428",num=1},{p="p429",num=2},{p="p430",num=5}}

    if data.rewardList~=nil then
      self.rewardList = data.rewardList
    end

    if data.num10 then
      self.num10=data.num10
    end
    if data.num50 then
      self.num50=data.num50
    end

end