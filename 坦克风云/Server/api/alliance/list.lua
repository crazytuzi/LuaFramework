-- 军团列表
function api_alliance_list(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid   
    local rc = tonumber(request.params.rc)

    if uid == nil then
        response.ret = -102
        return response
    end

    -- 如果已经加入军团，则给出军团排行列表，自己的军团放在第一位（100以后不显示）
    -- 否则给出推荐列表    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","buildings"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mBuilding = uobjs.getModel('buildings')

    -- 军团未解锁
    if not mBuilding.allianceIsUnlock() then
        response.ret = -113 
        return response
    end

    local execRet

    if rc then
        if rc == 0 then
            execRet = M_alliance.getRecommendList{uid=uid} or {}
        else
            execRet = M_alliance.getList({aid=mUserinfo.alliance,uid=uid}) or {}
        end
    else
        if mUserinfo.alliance == 0 or not mUserinfo.alliance then
            execRet = M_alliance.getRecommendList{uid=uid} or {}   
        else
            execRet = M_alliance.getList({aid=mUserinfo.alliance}) or {}
        end
    end

    if type(execRet.data.ranklist)=='table' then
        -- 领海等级
        for k,v in pairs(execRet.data.ranklist) do
            v.territorylv = 0
            local mTerritory = getModelObjs("aterritory",v.aid,true)
            if mTerritory and mTerritory.isNormal() then
                v.territorylv = tonumber(mTerritory.b1.lv) or 1
            end

            -- 2018/4/10 优化去掉军团资金，外挂会通过列表获取到其它军团剩余资金
            v.point = nil
        end
    end


    if not execRet then
        return response
    end

    response.data.alliance = execRet.data
    response.ret = 0
    response.msg = 'Success'    
    return response
end 