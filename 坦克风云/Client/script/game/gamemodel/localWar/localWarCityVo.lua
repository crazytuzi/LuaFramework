--区域战每一个战场城市的数据
localWarCityVo={}

function localWarCityVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

--初始化城市数据
--param cfg: localWarMapCfg里面的cityCfg的一个元素
function localWarCityVo:init(cfg)
	self.id=cfg.id
	self.cfg=cfg
	self.allianceID=0						--被哪个军团占领
	self.hp=self.cfg.hp						--剩余血量
	self.npc=0								--是否有NPC
end

function localWarCityVo:getHp()
	if(self.hp>self:getMaxHp())then
		return self:getMaxHp()
	else
		return self.hp
	end
end

--获取最大血量
--因为主基地的血量在无人占领或者打爆之后会变，所以封装一个方法
function localWarCityVo:getMaxHp()
	if(self.cfg.type==1)then
		if(self:isDestroyed())then
			return self.cfg.hp
		else
			return localWarMapCfg.baseCityHp
		end
	else
		return self.cfg.hp
	end
end

--是否是已经被摧毁的状态，没有人的主基地或者被打爆一次的主基地会被摧毁，血量上限变成1
function localWarCityVo:isDestroyed()
	if(self.cfg.type==1)then
		if(self.allianceID==0)then
			return true
		else
			local rank
			for k,v in pairs(localWarFightVoApi:getAllianceList()) do
				if(v.id==self.allianceID)then
					rank=v.side
					break
				end
			end
			local originRank
			for k,v in pairs(localWarMapCfg.baseCityID) do
				if(v==self.id)then
					originRank=k
					break
				end
			end
			if(rank~=originRank)then
				return true
			else
				return false
			end
		end
	else
		return false
	end
end