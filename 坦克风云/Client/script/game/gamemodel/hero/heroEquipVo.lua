heroEquipVo={}
function heroEquipVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.hid=""
    
    return nc
end

function heroEquipVo:initWithData(hid,data)
	self.hid=hid
	if data then
		self.eList={}
		for k,v in pairs(data) do
			
			if self.eList[k]==nil then
				self.eList[k]=v
			end
		end
	end
end


-- 获取装备，强化，进阶，觉醒等级
-- eid装备id，index是（1强化，2进阶，3觉醒）
function heroEquipVo:getLevelByEidAndIndex(eid,index)
	if self.eList and self.eList[eid] then
		return self.eList[eid][index]
	end
	if index==3 then--觉醒默认是0级，其他默认为1级
		return 0
	end
	return 1
end