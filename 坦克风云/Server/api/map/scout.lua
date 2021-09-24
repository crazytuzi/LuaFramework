function api_map_scout(request)
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
  
    ------------------------------ 侦察生成一份报告数据
    --type 战报类型为3，区别战斗战报
    --islandType 岛屿类型 1~5资源岛，6玩家
    --target 目标名字    
    --level 目标等级
    --place 地点 {x,y}
    --resource 玩家:      可以掠夺5种最大资源量, 
                       -- 资源岛:  占领并采集一种资源 每小时资源量
                       --      如果是资源岛，并且已被占领，则返回占领者的名字，当前已采集到的资源
    --defendShip 防守战船/玩家占领此岛的军队
    --helpDefender 米免101 /协防玩家名字

    local mMap = require  "lib.map"
    local map = mMap:getMapById(mid)
    local oid = mMap.arrayGet(map,'oid',0)    
    local mapLevel = mMap.arrayGet(map,'level',0)
    local mapexp = mMap.arrayGet(map,'exp',0)
    local mapType = mMap.arrayGet(map,'type')    
    local ts = getClientTs()  

    -- 侦察空地
    if mapType < 1 or mapType > 6 then
        response.ret = -117
        return response
    end

    -- 岛的保护时间
    if (tonumber(map.protect) or 0) > ts then
        response.ret = -5004  
        return response
    end

    local heatInfo
    if type(map.data) == 'table' and map.data.heat and (map.data.heat.point or 0) > 0 then
        heatInfo = map.data.heat
    end

     -- 金矿信息
    local goldMineLv,goldLeftTime
    local goldMineMap = mMap:getGoldMine()
    if goldMineMap[tostring(mid)] then
        goldMineLv = goldMineMap[tostring(mid)][3] -- report.goldMineLv
        goldLeftTime = goldMineMap[tostring(mid)][2] -- 金矿消失时间
    end

    mapLevel = mMap:getMapLevel(mapLevel,mapexp,mid)
    
    -- 侦察报告
    local report = {
        type = 2,
        info ={
            islandType = mapType,
            place  = {map.x,map.y},
            islandLevel = mapLevel,
            mapHeat = heatInfo,
        },
        resource = {collect={},battle={}},
    }

    if moduleIsEnabled('lf')==1 then
        report.info.landform = mapType
    end
    
    local scoutConsume = getConfig('map.scoutConsume')
    local mMapObjs = getUserObjs(uid)
    local mMapUserinfo = mMapObjs.getModel('userinfo')

    local mUserinfo = mMapUserinfo
    if tonumber(mUserinfo.hwid) == 1 then
        response.ret = -133
        return response
    elseif type(mUserinfo.hwid) == 'table' then
        local bannedInfo = mUserinfo.hwid
        if (tonumber(bannedInfo[1]) or 0) <= getClientTs() and (tonumber(bannedInfo[2]) or 0) > getClientTs() then
            response.ret = -133
            response.bannedInfo = bannedInfo
            return response
        end
    end

    -- 消耗稀土比例算法
    local goldConsume = scoutConsume[mapLevel]
    if mMapUserinfo.level < mapLevel then
        goldConsume = math.ceil(goldConsume*1.15^(mapLevel - mMapUserinfo.level))
    end

    -- 金币不足
    if not mMapUserinfo.useResource({gold=goldConsume}) then 
        response.ret = -108
        return response
    end
    response.data.goldConsume=goldConsume

    local mapUserNickname = mMapUserinfo.nickname 
    if string.find(mapUserNickname,'-') then
        mapUserNickname = string.gsub(mapUserNickname,'-','—')
    end

    -- 邮件标题
    local mailTitle = '2-'..mapType..'-'..mapUserNickname
    local uobjs,mUserinfo,mTroop
    -- 如果防守者是人
    if oid > 0 then
        uobjs = getUserObjs(oid,true)
        mUserinfo = uobjs.getModel('userinfo')
        mTroop = uobjs.getModel('troops')
        mBoom = uobjs.getModel('boom')
        mBoom.update()
        local oUserNickname = mUserinfo.nickname
        if string.find(oUserNickname,'-') then
            oUserNickname = string.gsub(oUserNickname,'-','—')
        end
        
        mailTitle = mailTitle ..'-'.. oUserNickname
        report.info.attacker = mMapUserinfo.nickname
        report.info.attackerName = mMapUserinfo.nickname
        report.info.attackerLevel = mMapUserinfo.level

        report.info.defenser = oid
        report.info.defenserName = mUserinfo.nickname
        report.info.defenserLevel = mUserinfo.level
        report.info.boom = mBoom.boom
        
        report.aid = mUserinfo.alliance
        report.info.DAName = mUserinfo.alliancename
    end
        
    local mapType = tonumber(mMap.arrayGet(map,'type'))
    if oid == uid then
        if mapType == 6 then
            response.ret = -5013 
            return response
        else
            if mTroop.getGatherFleetByMid(mid) then
                response.ret = -5013 
                return response
            else
                mMap:format(mid)
            end
        end
    end

    -- 侦察的是玩家
    if mapType == 6 then 

        local helpDefender = mUserinfo.nickname
        local hCid,helpDefence = mTroop.getHelpDefenceTroops()

        if type(helpDefence) == 'table' then
            local hUobjs = getUserObjs(helpDefence.uid)
            local hMtroops = hUobjs.getModel('troops')
            report.defendShip = hMtroops.getFleetTroopsByCron(hCid)
            report.helpDefender = helpDefence.name
        end

        if not report.defendShip then 
            report.defendShip = mTroop.getDefenseFleet()
        end                

        if mUserinfo.protect > ts then
            response.ret = -5004  
            return response
        end

        report.resource.battle = mUserinfo.getUnprotectedResource()
    else         
        -- 此岛有驻守玩家，需要获取当前已采集到的资源
        if oid > 0 then
            -- 邮件
            report.info.islandOwner = oid

            local defendFleetInfo = mTroop.getGatherFleetByMid(mid)
            local gatherResource = mMap.arrayGet(defendFleetInfo,'res',{})
            local gatherFleet = mMap.arrayGet(defendFleetInfo,'troops')
            
            if not gatherFleet then
                gatherFleet = {{},{},{},{},{},{}}
            end
            
            report.defendShip = gatherFleet
            -- 已采集到的资源量
            report.resource.collect = gatherResource

            if next(gatherResource) then
                local rname,rnum = next(gatherResource)

                local heatLv = mMap:getHeatLevel(mid) 
                local islandFlag = defendFleetInfo.goldMine and 1 or 2
                report.resource.alienRes = mTroop.goldAddAlien(rname,rnum,defendFleetInfo.AcRate,true,islandFlag,heatLv)
            end

            -- 有金币
            if defendFleetInfo.gems then
                report.resource.gems = defendFleetInfo.gems or 0
            end
        else
            report.defendShip = mMap:getDefenseFleet(mid) or {{},{},{},{},{},{},}
        end
    end

    report.info.ts = ts
    report.info.AAName = mMapUserinfo.alliancename
   
    report.goldMineLv = goldMineLv -- report.goldMineLv
    report.goldLeftTime = goldLeftTime -- 金矿消失时间

    if mMapObjs.save() then
        local mail = MAIL:mailSent(uid,1,uid,'',mMapUserinfo.nickname,mailTitle,report,2,1)    
        report = {report={mail}}
        
        regCheckcode2(uid, request.client_ip)
        response.data.arrival_time = arrival_time
        response.data.userinfo = mMapUserinfo.toArray(true)
        response.ret = 0
        response.data.mail = report
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = 'save failed'
    end

    return response
end
