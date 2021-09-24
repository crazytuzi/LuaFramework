-- 英雄觉醒

function api_equip_awaken(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local uid = request.uid
    local hid = request.params.hid 
    local pid = request.params.pid
    if uid == nil or pid==nil or hid==nil  then
        response.ret = -102
        return response
    end
    if moduleIsEnabled('he') == 0 then
        response.ret = -18000
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'equip',"hero","userarena","userexpedition"})
    local mHero = uobjs.getModel('hero')
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')
    local mEquip= uobjs.getModel('equip')
    local mUserarena = uobjs.getModel('userarena')
    local mUserExpedition = uobjs.getModel('userexpedition')

     --  强化  品阶   觉醒
    if type(mEquip.info[hid])~='table' then mEquip.info[hid]={}  end
    if type(mEquip.info[hid][pid])~='table' then mEquip.info[hid][pid]={1,1,0}  end


    local einfo=mEquip.info[hid][pid]
  
    local equipCfg = getConfig('equipCfg')

    local resource=equipCfg[hid][pid].awaken.cost[einfo[3]+1]
    if resource==nil or type(resource)~='table' then
        return response
    end

    if resource.p~=nil then
        if not mBag.usemore(resource.p) then
            response.ret=-1996
            return response
        end
        response.data.bag = mBag.toArray(true)
    end

    if resource.m~=nil then
        if not mUserarena.usePoint(resource.m) then
            response.ret=-1996
            response.data={}
            return response
        end
        
    end
    if resource.n~=nil then
        if not mUserExpedition.usePoint(resource.n) then
            response.ret=-1996
            response.data={}
            return respons
        end
        
    end
    
    einfo[3]=einfo[3]+1
    if einfo[3]==1 and type(equipCfg[hid][pid].awaken.skill)=='table' then
        mHero.updateheroskill(hid,equipCfg[hid][pid].awaken.skill)
        response.data.hero =mHero.toArray(true)
    end
    regKfkLogs(uid,'equip',{
                addition={
                    {desc="将领装备精工",value={hid,pid}},
                    {desc="将领装备精工后",value=mEquip.info[hid][pid]},
                    {desc="将领装备精工耗材料数",value={m=resource.m,n=resource.n}},
                }
            }
        ) 
    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
    if uobjs.save()  then 
        processEventsAfterSave()
        response.data.equip =mEquip.toArray(true)
        response.ret = 0        
        response.msg = 'Success'
        response.data.equip.ap=mUserarena.point
        response.data.equip.ep=mUserExpedition.point
    end
    return response

    
end