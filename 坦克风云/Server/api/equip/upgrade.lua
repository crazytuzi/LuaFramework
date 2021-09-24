-- 强化

function api_equip_upgrade(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local uid = request.uid
    local hid = request.params.hid 
    local pid = request.params.pid
    local method=tonumber(request.params.method) or 1
    if uid == nil or pid==nil or hid==nil  then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('he') == 0 then
        response.ret = -18000
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive',"hero","equip"})
    local mHero = uobjs.getModel('hero')
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')
    local mEquip= uobjs.getModel('equip')
    local equipCfg = getConfig('equipCfg')

    if type (mHero.hero[hid]) ~='table' then
        -- 英雄不存在
        response.ret=-11002
        return response
    end
 

    --  强化  品阶   觉醒
    if type(mEquip.info[hid])~='table' then mEquip.info[hid]={}  end
    if type(mEquip.info[hid][pid])~='table' then mEquip.info[hid][pid]={1,1,0}  end
    local count=1
    local einfo=mEquip.info[hid][pid]
    local maxcount= equipCfg.growLimit[einfo[2]]-einfo[1]

    if equipCfg[hid][pid]==nil then
        response.ret=-102
        return response
    end

    if einfo[1]>=equipCfg.growLimit[einfo[2]] then
        response.ret=-18001
        return response
    end
    if method==2 then
        count=maxcount
    end

    for i=1,count do
        local res=equipCfg[hid][pid].grow.cost[einfo[1]]
        if res==nil then
            break
        end
        if res.f~=nil then

          local ret=  mEquip.useResource(res.f)
          if not ret then
            if i==1 then
                response.ret=-1996
                return  response
            end
            break
          end
        end
        einfo[1]=einfo[1]+1
    end

    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
    if uobjs.save() then 
        processEventsAfterSave()
        response.data.equip =mEquip.toArray(true)
        response.ret = 0        
        response.msg = 'Success'
    end
    return response


end
