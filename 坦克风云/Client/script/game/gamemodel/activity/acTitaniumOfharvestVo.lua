acTitaniumOfharvestVo=activityVo:new()
function acTitaniumOfharvestVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function acTitaniumOfharvestVo:updateSpecialData(data)
	if data~=nil then
		 -- 每天充值给我的资源
		if data.dayres then
			self.dayres = data.dayres
		end
		 -- 已激活打折
		if data.value then
			self.value = data.value
		end

		if data.task then
			self.task = data.task
		end
		if data.res then
			self.res = self.res
		end

		-- 累计充值天数
		if data.pd then
			self.pd = data.pd
		end

		if data.pfr then
			self.pfr =  data.pfr
		end

		if data.pf then
			self.pf = data.pf
			acTitaniumOfharvestVoApi:setTaiNum(0)
		end

		if data.pt then
			self.pt = data.pt
		end

		-- 每天任务的具体信息   rd是每天任务的领取情况
		if data.d then
			local newData = data.d
			-- 生产坦克数量
			if newData.t then
				self.tankNum = newData.t
			end
			if newData.t==nil then
				self.tankNum=0
			end

			-- 生产taikuang数量
			if newData.r then
				self.RNum = newData.r
			end
			if newData.r==nil then
				self.RNum=0
			end

			-- 任务标记
			if newData.rd then
				if newData.rd.l then
					self.lFlag = newData.rd.l
				end
				if newData.rd.t then
					self.tankFlag = newData.rd.t[1]
				end
				if newData.rd.r then
					local num = SizeOfTable(newData.rd.r)
					if num ==1 then
						self.rFlag1 = newData.rd.r[1]
					end
					if num ==2 then
						self.rFlag1 = newData.rd.r[1]
						self.rFlag2 = newData.rd.r[2]
					end
				end

			end


		end

	end
end

function acTitaniumOfharvestVo:updateMySpecialData()
	self.tankFlag=nil
	self.rFlag1=nil
	self.rFlag2=nil
	self.lFlag=nil
end
