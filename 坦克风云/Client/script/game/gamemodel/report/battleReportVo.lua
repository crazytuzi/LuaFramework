battleReportVo={}
function battleReportVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

--report={rid=1,type=1,target="player",place={x="123",y="324"},time=time,isVictory=true,awardTab=awardTab,resourceTab=resourceTab,lostShip=lostShip,credit="+4",islandType=2,helpDefender=""}
--type 类型为1，战斗报告
--islandType 岛屿类型 1~5资源岛，6玩家，7叛军
--attacker 攻击者信息 {id,name,level,allianceName}
--defender 目标信息 {id,name,level,allianceName}
--place 地点 {x,y}
--isVictory 是否获胜
--award 奖励
--resource 掠夺或掠夺资源
--lostShip 双方损失战船
--credit 获得或损失荣誉
--helpDefender 协防部队
--report 战斗信息
--accessory 配件信息
--aLandform 攻击方地形类型
--dLandform 防守方地形类型
--rp        军功 {攻击方,防守方}
--hero      英雄信息，{{攻击方将领信息,将领强度},{防守方将领信息,将领强度}}
--battleRichLevel 富矿等级
--pic       头像
--rebel     叛军数据
--acData    活动数据
--emblemID 军徽信息{攻击方装备ID,防守方装备ID}
--plane     飞机信息{攻击方飞机,防守方飞机} 格式{{id,强度},{id,强度}}
--extraReportInfo: 额外的报告信息（以后如果加新的功能字段，都放在这里面），该数据解析在global2里G_formatExtraReportInfo方法
--tskinList：坦克皮肤数据
--airShipId: 飞艇ID
--shipboss：欧米伽小队(飞艇boss)
function battleReportVo:initWithData(rid,type,islandType,attacker,defender,place,level,time,islandOwner,isVictory,award,resource,lostShip,credit,helpDefender,report,attackerPlace,accessory,aLandform,dLandform,acaward,rp,hero,battleRichLevel,goldMineLv,disappearTime,pic,rebel,acData,emblemID,plane,weapon,armor,troops,xixue,aitroops,effect,extraReportInfo,privateMine,airShipId,shipboss)
    self.rid=rid
    self.type=type
    self.islandType=islandType
    self.attacker=attacker
    self.defender=defender
    self.place=place
    self.level=level
    self.time=time
    self.islandOwner=islandOwner
    self.isVictory=isVictory
    self.award=award
    self.resource=resource
    self.lostShip=lostShip
    self.credit=credit
    self.helpDefender=helpDefender
    self.report=report
    self.attackerPlace=attackerPlace
    self.accessory=accessory
    self.aLandform=aLandform
    self.dLandform=dLandform
    self.acaward = acaward
    self.rp=rp or {0,0}
    self.hero=hero
    self.richLevel=battleRichLevel or 0
    self.goldMineLv=goldMineLv or 0
    self.disappearTime=disappearTime or 0
    self.pic=pic or 1
    self.rebel=rebel or {}
    self.acData=acData or {}
    self.emblemID=emblemID
    self.plane=plane
    self.weapon=weapon --超级武器{进攻方，防守方}
    self.armor=armor --装甲矩阵{进攻方，防守方}
    self.aitroops=aitroops --AI部队
    self.troops=troops --敌我双方部队信息
    self.xixue=xixue --该战报是不是飞机戏谑技能生效的战报
    self.effect=effect --改战报是不是摩登之城限时皮肤(b6)生效的战报 1:是
    self.tskinList=G_formatExtraReportInfo(extraReportInfo)
    self.privateMine=privateMine
    self.airship=airShipId
    self.shipboss=shipboss
end