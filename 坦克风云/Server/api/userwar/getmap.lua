-- 行为 读取地图

function api_userwar_getmap(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid   = request.uid

    if uid == nil then
        response.ret = -102
        return response
    end
     
    if moduleIsEnabled('userwar') == 0 then
        --response.ret = -4012
        --return response
    end

    local cobjs = getCacheObjs(uid,1,'getmap')
    local mUserwar = cobjs.getModel('userwar')
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
    local ts = getClientTs()
    local userwarnew = require "model.userwarnew"
    local userWarCfg=getConfig("userWarCfg")
    local warId = userwarnew.getWarId()
    local round = userwarnew.getRound(warId)

    if not userwarnew.isEnable() then
        -- response.ret = -4002
        -- return response
    end
    
    if not mUserwar.getApply() then
        response.ret = -23307
        return response
    end
    
    -- 检查是否已死亡
    if not next(mUserwar.binfo) or tonumber(mUserwar.status) >= 2 then
        response = userwarnew.ifOver(response,mUserwar)
        return response
    end

    local syncInfo = userwarnew.sync(warId)
    local mapData = userwarnew.getMap(warId)
    local boomx,boomy = userwarnew.getWarning(warId,round)
    
    if boomx and boomy and mapData[boomy][boomx] and tonumber(mapData[boomy][boomx]) == 0 then
        mapData[boomy][boomx][1] = 1
    end
    
    syncInfo.mapData = userwarnew.getWarningInfo(warId,round,mUserwar.mapx,mUserwar.mapy,mapData)
    --userwarnew.setLandUser(warId,mUserwar.mapx..'-'..mUserwar.mapy,uid)

    response.ret = 0        
    response.msg = 'Success'

    response.data.map = syncInfo
    response.data.userwar = mUserwar.toArray(true)
    response.data.userwar.pointlog=nil
    response.data.blast=userwarnew.blast(warId)


    return response
end