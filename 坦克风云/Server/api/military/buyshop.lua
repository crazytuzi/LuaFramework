 -- 商店购买

function api_military_buyshop(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local id  = tonumber(request.params.id) or 1
    local pid  = request.params.pid
    local count  = tonumber(request.params.count) 
    if uid ==nil or id==nil or pid==nil or count<0 then
        response.ret=-102
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","userarena","hero","troops","bag"})
    local mUserarena = uobjs.getModel('userarena')
    local mUserinfo       = uobjs.getModel('userinfo')
    local mBag       = uobjs.getModel('bag')
    if moduleIsEnabled('expedition') == 0 or moduleIsEnabled('hero') == 0  then
      response.ret = -13000
      return response
    end
    local weets= getWeeTs()
    local ts   = getClientTs()
    if type(mUserarena.info)~='table' then   end
    if type(mUserarena.info.buy)~='table' then mUserarena.info.buy={}  end
    
    local flag=table.contains(mUserarena.info.buy,id)
    if flag then
        response.ret=-13009
        return response
    end
    if type(mUserarena.info.shop[id])~='table' then
        response.ret=-102
        return response
    end 
    local item =mUserarena.info.shop[id]
    if item[1]~=pid or item[2]~=count then
        response.ret=-13010
        return response
    end
    local point=item[3]
    local reward={[item[1]]=count}

    if mUserarena.point< point or point<=0 then 
        response.ret=-10010
        return response
    end

    local ret = takeReward(uid,reward)
    if not ret then
        response.ret = -403
        return response
    end

    table.insert(mUserarena.info.buy,id)
    local old=mUserarena.point
    if not mUserarena.usePoint({p=point}) then
        response.ret=-1996
        return response
    end
    regKfkLogs(uid,'userarena',{
                        addition={
                            {desc="军演商店购买",value=reward},
                            {desc="军演商店购买前勋章",value=old},
                            {desc="军演商店购买后勋章",value=mUserarena.point},
                        },
                        }
                    )
    if uobjs.save() then  
        response.ret = 0
        response.msg = 'Success'
    end

    
    return response 




end