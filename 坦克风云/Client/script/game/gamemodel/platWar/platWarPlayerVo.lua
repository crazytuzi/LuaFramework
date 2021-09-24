--跨平台战参赛选手的数据
platWarPlayerVo={}
function platWarPlayerVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function platWarPlayerVo:init(data)
	self.uid=data.u													--玩家在服务器内的uid
	self.serverID=tostring(data.z) 									--属于的服务器ID
	self.platID=data.pid											--玩家属于的平台ID
	self.id=self.platID.."-"..self.serverID.."-"..self.uid			--唯一参赛ID
	self.name=data.n or ""											--选手名称
	self.power=data.f or 0											--战斗力
	self.rank=data.rank or 0										--排行
	self.platName="Unknown platform"
	local platList=platWarVoApi:getPlatList()
	for k,v in pairs(platList) do
		if(v[1]==self.platID)then
			self.platName=v[2]
			break
		end
	end
end