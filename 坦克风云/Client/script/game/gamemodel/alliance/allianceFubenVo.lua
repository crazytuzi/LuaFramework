allianceFubenVo={}
function allianceFubenVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

-- "maxbid": 0, 		军团已解锁的最大关卡id
-- "akcount": 0, 		今日个人攻击次数
-- "rwcount": { }, 		今日领奖数据(详细数据，领奖次数，前台自己算)
-- "krcount": { }, 		军团今日击杀次数
-- "refresh_at": "0", 	刷新时间 （以此为标识，当日数据会清空）
-- tank: {id,tank},		副本数据
function allianceFubenVo:initWithData(maxbid,akcount,rwcount,krcount,refresh_at,tank,boss)
	self.unlockId=maxbid
	self.attackCount=akcount
	self.rewardCount=rwcount
	self.killCount=krcount
	self.refreshTime=refresh_at
	self.tank=tank
	self.boss=boss
end



