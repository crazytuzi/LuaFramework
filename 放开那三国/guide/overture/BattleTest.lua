-- Filename: BattleTest.lua
-- Author: k
-- Date: 2013-08-08
-- Purpose: 生成测试战斗数据

function getTestBattleInfo()
    
    local fightInfo = {}
    fightInfo.appraisal = "F"
    -- team1
    local team1 = {}
    team1.level = 36
    team1.uid = 21805
    team1.isPlayer = true
    team1.totalHpCost = 1000
    team1.name = GetLocalizeStringBy("key_2260")
    
    local team1arrHero = {}
    for i=1,6 do
        local heroInfo = {}
        heroInfo.position = i-1
        heroInfo.level = 11
        heroInfo.maxHp = 400
        heroInfo.rageSkill = 1030
        heroInfo.currRage = 0
        heroInfo.htid = 20002
        heroInfo.hid = 2009240+i
        
        team1arrHero[i] = heroInfo
    end
    team1arrHero[6].hid = 1009225
    team1.arrHero = team1arrHero
    fightInfo.team1 = team1
    
    --team2
    local team2 = {}
    team2.level = 36
    team2.uid = 21806
    team2.isPlayer = false
    team2.totalHpCost = 1000
    team2.name = GetLocalizeStringBy("key_2261")
    
    local team2arrHero = {}
    for i=1,6 do
        local heroInfo = {}
        heroInfo.position = i-1
        heroInfo.level = 11
        heroInfo.maxHp = 400
        heroInfo.rageSkill = 1030
        heroInfo.currRage = 0
        heroInfo.htid = 20002
        heroInfo.hid = 2007240+i
        
        team2arrHero[i] = heroInfo
    end
    team2arrHero[6].hid = 1009235
    team2.arrHero = team2arrHero
    fightInfo.team2 = team2
    
    --battle
    local battle = {}
    
    --battle1
    local battle1 = {}
    battle1.defender = 2007241
    battle1.arrReaction = {}
    battle1.arrReaction[1] = {}
    battle1.arrReaction[1].defender = 2007241
    battle1.arrReaction[1].reaction = 1
    battle1.arrReaction[1].arrDamage = {}
    battle1.arrReaction[1].arrDamage[1] = {}
    battle1.arrReaction[1].arrDamage[1].damageType = 1
    battle1.arrReaction[1].arrDamage[1].damageValue = 43
    battle1.arrReaction[1].enBuffer = {}
    battle1.arrReaction[1].enBuffer[1] = 4029
    
    battle1.arrChild = {}
    battle1.arrChild[1] = {}
    battle1.arrChild[1].defender = 2007242
    battle1.arrChild[1].round = 1
    battle1.arrChild[1].action = 645
    battle1.arrChild[1].attacker = 2009241
    battle1.arrChild[1].rage = 50
    battle1.arrChild[1].arrReaction = {}
    battle1.arrChild[1].arrReaction[1] = {}
    battle1.arrChild[1].arrReaction[1].defender = 2007242
    battle1.arrChild[1].arrReaction[1].reaction = 1
    battle1.arrChild[1].arrReaction[1].arrDamage = {}
    battle1.arrChild[1].arrReaction[1].arrDamage[1] = {}
    battle1.arrChild[1].arrReaction[1].arrDamage[1].damageType = 1
    battle1.arrChild[1].arrReaction[1].arrDamage[1].damageValue = 43
    battle1.arrChild[1].arrReaction[1].enBuffer = {}
    battle1.arrChild[1].arrReaction[1].enBuffer[1] = 119
    battle1.round = 1
    battle1.action = 645
    battle1.attacker = 2009241
    battle1.rage = 50
    
    battle[#battle+1] = battle1
    
    --battle2
    local battle2 = {}
    battle2.defender = 0
    battle2.buffer = {}
    battle2.buffer[1] = {}
    battle2.buffer[1].bufferId = 4029
    battle2.buffer[1].data = -5
    battle2.buffer[1].type = 9
    --battle2.arrReaction[1].deBuffer = {}
    --battle2.arrReaction[1].deBuffer[1] = 5029
    battle2.round = 1
    battle2.action = 0
    battle2.attacker = 2007241
    battle2.rage = 50
    
    battle[#battle+1] = battle2
    
    --battle3
    local battle3 = {}
    battle3.defender = 2009243
    battle3.arrReaction = {}
    battle3.arrReaction[1] = {}
    battle3.arrReaction[1].defender = 2009243
    battle3.arrReaction[1].reaction = 1
    battle3.arrReaction[1].arrDamage = {}
    battle3.arrReaction[1].arrDamage[1] = {}
    battle3.arrReaction[1].arrDamage[1].damageType = 1
    battle3.arrReaction[1].arrDamage[1].damageValue = 43
    battle3.arrReaction[2] = {}
    battle3.arrReaction[2].defender = 1009235
    battle3.arrReaction[2].reaction = 1
    battle3.arrReaction[2].arrDamage = {}
    battle3.arrReaction[2].arrDamage[1] = {}
    battle3.arrReaction[2].arrDamage[1].damageType = 1
    battle3.arrReaction[2].arrDamage[1].damageValue = 43
    battle3.round = 1
    battle3.action = 1030
    battle3.attacker = 2007243
    battle3.rage = 50
    
    battle[#battle+1] = battle3
    
    --[[
    --battle2
    local battle2 = {}
    battle2.defender = 2009241
    battle2.arrReaction = {}
    battle2.arrReaction[1] = {}
    battle2.arrReaction[1].defender = 2009241
    battle2.arrReaction[1].reaction = 1
    battle2.arrReaction[1].arrDamage = {}
    battle2.arrReaction[1].arrDamage[1] = {}
    battle2.arrReaction[1].arrDamage[1].damageType = 1
    battle2.arrReaction[1].arrDamage[1].damageValue = 43
    --battle2.arrReaction[1].deBuffer = {}
    --battle2.arrReaction[1].deBuffer[1] = 5029
    battle2.round = 1
    battle2.action = 800
    battle2.attacker = 2007242
    battle2.rage = 50
    
    battle[#battle+1] = battle2
    
    --battle3
    local battle3 = {}
    battle3.defender = 2009243
    battle3.arrReaction = {}
    battle3.arrReaction[1] = {}
    battle3.arrReaction[1].defender = 2009243
    battle3.arrReaction[1].reaction = 1
    battle3.arrReaction[1].arrDamage = {}
    battle3.arrReaction[1].arrDamage[1] = {}
    battle3.arrReaction[1].arrDamage[1].damageType = 1
    battle3.arrReaction[1].arrDamage[1].damageValue = 43
    battle3.arrReaction[2] = {}
    battle3.arrReaction[2].defender = 1009235
    battle3.arrReaction[2].reaction = 1
    battle3.arrReaction[2].arrDamage = {}
    battle3.arrReaction[2].arrDamage[1] = {}
    battle3.arrReaction[2].arrDamage[1].damageType = 1
    battle3.arrReaction[2].arrDamage[1].damageValue = 43
    battle3.round = 1
    battle3.action = 1030
    battle3.attacker = 2007243
    battle3.rage = 50
    
    battle[#battle+1] = battle3
    
    --battle4
    local battle4 = {}
    battle4.defender = 2007241
    battle4.arrReaction = {}
    battle4.arrReaction[1] = {}
    battle4.arrReaction[1].defender = 2007241
    battle4.arrReaction[1].reaction = 1
    battle4.arrReaction[1].arrDamage = {}
    battle4.arrReaction[1].arrDamage[1] = {}
    battle4.arrReaction[1].arrDamage[1].damageType = 1
    battle4.arrReaction[1].arrDamage[1].damageValue = 43
    battle4.arrReaction[2] = {}
    battle4.arrReaction[2].defender = 2007244
    battle4.arrReaction[2].reaction = 1
    battle4.arrReaction[2].arrDamage = {}
    battle4.arrReaction[2].arrDamage[1] = {}
    battle4.arrReaction[2].arrDamage[1].damageType = 1
    battle4.arrReaction[2].arrDamage[1].damageValue = 43
    battle4.round = 1
    battle4.action = 1070
    battle4.attacker = 2009244
    battle4.rage = 50
    
    battle[#battle+1] = battle4
    
    --battle5
    local battle5 = {}
    battle5.defender = 2007241
    battle5.arrReaction = {}
    battle5.arrReaction[1] = {}
    battle5.arrReaction[1].defender = 2007241
    battle5.arrReaction[1].reaction = 1
    battle5.arrReaction[1].arrDamage = {}
    battle5.arrReaction[1].arrDamage[1] = {}
    battle5.arrReaction[1].arrDamage[1].damageType = 1
    battle5.arrReaction[1].arrDamage[1].damageValue = 43
    battle5.round = 1
    battle5.action = 1130
    battle5.attacker = 2009245
    battle5.rage = 50
    
    battle[#battle+1] = battle5
    
    --battle6
    local battle6 = {}
    battle6.defender = 2007241
    battle6.arrReaction = {}
    battle6.arrReaction[1] = {}
    battle6.arrReaction[1].defender = 2007241
    battle6.arrReaction[1].reaction = 1
    battle6.arrReaction[1].arrDamage = {}
    battle6.arrReaction[1].arrDamage[1] = {}
    battle6.arrReaction[1].arrDamage[1].damageType = 1
    battle6.arrReaction[1].arrDamage[1].damageValue = 43
    battle6.arrReaction[2] = {}
    battle6.arrReaction[2].defender = 2007242
    battle6.arrReaction[2].reaction = 1
    battle6.arrReaction[2].arrDamage = {}
    battle6.arrReaction[2].arrDamage[1] = {}
    battle6.arrReaction[2].arrDamage[1].damageType = 1
    battle6.arrReaction[2].arrDamage[1].damageValue = 43
    battle6.arrReaction[3] = {}
    battle6.arrReaction[3].defender = 2007243
    battle6.arrReaction[3].reaction = 1
    battle6.arrReaction[3].arrDamage = {}
    battle6.arrReaction[3].arrDamage[1] = {}
    battle6.arrReaction[3].arrDamage[1].damageType = 1
    battle6.arrReaction[3].arrDamage[1].damageValue = 43
    battle6.arrReaction[4] = {}
    battle6.arrReaction[4].defender = 2007244
    battle6.arrReaction[4].reaction = 1
    battle6.arrReaction[4].arrDamage = {}
    battle6.arrReaction[4].arrDamage[1] = {}
    battle6.arrReaction[4].arrDamage[1].damageType = 1
    battle6.arrReaction[4].arrDamage[1].damageValue = 43
    battle6.arrReaction[5] = {}
    battle6.arrReaction[5].defender = 2007245
    battle6.arrReaction[5].reaction = 1
    battle6.arrReaction[5].arrDamage = {}
    battle6.arrReaction[5].arrDamage[1] = {}
    battle6.arrReaction[5].arrDamage[1].damageType = 1
    battle6.arrReaction[5].arrDamage[1].damageValue = 43
    battle6.arrReaction[6] = {}
    battle6.arrReaction[6].defender = 1009235
    battle6.arrReaction[6].reaction = 1
    battle6.arrReaction[6].arrDamage = {}
    battle6.arrReaction[6].arrDamage[1] = {}
    battle6.arrReaction[6].arrDamage[1].damageType = 1
    battle6.arrReaction[6].arrDamage[1].damageValue = 43
    battle6.round = 1
    battle6.action = 1090
    battle6.attacker = 1009225
    battle6.rage = 50
    
    battle[#battle+1] = battle6
    
    --battle7
    local battle7 = {}
    battle7.defender = 2007241
    battle7.arrReaction = {}
    battle7.arrReaction[1] = {}
    battle7.arrReaction[1].defender = 2007241
    battle7.arrReaction[1].reaction = 1
    battle7.arrReaction[1].arrDamage = {}
    battle7.arrReaction[1].arrDamage[1] = {}
    battle7.arrReaction[1].arrDamage[1].damageType = 1
    battle7.arrReaction[1].arrDamage[1].damageValue = 43
    battle7.arrReaction[2] = {}
    battle7.arrReaction[2].defender = 2007242
    battle7.arrReaction[2].reaction = 1
    battle7.arrReaction[2].arrDamage = {}
    battle7.arrReaction[2].arrDamage[1] = {}
    battle7.arrReaction[2].arrDamage[1].damageType = 1
    battle7.arrReaction[2].arrDamage[1].damageValue = 43
    battle7.arrReaction[3] = {}
    battle7.arrReaction[3].defender = 2007243
    battle7.arrReaction[3].reaction = 1
    battle7.arrReaction[3].arrDamage = {}
    battle7.arrReaction[3].arrDamage[1] = {}
    battle7.arrReaction[3].arrDamage[1].damageType = 1
    battle7.arrReaction[3].arrDamage[1].damageValue = 43
    battle7.arrReaction[4] = {}
    battle7.arrReaction[4].defender = 2007244
    battle7.arrReaction[4].reaction = 1
    battle7.arrReaction[4].arrDamage = {}
    battle7.arrReaction[4].arrDamage[1] = {}
    battle7.arrReaction[4].arrDamage[1].damageType = 1
    battle7.arrReaction[4].arrDamage[1].damageValue = 43
    battle7.arrReaction[5] = {}
    battle7.arrReaction[5].defender = 2007245
    battle7.arrReaction[5].reaction = 1
    battle7.arrReaction[5].arrDamage = {}
    battle7.arrReaction[5].arrDamage[1] = {}
    battle7.arrReaction[5].arrDamage[1].damageType = 1
    battle7.arrReaction[5].arrDamage[1].damageValue = 43
    battle7.arrReaction[6] = {}
    battle7.arrReaction[6].defender = 1009235
    battle7.arrReaction[6].reaction = 1
    battle7.arrReaction[6].arrDamage = {}
    battle7.arrReaction[6].arrDamage[1] = {}
    battle7.arrReaction[6].arrDamage[1].damageType = 1
    battle7.arrReaction[6].arrDamage[1].damageValue = 43
    battle7.round = 1
    battle7.action = 1050
    battle7.attacker = 2009241
    battle7.rage = 50
    
    battle[#battle+1] = battle7
    
    
    --battle8
    local battle8 = {}
    battle8.defender = 2007242
    battle8.arrReaction = {}
    battle8.arrReaction[1] = {}
    battle8.arrReaction[1].defender = 2007242
    battle8.arrReaction[1].reaction = 1
    battle8.arrReaction[1].arrDamage = {}
    battle8.arrReaction[1].arrDamage[1] = {}
    battle8.arrReaction[1].arrDamage[1].damageType = 1
    battle8.arrReaction[1].arrDamage[1].damageValue = 43
    battle8.round = 1
    battle8.action = 1010
    battle8.attacker = 2009242
    battle8.rage = 50
    
    battle[#battle+1] = battle8
    
    --battle9
    local battle9 = {}
    battle9.defender = 2007243
    battle9.arrReaction = {}
    battle9.arrReaction[1] = {}
    battle9.arrReaction[1].defender = 2007243
    battle9.arrReaction[1].reaction = 1
    battle9.arrReaction[1].arrDamage = {}
    battle9.arrReaction[1].arrDamage[1] = {}
    battle9.arrReaction[1].arrDamage[1].damageType = 1
    battle9.arrReaction[1].arrDamage[1].damageValue = 43
    battle9.round = 1
    battle9.action = 513
    battle9.attacker = 2009243
    battle9.rage = 50
    
    battle[#battle+1] = battle9
    
    --battle10
    local battle10 = {}
    battle10.defender = 2009243
    battle10.arrReaction = {}
    battle10.arrReaction[1] = {}
    battle10.arrReaction[1].defender = 2009243
    battle10.arrReaction[1].reaction = 1
    battle10.arrReaction[1].arrDamage = {}
    battle10.arrReaction[1].arrDamage[1] = {}
    battle10.arrReaction[1].arrDamage[1].damageType = 1
    battle10.arrReaction[1].arrDamage[1].damageValue = 43
    battle10.round = 1
    battle10.action = 615
    battle10.attacker = 2009244
    battle10.rage = 50
    
    battle[#battle+1] = battle10
    
    --battle11
    local battle11 = {}
    battle11.defender = 2007241
    battle11.arrReaction = {}
    battle11.arrReaction[1] = {}
    battle11.arrReaction[1].defender = 2007241
    battle11.arrReaction[1].reaction = 1
    battle11.arrReaction[1].arrDamage = {}
    battle11.arrReaction[1].arrDamage[1] = {}
    battle11.arrReaction[1].arrDamage[1].damageType = 1
    battle11.arrReaction[1].arrDamage[1].damageValue = 43
    battle11.round = 1
    battle11.action = 1200
    battle11.attacker = 2009241
    battle11.rage = 50
    
    battle[#battle+1] = battle11
    
    --]]
    
    
    
    fightInfo.battle = battle
    
    return fightInfo
end
