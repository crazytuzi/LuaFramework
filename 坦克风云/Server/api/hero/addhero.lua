-- 新手引导添加英雄
function api_hero_addhero(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }


    local uid = request.uid
    local hid = request.params.hid or 1
    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('hero') == 0 then
        response.ret = -11000
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive',"hero"})
    local mHero = uobjs.getModel('hero')
    local mUserinfo = uobjs.getModel('userinfo')
    if type(mHero.info.guide )~='table' then mHero.info.guide={} end
    local guide =#mHero.info.guide 
    if mUserinfo.level < 20 then
        response.ret=-11017
        return response
    end

    if guide >2 then
        response.ret=-11001
        return response
    end

    local flag=table.contains(mHero.info.guide, hid)
    if(flag)then
        response.ret=-11001
        return response
    end
    
    local heroCfg = getConfig('heroCfg')
    local addhero = {}
    if hid==1 then
       addhero=(heroCfg.left)
    else
       addhero=(heroCfg.right)
       if getClientBH() == 2 then
            local ret = takeReward(uid,heroCfg.payTicketBouns)
            if not ret then
                response.ret = -403
                return response
            end
       end
    end


    local ret=mHero.addhero(addhero[1],addhero[2])
    local logreward = {}
    logreward['hero_'..addhero[1]]=1
    
    -- 每日任务
    local mDailyTask = uobjs.getModel('dailytask')
    mDailyTask.changeTaskNum1('s1007')

    -- 悬赏任务
    activity_setopt(uid,'xuanshangtask',{t='',e='jz',n=1})
    -- 点亮铁塔
    activity_setopt(uid,'lighttower',{act='jz',num=1}) 
    -- 愚人节大作战-招募x次将领
    activity_setopt(uid,'foolday2018',{act='task',tp='jz',num=1})
    -- 感恩节拼图
    activity_setopt(uid,'gejpt',{act='tk',type='jz',num=1})
    
    -- 英雄等级 ,等级点数，品质
    table.insert(mHero.info.guide,hid)
    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
    if uobjs.save() and ret then 
        processEventsAfterSave()
        -- 系统功能抽奖记录
        setSysLotteryLog(uid,1,"hero.lottery",1,{r=logreward})  
        response.data.hero =mHero.toArray(true)
        response.ret = 0        
        response.msg = 'Success'


    end
    return response

end