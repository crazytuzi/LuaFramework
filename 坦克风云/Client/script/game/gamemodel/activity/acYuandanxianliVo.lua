acYuandanxianliVo = activityVo:new()
function acYuandanxianliVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    return nc
end


function acYuandanxianliVo:updateSpecialData( data )
	-- if self.rewardlist == nil then
	-- 	self.rewardlist ={}
	-- end 

	if data.rewardlist ~=nil then --抽奖列表
		self.rewardlist =data.rewardlist
	end

	if self.gems ==nil then
		self.gems =playerVoApi:getGems()
	end
	if data.cost then --单抽金币限制
		self.oneDraw = data.cost
	end
	if data.mulc and data.cost then --十抽金币限制
		self.tenDraw = data.cost * data.mulc
	end

	if data.freeTime then --每日强化限制
		self.freeTime = data.freeTime
	end

	if data.successUp then --强化倍率的几倍
		self.successUp = data.successUp
	end

	if data.t ~=nil then
		self.lastTime=data.t
	end 

	if data.q then
		self.strengTime = data.q --强化次数当夜0点 时间戳
	end


	if data.reportList then
		self.reportList = data.reportList
	end

	if data.reportNum then
		self.reportNum =data.reportNum
	end

	if data.w then  --当天实际强化次数
			self.curStrengTime =data.w
	end

	if data.bigReward then --每日充值领好礼 最终奖励
		self.bigReward = data.bigReward
	end

	if data.m then
		self.isBigReward = data.m
	end

	if data.dailyReward then --每日充值领好礼，礼品列表
		self.dailyReward = data.dailyReward
	end

	if data.p then
		self.sevenRe = data.p
	end


    --黑客修改记录需要的金币数

    if self.reviseCfg == nil then
      self.reviseCfg = 99999
    end

    if data.rR ~= nil then 
      self.reviseCfg = data.rR
    end
   
end
-- function acYuandanxianliVo:initRefresh()
--     self.needRefresh = true -- 活动结束后是否需要刷新数据（比如排行结束后）
--     self.refresh = false -- 活动结束后是否已刷新过数据
-- end
