acGhostWarsVo=activityVo:new()

function acGhostWarsVo:updateSpecialData(data)

	if data.collectspeedup~=nil then
		self.collectspeedup=data.collectspeedup
	end
	if data.pointup~=nil then
		self.pointup=data.pointup
	end
	if data.minLv~=nil then
		self.minLv = data.minLv
	end
	
end