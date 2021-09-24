--参赛团队的数据
serverWarTeamAllianceVo={}
function serverWarTeamAllianceVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function serverWarTeamAllianceVo:init(data)
	self.aid=data.aid								--服务器内的公会ID, 与下面的id不同, 因为不同服务器的公会aid有可能相同
	self.serverID=tostring(data.zid) 				--属于的服务器ID
	self.id=self.serverID.."-"..self.aid			--唯一参赛ID
	self.name=data.name or ""						--公会名称
	self.signTime=tonumber(data.apply_at) or base.serverTime		--公会的报名时间
	self.baseTroops=tonumber(data.basetroops) or 0	--捐献的主基地部队
	self.serverName=getlocal("world_war_landType_unknow")
	local serverList=serverWarTeamVoApi:getServerList()
	for k,v in pairs(serverList) do
		if(v[1]==self.serverID)then
			self.serverName=v[2]
			break
		end
	end
	self.commander=data.commander or ""		--军团长名字
	self.level=data.level or 1 				--等级
	self.fight=data.fight or 0 				--战力
	self.num=data.num or 0 					--当前成员数量
end