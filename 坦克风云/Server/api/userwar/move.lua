-- 行为 移动

function api_userwar_move(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid   = request.uid
    local target_x  = request.params.x or 0
    local target_y  = request.params.y or 0

    if uid == nil or x == 0 or y == 0 then
        response.ret = -102
        return response
    end
     
    if moduleIsEnabled('userwar') == 0 then
        --response.ret = -4012
        --return response
    end
    
    -- 个人锁 防刷数据
    
    local cobjs = getCacheObjs(uid,1,'move')
    local mUserwar = cobjs.getModel('userwar')
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
    local ts = getClientTs()
    local userwarnew = require "model.userwarnew"
    local userWarCfg=getConfig("userWarCfg")
    local warId = userwarnew.getWarId()
    local round = userwarnew.getRound(warId)
    --print('warId',warId)
    if not userwarnew.isEnable() then
        -- response.ret = -4002
        -- return response
    end
    
    if not mUserwar.getApply() then
        response.ret = -23307
        return response
    end

    if mUserwar.mapx == target_x and mUserwar.mapy == target_y  then
        response.ret = -102
        return response
    end
    
    -- 检查是否已死亡
    if not next(mUserwar.binfo) or tonumber(mUserwar.status) >= 2 then
        response = userwarnew.ifOver(response,mUserwar)
        return response
    end
    
    if not userwarnew.ifCanOper(warId,mUserwar.mapx..'-'..mUserwar.mapy,round,uid) then
        response.ret = -23308
        return response
    end
    

    local cost_energy = 0
    local flag = mUserwar.useEnergy(cost_energy)

    if flag then
        local flag = userwarnew.action_move(warId,uid,round,mUserwar.status,mUserwar.mapx,mUserwar.mapy,target_x,target_y)
        if not flag then
            response.ret = -23306
            return response
        end
        mUserwar.mapx = target_x
        mUserwar.mapy = target_y
    else
        -- 体力不足
        response.ret = -23303
        response.msg = 'energy not enough'
        return response
    end

    if cobjs.save() and uobjs.save() then
        response.ret = 0        
        response.msg = 'Success'
        response.data.userwar = mUserwar.toArray(true)
        response.data.userwar.pointlog=nil
    end


    return response
end