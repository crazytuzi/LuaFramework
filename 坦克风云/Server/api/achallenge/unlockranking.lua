-- 获取军团解锁排行
-- 默认是前10
-- 如果排名一样，以解锁时间先后排
function api_achallenge_unlockranking(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid

    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('allianceachallenge') == 0 then
        response.ret = -8041
        return response
    end

    local rankingData,code = M_alliance.getList({uid=uid,fbrank=1})
    if type(rankingData) ~= 'table' then
        response.ret = code 
        return response
    end

    response.data.unlockranking = rankingData.data
    response.ret = 0
    response.msg = 'Success'    

    return response
end
