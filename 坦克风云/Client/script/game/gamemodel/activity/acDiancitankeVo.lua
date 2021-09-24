acDiancitankeVo=activityVo:new()
function acDiancitankeVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acDiancitankeVo:updateSpecialData(data)
	if data~=nil then
  		if data.cost then
  			self.costTb=data.cost
  		end

  		if data.decay then
  			self.decayTb=data.decay --衰减百分比
  		end

  		if data.consume then --改装需要的道具
    		self.consume = data.consume
    	end

    	if data.reward then
    		self.reward=data.reward  --奖励的四种道具
    	end

    	if data.range then
    		self.range=data.range  --奖励放的地方
    	end

    	if data.addval then
    		self.addval=data.addval  --三个按钮转动范围
    	end

      if data.mulc then
        self.mulc=data.mulc -- 金币倍数
      end

      if data.mul then
        self.mul=data.mul  -- 物品倍数
      end

      if data.t then
        self.lastTime=data.t -- 上一次免费抽奖的时间戳
      end

      if data.n then
        self.score = data.n
      end
      if data.report then
        self.tankActionData =data.report
      end

      if data.range then
        self.range =data.range
      end

    end
end