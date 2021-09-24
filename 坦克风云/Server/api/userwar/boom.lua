-- 系统操作 地块爆炸

function api_userwar_boom(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    if moduleIsEnabled('userwar') == 0 then
        --response.ret = -4012
        --return response
    end

    local ts = getClientTs()
    local userwarnew = require "model.userwarnew"
    local userWarCfg=getConfig("userWarCfg")
    local warId = userwarnew.getWarId()

    if not userwarnew.isEnable() then
        -- response.ret = -4002
        -- return response
    end

    -- for i=1,30 do
        -- local warning_list = userwarnew.getRoundBlast(warId,i)
        -- ptb:p(warning_list)
    -- end
    -- writeLog(json.encode(warning_list),'warning_list')
    -- local uid = request.uid
    -- local uobjs = getUserObjs(uid)
    -- uobjs.load({"userinfo","userwar"})
    -- local mUserwar = uobjs.getModel('userwar')
    -- mUserwar.mapx,mUserwar.mapy = userwarnew.getPlace(bid)
    -- print('x',mUserwar.mapx,'y',mUserwar.mapy)
    
    --uobjs.save()
    
    local userwarlogLib = require "lib.userwarlog"
    local rtype,stype,params = userwarnew.randEvent(116867,'5-3',3000274,0,'a',38)
    userwarlogLib:setRandEvent(3000274,116867,38,rtype,stype,0,params)
    
    
    response.ret = 0
    response.data.warning_list = warning_list
    return response
end