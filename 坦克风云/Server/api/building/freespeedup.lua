-- 免费升级加速
function api_building_freespeedup(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    if moduleIsEnabled('fs') == 0 then
        response.ret = -180
        return response
    end

    local uid = request.uid
    local bid = request.params.bid and 'b' .. request.params.bid
    local buildType = request.params.buildType

    if uid == nil or bid == nil or buildType == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","useractive"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mBuildings = uobjs.getModel('buildings')

    -- 刷新队列
    mBuildings.update()
    
    local iSlotKey = mBuildings.checkIdInSlots(bid)
    
    if type(mBuildings.queue[iSlotKey]) ~= 'table' or mBuildings.queue[iSlotKey].type ~= buildType then       
        return response
    end

    local et = mBuildings.queue[iSlotKey].et or 0
    if et<=0 then
        response.ret=-102
        return response
    end
    local hid = tonumber(mBuildings.queue[iSlotKey].hid) or 0
    local iGems=0
    local surplusTime=0

        -- todo 宝石计算 
    local currentTs = getClientTs()                 
    surplusTime = et - currentTs
    local freespeedtime = getConfig("player.freespeedtime")
    if surplusTime>(freespeedtime[mUserinfo.vip+1]  or freespeedtime[#freespeedtime]) then
        response.ret=-102
        return response
    end
    if not mBuildings.openSlot(iSlotKey) then
        response.ret = -1992  
        return response
    end

    mBuildings.levelUp(bid,buildType)     

    if hid>0 then
        -- 要删除帮助id
    end

    --没有开启自动升级
    if moduleIsEnabled('autobuild') == 1 then
        local ts = getClientTs()
        if mBuildings.auto == 1 and mBuildings.auto_expire > ts then
            mBuildings.auto = 0
            mBuildings.auto_expire = mBuildings.auto_expire - ts
        end
    end
    
    local mTask = uobjs.getModel('task')
    mTask.check()
    --日常任务
    local mDailyTask = uobjs.getModel('dailytask')
    --新的日常任务检测
    mDailyTask.changeNewTaskNum('s402',1)
    regActionLogs(uid,1,{action=5,item=bid,value=iGems,params={buildingLevel=(mBuildings[bid][2] or 0),buyTime=surplusTime}})
    processEventsBeforeSave()

    if uobjs.save() then        
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.buildings = mBuildings.toArray(true)

        processEventsAfterSave()

        response.ret = 0
        response.msg = 'Success'
        ------------------------删除消息推送 start ----------------------------------------   
        if type (request.push)=='table' and moduleIsEnabled('push') ==1 then
            if request.push.tb[2]~=nil and request.push.tb[2]==1 then
                --加速或取消删除消息
                local execRet, code=M_push.delPushMsg({bindid=request.push.binid,ts=et,id=uid..bid,appid=request.appid})
            end
            
        end
        ------------------------删除消息推送 end   ----------------------------------------   
    end

    return response


end
