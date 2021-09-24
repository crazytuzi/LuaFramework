--每一个战场城市的数据
serverWarTeamCityVo={}

function serverWarTeamCityVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

--初始化城市数据
--param cfg: serverWarTeamMapCfg里面的cityCfg的一个元素
function serverWarTeamCityVo:init(cfg)
	self.id=cfg.id
	self.cfg=cfg
	self.allianceID=0						--被哪个军团占领
	self.hp=serverWarTeamCfg.baseBlood		--主基地有血量, 血量掉到0就挂掉了
end

--城市属于红方还是蓝方, 1是红方, 2是蓝方
function serverWarTeamCityVo:getSide()
	if(self.id==serverWarTeamFightVoApi:getMapCfg().baseCityID[1] or self.id==serverWarTeamFightVoApi:getMapCfg().airport[1])then
		return 1
	elseif(self.id==serverWarTeamFightVoApi:getMapCfg().baseCityID[2] or self.id==serverWarTeamFightVoApi:getMapCfg().airport[2])then
		return 2
	end
	local list=serverWarTeamFightVoApi:getAllianceList()
	if(self.allianceID==list[1].id)then
		return 1
	elseif(self.allianceID==list[2].id)then
		return 2
	else
		return 0
	end
end