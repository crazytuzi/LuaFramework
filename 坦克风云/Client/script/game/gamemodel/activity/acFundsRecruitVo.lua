acFundsRecruitVo=activityVo:new()
function acFundsRecruitVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function acFundsRecruitVo:updateSpecialData(data)
    if data ~=nil then
    	if data.reward ~= nil then
    		self.rewardCfg = data.reward
    	end
    	if data.ls ~=nil then
    		self:updateFundsRecruitData(data.ls)
    	end
    end
end
function acFundsRecruitVo:updateFundsRecruitData(data)
    if data ~=nil then
		self.ls = data
		print("acFundsRecruitVo",G_getWeeTs(base.serverTime),self.ls["lg"][3])
		if data["lg"]~=nil then
			if self.ls["lg"][3]~=nil and (G_getWeeTs(base.serverTime)> self.ls["lg"][3]) then
				self.ls["lg"][3]=G_getWeeTs(base.serverTime)
				self.ls["lg"][1] = base.serverTime
			end
			self.longinSt = data["lg"][1]
		end
		if data["gd"]~=nil then
			if self.ls["gd"][3]~=nil  and (G_getWeeTs(base.serverTime)> self.ls["gd"][3]) then
				self.ls["gd"][1] = 0
			end
			self.allianceDonateCount = data["gd"][1]
		end
		if data["gm"]~=nil then
			if self.ls["gm"][3]~=nil  and (G_getWeeTs(base.serverTime)> self.ls["gm"][3]) then
				self.ls["gm"][1] = 0
			end
			self.goldDonateCount = data["gm"][1]
		end
    end

end


