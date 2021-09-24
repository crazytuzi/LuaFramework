--
-- 商店购买记录
-- User: lmh
-- Date: 15-03-30
-- Time: 下午11:40
--
function api_worldwar_record(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local jointype = request.params.jointype or 0
    local zoneid=request.zoneid
    if uid == nil  then
        response.ret = -102
        return response
    end

    --检查比赛是否可押注
    require "model.wmatches"
    local mMatches = model_wmatches()

    if not next(mMatches.base) then
        response.ret = mMatches.errorCode
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive','wcrossinfo'})
    local mCrossinfo = uobjs.getModel('wcrossinfo') 

    mCrossinfo.setMatchId(mMatches.base.matchId, mMatches.base.et,jointype)
    if type(mCrossinfo.info)~='table' then mCrossinfo.info={}  end
    if mCrossinfo.info.bid~=mMatches.base.matchId then
        mCrossinfo.info.bid=mMatches.base.matchId
        mCrossinfo.info.round=0
        mCrossinfo.info.point=0
    end
   
    local round =mCrossinfo.info.round or 0
    if jointype>0 then
        mMatches.getMultInfo(jointype)
        if mMatches.checkJoinUser(uid,jointype) then
            mCrossinfo.bindJoinPoint(mMatches, mMatches.base.matchId,jointype)
        end
        local pointinfo,newround=mMatches.getUserPoingInfo(uid,round,zoneid,jointype)
        if pointinfo.point~=nil and tonumber(pointinfo.point)>mCrossinfo.info.point  then
                mCrossinfo.addScorePoint(tonumber(pointinfo.point)-mCrossinfo.info.point)
                mCrossinfo.info.point=tonumber(pointinfo.point)
        end
        mCrossinfo.info.round=round
        response.data.scorepointlog = pointinfo.pointlog
        response.data.score = tonumber(pointinfo.score)
        response.data.ranking = tonumber(pointinfo.userrank)
        response.data.scorepointlog = pointinfo.pointlog
    end
    local record = mCrossinfo.getPointRecord(mMatches.base.matchId)
    response.data.record = record
    response.data.point = mCrossinfo.point
    if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end

