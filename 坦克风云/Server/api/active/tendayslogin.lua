-- 昆仑封测10日送礼活动
function api_active_tendayslogin(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid
    local day = tonumber(request.params.day) or -1

    if uid == nil or (day < 1 or day > 10)  then
        response.ret = -102
        return response
    end

    -- 活动名称 ，10日登陆送礼
    local aname = 'tendayslogin'

    -- 加载数据
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","useractive"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mUseractive = uobjs.getModel('useractive')

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then        
        response.ret = activStatus
        return response
    end
    
    -- 注册日期验证
    local regDays =  ((getWeeTs() - getWeeTs(mUserinfo.regdate)) / 86400) + 1
    if regDays < day then
        response.ret = -102
        return response
    end 

    if not mUseractive.info[aname].d then
        mUseractive.info[aname].d = {}
    end

    -- 已经完成此任务了
    if mUseractive.info[aname].c < 0 then
        response.ret = -1984
        return response
    end

    -- 物品已领取
    if table.contains(mUseractive.info[aname].d,day) then
        response.ret = -1976
        return response
    end
    
    local activeCfg = getConfig("active")
    
    if not takeReward(uid,activeCfg[aname].serverreward[day]) then
        return response
    end

    local log = {
        uid=uid,
        parmas=request.params,
        reward=activeCfg[aname].serverreward[day],
    }
    writeLog(log,aname)

    table.insert(mUseractive.info[aname].d,day)

    -- 如果这个任务完成了（因为是永久），把d清空，节省空间
    if #mUseractive.info[aname].d >= 10 then
        mUseractive.info[aname].c = -1
        mUseractive.info[aname].d = nil
    end

    if uobjs.save() then
        response.ret = 0        
        response.msg = 'Success'
    end
    
    return response
end
