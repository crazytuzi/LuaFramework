-- 开始游戏
function api_fleetgo_start(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    if moduleIsEnabled('fleetgo') == 0 then
        response.ret = -180
        return response
    end
    local uid = request.uid
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local ts= getClientTs()
    local weeTs = getWeeTs()
    -- 当天23:59时间戳
    local currTs = weeTs+86400-1
    local cfg = getConfig('fleetgo')
    local Cfg = copyTab(cfg)
    if mUserinfo.level < Cfg.levelLimit then
        response.ret = -102
        return response
    end
    mUserinfo.flags.gamest = ts --游戏开始时间
    if mUserinfo.flags.playtime == nil then
       mUserinfo.flags.playtime = 0
    end
    -- 初始化每天可玩次数
    if ts > mUserinfo.flags.playtime then
        mUserinfo.flags.playtime = currTs
        mUserinfo.flags.playnum = 0 
    end
    if mUserinfo.flags.playnum + 1 > Cfg.playLimit then
        response.ret = -1973
        return response
    end

    if uobjs.save() then    
        processEventsAfterSave()
        response.ret = 0
        response.msg = 'Success'
    end
    return response

end