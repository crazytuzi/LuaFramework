allianceCityVo={}
function allianceCityVo:new()
    local nc={
    	crystal=0,
    	cr=0,
    	pinfo={},
    	protectst=base.serverTime,
    	skill={},
    	attlist={},
    	deflist={},
    	state=nil,
    	maintain={},
	}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function allianceCityVo:initWithData(data)
	if data.crystal then
		self.crystal=data.crystal or 0 --城市水晶
	end
	if data.cr then
		self.cr=data.cr or 0 --城市稀土资源
	end
	if data.pinfo then
		self.pinfo=data.pinfo or {} --城市及领地所占地块数据 pinfo[1]：城市所占地块，pinfo[2]：基础领地所占地块，pinfo[3]：拓展的领地
	end
	if data.protectst then
		self.protectst=data.protectst or base.serverTime --保护开始时间
	end
	if data.skill then
		if self.skill then
			for k,v in pairs(self.skill) do
				if data.skill[k] and tonumber(data.skill[k])<tonumber(v) then
					data.skill[k]=tonumber(v)
				end
			end
		end
		self.skill=data.skill or {} --该军团城市的个人技能等级上限
	end
	if data.attlist then --进攻我方城市的队列
		for slotId,v in pairs(self.attlist) do --更新敌军来袭数据
			if data.attlist[slotId]~=nil and v.place[1] and v.place[2] then
				enemyVoApi:deleteEnemy(v.place[1],v.place[2])
			end
		end
		self.attlist=data.attlist
		enemyVoApi:addEnemy(self.attlist)
	end
	if data.deflist then --我方驻防队列
		self.deflist=data.deflist
	end
	if data.state then --城市是否放下的状态（0：未放置，1：已放置）
		self.state=data.state
	end
	if data.maintain then --维护相关数据 -- maintain = {t=0,w=0,rt=0,f=0}, --维护数据 {t=上一次维护时间,w=维护警告次数 1失去领地 2回收城市,rt=维护资源不足，回收城市时间,f=一个维护周期内战斗失败次数}
		self.maintain=data.maintain
	end
end