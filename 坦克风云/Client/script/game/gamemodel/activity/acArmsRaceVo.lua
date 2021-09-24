acArmsRaceVo=activityVo:new()

function acArmsRaceVo:updateSpecialData(data)
	if self.reward == nil then
		self.reward = {}
	end

	if data.reward then
		if data.reward then
			self.reward={}
			for k, v in pairs(data.reward) do
				if k ~= nil and v ~= nil then
					table.insert(self.reward, {tankId = k, id = v.id, num = v.num, n = v.n, r = v.r})
				end
			end
		end
	end


	-- 领奖记录的统计
	if self.recode == nil then
		self.recode = {}
	end
	if data.armsracelog ~= nil then
		self.recode = data.armsracelog
		local function sortFunc(a,b)
			if a and b and a[3] and b[3] then
				if a[3] > b[3] then
					return true
				end
			end
		end
		table.sort(self.recode,sortFunc)
    end

    if self.flag == nil then
    	self.flag = 0
    end
    if self.produceData == nil then
    	self.produceData = {}
	end
    if data.v ~= nil and type(data.v)=="table" and SizeOfTable(data.v)>0 then
    	self.produceData = data.v -- 已生产数据
    	self.flag = 0
    end

end

function acArmsRaceVo:addMoreRecode(recodes)
	if recodes ~= nil then
		for k, v in pairs(recodes) do
			if v ~= nil then
				table.insert(self.recode, v)
		    end
		end
    end
end