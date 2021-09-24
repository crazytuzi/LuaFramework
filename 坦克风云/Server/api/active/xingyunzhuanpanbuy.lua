-- 幸运转盘购买东西

function api_active_xingyunzhuanpanbuy(request)
    local response = {    
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local id = request.params.id  or "i1" -- 商店物品的id
    if uid == nil then
        response.ret = -102
        return response
    end


    local acname = 'xingyunzhuanpan'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')

    local activStatus = mUseractive.getActiveStatus(acname)
    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local ts = getClientTs()
    local weeTs = getWeeTs()
    local activeCfg = getConfig("active." .. acname.."."..mUseractive.info[acname].cfg)
    if type (mUseractive.info[acname].b)~="table" then  mUseractive.info[acname].b={} end
    
    local buycount=mUseractive.info[acname].b[id] or 0    
    
    local item={}
    for k,v in pairs (activeCfg.shopItem) do
        if v.id ==id then
            item=v
            break
        end
    end
    if not next(item) then
        response.ret=-102 
        return
    end
    if mUseractive.info[acname].v< tonumber(item.price)  or tonumber(item.price)<=0 then
        response.ret=-1981
        return response
    end

    local reward =item.serverReward
    if not takeReward(uid,reward) then        
        response.ret = -403 
        return response
    end

    mUseractive.info[acname].v=mUseractive.info[acname].v-item.price
    mUseractive.info[acname].b[id]=(mUseractive.info[acname].b[id] or 0)  +1
    if uobjs.save() then 
            -- 统计
        response.ret = 0        
        response.msg = 'Success'
    end
    return response
end