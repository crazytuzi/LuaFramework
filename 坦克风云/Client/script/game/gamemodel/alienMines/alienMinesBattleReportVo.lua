alienMinesBattleReportVo = {}
function alienMinesBattleReportVo:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

--report={rid=1,type=1,target="player",place={x="123",y="324"},time=time,isVictory=true,awardTab=awardTab,resourceTab=resourceTab,lostShip=lostShip,credit="+4",islandType=2,helpDefender=""}
--type 类型为1，战斗报告
--islandType 岛屿类型 1~5资源岛，6玩家
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
--dLandform防守方地形类型
--rp 军功 {攻击方,防守方}
--hero 英雄信息，{{攻击方将领信息,将领强度},{防守方将领信息,将领强度}}
--emblemID 军徽信息{攻击方装备ID,防守方装备ID}
--plane     飞机信息{攻击方飞机,防守方飞机} 格式{{id,强度},{id,强度}}
--aitroops AI部队
--tskinList 坦克皮肤数据
function alienMinesBattleReportVo:initWithData(rid, type, islandType, attacker, defender, place, level, time, islandOwner, isVictory, award, resource, lostShip, credit, helpDefender, report, attackerPlace, accessory, aLandform, dLandform, acaward, rp, hero, emblemID, plane, weapon, armor, troops, aitroops, extraReportInfo, airshipId)
    self.rid = rid
    self.type = type
    self.islandType = islandType
    self.attacker = attacker
    self.defender = defender
    self.place = place
    self.level = level
    self.time = time
    self.islandOwner = islandOwner
    self.isVictory = isVictory
    self.award = award
    self.resource = resource
    self.lostShip = lostShip
    self.credit = credit
    self.helpDefender = helpDefender
    self.report = report
    self.attackerPlace = attackerPlace
    self.accessory = accessory
    self.aLandform = aLandform
    self.dLandform = dLandform
    self.acaward = acaward
    self.rp = rp or {0, 0}
    self.hero = hero
    self.emblemID = emblemID
    self.plane = plane
    self.weapon = weapon --超级武器{进攻方，防守方}
    self.armor = armor --装甲矩阵{进攻方，防守方}
    self.troops = troops --敌我双方部队信息
    self.aitroops = aitroops --AI部队
    self.tskinList = G_formatExtraReportInfo(extraReportInfo)
    self.airship = airshipId
end
