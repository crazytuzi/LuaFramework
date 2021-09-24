-- 补给 补充部队
function api_userwar_addtroops(request)
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
    
    local cobjs = getCacheObjs(uid,false,'addtroops')
    local mUserwar = cobjs.getModel('userwar')
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops') 
    local ts = getClientTs()
    local userwarnew = require "model.userwarnew"
    local userWarCfg=getConfig("userWarCfg")
    local warId = userwarnew.getWarId()
    local round = userwarnew.getRound(warId)

    if not userwarnew.isEnable() then
        response.ret = -4002
        return response
    end
    
    if not mUserwar.getApply() then
        response.ret = -23307
        return response
    end
    
    -- if not userwarnew.ifCanOper(warId,mUserwar.mapx..'-'..mUserwar.mapy,round,uid) then
        -- response.ret = -23308
        -- return response
    -- end
    
    -- 检查是否已死亡
    if not next(mUserwar.binfo) or tonumber(mUserwar.status) >= 2 then
        response = userwarnew.ifOver(response,mUserwar)
        return response
    end

    local cost = userWarCfg.support.troops.cost
    local limit = userWarCfg.support.troops.limit or 0
    if mUserwar.support2 >= limit then
        response.ret = -23305
        response.msg = 'support2 max limit'
    end

    local flag,code = mUserwar.cost(cost,mUserinfo)
    if flag then
        local troop = mUserwar.info
        local heros={}
        if type(mUserwar.info.hero)=="table" and next(mUserwar.info.hero) then
            for k,v in pairs (mUserwar.info.hero) do
                if v~=0 then
                    local hero = v:split('-')
                    table.insert(heros,hero[1])
                else
                    table.insert(heros,v)
                end
            end
        end
        local binfo,heroAccessoryInfo = mTroop.gettroopsinfo(mUserwar.info.troops,heros,mUserwar.info.equip,mUserwar.info.plane)
        mUserwar.support_addTroops(binfo)
    else
        -- 行动条件不满足
        response.ret = -23303
        response.msg = code..' not enough'
        return response
    end
    
    if cobjs.save(true) and uobjs.save() then 
        response.ret = 0        
        response.msg = 'Success'
        
        response.data.userwar = mUserwar.toArray(true)
        response.data.userwar.pointlog=nil
    end

    return response
end