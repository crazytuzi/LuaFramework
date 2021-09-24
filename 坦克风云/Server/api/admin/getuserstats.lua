function api_admin_getuserstats(request)
    local response = {
            ret=-1,
            msg='error',
            data = {},
        }

    local data_name =request.params.data_name
    local db = getDbo()

    local result = db:getAllRows("select uid from userinfo where vip>7")
    if not result then
        response.msg='db err'
        return response
    end

    local ret = {}
    for k , v in pairs(result) do 
        local uobjs = getUserObjs(tonumber(v.uid))
        local mTroops = uobjs.getModel('troops')        

        local totalTroops =mTroops.formatTotalTroopsByType()
        if totalTroops then
            ret[v.uid] = {
                        totalTroops.a10082 or 0, 
                        totalTroops.a10093 or 0,
                        totalTroops.a10063 or 0,
                        totalTroops.a10073 or 0,
                        totalTroops.a10043 or 0,
                        totalTroops.a10053 or 0,
                    }
        end
    end

    response.data.troops = ret
    response.msg = 'Success'
    response.ret = 0

    return response
end