returnReportVo={}
function returnReportVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

--type 类型为3，返航报告；类型为4，采集部队返回报告；5.查找目标基地；6.查找目标部队；7.进攻军团城市返回；8.驻防军团城市返回；9.飞机战机革新击飞玩家城市的进攻方战报；10.战机革新击飞技能被击飞玩家的通知战报
--returnType 类型：1被保护 2已搬家 3己方已占领 4同军团盟友已占领 5不能攻击同军团的玩家 6协防失败，目标已退出军团 7目标的协防部队队列已满，部队将返回自己的基地
--islandType 岛屿类型 1~5资源岛，6玩家，7叛军，9欧米伽小队
--name 名字
--place 地点 {x,y}
--allianceName 玩家或驻守玩家的公会名字
--time 部队返回的时间
--fleetload 部队的载重
--resource 部队带回的资源列表
--richLevel 富矿等级
--goldMineLv 金矿等级
--boom 繁荣度
-- power 战力
-- glory 繁荣度
-- searchtype 部队查找类型：1.正常；2.敌人没有正在采集的部队；3.敌人所有采集部队均已被侦查！
-- leftTime 采集剩余时间
-- curRes 当前采集量
-- isHasFleet 是否还有未找到的部队
-- defendShip 防守部队
-- rebel 叛军
function returnReportVo:initWithData(rid,type,returnType,islandType,name,place,level,allianceName,richLevel,goldMineLv,time,fleetload,resource,boom,power,glory,searchtype,leftTime,curRes,isHasFleet,defendShip,rebel,award,privateMine)
	self.rid=rid
	self.type=type
    self.returnType=returnType
	self.islandType=islandType
	self.name=name
	self.place=place
	self.level=level
	self.allianceName=allianceName
	self.richLevel=richLevel or 0
	self.goldMineLv=goldMineLv or 0
	self.time=time or 0
	self.fleetload=fleetload or 0
	self.resource=resource
	self.award=award
	self.boom=boom

	self.power=power or 1
	self.glory=glory
	self.searchtype=searchtype or 1
	self.leftTime=leftTime or 0
	self.curRes=curRes or 0
	self.isHasFleet=isHasFleet
	self.defendShip=defendShip or {}
	self.rebel=rebel or {}
	self.privateMine = privateMine or nil
	self.tskinList={}
end