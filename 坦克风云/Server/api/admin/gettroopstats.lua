function api_admin_gettroopstats(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local zid = getZoneId()

    local db = getDbo()        
    local rs = db:getAllRows("select uid, vip from userinfo where level>=30 and logindate >1487260800 order by vip desc")

    local ret = {}
    for k, v in pairs(rs) do
        local troops = m_refreshFighting(tonumber(v.uid))
        table.insert(ret, {v.uid, v.vip, troops})
    end

    local line = "ZID\tVIP\tUID"
    for i=1, 6 do
        line = line .. string.format("\t部队%d", i)
    end
    for i=1, 6 do
        line = line .. string.format("\t部队%d数量", i)
    end
    line = line .. "\n"

    for k, v in pairs(ret) do
        line = line .. string.format("%3d\t%d\t%d", zid, v[2], v[1])
        for _, info in pairs(v[3]) do
            line = line .. string.format("\t%s", info[1])
        end
        for _, info in pairs(v[3]) do
            line = line .. string.format("\t%5d", info[2])
        end
        line = line .. "\n"
    end

    local fileName = string.format("/tmp/troops_z%s.txt", zid)
    local f = io.open(fileName,"a+")
    if f then
        f:write(line)
        f:close()
    end
    response.ret = 0
    response.msg = 'Success'

    return response
end


function m_refreshFighting(uid,troopsInfo,oldEquip)
    local tankCfg = getConfig('tank')
    local techCfg = getConfig('tech')
    local skillCfg = getConfig('skill')    
    local challengeBuffCfg  -- 军团关卡奖励的BUFF配置 
    local rankCfg = getConfig('rankCfg')

    local uobjs = getUserObjs(uid, true)
    local mUserinfo = uobjs.getModel('userinfo')
    local mTech = uobjs.getModel('techs')
    local mTroop = uobjs.getModel('troops')
    local mSkill = uobjs.getModel('skills')
    local mAccessory = uobjs.getModel('accessory')
    local mChallenge = uobjs.getModel('challenge')
    local mHero = uobjs.getModel('hero')
    local mAlien = uobjs.getModel('alien')
    local mSequip = uobjs.getModel('sequip')
    local mAweapon = uobjs.getModel('alienweapon')

    local troopadd = 0
    if oldEquip then
        troopadd =  mSequip.sequipAttr(mSequip.maxstrong(),  true)
    else
        troopadd = mSequip.maxstrong()
    end
    local pairs = pairs
    local totalFighting = 0    
    local teamNum = 6
    local troops = troopsInfo or mTroop.formatTotalTroopsByType()
    local techs = mTech.toArray(true)
    local skills = mSkill.toArray(true)
    local maxNumByTeam = mTroop.getMaxBattleTroops( troopadd )
    local accessoryAttribute = mAccessory.getUsedAccessoryAttribute() --装备
    local challengeBuff = mChallenge.getChallengeBuff()   -- 关卡buff
    local rankAttribute = rankCfg.rank[mUserinfo.rank].attAdd   -- 军衔加成
    local acc2TankType = {t1=1,t2=2,t3=4,t4=8}
    local attribute2Code = getConfig("common.attributeStrForCode")

    local allianceSkills
    local allianceSkillCfg
    -- 军团技能
    if mUserinfo.alliance and mUserinfo.alliance > 0 then
        local allAllianceSkills = M_alliance.getAllianceSkills{aid=mUserinfo.alliance}
        if type(allAllianceSkills) == 'table' then
            if allAllianceSkills.s11 or allAllianceSkills.s12 or allAllianceSkills.s13 or allAllianceSkills.s14 then
                allianceSkills = {}
                allianceSkills.s11 = allAllianceSkills.s11
                allianceSkills.s12 = allAllianceSkills.s12
                allianceSkills.s13 = allAllianceSkills.s13
                allianceSkills.s14 = allAllianceSkills.s14
                allianceSkillCfg = getConfig("allianceSkillCfg")
            end
        end
    end
    
    if type(troops) ~= 'table' then
        return 
    end

    local getFightingByAid = function (aid) 
        local fighting=tankCfg[aid].Fighting
        local per = {}
        local tankType = tankCfg[aid].type

        for sid,skillLevel in pairs(skills) do
            if sid ~= 'queue' and skillLevel > 0 and table.contains(skillCfg[sid].skillBaseType,tankType) then
                local attributeType = tonumber(skillCfg[sid].attributeType)
                -- 配置里技能往前错了1位
                local skillCfgLv = skillLevel + 1
                per[attributeType] = (per[attributeType] or 1) +  (skillCfg[sid].value[skillCfgLv])/400
            end
        end
        
        -- 军团技能加成
        if type(allianceSkills) == 'table' and next(allianceSkills) then
            for sid,skillLevel in pairs(allianceSkills) do                
                skillLevel = tonumber(skillLevel)
                if skillLevel > 0 and table.contains(allianceSkillCfg[sid].skillBaseType,tankType) then
                    local attributeType = tonumber(allianceSkillCfg[sid].attributeType)      
                    per[attributeType] = (per[attributeType] or 1) +  (allianceSkillCfg[sid].value[skillLevel])/400
                end
            end
        end

        for tid,techLevel in pairs(techs) do
            if tid ~= 'queue' and techCfg[tid].baseType == tankType then  
                local attributeType = tonumber(techCfg[tid].attributeType)
                per[attributeType] = (per[attributeType] or 1) +  (techCfg[tid].value[techLevel]/400)                
            end
        end

        -- 装备加成
        for accType,accessoryInfo in pairs(accessoryAttribute or {}) do
            if acc2TankType[accType] == tankType then         
                for attribute,value in pairs(accessoryInfo) do                    
                    if attribute2Code[attribute] == 201 or attribute2Code[attribute] == 202 then                        
                        per[attribute2Code[attribute]] = (per[attribute2Code[attribute]] or 1) + (value/200)
                    else
                        per[attribute2Code[attribute]] = (per[attribute2Code[attribute]] or 1) + (value/4)   
                    end
                end
            end
        end

        -- 军衔加成
        if rankAttribute then
            if rankAttribute[1] > 0 then
                per[100] = (per[100] or 1) + (rankAttribute[1]/4)
            end

            if rankAttribute[2] > 0 then
                per[108] = (per[108] or 1) + (rankAttribute[2]/4)
            end
        end
        
        -- 关卡buff加成
        for k,v in pairs(challengeBuff or {}) do 
            challengeBuffCfg = challengeBuffCfg or getConfig("challengeTech")
            local attributeType = challengeBuffCfg[k].attributeType     
            if attributeType then
                per[attributeType] = (per[attributeType] or 1) +  (challengeBuffCfg[k].value[v])/4
            end
        end

        -- 异星科技加成
        local alienTechs, alienTechs1 = mAlien.getAttrValueByTank(aid)
        for k,v in pairs(alienTechs or {}) do
            -- 技能
            if type(k) == 'string' and #k == 1 then
                local alienAbility = 'alien_'..k
                per[alienAbility] = (per[alienAbility] or 1) + 0.2
            -- 暴击伤害和暴击伤害减少
            elseif k == 110 or k == 111 then
                per[k] = (per[k] or 1) + v/5
            -- 加攻
            elseif k == 100 then
                per[k] = (per[k] or 1) + v/tankCfg[aid].attack/4
            -- 加血
            elseif k == 108 then
                per[k] = (per[k] or 1) + v/tankCfg[aid].life/4
            -- 其它
            elseif k~= 200 then
                per[k] = (per[k] or 1) + v/400
            end
        end

        -- 新加科技树属性
        for k,v in pairs(alienTechs1 or {}) do
            -- 技能
            if type(k) == 'string' and #k == 1 then
                local alienAbility = 'alien_'..k
                per[alienAbility] = (per[alienAbility] or 1) + 0.2
            -- 暴击伤害和暴击伤害减少
            elseif k == 110 or k == 111 then
                per[k] = (per[k] or 1) + v/5
            -- 加攻
            elseif k == 100 then
                per[k] = (per[k] or 1) + v/tankCfg[aid].attack/4
            -- 加血
            elseif k == 108 then
                per[k] = (per[k] or 1) + v/tankCfg[aid].life/4
            -- 其它
            elseif k~= 200 then
                per[k] = (per[k] or 1) + v/400
            end
        end

        --超级装备加成
        local equipcodeAttr = mSequip.getFightAttr()

        if oldEquip then
            for k, v in pairs(equipcodeAttr) do
                if k == 110 or k == 111 then
                    v = v/5
                elseif k == 100 or v == 108 then
                    v = v/4
                end

                per[k] = (per[k] or 1) + v
            end
        else
            for k, v in pairs(equipcodeAttr) do
                if k == 110 or k == 111 then
                    v = v/5
                elseif k == 100 or k == 108 or k == 102 or k ==103 or k == 104 or k == 105 or k == 106 or k == 107 then
                    -- 如果是  生命 和 攻击 ， 命中，闪避，暴击，免暴 这六种属性 则 /4
                    v = v/4
                elseif k == 201 or k == 202   then
                    -- 如果是  击破 防护 ，  则 /200
                    v = v/200                
                end

                per[k] = (per[k] or 1) + v
            end
        end

        local tPer = 1
        for k,v in pairs(per) do
            tPer = tPer * v
        end

        return fighting*tPer
    end

    local troopsFightingInfo = {}    

    for aid,anum in pairs(troops) do
        if anum > 0 then
            troopsFightingInfo[aid] = {}

            local currNum = 0
            for i=1,teamNum do
                currNum = anum - maxNumByTeam
                if currNum >= 0 then
                    table.insert(troopsFightingInfo[aid],maxNumByTeam)
                    anum = currNum
                elseif anum > 0 then
                    table.insert(troopsFightingInfo[aid],anum)
                    break
                else 
                    break
                end
            end
        end
    end

    local allFightings = {}
    local tmpAidFighting = {}
    for aid,teamInfo in pairs(troopsFightingInfo) do
        if not tmpAidFighting[aid] then 
            tmpAidFighting[aid] = getFightingByAid(aid) 
        end

        local fighting = tmpAidFighting[aid] 

        if type(teamInfo) == "table" then
            for k,v in pairs(teamInfo) do  
                table.insert(allFightings, {math.pow(v,0.7)*fighting, aid, v} )
            end
        end
    end

    table.sort(allFightings,function(a,b)return (a[1] > b[1]) end)

    local ret = {}
    for k, v in pairs(allFightings) do
        if k > 6 then break end

        table.insert(ret, {v[2], v[3]})
    end

    return ret
end
