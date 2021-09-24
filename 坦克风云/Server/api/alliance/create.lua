function api_alliance_create(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    -- 1为使用资源
    -- 2为使用宝石（金币）
    local consumeType = tonumber(request.params.consumeType) or 1 

    -- 军团宣言，0-200字
    local foreignNotice = tostring(request.params.foreignNotice) or ''

    -- 军团名称，2-6汉字
    local name = tostring(request.params.name) or ''

    -- 加入需要的用户等级
    local joinNeedLv = tonumber(request.params.joinNeedLv) or 0

    -- 加入需要的用户战力
    local joinNeedFc = tonumber(request.params.joinNeedFc) or 0

    -- 成员加入军团方式
    -- 0，自由加入
    -- 1，需要批准
    local joinType = tonumber(request.params.joinType) or 0

    local uid = request.uid
    local nameLen = utfstrlen(name)    
    local maxNameLen = getClientPlat() == 'ship_arab' and 24 or 12

    if uid == nil or nameLen < 3 or nameLen > maxNameLen or utfstrlen(foreignNotice) > 200 then
        response.ret = -102
        return response
    end

    if match(name) then
        response.ret = -8024
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","buildings"})

    local mUserinfo = uobjs.getModel('userinfo')    
    local mBuilding = uobjs.getModel('buildings')    

    -- 军团未解锁
    if not mBuilding.allianceIsUnlock() then
        response.ret = -102
        return response
    end
    
    -- 已经入过盟了
    if mUserinfo.alliance > 0 then
        response.ret = -8001
        return response
    end

    local cfg = getConfig("alliance.createConsume")

    
    
    -- 使用资源
    if consumeType == 1 then
        if not mUserinfo.useResource(cfg[1]) then
            response.ret = -107
            return response
        end

    -- 使用宝石
    else
        -------------------- start vip新特权 vip 大于一定等级创建军团免金币
        local flag = true
        if moduleIsEnabled('vca') == 1 and mUserinfo.vip>0 then
                local vipRelatedCfg = getConfig('player.vipRelatedCfg')
                if type(vipRelatedCfg)=='table' then
                    local vip =vipRelatedCfg.createAllianceGems[1]
                    if mUserinfo.vip>=vip then
                        flag=false
                    end
                end 
                               
        end
        --------------------- end
        if flag and not mUserinfo.useGem(cfg[2])  then
            response.ret = -109 
            return response
        end
    end

    local aData = {} 
    aData.level = 1
    aData.fight = mUserinfo.fc
    aData.desc = foreignNotice
    aData.username = mUserinfo.nickname
    aData.level = mUserinfo.level
    aData.uid = uid
    aData.level_limit = joinNeedLv
    aData.fight_limit = joinNeedFc
    aData.type = joinType
    aData.name = name
    
    if request.params.logo and moduleIsEnabled('alogo') == 1 then
        -- 联盟旗帜（logo）
        local logo = request.params.logo
        local status,cost,logo = M_alliance.checkLogo(logo)
        if status ~= 1 then
            response.ret = -102
            return response
        end
        
        if not mUserinfo.useGem(cost) then
            response.ret = -109 
            return response
        end
        
        aData.logo = json.encode(logo)
    elseif request.params.logo then
        response.ret = -324
        return response
    end

    local execRet,code = M_alliance.create(aData)
    
    if not execRet then
        response.ret = code
        return response
    end

    mUserinfo.alliance = tonumber(execRet.data.alliance.aid)
    mUserinfo.alliancename = name

    -- 资金招募活动
    activity_setopt(uid,'fundsRecruit',{type=-1, name='create'})

    if consumeType == 2 then
        regActionLogs(uid,1,{action=25,item="",value=cfg[2],params={allianceId=mUserinfo.alliance}})
    end

    processEventsBeforeSave()

    if uobjs.save() then
        processEventsAfterSave()

        if mUserinfo.mapx ~= -1 and mUserinfo.mapy ~= -1 then 
            -- 更新地图中的联盟字段
            local mMap = require "lib.map"
            local mid = getMidByPos(mUserinfo.mapx,mUserinfo.mapy)
            local updateData = {}
            updateData.alliance = name
            if moduleIsEnabled('alogo') == 1 and aData.logo then
                updateData.alliancelogo = aData.logo
            end
            mMap:update(mid,updateData)
        end

        response.data.userinfo = mUserinfo.toArray(true)

        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end	