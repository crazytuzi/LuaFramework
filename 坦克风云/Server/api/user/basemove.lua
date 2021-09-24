--世界地图上迁徙令
function api_user_basemove(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local target = request.params.target

    if uid == nil then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end

    -- 迁岛加锁
    local mapId = nil
    if target then
        mapId = getMidByPos(target[1],target[2])
        if not commonLock(mapId,"maplock", attacker) then
            response.ret = -5004  
            return response
        end
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')
    local mTroop = uobjs.getModel('troops')
    local mMap = require "lib.map"
    local db = getDbo()
    db.conn:setautocommit(false)

    --------------------------------------------------
    -- 迁岛
    -- 普通迁岛令 15 随机迁移
    -- 高级迁岛令 16 指定地点迁移

    local arrayGet = arrayGet
    local status = 0

    if table.length(mTroop.attack) > 0 then
        if mapId then commonUnlock(mapId, "maplock") end

        response.ret = -2005
        return response
        --tankError('fleet execute attacking')
    end

    if mTroop.hasHelpFleet() then
        if mapId then commonUnlock(mapId, "maplock") end

        response.ret = -2007
        return response
    end

    mTroop.invade = {}
    mTroop.clearHelpDefence()
    mUserinfo.flags.event.f = 1

    local mUserinfoMid = getMidByPos(mUserinfo.mapx,mUserinfo.mapy)
    local gemCost = 0
    local allianceName = ''

    local currLandInfo = mMap:getMapById(mUserinfoMid)
    if mUserinfo.alliance > 0 then
        local isLandInfo = mMap:getMapById(mUserinfoMid)
        allianceName = arrayGet(isLandInfo,'alliance') or mUserinfo.alliancename or ''
        allianceLogo = arrayGet(isLandInfo,'alliancelogo')
    end

    -- 当前基地信息
    if type(currLandInfo.data) == 'table' and next(currLandInfo.data) then
        local nowtime = getClientTs()
        if type(currLandInfo.data.skin) == 'table' and #currLandInfo.data.skin == 4 and currLandInfo.data.skin[4] == 1 
            and (currLandInfo.data.skin[2] <= nowtime and nowtime < currLandInfo.data.skin[3]) then
            currLandInfo.skin = currLandInfo.data.skin[1]
        end
    end
    currLandInfo.skin = currLandInfo.skin or 0
    currLandInfo.data = nil
    local oldland = copyTab( currLandInfo )

    -- 随机迁岛
    if not target then
        local propNums = mBag.getPropNums('p15')
        if (propNums > 0 and mBag.use('p15',1)) then
            target = getMapPos(mUserinfo.uid,mUserinfo.nickname,nil,mUserinfo.level,mUserinfo.fc,mUserinfo.rank,allianceName,mUserinfo.protect,mUserinfo.pic,allianceLogo)
            if type(target) == 'table' then
                mUserinfo.mapx = target.x
                mUserinfo.mapy = target.y
                -- TODO 原地图数据初始化失败怎么办
                if mMap:format(mUserinfoMid,true) or mMap:format(mUserinfoMid,true) then
                    status = 1
                end
                mMap:refreshBaseSkin(uid)
            end
        end

        -- 版号2额外增加点10000点水晶
        if getClientBH() == 2 then
            mUserinfo.addResource{gold=10000}
        end

    else
        local isRemove = false
        local propNums = mBag.getPropNums('p16')
        if (propNums > 0 and mBag.use('p16',1)) then
            isRemove = true
        else
            gemCost = getConfig("prop.p16.gemCost")
            if mUserinfo.useGem(gemCost) then 
                isRemove = true
            end           
        end

        if isRemove then                
            local mid = getMidByPos(target[1],target[2])                 
            local isLandInfo = mMap:getMapById(mid)

            if not isLandInfo then
                if mapId then commonUnlock(mapId, "maplock") end

                response.ret = -6002
                return response
                --tankError('not find mid by target')
            end

            -- 不是空地
            if arrayGet(isLandInfo,'type') ~= 0 then
                if mapId then commonUnlock(mapId, "maplock") end

                response.ret = -6003
                return response
            end

            mUserinfo.mapx = target[1]
            mUserinfo.mapy = target[2]

            -- 更新地图
            local p = {
                level=mUserinfo.level,
                name=mUserinfo.nickname,type=6,
                oid=mUserinfo.uid,
                power=mUserinfo.fc,
                rank=mUserinfo.rank,
                protect=mUserinfo.protect,
                pic=mUserinfo.pic,
                alliance=allianceName,
                allianceLogo=allianceLogo,
                bpic=mUserinfo.bpic,
                apic=mUserinfo.apic,
            }
            if mMap:update(mid,p) then
                -- hwm 20180619 
                -- userinfo有x,y，但map没有数据的情况下，玩家会搬回这个点,搬回后要清空原地图数据，但这种情况
                -- 下，新的坐标点和原坐标点是同一个，所以直接清除的话相当于把刚搬过来的数据又给清掉了。
                -- 所以这里加了一个新坐标点与老从标点不一致的时候，才清除原来的地块数据
                if tonumber(mid) ~= tonumber(mUserinfoMid) then
                    if mMap:format(mUserinfoMid,true) or mMap:format(mUserinfoMid,true) then
                        status = 1
                    end
                else
                    status = 1
                end
                mMap:refreshBaseSkin(uid)
            end

            if gemCost > 0 then
                regActionLogs(uid,1,{action=21,item="basemove",value=gemCost,params={oldMapId=mUserinfoMid,mapId=mid}})
            end
        end
    end 

    ---------------------------------------------------

    local mTask = uobjs.getModel('task')
    mTask.check()

    processEventsBeforeSave()
    
    if status == 1 and uobjs.save() and db.conn:commit() then        
        processEventsAfterSave()
        response.data.mid = getMidByPos(mUserinfo.mapx, mUserinfo.mapy)
        response.data.bag = mBag.toArray(true)
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.status = status
        response.data.oldland = oldland
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
    end

    if mapId then commonUnlock(mapId, "maplock") end
    return response
end
