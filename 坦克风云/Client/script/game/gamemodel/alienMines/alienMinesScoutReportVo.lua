

alienMinesScoutReportVo={}
function alienMinesScoutReportVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

--report={type=3,target=targetStr,place={x="142",y="540"},time=time,shipTab=shipTab,resource={name="scout_content_product_4",num="2000"},helpDefender="",islandType=3}
--type 类型为2，侦察报告
--islandType 岛屿类型 1~5资源岛，6玩家
--defender 目标信息 {id,name,level}
--place 地点 {x,y}
--level 岛屿等级
--islandOwner 是否被占领 1被占领 0未被占领
--resource 玩家 可以掠夺5种最大资源量, 资源岛 占领并采集一种资源 每小时资源量
--defendShip 防守战船
--helpDefender 驻守玩家
--allianceName 被侦查玩家或驻守玩家的公会名字
--landform 侦查地形类型
--richLevel 富矿当前的等级
--tskinList 侦察目标部队皮肤数据
function alienMinesScoutReportVo:initWithData(rid,type,islandType,defender,place,level,time,islandOwner,resource,defendShip,helpDefender,allianceName,landform,richLevel,tskinList)
	self.rid=rid
	self.type=type
	self.islandType=islandType
	self.defender=defender
	self.place=place
    self.level=level
	self.time=time
	self.islandOwner=islandOwner
	self.resource=resource
	self.defendShip=defendShip
	self.helpDefender=helpDefender
    self.allianceName=allianceName
    self.landform=landform
    self.richLevel=richLevel
    self.tskinList = tskinList or {}
end