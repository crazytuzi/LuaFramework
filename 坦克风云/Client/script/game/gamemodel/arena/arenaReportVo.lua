require "luascript/script/game/gamemodel/arena/arenaReportVoApi"

arenaReportVo={}
function arenaReportVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end


--rid			战报id
--type 			自己是否是攻击者 1攻击 2防守
--uid 			自己的id
--name 			自己的名字
--enemyId		对方的id
--enemyName 	对方的名字
--time			时间
--isRead		是否已读
--isVictory		是否获胜
--report 		战斗信息
--rankChange	排名变化
--lostShip		损失坦克
--accessory		配件信息
--initReport	是否有战报数据，没数据需请求后台
--hero 			英雄数据
--emblemID		军徽数据
--plane			飞机数据
--aitroops      AI部队
--extraReportInfo战报新增功能的数据
function arenaReportVo:initWithData(rid,type,uid,name,enemyId,enemyName,time,isRead,isVictory,report,rankChange,lostShip,accessory,initReport,hero,emblemID,plane,attInfo,defInfo,weapon,armor,troops,aitroops,extraReportInfo)
	self.rid=rid
	self.type=type
	self.uid=uid or 0
	self.name=name or ""
	self.enemyId=enemyId or 0
	self.enemyName=enemyName or ""
	self.time=time or 0
	self.isRead=isRead or 0
	self.isVictory=isVictory or 1
	self.report=report or {}
	self.rankChange=rankChange or 0
	self.lostShip=lostShip or {}
    self.accessory=accessory or {}
    self.initReport=initReport or false
    self.hero=hero or {{{},0},{{},0}}
    self.emblemID=emblemID
    self.plane=plane
    self.attInfo=attInfo --攻击者信息[1]:战力,[2]:VIP,[3]:军衔,[4]:PIC,[5]:fhid,[6]:Lv,[7]:联盟名称
    self.defInfo=defInfo --防守者信息[1]:战力,[2]:VIP,[3]:军衔,[4]:PIC,[5]:fhid,[6]:Lv,[7]:联盟名称
    self.weapon=weapon --超级武器{进攻方，防守方}
    self.armor=armor --装甲矩阵{进攻方，防守方}
    self.troops=troops --敌我双方部队信息
    self.aitroops=aitroops --敌我双方AI部队信息
    self.tskinList=G_formatExtraReportInfo(extraReportInfo)
end