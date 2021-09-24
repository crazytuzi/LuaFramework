--群雄争霸战场上每一支部队的数据vo
serverWarLocalTroopVo={}
function serverWarLocalTroopVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function serverWarLocalTroopVo:init(data)
	self.uid=tonumber(data[1])								--部队所属玩家的uid
	self.cityID=data[2]										--部队所在或者将要到达的城市
	self.battleCity=data[3] or 0							--部队最近发生战斗的城市
	self.battleTime=tonumber(data[4]) or 0					--部队最近发生战斗的时间戳
	self.arriveTime=tonumber(data[5]) or 0					--部队抵达城市的时间
	self.canMoveTime=tonumber(data[6]) or 0					--部队可以开始移动的时间戳, 当玩家死亡或者刚进入战场的时候会有一段时间不能移动
	self.lastCityID=data[7]									--部队上一次所在的城市
	self.lastEnemyID=data[8]								--部队上次对阵的敌人
	self.serverID=tonumber(data[9])							--服ID
	self.troopID=tonumber(data[10])							--部队编号
	self.heroID=tostring(data[11])							--带队的英雄ID
	if(self.heroID=="")then
		self.heroID=nil
	end
	self.hpPercent=tonumber(data[12]) or 100				--部队剩余血量百分比
	self.killNum=tonumber(data[13]) or 0					--连杀数, 死亡之后清零
	self.nickname=tostring(data[14]) or ''					--玩家昵称
	self.aid=tonumber(data[15]) or 0						--军团ID
	self.id=self.serverID.."-"..self.uid.."-"..self.troopID
	self.name=self.nickname.."-"..self.troopID
	self.allianceID=self.serverID.."-"..self.aid
	local allianceIndex
	if(self.aid~=0)then
		for k,v in pairs(serverWarLocalFightVoApi:getAllianceList()) do
			if(v.id==self.allianceID)then
				self.allianceName=v.name
				allianceIndex=k
				break
			end
		end
	end
	if(self.cityID==nil or self.cityID==0 or type(self.cityID)~="string")then
		if(allianceIndex)then
			self.cityID=serverWarLocalFightVoApi:getMapCfg().baseCityID[allianceIndex]
		end
	end
	if(self.allianceName==nil)then
		if(self.cityID)then
			self.allianceName=getlocal("serverWarLocal_cityName_"..self.cityID)
		else
			self.allianceName=""
		end
	end
	if(self.lastCityID==nil or self.lastCityID==0 or type(self.lastCityID)~="string")then
		self.lastCityID=self.cityID
	end
end