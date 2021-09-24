expeditionReportVo={}
function expeditionReportVo:new()
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
--enemyLevel 	对方的等级
--time			时间
--isVictory		是否获胜
--report 		战斗信息
--lostShip		损失坦克
--accessory		配件信息
--hero 			英雄数据
--place 		第几关
--emblemID    	军徽
--plane	    	飞机
--aitroops      AI部队
--extraReportInfo: 额外的报告信息（以后如果加新的功能字段，都放在这里面），该数据解析在global2里G_formatExtraReportInfo方法
--tskinList：坦克皮肤数据
--airship       飞艇
function expeditionReportVo:initWithData(rid,type,uid,name,enemyId,enemyName,enemyLevel,time,isVictory,report,lostShip,accessory,hero,place,emblemID,plane,attInfo,defInfo,weapon,armor,troops,isRead,aitroops,extraReportInfo,airship)
	self.rid=rid
	self.type=type
	self.uid=uid or 0
	self.name=name or ""
	self.enemyId=enemyId or 0
	self.enemyName=enemyName or ""
	if self.enemyId==0 then
		self.enemyName=getlocal(enemyName)
	end
	self.enemyLevel=enemyLevel or 1
	self.time=time or 0
	self.isVictory=isVictory or 1
	self.report=report or {}
	self.lostShip=lostShip or {}
    self.accessory=accessory or {}
    self.hero=hero or {{{},0},{{},0}}
    self.place=place
    self.emblemID=emblemID
    self.plane=plane
    self.attInfo=attInfo --攻击者信息[1]:战力,[2]:VIP,[3]:军衔,[4]:PIC,[5]:fhid,[6]:Lv,[7]:联盟名称
    self.defInfo=defInfo --防守者信息[1]:战力,[2]:VIP,[3]:军衔,[4]:PIC,[5]:fhid,[6]:Lv,[7]:联盟名称
    self.weapon=weapon --超级武器{进攻方，防守方}
    self.armor=armor --装甲矩阵{进攻方，防守方}
    self.troops=troops --敌我双方部队信息
    self.aitroops=aitroops --AI部队
    self.isRead=isRead or false
    self.tskinList=G_formatExtraReportInfo(extraReportInfo)
    self.airship=airship --飞艇{进攻方，防守方}
end