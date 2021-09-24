acMoscowGamblingGaiVo=activityVo:new()

function acMoscowGamblingGaiVo:updateSpecialData(data)
	if self.rart1Num==nil then
		self.rart1Num=0
	end
	if self.rart2Num==nil then
		self.rart2Num=0
	end
	if type(data.t)=="table" then
		self.rart1Num = tonumber(data.t.part1) or 0	--碎片1数量
		self.rart2Num = tonumber(data.t.part2) or 0	--碎片2数量
	end

	if self.lastTime==nil then
		self.lastTime=0
	end
	if data.d then
		self.lastTime = data.d.ts or 0	--上一次抽奖时间
	end
	if data.version then
		self.version =data.version
	end
	if self.makeupCost==nil then
		self.makeupCost=0
	end
	if self.gemCost==nil then
		self.gemCost=38
	end

	if data.data then
		if data.data.upgradePartConsume then
			self.makeupCost=tonumber(data.data.upgradePartConsume) or 0	--合成一次需要碎片数量，20个碎片合成10个，全部合成
		end
		if data.data.gemCost then
			self.gemCost=tonumber(data.data.gemCost) or 0	--抽奖一次消耗金币
		end
		if self.partMap== nil then
			self.partMap = data.data.partMap
		end
	end

end