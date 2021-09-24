--购买cd时间和购买攻击次数 有钱好使
function api_military_buy(request)

    local response = {
        ret=-1,
        msg='error',
        data = {
        },
    }
    -- 军事演习功能关闭
    if moduleIsEnabled('military')  == 0 then
        response.ret = -10000
        return response
    end

  
    -- 攻防双方id
    local uid = request.uid
    local buy = math.abs(request.params.buy or 0)  
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","userarena"})    
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')
    local mUserarena = uobjs.getModel('userarena')
    local mBag =  uobjs.getModel('bag')
    ---  buy =1  就是购买时间   ==2 就是够买可攻击次数
    local ts = getClientTs()
    local arenaCfg = getConfig('arenaCfg')
    if buy==1 then
        local times =mUserarena.cdtime_at-ts
        if times>0 then
            local gemCost = math.ceil(times / arenaCfg.clearCDGold)
            local mUserinfo = uobjs.getModel('userinfo')

            if not mUserinfo.useGem(gemCost) then
                response.ret = -109 
                return response
            end
            mUserarena.cdtime_at=ts
            --日常任务
            local mDailyTask = uobjs.getModel('dailytask')
            --新的日常任务检测
            mDailyTask.changeNewTaskNum('s402',1)
            regActionLogs(uid,1,{action=37,item="",value=gemCost,params={buyNum=times}})
        end
    end

    if buy==2  then
        local atweeTs = getWeeTs(mUserarena.attack_at)
        local ts = getClientTs()
        local weeTs = getWeeTs()
        if atweeTs~=weeTs then
            mUserarena.attack_num=arenaCfg.startChallengingTimes
            mUserarena.attack_count=0
            mUserarena.attack_at=ts
            mUserarena.buy_num=0

        end
        local vip =mUserinfo.vip
        local addcount  = (arenaCfg.buyChallengingTimes["vip"..vip]) or 0
        local newflag=false
        if moduleIsEnabled('ma')  == 1 then
            local newaddcount  = (arenaCfg.buyChallengingTimes2["vip"..vip]) or 0
            addcount=newaddcount*arenaCfg.buyNum
            newflag=true
        end
        if mUserarena.attack_num >=arenaCfg.startChallengingTimes+addcount then 
            response.ret = -10005
            return response
        end
        local propid=arenaCfg.useprop
        local attack_num=1
        if not mBag.use(propid,1) then

            local gemCost = arenaCfg.buyChallengingTimesGold 
            if newflag then
                attack_num=arenaCfg.buyNum
                mUserarena.buy_num=mUserarena.buy_num+1
                gemCost = arenaCfg.buyChallengingTimesGold2[mUserarena.buy_num] 
                if gemCost==nil then
                   gemCost= arenaCfg.buyChallengingTimesGold2[#arenaCfg.buyChallengingTimesGold2] 
                end
            end
            if not mUserinfo.useGem(gemCost) then
                response.ret = -109 
                return response
            end

	    -- 32 购买军事演习的攻击次数  
	    regActionLogs(uid,1,{action=32,item="",value=gemCost,params={buyNum=1}})

        end
       
        mUserarena.attack_num=mUserarena.attack_num+attack_num
      
    end


    if uobjs.save() then
        processEventsAfterSave()
        response.data.userarena = mUserarena.toArray(true)
        response.ret = 0
        response.msg = 'Success'
    end

    return response
    
end