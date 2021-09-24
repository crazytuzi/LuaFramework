--   获取异星武器的战报

function api_alienweapon_getlog(request)

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
    local maxeid = request.params.maxeid
    local mineid = request.params.mineid
    local isPage = request.params.isPage
    local content = request.params.content 

    if uid <= 0 then
        response.ret = -102
        return response
    end

    local battlelogLib=require "lib.battlelog"

    local logtype = request.params.logtype -- 1 抢夺日志 2 护航日志
    local list = battlelogLib:logAweaponGet(uid, logtype, maxeid,mineid,isPage,content)

    if list then
        response.data.log = list
    end
    response.ret=0
    response.msg = 'Success' 
    return response
end