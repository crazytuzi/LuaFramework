-- 规则--------------
-- 军团事为翻页的方式展现，每页20条
-- 最多纪录2天那内容
function api_alliance_event(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
        
    local aid = tonumber(request.params.aid) or 0    

    -- 事件代号--------------
    -- 1.加入军团
    -- 2.退出军团
    -- 3.被踢出军团
    -- 4.官职设置
    -- 5.团员被攻击
    -- 6.成员贡献达到指定值
    -- 7.军团技能等级升级
    -- 8.军团升级
    -- 9.精英挑战
    local eid = tonumber(request.params.eid) or 0

    local uid = request.uid    

    if uid == nil or aid == 0 or eid == 0 then
        response.ret = -102
        return response
    end
    
    local mAlliance = getAlliance(uid)

    -- 管理员权限
    local admin = mAlliance.getAdminAuthority()
    if not admin then
        response.ret = -8008
        return response
    end

    mAlliance.joinCondition = {
        joinNeedLv = joinNeedLv,
        joinNeedFc = joinNeedFc,
    }
    mAlliance.foreignNotice = foreignNotice
    mAlliance.internalNotice = internalNotice
    mAlliance.joinType = joinType

    if not mAlliance.updateSettings() then
        return response
    end
    
    response.ret = 0
    response.msg = 'Success'
    
    return response
end	