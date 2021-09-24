function api_military_battle(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
        },
    }
    -- 军事演习功能关闭
    
    if moduleIsEnabled('military') == 0 then
        response.ret = -10000
        return response
    end

    -- 事务 -----------------------------------------------------------------

    local db = getDbo()
    db.conn:setautocommit(false)
    -- 攻防双方id
    local uid = request.uid
    
    local rank= math.abs(request.params.rank or 0)

    --检测排名npc是否被锁了  没有被锁 先加一个只给排名枷锁 
    local flag=userArenaRankLock(rank) 
    if not flag then
        response.ret =-10009
        return response
    end

    
    local defenderId=tonumber(getArenaUidByRank(rank))

    if not uid or defenderId <= 0 or rank <= 0  then
        response.ret = -102
        return response
    end

    if uid ==defenderId  then
        response.ret = -10006
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","hero","props","bag","skills","buildings","dailytask","task","userarena"})    
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')
    local muserarena = uobjs.getModel('userarena')
    local mHero = uobjs.getModel('hero')  
    local hero = mHero.getAttackHeros('m',1)
    local fleetInfo = muserarena.troops
    local weeTs = getWeeTs()
    local atweeTs = getWeeTs(muserarena.attack_at)
    local arenaCfg = getConfig('arenaCfg')
    local ts = getClientTs()
    
    if atweeTs~=weeTs then
        muserarena.attack_num=arenaCfg.startChallengingTimes
        muserarena.attack_count=0
        muserarena.attack_at=ts
    end
    --把自己也锁起来
    local flag=userArenaRankLock(muserarena.ranking) 
    if not flag then
        response.ret =-10009
        return response
    end

    --没有设置部队
    if not next(fleetInfo) then 
        response.ret =-10001
        return response
    end
    -- 看看有没有cd时间限制
    if muserarena.cdtime_at > ts then
        response.ret =-10003
        return response
    end

    -- 检测今天射了最大次数
    if  muserarena.attack_count >= muserarena.attack_num then
        response.ret =-10004
        return response
    end

    local rewardtime={}
    local newflag=false
    if moduleIsEnabled('ma')  == 1 then
        if ts >=  weeTs+24*3600-arenaCfg.rewardStopWarTime2 then
            response.ret =-10008
            return response
        end
        newflag=true
    else
        -- 下一领奖时间之前30分钟不能攻击
        rewardtime=muserarena.getRewardTime(ts)
        if ts >=  rewardtime[2]-arenaCfg.rewardStopWarTime then
            response.ret =-10011
            return response
        end
    end

    --日常任务
    local mDailyTask = uobjs.getModel('dailytask')
    --新的日常任务检测
    mDailyTask.changeNewTaskNum('s206',1)
    mDailyTask.changeTaskNum1('s1011',1)
    
    local isWin,report
    --攻击的排名是玩家
    local dfuobjs = false
    local dmUserinfo = false
    local dmUserinfo=false
    local dmTroop=false
    local dmuserarena=false
    local tarvictory = 0
    if defenderId>1000000 then
        dfuobjs = getUserObjs(defenderId)
        dfuobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","userarena"})    
        dmUserinfo = dfuobjs.getModel('userinfo')
        dmTroop = dfuobjs.getModel('troops')
        dmuserarena = dfuobjs.getModel('userarena')
        local defFleetInfo = dmuserarena.troops
        tarvictory   = dmuserarena.victory
        isWin,report= muserarena.battle(uid,fleetInfo,defenderId,defFleetInfo,muserarena.ranking,rank)

        if dmuserarena.ranking~=rank then
            --muserarena.repairRank(rank,defenderId)
            --response.ret =-10009
            --return response
        end

    else
        --攻击排名是npc

       
        local arenaNpcCfg = getConfig('arenaNpcCfg')
        local npc = arenaNpcCfg['s'..defenderId]
        report,isWin= muserarena.battlenpc(uid,fleetInfo,npc.tank,npc,{},muserarena.ranking,rank)



    end

    local Reward ={}
    local dfrank =rank
    local addscore=arenaCfg.losePoint
    if isWin == 1 then
        addscore=arenaCfg.winPoint
        local myrank = muserarena.ranking
         --check hero
        if type(hero)=='table' and next(hero) then
            mHero.refreshFeat("t3",hero,1)
        end
        dfrank = rank
        if(myrank>dfrank) then
            --修改排名数据

            muserarena.ranking=dfrank
            muserarena.info.alist=nil
            if newflag==false then
                
                if muserarena.ranked_at <rewardtime[1] then
                    muserarena.ranked=myrank
                    muserarena.ranked_at=ts
                end
            end

            

            if dfuobjs~=false then
                dmuserarena.victory=0
                dmuserarena.ranking=myrank
                dmuserarena.info.alist=nil
                if newflag ==false then
                    if dmuserarena.ranked_at<rewardtime[1] then
                        dmuserarena.ranked =dfrank
                        dmuserarena.ranked_at=ts
                    end
                end
                
            end
            dfrank =myrank
        end

        muserarena.victory=muserarena.victory+1
        Reward=arenaCfg.winReward
        --失败的连胜清除0
        if  dfuobjs~=false  then
             dmuserarena.victory=0
        end

        -- 中秋赏月活动埋点
        activity_setopt(uid, 'midautumn', {action='mw'})
        -- 国庆活动埋点
        activity_setopt(uid, 'nationalDay', {action='mw'})
        -- 开年大吉埋点
        activity_setopt(uid, 'openyear', {action='mw'})
        -- 春节攀升
        activity_setopt(uid, 'chunjiepansheng', {action='mw'})
        -- 点亮铁塔
        activity_setopt(uid,'lighttower',{act='mw',num=1})

        --德国七日狂欢 
        activity_setopt(uid,'sevendays',{act='sd24',v=muserarena.ranking,n=0})   

        
    else
        muserarena.victory=0
        muserarena.cdtime_at=ts+arenaCfg.failCD
        Reward=getRewardByPool(arenaCfg.loseReward)


    end
    muserarena.attack_count=muserarena.attack_count+1
    muserarena.attack_at=ts
    -- 春节攀升
    activity_setopt(uid, 'chunjiepansheng', {action='mc',set=muserarena.victory})

    -- 中秋赏月活动埋点
    activity_setopt(uid, 'midautumn', {action='mb'})
    -- 国庆活动埋点
    activity_setopt(uid, 'nationalDay', {action='mb'})
    -- 春节攀升
    activity_setopt(uid, 'chunjiepansheng', {action='mb'})

    -- 悬赏任务
    activity_setopt(uid,'xuanshangtask',{t='',e='mb',n=1}) 

   -- 点亮铁塔
   activity_setopt(uid,'lighttower',{act='mb',num=1})  
   -- 愚人节大作战-军事演习进行X次战斗
    activity_setopt(uid,'foolday2018',{act='task',tp='mb',num=1})
    --海域航线
    activity_setopt(uid,'hyhx',{act='tk',type='mb',num=1}) 
    -- 马力全开
    activity_setopt(uid,'mlqk',{act='tk',type='mb',num=1})   

         

    -- 将领装备开启才能记积分
    if moduleIsEnabled('he') == 1 then
        muserarena.score=muserarena.score+addscore
    end
    local ret = takeReward(uid,Reward)
    if not ret then
        response.ret = -403 
        return response
    end


  
    processEventsBeforeSave()
    local flag 
    -- 积分翻牌
    activity_setopt(uid,'jffp',{ac='ar'})
    if uobjs.save() then  

        if dfuobjs then
            if dfuobjs.save() and db.conn:commit() then
                flag = true
            end
        else
            if db.conn:commit() then
                flag = true
            end
        end  
       
    end
    if flag==true then
        -- 打开数据库自动提交
        db.conn:setautocommit(true)
        --设置新的排名关系到缓存
        if isWin==1 then

            setArenaRanking(uid,muserarena.ranking)
            
            setArenaRanking(defenderId,dfrank)
        end
        
        processEventsAfterSave()
        response.data.userarena = muserarena.toArray(true)
        response.data.reward = formatReward(Reward)
        response.data.tarvictory =tarvictory
        if report ~=nil then
            report.r=response.data.reward

        end

        response.data.report = report
        response.ret = 0
        response.msg = 'Success'


    end

    return response

end