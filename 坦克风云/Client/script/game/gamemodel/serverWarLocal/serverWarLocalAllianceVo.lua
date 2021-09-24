--群雄争霸参赛团队的数据
serverWarLocalAllianceVo={}
function serverWarLocalAllianceVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.side=0
    return nc
end

function serverWarLocalAllianceVo:init(data)
	self.aid=tonumber(data[1])						--服务器内的公会ID, 与下面的id不同, 因为不同服务器的公会aid有可能相同
	self.serverID=tonumber(data[2]) 				--属于的服务器ID
	self.id=self.serverID.."-"..self.aid			--唯一参赛ID
	self.name=data[3] or ""							--公会名称
	self.serverName=getlocal("world_war_landType_unknow")
	self.leader=tostring(data[4]) or ""			--军团长的名字
	self.rankPoint=tonumber(data[5]) or 0		--天梯分
	self.power=tonumber(data[6]) or 0			--战斗力
end