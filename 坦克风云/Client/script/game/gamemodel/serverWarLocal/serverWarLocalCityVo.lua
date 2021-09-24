--群雄争霸每一个战场城市的数据
serverWarLocalCityVo={}

function serverWarLocalCityVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

--初始化城市数据
--param cfg: serverWarLocalMapCfg里面的cityCfg的一个元素
function serverWarLocalCityVo:init(cfg)
	self.id=cfg.id
	self.cfg=cfg
	self.allianceID=0						--被哪个军团占领
	self.npc=0								--是否有NPC
	self.hp=100								--NPC的部队剩余血量百分比, 只有鹰巢有
end