function api_map_alienscout(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local pos = request.params.target
    local uid = request.uid

     -- 参数验证
    if uid == nil or type(pos) ~= 'table' then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end

    local mid = getAlienMineMidByPos(pos.x,pos.y)
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

    local mMap = require "lib.alienmap"
    
    local map = mMap:getMapById(mid)
    local oid = mMap.arrayGet(map,'oid',0)    
    local mapLevel = mMap.arrayGet(map,'level',0)
    local mapType = mMap.arrayGet(map,'type')    
    local ts = getClientTs()  

    -- 侦察空地
    if mapType < 1 or mapType > 6 then
        response.ret = -117
        return response
    end

    -- 岛的保护时间,如果前端没有罩子，此时应该加上
    if (tonumber(map.protect) or 0) > ts then
        response.ret = -5004  
        return response
    end

    -- 异星矿山没有富矿属性
    
    -- 侦察报告
    local report = {
        type = 2,
        info ={
            islandType = mapType,
            place  = {map.x,map.y},
            islandLevel = mapLevel,
        },
        resource = {collect={},battle={}},
    }

    -- 异星矿山没有地形
    
    local scoutConsume = getConfig('map.scoutConsume')
    local mMapObjs = getUserObjs(uid)
    local mMapUserinfo = mMapObjs.getModel('userinfo')

    -- 金币不足
    if not mMapUserinfo.useResource({gold=scoutConsume[mapLevel]}) then 
        response.ret = -108
        return response
    end

    local mapUserNickname = mMapUserinfo.nickname 
    if string.find(mapUserNickname,'-') then
        mapUserNickname = string.gsub(mapUserNickname,'-','—')
    end

    -- 邮件标题
    local mailTitle = '2-'..mapType..'-'..mapUserNickname
    local uobjs,mUserinfo,mTroop,defendFleetInfo

    -- 如果防守者是人
    if oid > 0 then
        uobjs = getUserObjs(oid,true)
        mUserinfo = uobjs.getModel('userinfo')
        mTroop = uobjs.getModel('troops')
        defendFleetInfo = mTroop.getGatherFleetByAlienMineMid(mid)

        if not defendFleetInfo then
            report.defendShip = mMap:getDefenseFleet(mid) or {{},{},{},{},{},{},}
            mMap:changeAlienMapOwner(mid,0)
        else
            -- 邮件
            report.info.islandOwner = oid
            local gatherResource = mMap.arrayGet(defendFleetInfo,'res',{})
            local gatherFleet = mMap.arrayGet(defendFleetInfo,'troops',{{},{},{},{},{},{}})
            
            -- 已采集到的资源量和敌方部队
            report.defendShip = gatherFleet
            report.resource.collect = gatherResource

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

            report.aid = mUserinfo.alliance
            report.info.DAName = mUserinfo.alliancename
        end
    end

    if not report.defendShip then 
        report.defendShip = mMap:getDefenseFleet(mid) or {{},{},{},{},{},{},}
    end
    
    if oid == uid and defendFleetInfo then  
        response.ret = -5013 
        return response
    end

    report.info.ts = ts
    report.info.AAName = mMapUserinfo.alliancename

    if mMapObjs.save() then
        local mail = MAIL:mailSent(uid,1,uid,'',mMapUserinfo.nickname,mailTitle,report,4,1)   

        report = {alienreport={mail}}
        response.data.arrival_time = 0
        response.data.userinfo = mMapUserinfo.toArray(true)
        response.data.mail = report

        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
