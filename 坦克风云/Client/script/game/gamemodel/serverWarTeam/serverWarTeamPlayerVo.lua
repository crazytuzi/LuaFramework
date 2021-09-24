--在战斗中的每个参赛选手的数据
serverWarTeamPlayerVo={}
function serverWarTeamPlayerVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function serverWarTeamPlayerVo:init(data)
	self.uid=tonumber(data.uid)											--玩家在服务器内的uid, 与id不同, 因为不同服务器的玩家uid有可能相同
	self.serverID=tostring(data.zid) 									--属于的服务器ID
	self.allianceID=data.aid 											--公会ID
	self.id=self.serverID.."-"..self.allianceID.."-"..self.uid			--唯一参赛ID
	self.name=data.nickname or ""										--选手名称
	self.cityID=data.target												--选手所在或者将要到达的城市
	self.arriveTime=tonumber(data.dist)									--选手抵达城市的时间
	self.lastCityID=data.prev											--选手上一次所在的城市
	self.canMoveTime=tonumber(data.revive) or 0							--选手可以开始移动的时间戳, 当玩家死亡或者刚进入战场的时候会有一段时间不能移动
	--1是红方, 2是蓝方
	local list=serverWarTeamFightVoApi:getAllianceList()
	local tmpID=self.serverID.."-"..self.allianceID
	if(tmpID==list[1].id)then
		self.side=1
	else
		self.side=2
	end
	if(self.cityID==nil)then
		if(self.side==1)then
			self.cityID=serverWarTeamFightVoApi:getMapCfg().baseCityID[1]
		else
			self.cityID=serverWarTeamFightVoApi:getMapCfg().baseCityID[2]
		end
	end
	if(self.lastCityID==nil)then
		if(self.side==1)then
			self.lastCityID=serverWarTeamFightVoApi:getMapCfg().baseCityID[1]
		else
			self.lastCityID=serverWarTeamFightVoApi:getMapCfg().baseCityID[2]
		end
	end
	self.lastEnemyID=data.enemy or nil
	self.battleTime=tonumber(data.battle_at) or 0						--选手最近发生战斗的时间戳
	self.battleCity=data.bplace or 0									--选手最近发生战斗的城市
	self.speedUpNum=tonumber(data.speedUpNum) or 0						--选手购买加速的次数
	self.role=tonumber(data.role) or 0									--选手的角色，军团长副军团长还是普通成员
end