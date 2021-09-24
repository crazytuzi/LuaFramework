-- 
-- desc:破译密码
-- user:chenyunhe
-- 玩家每天有一定的免费次数 且每次免费之间有时间间隔
--
function api_territory_crack(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local aid = request.params.aid

    local ts= getClientTs()
    local weeTs = getWeeTs()

    if uid == nil or aid == nil then
        response.ret = -1988
        response.msg = 'params invalid'
        return response
    end

    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')
    local mAterritory = getModelObjs("aterritory",aid,false)

    if not mAterritory.isNormal() then
        response.ret = -102
        return response
    end

    if mUserinfo.alliance==0 or mUserinfo.alliance ~= aid then
        response.ret = - 102
        return response
    end

    -- 维护时间 不能破译
    if mAterritory.maintenance() then
        response.ret = -8411
        return response
    end

    local mTerritorymember = uobjs.getModel('atmember')
    if type(mTerritorymember.crack)~='table' or not next(mTerritorymember.crack) then
         mTerritorymember.crack = {n=0,t=0}
    end

    local lasttime = getWeeTs(mTerritorymember.crack.t)
    if lasttime ~= weeTs then
        mTerritorymember.crack.n = 0 -- 每日非免费破译次数
        mTerritorymember.crack.t = 0  -- 上一次免费破译时间
    end

    local allianceCityCfg = getConfig('allianceCity')
    local allianceBuidCfg = getConfig('allianceBuid')

    local totalnum = allianceCityCfg.worshipFreeNum + allianceCityCfg.worshipCostLimit
    if mTerritorymember.crack.n>=totalnum then
        response.ret = -8410
        return response
    end

    local gems = 0
    --先判断免费次数
    if mTerritorymember.crack.n<allianceCityCfg.worshipFreeNum then
        -- 免费刷新时间未到
        if ts < mTerritorymember.crack.t + allianceCityCfg.worshipIntervalTime then
            response.ret = -25001
            return response
        end
        mTerritorymember.crack.t = ts
    else
        --花钻石
        gems = allianceCityCfg.worshipCost
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end

        if gems>0 then
            regActionLogs(uid, 1, {action = 182, item = "", value = gems, params = {}})
        end
    end
   

    mTerritorymember.crack.n =  mTerritorymember.crack.n+1
    local lv = mAterritory.b3.lv>0 and mAterritory.b3.lv or 1

    local seacoin =allianceBuidCfg.buildValue[3].worship[lv][1]--公海币
    local power =allianceBuidCfg.buildValue[3].worship[lv][2]--能量

    if not mAterritory.addPower(power) then
        response.ret = -403
        return response
    end

    if not mTerritorymember.addSeacoin(seacoin) then
        response.ret = -403
        return response
    end

    -- 任务 累计能量
    if power>0  then
        mAterritory.uptask({act=3,num=power,u=mUserinfo.uid})
    end

    -- 团结之力
    activity_setopt(uid,'unitepower',{id=2,aid=mUserinfo.alliance,num=1})

    processEventsBeforeSave()
    if mAterritory.saveData() and uobjs.save() then
        processEventsAfterSave()
        response.data.atmember =  mTerritorymember.toArray(true)
        response.data.addpower = power
        response.data.addseacoin = seacoin
        response.data.curpower = mAterritory.power

        response.ret = 0
        response.msg = 'Success'
    else			
        response.ret = -1
        response.msg = "save failed"
    end

    return response
end
