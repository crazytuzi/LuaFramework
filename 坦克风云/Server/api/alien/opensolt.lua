-- 开启科技的新位置[废弃]

function api_alien_opensolt(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    if true then --接口废弃
        return response
    end
    
    local uid = request.uid
    local tank  =tostring(request.params.ttype)
    local opensolt  =tonumber(request.params.solt) or 0
    if uid ==nil or tank==nil  then
        response.ret=-102
        return response
    end
    
    if moduleIsEnabled('alien') == 0 then
        response.ret = -16000
        return response
    end


    local uobjs = getUserObjs(uid)
    uobjs.load({"alien","userinfo","bag","troops"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mAlien= uobjs.getModel('alien')
    local mBag  = uobjs.getModel('bag')
    local mTroop  = uobjs.getModel('troops')
    local alienTechCfg = getConfig("alienTechCfg")

    if mTroop.troops[tank]==nil then
        response.ret=-102
        return response
    end
    local tankCfg=getConfig('tank.' .. tank)
    local slot,fixed =mAlien.getUnlockOpenSolt(tank,alienTechCfg.talent,tankCfg)
    -- 检测位置数是否够
    if slot+1>tankCfg.alienSlot[2]  then
        response.ret=-16011
        return response
    end
    if slot+1~=opensolt then
        response.ret=-102
        return response
    end
    local key =slot+1-tankCfg.alienSlot[1]
    local resource =tankCfg.slotCost[key]
    if resource.u==nil and resource.p==nil then
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
            regActionLogs(uid,1,{action=64,item="",value=resource.u.gems,params={count=slot+1,reward=resource}})
        end
    end
    if resource.p~=nil then
        if not mBag.usemore(resource.p) then
            response.ret=-1996
            return response
        end
    end
    if resource.r~=nil then
        if not mAlien.useProps(resource.r) then
            response.ret=-16014
            return response
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
    local ret =mAlien.addTankSolt(tank,fixed+slot+1,tankCfg.alienSlot[1]+fixed)
    if not ret then
        return response
    end

    if uobjs.save() then 
        response.data.alien = mAlien.toArray(true)
        response.ret = 0        
        response.msg = 'Success'
    end
    
    return response

end