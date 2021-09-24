-- 系统操作 初始化战斗

function api_userwar_initbattle(request)
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

    local db = getDbo()
    local allSurvival = 0
    local allUser = db:getAllRows("select * from userwar where bid = :bid and `status` = 0",{bid=warId})
    for index,user in pairs(allUser) do
        if user.mapx and user.mapx ~= 0 and user.mapy and user.mapy ~= 0 then
            local uid = tonumber(user.uid) or 0
            local lid = user.mapx..'-'..user.mapy
            userwarnew.setLandUser(warId,lid,uid)
            allSurvival = allSurvival + 1
            local cobjs = getCacheObjs(uid,1,'initbattle')
            cobjs.userGet(uid,{'userwar'})
            
            userwarnew.setSurvivalNum(warId,lid,1)
        end
    end
    
    userwarnew.setAllSurvivalNum(warId,allSurvival)

    response.ret = 0
    response.data = {bid=warId,allSurvival=allSurvival}
    return response
end