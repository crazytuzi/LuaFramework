--月度签到
acMonthlySignVo=activityVo:new()
function acMonthlySignVo:updateSpecialData(data)
	if self.freereward == nil then
		self.freereward = {}
	end
	if self.payreward == nil then
		self.payreward = {}
	end
	if data.showReward ~= nil then
		if data.showReward.freereward ~= nil then
			self.freereward = data.showReward.freereward
		end
		if data.showReward.payreward ~= nil then
			self.payreward = data.showReward.payreward
		end
	end
	-- 领奖状态
	if self.freeState == nil then
		self.freeState = {}
	end
	if self.payState == nil then
		self.payState = {}
	end	
	if data.f ~= nil then
		self.freeState = data.f
	end
	if data.p ~= nil then
		self.payState = data.p
	end	
	if data.version then
		self.version =data.version
	end
	if self.refreshTs == nil or self.refreshTs == 0 then
		self.refreshTs = G_getWeeTs(base.serverTime)+86400  -- 刷新时间（比如排行结束时间，可能与st 或 et 有关系 ，所以有可能写到updateData里)
		self.refresh = false --排行榜结束排名后是否已刷新过数据
	end
end

function acMonthlySignVo:initRefresh()
	self.needRefresh = true -- 排行榜结束排名后是否需要刷新数据（比如排行结束后）   这里是从前一天到第二天时需要刷新数据
end