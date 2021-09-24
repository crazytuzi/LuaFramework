-- 战报播放

function api_alienweapon_report(request)
    -- body
    local response = {
            ret=-1,
            msg='error',
            data = {},
        }
    if moduleIsEnabled('alienweapon')  == 0 then
        response.ret = -10000
        return response
    end

    local uid = request.uid
    local id = request.params.id
   
    if uid <= 0 then
        response.ret = -102
        return response
    end

    local battlelogLib=require "lib.battlelog"
    local data =battlelogLib:logAweaponGetById(uid,id)

    if data then
        response.data.content = data.content
        response.data.id=data.id
        response.data.isRead=data.isRead
    end
    response.ret=0
    response.msg = 'Success' 
    return response
end