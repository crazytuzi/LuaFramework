-- 免费升级加速
function api_tech_freespeedup(request)
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
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTechs = uobjs.getModel('techs')
    
    local iSlotKey = mTechs.checkIdInSlots(request.params.slotid)
    if type(mTechs.queue[iSlotKey]) ~= 'table' then
        response.ret=-102
        return response
    end
    local et = tonumber(mTechs.queue[iSlotKey].et) or 0
    if et<=0 then
        response.ret=-102
        return response
    end
    local currentTs = getClientTs()                 
    local remainsecs = et - currentTs
    local freespeedtime = getConfig("player.freespeedtime")
    if remainsecs>(freespeedtime[mUserinfo.vip+1]  or freespeedtime[#freespeedtime]) then
        response.ret=-102
        return response
    end
    local tid = mTechs.queue[iSlotKey].id
    mTechs.levelUp(mTechs.queue[iSlotKey].id)
    mTechs.openSlot(iSlotKey)      
   

    local mTask = uobjs.getModel('task')
    mTask.check()

    --日常任务
    local mDailyTask = uobjs.getModel('dailytask')
    --新的日常任务检测
    mDailyTask.changeNewTaskNum('s402',1)
    if uobjs.save() then    
        processEventsAfterSave()
        response.data.techs = mTechs.toArray(true)
        response.data.userinfo = mUserinfo.toArray(true)
        response.ret = 0
        response.msg = 'Success'
        ------------------------删除消息推送 start ----------------------------------------   
        if type (request.push)=='table' and moduleIsEnabled('push') ==1 then
            if request.push.tb[3]~=nil and request.push.tb[3]==1 then
                --加速或取消删除消息
                local execRet, code=M_push.delPushMsg({bindid=request.push.binid,ts=et,id=uid..tid,appid=request.appid})
            end
            
        end
        ------------------------删除消息推送 end   ----------------------------------------  
    end
    return response

end
