acMoveForwardVo=activityVo:new()
function acMoveForwardVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.activeRes=0.5
	nc.activeExp=0.5
	nc.dailyCfg={}
	nc.totalCfg={}
	nc.progressDaily={}
	nc.progressTotal={}
	nc.lastBattleTs=0
	return nc
end

function acMoveForwardVo:updateSpecialData(data)
	if(data.activeExp)then
		self.activeExp=tonumber(data.activeExp)
	end
	if(data.activeRes)then
		self.activeRes=tonumber(data.activeRes)
	end
	local function sortFunc(a,b)
		local id1=tonumber(string.sub(a.id,2))
		local id2=tonumber(string.sub(b.id,2))
		return id1<id2
	end
	if(data.taskChallenge)then
		self.dailyCfg={}
		for tid,v in pairs(data.taskChallenge) do
			v.id=tid
			table.insert(self.dailyCfg,v)
		end
		table.sort(self.dailyCfg,sortFunc)
	end
	if(data.passChallenge)then
		self.totalCfg={}
		for sid,v in pairs(data.passChallenge) do
			v.id=sid
			table.insert(self.totalCfg,v)
		end
		table.sort(self.totalCfg,sortFunc)
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
