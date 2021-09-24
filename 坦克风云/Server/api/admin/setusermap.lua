function api_admin_setusermap(request)
    local response = {
        data = {},
        config = {},
        ret = -1,
        msg = 'Success'
    }

    -- 新加的一段检测玩家地图的逻辑
    -- 玩家被击飞的操作里先清空了地图，而后才保存用户的坐标数据
    -- 就有可能会出现地图被清空但用户数据保存失败了的情况
    local action = request.params.action
    if action == "checkUserMap" then
        local uid = tonumber(request.params.uid)
        if uid then
            local uobjs = getUserObjs(uid)
            local mUserinfo = uobjs.getModel('userinfo')
            local mMap = require "lib.map"

            if mUserinfo.level >= 3 and (mUserinfo.mapx > 0 and mUserinfo.mapy > 0) then
                local mid = getMidByPos(mUserinfo.mapx,mUserinfo.mapy)
                local isLandInfo = mMap:getMapById(mid)

                if type(isLandInfo) == "table" then
                    local randFlag = false
                    
                    -- 对应的地块是个空地
                    if tonumber(isLandInfo.type) == 0 then
                        -- 如果是被击飞,或者是大领海战期间(有击飞的操作),随机一个坐标
                        if request.params.blow or getModelObjs("aterritory").checkTimeOfWar(1) then
                            randFlag = true

                        -- 否则应该改回原来的地方
                        else
                            local p = {
                                level=mUserinfo.level,
                                name=mUserinfo.nickname,
                                type=6,
                                oid=mUserinfo.uid,
                                power=mUserinfo.fc,
                                rank=mUserinfo.rank,
                                protect=mUserinfo.protect,
                                pic=mUserinfo.pic,
                                alliance=mUserinfo.allianceName,
                                bpic=mUserinfo.bpic,
                                apic=mUserinfo.apic,
                            }

                            if mMap:update(mid,p) then
                                mMap:refreshBaseSkin(uid)
                            end

                            writeLog({"setusermap","updateMap:",mid})

                            response.msg = 'Success'
                            response.ret = 0
                            return response
                        end

                    -- 对应的地块是个主基地,但不是我的
                    elseif tonumber(isLandInfo.type) == 6 and tonumber(isLandInfo.oid) ~= uid then
                        -- 直接随机一个坐标
                        randFlag = true
                    end

                    if randFlag then
                        local mapData = getMapPos(
                                uid,
                                mUserinfo.nickname,
                                false,
                                mUserinfo.level,
                                mUserinfo.fc,
                                mUserinfo.rank,
                                mUserinfo.alliancename,
                                mUserinfo.protect,
                                mUserinfo.pic)

                        if type(mapData) ~= 'table' then
                            tankError('getMapPos failed'.. (mapData and tostring(mapData) or ''))
                        end

                        if mapData.x and mapData.y then
                            mUserinfo.mapx = tonumber(mapData.x)
                            mUserinfo.mapy = tonumber(mapData.y)
                        end

                        mMap:refreshBaseSkin(uid)

                        sendMsgByUid(uid,json.encode({data={event={f=1}},cmd="msg.event"}))

                        writeLog({"setusermap","randMap:",uid,mapData.x,mapData.y})

                        uobjs.save()
                    end
                end
            end

            local db = getDbo()
            local data = db:getAllRows("select id,x,y from map where oid = :uid and type = 6",{uid=uid})

            for k,v in pairs(data) do
                if type(v) == "table" and v.id then
                    if tonumber(v.x) ~= mUserinfo.mapx or tonumber(v.y) ~= mUserinfo.mapy then
                        mMap:format(tonumber(v.id),true)
                        writeLog({"setusermap","cleanMap:",v.id,uid,v.x,v.y,mUserinfo.mapx,mUserinfo.mapy})
                    end
                end
            end
        end

        response.msg = 'Success'
        response.ret = 0
        return response
    end
        
    local uids = request.params.uids
    local ts = getClientTs() 

    if type(uids) == 'table' then
        for _,uid in pairs(uids) do
            uid = tonumber(uid) or 0
            if uid > 0 then
                local uobjs = getUserObjs(uid,true)
                local mUserinfo = uobjs.getModel('userinfo')
                local mBoom = uobjs.getModel('boom')

                if mUserinfo.level >= 3 and (mUserinfo.mapx == -1 or mUserinfo.mapy == -1) then
                    -- 合服后，等级大于等于5的，保护时间为6小时
                    local ptime = mUserinfo.level >= 5 and 21600 or 86400
                    local protect = ts + ptime

                    local setProp = true
                    if (tonumber(mUserinfo.protect) or 0) > protect then
                        protect = tonumber(mUserinfo.protect)
                        setProp = false
                    end

                    local boom
                    if moduleIsEnabled('boom') == 1 then
                        boom = {boom=mBoom.boom,bmax=mBoom.boom_max,bm_at=mBoom.boom_ts,bmd=mBoom.bmd}
                    end
                    local mapData = getMapPos(uid,mUserinfo.nickname,false,mUserinfo.level,mUserinfo.fc,mUserinfo.rank,'',protect,mUserinfo.pic,boom) 
                    if type(mapData) ~= 'table' then
                        tankError('getMapPos failed'.. (mapData and tostring(mapData) or ''))
                    end

                    mUserinfo.mapx = mapData.x
                    mUserinfo.mapy = mapData.y
                    mUserinfo.protect = protect

                    if setProp then
                        local mProp = uobjs.getModel('props')
                        local bSlotInfo = {} 
                        bSlotInfo.st = ts
                        bSlotInfo.et = protect
                        bSlotInfo.id = 'p14'
                        mProp.usePropSlot(bSlotInfo.id,bSlotInfo)
                    end
                end
                
                if uobjs.save() then
                    table.insert(response.data,{uid,mapx,mapy})
                end
            end
        end
    end

    response.msg = 'Success'
    response.ret = 0
    return response
end