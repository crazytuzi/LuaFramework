-- 飞机技能的数据模型
planeSkillVo={}

function planeSkillVo:new(scfg,gcfg)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.scfg=scfg
    nc.gcfg=gcfg
    return nc
end

function planeSkillVo:initWithData(sid,num,equipFlag)
	self.sid=sid --技能id
	self.num=num --技能数量
	self.equipFlag=equipFlag or 1 --是否装配的标记位
end

function planeSkillVo:getEquipBattleNum()
	-- return planeSkillVoApi:getBattleNumById(self.id)
end

function planeSkillVo:getUsableNum()
	-- return self.num-planeSkillVoApi:getBattleNumById(self.id)
end

function planeSkillVo:addNum(addValue)
	self.num=self.num or 0
	self.num=self.num+addValue
end



