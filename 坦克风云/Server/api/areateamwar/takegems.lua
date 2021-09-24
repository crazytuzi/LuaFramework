-- 设置军饷

function api_areateamwar_takegems(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local uid = request.uid
    local zid = request.zoneid
    local gems =request.params.gems

    -- 领取的金币数必须大于0
    if gems <= 0 then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","dailytask","areacrossinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mAreacrossinfo    = uobjs.getModel('areacrossinfo') 

    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
    --缓存跨服区域战的基本信息
    local mMatchinfo= mServerbattle.getserverareabattlecfg()
    local sevCfg=getConfig("serverAreaWarCfg")
    local ts = getClientTs()
    local weets      = getWeeTs()
    require "model.areamatches"
    local mMatches = model_areamatches()
    local send=false
    if next(mMatchinfo) then
        send=true
        local start =tonumber(mMatchinfo.st)
        start=start+sevCfg.signuptime*24*3600
        --报名结束时间
        if ts>start then    
            local endts =weets+sevCfg.startWarTime[1]*3600+sevCfg.startWarTime[2]*60+sevCfg.maxBattleTime
            local stts = weets+sevCfg.startWarTime[1]*3600+sevCfg.startWarTime[2]*60-sevCfg.setTroopsLimit
            if ts < endts  and  ts>stts   then
                local info,myround,cross=mMatches.getMatchInfo(zid,mUserinfo.alliance,0)
                if  myround~=nil and  myround>0  then
                    response.ret =-21017
                    return response
                end
            end

        end
    end

    local auserinfo=mMatches.getaMatchUserInfo(mUserinfo.alliance,zid,uid)
    if type(auserinfo)=='table' and   auserinfo.data.userinfo then
        local gems=tonumber(auserinfo.data.userinfo.gems)
        if mAreacrossinfo.gems>gems and auserinfo.data.userinfo.gems~=nil then
                            -- 日常任务
            local mDailyTask = uobjs.getModel('dailytask')
            mDailyTask.changeTaskNum(7)

                            -- 活动
            activity_setopt(uid,'wheelFortune',{value=mAreacrossinfo.gems-gems},true)
            activity_setopt(uid,'wheelFortune2',{value=mAreacrossinfo.gems-gems},true)
            activity_setopt(uid,'xiaofeisongli',{value=mAreacrossinfo.gems-gems})
            activity_setopt(uid,'danrixiaofei',{value=mAreacrossinfo.gems-gems})
            mAreacrossinfo.usegems=mAreacrossinfo.usegems+(mAreacrossinfo.gems-gems)
            mAreacrossinfo.gems=gems
            mAreacrossinfo.usegems_at=ts
        end
                    
    end
    if mAreacrossinfo.gems<gems and gems~=0 then
        gems=mAreacrossinfo.gems
    end

    local ret =mUserinfo.addResource({gems=gems})
    if not ret  then
        response.ret=-403
        return response
    end
    -- 钻石邮件监听
    recordRequest(uid,'nuhai',{num=gems})
    response.data.salaries=gems
    mAreacrossinfo.gems=mAreacrossinfo.gems-gems
    if send then
        local data={}
        data.uid=uid
        data.bid=mAreacrossinfo.bid
        data.aid=mUserinfo.alliance
        data.zid=getZoneId()
        data.level=mUserinfo.level
        data.nickname=mUserinfo.nickname
        data.pic=mUserinfo.pic
        data.rank=mUserinfo.rank
        data.fc=mUserinfo.fc
        data.aname=mUserinfo.alliancname
        data.carrygems=mAreacrossinfo.gems
        data.gems=mAreacrossinfo.gems
        local senddata={cmd='areateamwarserver.setuser',params={data=data,action='update'}}
        local config = getConfig("config.areacrossserver.connect")
        local flag = false
        for i=1,5 do
                local ret=sendGameserver(config.host,config.port,senddata)
                response.ret=-1
                if ret and  ret.ret==0 then
                    flag=true
                    break
                end
                response.ret=ret.ret
        end
           
        if not flag then
            return response
        end
    end

    if uobjs.save() then 
        response.ret = 0        
        response.msg = 'Success'
        response.data.areacrossinfo=mAreacrossinfo.toArray(true)
        response.data.areacrossinfo.pointlog=nil
    end


    return response

end