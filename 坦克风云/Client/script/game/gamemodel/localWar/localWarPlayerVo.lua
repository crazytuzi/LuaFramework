--区域战战斗中的每个参赛选手的数据
localWarPlayerVo={}
function localWarPlayerVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function localWarPlayerVo:init(data)
	self.uid=tonumber(data[1])											--玩家在服务器内的uid, 与id不同, 因为不同服务器的玩家uid有可能相同
	self.name=data[2] or ""												--选手名称
	local selfUid=playerVoApi:getUid()
	if tonumber(selfUid)==tonumber(self.uid) then
		self.name=playerVoApi:getPlayerName()
	end
	self.allianceID=tonumber(data[3]) 									--公会ID
	self.cityID=data[4]													--选手所在或者将要到达的城市
	self.battleCity=data[5] or 0										--选手最近发生战斗的城市
	self.battleTime=tonumber(data[6]) or 0								--选手最近发生战斗的时间戳
	self.arriveTime=tonumber(data[7]) or 0								--选手抵达城市的时间
	self.canMoveTime=tonumber(data[8]) or 0								--选手可以开始移动的时间戳, 当玩家死亡或者刚进入战场的时候会有一段时间不能移动
	self.lastCityID=data[9]												--选手上一次所在的城市
	self.lastEnemyID=tonumber(data[10]) or 0							--选手上次对阵的敌人
	if(localWarFightVoApi:getDefenderAlliance() and localWarFightVoApi:getDefenderAlliance().id==self.allianceID)then
		if(self.cityID==nil or self.cityID==0 or type(self.cityID)~="string")then
			self.cityID=localWarMapCfg.capitalID
		end
		self.allianceName=localWarFightVoApi:getDefenderAlliance().name
	else
		for k,v in pairs(localWarFightVoApi:getAllianceList()) do
			if(v.id==self.allianceID)then
				if(self.cityID==nil or self.cityID==0 or type(self.cityID)~="string")then
					self.cityID=localWarMapCfg.baseCityID[v.side]
				end
				self.allianceName=v.name
				break
			end
		end
	end
	if(self.allianceName==nil)then
		self.allianceName=getlocal("local_war_cityName_"..self.cityID)
	end
	if(self.lastCityID==nil or self.lastCityID==0 or type(self.lastCityID)~="string")then
		self.lastCityID=self.cityID
	end
end