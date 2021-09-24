acYwzqVo=activityVo:new()
function acYwzqVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.activeRes=0.5
	nc.activeExp=0.5
	nc.activeDie=0
	nc.dailyCfg={}
	nc.totalCfg={}
	nc.progressDaily={}
	nc.progressTotal={}
	nc.lastBattleTs=0
	return nc
end

function acYwzqVo:updateSpecialData(data)

	self.acCfg = data._activeCfg
	if self.acCfg then
		if(self.acCfg.activeExp)then
			self.activeExp=tonumber(self.acCfg.activeExp)
		end
		if(self.acCfg.activeRes)then
			self.activeRes=tonumber(self.acCfg.activeRes)
		end
		if self.acCfg.activeDie then
			self.activeDie=tonumber(self.acCfg.activeDie)
		end
		local function sortFunc(a,b)
			local id1=tonumber(string.sub(a.id,2))
			local id2=tonumber(string.sub(b.id,2))
			return id1<id2
		end
		if(self.acCfg.taskChallenge)then
			self.dailyCfg={}
			for tid,v in pairs(self.acCfg.taskChallenge) do
				v.id=tid
				table.insert(self.dailyCfg,v)
			end
			table.sort(self.dailyCfg,sortFunc)
		end
		if(self.acCfg.passChallenge)then
			self.totalCfg={}
			for sid,v in pairs(self.acCfg.passChallenge) do
				v.id=sid
				table.insert(self.totalCfg,v)
			end
			table.sort(self.totalCfg,sortFunc)
		end
	end
	if(data.t)then
		self.lastBattleTs=tonumber(data.t)
	end
	if(data.r)then
		self.progressDaily=data.r
	end
	if(data.p)then
		self.progressTotal=data.p
	end
end
