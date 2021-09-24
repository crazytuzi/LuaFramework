function api_active_harvestday(request)
    local response = {
        ret=-1,
        msg="error",
        data={}
}



    local uid = request.uid

    if uid == nil then
        response.ret = -102
        return response
    end

    -- 活动名称，收获日 t 是存储排行前十的次数 v 
    local aname = 'harvestDay'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')

    local activStatus = mUseractive.getActiveStatus(aname)

    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
    local activeCfg = getConfig("active")
    local rankCount = activeCfg.harvestDay.serverreward.rankCount
    local joinCount = activeCfg.harvestDay.serverreward.joinCount
    local winCount = activeCfg.harvestDay.serverreward.winCount
   if type(mUseractive.info.harvestDay.r) ~="table" then mUseractive.info.harvestDay.r={} end
    --设置排名的次数到最大数就不用读取缓存
    if mUseractive.info.harvestDay.t< rankCount then
        local t =mUseractive.getalliacerankcount(tostring("a"..mUserinfo.alliance))

        if t> rankCount then
            t =rankCount
        end
        mUseractive.info.harvestDay.t=t
    end
    
    local rt=mUseractive.getActiveInFo(aname,mUserinfo.alliance)
    mUseractive.info.harvestDay.r.t=rt




    --设置自己军团胜利的标识如果有不用读取php
    local date  = getWeeTs()
    local et = mUseractive.info.harvestDay.et
    local st = mUseractive.info.harvestDay.st
    if mUseractive.info.harvestDay.c<= 0 then 
        local execRet,code = M_alliance.getalliance{uid=uid,aid=mUserinfo.alliance,harvestDay=1,acst=st,acet=et,date=date}

        if execRet and execRet.data.warid>0 then
            local mAllianceWar = require "model.alliancewar"
            local opts = mAllianceWar:getWarOpenTs(tonumber(execRet.data.pid),execRet.data.warid)
            if tonumber(execRet.data.join_at) <=opts.et then
                mUseractive.info.harvestDay.c=1;
            end
        end
    end    

    if uobjs.save() then
        response.ret = 0        
        response.data.harvestDay=mUseractive.info.harvestDay
        response.msg = 'Success'
    end
    
    return response
end