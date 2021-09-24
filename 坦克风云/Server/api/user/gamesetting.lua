function api_user_gamesetting(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local sid = request.params.sid    
    local switch = request.params.switch

    if uid == nil or sid == nil or switch == nil then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","troops","task"})
    local mUserinfo = uobjs.getModel('userinfo')

    if not mUserinfo.flags.gameSetting then mUserinfo.flags.gameSetting = {} end
    mUserinfo.flags.gameSetting[sid] = switch
    
    if sid == 's4' then
        local mTroop = uobjs.getModel('troops')
        mTroop.updateDefenseFleet()
    end        
    if sid == 's5' then
        local mMap = require "lib.map"
        mMap:refreshBaseSkin(uid)
    end

    if uobjs.save() then            
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
