--参赛选手的数据
worldWarPlayerVo={}
function worldWarPlayerVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function worldWarPlayerVo:init(data)
	self.uid=data.uid								--玩家在服务器内的uid, 与id不同, 因为不同服务器的玩家uid有可能相同
	self.type=data.type								--玩家报名的是NB赛还是SB赛
	self.serverID=tostring(data.zid) 				--属于的服务器ID
	self.id=self.uid.."-"..self.serverID			--唯一参赛ID
	self.name=data.nickname or ""					--选手名称
	self.allianceName=data.aname					--公会名称
	self.pic=data.pic or 1							--头像
	self.rank=data.rank or 1						--军衔
	self.level=data.level or 1						--等级
	self.power=data.fc or 0							--战斗力
	self.serverName=getlocal("world_war_landType_unknow")
	if data.serverName then
		self.serverName=data.serverName
	end
	local serverList=worldWarVoApi:getServerList()
	for k,v in pairs(serverList) do
		if(v[1]==self.serverID)then
			self.serverName=v[2]
			break
		end
	end
	self.topRank=data.topRank or 0 					--淘汰赛最后的排名
	--战斗和战报面板需要的数据
	self.strategy=data.strategy or {}				--此轮战斗的战术
	self.point=data.point or 0 						--此轮战斗获得的商店积分
	self.rankPoint=data.rankPoint or 0 				--此轮战斗排名积分变化，上升或下降
end