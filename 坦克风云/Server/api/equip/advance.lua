-- 装备进阶
function api_equip_advance(request)
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
    

    if type(mEquip.info[hid])~='table'  or  type(mEquip.info[hid][pid])~='table' then
        response.ret=-102
        return response 
    end

    local equipCfg = getConfig('equipCfg')

    local version  =getVersionCfg()

    if mEquip.info[hid][pid][2]>=version.unEquipLevel then
        response.ret= -18002
        return response
    end

    --英雄的品阶限制装备品阶
    if mEquip.info[hid][pid][2]>=equipCfg.upgradeLimit[mHero.hero[hid][3]] then
       response.ret= -18002
       return response
    end
    
    local einfo=mEquip.info[hid][pid]
    local  resource=equipCfg[hid][pid].upgrade.cost[einfo[2]]
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
            response.ret= -1996
            response.data={}
            return response
        end
        
    end
    einfo[2]=einfo[2]+1
    regKfkLogs(uid,'equip',{
                addition={
                    {desc="将领装备进阶",value={hid,pid}},
                    {desc="将领装备装进阶工后",value=mEquip.info[hid][pid]},
                    {desc="将领装备进阶耗材料数",value={m=resource.m,n=resource.n}},
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