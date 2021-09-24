alienMinesReturnReportVo={}
function alienMinesReturnReportVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

--type 类型为3，返航报告
--returnType 类型：1自己返回，2被攻击返回
--islandType 岛屿类型 1~3对应异星矿点
--place 地点 {x,y}
--level 矿等级
--alienPoint 个人异星积分
--aAlienPoint 军团异星积分
--resource 采集的钛矿资源信息
function alienMinesReturnReportVo:initWithData(rid,type,returnType,islandType,place,level,alienPoint,aAlienPoint,resource,time)
	self.rid=rid
	self.type=type
    self.returnType=returnType
	self.islandType=islandType
	self.place=place
	self.level=level
	self.alienPoint=alienPoint
	self.aAlienPoint=aAlienPoint
	self.resource=resource
	self.time=time
end
