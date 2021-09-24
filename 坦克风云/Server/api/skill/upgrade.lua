-- 技能升级
function api_skill_upgrade(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local sid = 's'..request.params.sid
    local uid = request.uid
    local uplevel =tonumber(request.params.lv or 0)
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})

    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')
    local skill = uobjs.getModel('skills')

    if skill[sid] == nil then
        response.ret = -301
        response.msg = 'sid invalid'
        return response
    end
    
    -- 军官等级限制
    local iUpLevel = skill.getLevel(sid) + 1
    local cfg = skill.getConfig(sid)

    if uplevel<iUpLevel then
        uplevel=iUpLevel
    end
    local ilevelRequire=uplevel

    if ilevelRequire  > mUserinfo.getLevel() then
        response.ret = -301
        response.msg = 'up level Exceeds the user level'
        return response
    end

    -- 升级限制
    local useProp={}
    for iUpLevel=iUpLevel,uplevel do

        if type(cfg.levelRequire)=="table" then --兼容旧格式
            ilevelRequire = cfg.levelRequire[iUpLevel]
        else   
            ilevelRequire = iUpLevel
        end

        local iPropRequire =iUpLevel 

        if cfg.propRequire then  --旧配置数量
            iPropRequire=cfg.propRequire[iUpLevel] or iPropRequire

            useProp['p19']=(useProp['p19'] or 0)+iPropRequire
        else 
            local use={}
            if cfg.needPropID1 then  --新配置数量

                use=copyTab(cfg.needPropID1)
                --特殊技能如果满级了 要用id2
                if type(cfg.relationSkill)=="table" and next(cfg.relationSkill) then
                    local Smaxlvl=cfg.maxLevel
                    if skill[sid]>=Smaxlvl then
                        response.ret=-2047
                        return response
                    end
                    local maxlvlSid=""
                    local maxlvl=0
                    for k,v in pairs(cfg.relationSkill) do
                        if (skill[v] or 0) >maxlvl then
                            maxlvlSid=v
                            maxlvl=skill[v]
                        end
                    end
                    --最大id是空 就是用id1的消耗
                    if maxlvlSid~="" then
                        --  如果最大等级的id不是本次升级id要判断最大等级id是否满级 如果不满级不让升级 如果满级就用2的
                        if maxlvlSid~=sid  then
                            if skill[maxlvlSid]<Smaxlvl then
                                response.ret=-2048
                                return response
                            end 
                            use=copyTab(cfg.needPropID2) 
                        end
                    end
                end


                for k,v in pairs (use) do
                    useProp[k]=(useProp[k] or 0)+v[1]*iUpLevel+v[2]
                end
            else
                useProp['p19']=(useProp['p19'] or 0)+iPropRequire
            end
        end

         -- 检测前置技能是否满级
        local check=true
        if type(cfg.needSkillID)=="table" and next(cfg.needSkillID) then
            for k,v in pairs(cfg.needSkillID) do
                local  id =k
                local clevel=v[1]*iUpLevel+v[2]
                if skill[id]<clevel then
                    check=false
                end
            end 
            if not check then
                response.ret=-2046
                return response
            end

        end
    
        iUpLevel=iUpLevel+1
        skill.upgrade(sid)
    end


    if not next(useProp) then
        return response
    end
    
    if not mBag.usemore(useProp) then
        response.ret = -1996
        response.msg = 'require prop'
        return response
    end

    -- 战力刷新
    regEventBeforeSave(uid,'e1')
        
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