-- 检索升级技能 最小等级的技能批量升级
function api_skill_checkupgrade(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})

    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')
    local skill = uobjs.getModel('skills')
    local openlevel=getConfig('skill.openlevel')
    local cfg = skill.getConfig()

    local logskill=copyTab(skill)
    local function getMinlvl(mtype)
        local min=0
        local max=0
        local level=nil
        if mtype==1 then
            min=101
            max=112
        elseif  mtype==2 then
            min=201
            max=210  
        else
            min=301
            max=312     
        end
        local  nocheck={}
        for i=min,max do
            local tmpsid = 's' .. i
        
            local checkflag=table.contains(nocheck, tmpsid) 
            if not checkflag then
                if level ==nil then
                    level=skill[tmpsid]
                end
                if type(cfg[tmpsid].relationSkill)=="table" and next(cfg[tmpsid].relationSkill) then
                    local Smaxlvl=cfg[tmpsid].maxLevel 
                    if skill[tmpsid]<Smaxlvl then
                        local nmax=nil
                        local nid=nil
                        for rk,rid  in pairs(cfg[tmpsid].relationSkill) do
                            if nmax==nil then
                                nid=rid
                                nmax=skill[rid]
                            end
                            if skill[rid]>nmax then
                                nid=rid
                                nmax=skill[rid]
                            end
                        end
                        for rmk,rmid  in pairs(cfg[tmpsid].relationSkill) do
                            if rmid~=nid then
                                local inflag=table.contains(nocheck, rmid) 
                                if not inflag then
                                    table.insert(nocheck,rmid)
                                end
                            end
                        end
                    end
                end

                if level==0 then
                    return level
                end
                if skill[tmpsid] < level then                 
                    sid=tmpsid
                    level=skill[tmpsid]  
                end
            end    
        end
        

        return level
    end


    local function getMinLvlSkills(mtype,minLvl)
        
        local result={}
        local nocheck={}
        -- 计算出最小等级的技能id
        local min=0
        local max=0
        if mtype==1 then
            min=101
            max=112
        elseif  mtype==2 then
            min=201
            max=210  
        else
            min=301
            max=312     
        end

        for i=min,max do
            local tmpsid = 's' .. i
            if type(cfg[tmpsid].relationSkill)=="table" and next(cfg[tmpsid].relationSkill) then
                local Smaxlvl=cfg[tmpsid].maxLevel 
                if skill[tmpsid]<Smaxlvl then
                    local nmax=nil
                    local nid=nil
                    for rk,rid  in pairs(cfg[tmpsid].relationSkill) do
                        if skill[rid]>=cfg[rid].maxLevel then
                            nmax=nil
                            nid=nil
                            break
                        end
                        if nmax==nil  then
                            nid=rid
                            nmax=skill[rid]
                        end
                        if skill[rid]>nmax then
                            nid=rid
                            nmax=skill[rid]
                        end
                    end
                    for rmk,rmid  in pairs(cfg[tmpsid].relationSkill) do
                        if rmid~=nid and nid~=nil then
                            local inflag=table.contains(nocheck, rmid) 
                            if not inflag then
                                table.insert(nocheck,rmid)
                            end
                        end
                    end
                end
            end
            local checkflag=table.contains(nocheck, tmpsid)
            if not checkflag then
                if skill[tmpsid] == minLvl then                 
                    table.insert(result,tmpsid)
                end
            end
        end
        return result
    end

   
    
    -- 军官等级限制
   
    local version  =getVersionCfg()
    local maxLevel =tonumber(version.roleMaxLevel)
    local falg=true
    
    for i=1,4 do
        -- 一介的升级
        if i==1 then
            local level1=getMinlvl(1)
            local level =level1
            for j=level1,maxLevel do
                level=level+1
                if level > tonumber(maxLevel) or  level>mUserinfo.level then
                    break
                end    
                local uskill=getMinLvlSkills(1,level-1)
                local use=true
                if next(uskill) then
                    for k,sid  in pairs(uskill) do
                        local useProp={}
                        for kid,v in pairs (cfg[sid]['needPropID1']) do
                            useProp[kid]=(useProp[kid] or 0)+v[1]*level+v[2]
                        end
                        if not next(useProp) then
                            return response
                        end
                        if not mBag.usemore(useProp) then
                            use=false
                            break
                        else
                            falg=false    
                        end
                        skill.upgrade(sid)
                    end
                else
                    break    
                end
                if use==false then
                    break
                end
            end
        end

        -- 新技能的判断
        if moduleIsEnabled('nbs') == 0 or mUserinfo.level< openlevel then
            break
        end
        -- 2介技能
        if i==2 then
            local level1=getMinlvl(2)
            local level =level1
            for j=level1,maxLevel do
                level=level+1
                if level > tonumber(maxLevel) or  level>mUserinfo.level then
                    break
                end  
                local uskill=getMinLvlSkills(2,level-1)
                local use=true
                if next(uskill) then
                    for k,sid  in pairs(uskill) do
                        local useProp={}
                        local needSkillID=cfg[sid]['needSkillID']
                        local check=true
                        if type(needSkillID)=='table' and next(needSkillID) then
                            for cid ,cv in pairs(needSkillID) do
                                local clevel=cv[1]*level+cv[2]
                                if skill[cid]<clevel then
                                    check=false
                                end
                            end

                        end
                        if check ==false then
                            break
                        end
                        for kid,v in pairs (cfg[sid]['needPropID1']) do
                            useProp[kid]=(useProp[kid] or 0)+v[1]*level+v[2]
                        end
                        if not next(useProp) then
                            return response
                        end
                        if not mBag.usemore(useProp) then
                            use=false
                            break
                        else
                            falg=false    
                        end
                        skill.upgrade(sid)
                    end
                else
                    break    
                end
                if use==false then
                    break
                end

            end    
        end
        if i==3 or i==4 then
            local level1=getMinlvl(3)
            local level =level1
            if level1==nil then
                return response
            end
            for j=level1,maxLevel do
                level=level+1
                if level > tonumber(maxLevel) or  level>mUserinfo.level then
                    break
                end  

                local uskill=getMinLvlSkills(3,level-1)
                local use=true
                if next(uskill) then
                    local len=#uskill
                    for k,sid  in pairs(uskill) do
                        if level>cfg[sid]['maxLevel'] then
                            break
                        end
                        local useProp={}
                        local needSkillID=cfg[sid]['needSkillID']
                        local check=true
                        if type(needSkillID)=='table' and next(needSkillID) then
                            for cid ,cv in pairs(needSkillID) do
                                local clevel=cv[1]*level+cv[2]
                                if skill[cid]<clevel then
                                    check=false
                                end
                            end

                        end
                        if check ==false then
                            break
                        end
                        local needPropID=cfg[sid]['needPropID1']
                          --特殊技能如果满级了 要用id2
                        local  relationSkill=cfg[sid]['relationSkill']
                        if type(relationSkill)=="table" and next(relationSkill) then
                            local Smaxlvl=cfg[sid].maxLevel
                            local maxlvlSid=""
                            for rk,rv in pairs(relationSkill) do
                                if (skill[rv] )>=Smaxlvl then
                                    maxlvlSid=rv
                                    break
                                end
                            end
                            --最大id是空 就是用id1的消耗
                            if maxlvlSid~="" then
                                --  如果最大等级的id不是本次升级id要判断最大等级id是否满级 如果不满级不让升级 如果满级就用2的
                                if maxlvlSid~=sid  then
                                    needPropID=copyTab(cfg[sid]['needPropID2']) 
                                end
                            end
                        end
                        for kid,v in pairs (needPropID) do
                            useProp[kid]=(useProp[kid] or 0)+v[1]*level+v[2]
                        end
                        if not next(useProp) then
                            return response
                        end
                        if not mBag.usemore(useProp) then
                            use=false
                            break
                        else
                            falg=false    
                        end
                        skill.upgrade(sid)
                    end
                else
                    break    
                end
                if use==false then
                    break
                end

            end    
        end    
    end

    if falg then
        response.ret = -1996
        response.msg = 'require prop'
        return response
    end
    -- 战力刷新
    regEventBeforeSave(uid,'e1')

    -- kafkaLog
    regKfkLogs(uid,'action',{
            addition={
                {desc="技能升级前",value=logskill},
                {desc="技能升级后",value=skill.toArray(true)},
            }
        }
    ) 
            
    local mTask = uobjs.getModel('task')
    mTask.check()
    
    processEventsBeforeSave()

    if uobjs.save() then    
        processEventsAfterSave()
        response.data.bag = mBag.toArray(true)
        response.data.skills = skill.toArray(true)
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = 501
        response.msg = 'save failed'
    end
    
    return response
end