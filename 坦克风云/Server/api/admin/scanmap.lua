-- 隐形矿bug 修复
function api_admin_scanmap(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local repair = request.params.repair

    local mMap = require 'lib.map'        
    

    local db = getDbo()        
    uids = db:getAllRows("select uid from userinfo where level>3")

    local retdata = {}
    local problem = {}
    local fleeback = {}
    for m, n in pairs(uids) do 

        local uobjs = getUserObjs(tonumber(n.uid))
        local mTroops = uobjs.getModel('troops')

        for k, v in pairs(mTroops.attack) do
            if not v.bs and tonumber(v.isGather) and tonumber(v.isGather)>1 then
                local mapId = getMidByPos(v.targetid[1], v.targetid[2])
                local map = mMap:getMapById(mapId)
                local oid = tonumber(map.oid) or 0
                if oid ~= tonumber(n.uid) then
                    -- 有问题的号
                    local data = {n.uid, k, oid}
                    table.insert(retdata, data)

                    -- 数据修复
                    if repair then
                        if oid == 0 then -- 没其他人, 重置占领
                            mMap:changeOwner(mapId, n.uid, true)
                        else --有其他玩家，直接撤兵
                            local ret = mTroops.fleetBack(k)
                            local pdata = {n.uid, k, v.targetid[1], v.targetid[2]}
                            if ret and uobjs.save() then
                                table.insert(problem, pdata)
                                writeLog(pdata, 'scanlog')
                            else
                                table.insert(fleeback, pdata)
                                writeLog(pdata, 'scanerror')
                            end
                            -- 发系统邮件
                        end
                    end

                end
            end

        end

    end        

    if not repair then
        response.data.result = retdata
    else
        response.data.problem = problem
        response.data.fleeback = fleeback
    end

    response.ret = 0

    return response
end
