function api_admin_getUserMetrics(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local db = getDbo()

    local self = {}
    -- 关卡统计
    function self.getChallengeMetric( )
        -- body
        local data = {}
        local result = db:getAllRows("select uid, info from challenge")
        for i, v in pairs(result) do 
            local info = json.decode(v["info"])
            for k, value in pairs(info) do
                local id = string.sub(k, 2,string.len(k))
                data[id] = (data[id] or 0) + 1
            end  
        end

        return data, #result
    end

    --在线时长统计
    function self.getOnlineMetric(ts)
        -- body
        local data = {}
        local len = {600, 1200, 1800, 3600, 10800}
        if not ts then
            ts = getWeeTs()
        end
        local result = db:getAllRows("select uid, olt from userinfo where regdate> :ts", {ts=ts})
        --local result = db:getAllRows("select uid, olt from userinfo")
        for i, v in pairs(result) do 
            local olt = tonumber(v['olt'])
            local flag = false
            for idx, vTime in pairs(len) do
                if olt < vTime then
                    data[idx] = (data[idx] or 0) + 1
                    flag = true
                    break
                end
            end
            if not flag then
                data[#len+1] = (data[#len+1] or 0) + 1
            end

        end

        return data, #result
    end

    ------------------main-----------------------
    local action = tonumber(request.params.action)
    local ts = request.params.ts

    if action==1 then
        response.data.metric, response.data.all=self.getChallengeMetric()
    elseif action==2 then
        response.data.metric, response.data.all=self.getOnlineMetric(ts)
    end

    response.ret = 0
    response.msg = 'Success'
    
    return response

end