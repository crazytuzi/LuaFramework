-- 侦察叛军
function api_map_rebelscout(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local filterRet = Filter.scoutCaptcha(request)
    if filterRet then
        -- 客户端要求有验证码的时候ret必需返回0
        if filterRet.ret ~= 0 then
            response = filterRet
            response.ret = 0
            response.msg = 'Success'
            return response
        end

        if filterRet.data.captchaReward then
            response.data.captchaReward = filterRet.data.captchaReward
        end
    end

    local pos = request.params.target
    local uid = request.uid

     -- 参数验证
    if uid == nil or type(pos) ~= 'table' then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end

    local mid = getMidByPos(pos.x,pos.y)
    if not mid then
        response.ret = -118
        return response
    end

    local mRebel = loadModel("model.rebelforces")
    local rebelInfo = mRebel.getRebelInfo(mid)

    if rebelInfo.isDie then
        response.ret = -117
        return response
    end

    local mMapObjs = getUserObjs(uid)
    local mMapUserinfo = mMapObjs.getModel('userinfo')

    local mapLevel = rebelInfo.level
    local mapType = rebelInfo.mapType
    local ts = getClientTs()

    -- 水晶不足
    local scoutConsume = getConfig("rebelCfg.troops.scoutConsume")
    if not mMapUserinfo.useResource({gold=scoutConsume[mapLevel]}) then 
        response.ret = -108
        return response
    end

    local mapUserNickname = mMapUserinfo.nickname 
    if string.find(mapUserNickname,'-') then
        mapUserNickname = string.gsub(mapUserNickname,'-','—')
    end
    
    -- 侦察报告
    local report = {
        type = 2,
        info ={
            islandType = mapType,
            place  = {pos.x,pos.y},
            islandLevel = mapLevel,
            AAName = mMapUserinfo.alliancename,
            landform = getLandformByPos(pos.x,pos.y),
            ts = ts,
        },
        rebel = {
            rebelID = rebelInfo.force,
            rebelExpireTs = rebelInfo.expireTs,
        },
        defendShip = rebelInfo.troops,
    }

    if mMapObjs.save() then
        local rebelName = mapLevel .. "," .. rebelInfo.force
        local mailTitle = table.concat({"2",mapType,mapUserNickname,rebelName},"-")
        local mail = MAIL:mailSent(uid,1,uid,'',mMapUserinfo.nickname,mailTitle,report,2,1)   

        report = {report={mail}}
        response.data.mail = report

        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
