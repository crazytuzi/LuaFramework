-- 升级科技

function api_alien_upgrade(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local pid = request.params.id
    if uid ==nil or  pid==nil  then
        response.ret=-102
        return response
    end
    
    if moduleIsEnabled('alien') == 0 then
        response.ret = -16000
        return response
    end


    local uobjs = getUserObjs(uid)
    uobjs.load({"alien","userinfo","bag","dailytask","troops"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mAlien= uobjs.getModel('alien')
    local mBag  = uobjs.getModel('bag')
    local mTroop = uobjs.getModel('troops')
    local alienTechCfg = getConfig("alienTechCfg")

    if alienTechCfg.talent[pid]==nil then
        response.ret=-16001
        return response
    end 
    local level =mAlien.info[pid] or 0 
    level=level+1
    local maxLv=alienTechCfg.talent[pid][8]
    local unlockLv=alienTechCfg.talent[pid][11]
    local version  =getVersionCfg()

    if unlockLv>version.unlockAlienTech then
        response.ret=-16015
        return response
    end
    if level >maxLv then
        response.ret=-16002
        return response
    end
    -- 上级必需的上级天赋 科技模块等级
    local needTech =alienTechCfg.talent[pid][6]
    if type(needTech)=='table' and next(needTech) then
        if not mAlien.checkTechLevel(needTech) then
            response.ret=-16004
            return  response
        end
    end
    
    -- 需要整体科技的技能等级大于该配置 前置N个科技树(总点数)
    local needLevel =alienTechCfg.talent[pid][7] or 0
    local troopstype=alienTechCfg.talent[pid][2]
    if needLevel>0 then
        if alienTechCfg.tree[troopstype].tech==nil then
            return response
        end
        local c=0
        local flag=false 
        local tmp=alienTechCfg.tree[troopstype].tech
        if next(tmp) then
            local Level= mAlien.getMoreTechLevel(tmp)
            if Level>0 and Level< needLevel then
                response.ret=-16003
                return response
            end
        end
    end
    
    -- 前置1个科技树点数
    local preLevel =alienTechCfg.talent[pid][13] or 0
    if preLevel > 0 then
        local tmp = alienTechCfg.subtree[ alienTechCfg.talent[pid][14] ].tech
        local lvl = mAlien.getMoreTechLevel(tmp)
        if lvl < preLevel then
            response.ret = -16004
            return response
        end
    end

    -- 玩家等级限制
    if mUserinfo.level < (alienTechCfg.talent[pid][12] or 0) then
        response.ret = -16005
        return response
    end

    local talentType=alienTechCfg.talent[pid][3]
    local resourceConsume=alienTechCfg.talent[pid][10]
    if resourceConsume[level]==nil then
        return response
    end

    local resource =resourceConsume[level]

    if resource.u==nil and resource.p==nil and resource.o==nil and resource.r==nil  then
        return response
    end
    if resource.u~=nil then
        if not mUserinfo.useResource(resource.u) then
            response.ret =-107
            return response
        end
        if resource.u.gems~=nil and resource.u.gems>0 then
             local mDailyTask = uobjs.getModel('dailytask')
             mDailyTask.changeTaskNum(7)

                            -- 活动
            activity_setopt(uid,'wheelFortune',{value=resource.u.gems},true)
            activity_setopt(uid,'wheelFortune2',{value=resource.u.gems},true)
            regActionLogs(uid,1,{action=63,item="",value=resource.u.gems,params={level=level,reward=resource}})
        end
        response.data.userinfo = mUserinfo.toArray(true)
    end
    if resource.p~=nil then
        if not mBag.usemore(resource.p) then
            response.ret=-1996
            return response
        end
        response.data.bag = mBag.toArray(true)
    end
    if resource.r~=nil then
        local res = activity_setopt(uid,'aliencard',{act='up',t=pid,value=copyTable(resource.r)})
        if type(res)=="table" and next(res) then
            if not mAlien.useProps(res) then
                response.ret=-16014
                return response
            end
        else
            if not mAlien.useProps(resource.r) then
                response.ret=-16014
                return response
            end
        end
    end
    if resource.o~=nil then
        if next(resource.o) then
            for k,v in pairs(resource.o) do
                if not mTroop.troops[k] or v > mTroop.troops[k] or not mTroop.consumeTanks(k,v) then
                        response.ret = -115
                        return response
                end
            end
        end

        response.data.troops = mTroop.toArray(true)
    end

    mAlien.upgradeLevel(pid)
    if not mAlien.autoAppendTech(pid) then
        response.ret = -16013
        return response
    end

    --废弃 
    --[[
    -- local effectTroops=alienTechCfg.talent[pid][5]

    -- -- 固定类绑定固定坦克 固定技能
    -- if talentType==2 then
    --     if effectTroops[1]~=nil then
    --         effectTroops=effectTroops[1]
    --     end

    --     if mTroop.troops[effectTroops]==nil  then
    --         return response
    --     end
    --     mAlien.useTech(effectTroops,pid)
    -- end
    ]]

    -- 猎杀潜航
    activity_setopt(uid,'silentHunter',{action='rt',num=1,type=troopstype})
    --点亮铁塔
    activity_setopt(uid,'lighttower',{act='rc',num=1}) 
    --德国七日狂欢 
    activity_setopt(uid,'sevendays',{act='sd35',v=0,n=1})    
    -- 节日花朵
    activity_setopt(uid,'jrhd',{act="tk",id="rc",num=1}) 

    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
    if uobjs.save() then 
        processEventsAfterSave()

        response.data.alien = {info=mAlien.info, used=mAlien.used, used1=mAlien.used1,prop=mAlien.prop }
        response.ret = 0        
        response.msg = 'Success'
    end
    
    return response

end