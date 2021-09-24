--区域战参赛团队的数据
localWarAllianceVo={}
function localWarAllianceVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function localWarAllianceVo:init(data)
	self.id=tonumber(data.aid)						--公会ID
	self.name=data.name or ""						--公会名称
	self.side=tonumber(data.ranking)				--属于哪一方, 根据报名的排名来算的,99是防守王城的
	self.commander=data.commander and tostring(data.commander) or ""	--团长名字
	if(self.side>4)then
		self.side=99
	end
end