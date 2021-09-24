function api_troop_backspeedup(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local cid = request.params.cid

    if uid == nil or cid == nil then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end

    cid = 'c'.. cid

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "hero","props","bag","skills","buildings","dailytask","task", "boom"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')
    local mHero  = uobjs.getModel('hero')
    local mBoom = uobjs.getModel('boom')
    local mSequip = uobjs.getModel('sequip')
    local mPlane = uobjs.getModel('plane')
    local oldRes = {}
    if mTroop.attack[cid] and type(mTroop.attack[cid].res) == 'table' then
        for k,v in pairs(mTroop.attack[cid].res) do
            oldRes [k]=  mUserinfo[k] or 0
        end
    end

    -- 刷新出战舰队队列
    mTroop.updateAttack()

    local ts = getClientTs()    
    if type(mTroop.attack[cid]) ~= 'table' or  mTroop.attack[cid].bs <= ts then
        response.ret = -1989
        return response
    end
    
    local sec = mTroop.attack[cid].bs - ts
    local gems = speedConsumeGems(sec)        
    --活动检测
    gems = activity_setopt(uid,'speedupdisc',{speedtype="troop", gems=gems},false,gems)

    if not mUserinfo.useGem(gems) then
        response.ret = -109 
        return response
    end

    local logmapId = getMidByPos(mTroop.attack[cid].targetid[1],mTroop.attack[cid].targetid[2])
    local logislandType = mTroop.attack[cid].type
    local logtroopsInfo = copyTable(mTroop.attack[cid].troops)
    local logresource = copyTable(mTroop.attack[cid].res)
    
    mTroop.attack[cid].bs = ts
    mTroop.updateAttack()

    local mTask = uobjs.getModel('task')
    mTask.check()
    --日常任务
    local mDailyTask = uobjs.getModel('dailytask')
    --新的日常任务检测
    mDailyTask.changeNewTaskNum('s402',1)
    processEventsBeforeSave()

    local newRes = {}
    if type(logresource) == 'table' then
        for k,v in pairs(logresource) do
            newRes [k]=  mUserinfo[k] or 0
        end
    end
    
    regActionLogs(uid,1,{action=11,item=logmapId,value=gems,params={islandType=logislandType,troopsInfo=logtroopsInfo,resource=logresource,cronId=cid,buyTime=sec,oldRes=oldRes,newRes=newRes}})
    if uobjs.save() then
        processEventsAfterSave()
        response.data.hero={}
        response.data.hero.stats=mHero.stats
        response.data.sequip ={stats = mSequip.stats}
        response.data.plane ={stats = mPlane.stats}
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.troops = mTroop.toArray(true)
        response.data.boom = mBoom.toArray(true)
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = 'save failed'
    end

    return response
end
