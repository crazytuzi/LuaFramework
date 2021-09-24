--
-- baifudali
-- User: luoning
-- Date: 14-11-18
-- Time: 下午7:02
--
function api_active_baifudali(request)

    local aname = 'baifudali'

    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid
    local action = request.params.action

    if uid == nil or action == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local activeCfg = getConfig("active."..aname.."."..mUseractive.info[aname].cfg)

    if action == "getreward" then

        if not mUseractive.info[aname].m then
            mUseractive.info[aname].m = 0
        end

        if mUseractive.info[aname].v < activeCfg.goldcondition then
            response.ret = -1981
            return response
        end

        if mUseractive.info[aname].m == 1 then
            response.ret = -401
            return response
        end

        if not takeReward(uid, {userinfo_gems=activeCfg.goldreward}) then
            return response
        end

        mUseractive.info[aname].m = 1

    elseif action == "dailyreward" then

        local weelTs = getWeeTs()
        if tonumber(mUserinfo.level) < activeCfg.levellimit then
            response.ret = -1981
            return response
        end
        if mUseractive.info[aname].t >= weelTs then
            response.ret = -1981
            return response
        end
        if not takeReward(uid, activeCfg.serverreward.daily) then
            return response
        end
        mUseractive.info[aname].t = weelTs

    end

    if (action=="getreward" or action == "dailyreward") and uobjs.save() then
        response.msg = "Success"
        response.ret = 0
    end

    return response
end

