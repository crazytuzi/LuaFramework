--
-- 升级统率 批量使用统帅
-- 提高玩家使用效率，提高玩家体验，所以增加统率书一次使用10本的功能；
-- 玩家统率等级不能高于自身等级
-- 这个接口只扣道具
-- 道具不足的情况下客户端会引导玩家购买,保证道具满足十个 
--
function api_user_multitroopsup(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","bag","task","dailytask"})
    local mUserinfo = uobjs.getModel('userinfo')

    local upLevel = mUserinfo.troops or 0

    if upLevel >= mUserinfo.level then
        response.ret = -2003
        return response
    end

    local mBag = uobjs.getModel('bag')
    local propNums = mBag.getPropNums('p20')
    -- 每次都是固定十个
    if propNums<10 then
        response.ret =-1996
        return response
    end

    -- 返回值 {{成功或失败(0失败,1成功,2停止),等级,},{},...}
    local result = {}
    for i=1,10 do
        if mUserinfo.troops < mUserinfo.level then
            local sta,ct,cn--升级成功与否  消耗道具还是钻石 消耗的数量
            local consumeN = 0
            --升级带兵量根据不同平台配置不同
            local platFlag = moduleIsEnabled('luck')
            if platFlag == 1 then
                local luckFlag = getConfig('player.commander_lucky_val')
                if luckFlag then
                    sta,ct,cn = mUserinfo.troopsLevelUpByLuck()
                else
                    sta,ct,cn = mUserinfo.troopsLevelUp()
                end
            else
                sta,ct,cn = mUserinfo.troopsLevelUp()
            end

            local mTask = uobjs.getModel('task')
            mTask.check()
          
            if response.data.ConsumeType == 2 then
                local mDailyTask = uobjs.getModel('dailytask')
                --新的日常任务检测
                mDailyTask.changeNewTaskNum('s405',1)  
                regActionLogs(uid,1,{action=1,item='troopsup',value=consumeN,params={upNum=response.data.status,troopsLevel=mUserinfo.troops}})
            end
            

            -- 版号2额外送一点声望
            if getClientBH() == 2 then
                if response.data.status == 1 then
                    mUserinfo.addResource{honors=1}
                    response.data.bhreward={1}
                else
                    mUserinfo.addResource{honors=2}
                    response.data.bhreward={1,1}
                end
            end
            
            if sta==1 then
                table.insert(result,{1,mUserinfo.troops})
            else
                table.insert(result,{0,mUserinfo.troops})
            end
        else
            table.insert(result,{2,mUserinfo.troops})
            break
        end
    end

    if setUserDailyActionNum(uid,'troopsup') > 10 then
        response.ret = -1973
        return response
    end
    processEventsBeforeSave()
    if uobjs.save() then
        processEventsAfterSave()
             
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.bag = mBag.toArray(true)
        response.data.result = result
        
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = uobjs.msg
    end

    return response
end
