function api_admin_getstats(request)
    local response = {
            ret=-1,
            msg='error',
            data = {},
        }
    
    local statsLib = require "lib.stats"
    local data_name =request.params.data_name
    local ts =       tonumber(request.params.ts)
    if data_name=='accessory' then 

        local stats = statsLib.getAccessory()
        local dailyData = {}
        
        if ts ~=nil then

            if type(stats.dailyData) =='table' then

               for keys,val in pairs (stats.dailyData) do
                    local key = keys:split('_')
                     if type(key) == 'table' then

                        if tonumber(key[1])==ts then  
                            dailyData[keys]=val
                        end

                     end
                end
                

            end

            stats.dailyData=dailyData
        end
        response.data.stats=stats
    end
    -- 检测work是不是最新的
    if request.params.checkserver==1 then
        local redis = getRedis()
        local key="zid."..getZoneId().."checkserver"
        if request.workId~=nil then
            redis:set(key,1)
        else
            redis:set(key,0)
        end
        redis:expire(key,86400)
    end

    response.msg = 'Success'
    response.ret = 0

    return response
end