acThrivingVo=activityVo:new()

function acThrivingVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acThrivingVo:updateSpecialData(data)

    if data~=nil then
        if data._activeCfg then
            self.activeCfg=activityCfg.zzrsCfg[1]
        end
        if self.activeCfg then
        	if self.activeCfg.bonusPointReward then
        		self.bigRewardTb = self.activeCfg.bonusPointReward
        	end

        	if self.activeCfg.taskList then
        		self.taskList = self.activeCfg.taskList
        	end
        	if self.activeCfg.qtype then
        		self.taskClassTb = self.activeCfg.qtype
        	end
        end

        if data.tk then
        	self.cpltTaskNumTb = data.tk
        end
        if self.cpltTaskNumTb ==nil then
        	self.cpltTaskNumTb = {}
        end
        if data.rd then
        	self.hasBeenRecAwardTb = data.rd
        end
        if self.hasBeenRecAwardTb ==nil then
        	self.hasBeenRecAwardTb = {}
        end
        if data.c then
        	self.hadBigAward =data.c
        end
        if self.hadBigAward == nil then
        	self.hadBigAward = 0
        end
    end
end