local function returnCfg(clientPlat)
local commonCfg={
  -- ------------------------------------------------------
  -- 切记
  -- clientVersionCfg 是返给前端的简写形式，如果相应的值变了，也要更改clientVersionCfg中的值
  -- ------------------------------------------------------

--50级 初始化配置
version1={
    --建筑等级上限 60
    buildingMaxLevel=60,
    --改造厂中未开放的部队id
    unlockForceIdStr={10006,10016,10026,10036,10007,10017,10027,10037},
    --用户等级以及技能等级上限 60
    roleMaxLevel=60,
    --个人关卡章节数解锁至 11 章
    unlockCheckpoint=11,
    --军团科技等级上限 30
    allianceMaxLevel=30,
    --个人等级等级上限 60
    techMaxLevel=60,
    --军团副本章节数解锁至 4 章
    aChallengeLevel=4,
    --任务等级上限 60
    unlockTaskLevel=60,
    --配件开启部位 4 个
    unlockAccParts=4,
    --配件补给线关卡解锁至 15 关
    unlockEliteChallenge=15,
    --将领突破品质上限为 3 品阶
    unlockHeroThrouh=3,
    --Vip开放等级上限为 9
    unlockVipLevel=9,
    --富矿成长品质上限为 3
    mapHeatlevel=3,
    --建造场中未开放的部队id
    unlockBuildForceIdStr={10006,10016,10026,10036,10007,10017,10027,10037},
    --坦克军团商店解锁 普通坦克&活动坦克Id
    unlockTankShopIdStr={4,4},
    --异星科技解锁等级
    unlockAlienTech=50,
    --精英章节数解锁至 0 章
    unlockElitepoint=0,
    --超级武器开放部位
    unlockSwParts=8,
    --超级武器开启等级
    unlockSwLevel=15,
    --将领装备强化等级上限
    unEquipLevel=9,
    --配件科技的科技强化等级上限
    unlockAccTechLvl=0,
    --配件科技的触发技能等级上限
    unlockAccSkillLvl=0,
    --紫色装备可升级上限
    unlockEmblemLevel1=3,
    --橙色装备可升级上限
    unlockEmblemLevel2=2,
    --紫色7号战斗位升级上限
        unlockPlaneLevel1=2,
    --橙色7号战斗位升级上限
        unlockPlaneLevel2=1,
    --前端用的配置格式
    clientVersionCfg = {60,{10006,10016,10026,10036,10007,10017,10027,10037},60,11,30,60,4,60,4,15,3,9,3,{10006,10016,10026,10036,10007,10017,10027,10037},{4,4},50,0,8,15,9,0,0,3,2,2,1},
},
--60级 初始化配置
version2={
    --建筑等级上限 60
    buildingMaxLevel=60,
    --改造厂中未开放的部队id
    unlockForceIdStr={10006,10016,10026,10036,10007,10017,10027,10037},
    --用户等级以及技能等级上限 60
    roleMaxLevel=60,
    --个人关卡章节数解锁至 11 章
    unlockCheckpoint=11,
    --军团科技等级上限 30
    allianceMaxLevel=30,
    --个人等级等级上限 60
    techMaxLevel=60,
    --军团副本章节数解锁至 4 章
    aChallengeLevel=4,
    --任务等级上限 60
    unlockTaskLevel=60,
    --配件开启部位 6 个
    unlockAccParts=6,
    --配件补给线关卡解锁至 15 关
    unlockEliteChallenge=15,
    --将领突破品质上限为 4 品阶
    unlockHeroThrouh=4,
    --Vip开放等级上限为 9
    unlockVipLevel=9,
    --富矿成长品质上限为 3
    mapHeatlevel=3,
    --建造场中未开放的部队id
    unlockBuildForceIdStr={10006,10016,10026,10036,10007,10017,10027,10037},
    --坦克军团商店解锁 普通坦克&活动坦克Id
    unlockTankShopIdStr={8,4},
    --异星科技解锁等级
    unlockAlienTech=60,
    --精英章节数解锁至 0 章
    unlockElitepoint=0,
    --超级武器开放部位
    unlockSwParts=8,
    --超级武器开启等级
    unlockSwLevel=15,
    --将领装备强化等级上限
    unEquipLevel=9,
    --配件科技的科技强化等级上限
    unlockAccTechLvl=0,
    --配件科技的触发技能等级上限
    unlockAccSkillLvl=0,
    --紫色装备可升级上限
    unlockEmblemLevel1=3,
    --橙色装备可升级上限
    unlockEmblemLevel2=2,
    --紫色7号战斗位升级上限
        unlockPlaneLevel1=2,
    --橙色7号战斗位升级上限
        unlockPlaneLevel2=1,
    --前端用的配置格式
    clientVersionCfg = {60,{10006,10016,10026,10036,10007,10017,10027,10037},60,11,30,60,4,60,6,15,4,9,3,{10006,10016,10026,10036,10007,10017,10027,10037},{8,4},60,0,8,15,9,0,0,3,2,2,1},
},
--70级 第一周，不开坦克
version3={
    --建筑等级上限 70
    buildingMaxLevel=70,
    --改造厂中未开放的部队id
    unlockForceIdStr={10006,10016,10026,10036,10007,10017,10027,10037},
    --用户等级以及技能等级上限 70
    roleMaxLevel=70,
    --个人关卡章节数解锁至 15 章
    unlockCheckpoint=15,
    --军团科技等级上限 30
    allianceMaxLevel=30,
    --个人等级等级上限 70
    techMaxLevel=70,
    --军团副本章节数解锁至 5 章
    aChallengeLevel=5,
    --任务等级上限 70
    unlockTaskLevel=70,
    --配件开启部位 6 个
    unlockAccParts=6,
    --配件补给线关卡解锁至 15 关
    unlockEliteChallenge=15,
    --将领突破品质上限为 4 品阶
    unlockHeroThrouh=4,
    --Vip开放等级上限为 10
    unlockVipLevel=10,
    --富矿成长品质上限为 3
    mapHeatlevel=3,
    --建造场中未开放的部队id
    unlockBuildForceIdStr={10006,10016,10026,10036,10007,10017,10027,10037},
    --坦克军团商店解锁 普通坦克&活动坦克Id
    unlockTankShopIdStr={12,8},
    --异星科技解锁等级
    unlockAlienTech=60,
    --精英章节数解锁至 3 章
    unlockElitepoint=3,
    --超级武器开放部位
    unlockSwParts=8,
    --超级武器开启等级
    unlockSwLevel=15,
    --将领装备强化等级上限
    unEquipLevel=9,
    --配件科技的科技强化等级上限
    unlockAccTechLvl=0,
    --配件科技的触发技能等级上限
    unlockAccSkillLvl=0,
    --紫色装备可升级上限
    unlockEmblemLevel1=3,
    --橙色装备可升级上限
    unlockEmblemLevel2=2,
    --紫色7号战斗位升级上限
        unlockPlaneLevel1=2,
    --橙色7号战斗位升级上限
        unlockPlaneLevel2=1,
    --前端用的配置格式
    clientVersionCfg = {70,{10006,10016,10026,10036,10007,10017,10027,10037},70,15,30,70,5,70,6,15,4,10,3,{10006,10016,10026,10036,10007,10017,10027,10037},{12,8},60,3,8,15,9,0,0,3,2,2,1},
},
--70级 开启7、8位配件，解锁补给线16-19关
version4={
    --建筑等级上限 70
    buildingMaxLevel=70,
    --改造厂中未开放的部队id
    unlockForceIdStr={10006,10016,10026,10036,10007,10017,10027,10037},
    --用户等级以及技能等级上限 70
    roleMaxLevel=70,
    --个人关卡章节数解锁至 15 章
    unlockCheckpoint=15,
    --军团科技等级上限 30
    allianceMaxLevel=30,
    --个人等级等级上限 70
    techMaxLevel=70,
    --军团副本章节数解锁至 5 章
    aChallengeLevel=5,
    --任务等级上限 70
    unlockTaskLevel=70,
    --配件开启部位 8 个
    unlockAccParts=8,
    --配件补给线关卡解锁至 19 关
    unlockEliteChallenge=19,
    --将领突破品质上限为 4 品阶
    unlockHeroThrouh=4,
    --Vip开放等级上限为 10
    unlockVipLevel=10,
    --富矿成长品质上限为 3
    mapHeatlevel=3,
    --建造场中未开放的部队id
    unlockBuildForceIdStr={10006,10016,10026,10036,10007,10017,10027,10037},
    --坦克军团商店解锁 普通坦克&活动坦克Id
    unlockTankShopIdStr={12,8},
    --异星科技解锁等级
    unlockAlienTech=60,
    --精英章节数解锁至 3 章
    unlockElitepoint=3,
    --超级武器开放部位
    unlockSwParts=8,
    --超级武器开启等级
    unlockSwLevel=15,
    --将领装备强化等级上限
    unEquipLevel=9,
    --配件科技的科技强化等级上限
    unlockAccTechLvl=0,
    --配件科技的触发技能等级上限
    unlockAccSkillLvl=0,
    --紫色装备可升级上限
    unlockEmblemLevel1=3,
    --橙色装备可升级上限
    unlockEmblemLevel2=2,
    --紫色7号战斗位升级上限
        unlockPlaneLevel1=2,
    --橙色7号战斗位升级上限
        unlockPlaneLevel2=1,
    --前端用的配置格式
    clientVersionCfg = {70,{10006,10016,10026,10036,10007,10017,10027,10037},70,15,30,70,5,70,8,19,4,10,3,{10006,10016,10026,10036,10007,10017,10027,10037},{12,8},60,3,8,15,9,0,0,3,2,2,1},
},
--等级上限80级
version5={
    --建筑等级上限 80
    buildingMaxLevel=80,
    --改造厂中未开放的部队id
    unlockForceIdStr={10006,10016,10026,10036,10007,10017,10027,10037},
    --用户等级以及技能等级上限 80
    roleMaxLevel=80,
    --个人关卡章节数解锁至 17 章
    unlockCheckpoint=17,
    --军团科技等级上限 30
    allianceMaxLevel=30,
    --个人等级等级上限 80
    techMaxLevel=80,
    --军团副本章节数解锁至 5 章
    aChallengeLevel=5,
    --任务等级上限 80
    unlockTaskLevel=80,
    --配件开启部位 8 个
    unlockAccParts=8,
    --配件补给线关卡解锁至 19 关
    unlockEliteChallenge=19,
    --将领突破品质上限为 4 品阶
    unlockHeroThrouh=4,
    --Vip开放等级上限为 10
    unlockVipLevel=10,
    --富矿成长品质上限为 3
    mapHeatlevel=3,
    --建造场中未开放的部队id
    unlockBuildForceIdStr={10006,10016,10026,10036,10007,10017,10027,10037},
    --坦克军团商店解锁 普通坦克&活动坦克Id
    unlockTankShopIdStr={12,8},
    --异星科技解锁等级
    unlockAlienTech=60,
    --精英章节数解锁至 11 章
    unlockElitepoint=11,
    --超级武器开放部位
    unlockSwParts=8,
    --超级武器开启等级
    unlockSwLevel=15,
    --将领装备强化等级上限
    unEquipLevel=9,
    --配件科技的科技强化等级上限
    unlockAccTechLvl=0,
    --配件科技的触发技能等级上限
    unlockAccSkillLvl=0,
    --紫色装备可升级上限
    unlockEmblemLevel1=3,
    --橙色装备可升级上限
    unlockEmblemLevel2=2,
    --紫色7号战斗位升级上限
        unlockPlaneLevel1=2,
    --橙色7号战斗位升级上限
        unlockPlaneLevel2=1,
    --前端用的配置格式
    clientVersionCfg = {80,{10006,10016,10026,10036,10007,10017,10027,10037},80,17,30,80,5,80,8,19,4,10,3,{10006,10016,10026,10036,10007,10017,10027,10037},{12,8},60,11,8,15,9,0,0,3,2,2,1},
},
--80级 改船场升至6级船
version6={
    --建筑等级上限 80
    buildingMaxLevel=80,
    --改造厂中未开放的部队id
    unlockForceIdStr={10007,10017,10027,10037},
    --用户等级以及技能等级上限 80
    roleMaxLevel=80,
    --个人关卡章节数解锁至 17 章
    unlockCheckpoint=17,
    --军团科技等级上限 30
    allianceMaxLevel=30,
    --个人等级等级上限 80
    techMaxLevel=80,
    --军团副本章节数解锁至 5 章
    aChallengeLevel=5,
    --任务等级上限 80
    unlockTaskLevel=80,
    --配件开启部位 8 个
    unlockAccParts=8,
    --配件补给线关卡解锁至 19 关
    unlockEliteChallenge=19,
    --将领突破品质上限为 4 品阶
    unlockHeroThrouh=4,
    --Vip开放等级上限为 10
    unlockVipLevel=10,
    --富矿成长品质上限为 3
    mapHeatlevel=3,
    --建造场中未开放的部队id
    unlockBuildForceIdStr={10006,10016,10026,10036,10007,10017,10027,10037},
    --坦克军团商店解锁 普通坦克&活动坦克Id
    unlockTankShopIdStr={12,8},
    --异星科技解锁等级
    unlockAlienTech=70,
    --精英章节数解锁至 11 章
    unlockElitepoint=11,
    --超级武器开放部位
    unlockSwParts=8,
    --超级武器开启等级
    unlockSwLevel=15,
    --将领装备强化等级上限
    unEquipLevel=9,
    --配件科技的科技强化等级上限
    unlockAccTechLvl=0,
    --配件科技的触发技能等级上限
    unlockAccSkillLvl=0,
    --紫色装备可升级上限
    unlockEmblemLevel1=3,
    --橙色装备可升级上限
    unlockEmblemLevel2=2,
    --紫色7号战斗位升级上限
        unlockPlaneLevel1=2,
    --橙色7号战斗位升级上限
        unlockPlaneLevel2=1,
    --前端用的配置格式
    clientVersionCfg = {80,{10007,10017,10027,10037},80,17,30,80,5,80,8,19,4,10,3,{10006,10016,10026,10036,10007,10017,10027,10037},{12,8},70,11,8,15,9,0,0,3,2,2,1},
},
--80级 造船厂升到6级船
version7={
    --建筑等级上限 80
    buildingMaxLevel=80,
    --改造厂中未开放的部队id
    unlockForceIdStr={10007,10017,10027,10037},
    --用户等级以及技能等级上限 80
    roleMaxLevel=80,
    --个人关卡章节数解锁至 17 章
    unlockCheckpoint=17,
    --军团科技等级上限 30
    allianceMaxLevel=30,
    --个人等级等级上限 80
    techMaxLevel=80,
    --军团副本章节数解锁至 5 章
    aChallengeLevel=5,
    --任务等级上限 80
    unlockTaskLevel=80,
    --配件开启部位 8 个
    unlockAccParts=8,
    --配件补给线关卡解锁至 19 关
    unlockEliteChallenge=19,
    --将领突破品质上限为 5 品阶
    unlockHeroThrouh=5,
    --Vip开放等级上限为 10
    unlockVipLevel=10,
    --富矿成长品质上限为 3
    mapHeatlevel=3,
    --建造场中未开放的部队id
    unlockBuildForceIdStr={10006,10016,10026,10036,10007,10017,10027,10037},
    --坦克军团商店解锁 普通坦克&活动坦克Id
    unlockTankShopIdStr={12,8},
    --异星科技解锁等级
    unlockAlienTech=70,
    --精英章节数解锁至 11 章
    unlockElitepoint=11,
    --超级武器开放部位
    unlockSwParts=8,
    --超级武器开启等级
    unlockSwLevel=15,
    --将领装备强化等级上限
    unEquipLevel=9,
    --配件科技的科技强化等级上限
    unlockAccTechLvl=0,
    --配件科技的触发技能等级上限
    unlockAccSkillLvl=0,
    --紫色装备可升级上限
    unlockEmblemLevel1=3,
    --橙色装备可升级上限
    unlockEmblemLevel2=2,
    --紫色7号战斗位升级上限
        unlockPlaneLevel1=2,
    --橙色7号战斗位升级上限
        unlockPlaneLevel2=1,
    --前端用的配置格式
    clientVersionCfg = {80,{10007,10017,10027,10037},80,17,30,80,5,80,8,19,5,10,3,{10006,10016,10026,10036,10007,10017,10027,10037},{12,8},70,11,8,15,9,0,0,3,2,2,1},
},
--紫3橙3
version8={
    --建筑等级上限 80
    buildingMaxLevel=80,
    --改造厂中未开放的部队id
    unlockForceIdStr={10007,10017,10027,10037},
    --用户等级以及技能等级上限 80
    roleMaxLevel=80,
    --个人关卡章节数解锁至 17 章
    unlockCheckpoint=17,
    --军团科技等级上限 30
    allianceMaxLevel=30,
    --个人等级等级上限 80
    techMaxLevel=80,
    --军团副本章节数解锁至 5 章
    aChallengeLevel=5,
    --任务等级上限 80
    unlockTaskLevel=80,
    --配件开启部位 8 个
    unlockAccParts=8,
    --配件补给线关卡解锁至 19 关
    unlockEliteChallenge=19,
    --将领突破品质上限为 5 品阶
    unlockHeroThrouh=5,
    --Vip开放等级上限为 10
    unlockVipLevel=10,
    --富矿成长品质上限为 3
    mapHeatlevel=3,
    --建造场中未开放的部队id
    unlockBuildForceIdStr={10006,10016,10026,10036,10007,10017,10027,10037},
    --坦克军团商店解锁 普通坦克&活动坦克Id
    unlockTankShopIdStr={12,8},
    --异星科技解锁等级
    unlockAlienTech=70,
    --精英章节数解锁至 11 章
    unlockElitepoint=11,
    --超级武器开放部位
    unlockSwParts=8,
    --超级武器开启等级
    unlockSwLevel=15,
    --将领装备强化等级上限
    unEquipLevel=9,
    --配件科技的科技强化等级上限
    unlockAccTechLvl=0,
    --配件科技的触发技能等级上限
    unlockAccSkillLvl=0,
    --紫色装备可升级上限
    unlockEmblemLevel1=3,
    --橙色装备可升级上限
    unlockEmblemLevel2=3,
    --紫色7号战斗位升级上限
        unlockPlaneLevel1=2,
    --橙色7号战斗位升级上限
        unlockPlaneLevel2=1,
    --前端用的配置格式
    clientVersionCfg = {80,{10007,10017,10027,10037},80,17,30,80,5,80,8,19,5,10,3,{10006,10016,10026,10036,10007,10017,10027,10037},{12,8},70,11,8,15,9,0,0,3,3,2,1},
},
--紫3橙3
version9={
    --建筑等级上限 90
    buildingMaxLevel=90,
    --改造厂中未开放的部队id
    unlockForceIdStr={10007,10017,10027,10037},
    --用户等级以及技能等级上限 90
    roleMaxLevel=90,
    --个人关卡章节数解锁至 21 章
    unlockCheckpoint=21,
    --军团科技等级上限 30
    allianceMaxLevel=30,
    --个人等级等级上限 90
    techMaxLevel=90,
    --军团副本章节数解锁至 5 章
    aChallengeLevel=5,
    --任务等级上限 90
    unlockTaskLevel=90,
    --配件开启部位 8 个
    unlockAccParts=8,
    --配件补给线关卡解锁至 19 关
    unlockEliteChallenge=19,
    --将领突破品质上限为 5 品阶
    unlockHeroThrouh=5,
    --Vip开放等级上限为 10
    unlockVipLevel=10,
    --富矿成长品质上限为 3
    mapHeatlevel=3,
    --建造场中未开放的部队id
    unlockBuildForceIdStr={10006,10016,10026,10036,10007,10017,10027,10037},
    --坦克军团商店解锁 普通坦克&活动坦克Id
    unlockTankShopIdStr={12,8},
    --异星科技解锁等级
    unlockAlienTech=70,
    --精英章节数解锁至 11 章
    unlockElitepoint=11,
    --超级武器开放部位
    unlockSwParts=8,
    --超级武器开启等级
    unlockSwLevel=15,
    --将领装备强化等级上限
    unEquipLevel=9,
    --配件科技的科技强化等级上限
    unlockAccTechLvl=0,
    --配件科技的触发技能等级上限
    unlockAccSkillLvl=0,
    --紫色装备可升级上限
    unlockEmblemLevel1=3,
    --橙色装备可升级上限
    unlockEmblemLevel2=3,
    --紫色7号战斗位升级上限
        unlockPlaneLevel1=10,
    --橙色7号战斗位升级上限
        unlockPlaneLevel2=5,
    --前端用的配置格式
    clientVersionCfg = {90,{10007,10017,10027,10037},90,21,30,90,5,90,8,19,5,10,3,{10006,10016,10026,10036,10007,10017,10027,10037},{12,8},70,11,8,15,9,0,0,3,3,10,5},
},
--开放异星等级
version10={
    --建筑等级上限 90
    buildingMaxLevel=90,
    --改造厂中未开放的部队id
    unlockForceIdStr={},
    --用户等级以及技能等级上限 90
    roleMaxLevel=90,
    --个人关卡章节数解锁至 21 章
    unlockCheckpoint=21,
    --军团科技等级上限 30
    allianceMaxLevel=30,
    --个人等级等级上限 90
    techMaxLevel=90,
    --军团副本章节数解锁至 5 章
    aChallengeLevel=5,
    --任务等级上限 90
    unlockTaskLevel=90,
    --配件开启部位 8 个
    unlockAccParts=8,
    --配件补给线关卡解锁至 19 关
    unlockEliteChallenge=19,
    --将领突破品质上限为 5 品阶
    unlockHeroThrouh=5,
    --Vip开放等级上限为 10
    unlockVipLevel=10,
    --富矿成长品质上限为 3
    mapHeatlevel=3,
    --建造场中未开放的部队id
    unlockBuildForceIdStr={10007,10017,10027,10037},
    --坦克军团商店解锁 普通坦克&活动坦克Id
    unlockTankShopIdStr={12,8},
    --异星科技解锁等级
    unlockAlienTech=80,
    --精英章节数解锁至 11 章
    unlockElitepoint=11,
    --超级武器开放部位
    unlockSwParts=8,
    --超级武器开启等级
    unlockSwLevel=15,
    --将领装备强化等级上限
    unEquipLevel=9,
    --配件科技的科技强化等级上限
    unlockAccTechLvl=5,
    --配件科技的触发技能等级上限
    unlockAccSkillLvl=5,
    --紫色装备可升级上限
    unlockEmblemLevel1=3,
    --橙色装备可升级上限
    unlockEmblemLevel2=3,
    --紫色7号战斗位升级上限
        unlockPlaneLevel1=10,
    --橙色7号战斗位升级上限
        unlockPlaneLevel2=5,
    --前端用的配置格式
    clientVersionCfg = {90,{},90,21,30,90,5,90,8,19,5,10,3,{10007,10017,10027,10037},{12,8},80,11,8,15,9,5,5,3,3,10,5},
},
--开放异星等级
version11={
    --建筑等级上限 90
    buildingMaxLevel=90,
    --改造厂中未开放的部队id
    unlockForceIdStr={},
    --用户等级以及技能等级上限 90
    roleMaxLevel=90,
    --个人关卡章节数解锁至 21 章
    unlockCheckpoint=21,
    --军团科技等级上限 30
    allianceMaxLevel=30,
    --个人等级等级上限 90
    techMaxLevel=90,
    --军团副本章节数解锁至 5 章
    aChallengeLevel=5,
    --任务等级上限 90
    unlockTaskLevel=90,
    --配件开启部位 8 个
    unlockAccParts=8,
    --配件补给线关卡解锁至 19 关
    unlockEliteChallenge=19,
    --将领突破品质上限为 5 品阶
    unlockHeroThrouh=5,
    --Vip开放等级上限为 12
    unlockVipLevel=12,
    --富矿成长品质上限为 3
    mapHeatlevel=3,
    --建造场中未开放的部队id
    unlockBuildForceIdStr={10007,10017,10027,10037},
    --坦克军团商店解锁 普通坦克&活动坦克Id
    unlockTankShopIdStr={12,8},
    --异星科技解锁等级
    unlockAlienTech=80,
    --精英章节数解锁至 11 章
    unlockElitepoint=11,
    --超级武器开放部位
    unlockSwParts=8,
    --超级武器开启等级
    unlockSwLevel=15,
    --将领装备强化等级上限
    unEquipLevel=9,
    --配件科技的科技强化等级上限
    unlockAccTechLvl=5,
    --配件科技的触发技能等级上限
    unlockAccSkillLvl=5,
    --紫色装备可升级上限
    unlockEmblemLevel1=3,
    --橙色装备可升级上限
    unlockEmblemLevel2=3,
    --紫色7号战斗位升级上限
        unlockPlaneLevel1=10,
    --橙色7号战斗位升级上限
        unlockPlaneLevel2=5,
    --前端用的配置格式
    clientVersionCfg = {90,{},90,21,30,90,5,90,8,19,5,12,3,{10007,10017,10027,10037},{12,8},80,11,8,15,9,5,5,3,3,10,5},
},
--开放100级
version12={
    --建筑等级上限 100
    buildingMaxLevel=100,
    --改造厂中未开放的部队id
    unlockForceIdStr={},
    --用户等级以及技能等级上限 100
    roleMaxLevel=100,
    --个人关卡章节数解锁至 26 章
    unlockCheckpoint=26,
    --军团科技等级上限 30
    allianceMaxLevel=30,
    --个人等级等级上限 100
    techMaxLevel=100,
    --军团副本章节数解锁至 5 章
    aChallengeLevel=5,
    --任务等级上限 100
    unlockTaskLevel=100,
    --配件开启部位 8 个
    unlockAccParts=8,
    --配件补给线关卡解锁至 19 关
    unlockEliteChallenge=19,
    --将领突破品质上限为 5 品阶
    unlockHeroThrouh=5,
    --Vip开放等级上限为 12
    unlockVipLevel=12,
    --富矿成长品质上限为 3
    mapHeatlevel=3,
    --建造场中未开放的部队id
    unlockBuildForceIdStr={10007,10017,10027,10037},
    --坦克军团商店解锁 普通坦克&活动坦克Id
    unlockTankShopIdStr={12,8},
    --异星科技解锁等级
    unlockAlienTech=80,
    --精英章节数解锁至 11 章
    unlockElitepoint=11,
    --超级武器开放部位
    unlockSwParts=8,
    --超级武器开启等级
    unlockSwLevel=15,
    --将领装备强化等级上限
    unEquipLevel=9,
    --配件科技的科技强化等级上限
    unlockAccTechLvl=5,
    --配件科技的触发技能等级上限
    unlockAccSkillLvl=5,
    --紫色装备可升级上限
    unlockEmblemLevel1=3,
    --橙色装备可升级上限
    unlockEmblemLevel2=3,
    --紫色7号战斗位升级上限
        unlockPlaneLevel1=10,
    --橙色7号战斗位升级上限
        unlockPlaneLevel2=5,
    --前端用的配置格式
    clientVersionCfg = {100,{},100,26,30,100,5,100,8,19,5,12,3,{10007,10017,10027,10037},{12,8},80,11,8,15,9,5,5,3,3,10,5},
},
--开放飞机技能等级
version13={
    --建筑等级上限 100
    buildingMaxLevel=100,
    --改造厂中未开放的部队id
    unlockForceIdStr={},
    --用户等级以及技能等级上限 100
    roleMaxLevel=100,
    --个人关卡章节数解锁至 26 章
    unlockCheckpoint=26,
    --军团科技等级上限 30
    allianceMaxLevel=30,
    --个人等级等级上限 100
    techMaxLevel=100,
    --军团副本章节数解锁至 5 章
    aChallengeLevel=5,
    --任务等级上限 100
    unlockTaskLevel=100,
    --配件开启部位 8 个
    unlockAccParts=8,
    --配件补给线关卡解锁至 19 关
    unlockEliteChallenge=19,
    --将领突破品质上限为 5 品阶
    unlockHeroThrouh=5,
    --Vip开放等级上限为 12
    unlockVipLevel=12,
    --富矿成长品质上限为 3
    mapHeatlevel=3,
    --建造场中未开放的部队id
    unlockBuildForceIdStr={10007,10017,10027,10037},
    --坦克军团商店解锁 普通坦克&活动坦克Id
    unlockTankShopIdStr={12,8},
    --异星科技解锁等级
    unlockAlienTech=80,
    --精英章节数解锁至 11 章
    unlockElitepoint=11,
    --超级武器开放部位
    unlockSwParts=8,
    --超级武器开启等级
    unlockSwLevel=15,
    --将领装备强化等级上限
    unEquipLevel=9,
    --配件科技的科技强化等级上限
    unlockAccTechLvl=5,
    --配件科技的触发技能等级上限
    unlockAccSkillLvl=5,
    --紫色装备可升级上限
    unlockEmblemLevel1=3,
    --橙色装备可升级上限
    unlockEmblemLevel2=3,
    --紫色7号战斗位升级上限
        unlockPlaneLevel1=15,
    --橙色7号战斗位升级上限
        unlockPlaneLevel2=10,
    --前端用的配置格式
    clientVersionCfg = {100,{},100,26,30,100,5,100,8,19,5,12,3,{10007,10017,10027,10037},{12,8},80,11,8,15,9,5,5,3,3,15,10},
},
--开放110级
version14={
    --建筑等级上限 110
    buildingMaxLevel=110,
    --改造厂中未开放的部队id
    unlockForceIdStr={},
    --用户等级以及技能等级上限 110
    roleMaxLevel=110,
    --个人关卡章节数解锁至 27 章
    unlockCheckpoint=27,
    --军团科技等级上限 30
    allianceMaxLevel=30,
    --个人等级等级上限 110
    techMaxLevel=110,
    --军团副本章节数解锁至 5 章
    aChallengeLevel=5,
    --任务等级上限 110
    unlockTaskLevel=110,
    --配件开启部位 8 个
    unlockAccParts=8,
    --配件补给线关卡解锁至 19 关
    unlockEliteChallenge=19,
    --将领突破品质上限为 5 品阶
    unlockHeroThrouh=5,
    --Vip开放等级上限为 12
    unlockVipLevel=12,
    --富矿成长品质上限为 3
    mapHeatlevel=3,
    --建造场中未开放的部队id
    unlockBuildForceIdStr={10007,10017,10027,10037},
    --坦克军团商店解锁 普通坦克&活动坦克Id
    unlockTankShopIdStr={12,8},
    --异星科技解锁等级
    unlockAlienTech=80,
    --精英章节数解锁至 11 章
    unlockElitepoint=11,
    --超级武器开放部位
    unlockSwParts=8,
    --超级武器开启等级
    unlockSwLevel=15,
    --将领装备强化等级上限
    unEquipLevel=9,
    --配件科技的科技强化等级上限
    unlockAccTechLvl=5,
    --配件科技的触发技能等级上限
    unlockAccSkillLvl=5,
    --紫色装备可升级上限
    unlockEmblemLevel1=3,
    --橙色装备可升级上限
    unlockEmblemLevel2=3,
    --紫色7号战斗位升级上限
        unlockPlaneLevel1=15,
    --橙色7号战斗位升级上限
        unlockPlaneLevel2=10,
    --前端用的配置格式
    clientVersionCfg = {110,{},110,27,30,110,5,110,8,19,5,12,3,{10007,10017,10027,10037},{12,8},80,11,8,15,9,5,5,3,3,15,10},
},



}
local platCfg={ 
}
if clientPlat ~= 'def' then 
if platCfg and type(platCfg[clientPlat]) == 'table' then
for k,v in pairs(platCfg[clientPlat]) do
commonCfg[k] = v
end
end
end

return commonCfg 
end

return returnCfg