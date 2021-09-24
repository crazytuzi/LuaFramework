-- 战报播放

function api_military_report(request)
    -- body
    local response = {
            ret=-1,
            msg='error',
            data = {},
        }
    if moduleIsEnabled('military')  == 0 then
        response.ret = -10000
        return response
    end


    local uid = request.uid
    local eid = request.params.eid
   

    if uid <= 0 then
        response.ret = -102
        return response
    end


    local battlelogLib=require "lib.battlelog"

    local data =battlelogLib:logGet(uid,eid)

    if data then

        response.data.content = data.content
       

    end
    response.ret=0
    response.msg = 'Success' 
    return response
end