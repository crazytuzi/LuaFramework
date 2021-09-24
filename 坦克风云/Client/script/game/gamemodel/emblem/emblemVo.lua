-- 军徽的数据模型
emblemVo={}

function emblemVo:new(cfg)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.cfg=cfg
    return nc
end

--eId 装备Id,eNum 装备数量
function emblemVo:initWithData(eId,eNum)
	self.id = eId
	self.num = eNum
end

function emblemVo:getEquipNum()
	return self.num
end

function emblemVo:getEquipBattleNum()
	return emblemVoApi:getBattleNumById(self.id)
end

--装备装配到大师上的数量
function emblemVo:getTroopEquipNum()
	return emblemTroopVoApi:getTroopEquipedNumById(self.id)
end

--装备未出征且未装配的数量
function emblemVo:getUsableNum()
	-- return self.num - emblemVoApi:getBattleNumById(self.id)
	local battleNum = self:getEquipBattleNum()
	local troopNum = self:getTroopEquipNum()
	print("id,battleNum,troopNum---->>",self.id,battleNum,troopNum)
	if self.num > battleNum + troopNum then
		return self.num - (battleNum + troopNum)
	end
	return 0
end

function emblemVo:addNum(eNum)
	if self.num == nil then
		self.num = eNum
	else
		self.num = self.num + eNum
	end
end



