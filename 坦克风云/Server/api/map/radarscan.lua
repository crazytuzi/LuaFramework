--[[
    doc:文档2016年5月9日/玩家信息查询道具.docx
    api:搜索雷达
    功能:使用后获得一个玩家当前基地的位置坐标或采矿部队信息
]]

function api_map_radarscan(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local lastTs = request.params.lastTs or 0
    local targetName = request.params.targetName
    local action = tonumber(request.params.action) or 1

    local targetUid = userGetUidByNickname(targetName)
    if targetUid < 1 or targetUid == uid then 
        response.ret = -104 
        return response
    end

    local uobjs = getUserObjs(uid)
    local mBag = uobjs.getModel('bag')

    local ts = getClientTs()
    local mailTitle = ''
    local report = {
        info ={
            ts=ts,
            searchtype=1,
        },
        resource={},
    }

    if action == 1 then
        if not mBag.use("p3304",1) then
            response.ret =-1996
            return response
        end

        local tuobjs = getUserObjs(targetUid,true)
        local tModelUserinfo = tuobjs.getModel('userinfo')

        -- 目标不存在
        if tModelUserinfo.mapx == -1 or tModelUserinfo.mapy == -1 then
            response.ret = -117
            return response
        end

        local tModelBoom = uobjs.getModel('boom')
        tModelBoom.update()

        report.type = 5
        report.info.target = tModelUserinfo.nickname
        report.info.aName = tModelUserinfo.alliancename
        report.info.power = tModelUserinfo.fc
        report.info.glory = {tModelBoom.boom,tModelBoom.boom_max}
        report.info.place  = {tModelUserinfo.mapx,tModelUserinfo.mapy}

        mailTitle = "5-1-" .. (tModelUserinfo.nickname or "")

    elseif action == 2 then
        if not mBag.use("p3305",1) then
            response.ret = -1996
            return response
        end

        local tuobjs = getUserObjs(targetUid,true)
        local tModelUserinfo = tuobjs.getModel('userinfo')
        local tModelTroops = tuobjs.getModel('troops')

        -- 20180511 优化，只能找到type是1-5的部队数据
        -- 在这里重新做一下过滤，影响最好
        local oldScanTroop = tModelTroops.getCanScanTroop()
        local canScanTroop = {}
        for k,v in pairs(oldScanTroop) do
            if v.type > 0 and v.type < 6 then
                table.insert(canScanTroop,v)
            end
        end

        table.sort(canScanTroop,function (a,b)
            return a.dist < b.dist
        end)

        local troop = {}
        local i = 0
        for k,v in pairs(canScanTroop) do
            i = k
            if v.dist > lastTs then
                troop = v
                lastTs = v.dist
                break
            end
        end

        if next(troop) then
            if canScanTroop[i+1] then
                report.info.isHasFleet = 1
            end

            local mMap = require  "lib.map"
            local mid = getMidByPos(troop.targetid[1],troop.targetid[2])
            local map = mMap:getMapById(mid)

            
            report.info.target = tModelUserinfo.nickname
            report.info.aName = tModelUserinfo.alliancename
            report.info.place  = {troop.targetid[1],troop.targetid[2]}
            report.info.islandType = map.type
            report.info.leftTime = troop.ges - ts

            if report.info.leftTime < 0 then report.info.leftTime = 0 end

            local gatherResource = troop.res
            report.defendShip = troop.troops
            report.resource.collect = gatherResource
            report.resource.maxRes = troop.maxRes

            -- 部队战力
            local tmpFormatTroops = {}
            for k,v in pairs(troop.troops) do
                if next(v) then
                    tmpFormatTroops[v[1]] = (tmpFormatTroops[v[1]] or 0) + v[2]
                end
            end
            report.info.power = refreshFighting(targetUid,tmpFormatTroops)
            tmpFormatTroops = nil

            -- if next(gatherResource) then
            --     local rname,rnum = next(gatherResource)
            --     local heatLv = mMap:getHeatLevel(mid)
            --     local islandFlag = troop.goldMine and 1 or 2
            --     report.resource.alienRes = mTroop.goldAddAlien(rname,rnum,troop.AcRate,true,islandFlag,heatLv)
            -- end

            -- -- 有金币
            -- if troop.gems then
            --     report.resource.gems = troop.gems or 0
            -- end
        else
            if i > 0 then
                report.info.searchtype = 3
            else
                report.info.searchtype = 2
            end
        end   

        mailTitle = "6-1-" .. (tModelUserinfo.nickname or "")
        report.type = 6     
    end

    if uobjs.save() then
        local mail = MAIL:mailSent(uid,1,uid,'',"",mailTitle,report,2,1)   
        response.data.mail = {report={mail}}
        response.data.bag = mBag.toArray(true)
        response.data.radarscan={lastTs=lastTs}
        
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
