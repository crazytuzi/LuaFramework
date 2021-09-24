--
-- 世界大战信息接口
-- User: lmh
-- Date: 14-9-28
-- Time: 下午3:35
--

function api_worldwar_crossinit(request)
    local response = {
        ret=-1,
        msg='error',
        data = {applydata={}},
    }

    local uid = tonumber(request.uid)
    local ts = getClientTs()
    local sevCfg=getConfig("worldWarCfg")
    local zoneid=tonumber(request.zoneid)
    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
        --世界大战基本信息
    local mMatchinfo= mServerbattle.getWorldWarBattleInfo()
    if not next(mMatchinfo)  then
        return response
    end
   
    -- 检测是否报名
    local worldserver = require "model.worldserverin"
    local cross = worldserver.new()
    local ApplyData =cross:getUserApplyData(mMatchinfo.bid,zoneid,uid)
    

    local ts = getClientTs()
    local weets      = getWeeTs()
    local info =json.decode(mMatchinfo.info)
    local sevCfg=getConfig("worldWarCfg")
    local start =tonumber(mMatchinfo.st)
    local endts=start+sevCfg.signuptime*24*3600

    require "model.wmatches"
    local mMatches = model_wmatches()
    if not next(mMatches.base) then
        response.ret = mMatches.errorCode
        return response
    end
    --普通商店
    local shoplist = {'pShopItems' }
    local eliminateTroopsFlag = 1
    start=start+sevCfg.signuptime*24*3600
    local myjoin=0
    --参赛用户可以在精品商店购买物品
    if ApplyData~=nil and next(ApplyData) then
        -- 淘汰赛需要设置部队
        -- writeLog({ts, endts+sevCfg.pmatchdays*24*3600 - 3*3600 - 30, ts - (endts+sevCfg.pmatchdays*24*3600 - 3*3600 - 30)}, 'worldWar')
        if  ts >= (endts+sevCfg.pmatchdays*24*3600 - 3*3600 - 30) and tonumber(ApplyData.eliminateTroopsFlag) ~=1 then
            ApplyData.tinfo = {}
            eliminateTroopsFlag = 0
        end

        table.insert(shoplist, 'aShopItems')
        response.data.applydata.tinfo =json.decode(ApplyData.tinfo)
        response.data.applydata.land= nil
        response.data.applydata.jointype=ApplyData.jointype
        myjoin=tonumber(ApplyData.jointype)
        
        response.data.applydata.line=json.decode(ApplyData.line)
        response.data.applydata.land=json.decode(ApplyData.land)
        response.data.applydata.strategy=json.decode(ApplyData.strategy)
        
    end
    --获取用户的积分信息
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", 'wcrossinfo'})
    local mCrossinfo = uobjs.getModel('wcrossinfo')
    
    -- 拉取积分赛积分
    if type(mCrossinfo.info)~='table' then mCrossinfo.info={}  end
    if mCrossinfo.info.bid~=mMatchinfo.bid then
        mCrossinfo.info.bid=mMatchinfo.bid
        mCrossinfo.info.round=0
        mCrossinfo.info.point=0
    end
    local round =mCrossinfo.info.round or 0
    local pointinfo,newround
    if myjoin>0 then
        mCrossinfo.setMatchId(mMatches.base.matchId, mMatches.base.et,myjoin)
        mMatches.getMultInfo(myjoin)
        local pointinfo,newround=mMatches.getUserPoingInfo(uid,round,zoneid,myjoin)
        if pointinfo.point~=nil and tonumber(pointinfo.point)>mCrossinfo.info.point  then
                mCrossinfo.addScorePoint(tonumber(pointinfo.point)-mCrossinfo.info.point)
                mCrossinfo.info.point=tonumber(pointinfo.point)
        end
        -- 排名前64发邮件
        local clientElimFlag = -1
        if sevCfg.eliminateTroopsFlag == 1 and eliminateTroopsFlag == 0 and pointinfo.userrank and tonumber(pointinfo.userrank) < 64 then
            mMatches.checkEliminateTroops(uid, {et=mMatchinfo.et, ranking=pointinfo.userrank, jointype=myjoin})
            clientElimFlag = 0
        end
        response.data.eliminateTroopsFlag = clientElimFlag
        response.data.score = tonumber(pointinfo.score)
        response.data.ranking = tonumber(pointinfo.userrank)
        response.data.scorepointlog = pointinfo.pointlog
        --刷新参赛用户积分
        if mMatches.checkJoinUser(uid,myjoin) then
            mCrossinfo.bindJoinPoint(mMatches, mMatches.base.matchId,myjoin)
        end

        mCrossinfo.info.round=newround

        -- 报名参赛的类型
        mCrossinfo.info.join =myjoin

        -- 参赛人数
        local count =mMatches.getjoincount(zoneid,myjoin,start)
        response.data.joincount =tonumber(count)
    end
    --检查是否发送大师区服邮件
    if  not mMatches.checkAllUser(1) then
        mMatches.getMultInfo(1)
        mMatches.getAllUserReward(1,zoneid)
    end
    --检查是否发送精英区服邮件
    if  not mMatches.checkAllUser(2) then
        mMatches.getMultInfo(2)
        mMatches.getAllUserReward(2,zoneid)
    end
    local url = getConfig("config.worldwarserver.worldwarserverurl")
    if uobjs.save() then

        response.ret = 0
        response.msg = 'Success'
        mCrossinfo.pointlog.del=nil
        response.data.pointlog=mCrossinfo.pointlog
        response.data.bet      =mCrossinfo.bet
        response.data.point = mCrossinfo.point
        response.data.matchId = mMatchinfo.bid
        response.data.shoplist = shoplist
        response.data.st = mMatchinfo.st
        response.data.et = mMatchinfo.et
        response.data.servers =mMatchinfo.servers
        response.data.url=url
    end
   
    return response



end