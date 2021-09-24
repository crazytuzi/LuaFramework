acTenDaysLoginVo=activityVo:new()
function acTenDaysLoginVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.allGiftsVo={}
	return nc
end

function acTenDaysLoginVo:updateSpecialData(data)
	if(data.c==-1)then
		self.over=true
		do return end
	end
	local awardData=data.d
	if(data.c)then
		self.allGiftsVo={}
		local tmpTb=activityCfg.tendaysLogin.award
		for k,v in pairs(tmpTb) do
			if v.award then
				local awardCfg=v.award
				local num
				if awardData and awardData[k] then
					num=tonumber(awardData[k])
				else
					num=0
				end
				local award=FormatItem(awardCfg,nil,true)
				local singleData={}
				singleData.id=k
				singleData.num=num
				singleData.award=award
				table.insert(self.allGiftsVo,k,singleData)
			end
		end
	end
end