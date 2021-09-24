acLmqrjVo=activityVo:new()

function acLmqrjVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acLmqrjVo:updateSpecialData(data)
	if data==nil then
		return
	end

	--当天零点时间戳
    if data.t ~= nil then
        self.todayTimer = data.t
    end

	--魅力值
	if data.mlz ~= nil then
		self.mlz=data.mlz
	end

    --已领取魅力奖励
    if data.rdm ~= nil then
        self.rdm=data.rdm
    end

	--拥有礼盒信息
	if data.lh ~= nil then
		self.lh=data.lh
	end

    --已完成任务
    if data.tk ~= nil then
        self.tk=data.tk
    end

    --已领取的任务
    if data.rd ~= nil then
        self.rd=data.rd
    end

	if data._activeCfg==nil then
		return
	end
	local activitCfg=data._activeCfg

	if self.version == nil then
    	self.version = 1
    end
    if activitCfg.version ~= nil then
    	self.version = activitCfg.version
    end

    --和谐版
    if activitCfg.hxcfg ~= nil and activitCfg.hxcfg.reward then
    	self.hxReward = activitCfg.hxcfg.reward
    end

    --好友赠送的等级限制
    if activitCfg.openLevel ~= nil then
    	self.openLevel = activitCfg.openLevel
    end

    --送礼分数(每个礼盒对应的分数)  sendgift={3,6,12}
    if activitCfg.sendgift ~= nil then
    	self.sendgift = activitCfg.sendgift
	end

    --礼盒奖励
    if activitCfg.reward ~= nil then
    	self.reward = activitCfg.reward
    end

    --礼盒单拆价格  cost={18,38,58}
    if activitCfg.cost ~= nil then
    	self.cost = activitCfg.cost
    end

    --礼盒5拆价格  cost5={81,171,261}
    if activitCfg.cost5 ~= nil then
    	self.cost5 = activitCfg.cost5
    end

    if activitCfg.rndNumReward ~= nil then
        self.rndNumReward = activitCfg.rndNumReward
        table.sort(self.rndNumReward, function(a,b) return a[1]<b[1] end)
    end

    --礼盒物品对应的魅力值(积分)
    if activitCfg.point ~= nil then
    	self.point = activitCfg.point
    end

    --运费(每个礼盒对应的赠送价格)  sendCost={3,6,12}
    if activitCfg.sendCost ~= nil then
    	self.sendCost = activitCfg.sendCost
	end

    --任务奖励
    if activitCfg.taskReward ~= nil then
        -- self.taskReward = activitCfg.taskReward
        self.taskReward={}
        for k,v in pairs(activitCfg.taskReward) do
            local _tempTb={id=k}
            for m,n in pairs(v) do
                _tempTb[m]=n
            end
            table.insert(self.taskReward,_tempTb)
        end
    end

end