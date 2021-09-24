serverWarLocalReportVo={}
function serverWarLocalReportVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function serverWarLocalReportVo:initWithData(tb,report)
	if tb then
		-- 1：id
		-- 2：建筑类型
		-- 3：攻击方名字
		-- 4：防守方名字
		-- 5：攻击方军团名字
		-- 6：防守方军团名字
		-- 7：是否胜利：0否，1是
		-- 8：是否占领：0否，1是
		-- 9：时间
		if tb[1] then
			self.id=tonumber(tb[1])
		end
		if tb[2] then
			self.buildType=tb[2]
		end
		if tb[3] then
			self.attackName=tb[3]
		end
		if tb[4] then
			self.defenceName=tb[4]
		end
		if tb[5] then
			self.attackAName=tb[5]
		end
		if tb[6] then
			self.defenceAName=tb[6]
		end
		if tb[7] then
			self.isVictory=tonumber(tb[7])
		end
		if tb[8] then
			self.isOccupied=tonumber(tb[8])
		end
		if tb[9] then
			self.time=tonumber(tb[9])
		end
		
		if tostring(self.defenceName)=="-1" or tostring(self.defenceName)=="0" then
			self.defenceAName=""
			self.defenceName=getlocal("local_war_npc_name")
			local mapCfg=serverWarLocalFightVoApi:getMapCfg(1)
			if self.buildType and mapCfg and mapCfg.bossCity then
				if self.buildType==mapCfg.bossCity then
					self.defenceName=getlocal("serverWarLocal_npc_boss")
				end
			end
		end
		local selfAlliance=allianceVoApi:getSelfAlliance()
		if selfAlliance and selfAlliance.name then
			local selfAllianceName=selfAlliance.name
			if self.attackAName==selfAllianceName then
				self.isAttack=1
			else
				self.isAttack=0
			end
		end
		if self.isVictory then
			if (self.isAttack==1 and self.isVictory==1) or (self.isAttack==0 and self.isVictory==0) then
				self.isVictory=1
			else
				self.isVictory=0
			end
		end
	end
	if report then
		self.report=report
	end
end
