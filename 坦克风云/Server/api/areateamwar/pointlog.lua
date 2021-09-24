-- 获取积分详情

function api_areateamwar_pointlog(request)
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
    require "model.serverbattle"
    local mServerbattle = model_serverbattle()

    local mMatchinfo= mServerbattle.getserverareabattlecfg()
    if not next(mMatchinfo)  then
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","areacrossinfo","userexpedition"})
    local mTroop = uobjs.getModel('troops')
    local mAreacrossinfo = uobjs.getModel('areacrossinfo')

    response.ret = 0
    response.msg = 'Success'
    response.data.pointlog=mAreacrossinfo.pointlog
    return response
end