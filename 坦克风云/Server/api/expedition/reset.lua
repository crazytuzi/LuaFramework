-- 重新设置远征军

function api_expedition_reset(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    if uid ==nil then
        response.ret=-102
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","userexpedition","hero","troops"})
    local mUserExpedition = uobjs.getModel('userexpedition')
    local mUserinfo       = uobjs.getModel('userinfo')
    if mUserExpedition.info.grade==nil then
        response.ret=-102
        return response
    end

    if moduleIsEnabled('expedition') == 0 or moduleIsEnabled('hero') == 0  then
      response.ret = -13000
      return response
    end
    local reset=mUserExpedition.reset
    local weets      = getWeeTs()
    if mUserExpedition.reset_at ~=weets then
        reset=0
    end
    local vip=mUserinfo.vip
    local resetNum=getConfig("expeditionCfg.resetNum")
    if reset>=resetNum[vip+1] then
        response.ret=-13003
        return response
    end
    local fc = mUserinfo.fc
    local grade =getExpeditionGrade(fc)
    -- 开启扫荡
    local oldgrade=mUserExpedition.info.grade
    if  mUserExpedition.info.grade <grade then
        mUserExpedition.info.grade=grade
    end
    if moduleIsEnabled('ea') == 1 then
        if mUserExpedition.info.grade==oldgrade then
            if  mUserExpedition.eid==15 and mUserExpedition.info.win==1 then
                mUserExpedition.acount=mUserExpedition.acount+1
            end
        else
            mUserExpedition.acount=0
        end
    end
    local resetRatio=getConfig("expeditionCfg.resetRatio")
    local noweid=mUserExpedition.eid-1
    if mUserExpedition.info.win==1 then
        noweid=mUserExpedition.eid
    end
    mUserExpedition.info.raidgrade=math.ceil(noweid*resetRatio)+1
    mUserExpedition.eid=1
    local ret=mUserExpedition.getInFo(mUserExpedition.info.grade,mUserExpedition.eid)
    if not ret  then
        response.ret=-13004
        return response
    end
    
    -- 春节攀升
    activity_setopt(uid, 'chunjiepansheng', {action='er'})

    mUserExpedition.info.dt=nil
    mUserExpedition.info.dh=nil
    mUserExpedition.reset=reset+1
    mUserExpedition.reset_at=weets
    mUserExpedition.info.r=nil
    mUserExpedition.info.win=nil
    mUserExpedition.info.dse=nil
    if uobjs.save() then  
        mUserExpedition.binfo=nil
        response.data.expedition=mUserExpedition.toArray(true) 
        response.ret = 0
        response.msg = 'Success'
    end


    return response

end
