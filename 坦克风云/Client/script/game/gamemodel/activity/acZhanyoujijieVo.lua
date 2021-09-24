--周年庆活动
acZhanyoujijieVo=activityVo:new()
function acZhanyoujijieVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	-- nc.rp=0
	return nc
end

function acZhanyoujijieVo:updateSpecialData(data)
	--配置
	if data._activeCfg then
		self.acCfg=data._activeCfg
	end
	--是否是活跃用户，nil需要调用初始化接口，1流失用户，2活跃用户
	if data.u then
		self.isAfk=data.u
	end
	--回归时等级
	if data.v then
		self.returnLv=data.v or 0
	end
	--邀请码
	if data.ic then
		self.code=data.ic
	end
	-- --绑定玩家列表
	-- if data.bd then
	-- 	--格式同data.rechargeInfo
	-- 	--{{4000010,1478272335,420,1,"playerName",60,1,1200},{id，时间，已领取该玩家的金币数，是否已经领取过绑定奖励，名字，等级，玩家头像图片，该绑定用户总充值金币数}}
	-- 	self.bindPlayers=data.bd or {}
	-- end
	--绑定玩家充值信息列表
	--{{4000010,1478272335,420,1,"playerName",60,1,1200},{id，时间，已领取该玩家的金币数，是否已经领取过绑定奖励，名字，等级，玩家头像图片，该绑定用户总充值金币数}}
	if self.bindPlayers==nil then
		self.bindPlayers={}
	end
	if data.bd then
		for k,v in pairs(data.bd) do
			local uid=tonumber(v[1]) or 0
			local time=tonumber(v[2]) or 0
			local hasRewardNum=tonumber(v[3]) or 0
			local isReward=tonumber(v[4]) or 0
	        local name=v[5] or ""
	        local level=tonumber(v[6]) or 0
	        local pic=v[7] or 1
	        local isHas=false
	        local info={uid=uid,time=time,hasRewardNum=hasRewardNum,isReward=isReward,name=name,level=level,pic=pic}
	        for m,n in pairs(self.bindPlayers) do
	        	if uid==n.uid then
	        		isHas=true
	        		for i,j in pairs(n) do
	        			if info[i] then
		        			self.bindPlayers[m][i]=info[i]
		        		end
	        		end
	        	end
	        end
	        if isHas==false then
				table.insert(self.bindPlayers,info)
			end
		end
	end
	if data.rechargeInfo then
		if self.bindPlayers then
			for k,v in pairs(self.bindPlayers) do
				if data.rechargeInfo[k] then
					local buyTotalNum=data.rechargeInfo[k] or 0
					self.bindPlayers[k].buyTotalNum=buyTotalNum
				end
			end
		end
    end

	--是否已经领取回归奖励，r有值表示已经领取过了,无值的时候表示可领取
	if data.r then
		self.isRewardReturn=data.r or 0
	end
	--累计充值
	if self.buyGems==nil then
		self.buyGems=0
	end
	if data.rc1 then
		self.buyGems=data.rc1 or 0
	end
	-- 充值奖励领取详情0|1,key分别对应每个档次
	if data.r1 then
		self.hasRewardTb=data.r1 or {}
	end
end