function api_military_sweep(request)
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

    local uid = request.uid
    local sweepnum= request.params.num --扫荡次数
    local rank= math.abs(request.params.rank or 0) --对手排名

    if uid<=0 or sweepnum<=0 or sweepnum>5 then
    	response.ret = -102
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
   -- 扫荡次数有误
    if  muserarena.attack_count+sweepnum > muserarena.attack_num then
        response.ret =-102
        return response
    end

    --单次战斗
    local function battle(uid,rank)
    	local retflag={
    	      ret=-1,
        }
	    -- 攻防双方id

	    local defenderId=tonumber(getArenaUidByRank(rank))
	    if not uid or defenderId <= 0 or rank <= 0  then
	        retflag.ret = -102
	        return retflag
	    end

	    if uid ==defenderId  then
	        retflag.ret = -10006
	        return retflag
	    end

	    --没有设置部队
	    if not next(fleetInfo) then 
	        retflag.ret =-10001
	        return retflag
	    end
	   

	    local rewardtime={}
	    local newflag=false
	    if moduleIsEnabled('ma')  == 1 then
	        if ts >=  weeTs+24*3600-arenaCfg.rewardStopWarTime2 then
	            retflag.ret =-10008
	            return retflag
	        end
	        newflag=true
	    else
	        -- 下一领奖时间之前30分钟不能攻击
	        rewardtime=muserarena.getRewardTime(ts)
	        if ts >=  rewardtime[2]-arenaCfg.rewardStopWarTime then
	            retflag.ret =-10011
	            return retflag
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
           
	        if type(hero)=='table' and next(hero) then
	            mHero.refreshFeat("t3",hero,1)
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
	    else
	        muserarena.victory=0
	        -- 扫荡不触发cd时间
	        --muserarena.cdtime_at=ts+arenaCfg.failCD
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
	    --海域航线
    	activity_setopt(uid,'hyhx',{act='tk',type='mb',num=1}) 
        -- 马力全开
        activity_setopt(uid,'mlqk',{act='tk',type='mb',num=1})   
	    -- 将领装备开启才能记积分
	    if moduleIsEnabled('he') == 1 then
	        muserarena.score=muserarena.score+addscore
	    end
	    -- ptb:e(tarvictory)
	    local ret = takeReward(uid,Reward)
	    if not ret then
	        retflag.ret = -403 
	        return retflag
	    end

	    -- 积分翻牌
	    activity_setopt(uid,'jffp',{ac='ar'})
        retflag.ret=0
	    retflag.w=isWin
	    --retflag.r=formatReward(Reward)
	    retflag.r=Reward
	    if type(report)=='table' and next(report) then
	    	retflag.p=report.p
	    end
	    retflag.t=tarvictory
	    retflag.qixi=report
	    return retflag
    end

    -- 扫荡
    local clientRewad={}
    local qixirw={}
    local qixitarv=0
    for i=1,sweepnum do
    	local result=battle(uid,rank)
    	if result.ret~=0  then
    		 response.ret = result.ret
    		return response
    	end
        
    	-- 奇袭
    	if result.qixi==nil then
    		for k,v in pairs(result.r) do
    			qixirw[k] =(qixirw[k] or 0) + v
    		end
    	    qixitarv=result.t
    	else
    		table.insert(clientRewad,{w=result.w,r=formatReward(result.r),p=result.p,tarvictory=result.t})
    	end
    end
    if next(qixirw) then
    	clientRewad={}
    	table.insert(clientRewad,{w=1,r=formatReward(qixirw),tarvictory=qixitarv})
    end

    processEventsBeforeSave()
    if uobjs.save() then
		processEventsAfterSave()
	    response.data.reward = clientRewad
	    response.data.userarena = muserarena.toArray(true)
	    response.ret = 0
	    response.msg = 'Success'
	else
		response.ret =-106
	end    

    return response

end
