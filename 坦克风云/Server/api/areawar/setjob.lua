-- 设置职位

function api_areawar_setjob(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid   = tonumber(request.uid)
    local aid   = tonumber(request.params.aid) or 0
    local memuid= tonumber(request.params.memuid) or 0
    local jobid = tonumber(request.params.jobid) or 0    
    local date  = getWeeTs()

    if uid == nil or  aid == 0  or jobid==0 then
        response.ret = -102
        return response
    end


    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","jobs"})
    local mUserinfo = uobjs.getModel("userinfo")
    local mJobs     = uobjs.getModel("jobs")
    local memuobjs = getUserObjs(memuid)
    memuobjs.load({"userinfo", "techs", "troops","jobs"})
    local memUserinfo = memuobjs.getModel('userinfo')
    local memJobs     =memuobjs.getModel('jobs')
    local areaWarCfg = getConfig('areaWarCfg')
    local ts = getClientTs()
    -- check 职位
    if mJobs.job~=1 or mJobs.end_at<= ts  then
        response.ret=-23012
        return response
    end

    if jobid~=10 then
        if mUserinfo.alliance~=mUserinfo.alliance then
            response.ret=-102
            return response
        end
    end

    local jobs=areaWarCfg.jobs
    if jobs[jobid]==nil then
        response.ret=-102
        return response
    end
    local count=1
    if jobs[jobid].count~=nil and jobs[jobid].count>0 then
        count=jobs[jobid].count
    end


    local execRet,code = M_alliance.setjob{uid=uid,aid=aid,jobid=jobid,memuid=memuid,count=count,buffTime=areaWarCfg.buffTime,point=areaWarCfg.slaveRaising}
    if not execRet then
        response.ret = code
        return response
    end

    if execRet.data.point~=nil then
        response.data.point=execRet.data.point    
    end
    memJobs.job=jobid
    memJobs.aid =aid
    memJobs.end_at=mJobs.end_at
    
    if memuobjs.save() then
            regSendMsg(memuid,'areawar.job',{job=jobid,end_at=mJobs.end_at})  
            local key   ="z" .. getZoneId() .."arenBattleWinAlliance"
            local redis = getRedis() 
            redis:del(key) 
            response.ret = 0
            response.data.info={memuid,memUserinfo.nickname,memUserinfo.level,memUserinfo.fc,memUserinfo.pic}
            response.msg = "Success"
            local mtype=28
            if jobid==10 then
                mtype=29
            end
            local content = {type=mtype,job=jobid,name=execRet.data.name,aname=execRet.data.aname}
            content = json.encode(content)
            MAIL:mailSent(memuid,1,memuid,'',memUserinfo.name,mtype,content,1,0)
    end
    return response
    
end

