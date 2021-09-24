--  远征扫荡  并领取奖励
function api_funmerge_expedraid(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    if moduleIsEnabled('funmerge') == 0 then
        response.ret = -180
        return response
    end
    if moduleIsEnabled('ea') == 0 then
        response.ret = -13013
        return response
    end

    local uid = tonumber(request.uid)

    if uid == nil then
        response.ret = -102
        return response
    end
   if moduleIsEnabled('expedition') == 0 or moduleIsEnabled('hero') == 0  then
      response.ret = -13000
      return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","userexpedition","hero","troops"})
    local mUserExpedition = uobjs.getModel('userexpedition')
    local mUserinfo       = uobjs.getModel('userinfo')
    local mHero     = uobjs.getModel('hero')
    local acount=getConfig("expeditionCfg.acount")
    local  tolgrade=15
    mUserExpedition.info.win=1
    if mUserExpedition.acount<acount then
       
        if mUserExpedition.info.raidgrade==nil then
            response.ret = -13014
            return response
        else
            if mUserExpedition.info.raidgrade<=0  or mUserExpedition.info.raidgrade<=mUserExpedition.eid then
                response.ret = -13014
                return response
            end    
        end
        tolgrade=mUserExpedition.info.raidgrade
        mUserExpedition.info.win=nil
    end
    local start = mUserExpedition.eid
    local finish = tolgrade
    local count =tolgrade-mUserExpedition.eid
    mHero.refreshFeat("t7",1,count+1)
    mUserExpedition.eid=tolgrade
    
    --自动发奖
    if type(mUserExpedition.info.r)~='table' then  
        mUserExpedition.info.r={}   
    end
    local reward = {}
    local point = 0

    if start>0 and finish>=start then
        for i=start,finish do
            if i <= mUserExpedition.eid then
                local flag=table.contains(mUserExpedition.info.r,i)
                if not flag then
                    local tmpreward,tmppoint = mUserExpedition.getReward(i)
                    if next(tmpreward) then
                        for k,v in pairs(tmpreward) do
                            reward[k] = (reward[k] or 0) + v
                        end
                    end
                    if tmppoint > 0 then
                        point = point + tmppoint
                    end
                    table.insert(mUserExpedition.info.r,i)
                end
            end
        end
    end
    if next(reward) then
        local ret = takeReward(uid,reward)
        if not ret then
            response.ret = -403
            return response
        end
        response.data.reward = formatReward(reward)
    end
    if point>0 then
        mUserExpedition.addResource("point",point)
        response.data.p=mUserExpedition.point
    end
    -- 春节攀升计划活动
    activity_setopt(uid,'chunjiepansheng',{action='ez',num=count+1})
    -- 奥运奖章
    activity_setopt(uid,'aoyunjizhang',{action='eb',num=count+1})
    -- 中秋赏月
    activity_setopt(uid,'midautumn',{action='eb',num=count+1})

    -- 悬赏任务
    activity_setopt(uid,'xuanshangtask',{t='',e='ez',n=1})
    -- 点亮铁塔
    activity_setopt(uid,'lighttower',{act='eb',num=1})
    -- 岁末回馈
    activity_setopt(uid,'feedback',{act='ez',num=1}) 
    --海域航线
    activity_setopt(uid,'hyhx',{act='tk',type='ez',num=count+1})  

    --日常任务
    local mDailyTask = uobjs.getModel('dailytask')
    mDailyTask.changeTaskNum1('s1014',count+1)

    --efun 要记录12-10---12-31 打远征次数 
    local ts = getClientTs()
    if ts>=1449676800   and  ts<=1451577600 then
        local redis = getRedis()
        local statuskey="z."..getZoneId().."efun.stats.expedition"..uid
        local count=redis:incrby(statuskey,count+1)
        redis:expireat(statuskey,1451577600+86400)
    end
    if uobjs.save() then  
        mUserExpedition.binfo=nil
        response.data.expedition=mUserExpedition.toArray(true) 
        response.ret = 0
        response.msg = 'Success'

    end

    return response

end