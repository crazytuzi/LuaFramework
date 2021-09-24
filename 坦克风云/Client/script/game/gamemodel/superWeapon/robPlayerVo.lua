robPlayerVo={}
function robPlayerVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function robPlayerVo:initWithData(tb,level)
	if tb then
		self.id=tb[1]
		self.name=tb[2] or ""
		self.level=tb[3] or 0
		self.power=tb[4] or 0
		self.pic=tb[5] or 1
		self.rate=tb[6] or 0
		if self.id and self.id<=10 then
			self.name=getlocal("super_weapon_rob_npc_name_"..self.id)
			self.pic=1
			if level and weaponrobCfg.robListRule and weaponrobCfg.robListRule.npcRobProb then
				if level+1>SizeOfTable(weaponrobCfg.robListRule.npcRobProb) then
					self.rate=weaponrobCfg.robListRule.npcRobProb[SizeOfTable(weaponrobCfg.robListRule.npcRobProb)]
				else
					self.rate=weaponrobCfg.robListRule.npcRobProb[level+1]
				end
			end
		end
	end
end

