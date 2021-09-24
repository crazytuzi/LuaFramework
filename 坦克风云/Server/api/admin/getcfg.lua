-- desc: 获取活动配置
-- user: liming
local function api_admin_get(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
    }
    function self.action_get(request)
        local response = self.response
        local cfg = request.params.cfg
        local aname = request.params.aname
        if not cfg or not aname then
            response.ret = -102
            return response
        end
        local activeCfg = getConfig("active/" .. aname)[cfg]
        local table = {}
        if aname == 'lxxf' then
            local maxday = activeCfg.maxDay
            local lastday = activeCfg.lastDay
            table['maxday'] = maxday or 0
            table['lastday'] = lastday or 0
        end
        if aname == 'ljczsjb' then
            local days = activeCfg.days
            local ljczsjbday = 0
            for k,v in pairs(days) do
                ljczsjbday = ljczsjbday + v
            end
            table['ljczsjbday'] = ljczsjbday
        end
        response.data[aname] = table
        response.ret = 0
        response.msg = 'success'
        return response
    end


    return self
end

return api_admin_get
