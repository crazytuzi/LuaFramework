-- 系统操作 缓存入库
function api_userwar_endbattle(request)
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
    local num = 0
    local sucess = 0
    local allUser = db:getAllRows("select * from userwar where bid = :bid ",{bid=warId})
    for index,user in pairs(allUser) do
        num = num + 1
        if tonumber(user.uid) then
            local uid = tonumber(user.uid)
            --print('uid',uid)
            local uobjs = getUserObjs(uid,1)
            local mUserwar = uobjs.getModel('userwar')
            local cobjs = getCacheObjs(uid,1,'endbattle')
            local cUserwar = cobjs.getModel('userwar')
            
            local newData = cUserwar.toArray(true)
            for i,v in pairs(newData) do
                if mUserwar[i] then
                    mUserwar[i] = v
                end
            end

            local flag = uobjs.save()
            if flag then
                sucess = sucess + 1
            end
        end
    end

    response.ret = 0
    response.data = {bid=warId,num=num,sucess=sucess}
    return response
end